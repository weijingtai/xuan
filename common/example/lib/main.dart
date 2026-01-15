import 'dart:async';

import 'package:account/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:common/pages/four_zhu_edit_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/datasource/sync_local_appliers.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/persistence_firebase.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Uuid>(create: (ctx) => const Uuid()),
        Provider<DeviceIdentity>(
          create: (ctx) => DeviceIdentity(
            deviceId: const Uuid().v4(),
            platform: kIsWeb ? 'web' : defaultTargetPlatform.toString(),
            formFactor: kIsWeb
                ? 'web'
                : (defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS)
                ? 'mobile'
                : 'desktop',
          ),
        ),
        Provider<FirebaseAuth?>(
          create: (_) {
            if (Firebase.apps.isEmpty) return null;
            return FirebaseAuth.instance;
          },
        ),
        Provider<FirebaseFirestore?>(
          create: (_) {
            if (Firebase.apps.isEmpty) return null;
            return FirebaseFirestore.instance;
          },
        ),
        Provider<AccountRegistry>(create: (ctx) => AccountRegistry()),
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
              _ActiveAccountAuthScopeProvider(ctx.read<ActiveAccountStore>()),
        ),
        Provider<_DemoAuthAdapter>(
          create: (ctx) => _DemoAuthAdapter(uuid: ctx.read<Uuid>()),
          dispose: (ctx, adapter) => adapter.dispose(),
        ),
        Provider<AuthAdapter>(
          create: (ctx) {
            final auth = ctx.read<FirebaseAuth?>();
            if (auth == null) return ctx.read<_DemoAuthAdapter>();
            return FirebaseEmailAuthAdapter(auth: auth);
          },
        ),
        Provider<IdentityResolver>(
          create: (ctx) {
            final firestore = ctx.read<FirebaseFirestore?>();
            if (firestore == null) {
              return _DemoIdentityResolver(uuid: ctx.read<Uuid>());
            }
            return FirebaseIdentityResolver(
              firestore: firestore,
              uuid: ctx.read<Uuid>(),
            );
          },
        ),
        Provider<AuthCoordinator>(
          create: (ctx) => AuthCoordinator(
            authAdapter: ctx.read<AuthAdapter>(),
            identityResolver: ctx.read<IdentityResolver>(),
            accountRegistry: ctx.read<AccountRegistry>(),
            activeAccountStore: ctx.read<ActiveAccountStore>(),
          ),
        ),
        Provider<GuestAccountConflictDelegate>(
          create: (ctx) => const _NoopGuestAccountConflictDelegate(),
        ),
        Provider<AppDatabase>(
          create: (ctx) => AppDatabase(null, false),
          dispose: (ctx, db) => db.close(),
        ),
        Provider<OutboxStore>(create: (ctx) => _MemoryOutboxStore()),
        Provider<SyncStateStore>(create: (ctx) => _MemorySyncStateStore()),
        Provider<RemoteGateway>(
          create: (ctx) {
            final firestore = ctx.read<FirebaseFirestore?>();
            if (firestore == null) return const _UnavailableRemoteGateway();
            if (!ctx.read<ActiveAccountStore>().isSignedIn) {
              return const _UnavailableRemoteGateway();
            }
            return FirestoreRemoteGateway(
              firestore: firestore,
              device: ctx.read<DeviceIdentity>(),
              nowUtc: () => DateTime.now().toUtc(),
              module: 'common',
            );
          },
        ),
        Provider<LayoutTemplateLocalDataSource>(
          create: (ctx) => LayoutTemplateLocalDataSource(
            ctx.read<AppDatabase>(),
            outboxStore: ctx.read<OutboxStore>(),
          ),
        ),
        Provider<LocalApplier>(
          create: (ctx) {
            final appDb = ctx.read<AppDatabase>();
            final seekerMapApplier = SeekerDivinationMapperLocalApplier(appDb);
            final divinationPanelApplier = DivinationPanelMapperLocalApplier(
              appDb,
            );

            return CompositeLocalApplier(<String, LocalApplier>{
              'layout_template': ctx.read<LayoutTemplateLocalDataSource>(),
              'divination': DivinationLocalApplier(appDb),
              'seeker': SeekerLocalApplier(appDb),
              'timing_divination': TimingDivinationLocalApplier(appDb),
              'seeker_divination_map': seekerMapApplier,
              'seeker_divination_mapper': seekerMapApplier,
              'divination_panel_map': divinationPanelApplier,
              'divination_panel_mapper': divinationPanelApplier,
            });
          },
        ),
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
              enablePush: true,
              pushInterval: const Duration(seconds: 10),
              pullInterval: const Duration(seconds: 15),
              minBackoff: const Duration(seconds: 2),
              maxBackoff: const Duration(minutes: 2),
            );
            runtime.setPullEntityTypes(const <String>[
              'layout_template',
              'divination',
              'seeker',
              'timing_divination',
              'seeker_divination_map',
              'divination_panel_map',
            ], triggerImmediately: true);
            return runtime;
          },
          dispose: (ctx, runtime) {
            runtime.stop();
            runtime.dispose();
          },
        ),
      ],
      child: MaterialApp(
        title: 'FourZhu Edit Preview',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAccountStore>(
      builder: (context, active, _) {
        if (!active.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!active.isSignedIn) return const AuthPage();

        final scopeUid = active.activeAppUserId;
        if (scopeUid == null || scopeUid.isEmpty) return const AuthPage();

        return _SyncShell(scopeUid: scopeUid, child: const FourZhuEditPage());
      },
    );
  }
}

class _ActiveAccountAuthScopeProvider implements AuthScopeProvider {
  _ActiveAccountAuthScopeProvider(this._active);

  final ActiveAccountStore _active;

  @override
  Future<String> getScopeUid() async {
    if (!_active.isSignedIn) throw StateError('Not signed in');
    final uid = _active.activeAppUserId;
    if (uid == null || uid.isEmpty) throw StateError('Not signed in');
    return uid;
  }
}

class _SyncShell extends StatefulWidget {
  const _SyncShell({required this.scopeUid, required this.child});

  final String scopeUid;
  final Widget child;

  @override
  State<_SyncShell> createState() => _SyncShellState();
}

class _SyncShellState extends State<_SyncShell> {
  late final SyncRuntime _runtime;

  @override
  void initState() {
    super.initState();
    _runtime = context.read<SyncRuntime>();
    _runtime
        .start(scopeUid: widget.scopeUid)
        .then((_) => _runtime.triggerPullAll());
  }

  @override
  void didUpdateWidget(covariant _SyncShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scopeUid == oldWidget.scopeUid) return;
    unawaited(
      _runtime
          .stop()
          .then((_) => _runtime.start(scopeUid: widget.scopeUid))
          .catchError((_) {}),
    );
  }

  @override
  void dispose() {
    unawaited(_runtime.stop().catchError((_) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _DemoAuthAdapter implements AuthAdapter {
  _DemoAuthAdapter({required Uuid uuid}) : _uuid = uuid;

  final Uuid _uuid;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();
  final Map<String, String> _passwordByEmail = <String, String>{};

  AuthSession? _current;

  void dispose() {
    if (_controller.isClosed) return;
    _controller.close();
  }

  @override
  Stream<AuthSession?> sessionChanges() => _controller.stream;

  void _emit(AuthSession? session) {
    _current = session;
    if (_controller.isClosed) return;
    _controller.add(session);
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    final session = AuthSession(
      baasUid: 'anon-${_uuid.v4()}',
      providerType: AuthProviderType.anonymous,
      issuedAt: DateTime.now().toUtc(),
    );
    _emit(session);
    return session;
  }

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) throw StateError('邮箱不能为空');

    final existing = _passwordByEmail[normalized];
    if (existing == null) {
      if (!createIfMissing) throw StateError('账号不存在');
      _passwordByEmail[normalized] = password;
    } else {
      if (existing != password) throw StateError('密码错误');
    }

    final session = AuthSession(
      baasUid: 'email:$normalized',
      providerType: AuthProviderType.emailPassword,
      issuedAt: DateTime.now().toUtc(),
      email: normalized,
    );
    _emit(session);
    return session;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final normalized = email.trim().toLowerCase();
    if (!_passwordByEmail.containsKey(normalized)) throw StateError('账号不存在');
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    final email = _current?.email;
    if (email == null) throw StateError('未登录');
    _passwordByEmail[email] = newPassword;
  }

  @override
  Future<void> deleteAccount() async {
    final email = _current?.email;
    if (email != null) _passwordByEmail.remove(email);
    await signOut();
  }
}

class _DemoIdentityResolver implements IdentityResolver {
  _DemoIdentityResolver({required Uuid uuid}) : _uuid = uuid;

  final Uuid _uuid;
  final Map<String, String> _appUserIdByBaasUid = <String, String>{};

  @override
  Future<String> resolveAppUserId(AuthSession session) async {
    final existing = _appUserIdByBaasUid[session.baasUid];
    if (existing != null && existing.isNotEmpty) return existing;
    final created = 'app_${_uuid.v4()}';
    _appUserIdByBaasUid[session.baasUid] = created;
    return created;
  }

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) async {
    final existing = _appUserIdByBaasUid[session.baasUid];
    if (existing != null && existing.isNotEmpty && existing != appUserId) {
      throw IdentityMappingConflict(
        baasUid: session.baasUid,
        expectedAppUserId: appUserId,
        existingAppUserId: existing,
      );
    }
    _appUserIdByBaasUid[session.baasUid] = appUserId;
  }
}

class _NoopGuestAccountConflictDelegate
    implements GuestAccountConflictDelegate {
  const _NoopGuestAccountConflictDelegate();

  @override
  Future<void> mergeGuestIntoAccount({
    required String guestAppUserId,
    required String accountAppUserId,
  }) async {}

  @override
  Future<void> discardGuest({required String guestAppUserId}) async {}
}

class _UnavailableRemoteGateway implements RemoteGateway {
  const _UnavailableRemoteGateway();

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    return const SyncError(
      code: SyncErrorCode.permission,
      message: 'Firestore not initialized or not signed in',
    );
  }

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
}

class _MemoryOutboxStore implements OutboxStore {
  final Map<String, OutboxRecord> _recordsByOperationId =
      <String, OutboxRecord>{};
  final Set<String> _dead = <String>{};
  final Set<String> _success = <String>{};

  @override
  Future<int> backlogCount(String scopeUid) async {
    var count = 0;
    for (final r in _recordsByOperationId.values) {
      if (r.scopeUid != scopeUid) continue;
      if (_dead.contains(r.operationId)) continue;
      if (_success.contains(r.operationId)) continue;
      count += 1;
    }
    return count;
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
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    if (_recordsByOperationId.containsKey(operationId)) {
      _success.add(operationId);
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
  final Map<String, DateTime> _pulledAtByKey = <String, DateTime>{};
  final Map<String, DateTime> _pushedAtByScope = <String, DateTime>{};

  String _key(String scopeUid, String entityType) => '$scopeUid::$entityType';

  @override
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) async {
    final k = _key(scopeUid, entityType);
    _cursorByKey.remove(k);
    _pulledAtByKey.remove(k);
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
  }) async {
    _pulledAtByKey[_key(scopeUid, entityType)] = atUtc;
  }

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) async {
    _pushedAtByScope[scopeUid] = atUtc;
  }

  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) async {
    final k = _key(scopeUid, entityType);
    final current = _cursorByKey[k];
    if (current == null) {
      _cursorByKey[k] = cursor;
      return;
    }
    if (_isNewer(cursor, current)) _cursorByKey[k] = cursor;
  }

  bool _isNewer(PullCursor candidate, PullCursor current) {
    if (candidate.runtimeType != current.runtimeType) return false;

    if (candidate is TimestampCursor && current is TimestampCursor) {
      final t = candidate.serverUpdatedAtUtc.compareTo(
        current.serverUpdatedAtUtc,
      );
      if (t != 0) return t > 0;
      return candidate.tieBreaker.compareTo(current.tieBreaker) > 0;
    }

    if (candidate is RevisionCursor && current is RevisionCursor) {
      return candidate.revision > current.revision;
    }

    return false;
  }
}
