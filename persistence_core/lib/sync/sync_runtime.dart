import 'dart:async';

import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/model/ports.dart';
import 'package:persistence_core/model/types.dart';

/// A pure-Dart runtime wrapper around [SyncCoordinator].
///
/// Why this exists:
/// - [SyncCoordinator] provides single-run primitives (`pushOnce`, `pullOnce`).
/// - Apps typically need lifecycle + scheduling glue: start/stop, periodic runs,
///   online/offline gating, scope(uid) switching, and a status stream.
/// - This runtime remains framework-agnostic (no Flutter / Provider dependency).
///
/// Integration guidance:
/// - Flutter/app layer should translate lifecycle events into:
///   - [setScopeUid] on login/logout
///   - [setOnline] on connectivity changes
///   - [start]/[stop] on app foreground/background if desired
class SyncRuntime {
  /// Creates a [SyncRuntime].
  ///
  /// Parameters:
  /// - [coordinator]: The core sync engine. Must be configured with the
  ///   appropriate `OutboxStore`, `RemoteGateway`, and optionally
  ///   `SyncStateStore` + `LocalApplier` if pull is used.
  /// - [authScopeProvider]: Optional. If provided, [start] can auto-resolve the
  ///   current scope uid by calling it when scope is not set explicitly.
  /// - [pushInterval]: Period between automatic push attempts.
  /// - [pullInterval]: Period between automatic pull attempts (per entityType).
  /// - [minBackoff]: Base delay used after failures before the next attempt.
  /// - [maxBackoff]: Maximum delay cap used after repeated failures.
  /// - [nowUtc]: Clock source used for scheduling/backoff decisions.
  ///
  /// Notes:
  /// - This class does not perform network detection itself. Use [setOnline].
  /// - This class does not infer entity types. Use [setPullEntityTypes].
  SyncRuntime({
    required SyncCoordinator coordinator,
    AuthScopeProvider? authScopeProvider,
    Duration pushInterval = const Duration(seconds: 10),
    Duration pullInterval = const Duration(seconds: 30),
    Duration minBackoff = const Duration(seconds: 2),
    Duration maxBackoff = const Duration(minutes: 2),
    DateTime Function()? nowUtc,
  })  : _coordinator = coordinator,
        _authScopeProvider = authScopeProvider,
        _pushInterval = pushInterval,
        _pullInterval = pullInterval,
        _minBackoff = minBackoff,
        _maxBackoff = maxBackoff,
        _nowUtc = nowUtc ?? DateTime.now().toUtc;

  final SyncCoordinator _coordinator;
  final AuthScopeProvider? _authScopeProvider;
  final Duration _pushInterval;
  final Duration _pullInterval;
  final Duration _minBackoff;
  final Duration _maxBackoff;
  final DateTime Function() _nowUtc;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  Timer? _pushTimer;
  Timer? _pullTimer;

  Future<void> _serial = Future<void>.value();

  bool _started = false;
  bool _online = true;
  bool _disposed = false;

  String? _scopeUid;
  List<String> _pullEntityTypes = const <String>[];

  DateTime? _nextPushNotBeforeUtc;
  int _pushFailureCount = 0;

  final Map<String, DateTime?> _nextPullNotBeforeUtcByEntityType =
      <String, DateTime?>{};
  final Map<String, int> _pullFailureCountByEntityType = <String, int>{};

  /// A broadcast stream of the latest [SyncStatus].
  ///
  /// Emission points:
  /// - When [start]/[stop] changes runtime state.
  /// - After each push/pull attempt completes (success or error).
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Returns the most recent status snapshot from the underlying coordinator.
  ///
  /// This is a snapshot getter; for reactive UI/logging prefer [statusStream].
  SyncStatus get status => _coordinator.status;

  /// Returns whether the runtime is currently started.
  bool get isStarted => _started;

  /// Returns current online flag used for gating push/pull.
  ///
  /// This does not perform connectivity checks. Use [setOnline] to update.
  bool get isOnline => _online;

  /// Returns the currently configured scope uid.
  ///
  /// Convention:
  /// - `uid` is typically the Firebase Auth uid.
  /// - When null, the runtime will not push/pull.
  String? get scopeUid => _scopeUid;

  /// Returns the entity types configured for automatic pull.
  List<String> get pullEntityTypes =>
      List<String>.unmodifiable(_pullEntityTypes);

  /// Starts periodic scheduling.
  ///
  /// Behavior:
  /// - If [scopeUid] is provided, sets scope immediately.
  /// - Else if no scope is set and [AuthScopeProvider] was provided, resolves it
  ///   once during start.
  /// - Schedules periodic push and pull ticks.
  ///
  /// Idempotency:
  /// - Calling [start] multiple times is safe; it re-arms timers.
  Future<void> start({String? scopeUid}) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _started = true;
      if (scopeUid != null) _scopeUid = scopeUid;

      if (_scopeUid == null) {
        final provider = _authScopeProvider;
        if (provider != null) {
          _scopeUid = await provider.getScopeUid();
        }
      }

      _armTimers();
      _emitStatus(_coordinator.status);

      await _maybeRunPush(reason: 'start');
      await _maybeRunPullAll(reason: 'start');
    });
  }

  /// Stops periodic scheduling.
  ///
  /// Behavior:
  /// - Cancels timers.
  /// - Does not clear local state (scope uid, failure counters) by default.
  ///   If you want to clear scope, call [setScopeUid] with null.
  Future<void> stop() async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _started = false;
      _cancelTimers();

      _emitStatus(
        _coordinator.status.copyWith(
          state: SyncRunState.stopped,
        ),
      );
    });
  }

  /// Disposes internal resources.
  ///
  /// After disposal:
  /// - All timers are cancelled
  /// - [statusStream] is closed
  /// - All public methods will throw [StateError]
  Future<void> dispose() async {
    await _enqueue(() async {
      if (_disposed) return;

      _cancelTimers();
      _disposed = true;
      await _statusController.close();
    });
  }

  /// Sets the online flag used to gate push/pull operations.
  ///
  /// Typical usage:
  /// - App listens to connectivity; call `setOnline(true/false)` accordingly.
  /// - When switching from offline to online, runtime triggers an immediate push
  ///   and pull-all attempt (subject to backoff).
  Future<void> setOnline(bool online) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      final changed = _online != online;
      _online = online;

      _emitStatus(_coordinator.status);

      if (changed && online) {
        await _maybeRunPush(reason: 'online');
        await _maybeRunPullAll(reason: 'online');
      }
    });
  }

  /// Sets the current scope uid.
  ///
  /// Typical usage:
  /// - Login: `setScopeUid(uid)` then [start] or call [triggerPullAll].
  /// - Logout: `setScopeUid(null)` then [stop] or keep started (it will noop).
  ///
  /// Behavior:
  /// - Updates internal scope.
  /// - Triggers an immediate push and pull-all attempt if started and online.
  Future<void> setScopeUid(String? scopeUid) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      final changed = _scopeUid != scopeUid;
      _scopeUid = scopeUid;

      if (changed) {
        _resetBackoff();
      }

      _emitStatus(
        _coordinator.status.copyWith(
          scopeUid: scopeUid,
        ),
      );

      if (_started && _online && _scopeUid != null) {
        await _maybeRunPush(reason: 'scope');
        await _maybeRunPullAll(reason: 'scope');
      }
    });
  }

  /// Configures which entity types should be pulled periodically.
  ///
  /// Notes:
  /// - Pull only works if [SyncCoordinator] was created with `syncStateStore`
  ///   and `localApplier`. Otherwise, pull methods will throw.
  /// - Changing the list resets pull backoff per entityType and can optionally
  ///   trigger a pull.
  Future<void> setPullEntityTypes(
    List<String> entityTypes, {
    bool triggerImmediately = true,
  }) async {
    await _enqueue(() async {
      _ensureNotDisposed();

      _pullEntityTypes = List<String>.unmodifiable(
        entityTypes.where((e) => e.trim().isNotEmpty).toSet().toList()..sort(),
      );

      _nextPullNotBeforeUtcByEntityType.removeWhere(
        (k, _) => !_pullEntityTypes.contains(k),
      );
      _pullFailureCountByEntityType.removeWhere(
        (k, _) => !_pullEntityTypes.contains(k),
      );

      for (final t in _pullEntityTypes) {
        _nextPullNotBeforeUtcByEntityType.putIfAbsent(t, () => null);
        _pullFailureCountByEntityType.putIfAbsent(t, () => 0);
      }

      if (triggerImmediately && _started && _online && _scopeUid != null) {
        await _maybeRunPullAll(reason: 'entityTypes');
      }
    });
  }

  /// Manually triggers a push attempt (subject to gating + backoff).
  Future<void> triggerPush() async {
    await _enqueue(() async {
      _ensureNotDisposed();
      await _maybeRunPush(reason: 'manual');
    });
  }

  /// Manually triggers a pull attempt for one entity type (subject to gating + backoff).
  Future<void> triggerPull(String entityType) async {
    await _enqueue(() async {
      _ensureNotDisposed();
      await _maybeRunPull(entityType: entityType, reason: 'manual');
    });
  }

  /// Manually triggers pull for all configured entity types (subject to gating + backoff).
  Future<void> triggerPullAll() async {
    await _enqueue(() async {
      _ensureNotDisposed();
      await _maybeRunPullAll(reason: 'manual');
    });
  }

  /// Arms periodic timers for push and pull.
  ///
  /// Timers:
  /// - push timer ticks every [_pushInterval]
  /// - pull timer ticks every [_pullInterval]
  void _armTimers() {
    _cancelTimers();

    if (!_started) return;

    _pushTimer = Timer.periodic(_pushInterval, (_) {
      _serial = _serial.then((_) async {
        if (_disposed) return;
        await _maybeRunPush(reason: 'timer');
      });
    });

    _pullTimer = Timer.periodic(_pullInterval, (_) {
      _serial = _serial.then((_) async {
        if (_disposed) return;
        await _maybeRunPullAll(reason: 'timer');
      });
    });
  }

  /// Cancels periodic timers if they exist.
  void _cancelTimers() {
    _pushTimer?.cancel();
    _pullTimer?.cancel();
    _pushTimer = null;
    _pullTimer = null;
  }

  /// Runs one push attempt if started, online, scope is set, and not in backoff.
  Future<void> _maybeRunPush({required String reason}) async {
    if (!_started) return;
    if (!_online) return;
    final uid = _scopeUid;
    if (uid == null) return;

    final notBefore = _nextPushNotBeforeUtc;
    final now = _nowUtc();
    if (notBefore != null && now.isBefore(notBefore)) return;

    final result = await _coordinator.pushOnce(scopeUid: uid);

    if (result.hasError) {
      _pushFailureCount += 1;
      _nextPushNotBeforeUtc = now.add(_computeBackoff(_pushFailureCount));
    } else {
      _pushFailureCount = 0;
      _nextPushNotBeforeUtc = null;
    }

    _emitStatus(_coordinator.status);
  }

  /// Runs pull for all configured entity types.
  Future<void> _maybeRunPullAll({required String reason}) async {
    if (_pullEntityTypes.isEmpty) return;

    for (final entityType in _pullEntityTypes) {
      await _maybeRunPull(entityType: entityType, reason: reason);
    }
  }

  /// Runs one pull attempt for [entityType] if started, online, scope is set, and not in backoff.
  Future<void> _maybeRunPull({
    required String entityType,
    required String reason,
  }) async {
    if (!_started) return;
    if (!_online) return;
    final uid = _scopeUid;
    if (uid == null) return;

    final normalized = entityType.trim();
    if (normalized.isEmpty) return;

    final now = _nowUtc();
    final notBefore = _nextPullNotBeforeUtcByEntityType[normalized];
    if (notBefore != null && now.isBefore(notBefore)) return;

    PullRunResult? result;
    SyncError? error;

    try {
      result = await _coordinator.pullOnce(
        scopeUid: uid,
        entityType: normalized,
      );
      error = result.lastError;
    } on Object catch (e) {
      error = SyncError(code: SyncErrorCode.unknown, message: '$e');
    }

    if (error != null) {
      final failures = (_pullFailureCountByEntityType[normalized] ?? 0) + 1;
      _pullFailureCountByEntityType[normalized] = failures;
      _nextPullNotBeforeUtcByEntityType[normalized] =
          now.add(_computeBackoff(failures));
    } else {
      _pullFailureCountByEntityType[normalized] = 0;
      _nextPullNotBeforeUtcByEntityType[normalized] = null;
    }

    _emitStatus(_coordinator.status);
  }

  /// Computes exponential backoff based on [failureCount], clamped to [_maxBackoff].
  Duration _computeBackoff(int failureCount) {
    if (failureCount <= 0) return Duration.zero;

    var multiplier = 1;
    for (var i = 1; i < failureCount; i += 1) {
      multiplier *= 2;
      if (multiplier >= 1024) break;
    }

    final raw = Duration(
      milliseconds: _minBackoff.inMilliseconds * multiplier,
    );

    if (raw <= _maxBackoff) return raw;
    return _maxBackoff;
  }

  /// Clears internal backoff state.
  void _resetBackoff() {
    _pushFailureCount = 0;
    _nextPushNotBeforeUtc = null;

    _nextPullNotBeforeUtcByEntityType.clear();
    _pullFailureCountByEntityType.clear();

    for (final t in _pullEntityTypes) {
      _nextPullNotBeforeUtcByEntityType[t] = null;
      _pullFailureCountByEntityType[t] = 0;
    }
  }

  /// Serializes public operations to avoid overlapping start/stop/trigger calls.
  Future<void> _enqueue(Future<void> Function() op) {
    _serial = _serial.then((_) => op());
    return _serial;
  }

  /// Emits [status] to the stream if possible.
  void _emitStatus(SyncStatus status) {
    if (_disposed) return;
    if (_statusController.isClosed) return;
    _statusController.add(status);
  }

  /// Throws if the runtime has been disposed.
  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SyncRuntime is disposed');
    }
  }
}
