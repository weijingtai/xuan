# 八卦加则算法开发任务清单

## 📋 项目概述

**算法名称**: 八卦加则取数法
**开发周期**: 预计3-5天
**优先级**: 高
**负责人**: 待分配

## 🎯 核心目标

实现八卦加则算法，支持两种装卦方法（爻序法和纳甲法），为四柱分别计算，产生8个条文编号，并展示详细的计算过程。

## 📊 算法概览

### 输入
- 八字四柱（EightChars对象）

### 输出
- 8个基础数（4柱 × 2方法）
- 每个基础数直接作为条文编号（不扩展）
- 详细的计算过程数据

### 两种方法
1. **爻序法**: 阳爻依次配子寅辰午申戌，阴爻依次配丑卯巳未酉亥
2. **纳甲法**: 使用传统六爻纳甲规则（不区分年干阴阳）

---

## ✅ 任务分解

### 阶段一：数据模型设计 (0.5天)

#### Task 1.1: 创建 BaGuaJiaZeBaseNumberModel ✅
**文件**: `lib/domain/models/ba_gua_jia_ze_base_number_model.dart`

**要求**:
- [x] 继承自 BaseNumberModel
- [ ] 添加字段：
  ```dart
  /// 算法方法："爻序法" / "纳甲法"
  final String method;

  /// 来源柱："年柱" / "月柱" / "日柱" / "时柱"
  final String pillarName;

  /// 干支
  final JiaZi ganZhi;

  /// 六爻卦象（保存中间结果）
  final PureSixYaoGua guaData;

  /// 上卦
  final Enum8Gua upperGua;

  /// 下卦
  final Enum8Gua lowerGua;

  /// 上卦数（后天）
  final int upperGuaNumber;

  /// 下卦数（后天）
  final int lowerGuaNumber;

  /// 六爻地支总和
  final int yaoSum;

  /// 计算公式
  final String formula;
  ```

- [ ] 实现构造函数和工厂方法
- [ ] 实现 `toMap()` 方法用于调试
- [ ] 实现 `toString()` 方法
- [ ] 添加详细的文档注释

**验收标准**:
- 所有字段定义清晰
- 继承关系正确
- 文档注释完整

---

### 阶段二：Strategy实现 (1.5天)

#### Task 2.1: 创建 BaGuaJiaZeStrategy ✅
**文件**: `lib/service/strategy/ba_gua_jia_ze_strategy.dart`

**要求**:
- [x] 继承 StandardCalculationStrategy
- [x] 实现核心计算方法 `calculate()`
- [x] 实现爻序法 `_calculateByYaoSequence()`
- [x] 实现纳甲法 `_calculateByNaJia()`
- [ ] 实现干支配卦逻辑
- [ ] 实现六爻装配逻辑
- [ ] 实现地支数字求和
- [ ] 实现基础数计算公式

**详细实现要点**:

##### calculate() 主方法
```dart
@override
BaseNumberModelResult calculate(BaGuaJiaZeStrategyParams params) {
  try {
    final results = <BaGuaJiaZeBaseNumberModel>[];

    // 四柱循环
    final pillars = [
      (params.eightChars.year, '年柱'),
      (params.eightChars.month, '月柱'),
      (params.eightChars.day, '日柱'),
      (params.eightChars.time, '时柱'),
    ];

    for (final (pillar, pillarName) in pillars) {
      // 干支配卦
      final upperGua = Constants.tianGanGuaMapper[pillar.gan]!;
      final lowerGua = Constants.diZhiGuaMapper[pillar.zhi]!;

      // 生成六爻卦（创建副本用于爻序法）
      final guaForYaoSeq = PureSixYaoGua.by8Gua(upperGua, lowerGua);
      final guaForNaJia = PureSixYaoGua.by8Gua(upperGua, lowerGua);

      // 方案A: 爻序法
      final resultA = _calculateByYaoSequence(
        pillar,
        pillarName,
        guaForYaoSeq,
        upperGua,
        lowerGua
      );
      results.add(resultA);

      // 方案B: 纳甲法
      final resultB = _calculateByNaJia(
        pillar,
        pillarName,
        guaForNaJia,
        upperGua,
        lowerGua
      );
      results.add(resultB);
    }

    return BaseNumberModelResult.success(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      baseNumbers: results,
      sourceData: {...},
    );
  } catch (e) {
    return BaseNumberModelResult.error(...);
  }
}
```

##### _calculateByYaoSequence() 爻序法
```dart
BaGuaJiaZeBaseNumberModel _calculateByYaoSequence(
  JiaZi pillar,
  String pillarName,
  PureSixYaoGua gua,
  Enum8Gua upperGua,
  Enum8Gua lowerGua,
) {
  final yangDiZhi = [
    DiZhi.ZI, DiZhi.YIN, DiZhi.CHEN,
    DiZhi.WU, DiZhi.SHEN, DiZhi.XU
  ];
  final yinDiZhi = [
    DiZhi.CHOU, DiZhi.MAO, DiZhi.SI,
    DiZhi.WEI, DiZhi.YOU, DiZhi.HAI
  ];

  int yangIndex = 0;
  int yinIndex = 0;
  int sum = 0;

  // 从下到上装配地支（索引0是初爻，索引5是上爻）
  for (int i = 0; i < 6; i++) {
    final yao = gua.yaoList[i];
    DiZhi diZhi;

    if (yao.yinYang == YinYang.YANG) {
      if (yangIndex < yangDiZhi.length) {
        diZhi = yangDiZhi[yangIndex++];
      } else {
        break; // 超出范围则停止
      }
    } else {
      if (yinIndex < yinDiZhi.length) {
        diZhi = yinDiZhi[yinIndex++];
      } else {
        break; // 超出范围则停止
      }
    }

    // 将地支配到爻上
    yao.naZhi = diZhi;
    // 累加数字
    sum += Constants.yaoDiZhiNumberMapper[diZhi]!;
  }

  // 计算基础数
  final upperNum = Constants.houGuaNumberMapper[upperGua]!;
  final lowerNum = Constants.houGuaNumberMapper[lowerGua]!;
  final baseNumber = upperNum * 1000 + sum - lowerNum;

  // 生成计算公式
  final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

  return BaGuaJiaZeBaseNumberModel(
    baseNumber: baseNumber,
    name: '$pillarName-爻序法',
    description: '$pillarName${pillar.name}爻序法计算：上卦${upperGua.name}，下卦${lowerGua.name}，总和$sum',
    source: _getSourceFromPillarName(pillarName),
    method: '爻序法',
    pillarName: pillarName,
    ganZhi: pillar,
    guaData: gua,
    upperGua: upperGua,
    lowerGua: lowerGua,
    upperGuaNumber: upperNum,
    lowerGuaNumber: lowerNum,
    yaoSum: sum,
    formula: formula,
  );
}
```

##### _calculateByNaJia() 纳甲法
```dart
BaGuaJiaZeBaseNumberModel _calculateByNaJia(
  JiaZi pillar,
  String pillarName,
  PureSixYaoGua gua,
  Enum8Gua upperGua,
  Enum8Gua lowerGua,
) {
  int sum = 0;

  // 下卦纳支（不区分年干阴阳）
  for (var i = 0; i < 3; i++) {
    final diZhi = Constants.innerGuaYaoDiZhi[lowerGua]![i];
    gua.yaoList[i].naZhi = diZhi;
    sum += Constants.yaoDiZhiNumberMapper[diZhi]!;
  }

  // 上卦纳支
  for (var i = 3; i < 6; i++) {
    final diZhi = Constants.outerGuaYaoDiZhi[upperGua]![i - 3];
    gua.yaoList[i].naZhi = diZhi;
    sum += Constants.yaoDiZhiNumberMapper[diZhi]!;
  }

  // 计算基础数
  final upperNum = Constants.houGuaNumberMapper[upperGua]!;
  final lowerNum = Constants.houGuaNumberMapper[lowerGua]!;
  final baseNumber = upperNum * 1000 + sum - lowerNum;

  // 生成计算公式
  final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

  return BaGuaJiaZeBaseNumberModel(
    baseNumber: baseNumber,
    name: '$pillarName-纳甲法',
    description: '$pillarName${pillar.name}纳甲法计算：上卦${upperGua.name}，下卦${lowerGua.name}，总和$sum',
    source: _getSourceFromPillarName(pillarName),
    method: '纳甲法',
    pillarName: pillarName,
    ganZhi: pillar,
    guaData: gua,
    upperGua: upperGua,
    lowerGua: lowerGua,
    upperGuaNumber: upperNum,
    lowerGuaNumber: lowerNum,
    yaoSum: sum,
    formula: formula,
  );
}
```

**验收标准**:
- [ ] 四柱都能正确计算
- [ ] 爻序法装配逻辑正确
- [ ] 纳甲法装配逻辑正确
- [ ] 基础数计算公式正确
- [ ] 返回8个BaseNumberModel
- [ ] 详细的sourceData包含所有中间结果

---

#### Task 2.2: 创建 BaGuaJiaZeStrategyParams
**要求**:
- [ ] 定义参数类
- [ ] 包含 EightChars 字段
- [ ] 实现 toString() 方法
- [ ] 实现 == 和 hashCode

---

### 阶段三：UseCase实现 (1天)

#### Task 3.1: 创建 BaGuaJiaZeTiaoWenListUseCase ✅
**文件**: `lib/usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart`

**要求**:
- [x] 继承 BaseGetTiaoWenListUseCase
- [x] 实现 `execute()` 方法
- [x] 调用 Strategy 计算基础数
- [x] **不扩展条文列表**（直接使用基础数）
- [ ] 查询条文数据（8个条文编号）
- [ ] 构建 BaseNumberTiaoWenListModel
- [ ] 返回 MultiBaseNumberResult

**核心逻辑**:
```dart
@override
Future<MultiBaseNumberResult> execute(
  BaGuaJiaZeUseCaseParams params, {
  TiaoWenListCalculationConfig? calculationConfig,
}) async {
  try {
    // 1. 验证参数
    validateParams(params);

    // 2. 调用Strategy计算基础数
    final strategyParams = BaGuaJiaZeStrategyParams(
      eightChars: params.eightChars,
    );
    final strategyResult = _strategy.calculate(strategyParams);

    if (strategyResult.hasError) {
      throw Exception("八卦加则计算失败: ${strategyResult.errorMessage}");
    }

    // 3. 不扩展条文列表，直接使用基础数作为条文编号
    final baseNumberTiaoWenList = <BaseNumberTiaoWenListModel>[];

    for (final baseModel in strategyResult.baseNumbers) {
      final tiaoWenNumber = baseModel.baseNumber;

      // 查询单个条文
      final tiaoWenData = await _repository.getById(tiaoWenNumber);

      // 创建BaseNumberTiaoWenListModel（条文列表只包含自己）
      baseNumberTiaoWenList.add(
        BaseNumberTiaoWenListModel(
          baseNumber: baseModel.baseNumber,
          tiaoWenDataList: tiaoWenData != null ? [tiaoWenData] : [],
          name: baseModel.name,
          description: baseModel.description,
          source: baseModel.source,
          tiaoWenNumbers: [tiaoWenNumber],
        ),
      );
    }

    // 4. 提取所有条文实体
    final allTiaoWenEntities = baseNumberTiaoWenList
        .expand((model) => model.tiaoWenDataList)
        .toList();

    // 5. 返回结果
    return MultiBaseNumberResult.success(
      algorithmName: '八卦加则',
      algorithmDescription: '八卦装配地支加则取数法',
      calculationParams: params.eightChars.toString(),
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      tiaoWenEntities: allTiaoWenEntities,
      sourceData: {
        'eightChars': params.eightChars.toString(),
        'methodCount': 2,
        'pillarCount': 4,
        'totalResults': 8,
      },
    );
  } catch (e) {
    return MultiBaseNumberResult.error(
      algorithmName: '八卦加则',
      algorithmDescription: '八卦装配地支加则取数法',
      calculationParams: params.eightChars.toString(),
      errorMessage: e.toString(),
      sourceData: {'error': e.toString()},
    );
  }
}
```

**验收标准**:
- [ ] 参数验证正确
- [ ] Strategy调用成功
- [ ] 8个条文查询成功
- [ ] 返回结果结构正确
- [ ] 错误处理完善

---

### 阶段四：ViewModel实现 (0.5天)

#### Task 4.1: 创建 BaGuaJiaZeViewModel ✅
**文件**: `lib/presentation/viewmodels/ba_gua_jia_ze_view_model.dart`

**要求**:
- [x] 继承 BaseTiaoWenListViewModel
- [x] 实现 `setEightChars()` 方法
- [x] 实现 `calculateTiaoWenList()` 方法
- [x] 实现 `refresh()` 方法
- [x] 添加便捷的 getter 方法

**便捷方法**:
```dart
/// 获取按柱分组的结果
Map<String, List<BaGuaJiaZeUIModel>> get groupedResults {
  if (!hasResult) return {};

  final grouped = <String, List<BaGuaJiaZeUIModel>>{};

  for (final item in result!.baseNumberTiaoWenList) {
    // 从name中提取柱名（如"年柱-爻序法" -> "年柱"）
    final pillarName = item.name.split('-')[0];

    if (!grouped.containsKey(pillarName)) {
      grouped[pillarName] = [];
    }

    grouped[pillarName]!.add(
      BaGuaJiaZeUIModel.fromDomain(item)
    );
  }

  return grouped;
}

/// 获取所有结果列表
List<BaGuaJiaZeUIModel> get allResults {
  if (!hasResult) return [];

  return result!.baseNumberTiaoWenList
      .map((item) => BaGuaJiaZeUIModel.fromDomain(item))
      .toList();
}
```

**验收标准**:
- [x] ViewModel正确管理状态
- [x] 计算方法调用UseCase
- [x] 数据转换正确
- [x] 错误处理完善

---

### 阶段五：UI实现 (1天)

#### Task 5.1: 创建 BaGuaJiaZeUIModel ✅
**文件**: `lib/presentation/models/ba_gua_jia_ze_ui_model.dart`

**要求**:
- [x] 定义UI展示所需的数据结构
- [x] 包含计算过程的所有信息
- [x] 实现 `fromDomain()` 工厂方法
- [x] 实现 `fromBaGuaJiaZeModel()` 工厂方法
- [x] 包含六爻详情数据

**数据结构**:
```dart
class BaGuaJiaZeUIModel {
  final String pillarName;        // "年柱"
  final String ganZhi;            // "甲子"
  final String method;            // "爻序法" / "纳甲法"
  final int tiaoWenNumber;        // 条文编号
  final String? tiaoWenContent;   // 条文内容

  // 计算过程
  final String upperGua;          // "乾卦"
  final String lowerGua;          // "坤卦"
  final int upperGuaNumber;       // 6
  final int lowerGuaNumber;       // 2
  final List<YaoUIModel> yaoList; // 六爻详情
  final int yaoSum;               // 总和
  final String formula;           // "6000 + 270 - 2 = 6268"

  // 卦象信息
  final PureSixYaoGua? guaData;   // 完整卦象数据
}

class YaoUIModel {
  final int position;             // 爻位（0-5）
  final String positionLabel;     // "初" / "二" / "三" / "四" / "五" / "上"
  final String yinYang;           // "阳" / "阴"
  final String diZhi;             // "子"
  final int number;               // 30
}
```

---

#### Task 5.2: 创建 BaGuaJiaZeCard Widget ✅
**文件**: `lib/presentation/widgets/ba_gua_jia_ze_card.dart`

**要求**:
- [x] 展示单个结果的卡片
- [x] 显示柱名和方法
- [x] 显示条文编号
- [x] 可展开显示详细计算过程
- [x] 六爻信息可视化展示
- [x] 创建BaGuaJiaZeResultsList组件支持分组显示

**UI结构**:
```dart
Card(
  child: ExpansionTile(
    title: Text('${model.pillarName} - ${model.method}'),
    subtitle: Text('条文: ${model.tiaoWenNumber}'),
    children: [
      // 卦象信息
      _buildGuaInfo(),

      // 六爻详情
      _buildYaoDetails(),

      // 计算公式
      _buildFormula(),

      // 条文内容
      _buildTiaoWenContent(),
    ],
  ),
)
```

---

#### Task 5.3: 更新 StrategyDemoPage ✅
**文件**: `lib/presentation/pages/strategy_demo_page.dart`

**要求**:
- [x] 添加 BaGuaJiaZeViewModel 到 Provider ✅
- [x] 添加八卦加则页面到 PageView
- [x] 更新底部导航栏（添加第5个tab）
- [x] 实现页面初始化逻辑
- [x] 实现刷新逻辑
- [x] 创建 _buildBaGuaJiaZeContent 方法

**Provider注入**: 已在 `lib/infrastructure/di/strategy_providers.dart` 中添加：
- Provider<BaGuaJiaZeStrategy>
- Provider<BaGuaJiaZeTiaoWenListUseCase>
- ChangeNotifierProvider<BaGuaJiaZeViewModel>

**关键修改**:
```dart
// 添加到PageView
_buildStrategyPage(
  child: Consumer<BaGuaJiaZeViewModel>(
    builder: (context, viewModel, child) {
      return BaGuaJiaZeResultsWidget(
        viewModel: viewModel,
      );
    },
  ),
),

// 底部导航添加
BottomNavigationBarItem(
  icon: Icon(Icons.auto_graph),
  label: '八卦加则',
),
```

---

### 阶段六：测试与优化 (0.5天)

#### Task 6.1: 单元测试
- [ ] Strategy算法测试
- [ ] UseCase流程测试
- [ ] ViewModel状态测试

#### Task 6.2: 集成测试
- [ ] 完整流程测试
- [ ] 错误处理测试
- [ ] 边界条件测试

#### Task 6.3: UI测试
- [ ] Widget渲染测试
- [ ] 交互测试
- [ ] 性能测试

---

## 📝 开发检查清单

### 代码质量
- [ ] 所有方法都有文档注释
- [ ] 代码符合Dart风格规范
- [ ] 没有硬编码的Magic Number
- [ ] 异常处理完善
- [ ] 日志输出合理

### 功能完整性
- [ ] 爻序法计算正确
- [ ] 纳甲法计算正确
- [ ] 四柱都能正确处理
- [ ] 边界情况处理（如爻数不足）
- [ ] 条文查询正常

### UI/UX
- [ ] 界面美观统一
- [ ] 交互流畅
- [ ] 错误提示友好
- [ ] 加载状态清晰
- [ ] 计算过程展示详细

### 文档
- [ ] 更新PRD文档 ✅
- [ ] 更新API文档
- [ ] 添加使用示例
- [ ] 更新CHANGELOG

---

## 🐛 已知问题与风险

### 潜在问题
1. **爻序法边界问题**:
   - 风险：某些卦象阳爻或阴爻数量可能不足6个
   - 解决：已在代码中添加索引检查，不足则停止

2. **PureSixYaoGua修改**:
   - 风险：装配地支会修改gua对象
   - 解决：为每个计算创建独立的PureSixYaoGua实例

3. **性能考虑**:
   - 风险：8次条文查询可能较慢
   - 优化：考虑批量查询或缓存

### 待讨论事项
- [ ] 是否需要天干纳甲（当前只配地支）
- [ ] 是否需要支持自定义配置
- [ ] UI展示是否需要更多可视化元素

---

## 📅 里程碑

### M1: 数据模型完成 (Day 0.5)
- ✅ BaGuaJiaZeBaseNumberModel 创建完成

### M2: Strategy实现完成 (Day 2)
- ✅ BaGuaJiaZeStrategy 实现完成
- ✅ 两种装卦方法验证通过

### M3: UseCase实现完成 (Day 3)
- ✅ BaGuaJiaZeTiaoWenListUseCase 实现完成
- ✅ 条文查询集成完成

### M4: ViewModel实现完成 (Day 3.5)
- ✅ BaGuaJiaZeViewModel 实现完成
- ✅ 状态管理正常

### M5: UI实现完成 (Day 4.5)
- ✅ 所有Widget创建完成
- ✅ StrategyDemoPage集成完成
- ✅ 页面展示正常

### M6: 测试与发布 (Day 5)
- [ ] 所有测试通过
- [ ] 代码Review完成
- [ ] 文档更新完成
- [ ] 正式发布

**当前状态**: 核心功能实现完成，待测试和优化

---

## 🔗 相关资源

### 代码参考
- 太玄四柱Strategy: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`
- PureSixYaoGua: `lib/domain/pure_six_yao_gua.dart`
- Constants: `lib/constant/constants.dart`

### 文档
- PRD: `docs/normal_alg/PRD.md`
- Code Review: `docs/normal_alg/code_review.md`

### 工具
- yaoDiZhiNumberMapper: 地支数字映射
- houGuaNumberMapper: 后天卦数映射
- tianGanGuaMapper: 天干配卦映射
- diZhiGuaMapper: 地支配卦映射

---

## 📧 联系方式

**技术问题**: 请提Issue或联系项目维护者
**需求变更**: 请更新PRD并通知团队
**进度更新**: 每日更新此TODO清单的完成状态

---

**最后更新**: 2025-10-10
**文档版本**: v1.0
