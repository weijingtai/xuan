// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:account/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/pages/four_zhu_edit_page.dart';
import 'package:example/main.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  testWidgets('Login then open FourZhuEditPage', (WidgetTester tester) async {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('A RenderFlex overflowed by')) return;
      if (message.contains('RenderFlex overflowed by')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory(), false);
    addTearDown(() async => db.close());

    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Uuid>(create: (_) => const Uuid()),
          Provider<AccountRegistry>(create: (_) => AccountRegistry()),
          Provider<GuestIdentityStore>(
            create: (ctx) => GuestIdentityStore(uuid: ctx.read<Uuid>()),
          ),
          ChangeNotifierProvider<ActiveAccountStore>(
            create: (ctx) => ActiveAccountStore(
              registry: ctx.read<AccountRegistry>(),
              guestIdentityStore: ctx.read<GuestIdentityStore>(),
            )..load(),
          ),
          Provider<AuthScopeProvider>(
            create: (ctx) =>
                _TestAuthScopeProvider(ctx.read<ActiveAccountStore>()),
          ),
          Provider<AuthAdapter>(create: (ctx) => _TestAuthAdapter()),
          Provider<IdentityResolver>(
            create: (ctx) => _TestIdentityResolver(uuid: ctx.read<Uuid>()),
          ),
          Provider<AuthCoordinator>(
            create: (ctx) => AuthCoordinator(
              authAdapter: ctx.read<AuthAdapter>(),
              identityResolver: ctx.read<IdentityResolver>(),
              accountRegistry: ctx.read<AccountRegistry>(),
              activeAccountStore: ctx.read<ActiveAccountStore>(),
            ),
          ),
          Provider<AppDatabase>.value(value: db),
          Provider<OutboxStore>(create: (_) => _MemoryOutboxStore()),
          Provider<SyncStateStore>(create: (_) => _MemorySyncStateStore()),
          Provider<RemoteGateway>(create: (_) => _NoopRemoteGateway()),
          Provider<LayoutTemplateLocalDataSource>(
            create: (ctx) => LayoutTemplateLocalDataSource(
              ctx.read<AppDatabase>(),
              outboxStore: ctx.read<OutboxStore>(),
            ),
          ),
          Provider<LocalApplier>(create: (_) => _NoopLocalApplier()),
          Provider<SyncCoordinator>(
            create: (ctx) => SyncCoordinator(
              outboxStore: ctx.read<OutboxStore>(),
              syncStateStore: ctx.read<SyncStateStore>(),
              remoteGateway: ctx.read<RemoteGateway>(),
              localApplier: ctx.read<LocalApplier>(),
              nowUtc: () => DateTime.now().toUtc(),
            ),
          ),
          Provider<SyncRuntime>(
            create: (ctx) {
              final runtime = SyncRuntime(
                coordinator: ctx.read<SyncCoordinator>(),
                enablePush: false,
                pushInterval: const Duration(seconds: 60),
                pullInterval: const Duration(seconds: 60),
                minBackoff: const Duration(seconds: 1),
                maxBackoff: const Duration(seconds: 2),
              );
              runtime.setPullEntityTypes(const <String>[
                'layout_template',
                'divination',
                'seeker',
                'timing_divination',
                'seeker_divination_map',
                'divination_panel_map',
              ], triggerImmediately: false);
              return runtime;
            },
          ),
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final element = tester.element(find.byType(AuthGate));
    final coordinator = Provider.of<AuthCoordinator>(element, listen: false);
    await coordinator.signInOrRegisterWithEmailPassword(
      email: 'demo@example.com',
      password: 'pw',
    );

    await tester.pumpAndSettle();

    expect(find.byType(FourZhuEditPage), findsOneWidget);

    final editorElement = tester.element(find.byType(FourZhuEditPage));
    final runtime = Provider.of<SyncRuntime>(editorElement, listen: false);
    await runtime.stop();
    await runtime.dispose();
  });
}

class _NoopRemoteGateway implements RemoteGateway {
  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return const RemoteChangesPage(
      changes: <RemoteChange>[],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    return null;
  }
}

class _NoopLocalApplier implements LocalApplier {
  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    return const LocalApplyResult(
      canAdvanceCursor: true,
      appliedCount: 0,
      outcomes: <ChangeApplyOutcome>[],
      lastError: null,
    );
  }
}

class _MemoryOutboxStore implements OutboxStore {
  final Map<String, OutboxRecord> _recordsByOperationId =
      <String, OutboxRecord>{};
  final Set<String> _dead = <String>{};
  final Set<String> _success = <String>{};

  final Map<String, StreamController<int>> _backlogControllersByScope =
      <String, StreamController<int>>{};

  int _backlogCountSync(String scopeUid) {
    var count = 0;
    for (final r in _recordsByOperationId.values) {
      if (r.scopeUid != scopeUid) continue;
      if (_dead.contains(r.operationId)) continue;
      if (_success.contains(r.operationId)) continue;
      count += 1;
    }
    return count;
  }

  void _emitBacklog(String scopeUid) {
    final c = _backlogControllersByScope[scopeUid];
    if (c == null) return;
    if (c.isClosed) return;
    c.add(_backlogCountSync(scopeUid));
  }

  @override
  Future<int> backlogCount(String scopeUid) async {
    return _backlogCountSync(scopeUid);
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    final controller = _backlogControllersByScope.putIfAbsent(
      scopeUid,
      () => StreamController<int>.broadcast(
        sync: true,
        onListen: () => _emitBacklog(scopeUid),
      ),
    );
    return controller.stream;
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    var count = 0;
    for (final opId in _dead) {
      final r = _recordsByOperationId[opId];
      if (r == null) continue;
      if (r.scopeUid != scopeUid) continue;
      count += 1;
    }
    return count;
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {
    _recordsByOperationId.putIfAbsent(record.operationId, () => record);
    _emitBacklog(record.scopeUid);
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    final existing = _recordsByOperationId[operationId];
    if (existing == null) return;
    _recordsByOperationId[operationId] = existing.copyWith(attempt: attempt);
    if (isDead) _dead.add(operationId);
    _emitBacklog(existing.scopeUid);
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    if (_recordsByOperationId.containsKey(operationId)) {
      _success.add(operationId);
      _emitBacklog(_recordsByOperationId[operationId]!.scopeUid);
    }
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    final candidates =
        _recordsByOperationId.values
            .where(
              (r) =>
                  r.scopeUid == scopeUid &&
                  !_dead.contains(r.operationId) &&
                  !_success.contains(r.operationId),
            )
            .toList()
          ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));

    if (candidates.length <= limit) return candidates;
    return candidates.sublist(0, limit);
  }
}

class _MemorySyncStateStore implements SyncStateStore {
  final Map<String, PullCursor> _cursorByKey = <String, PullCursor>{};

  String _key(String scopeUid, String entityType) => '$scopeUid::$entityType';

  @override
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) async {
    _cursorByKey.remove(_key(scopeUid, entityType));
  }

  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  }) async {
    return _cursorByKey[_key(scopeUid, entityType)];
  }

  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) async {}

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) async {}

  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) async {
    _cursorByKey[_key(scopeUid, entityType)] = cursor;
  }
}

class _TestAuthScopeProvider implements AuthScopeProvider {
  _TestAuthScopeProvider(this._active);

  final ActiveAccountStore _active;

  @override
  Future<String> getScopeUid() async {
    if (!_active.isSignedIn) throw StateError('Not signed in');
    final uid = _active.activeAppUserId;
    if (uid == null || uid.isEmpty) throw StateError('Not signed in');
    return uid;
  }
}

class _TestAuthAdapter implements AuthAdapter {
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> sessionChanges() => _controller.stream;

  void _emit(AuthSession? session) {
    _controller.add(session);
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    final s = AuthSession(
      baasUid: 'anon',
      providerType: AuthProviderType.anonymous,
      issuedAt: DateTime.now().toUtc(),
    );
    _emit(s);
    return s;
  }

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) async {
    final s = AuthSession(
      baasUid: 'email:$email',
      providerType: AuthProviderType.emailPassword,
      issuedAt: DateTime.now().toUtc(),
      email: email,
    );
    _emit(s);
    return s;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}

  @override
  Future<void> deleteAccount() async {
    await signOut();
  }
}

class _TestIdentityResolver implements IdentityResolver {
  _TestIdentityResolver({required Uuid uuid}) : _uuid = uuid;
  final Uuid _uuid;

  @override
  Future<String> resolveAppUserId(AuthSession session) async {
    return 'app_${_uuid.v4()}';
  }

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) async {}
}
