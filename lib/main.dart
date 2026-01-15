import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:account/account.dart';
import 'package:common/common_logger.dart';
import 'package:common/database/app_database.dart' as db;
import 'package:common/database/world_info_database.dart' as world_db;
import 'package:common/datasource/geo_location_repository.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/datasource/loca_binary/world_country_repository.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_firebase/persistence_firebase.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:uuid/uuid.dart';
import 'package:xuan/pages/conditional_route_widget.dart';
import 'package:xuan/pages/cross_platform_main_page.dart';
import 'package:xuan/pages/root_page.dart';
import 'package:xuan/routes.dart';
import 'ephe_web_helper.dart' if (dart.library.ffi) 'ephe_io_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'NavigatorGenerator.dart';

bool _firebaseReady = false;
String? _firestoreDeviceId;

class _UnavailableRemoteGateway implements RemoteGateway {
  const _UnavailableRemoteGateway();

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    return const SyncError(
      code: SyncErrorCode.permission,
      message: 'Firestore not initialized',
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
      changes: [],
      nextCursor: null,
      hasMore: false,
    );
  }
}

class _UnavailableAuthAdapter implements AuthAdapter {
  const _UnavailableAuthAdapter();

  static StateError _err() => StateError('FirebaseAuth not initialized');

  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) {
    return Future<AuthSession>.error(_err());
  }

  @override
  Future<AuthSession> signInAnonymously() {
    return Future<AuthSession>.error(_err());
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return Future<void>.error(_err());
  }

  @override
  Future<void> signOut() {
    return Future<void>.error(_err());
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return Future<void>.error(_err());
  }

  @override
  Future<void> deleteAccount() {
    return Future<void>.error(_err());
  }
}

class _UnavailableIdentityResolver implements IdentityResolver {
  const _UnavailableIdentityResolver();

  static StateError _err() => StateError('FirebaseFirestore not initialized');

  @override
  Future<String> resolveAppUserId(AuthSession session) {
    return Future<String>.error(_err());
  }

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) {
    return Future<void>.error(_err());
  }
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseReady = true;
  } catch (e) {
    _firebaseReady = false;
    CommonLogger().logger.w('Firebase initializeApp skipped: $e');
  }

  _firestoreDeviceId ??= const Uuid().v4();

  await initSweph([
    'packages/sweph/assets/ephe/sefstars.txt',
  ]);
}

void main() async {
  await initServices();
  runApp(const _BootstrapApp());
}

QueryExecutor _driftExecutor(String name) {
  return driftDatabase(
    name: name,
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
            );
          }
        }
      },
    ),
  );
}

class _ActiveAccountScopeProvider implements AuthScopeProvider {
  _ActiveAccountScopeProvider(this._store);

  final ActiveAccountStore _store;

  @override
  Future<String> getScopeUid() async {
    final uid = _store.activeAppUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError('No active appUserId');
    }
    return uid;
  }
}

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
        Provider<DeviceIdentity>(
          create: (ctx) => DeviceIdentity(
            deviceId: _firestoreDeviceId ?? const Uuid().v4(),
            platform: kIsWeb ? 'web' : defaultTargetPlatform.toString(),
            formFactor: kIsWeb
                ? 'web'
                : (defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS)
                    ? 'mobile'
                    : 'desktop',
          ),
        ),
        Provider<FirebaseFirestore?>(
          create: (_) => _firebaseReady ? FirebaseFirestore.instance : null,
        ),
        Provider<FirebaseAuth?>(
          create: (_) => _firebaseReady ? FirebaseAuth.instance : null,
        ),
        Provider<AuthAdapter>(
          create: (ctx) {
            final auth = ctx.read<FirebaseAuth?>();
            if (auth == null) {
              return const _UnavailableAuthAdapter();
            }
            return FirebaseEmailAuthAdapter(auth: auth);
          },
        ),
        Provider<IdentityResolver>(
          create: (ctx) {
            final firestore = ctx.read<FirebaseFirestore?>();
            if (firestore == null) {
              return const _UnavailableIdentityResolver();
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
      ],
      child: const _AuthAwareApp(),
    );
  }
}

class _AuthAwareApp extends StatelessWidget {
  const _AuthAwareApp();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ActiveAccountStore>();
    if (!store.isReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final appUserId = store.activeAppUserId;
    if (appUserId == null || appUserId.isEmpty) {
      return const MaterialApp(home: AuthPage());
    }
    return KeyedSubtree(
      key: ValueKey(appUserId),
      child: MultiProvider(
        providers: [
          Provider<AuthScopeProvider>(
            create: (ctx) =>
                _ActiveAccountScopeProvider(ctx.read<ActiveAccountStore>()),
          ),
          Provider<db.AppDatabase>(
            create: (ctx) => db.AppDatabase(
              _driftExecutor('app_database_$appUserId'),
            ),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<world_db.WorldInfoDatabase>(
            create: (ctx) => world_db.WorldInfoDatabase(),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<PersistenceDriftDatabase>(
            create: (ctx) => PersistenceDriftDatabase(
              _driftExecutor('persistence_drift_$appUserId'),
            ),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<OutboxStore>(
            create: (ctx) => DriftOutboxStore(
              dao: ctx.read<PersistenceDriftDatabase>().outboxRecordsDao,
            ),
          ),
          Provider<SyncStateStore>(
            create: (ctx) => DriftSyncStateStore(
              dao: ctx.read<PersistenceDriftDatabase>().syncStatesDao,
            ),
          ),
          Provider<RemoteGateway>(
            create: (ctx) {
              if (!ctx.read<ActiveAccountStore>().isSignedIn) {
                return const _UnavailableRemoteGateway();
              }
              final firestore = ctx.read<FirebaseFirestore?>();
              if (firestore == null) return const _UnavailableRemoteGateway();
              return FirestoreRemoteGateway(
                firestore: firestore,
                device: ctx.read<DeviceIdentity>(),
                nowUtc: () => DateTime.now().toUtc(),
              );
            },
          ),
          Provider<LayoutTemplateLocalDataSource>(
            create: (ctx) => LayoutTemplateLocalDataSource(
              ctx.read<db.AppDatabase>(),
              outboxStore: ctx.read<OutboxStore>(),
            ),
          ),
          Provider<SyncCoordinator>(
            create: (ctx) => SyncCoordinator(
              outboxStore: ctx.read<OutboxStore>(),
              syncStateStore: ctx.read<SyncStateStore>(),
              remoteGateway: ctx.read<RemoteGateway>(),
              localApplier: ctx.read<LayoutTemplateLocalDataSource>(),
              nowUtc: () => DateTime.now().toUtc(),
            ),
          ),
          Provider<GuestAccountConflictDelegate>(
            create: (ctx) => _GuestConflictDelegate(
              appDb: ctx.read<db.AppDatabase>(),
              persistenceDb: ctx.read<PersistenceDriftDatabase>(),
              uuid: ctx.read<Uuid>(),
            ),
          ),
          Provider<WorldCountryRepository>(
            create: (ctx) => WorldCountryRepository(
              path: 'assets/dataset/world_country.pro',
              regionJsonFilePath: 'assets/dataset/regions.json',
            ),
          ),
          Provider<GeoLocationRepository>(
            create: (ctx) => GeoLocationRepository(
              path: 'assets/dataset/province_city_area_lng_lat.json',
            ),
          ),
          ListenableProvider<TimezoneLocationViewModel>(
            create: (ctx) => TimezoneLocationViewModel(
                appFeatureModule: AppFeatureModule.Golabel),
          ),
          ListenableProvider<DevEnterPageViewModel>(
            create: (ctx) =>
                DevEnterPageViewModel(appDatabase: ctx.read<db.AppDatabase>())
                  ..initState(),
          ),
        ],
        child: store.isSignedIn
            ? const _SignedInSyncShell(child: MyApp())
            : const _GuestAnonBootstrap(child: MyApp()),
      ),
    );
  }
}

class _GuestAnonBootstrap extends StatefulWidget {
  const _GuestAnonBootstrap({required this.child});

  final Widget child;

  @override
  State<_GuestAnonBootstrap> createState() => _GuestAnonBootstrapState();
}

class _GuestAnonBootstrapState extends State<_GuestAnonBootstrap> {
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trySignInAnonymously();
    });
  }

  Future<void> _trySignInAnonymously() async {
    if (!mounted) return;
    if (_attempted) return;
    _attempted = true;

    final store = context.read<ActiveAccountStore>();
    if (!store.isGuest || store.isSignedIn) return;

    final auth = context.read<FirebaseAuth?>();
    final firestore = context.read<FirebaseFirestore?>();
    if (auth == null || firestore == null) return;

    try {
      await context.read<AuthCoordinator>().signInAnonymously();
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _GuestConflictDelegate implements GuestAccountConflictDelegate {
  _GuestConflictDelegate({
    required db.AppDatabase appDb,
    required PersistenceDriftDatabase persistenceDb,
    required Uuid uuid,
  })  : _appDb = appDb,
        _persistenceDb = persistenceDb,
        _uuid = uuid;

  final db.AppDatabase _appDb;
  final PersistenceDriftDatabase _persistenceDb;
  final Uuid _uuid;

  @override
  Future<void> mergeGuestIntoAccount({
    required String guestAppUserId,
    required String accountAppUserId,
  }) async {
    final accountAppDb = db.AppDatabase(
      _driftExecutor('app_database_$accountAppUserId'),
    );
    final accountPersistenceDb = PersistenceDriftDatabase(
      _driftExecutor('persistence_drift_$accountAppUserId'),
    );

    try {
      final remap = await _mergeLayoutTemplates(
        from: _appDb,
        to: accountAppDb,
      );
      await _mergeCardTemplateMetas(
        from: _appDb,
        to: accountAppDb,
        remapTemplateUuid: remap,
      );
      await _mergeCardTemplateSettings(
        from: _appDb,
        to: accountAppDb,
        remapTemplateUuid: remap,
      );
      await _rewriteOutboxIntoAccountDb(
        from: _persistenceDb,
        to: accountPersistenceDb,
        guestAppUserId: guestAppUserId,
        accountAppUserId: accountAppUserId,
        remapEntityId: remap,
      );

      await _wipeAllTables(_appDb);
      await _wipeAllTables(_persistenceDb);
    } finally {
      await accountAppDb.close();
      await accountPersistenceDb.close();
    }
  }

  @override
  Future<void> discardGuest({required String guestAppUserId}) async {
    await _wipeAllTables(_appDb);
    await _wipeAllTables(_persistenceDb);
  }

  Future<void> _wipeAllTables(GeneratedDatabase db) async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await db.transaction(() async {
        for (final table in db.allTables) {
          await db.delete(table).go();
        }
      });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<Map<String, String>> _mergeLayoutTemplates({
    required db.AppDatabase from,
    required db.AppDatabase to,
  }) async {
    final rows = await from.select(from.layoutTemplates).get();
    if (rows.isEmpty) return const {};

    final ids = rows.map((r) => r.uuid).toSet().toList(growable: false);
    final existing = await (to.select(to.layoutTemplates)
          ..where((t) => t.uuid.isIn(ids)))
        .get();
    final existingIds = existing.map((r) => r.uuid).toSet();

    final remap = <String, String>{};
    final inserts = <db.LayoutTemplatesCompanion>[];

    for (final r in rows) {
      var uuid = r.uuid;
      var templateJson = r.templateJson;
      if (existingIds.contains(uuid)) {
        final newId = _uuid.v4();
        remap[uuid] = newId;
        uuid = newId;
        templateJson = _rewriteLayoutTemplateJsonId(templateJson, newId);
      }

      inserts.add(
        db.LayoutTemplatesCompanion.insert(
          uuid: uuid,
          collectionId: r.collectionId,
          name: r.name,
          description: Value(r.description),
          templateJson: templateJson,
          version: r.version,
          updatedAt: r.updatedAt,
          deletedAt: Value(r.deletedAt),
        ),
      );
    }

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(to.layoutTemplates, inserts);
    });

    return remap;
  }

  String _rewriteLayoutTemplateJsonId(String templateJson, String newId) {
    final decoded = jsonDecode(templateJson);
    if (decoded is! Map<String, dynamic>) return templateJson;
    decoded['id'] = newId;
    return jsonEncode(decoded);
  }

  String _rewriteLayoutTemplatePayloadJson(String payloadJson, String newId) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) return payloadJson;
    decoded['entityId'] = newId;
    final template = decoded['template'];
    if (template is Map<String, dynamic>) {
      template['id'] = newId;
    }
    return jsonEncode(decoded);
  }

  Future<void> _mergeCardTemplateMetas({
    required db.AppDatabase from,
    required db.AppDatabase to,
    required Map<String, String> remapTemplateUuid,
  }) async {
    final rows = await from.select(from.cardTemplateMetas).get();
    if (rows.isEmpty) return;

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(
        to.cardTemplateMetas,
        rows
            .map(
              (r) => db.CardTemplateMetasCompanion.insert(
                templateUuid: remapTemplateUuid[r.templateUuid] ?? r.templateUuid,
                createdAt: r.createdAt,
                modifiedAt: r.modifiedAt,
                deletedAt: Value(r.deletedAt),
                authorUuid: Value(r.authorUuid),
                createFromCardUuid: Value(r.createFromCardUuid),
                isCustomized: Value(r.isCustomized),
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _mergeCardTemplateSettings({
    required db.AppDatabase from,
    required db.AppDatabase to,
    required Map<String, String> remapTemplateUuid,
  }) async {
    final rows = await from.select(from.cardTemplateSettings).get();
    if (rows.isEmpty) return;

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(
        to.cardTemplateSettings,
        rows
            .map(
              (r) => db.CardTemplateSettingsCompanion.insert(
                templateUuid: remapTemplateUuid[r.templateUuid] ?? r.templateUuid,
                createdAt: r.createdAt,
                modifiedAt: r.modifiedAt,
                deletedAt: Value(r.deletedAt),
                settingJson: r.settingJson,
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _rewriteOutboxIntoAccountDb({
    required PersistenceDriftDatabase from,
    required PersistenceDriftDatabase to,
    required String guestAppUserId,
    required String accountAppUserId,
    required Map<String, String> remapEntityId,
  }) async {
    final rows = await from.outboxRecordsDao.listRetryable(
      scopeUid: guestAppUserId,
    );
    if (rows.isEmpty) return;

    final nowUtc = DateTime.now().toUtc();
    final inserts = rows
        .map((r) {
          final remapped = r.entityType == 'layout_template'
              ? (remapEntityId[r.entityId] ?? r.entityId)
              : r.entityId;
          final payloadJson = (r.entityType == 'layout_template' &&
                  remapEntityId.containsKey(r.entityId))
              ? _rewriteLayoutTemplatePayloadJson(
                  r.payloadJson,
                  remapped,
                )
              : r.payloadJson;

          return OutboxRecordsCompanion.insert(
            operationId: _uuid.v4(),
            scopeUid: accountAppUserId,
            entityType: r.entityType,
            entityId: remapped,
            opType: r.opType,
            payloadJson: payloadJson,
            createdAtUtc: nowUtc,
          );
        })
        .toList(growable: false);

    await to.outboxRecordsDao.enqueueMany(inserts);
    await from.outboxRecordsDao.deleteByScope(scopeUid: guestAppUserId);
  }
}

class _SignedInSyncShell extends StatefulWidget {
  const _SignedInSyncShell({required this.child});

  final Widget child;

  @override
  State<_SignedInSyncShell> createState() => _SignedInSyncShellState();
}

class _SignedInSyncShellState extends State<_SignedInSyncShell>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _kick();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kick();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _kick();
    }
  }

  Future<void> _kick() async {
    if (!mounted) return;
    if (_running) return;
    _running = true;
    try {
      final scopeUid = await context.read<AuthScopeProvider>().getScopeUid();
      final coordinator = context.read<SyncCoordinator>();
      await coordinator.pushOnce(scopeUid: scopeUid);
      await coordinator.pullOnce(
        scopeUid: scopeUid,
        entityType: 'layout_template',
        maxPages: 3,
      );
    } catch (_) {
    } finally {
      _running = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return buildNewXuan();
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      onGenerateRoute: NavigatorGenerator.generateRoute,
      // initialRoute: '/qizhengsiyu',
      // initialRoute: '/one_year',
      // initialRoute: '/dev', // 七政四余
      // initialRoute: '/common/dev', // 占测记录
      // initialRoute: '/qizhengsiyu/panel', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      initialRoute: '/daliuren', // 大六壬 (MVVM)
      // initialRoute: '/daliuren/dev', // 大六壬
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // main
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildNewXuan() {
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 480, name: MOBILE),
          const Breakpoint(start: 481, end: 800, name: PHONE),
          const Breakpoint(start: 801, end: 1024, name: TABLET),
          const Breakpoint(start: 1025, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
      initialRoute: "/",
      onGenerateInitialRoutes: (initialRoute) {
        final Uri uri = Uri.parse(initialRoute);
        return [
          buildPage(path: uri.path, queryParams: uri.queryParameters),
        ];
      },
      onGenerateRoute: (RouteSettings settings) {
        // A custom `fadeThrough` route transition animation.
        final Uri uri = Uri.parse(settings.name ?? '/');
        return Routes.fadeThrough(
            settings: settings,
            builder: (context) {
              // Wrap widgets with another widget based on the route.
              // Wrap the page with the ResponsiveScaledBox for desired pages.
              //   final Uri uri = Uri.parse(settings.name ?? '/');
              return ConditionalRouteWidget(
                  routesExcluded: const [], // Excluding a page from AutoScale.
                  builder: (context, child) =>
                      child ??
                      ResponsiveScaledBox(
                          // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
                          // Set the fixed width value based on the active breakpoint.
                          width: ResponsiveValue<double>(context,
                              conditionalValues: [
                                // const Condition.equals(name: MOBILE, value: 450),
                                const Condition.between(
                                    start: 0, end: 450, value: 0),
                                const Condition.between(
                                    start: 800, end: 1100, value: 800),
                                Condition.between(
                                    start: 1000,
                                    end: double.maxFinite.toInt(),
                                    value: 1000),
                              ]).value,
                          child: child!),
                  child: BouncingScrollWrapper.builder(
                      context, buildPageByName(uri.path),
                      dragWithMouse: true));
            });
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   final Uri uri = Uri.parse(settings.name ?? '/');
      //   return buildPage(path: uri.path, queryParams: uri.queryParameters);
      // },

      // initialRoute: '/qizhengsiyu',
      // initialRoute: '/one_year',
      // initialRoute: '/qizhengsiyu', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      // initialRoute: '/daliuren', // 大六壬
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // mai
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildPageByName(String name) {
    switch (name) {
      case '/':
      case CrossPlatformMainPage.routeName:
        return const CrossPlatformMainPage();
      // case PostPage.name:
      //   return const PostPage();
      // case TypographyPage.name:
      //   return const TypographyPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Route<dynamic> buildPage(
      {required String path, Map<String, String> queryParams = const {}}) {
    return Routes.noAnimation(
        settings: RouteSettings(
            name: (path.startsWith('/') == false) ? '/$path' : path),
        builder: (context) {
          String pathName =
              path != '/' && path.startsWith('/') ? path.substring(1) : path;
          return switch (pathName) {
            // '/' || ListPage.name => const ListPage(),
            "ok" =>
              // Breakpoints can be nested.
              // Here's an example of custom "per-page" breakpoints.
              ResponsiveBreakpoints(breakpoints: [
                Breakpoint(start: 0, end: 480, name: MOBILE),
                Breakpoint(start: 481, end: 1200, name: TABLET),
                Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
              ], child: RootPage()),
            '/' ||
            CrossPlatformMainPage.routeName =>
              const CrossPlatformMainPage(),
            // TypographyPage.name => const TypographyPage(),
            _ => const SizedBox.shrink(),
          };
        });
  }
}
