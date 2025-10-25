# 奇门遁甲模块 - MVVM+UseCase+Repository 架构重构方案

## 📋 执行摘要

本文档详细规划了将 qimendunjia 模块从当前混乱的代码结构重构为现代标准的 MVVM+UseCase+Repository 架构。重构将保留所有现有 UI 页面，确保零业务逻辑中断。

---

## 🎯 重构目标

### 核心目标
1. ✅ **引入 Clean Architecture**: 实现清晰的层次分离
2. ✅ **保留旧版 UI**: 不修改任何现有 UI 代码，保持向后兼容
3. ✅ **Provider DI**: 使用 Provider 进行依赖注入
4. ✅ **可测试性**: 大幅提升代码可测试性
5. ✅ **可维护性**: 降低耦合度，提高代码可维护性

### 非目标
- ❌ 不修改现有 UI 界面
- ❌ 不改变现有功能行为
- ❌ 不进行数据库迁移（当前无数据库）
- ❌ 不重写算法逻辑（保持算法不变）

---

## 🏗️ 架构设计

### 新架构分层

```
qimendunjia/
├── lib/
│   ├── domain/                    # 领域层（业务核心）
│   │   ├── entities/             # 实体（纯业务对象）
│   │   │   ├── qimen_pan.dart
│   │   │   ├── shi_jia_ju.dart
│   │   │   ├── each_gong.dart
│   │   │   ├── gong_wang_shuai.dart
│   │   │   └── pan_settings.dart
│   │   ├── repositories/         # 仓储接口
│   │   │   ├── qimen_calculator_repository.dart
│   │   │   └── qimen_data_repository.dart
│   │   └── usecases/            # 用例（业务逻辑）
│   │       ├── calculate_ju_usecase.dart
│   │       ├── arrange_pan_usecase.dart
│   │       ├── load_ke_ying_usecase.dart
│   │       ├── select_gong_usecase.dart
│   │       └── analyze_ge_ju_usecase.dart
│   │
│   ├── data/                     # 数据层
│   │   ├── models/              # 数据模型（带序列化）
│   │   │   ├── qimen_pan_model.dart
│   │   │   ├── shi_jia_ju_model.dart
│   │   │   └── mappers/        # Entity ↔ Model 转换
│   │   │       ├── qimen_pan_mapper.dart
│   │   │       └── shi_jia_ju_mapper.dart
│   │   ├── datasources/         # 数据源
│   │   │   ├── json_data_source.dart
│   │   │   ├── cache_data_source.dart
│   │   │   └── calculator/     # 计算器实现
│   │   │       ├── chaibu_calculator_impl.dart
│   │   │       ├── zhirun_calculator_impl.dart
│   │   │       ├── maoshan_calculator_impl.dart
│   │   │       └── yinpan_calculator_impl.dart
│   │   └── repositories/        # 仓储实现
│   │       ├── qimen_calculator_repository_impl.dart
│   │       └── qimen_data_repository_impl.dart
│   │
│   ├── presentation/            # 表示层
│   │   ├── viewmodels/         # ViewModel
│   │   │   └── qimen_viewmodel.dart
│   │   ├── views/              # 新版 View（可选）
│   │   │   └── qimen_view.dart
│   │   └── widgets/            # 共享组件
│   │
│   ├── di/                      # 依赖注入
│   │   └── dependency_injection.dart
│   │
│   ├── pages/                   # 旧版 UI（保留）
│   │   ├── primary_page.dart
│   │   ├── shi_jia_qi_men_view_page.dart
│   │   └── scalable_shi_jia_qi_men_view_page.dart
│   │
│   ├── legacy/                  # 遗留代码（渐进迁移）
│   │   ├── model/              # 旧模型（逐步废弃）
│   │   └── utils/              # 旧工具类（逐步废弃）
│   │
│   └── main.dart               # 入口（支持新旧切换）
```

---

## 📊 当前架构问题分析

### 问题 1: 职责混乱

**当前状态**:
```dart
// ShiJiaQiMenViewModel - 职责过多
class ShiJiaQiMenViewModel extends ChangeNotifier {
  // ❌ 直接实例化业务对象
  void createShiJiaQiMen(...) {
    var shiJiaQiMen = ShiJiaQiMen(...);
  }

  // ❌ 直接加载数据
  Future<TenGanKeYing?> loadTenGanKeyYing(...) {
    return ReadDataUtils.readTenGanKeYing();
  }

  // ❌ 混合了业务逻辑和数据访问
  Future<void> selectGong(...) {
    // 计算逻辑
    // 数据加载
    // 状态更新
  }
}
```

### 问题 2: 硬编码依赖

**当前状态**:
```dart
// ❌ 直接依赖具体实现
class ReadDataUtils {
  static Future<Map> readTenGanKeYing() {
    String jsonString = await rootBundle.loadString('...');
    return jsonDecode(jsonString);
  }
}
```

### 问题 3: 无法测试

**当前状态**:
```dart
// ❌ 无法 mock
test('test calculate ju', () {
  final viewModel = ShiJiaQiMenViewModel(context);
  // 无法注入 mock 依赖
  // 依赖真实文件系统
});
```

---

## 🔧 重构策略

### 策略 1: 渐进式重构

采用"绞杀者模式"（Strangler Pattern），逐步替换旧代码：

```
Phase 1: 建立新架构骨架
  ├─ 创建 domain 层
  ├─ 创建 data 层
  ├─ 建立 DI 容器
  └─ 保持旧代码运行

Phase 2: 迁移核心逻辑
  ├─ 实现 UseCases
  ├─ 实现 Repositories
  ├─ 迁移计算器
  └─ 旧 UI 继续使用旧代码

Phase 3: 重构 ViewModel
  ├─ 创建新 ViewModel
  ├─ 注入 UseCases
  ├─ 旧 UI 切换到新 ViewModel
  └─ 保留旧代码作为备份

Phase 4: 清理与优化
  ├─ 移除未使用代码
  ├─ 完善测试
  └─ 文档更新
```

### 策略 2: UI 兼容性保证

```dart
// main.dart - 支持新旧 UI 切换
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 环境变量控制
    final useNewArch = bool.fromEnvironment('USE_NEW_ARCH', defaultValue: false);

    if (useNewArch) {
      // 新架构 + 新 UI
      return MultiProvider(
        providers: DependencyInjection.getProviders(),
        child: MaterialApp(
          home: QiMenView(), // 新 UI
        ),
      );
    } else {
      // 新架构 + 旧 UI
      return MultiProvider(
        providers: DependencyInjection.getProviders(),
        child: MaterialApp(
          home: ScalableShiJiaQiMenViewPage(), // 旧 UI
        ),
      );
    }
  }
}
```

---

## 📝 详细实施计划

### Phase 1: 建立架构骨架 (1-2天)

#### Step 1.1: 创建 Domain 层

**文件: `domain/entities/qimen_pan.dart`**
```dart
/// 奇门盘实体（纯业务对象，无依赖）
class QiMenPan {
  final String id;
  final DateTime panDateTime;
  final ShiJiaJu shiJiaJu;
  final PlateType plateType;
  final Map<HouTianGua, EachGong> gongMapper;
  final EightDoorEnum zhiShiDoor;
  final NineStarsEnum zhiFuStar;
  final bool isStarFuYin;
  final bool isDoorFuYin;
  // ... 所有业务属性

  const QiMenPan({
    required this.id,
    required this.panDateTime,
    required this.shiJiaJu,
    required this.plateType,
    required this.gongMapper,
    required this.zhiShiDoor,
    required this.zhiFuStar,
    required this.isStarFuYin,
    required this.isDoorFuYin,
  });

  // 纯业务方法
  bool get hasAnyFuYin => isStarFuYin || isDoorFuYin;
  List<EnumMostPopularGeJu> getGeJuList() { /* ... */ }
}
```

**文件: `domain/repositories/qimen_calculator_repository.dart`**
```dart
/// 奇门计算器仓储接口
abstract class QiMenCalculatorRepository {
  /// 计算局数
  Future<ShiJiaJu> calculateJu({
    required DateTime dateTime,
    required ArrangeType arrangeType,
  });

  /// 排盘
  Future<QiMenPan> arrangePan({
    required ShiJiaJu ju,
    required PlateType plateType,
    required PanSettings settings,
  });
}
```

**文件: `domain/repositories/qimen_data_repository.dart`**
```dart
/// 奇门数据仓储接口
abstract class QiMenDataRepository {
  /// 获取十干克应
  Future<TenGanKeYing> getTenGanKeYing({
    required TianGan tianPan,
    required TianGan diPan,
  });

  /// 获取门星克应
  Future<DoorStarKeYing> getDoorStarKeYing({
    required EightDoorEnum door,
    required NineStarsEnum star,
  });

  /// 获取三奇入宫
  Future<QiYiRuGong?> getQiYiRuGong({
    required HouTianGua gong,
    required TianGan gan,
  });

  // ... 其他数据访问方法
}
```

#### Step 1.2: 创建 UseCase

**文件: `domain/usecases/calculate_ju_usecase.dart`**
```dart
/// 计算局数用例
class CalculateJuUseCase {
  final QiMenCalculatorRepository _repository;

  CalculateJuUseCase(this._repository);

  Future<ShiJiaJu> execute({
    required DateTime dateTime,
    required ArrangeType arrangeType,
  }) async {
    try {
      return await _repository.calculateJu(
        dateTime: dateTime,
        arrangeType: arrangeType,
      );
    } catch (e) {
      // 统一错误处理
      throw QiMenCalculationException('计算局数失败: $e');
    }
  }
}
```

**文件: `domain/usecases/arrange_pan_usecase.dart`**
```dart
/// 排盘用例
class ArrangePanUseCase {
  final QiMenCalculatorRepository _calculatorRepo;
  final QiMenDataRepository _dataRepo;

  ArrangePanUseCase(this._calculatorRepo, this._dataRepo);

  Future<QiMenPan> execute({
    required ShiJiaJu ju,
    required PlateType plateType,
    required PanSettings settings,
  }) async {
    try {
      // 1. 排盘
      final pan = await _calculatorRepo.arrangePan(
        ju: ju,
        plateType: plateType,
        settings: settings,
      );

      // 2. 加载格局数据（可选，按需加载）
      // ...

      return pan;
    } catch (e) {
      throw QiMenCalculationException('排盘失败: $e');
    }
  }
}
```

**文件: `domain/usecases/select_gong_usecase.dart`**
```dart
/// 选择宫位用例（加载详细信息）
class SelectGongUseCase {
  final QiMenDataRepository _dataRepo;

  SelectGongUseCase(this._dataRepo);

  Future<GongDetailInfo> execute({
    required QiMenPan pan,
    required HouTianGua gongGua,
  }) async {
    final gong = pan.gongMapper[gongGua]!;

    // 并行加载所有数据
    final results = await Future.wait([
      _loadTenGanKeYing(pan, gong),
      _loadDoorStarKeYing(gong),
      _loadQiYiRuGong(gong),
      _loadEightDoorKeYing(gong),
    ]);

    return GongDetailInfo(
      gong: gong,
      tenGanKeYing: results[0] as TenGanKeYingData,
      doorStarKeYing: results[1] as DoorStarKeYing?,
      qiYiRuGong: results[2] as QiYiRuGong?,
      doorKeYing: results[3] as Map<YinYang, EightDoorKeYing>,
    );
  }

  Future<TenGanKeYingData> _loadTenGanKeYing(...) async { /* ... */ }
  Future<DoorStarKeYing?> _loadDoorStarKeYing(...) async { /* ... */ }
  Future<QiYiRuGong?> _loadQiYiRuGong(...) async { /* ... */ }
  Future<Map<YinYang, EightDoorKeYing>> _loadEightDoorKeYing(...) async { /* ... */ }
}
```

#### Step 1.3: 创建 Data 层

**文件: `data/repositories/qimen_calculator_repository_impl.dart`**
```dart
/// 奇门计算器仓储实现
class QiMenCalculatorRepositoryImpl implements QiMenCalculatorRepository {
  final Map<ArrangeType, QiMenCalculator> _calculators;

  QiMenCalculatorRepositoryImpl(this._calculators);

  @override
  Future<ShiJiaJu> calculateJu({
    required DateTime dateTime,
    required ArrangeType arrangeType,
  }) async {
    final calculator = _calculators[arrangeType];
    if (calculator == null) {
      throw ArgumentError('不支持的起盘方式: $arrangeType');
    }

    return await calculator.calculate(dateTime);
  }

  @override
  Future<QiMenPan> arrangePan({
    required ShiJiaJu ju,
    required PlateType plateType,
    required PanSettings settings,
  }) async {
    // 调用 ShiJiaQiMen 进行排盘
    final shiJiaQiMen = ShiJiaQiMen(
      plateType: plateType,
      shiJiaJu: ju.toModel(), // 使用 mapper 转换
      settings: settings.toModel(),
    );

    // 转换为 Entity
    return QiMenPanMapper.fromModel(shiJiaQiMen);
  }
}
```

**文件: `data/repositories/qimen_data_repository_impl.dart`**
```dart
/// 奇门数据仓储实现（带缓存）
class QiMenDataRepositoryImpl implements QiMenDataRepository {
  final JsonDataSource _jsonDataSource;
  final CacheDataSource _cacheDataSource;

  QiMenDataRepositoryImpl(this._jsonDataSource, this._cacheDataSource);

  @override
  Future<TenGanKeYing> getTenGanKeYing({
    required TianGan tianPan,
    required TianGan diPan,
  }) async {
    final cacheKey = 'ten_gan_${tianPan.name}_${diPan.name}';

    // 1. 尝试从缓存获取
    final cached = await _cacheDataSource.get<TenGanKeYing>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. 从 JSON 加载
    final data = await _jsonDataSource.loadTenGanKeYing();
    final result = data[tianPan]?[diPan];

    if (result == null) {
      throw QiMenDataNotFoundException(
        '未找到 $tianPan-$diPan 的十干克应数据'
      );
    }

    // 3. 缓存结果
    await _cacheDataSource.set(cacheKey, result);

    return result;
  }

  // ... 其他方法类似
}
```

**文件: `data/datasources/json_data_source.dart`**
```dart
/// JSON 数据源（单例 + 懒加载）
class JsonDataSource {
  final AssetBundle _assetBundle;
  final Map<String, dynamic> _cache = {};

  JsonDataSource(this._assetBundle);

  Future<Map<TianGan, Map<TianGan, TenGanKeYing>>> loadTenGanKeYing() async {
    const key = 'ten_gan_ke_ying';
    if (_cache.containsKey(key)) {
      return _cache[key] as Map<TianGan, Map<TianGan, TenGanKeYing>>;
    }

    final jsonString = await _assetBundle.loadString(
      'packages/qimendunjia/assets/data/ten_gan_ke_ying.json'
    );
    final jsonData = jsonDecode(jsonString);

    // 解析并缓存
    final result = _parseTenGanKeYing(jsonData);
    _cache[key] = result;

    return result;
  }

  Map<TianGan, Map<TianGan, TenGanKeYing>> _parseTenGanKeYing(Map<String, dynamic> json) {
    // 解析逻辑（从 ReadDataUtils 迁移）
    // ...
  }

  // ... 其他加载方法
}
```

**文件: `data/datasources/cache_data_source.dart`**
```dart
/// 内存缓存数据源
class CacheDataSource {
  final Map<String, dynamic> _cache = {};
  final int _maxSize;

  CacheDataSource({int maxSize = 1000}) : _maxSize = maxSize;

  Future<T?> get<T>(String key) async {
    return _cache[key] as T?;
  }

  Future<void> set<T>(String key, T value) async {
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first); // 简单 LRU
    }
    _cache[key] = value;
  }

  Future<void> clear() async {
    _cache.clear();
  }
}
```

#### Step 1.4: 创建依赖注入

**文件: `di/dependency_injection.dart`**
```dart
/// 依赖注入容器
class DependencyInjection {
  static List<SingleChildWidget> getProviders() {
    // 1. 创建数据源
    final jsonDataSource = JsonDataSource(rootBundle);
    final cacheDataSource = CacheDataSource();

    // 2. 创建仓储
    final calculatorRepo = QiMenCalculatorRepositoryImpl({
      ArrangeType.CHAI_BU: ChaiBuCalculator(),
      ArrangeType.ZHI_RUN: ZhiRunCalculator(),
      ArrangeType.MAO_SHAN: MaoShanCalculator(),
      ArrangeType.YIN_PAN: YinPanCalculator(),
    });

    final dataRepo = QiMenDataRepositoryImpl(
      jsonDataSource,
      cacheDataSource,
    );

    // 3. 创建用例
    final calculateJuUseCase = CalculateJuUseCase(calculatorRepo);
    final arrangePanUseCase = ArrangePanUseCase(calculatorRepo, dataRepo);
    final selectGongUseCase = SelectGongUseCase(dataRepo);

    // 4. 创建 ViewModel
    final qimenViewModel = QiMenViewModel(
      calculateJuUseCase: calculateJuUseCase,
      arrangePanUseCase: arrangePanUseCase,
      selectGongUseCase: selectGongUseCase,
    );

    return [
      // Repositories
      Provider<QiMenCalculatorRepository>.value(value: calculatorRepo),
      Provider<QiMenDataRepository>.value(value: dataRepo),

      // UseCases
      Provider<CalculateJuUseCase>.value(value: calculateJuUseCase),
      Provider<ArrangePanUseCase>.value(value: arrangePanUseCase),
      Provider<SelectGongUseCase>.value(value: selectGongUseCase),

      // ViewModel
      ChangeNotifierProvider<QiMenViewModel>.value(value: qimenViewModel),
    ];
  }
}
```

---

### Phase 2: 重构 ViewModel (2-3天)

#### Step 2.1: 创建新 ViewModel

**文件: `presentation/viewmodels/qimen_viewmodel.dart`**
```dart
/// 奇门 ViewModel（新架构）
class QiMenViewModel extends ChangeNotifier {
  final CalculateJuUseCase _calculateJuUseCase;
  final ArrangePanUseCase _arrangePanUseCase;
  final SelectGongUseCase _selectGongUseCase;

  // State
  QiMenPan? _currentPan;
  GongDetailInfo? _selectedGongInfo;
  bool _isLoading = false;
  String? _error;

  // Getters
  QiMenPan? get currentPan => _currentPan;
  GongDetailInfo? get selectedGongInfo => _selectedGongInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QiMenViewModel({
    required CalculateJuUseCase calculateJuUseCase,
    required ArrangePanUseCase arrangePanUseCase,
    required SelectGongUseCase selectGongUseCase,
  })  : _calculateJuUseCase = calculateJuUseCase,
        _arrangePanUseCase = arrangePanUseCase,
        _selectGongUseCase = selectGongUseCase;

  /// 创建盘局
  Future<void> createPan({
    required DateTime dateTime,
    required ArrangeType arrangeType,
    required PlateType plateType,
    required PanSettings settings,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. 计算局数
      final ju = await _calculateJuUseCase.execute(
        dateTime: dateTime,
        arrangeType: arrangeType,
      );

      // 2. 排盘
      final pan = await _arrangePanUseCase.execute(
        ju: ju,
        plateType: plateType,
        settings: settings,
      );

      _currentPan = pan;
      _selectedGongInfo = null; // 重置选择
      notifyListeners();
    } catch (e) {
      _setError('创建盘局失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 选择宫位
  Future<void> selectGong(HouTianGua gongGua) async {
    if (_currentPan == null) return;

    _setLoading(true);
    try {
      final info = await _selectGongUseCase.execute(
        pan: _currentPan!,
        gongGua: gongGua,
      );

      _selectedGongInfo = info;
      notifyListeners();
    } catch (e) {
      _setError('加载宫位信息失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 取消选择
  void clearSelection() {
    _selectedGongInfo = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) notifyListeners();
  }

  @override
  void dispose() {
    // 清理资源
    super.dispose();
  }
}
```

#### Step 2.2: 适配旧 UI

**文件: `pages/scalable_shi_jia_qi_men_view_page.dart` (修改)**
```dart
// 旧 UI，使用新 ViewModel
class ScalableShiJiaQiMenViewPage extends StatefulWidget {
  const ScalableShiJiaQiMenViewPage({Key? key}) : super(key: key);

  @override
  State<ScalableShiJiaQiMenViewPage> createState() =>
      _ScalableShiJiaQiMenViewPageState();
}

class _ScalableShiJiaQiMenViewPageState
    extends State<ScalableShiJiaQiMenViewPage> {
  late QiMenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 从 Provider 获取 ViewModel
    _viewModel = context.read<QiMenViewModel>();
  }

  void _handleCreatePan() {
    _viewModel.createPan(
      dateTime: _selectedDateTime,
      arrangeType: _selectedArrangeType,
      plateType: _selectedPlateType,
      settings: _currentSettings,
    );
  }

  void _handleGongTap(HouTianGua gong) {
    _viewModel.selectGong(gong);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QiMenViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return _buildLoadingWidget();
        }

        if (viewModel.error != null) {
          return _buildErrorWidget(viewModel.error!);
        }

        if (viewModel.currentPan == null) {
          return _buildEmptyWidget();
        }

        // 使用现有 UI 代码，只是数据来源改为 viewModel
        return _buildPanWidget(viewModel.currentPan!);
      },
    );
  }

  // 保留所有现有 UI 构建方法，只修改数据来源
  Widget _buildPanWidget(QiMenPan pan) {
    // 现有代码不变，只是从 pan 读取数据
    // ...
  }
}
```

---

### Phase 3: 测试 (1天)

#### Step 3.1: UseCase 测试

**文件: `test/domain/usecases/calculate_ju_usecase_test.dart`**
```dart
void main() {
  late MockQiMenCalculatorRepository mockRepo;
  late CalculateJuUseCase useCase;

  setUp(() {
    mockRepo = MockQiMenCalculatorRepository();
    useCase = CalculateJuUseCase(mockRepo);
  });

  group('CalculateJuUseCase', () {
    test('should return ShiJiaJu when repository succeeds', () async {
      // Arrange
      final dateTime = DateTime(2023, 12, 1, 12, 0);
      final expectedJu = ShiJiaJu(/* ... */);
      when(() => mockRepo.calculateJu(
        dateTime: any(named: 'dateTime'),
        arrangeType: any(named: 'arrangeType'),
      )).thenAnswer((_) async => expectedJu);

      // Act
      final result = await useCase.execute(
        dateTime: dateTime,
        arrangeType: ArrangeType.CHAI_BU,
      );

      // Assert
      expect(result, equals(expectedJu));
      verify(() => mockRepo.calculateJu(
        dateTime: dateTime,
        arrangeType: ArrangeType.CHAI_BU,
      )).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(() => mockRepo.calculateJu(
        dateTime: any(named: 'dateTime'),
        arrangeType: any(named: 'arrangeType'),
      )).thenThrow(Exception('计算失败'));

      // Act & Assert
      expect(
        () => useCase.execute(
          dateTime: DateTime.now(),
          arrangeType: ArrangeType.CHAI_BU,
        ),
        throwsA(isA<QiMenCalculationException>()),
      );
    });
  });
}
```

#### Step 3.2: ViewModel 测试

**文件: `test/presentation/viewmodels/qimen_viewmodel_test.dart`**
```dart
void main() {
  late MockCalculateJuUseCase mockCalculateJu;
  late MockArrangePanUseCase mockArrangePan;
  late MockSelectGongUseCase mockSelectGong;
  late QiMenViewModel viewModel;

  setUp(() {
    mockCalculateJu = MockCalculateJuUseCase();
    mockArrangePan = MockArrangePanUseCase();
    mockSelectGong = MockSelectGongUseCase();

    viewModel = QiMenViewModel(
      calculateJuUseCase: mockCalculateJu,
      arrangePanUseCase: mockArrangePan,
      selectGongUseCase: mockSelectGong,
    );
  });

  group('QiMenViewModel', () {
    test('createPan should update currentPan on success', () async {
      // Arrange
      final ju = ShiJiaJu(/* ... */);
      final pan = QiMenPan(/* ... */);

      when(() => mockCalculateJu.execute(
        dateTime: any(named: 'dateTime'),
        arrangeType: any(named: 'arrangeType'),
      )).thenAnswer((_) async => ju);

      when(() => mockArrangePan.execute(
        ju: any(named: 'ju'),
        plateType: any(named: 'plateType'),
        settings: any(named: 'settings'),
      )).thenAnswer((_) async => pan);

      // Act
      await viewModel.createPan(
        dateTime: DateTime.now(),
        arrangeType: ArrangeType.CHAI_BU,
        plateType: PlateType.ZHUAN_PAN,
        settings: PanSettings(),
      );

      // Assert
      expect(viewModel.currentPan, equals(pan));
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    test('createPan should set error on failure', () async {
      // Arrange
      when(() => mockCalculateJu.execute(
        dateTime: any(named: 'dateTime'),
        arrangeType: any(named: 'arrangeType'),
      )).thenThrow(Exception('测试错误'));

      // Act
      await viewModel.createPan(
        dateTime: DateTime.now(),
        arrangeType: ArrangeType.CHAI_BU,
        plateType: PlateType.ZHUAN_PAN,
        settings: PanSettings(),
      );

      // Assert
      expect(viewModel.currentPan, null);
      expect(viewModel.error, isNotNull);
      expect(viewModel.isLoading, false);
    });
  });
}
```

---

## 📋 实施检查清单

### Phase 1: 架构骨架 ✅
- [ ] 创建 `domain/entities/` 目录和实体
- [ ] 创建 `domain/repositories/` 接口
- [ ] 创建 `domain/usecases/` 用例
- [ ] 创建 `data/repositories/` 实现
- [ ] 创建 `data/datasources/` 数据源
- [ ] 创建 `di/dependency_injection.dart`
- [ ] 更新 `pubspec.yaml` 添加依赖
- [ ] 运行 `flutter pub get`

### Phase 2: ViewModel 重构 ✅
- [ ] 创建 `presentation/viewmodels/qimen_viewmodel.dart`
- [ ] 修改 `main.dart` 集成 DI
- [ ] 修改旧 UI 使用新 ViewModel
- [ ] 测试旧 UI 功能正常

### Phase 3: 测试 ✅
- [ ] 编写 UseCase 单元测试
- [ ] 编写 Repository 单元测试
- [ ] 编写 ViewModel 单元测试
- [ ] 运行所有测试确保通过

### Phase 4: 文档与清理 ✅
- [ ] 更新 README.md
- [ ] 添加架构文档
- [ ] 标记遗留代码
- [ ] 清理未使用代码

---

## 🔄 迁移路径示例

### 示例 1: 从旧 ViewModel 迁移

**旧代码 (ShiJiaQiMenViewModel)**:
```dart
class ShiJiaQiMenViewModel extends ChangeNotifier {
  void createShiJiaQiMen(PlateType plateType, DateTime dateTime,
      ShiJiaJu shiJiaJu, PanArrangeSettings settings) {
    var shiJiaQiMen = ShiJiaQiMen(
      plateType: plateType,
      shiJiaJu: shiJiaJu,
      settings: settings,
    );
    _shiJiaQiMen = shiJiaQiMen;
    notifyListeners();
  }
}
```

**新代码 (QiMenViewModel)**:
```dart
class QiMenViewModel extends ChangeNotifier {
  Future<void> createPan({
    required DateTime dateTime,
    required ArrangeType arrangeType,
    required PlateType plateType,
    required PanSettings settings,
  }) async {
    final ju = await _calculateJuUseCase.execute(...);
    final pan = await _arrangePanUseCase.execute(...);
    _currentPan = pan;
    notifyListeners();
  }
}
```

### 示例 2: 从直接数据访问迁移

**旧代码**:
```dart
Future<TenGanKeYing?> loadTenGanKeyYing(TianGan tianPan, TianGan diPan) async {
  Map<TianGan, Map<TianGan, TenGanKeYing>> loadResult =
      await ReadDataUtils.readTenGanKeYing();
  return loadResult[tianPan]?[diPan];
}
```

**新代码**:
```dart
// 在 UseCase 中
final keying = await _dataRepository.getTenGanKeYing(
  tianPan: tianPan,
  diPan: diPan,
);
```

---

## 📊 关键指标

### 重构前
- 代码层数: 2层（UI + Utils）
- 可测试性: 低（30%）
- 耦合度: 高
- 可维护性: 中

### 重构后
- 代码层数: 4层（Domain + Data + Presentation + DI）
- 可测试性: 高（80%+）
- 耦合度: 低
- 可维护性: 高

---

## ⚠️ 风险与应对

### 风险 1: 重构破坏现有功能
**应对**:
- 保留所有旧代码
- 渐进式迁移
- 每个阶段充分测试

### 风险 2: 性能下降
**应对**:
- 实现缓存层
- 性能基准测试
- 优化热点代码

### 风险 3: 学习曲线
**应对**:
- 详细文档
- 代码示例
- 团队培训

---

## 📚 参考资料

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Provider Documentation](https://pub.dev/packages/provider)
- [DaLiuRen Module](../daliuren) - 参考实现

---

**文档版本**: v1.0
**创建日期**: 2025-10-01
**最后更新**: 2025-10-01
