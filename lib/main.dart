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

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    await Firebase.initializeApp();
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
        ChangeNotifierProvider<ActiveAccountStore>(
          create: (ctx) => ActiveAccountStore(
            registry: ctx.read<AccountRegistry>(),
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
              throw StateError('FirebaseAuth not initialized');
            }
            return FirebaseEmailAuthAdapter(auth: auth);
          },
        ),
        Provider<IdentityResolver>(
          create: (ctx) {
            final firestore = ctx.read<FirebaseFirestore?>();
            if (firestore == null) {
              throw StateError('FirebaseFirestore not initialized');
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

    if (!store.isSignedIn) {
      return const MaterialApp(home: AuthPage());
    }

    final appUserId = store.activeAppUserId!;
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
        child: const MyApp(),
      ),
    );
  }
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
