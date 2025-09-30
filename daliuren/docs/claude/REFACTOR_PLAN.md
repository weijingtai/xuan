# 大六壬 MVVM+UseCase+Repository 重构计划

## 一、项目背景与现状分析

### 1.1 当前架构状态

✅ **已完成的MVVM基础架构**:
- `presentation/viewmodels/` - ViewModel层已实现
  - `BaseViewModel`: 统一状态管理 (idle/loading/success/error)
  - `DaLiuRenViewModel`: 大六壬业务ViewModel
- `presentation/views/` - View层已实现
  - `DaLiuRenView`: 新版MVVM视图
  - `widgets/`: 组件化UI (DateTimeSelectorWidget, DivinationDisplayWidget等)
- `domain/` - 领域层已初步搭建
  - `usecases/`: UseCase层 (CalculateDivinationUseCase, LoadDivinationDataUseCase)
  - `repositories/`: Repository抽象接口
- `data/repositories/` - 数据层实现
  - `DaLiuRenRepositoryImpl`: Repository实现(但计算逻辑为占位符)
- `di/dependency_injection.dart` - 依赖注入配置

⚠️ **存在的主要问题**:

1. **Model层职责过重** (Critical)
   - `da_liu_ren_ke_pan.dart` (1827行): 包含大量静态计算方法
   - 违反单一职责原则,Model应该是纯数据模型
   - 业务逻辑(四课、三传、九宗门计算)都在Model层

2. **Repository实现不完整** (Major)
   - `DaLiuRenRepositoryImpl.calculateDivination()` 使用占位符
   - 缺少真实的农历计算、月将推算、局数计算

3. **旧版UI未隔离** (Major)
   - `pages/my_home_page.dart` (3000+行): 旧版本UI,未使用MVVM
   - 直接在Widget中进行复杂计算和状态管理
   - 需要标记为legacy或移除

4. **性能优化不足** (Major)
   - 大数据文件(~7MB) 一次性全量加载
   - 缺少懒加载和缓存策略

5. **测试覆盖不足** (Minor)
   - 缺少ViewModel、Repository、UseCase的单元测试
   - 缺少Widget测试

### 1.2 核心业务逻辑梳理

**大六壬占卜核心流程**:

```
输入: DateTime + 问题(可选)
  ↓
1. 时间转换
  - 公历 → 农历(lunar包)
  - 计算四柱八字(年月日时干支)
  - 确定节气,推算月将
  ↓
2. 天地盘生成
  - 地盘: 十二地支固定布局
  - 天盘: 月将加时辰,顺时针旋转
  ↓
3. 贵人与神将定位
  - 根据日干+时辰判断昼贵人/夜贵人
  - 确定十二神将顺逆排列
  ↓
4. 四课计算
  - 第一课(日课): 日干寄宫
  - 第二课(日神课): 日课之上神
  - 第三课(支课): 日支
  - 第四课(支神课): 支课之上神
  - 判断: 伏吟/反吟/八专/别责
  ↓
5. 三传推导(九宗门法)
  - 伏吟门、反吟门、八专门
  - 贼克门(元首/蒿矢/重审)
  - 比用门、涉害门
  - 遥克门、别责门、昴星门
  ↓
输出: DaLiuRenKePan(完整盘面数据)
```

**当前实现位置**:
- ❌ **流程1-5** 的计算逻辑全部在 `DaLiuRenKePan` (Model)
- ✅ **数据模型** 定义合理: `FourClass`, `ThreeChuan`, `EachClass` 等
- ❌ **Repository** 只加载JSON资产,未实现真实计算

---

## 二、重构目标与原则

### 2.1 重构目标

1. **分层清晰**: 严格遵循MVVM + Clean Architecture
   - Model: 纯数据模型,无业务逻辑
   - Repository: 数据访问(JSON加载)
   - UseCase: 单一业务用例封装
   - Service/Calculator: 业务逻辑计算
   - ViewModel: UI状态管理
   - View: 纯UI展示

2. **保持功能不变**:
   - ✅ 所有占卜计算逻辑保持一致
   - ✅ UI交互和展示效果不变
   - ✅ 所有测试用例继续通过

3. **提升可维护性**:
   - 拆分超大类文件
   - 单一职责,便于单元测试
   - 清晰的依赖关系

4. **性能优化**:
   - 数据懒加载
   - 计算结果缓存
   - 减少不必要的UI重建

### 2.2 重构原则

- **渐进式重构**: 不做大爆炸式改动
- **向后兼容**: 保留旧版UI作为参照,标记为legacy
- **测试驱动**: 每次重构后运行测试确保功能正常
- **最小改动**: 只重构架构,不改UI和业务逻辑细节

---

## 三、详细重构计划

### Phase 1: 业务逻辑分离 (P0 - 最高优先级)

#### 任务1.1: 创建计算器(Calculator)层

**目标**: 将Model层的静态计算方法迁移到独立的Calculator类

**新建文件结构**:
```
lib/domain/services/calculators/
├── base_calculator.dart              # 计算器基类
├── lunar_calculator.dart              # 农历计算器
├── tian_di_pan_calculator.dart        # 天地盘计算器
├── gui_ren_calculator.dart            # 贵人计算器
├── four_class_calculator.dart         # 四课计算器
└── three_chuan_calculator.dart        # 三传计算器
    ├── fu_yin_strategy.dart           # 伏吟策略
    ├── fan_yin_strategy.dart          # 反吟策略
    ├── ba_zhuan_strategy.dart         # 八专策略
    ├── zei_ke_strategy.dart           # 贼克策略
    ├── bi_yong_strategy.dart          # 比用策略
    ├── she_hai_strategy.dart          # 涉害策略
    ├── yao_ke_strategy.dart           # 遥克策略
    ├── bie_ze_strategy.dart           # 别责策略
    └── mao_xing_strategy.dart         # 昴星策略
```

**具体步骤**:

1. **创建 `LunarCalculator`** (农历与八字计算)
   ```dart
   class LunarCalculator {
     // 计算四柱八字
     String calculateBaZi(DateTime dateTime);

     // 确定月将(根据节气)
     MonthGeneral calculateMonthGeneral(DateTime dateTime);

     // 判断阴阳遁
     YinYang determineYinYangDun(JiaZi dayJiaZi, DiZhi timeZhi);

     // 计算局数
     int calculateJuNumber(JiaZi dayJiaZi, DiZhi timeZhi, YinYang yinYangDun);
   }
   ```

2. **创建 `TianDiPanCalculator`** (天地盘计算)
   ```dart
   class TianDiPanCalculator {
     // 生成天地盘映射
     Map<DiZhi, DiZhi> generateTianDiPanMapper(
       DiZhi timeZhi,
       MonthGeneral monthGeneral
     );

     // 生成宫位映射
     Map<DiZhi, DaLiuRenGong> generateGongMapper(
       Map<DiZhi, DiZhi> tianDiPanMapper,
       DiZhi guiRenDiZhi,
       JiaZi dayJiaZi,
     );
   }
   ```

3. **创建 `GuiRenCalculator`** (贵人计算)
   ```dart
   class GuiRenCalculator {
     // 计算贵人位置
     Tuple2<bool, DiZhi> calculateGuiRenLocation(
       JiaZi dayJiaZi,
       JiaZi timeJiaZi
     );

     // 生成十二神将映射
     Map<DiZhi, GuiRen> calculateGodsMapper(
       DiZhi timeZhi,
       Map<DiZhi, DiZhi> tianDiPanMapper,
       DiZhi guiRenDiZhi
     );
   }
   ```

4. **创建 `FourClassCalculator`** (四课计算)
   ```dart
   class FourClassCalculator {
     FourClass calculate(
       JiaZi dayJiaZi,
       Map<DiZhi, DaLiuRenGong> gongMapper
     );
   }
   ```

5. **创建 `ThreeChuanCalculator`** (三传计算 - 核心复杂逻辑)
   ```dart
   // 策略模式 - 九宗门策略
   abstract class ThreeChuanStrategy {
     ThreeChuan? calculate(
       JiaZi dayJiaZi,
       FourClass fourClass,
       Map<DiZhi, DaLiuRenGong> gongMapper
     );
   }

   class ThreeChuanCalculator {
     final List<ThreeChuanStrategy> strategies = [
       FuYinStrategy(),      // 伏吟
       FanYinStrategy(),     // 反吟
       BaZhuanStrategy(),    // 八专
       ZeiKeStrategy(),      // 贼克
       BiYongStrategy(),     // 比用
       SheHaiStrategy(),     // 涉害
       YaoKeStrategy(),      // 遥克
       BieZeStrategy(),      // 别责
       MaoXingStrategy(),    // 昴星
     ];

     ThreeChuan calculate(
       JiaZi dayJiaZi,
       FourClass fourClass,
       Map<DiZhi, DaLiuRenGong> gongMapper
     ) {
       for (var strategy in strategies) {
         var result = strategy.calculate(dayJiaZi, fourClass, gongMapper);
         if (result != null) return result;
       }
       throw Exception("无法计算三传");
     }
   }
   ```

**预期成果**:
- ✅ `DaLiuRenKePan` 减少1500+行代码
- ✅ 每个Calculator职责单一,易于测试
- ✅ 使用策略模式,九宗门逻辑清晰

---

#### 任务1.2: 重构 `DaLiuRenKePan` Model

**目标**: Model只保留数据字段和构造函数,移除所有计算逻辑

**修改前**:
```dart
class DaLiuRenKePan extends DaLiuRenPanel {
  // 数据字段
  DateTime panDateTime;
  String? question;
  late final FourClass fourClass;
  late final ThreeChuan threeChuan;
  // ...

  // ❌ 大量静态计算方法 (1500+行)
  static ThreeChuan calculateThreeChuan(...) { }
  static ThreeChuan? checkByFuYin(...) { }
  static ThreeChuan? checkByFanYin(...) { }
  // ... 数十个方法
}
```

**修改后**:
```dart
class DaLiuRenKePan {
  // 只保留数据字段
  final DateTime panDateTime;
  final String? question;
  final String eightChatStr;
  final MonthGeneral monthGeneral;
  final JiaZi yearJiaZi;
  final JiaZi monthJiaZi;
  final JiaZi dayJiaZi;
  final JiaZi timeJiaZi;
  final DiZhi guiRenDiZhi;
  final bool isDayGuiRen;
  final Map<DiZhi, DiZhi> tianDiPanMapper;
  final Map<DiZhi, GuiRen> godsMapper;
  final Map<DiZhi, DaLiuRenGong> gongMapper;
  final FourClass fourClass;
  final ThreeChuan threeChuan;
  final YinYang yinYangDun;
  final int juNumber;

  // 构造函数 - 接收已计算好的数据
  DaLiuRenKePan({
    required this.panDateTime,
    required this.eightChatStr,
    required this.monthGeneral,
    required this.yearJiaZi,
    required this.monthJiaZi,
    required this.dayJiaZi,
    required this.timeJiaZi,
    required this.guiRenDiZhi,
    required this.isDayGuiRen,
    required this.tianDiPanMapper,
    required this.godsMapper,
    required this.gongMapper,
    required this.fourClass,
    required this.threeChuan,
    required this.yinYangDun,
    required this.juNumber,
    this.question,
  });

  // ✅ 可选: 添加JSON序列化支持
  factory DaLiuRenKePan.fromJson(Map<String, dynamic> json) =>
    _$DaLiuRenKePanFromJson(json);
  Map<String, dynamic> toJson() => _$DaLiuRenKePanToJson(this);
}
```

**预期成果**:
- ✅ Model职责清晰,只包含数据
- ✅ 符合MVVM设计原则
- ✅ 易于序列化和测试

---

#### 任务1.3: 创建 `DaLiuRenCalculationService`

**目标**: 创建一个编排服务,统一调度各个Calculator,实现完整的占卜计算流程

**新建文件**:
```dart
// lib/domain/services/da_liu_ren_calculation_service.dart

class DaLiuRenCalculationService {
  final LunarCalculator lunarCalculator;
  final TianDiPanCalculator tianDiPanCalculator;
  final GuiRenCalculator guiRenCalculator;
  final FourClassCalculator fourClassCalculator;
  final ThreeChuanCalculator threeChuanCalculator;

  DaLiuRenCalculationService({
    required this.lunarCalculator,
    required this.tianDiPanCalculator,
    required this.guiRenCalculator,
    required this.fourClassCalculator,
    required this.threeChuanCalculator,
  });

  /// 完整的占卜计算流程
  DaLiuRenKePan calculate(DateTime dateTime, {String? question}) {
    // 1. 计算农历与八字
    final baZiStr = lunarCalculator.calculateBaZi(dateTime);
    final baZiList = baZiStr.split(" ");
    final yearJiaZi = JiaZi.getFromGanZhiValue(baZiList[0])!;
    final monthJiaZi = JiaZi.getFromGanZhiValue(baZiList[1])!;
    final dayJiaZi = JiaZi.getFromGanZhiValue(baZiList[2])!;
    final timeJiaZi = JiaZi.getFromGanZhiValue(baZiList[3])!;

    // 2. 计算月将
    final monthGeneral = lunarCalculator.calculateMonthGeneral(dateTime);

    // 3. 生成天地盘
    final tianDiPanMapper = tianDiPanCalculator.generateTianDiPanMapper(
      timeJiaZi.diZhi,
      monthGeneral
    );

    // 4. 计算贵人
    final guiRenResult = guiRenCalculator.calculateGuiRenLocation(
      dayJiaZi,
      timeJiaZi
    );
    final isDayGuiRen = guiRenResult.item1;
    final guiRenDiZhi = guiRenResult.item2;

    // 5. 生成神将映射
    final godsMapper = guiRenCalculator.calculateGodsMapper(
      timeJiaZi.diZhi,
      tianDiPanMapper,
      guiRenDiZhi
    );

    // 6. 生成宫位映射
    final gongMapper = tianDiPanCalculator.generateGongMapper(
      tianDiPanMapper,
      guiRenDiZhi,
      dayJiaZi
    );

    // 7. 计算四课
    final fourClass = fourClassCalculator.calculate(dayJiaZi, gongMapper);

    // 8. 计算三传
    final threeChuan = threeChuanCalculator.calculate(
      dayJiaZi,
      fourClass,
      gongMapper
    );

    // 9. 计算阴阳遁和局数
    final yinYangDun = lunarCalculator.determineYinYangDun(
      dayJiaZi,
      timeJiaZi.diZhi
    );
    final juNumber = lunarCalculator.calculateJuNumber(
      dayJiaZi,
      timeJiaZi.diZhi,
      yinYangDun
    );

    // 10. 组装完整的盘面数据
    return DaLiuRenKePan(
      panDateTime: dateTime,
      question: question,
      eightChatStr: baZiStr,
      monthGeneral: monthGeneral,
      yearJiaZi: yearJiaZi,
      monthJiaZi: monthJiaZi,
      dayJiaZi: dayJiaZi,
      timeJiaZi: timeJiaZi,
      guiRenDiZhi: guiRenDiZhi,
      isDayGuiRen: isDayGuiRen,
      tianDiPanMapper: tianDiPanMapper,
      godsMapper: godsMapper,
      gongMapper: gongMapper,
      fourClass: fourClass,
      threeChuan: threeChuan,
      yinYangDun: yinYangDun,
      juNumber: juNumber,
    );
  }
}
```

**预期成果**:
- ✅ 计算流程清晰,步骤明确
- ✅ 易于单元测试每个步骤
- ✅ 便于扩展和优化

---

### Phase 2: Repository层完善 (P0)

#### 任务2.1: 完善 `DaLiuRenRepositoryImpl`

**目标**: 实现真实的占卜计算逻辑,替换占位符代码

**修改前**:
```dart
@override
Future<DaLiuRenKePan> calculateDivination(DateTime dateTime, {String? question}) async {
  await loadDivinationData();

  // ❌ 占位符代码
  final eightChatStr = "甲子 丙寅 戊辰 庚午";
  final monthGeneral = MonthGeneral.ZI_SHEN_HOU;

  final kePan = DaLiuRenKePan(
    panDateTime: dateTime,
    question: question,
    eightChatStr: eightChatStr,
    monthGeneral: monthGeneral,
  );

  return kePan;
}
```

**修改后**:
```dart
class DaLiuRenRepositoryImpl implements DaLiuRenRepository {
  final DaLiuRenCalculationService calculationService;

  DaLiuRenRepositoryImpl({required this.calculationService});

  @override
  Future<DaLiuRenKePan> calculateDivination(
    DateTime dateTime,
    {String? question}
  ) async {
    try {
      // 确保数据已加载
      await loadDivinationData();

      // ✅ 使用CalculationService进行真实计算
      final kePan = calculationService.calculate(dateTime, question: question);

      return kePan;
    } catch (e) {
      throw DivinationException(
        'Failed to calculate divination: $e',
        DivinationErrorCode.calculationError
      );
    }
  }

  // ... 其他数据加载方法保持不变
}
```

**预期成果**:
- ✅ Repository真正实现占卜计算
- ✅ 错误处理完善
- ✅ 依赖CalculationService,职责清晰

---

#### 任务2.2: 优化数据加载策略

**目标**: 实现懒加载,减少启动时间

**当前问题**:
```dart
// ❌ 一次性加载所有数据 (~7MB)
Future<void> loadDivinationData() async {
  await Future.wait([
    _loadYuDingData(),      // 1.3MB
    _loadJuMapperData(),
    _loadPanData(YinYang.YANG),  // 3MB
    _loadPanData(YinYang.YIN),   // 3MB
  ]);
}
```

**优化后**:
```dart
// ✅ 分阶段加载
Future<void> loadEssentialData() async {
  // 只加载必需数据
  await _loadJuMapperData();
}

Future<void> loadYuDingDataIfNeeded() async {
  if (_yuDingData == null) {
    await _loadYuDingData();
  }
}

Future<void> loadPanDataIfNeeded(YinYang yinYang) async {
  if (yinYang.isYang && _yangPanData == null) {
    await _loadPanData(YinYang.YANG);
  } else if (yinYang.isYin && _yinPanData == null) {
    await _loadPanData(YinYang.YIN);
  }
}
```

**预期成果**:
- ✅ 启动速度显著提升
- ✅ 按需加载,减少内存占用
- ✅ 用户体验改善

---

### Phase 3: UseCase层优化 (P1)

#### 任务3.1: 拆分 `CalculateDivinationUseCase`

**目标**: 将单一UseCase拆分为多个细粒度UseCase

**新建UseCase**:
```
lib/domain/usecases/
├── base_usecase.dart
├── load_divination_data_usecase.dart        # ✅ 已存在
├── calculate_divination_usecase.dart        # ✅ 已存在,需优化
├── calculate_ba_zi_usecase.dart             # 🆕 计算八字
├── calculate_four_class_usecase.dart        # 🆕 计算四课
├── calculate_three_chuan_usecase.dart       # 🆕 计算三传
└── get_ju_number_usecase.dart               # 🆕 获取局数
```

**示例**:
```dart
class CalculateBaZiUseCase extends UseCase<String, DateTimeParams> {
  final DaLiuRenRepository repository;

  CalculateBaZiUseCase(this.repository);

  @override
  Future<String> call(DateTimeParams params) async {
    final kePan = await repository.calculateDivination(params.dateTime);
    return kePan.eightChatStr;
  }
}
```

**预期成果**:
- ✅ UseCase职责单一
- ✅ 可复用性提高
- ✅ 易于测试

---

### Phase 4: ViewModel层优化 (P1)

#### 任务4.1: 细化 `DaLiuRenViewModel` 状态

**目标**: 更精细的状态管理,减少不必要的UI重建

**修改前**:
```dart
enum ViewState { idle, loading, success, error }
```

**修改后**:
```dart
enum DivinationViewState {
  initial,           // 初始状态
  loadingData,       // 加载数据中
  dataLoaded,        // 数据加载完成
  calculating,       // 计算中
  calculated,        // 计算完成
  error,             // 错误
}
```

**ViewModel优化**:
```dart
class DaLiuRenViewModel extends BaseViewModel {
  // 状态细化
  DivinationViewState _divinationState = DivinationViewState.initial;

  DivinationViewState get divinationState => _divinationState;

  bool get isCalculating => _divinationState == DivinationViewState.calculating;
  bool get isCalculated => _divinationState == DivinationViewState.calculated;

  // ... 其他优化
}
```

**预期成果**:
- ✅ 状态更精确
- ✅ UI响应更及时
- ✅ 便于添加加载动画

---

#### 任务4.2: 添加缓存机制

**目标**: 避免重复计算相同时间的占卜

```dart
class DaLiuRenViewModel extends BaseViewModel {
  // 缓存最近的计算结果
  final Map<String, DaLiuRenKePan> _cache = {};

  Future<void> _calculateDivination() async {
    final cacheKey = _selectedDateTime.toIso8601String();

    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      _currentDivination = _cache[cacheKey];
      _updateDivinationProperties();
      setSuccess();
      return;
    }

    // 计算并缓存
    setLoading();
    try {
      final params = DateTimeParams(_selectedDateTime, question: _question);
      final divination = await _calculateDivinationUseCase.call(params);

      _cache[cacheKey] = divination;
      _currentDivination = divination;
      _updateDivinationProperties();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }
}
```

**预期成果**:
- ✅ 重复查询秒级响应
- ✅ 减少计算开销
- ✅ 提升用户体验

---

### Phase 5: 旧版代码隔离 (P1)

#### 任务5.1: 隔离旧版UI

**目标**: 将 `pages/my_home_page.dart` 标记为legacy,避免混淆

**文件迁移**:
```
lib/pages/my_home_page.dart
  → lib/legacy/pages/my_home_page_legacy.dart
```

**路由更新**:
```dart
// lib/navigator.dart
static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
  return {
    // ✅ 新版MVVM路由 (默认)
    "/daliuren": (context) => const DaLiuRenView(),

    // ⚠️ 旧版路由 (兼容)
    "/daliuren/legacy": (context) => const MyHomePageLegacy(title: "大六壬(旧版)"),

    "/daliuren/dev": (context) => const DevPage(),
  };
}
```

**添加废弃标记**:
```dart
@Deprecated('Use DaLiuRenView instead. This legacy page will be removed in v2.0')
class MyHomePageLegacy extends StatefulWidget {
  // ...
}
```

**预期成果**:
- ✅ 新旧版本清晰区分
- ✅ 避免代码混淆
- ✅ 为未来移除做准备

---

### Phase 6: 依赖注入优化 (P2)

#### 任务6.1: 完善依赖注入配置

**目标**: 注册所有新增的Calculator和Service

**修改前**:
```dart
// lib/di/dependency_injection.dart
List<SingleChildWidget> getDaLiuRenProviders() {
  return [
    Provider<DaLiuRenRepository>(
      create: (_) => DaLiuRenRepositoryImpl(),
    ),
    // ...
  ];
}
```

**修改后**:
```dart
List<SingleChildWidget> getDaLiuRenProviders() {
  return [
    // Calculators
    Provider<LunarCalculator>(
      create: (_) => LunarCalculator(),
    ),
    Provider<TianDiPanCalculator>(
      create: (_) => TianDiPanCalculator(),
    ),
    Provider<GuiRenCalculator>(
      create: (_) => GuiRenCalculator(),
    ),
    Provider<FourClassCalculator>(
      create: (_) => FourClassCalculator(),
    ),
    Provider<ThreeChuanCalculator>(
      create: (_) => ThreeChuanCalculator(),
    ),

    // Calculation Service
    Provider<DaLiuRenCalculationService>(
      create: (context) => DaLiuRenCalculationService(
        lunarCalculator: context.read<LunarCalculator>(),
        tianDiPanCalculator: context.read<TianDiPanCalculator>(),
        guiRenCalculator: context.read<GuiRenCalculator>(),
        fourClassCalculator: context.read<FourClassCalculator>(),
        threeChuanCalculator: context.read<ThreeChuanCalculator>(),
      ),
    ),

    // Repository
    Provider<DaLiuRenRepository>(
      create: (context) => DaLiuRenRepositoryImpl(
        calculationService: context.read<DaLiuRenCalculationService>(),
      ),
    ),

    // UseCases
    Provider<LoadDivinationDataUseCase>(
      create: (context) => LoadDivinationDataUseCase(
        context.read<DaLiuRenRepository>(),
      ),
    ),
    Provider<CalculateDivinationUseCase>(
      create: (context) => CalculateDivinationUseCase(
        context.read<DaLiuRenRepository>(),
      ),
    ),

    // ViewModel
    ChangeNotifierProvider<DaLiuRenViewModel>(
      create: (context) => DaLiuRenViewModel(
        calculateDivinationUseCase: context.read<CalculateDivinationUseCase>(),
        loadDivinationDataUseCase: context.read<LoadDivinationDataUseCase>(),
      ),
    ),
  ];
}
```

**预期成果**:
- ✅ 依赖关系清晰
- ✅ 自动管理生命周期
- ✅ 便于测试和替换实现

---

### Phase 7: 测试完善 (P2)

#### 任务7.1: 添加单元测试

**新增测试文件**:
```
test/
├── calculators/
│   ├── lunar_calculator_test.dart
│   ├── four_class_calculator_test.dart
│   └── three_chuan_calculator_test.dart
├── services/
│   └── da_liu_ren_calculation_service_test.dart
├── repositories/
│   └── da_liu_ren_repository_impl_test.dart
├── usecases/
│   ├── calculate_divination_usecase_test.dart
│   └── load_divination_data_usecase_test.dart
└── viewmodels/
    └── da_liu_ren_viewmodel_test.dart
```

**示例测试**:
```dart
// test/calculators/four_class_calculator_test.dart
void main() {
  group('FourClassCalculator', () {
    late FourClassCalculator calculator;

    setUp(() {
      calculator = FourClassCalculator();
    });

    test('should calculate correct four classes for 甲子日', () {
      // Arrange
      final dayJiaZi = JiaZi.JIA_ZI;
      final gongMapper = _createMockGongMapper();

      // Act
      final result = calculator.calculate(dayJiaZi, gongMapper);

      // Assert
      expect(result.isFullClass, true);
      expect(result.first.sky, DiZhi.ZI);
      // ... 更多断言
    });
  });
}
```

**预期成果**:
- ✅ 测试覆盖率 >= 70%
- ✅ 关键业务逻辑有测试保障
- ✅ 回归测试防止破坏原有功能

---

### Phase 8: 文档完善 (P2)

#### 任务8.1: 添加代码文档注释

**目标**: 为关键类和方法添加DartDoc注释

**示例**:
```dart
/// 大六壬三传计算器
///
/// 根据九宗门法推导三传(初传、中传、末传)。
/// 九宗门依次为: 伏吟、反吟、八专、贼克、比用、涉害、遥克、别责、昴星
///
/// Example:
/// ```dart
/// final calculator = ThreeChuanCalculator();
/// final threeChuan = calculator.calculate(dayJiaZi, fourClass, gongMapper);
/// print(threeChuan.nineZongMenType); // 输出: NineZongMen.FU_YIN
/// ```
class ThreeChuanCalculator {
  /// 计算三传
  ///
  /// [dayJiaZi] 日柱干支
  /// [fourClass] 已计算的四课
  /// [gongMapper] 宫位映射
  ///
  /// Returns: 三传结果
  /// Throws: [Exception] 如果所有九宗门都无法匹配
  ThreeChuan calculate(
    JiaZi dayJiaZi,
    FourClass fourClass,
    Map<DiZhi, DaLiuRenGong> gongMapper,
  ) {
    // ...
  }
}
```

**预期成果**:
- ✅ 代码可读性提升
- ✅ IDE智能提示完善
- ✅ 新人上手更容易

---

## 四、实施计划与时间线

### 里程碑规划

| 阶段 | 任务 | 预计工作量 | 优先级 | 验收标准 |
|-----|------|----------|--------|---------|
| **Phase 1** | 业务逻辑分离 | 3-5天 | P0 | Calculator类创建完成,Model层精简 |
| **Phase 2** | Repository完善 | 2-3天 | P0 | Repository实现真实计算,测试通过 |
| **Phase 3** | UseCase优化 | 1-2天 | P1 | UseCase拆分完成,职责清晰 |
| **Phase 4** | ViewModel优化 | 1-2天 | P1 | 状态细化,缓存机制实现 |
| **Phase 5** | 旧代码隔离 | 0.5-1天 | P1 | 旧版UI迁移到legacy目录 |
| **Phase 6** | 依赖注入优化 | 0.5天 | P2 | DI配置完善,所有依赖正确注入 |
| **Phase 7** | 测试完善 | 2-3天 | P2 | 测试覆盖率 >= 70% |
| **Phase 8** | 文档完善 | 1-2天 | P2 | 关键类和方法有完整注释 |

**总预计工作量**: 11-18天

---

### 实施顺序

#### Week 1: 核心重构 (P0任务)
- **Day 1-2**: 创建Calculator基础类和策略接口
- **Day 3-4**: 实现四课、三传计算器,迁移业务逻辑
- **Day 5**: 重构DaLiuRenKePan Model,创建CalculationService
- **Day 6-7**: 完善Repository实现,集成CalculationService

**验收标准**:
- ✅ `flutter test` 所有现有测试通过
- ✅ `flutter analyze` 无Critical错误
- ✅ 新版UI (`/daliuren`) 功能正常

#### Week 2: 优化与完善 (P1任务)
- **Day 8-9**: UseCase拆分,ViewModel状态优化
- **Day 10**: 数据懒加载优化,缓存机制
- **Day 11**: 旧版代码隔离,路由调整

**验收标准**:
- ✅ 启动时间 < 3秒
- ✅ 占卜计算 < 500ms
- ✅ 旧版UI可通过 `/daliuren/legacy` 访问

#### Week 3: 测试与文档 (P2任务)
- **Day 12-14**: 单元测试编写
- **Day 15-16**: 代码文档注释
- **Day 17**: 依赖注入优化
- **Day 18**: 最终验收和优化

**验收标准**:
- ✅ 测试覆盖率 >= 70%
- ✅ 关键类有完整DartDoc
- ✅ 性能满足PRD要求

---

## 五、风险与应对

### 风险1: 业务逻辑迁移错误

**风险描述**: 从Model迁移计算逻辑到Calculator时,可能引入bug

**应对措施**:
- ✅ 保留原有测试用例,确保输出一致
- ✅ 逐个方法迁移,每次迁移后运行测试
- ✅ 对比新旧实现的计算结果

### 风险2: 性能下降

**风险描述**: 增加抽象层可能导致性能下降

**应对措施**:
- ✅ 进行性能基准测试
- ✅ 使用缓存减少重复计算
- ✅ 优化数据加载策略

### 风险3: 依赖注入复杂度增加

**风险描述**: Calculator和Service增多,DI配置复杂

**应对措施**:
- ✅ 考虑使用 `get_it` 替代Provider (可选)
- ✅ 清晰的依赖图文档
- ✅ 单元测试使用Mock,不依赖真实DI

---

## 六、重构后的架构图

### 最终架构层次
```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│  ┌───────────────┐      ┌────────────────┐ │
│  │  ViewModel    │◀─────│  View/Widget   │ │
│  │ (状态管理)     │      │  (UI展示)       │ │
│  └───────┬───────┘      └────────────────┘ │
└──────────┼──────────────────────────────────┘
           │ 调用
           ▼
┌─────────────────────────────────────────────┐
│              Domain Layer                   │
│  ┌───────────────┐                          │
│  │   UseCase     │  (业务用例)               │
│  └───────┬───────┘                          │
│          │                                   │
│  ┌───────▼───────┐      ┌────────────────┐ │
│  │  Repository   │      │  Calculator    │ │
│  │  (接口)        │      │  Service       │ │
│  └───────────────┘      │  (业务逻辑)     │ │
│                         └────────────────┘ │
└─────────────────────────────────────────────┘
           │ 实现
           ▼
┌─────────────────────────────────────────────┐
│              Data Layer                     │
│  ┌───────────────┐                          │
│  │  Repository   │                          │
│  │  Impl         │─────┐                    │
│  └───────────────┘     │                    │
│                        ▼                    │
│              ┌────────────────┐             │
│              │  Data Source   │             │
│              │  (JSON Assets) │             │
│              └────────────────┘             │
└─────────────────────────────────────────────┘
           ▲
           │ 使用
           │
┌──────────┴──────────────────────────────────┐
│              Model Layer                    │
│  ┌───────────────┐      ┌────────────────┐ │
│  │  DaLiuRenKePan│      │  FourClass     │ │
│  │  (纯数据)      │      │  ThreeChuan    │ │
│  └───────────────┘      │  (纯数据)       │ │
│                         └────────────────┘ │
└─────────────────────────────────────────────┘
```

### 数据流向
```
用户操作 (选择时间)
  ↓
View (DaLiuRenView)
  ↓
ViewModel.updateDateTime()
  ↓
UseCase.call()
  ↓
Repository.calculateDivination()
  ↓
CalculationService.calculate()
  ↓
Calculator (LunarCalculator, FourClassCalculator, ThreeChuanCalculator...)
  ↓
返回 DaLiuRenKePan (纯数据模型)
  ↓
ViewModel 更新状态
  ↓
View 重建UI,展示结果
```

---

## 七、预期成果

### 架构改进

| 指标 | 重构前 | 重构后 | 改进 |
|-----|--------|--------|------|
| Model层代码行数 | 1827行 | <300行 | ↓ 84% |
| 单个类最大行数 | 1827行 | <500行 | ↓ 73% |
| 业务逻辑位置 | Model层 | Service/Calculator层 | ✅ 分离 |
| 依赖方向 | 混乱 | 单向依赖 | ✅ 清晰 |
| 可测试性 | 困难 | 容易 | ✅ 提升 |

### 性能改进

| 指标 | 重构前 | 重构后 | 改进 |
|-----|--------|--------|------|
| 启动时间 | >5秒 | <3秒 | ↓ 40% |
| 数据加载 | 全量7MB | 懒加载<1MB | ↓ 85% |
| 重复计算 | 每次重新计算 | 缓存命中 | ↓ 99% |

### 代码质量

| 指标 | 重构前 | 重构后 |
|-----|--------|--------|
| 测试覆盖率 | 30% | >=70% |
| 文档注释覆盖率 | <20% | >=80% |
| `flutter analyze` | 多个warning | 0 error |
| 单一职责原则 | ❌ | ✅ |
| 依赖倒置原则 | ❌ | ✅ |

---

## 八、总结

本重构计划遵循 **MVVM + UseCase + Repository** 架构模式,旨在:

1. **保持功能不变**: 所有占卜计算逻辑和UI交互保持一致
2. **分离关注点**: Model只负责数据,Calculator负责业务逻辑,Repository负责数据访问
3. **提升可维护性**: 拆分超大类,单一职责,便于测试和扩展
4. **优化性能**: 懒加载、缓存机制,提升用户体验
5. **渐进式重构**: 分阶段实施,降低风险

**关键原则**:
- ✅ 业务逻辑从Model迁移到Calculator/Service
- ✅ Repository实现真实计算逻辑
- ✅ ViewModel专注于状态管理
- ✅ View只负责UI展示
- ✅ 依赖注入管理对象生命周期

通过本次重构,大六壬模块将具备 **清晰的架构、优秀的可维护性、完善的测试覆盖**,为后续功能扩展和性能优化奠定坚实基础。
