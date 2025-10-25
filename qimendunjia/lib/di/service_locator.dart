import 'package:qimendunjia/data/datasources/cache_data_source.dart';
import 'package:qimendunjia/data/datasources/calculator/qimen_calculator_data_source.dart';
import 'package:qimendunjia/data/datasources/json_data_source.dart';
import 'package:qimendunjia/data/repositories/qimen_calculator_repository_impl.dart';
import 'package:qimendunjia/data/repositories/qimen_data_repository_impl.dart';
import 'package:qimendunjia/domain/repositories/qimen_calculator_repository.dart';
import 'package:qimendunjia/domain/repositories/qimen_data_repository.dart';
import 'package:qimendunjia/domain/usecases/arrange_pan_usecase.dart';
import 'package:qimendunjia/domain/usecases/calculate_ju_usecase.dart';
import 'package:qimendunjia/domain/usecases/select_gong_usecase.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/presentation/viewmodels/qimen_viewmodel.dart';

/// 服务定位器
///
/// 负责管理整个应用的依赖注入
/// 使用单例模式确保全局唯一的依赖容器
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // 缓存已创建的实例
  final Map<Type, dynamic> _services = {};

  /// 初始化所有依赖
  void init() {
    // 1. 注册数据源
    _registerDataSources();

    // 2. 注册仓储
    _registerRepositories();

    // 3. 注册用例
    _registerUseCases();

    // 4. 注册ViewModel
    _registerViewModels();
  }

  /// 注册数据源
  void _registerDataSources() {
    // JSON 数据源（单例）
    _services[JsonDataSource] = JsonDataSource();

    // 缓存数据源（单例）
    _services[CacheDataSource] = CacheDataSource();

    // 计算器数据源（每种算法一个实例）
    _services[Map<ArrangeType, QiMenCalculatorDataSource>] = {
      ArrangeType.CHAI_BU: ChaiBuCalculatorDataSource(),
      ArrangeType.ZHI_RUN: ZhiRunCalculatorDataSource(),
      ArrangeType.MAO_SHAN: MaoShanCalculatorDataSource(),
      ArrangeType.YIN_PAN: YinPanCalculatorDataSource(),
    };
  }

  /// 注册仓储
  void _registerRepositories() {
    // 奇门数据仓储
    _services[QiMenDataRepository] = QiMenDataRepositoryImpl(
      get<JsonDataSource>(),
      get<CacheDataSource>(),
    );

    // 奇门计算器仓储
    _services[QiMenCalculatorRepository] = QiMenCalculatorRepositoryImpl(
      get<Map<ArrangeType, QiMenCalculatorDataSource>>(),
    );
  }

  /// 注册用例
  void _registerUseCases() {
    // 计算局数用例
    _services[CalculateJuUseCase] = CalculateJuUseCase(
      get<QiMenCalculatorRepository>(),
    );

    // 排盘用例
    _services[ArrangePanUseCase] = ArrangePanUseCase(
      get<QiMenCalculatorRepository>(),
    );

    // 选宫用例
    _services[SelectGongUseCase] = SelectGongUseCase(
      get<QiMenDataRepository>(),
    );
  }

  /// 注册ViewModels
  void _registerViewModels() {
    // 奇门遁甲 ViewModel
    // 使用工厂模式，每次获取都创建新实例
    // 因为 ViewModel 需要在每个页面有独立的状态
  }

  /// 创建 QiMenViewModel 实例（工厂方法）
  QiMenViewModel createQiMenViewModel() {
    return QiMenViewModel(
      get<CalculateJuUseCase>(),
      get<ArrangePanUseCase>(),
      get<SelectGongUseCase>(),
    );
  }

  /// 获取服务实例
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  /// 清理所有服务
  void dispose() {
    _services.clear();
  }

  /// 重置服务定位器（用于测试）
  void reset() {
    _services.clear();
    init();
  }
}

/// 全局服务定位器实例
final serviceLocator = ServiceLocator();
