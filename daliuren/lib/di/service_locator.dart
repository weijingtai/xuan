// lib/di/service_locator.dart

/// Service Locator setup using `get_it`.
/// This file is responsible for registering all dependencies (DataSources, Repositories,
/// UseCases, ViewModels, Services, etc.) so they can be easily accessed throughout the application.

import 'package:get_it/get_it.dart'; // The get_it package
import 'package:daliuren/data/datasources/local/database/drift_database.dart'; // Database class
import 'package:daliuren/data/datasources/local/database/local_data_source.dart'; // Local Data Source
// import 'package:daliuren/data/datasources/remote/remote_data_source.dart'; // Placeholder for Remote Data Source
import 'package:daliuren/data/repositories/liuren_repository_impl.dart'; // Repository Implementation
import 'package:daliuren/domain/repositories/liuren_repository.dart'; // Repository Interface
import 'package:daliuren/domain/usecases/initialize_database_usecase.dart'; // Use Cases
import 'package:daliuren/domain/usecases/calculate_liuren_pan_usecase.dart';
import 'package:daliuren/domain/usecases/get_yuding_entry_usecase.dart';
import 'package:daliuren/domain/services/liuren_calculation_service.dart'; // Domain Service
import 'package:daliuren/domain/services/shen_sha_calculation_service.dart'; // 神煞计算服务
import 'package:daliuren/domain/services/shen_sha_calculation_service_impl.dart'; // 神煞计算服务实现
import 'package:daliuren/data/services/shen_sha_data_service_impl.dart'; // 神煞数据服务实现
import 'package:daliuren/domain/usecases/calculate_shen_sha_usecase.dart'; // 神煞用例
import 'package:daliuren/presentation/viewmodels/my_home_viewmodel.dart';

import '../data/datasources/local/database/dao/liuren_dao.dart'; // ViewModel

/// Global GetIt instance, used as a Service Locator.
final sl = GetIt.instance;

/// Asynchronously sets up the Service Locator by registering all necessary dependencies.
/// This function should be called once at application startup (e.g., in `main.dart`).
Future<void> setupServiceLocator() async {
  // --- Core ---
  // Register core services like NetworkInfo, etc. if needed.
  // Example: sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // --- Database ---
  // Register AppDatabase as a lazy singleton, so it's created only when first needed
  // and a single instance is shared throughout the app.
  sl.registerLazySingleton<DaLiuRenAppDatabase>(() => DaLiuRenAppDatabase());

  // Register LiuRenDao as a lazy singleton. It depends on AppDatabase.
  // DAOs are typically tied to a database instance.
  sl.registerLazySingleton<LiuRenDao>(
      () => LiuRenDao(sl<DaLiuRenAppDatabase>()));

  // --- Data sources ---
  // Register LiuRenLocalDataSource implementation, dependent on LiuRenDao.
  sl.registerLazySingleton<LiuRenLocalDataSource>(
      () => LiuRenLocalDataSourceImpl(liuRenDao: sl<LiuRenDao>()));

  // Register RemoteDataSource if it existed.
  // sl.registerLazySingleton<LiuRenRemoteDataSource>(
  //     () => LiuRenRemoteDataSourceImpl(client: sl())); // Assuming an HttpClient (sl()) was registered

  // --- Repository ---
  // Register LiuRenRepository implementation, dependent on data sources.
  sl.registerLazySingleton<LiuRenRepository>(() => LiuRenRepositoryImpl(
        localDataSource: sl<LiuRenLocalDataSource>(),
        // remoteDataSource: sl<LiuRenRemoteDataSource>(), // Uncomment if remote source is used
        // networkInfo: sl<NetworkInfo>(), // Uncomment if network checks are needed
      ));

  // --- Domain Services ---
  // Register LiuRenCalculationService. This is a placeholder implementation.
  // Lazy singleton is appropriate as it's likely stateless or its state is managed internally.
  sl.registerLazySingleton<LiuRenCalculationService>(
      () => LiuRenCalculationServiceImpl());

  // Register 神煞 related services
  sl.registerLazySingleton<ShenShaDataService>(
      () => ShenShaDataServiceImpl());
  sl.registerLazySingleton<ShenShaCalculationService>(
      () => ShenShaCalculationServiceImpl(dataService: sl<ShenShaDataService>()));

  // --- Use cases ---
  // Use cases are typically stateless and depend on repositories or services.
  // Lazy singletons are often suitable.
  sl.registerLazySingleton(
      () => InitializeDatabaseUseCase(sl<LiuRenRepository>()));
  sl.registerLazySingleton(
      () => CalculateLiuRenPanUseCase(sl<LiuRenRepository>()));
  // Alternative for CalculateLiuRenPanUseCase if it directly used LiuRenCalculationService:
  // sl.registerLazySingleton(() => CalculateLiuRenPanUseCase(repository: sl<LiuRenRepository>(), calculationService: sl<LiuRenCalculationService>()));
  sl.registerLazySingleton(() => GetYuDingEntryUseCase(sl<LiuRenRepository>()));
  
  // Register 神煞 use cases
  sl.registerLazySingleton(() => CalculateShenShaUseCase(sl<ShenShaCalculationService>()));
  sl.registerLazySingleton(() => GetShenShaAtLocationUseCase(sl<ShenShaCalculationService>()));
  sl.registerLazySingleton(() => FindShenShaByNameUseCase(sl<ShenShaCalculationService>()));

  // --- ViewModels (or BloCs/Cubits using flutter_bloc) ---
  // ViewModels (like those using ChangeNotifier) are often registered as factories.
  // This ensures a new instance is created each time it's requested, which is suitable
  // when using `Provider(create: (_) => sl<MyViewModel>())` where Provider manages the lifecycle.
  // If a ViewModel's state needs to be preserved across different parts of the widget tree
  // independently of Provider's default behavior, other strategies might be used (e.g. Provider.value with an instance managed elsewhere).
  sl.registerFactory(() => MyHomePageViewModel(
        initializeDatabaseUseCase: sl<InitializeDatabaseUseCase>(),
        calculateLiuRenPanUseCase: sl<CalculateLiuRenPanUseCase>(),
        getYuDingEntryUseCase: sl<GetYuDingEntryUseCase>(),
        // If ViewModel needed the calculation service directly (less common if use cases handle orchestration):
        // liuRenCalculationService: sl<LiuRenCalculationService>(),
      ));

  print("Service Locator: All dependencies registered.");
}
