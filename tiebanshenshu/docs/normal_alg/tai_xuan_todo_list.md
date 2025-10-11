# 太玄取数法双纳甲方案开发任务清单

## 📋 项目概述

**算法名称**: 太玄取数法（双纳甲方案）
**开发周期**: 预计16-23小时
**优先级**: 高
**负责人**: 待分配
**最后更新**: 2025-10-10

## 🎯 核心目标

实现太玄取数法的双纳甲方案，支持"年干阴阳纳甲"和"传统内外卦纳甲"两种方法，为四柱分别计算，产生8个基础数（4柱 × 2方法），并同时展示两种方法的结果。

## 📊 算法概览

### 输入
- 八字四柱（EightChars对象）

### 输出
- 8个基础数（4柱 × 2纳甲方案）
- 每个基础数扩展为条文列表（基础数 ± 96）
- 详细的计算过程数据（包含六爻详情）

### 两种纳甲方案
1. **年干阴阳纳甲**: 根据年干阴阳决定纳甲天干配置（已实现）
   - 阳年：使用 yangGuaYaoTianGan
   - 阴年：使用 yinGuaYaoTianGan
2. **传统内外卦纳甲**: 根据当前卦的阴阳决定纳甲天干配置（待实现）
   - 阳卦（乾震坎艮）：使用 outerGuaYaoTianGan
   - 阴卦（坤巽离兑）：使用 innerGuaYaoTianGan

### 关键区别
- **天干配置**: 两种方案不同
- **地支配置**: 两种方案相同（都使用 innerGuaYaoDiZhi 和 outerGuaYaoDiZhi）

---

## ✅ 任务分解

### Phase 1: 数据模型重构 (预计2-3小时)

#### Task 1.1: 创建 TaiXuanYaoDetail 模型
**文件**: `lib/domain/models/tai_xuan_base_number_model.dart`

**要求**:
- [ ] 定义 TaiXuanYaoDetail 类
- [ ] 添加字段：
  ```dart
  final int position;           // 0-5 (初爻到上爻)
  final String positionLabel;   // '初', '二', '三', '四', '五', '上'
  final TianGan tianGan;        // 纳甲天干
  final DiZhi diZhi;            // 纳甲地支
  final int taiXuanGanNumber;   // 天干太玄数
  final int taiXuanZhiNumber;   // 地支太玄数
  final int taiXuanNumber;      // 该爻总太玄数（天干+地支）
  final String yinYang;         // '阴' or '阳'
  final bool isFiltered;        // 是否被过滤（和为10）
  ```
- [ ] 实现构造函数
- [ ] 实现 `toMap()` 方法
- [ ] 实现 `toString()` 方法
- [ ] 添加文档注释

**验收标准**:
- 所有字段定义清晰
- 文档注释完整
- 包含所有中间计算结果

---

#### Task 1.2: 创建 TaiXuanNaJiaMethod 枚举
**文件**: `lib/domain/models/tai_xuan_base_number_model.dart`

**要求**:
- [ ] 定义枚举类型：
  ```dart
  enum TaiXuanNaJiaMethod {
    yearGanYinYang,    // 年干阴阳纳甲
    innerOuterGua,     // 传统内外卦纳甲
  }
  ```
- [ ] 添加扩展方法 `displayName` 返回中文名称
- [ ] 添加文档注释

**验收标准**:
- 枚举定义正确
- 扩展方法可用
- 文档注释清晰

---

#### Task 1.3: 创建 TaiXuanBaseNumberModel
**文件**: `lib/domain/models/tai_xuan_base_number_model.dart`

**要求**:
- [ ] 继承 BaseNumberModel
- [ ] 添加字段：
  ```dart
  final String pillarName;      // '年柱', '月柱', '日柱', '时柱'
  final JiaZi ganzhi;           // 原始干支
  final Enum8Gua upperGua;      // 上卦
  final Enum8Gua lowerGua;      // 下卦
  final int upperGuaNumber;     // 上卦后天数
  final int lowerGuaNumber;     // 下卦后天数
  final TaiXuanNaJiaMethod naJiaMethod; // 纳甲方法
  final int upperGuaSum;        // 上卦三爻太玄数总和
  final int lowerGuaSum;        // 下卦三爻太玄数总和
  final List<TaiXuanYaoDetail> yaoDetails; // 六爻详情
  final String formula;         // 计算公式字符串
  ```
- [ ] 实现构造函数和工厂方法
- [ ] 实现 `toMap()` 方法
- [ ] 实现 `toString()` 方法
- [ ] 重写 `name` getter（格式："{柱名}-{纳甲方案名}"）
- [ ] 重写 `description` getter
- [ ] 添加详细的文档注释

**验收标准**:
- 所有字段定义清晰
- 继承关系正确
- 文档注释完整
- 包含完整的计算过程数据

---

### Phase 2: Strategy层实现 (预计3-4小时)

#### Task 2.1: 添加 TaiXuanNaJiaMethod 参数到 TaiXuanFourZhuStrategyParams
**文件**: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`

**要求**:
- [ ] 添加 `naJiaMethod` 字段：
  ```dart
  final TaiXuanNaJiaMethod naJiaMethod;
  ```
- [ ] 修改构造函数，添加默认值：
  ```dart
  TaiXuanFourZhuStrategyParams({
    required this.eightChars,
    this.naJiaMethod = TaiXuanNaJiaMethod.yearGanYinYang,
  });
  ```
- [ ] 更新 `description` getter

**验收标准**:
- 参数添加成功
- 默认值正确
- 兼容现有代码

---

#### Task 2.2: 重构现有计算逻辑为 _calculateByYearGanYinYang()
**文件**: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`

**要求**:
- [ ] 将现有的 `_generateTaiXuanEachZhu()` 方法重命名并重构为 `_calculateByYearGanYinYang()`
- [ ] 保持现有逻辑不变
- [ ] 返回类型改为 `TaiXuanBaseNumberModel`
- [ ] 添加参数：`JiaZi ganzhi`, `String pillarName`, `bool isYangYear`
- [ ] 确保返回的模型包含 `naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang`
- [ ] 添加 `yaoDetails` 详细信息

**实现要点**:
```dart
TaiXuanBaseNumberModel _calculateByYearGanYinYang(
  JiaZi ganzhi,
  String pillarName,
  bool isYangYear,
) {
  final Enum8Gua ganGua = Constants.tianGanGuaMapper[ganzhi.gan]!;
  final Enum8Gua zhiGua = Constants.diZhiGuaMapper[ganzhi.zhi]!;

  var pura = PureSixYaoGua.by8Gua(ganGua, zhiGua);

  // 选择天干配置（根据年干阴阳）
  final Map<Enum8Gua, List<TianGan>> ganMapper;
  if (isYangYear) {
    ganMapper = Constants.yangGuaYaoTianGan;
  } else {
    ganMapper = Constants.yinGuaYaoTianGan;
  }

  // 地支配置
  final zhiMapperInner = Constants.innerGuaYaoDiZhi;
  final zhiMapperOuter = Constants.outerGuaYaoDiZhi;

  // 下卦纳甲纳支
  final List<TaiXuanYaoDetail> yaoDetails = [];
  int lowerSum = 0;

  for (var i = 0; i < 3; i++) {
    final yao = pura.yaoList[i];
    final tianGan = ganMapper[pura.bottomGua]![i];
    final diZhi = zhiMapperInner[pura.bottomGua]![i];

    yao.naJia = tianGan;
    yao.naZhi = diZhi;

    final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
    final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;

    // 检查是否和为10
    if (ganNum + zhiNum != 10) {
      lowerSum += ganNum + zhiNum;
    }

    yaoDetails.add(TaiXuanYaoDetail(
      position: i,
      positionLabel: ['初', '二', '三'][i],
      tianGan: tianGan,
      diZhi: diZhi,
      taiXuanGanNumber: ganNum,
      taiXuanZhiNumber: zhiNum,
      taiXuanNumber: ganNum + zhiNum,
      yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
      isFiltered: ganNum + zhiNum == 10,
    ));
  }

  // 上卦纳甲纳支
  int upperSum = 0;

  for (var i = 3; i < 6; i++) {
    final yao = pura.yaoList[i];
    final tianGan = ganMapper[pura.topGua]![i - 3];
    final diZhi = zhiMapperOuter[pura.topGua]![i - 3];

    yao.naJia = tianGan;
    yao.naZhi = diZhi;

    final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
    final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;

    if (ganNum + zhiNum != 10) {
      upperSum += ganNum + zhiNum;
    }

    yaoDetails.add(TaiXuanYaoDetail(
      position: i,
      positionLabel: ['四', '五', '上'][i - 3],
      tianGan: tianGan,
      diZhi: diZhi,
      taiXuanGanNumber: ganNum,
      taiXuanZhiNumber: zhiNum,
      taiXuanNumber: ganNum + zhiNum,
      yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
      isFiltered: ganNum + zhiNum == 10,
    ));
  }

  // 计算基础数
  final baseNumber = upperSum * 100 + lowerSum;

  // 后天卦数
  final upperGuaNumber = Constants.houGuaNumberMapper[ganGua]!;
  final lowerGuaNumber = Constants.houGuaNumberMapper[zhiGua]!;

  // 生成公式
  final formula = '上卦: $upperSum, 下卦: $lowerSum, 基础数: $baseNumber';

  return TaiXuanBaseNumberModel(
    baseNumber: baseNumber,
    name: '$pillarName-年干阴阳纳甲',
    description: '$pillarName${ganzhi.name}年干阴阳纳甲计算',
    source: _getSourceFromPillarName(pillarName),
    pillarName: pillarName,
    ganzhi: ganzhi,
    upperGua: ganGua,
    lowerGua: zhiGua,
    upperGuaNumber: upperGuaNumber,
    lowerGuaNumber: lowerGuaNumber,
    naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
    upperGuaSum: upperSum,
    lowerGuaSum: lowerSum,
    yaoDetails: yaoDetails,
    formula: formula,
  );
}
```

**验收标准**:
- [ ] 重构不影响现有功能
- [ ] 返回 TaiXuanBaseNumberModel
- [ ] yaoDetails 包含完整信息
- [ ] 过滤和为10的爻

---

#### Task 2.3: 实现 _calculateByInnerOuterGua() 方法
**文件**: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`

**要求**:
- [ ] 创建新方法 `_calculateByInnerOuterGua()`
- [ ] 参数：`JiaZi ganzhi`, `String pillarName`
- [ ] 返回类型：`TaiXuanBaseNumberModel`
- [ ] 实现传统内外卦纳甲逻辑

**关键逻辑**:
```dart
TaiXuanBaseNumberModel _calculateByInnerOuterGua(
  JiaZi ganzhi,
  String pillarName,
) {
  final Enum8Gua ganGua = Constants.tianGanGuaMapper[ganzhi.gan]!;
  final Enum8Gua zhiGua = Constants.diZhiGuaMapper[ganzhi.zhi]!;

  var pura = PureSixYaoGua.by8Gua(ganGua, zhiGua);

  // 关键区别：判断当前卦的阴阳
  // 下卦判断
  final bool isLowerYangGua = Constants.yangGua.contains(zhiGua.name);
  final Map<Enum8Gua, List<TianGan>> lowerGanMapper =
      isLowerYangGua ? Constants.outerGuaYaoTianGan : Constants.innerGuaYaoTianGan;

  // 上卦判断
  final bool isUpperYangGua = Constants.yangGua.contains(ganGua.name);
  final Map<Enum8Gua, List<TianGan>> upperGanMapper =
      isUpperYangGua ? Constants.outerGuaYaoTianGan : Constants.innerGuaYaoTianGan;

  // 地支配置（与年干阴阳法相同）
  final zhiMapperInner = Constants.innerGuaYaoDiZhi;
  final zhiMapperOuter = Constants.outerGuaYaoDiZhi;

  // 下卦纳甲纳支
  final List<TaiXuanYaoDetail> yaoDetails = [];
  int lowerSum = 0;

  for (var i = 0; i < 3; i++) {
    final yao = pura.yaoList[i];
    final tianGan = lowerGanMapper[pura.bottomGua]![i];
    final diZhi = zhiMapperInner[pura.bottomGua]![i];

    yao.naJia = tianGan;
    yao.naZhi = diZhi;

    final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
    final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;

    if (ganNum + zhiNum != 10) {
      lowerSum += ganNum + zhiNum;
    }

    yaoDetails.add(TaiXuanYaoDetail(
      position: i,
      positionLabel: ['初', '二', '三'][i],
      tianGan: tianGan,
      diZhi: diZhi,
      taiXuanGanNumber: ganNum,
      taiXuanZhiNumber: zhiNum,
      taiXuanNumber: ganNum + zhiNum,
      yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
      isFiltered: ganNum + zhiNum == 10,
    ));
  }

  // 上卦纳甲纳支
  int upperSum = 0;

  for (var i = 3; i < 6; i++) {
    final yao = pura.yaoList[i];
    final tianGan = upperGanMapper[pura.topGua]![i - 3];
    final diZhi = zhiMapperOuter[pura.topGua]![i - 3];

    yao.naJia = tianGan;
    yao.naZhi = diZhi;

    final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
    final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;

    if (ganNum + zhiNum != 10) {
      upperSum += ganNum + zhiNum;
    }

    yaoDetails.add(TaiXuanYaoDetail(
      position: i,
      positionLabel: ['四', '五', '上'][i - 3],
      tianGan: tianGan,
      diZhi: diZhi,
      taiXuanGanNumber: ganNum,
      taiXuanZhiNumber: zhiNum,
      taiXuanNumber: ganNum + zhiNum,
      yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
      isFiltered: ganNum + zhiNum == 10,
    ));
  }

  // 计算基础数
  final baseNumber = upperSum * 100 + lowerSum;

  // 后天卦数
  final upperGuaNumber = Constants.houGuaNumberMapper[ganGua]!;
  final lowerGuaNumber = Constants.houGuaNumberMapper[zhiGua]!;

  // 生成公式
  final formula = '上卦: $upperSum, 下卦: $lowerSum, 基础数: $baseNumber';

  return TaiXuanBaseNumberModel(
    baseNumber: baseNumber,
    name: '$pillarName-传统内外卦纳甲',
    description: '$pillarName${ganzhi.name}传统内外卦纳甲计算',
    source: _getSourceFromPillarName(pillarName),
    pillarName: pillarName,
    ganzhi: ganzhi,
    upperGua: ganGua,
    lowerGua: zhiGua,
    upperGuaNumber: upperGuaNumber,
    lowerGuaNumber: lowerGuaNumber,
    naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
    upperGuaSum: upperSum,
    lowerGuaSum: lowerSum,
    yaoDetails: yaoDetails,
    formula: formula,
  );
}
```

**验收标准**:
- [ ] 方法实现正确
- [ ] 根据内外卦阴阳选择天干配置
- [ ] 返回完整的 TaiXuanBaseNumberModel
- [ ] yaoDetails 包含所有信息

---

#### Task 2.4: 修改 calculate() 主方法
**文件**: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`

**要求**:
- [ ] 修改 `calculate()` 方法支持根据 `naJiaMethod` 参数调用不同的计算方法
- [ ] 实现 switch-case 逻辑
- [ ] 确保返回值包含 `naJiaMethod` 信息

**实现要点**:
```dart
@override
BaseNumberModelResult calculate(TaiXuanFourZhuStrategyParams params) {
  try {
    final List<TaiXuanBaseNumberModel> results = [];

    // 四柱循环
    final pillars = [
      (params.eightChars.year, '年柱'),
      (params.eightChars.month, '月柱'),
      (params.eightChars.day, '日柱'),
      (params.eightChars.time, '时柱'),
    ];

    for (final (pillar, pillarName) in pillars) {
      TaiXuanBaseNumberModel result;

      // 根据纳甲方法选择计算逻辑
      switch (params.naJiaMethod) {
        case TaiXuanNaJiaMethod.yearGanYinYang:
          final isYangYear = params.eightChars.year.gan.isYang;
          result = _calculateByYearGanYinYang(pillar, pillarName, isYangYear);
          break;

        case TaiXuanNaJiaMethod.innerOuterGua:
          result = _calculateByInnerOuterGua(pillar, pillarName);
          break;
      }

      results.add(result);
    }

    return BaseNumberModelResult.success(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      baseNumbers: results,
      sourceData: {
        'naJiaMethod': params.naJiaMethod.toString(),
        'eightChars': params.eightChars.toString(),
        'pillarCount': 4,
      },
    );
  } catch (e, stackTrace) {
    return BaseNumberModelResult.error(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      errorMessage: e.toString(),
      sourceData: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
    );
  }
}
```

**验收标准**:
- [ ] 支持两种纳甲方法
- [ ] Switch逻辑正确
- [ ] 错误处理完善
- [ ] sourceData 包含方法信息

---

#### Task 2.5: 添加辅助方法 _getSourceFromPillarName()
**文件**: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`

**要求**:
- [ ] 实现 `_getSourceFromPillarName()` 方法
- [ ] 将柱名转换为 BaseNumberSource 枚举

**实现**:
```dart
BaseNumberSource _getSourceFromPillarName(String pillarName) {
  switch (pillarName) {
    case '年柱':
      return BaseNumberSource.yearZhu;
    case '月柱':
      return BaseNumberSource.monthZhu;
    case '日柱':
      return BaseNumberSource.dayZhu;
    case '时柱':
      return BaseNumberSource.timeZhu;
    default:
      throw ArgumentError('Invalid pillar name: $pillarName');
  }
}
```

**验收标准**:
- [ ] 方法实现正确
- [ ] 处理所有情况
- [ ] 抛出合适的异常

---

### Phase 3: UseCase层实现 (预计1-2小时)

#### Task 3.1: 修改 TaiXuanFourZhuTiaoWenListUseCase
**文件**: `lib/usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart`

**要求**:
- [ ] 添加方法 `calculateBothMethods()` 返回两种方法的结果
- [ ] 现有 `execute()` 方法支持 `naJiaMethod` 参数
- [ ] 实现条文扩展逻辑（基础数 ± 96）

**实现要点**:
```dart
/// 计算指定纳甲方法的结果
Future<MultiBaseNumberResult> execute(
  TaiXuanFourZhuUseCaseParams params, {
  TaiXuanNaJiaMethod? naJiaMethod,
  TiaoWenListCalculationConfig? calculationConfig,
}) async {
  try {
    // 使用指定的纳甲方法，如未指定则使用默认
    final method = naJiaMethod ?? TaiXuanNaJiaMethod.yearGanYinYang;

    // 调用Strategy
    final strategyParams = TaiXuanFourZhuStrategyParams(
      eightChars: params.eightChars,
      naJiaMethod: method,
    );
    final strategyResult = _strategy.calculate(strategyParams);

    if (strategyResult.hasError) {
      throw Exception("太玄取数计算失败: ${strategyResult.errorMessage}");
    }

    // 扩展条文列表（基础数 ± 96）
    final baseNumberTiaoWenList = <BaseNumberTiaoWenListModel>[];

    for (final baseModel in strategyResult.baseNumbers) {
      final tiaoWenNumbers = [
        baseModel.baseNumber - 96,
        baseModel.baseNumber,
        baseModel.baseNumber + 96,
      ];

      // 查询条文数据
      final tiaoWenDataList = await _repository.getByIds(tiaoWenNumbers);

      baseNumberTiaoWenList.add(
        BaseNumberTiaoWenListModel(
          baseNumber: baseModel.baseNumber,
          tiaoWenDataList: tiaoWenDataList,
          name: baseModel.name,
          description: baseModel.description,
          source: baseModel.source,
          tiaoWenNumbers: tiaoWenNumbers,
        ),
      );
    }

    // 提取所有条文实体
    final allTiaoWenEntities = baseNumberTiaoWenList
        .expand((model) => model.tiaoWenDataList)
        .toList();

    return MultiBaseNumberResult.success(
      algorithmName: '太玄取数法',
      algorithmDescription: '太玄纳甲取数法（${method == TaiXuanNaJiaMethod.yearGanYinYang ? "年干阴阳" : "传统内外卦"}）',
      calculationParams: params.eightChars.toString(),
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      tiaoWenEntities: allTiaoWenEntities,
      sourceData: {
        'naJiaMethod': method.toString(),
        'eightChars': params.eightChars.toString(),
        'pillarCount': 4,
      },
    );
  } catch (e, stackTrace) {
    return MultiBaseNumberResult.error(
      algorithmName: '太玄取数法',
      algorithmDescription: '太玄纳甲取数法',
      calculationParams: params.eightChars.toString(),
      errorMessage: e.toString(),
      sourceData: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
    );
  }
}

/// 计算两种方法并返回
Future<Map<TaiXuanNaJiaMethod, MultiBaseNumberResult>> calculateBothMethods(
  TaiXuanFourZhuUseCaseParams params, {
  TiaoWenListCalculationConfig? calculationConfig,
}) async {
  final results = <TaiXuanNaJiaMethod, MultiBaseNumberResult>{};

  // 计算年干阴阳纳甲
  results[TaiXuanNaJiaMethod.yearGanYinYang] = await execute(
    params,
    naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
    calculationConfig: calculationConfig,
  );

  // 计算传统内外卦纳甲
  results[TaiXuanNaJiaMethod.innerOuterGua] = await execute(
    params,
    naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
    calculationConfig: calculationConfig,
  );

  return results;
}
```

**验收标准**:
- [ ] execute() 支持 naJiaMethod 参数
- [ ] calculateBothMethods() 返回两种结果
- [ ] 条文扩展逻辑正确（± 96）
- [ ] 错误处理完善

---

### Phase 4: ViewModel层实现 (预计2-3小时)

#### Task 4.1: 修改 TaiXuanFourZhuViewModel
**文件**: `lib/presentation/viewmodels/tai_xuan_four_zhu_view_model.dart`

**要求**:
- [ ] 添加两种方法的计算结果状态
- [ ] 添加显示控制状态
- [ ] 实现 `calculateBothMethods()` 方法
- [ ] 添加便捷的 getter 方法

**实现要点**:
```dart
class TaiXuanFourZhuViewModel extends ChangeNotifier {
  final TaiXuanFourZhuTiaoWenListUseCase _useCase;

  // 两种方法的计算结果
  MultiBaseNumberResult? _yearGanYinYangResult;
  MultiBaseNumberResult? _innerOuterGuaResult;

  // 两种方法的显示状态（默认都为true）
  bool _showYearGanYinYang = true;
  bool _showInnerOuterGua = true;

  // 当前八字
  EightChars? _currentEightChars;

  // 加载状态
  bool _isLoading = false;
  String? _errorMessage;

  TaiXuanFourZhuViewModel(this._useCase);

  // Getters
  MultiBaseNumberResult? get yearGanYinYangResult => _yearGanYinYangResult;
  MultiBaseNumberResult? get innerOuterGuaResult => _innerOuterGuaResult;
  bool get showYearGanYinYang => _showYearGanYinYang;
  bool get showInnerOuterGua => _showInnerOuterGua;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasYearGanYinYangResult => _yearGanYinYangResult != null;
  bool get hasInnerOuterGuaResult => _innerOuterGuaResult != null;

  // 切换显示状态
  void toggleYearGanYinYang(bool value) {
    _showYearGanYinYang = value;
    notifyListeners();
  }

  void toggleInnerOuterGua(bool value) {
    _showInnerOuterGua = value;
    notifyListeners();
  }

  // 计算两种方法
  Future<void> calculateBothMethods(EightChars eightChars) async {
    _currentEightChars = eightChars;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = TaiXuanFourZhuUseCaseParams(eightChars: eightChars);
      final results = await _useCase.calculateBothMethods(params);

      _yearGanYinYangResult = results[TaiXuanNaJiaMethod.yearGanYinYang];
      _innerOuterGuaResult = results[TaiXuanNaJiaMethod.innerOuterGua];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新
  Future<void> refresh() async {
    if (_currentEightChars != null) {
      await calculateBothMethods(_currentEightChars!);
    }
  }

  // 获取展开的条文列表
  List<int> getExpandedTiaoWen(int baseNumber) {
    return [
      baseNumber - 96,
      baseNumber,
      baseNumber + 96,
    ];
  }

  // 获取年干阴阳纳甲的UI模型列表
  List<TaiXuanUIModel> get yearGanYinYangUIModels {
    if (!hasYearGanYinYangResult) return [];
    return _yearGanYinYangResult!.baseNumberTiaoWenList
        .map((item) => TaiXuanUIModel.fromDomain(item))
        .toList();
  }

  // 获取传统内外卦纳甲的UI模型列表
  List<TaiXuanUIModel> get innerOuterGuaUIModels {
    if (!hasInnerOuterGuaResult) return [];
    return _innerOuterGuaResult!.baseNumberTiaoWenList
        .map((item) => TaiXuanUIModel.fromDomain(item))
        .toList();
  }
}
```

**验收标准**:
- [ ] 状态管理正确
- [ ] calculateBothMethods() 实现正确
- [ ] 显示控制状态工作正常
- [ ] 便捷 getter 方法可用
- [ ] 错误处理完善

---

### Phase 5: UI层实现 (预计3-4小时)

#### Task 5.1: 创建 TaiXuanUIModel
**文件**: `lib/presentation/models/tai_xuan_ui_model.dart`

**要求**:
- [ ] 定义UI展示所需的数据结构
- [ ] 包含计算过程的所有信息
- [ ] 实现 `fromDomain()` 工厂方法
- [ ] 实现 `fromTaiXuanModel()` 工厂方法

**数据结构**:
```dart
class TaiXuanUIModel {
  final String pillarName;              // "年柱"
  final String ganZhi;                  // "甲子"
  final String naJiaMethod;             // "年干阴阳纳甲" / "传统内外卦纳甲"
  final int baseNumber;                 // 基础数
  final List<int> tiaoWenNumbers;       // 条文编号列表
  final List<String> tiaoWenContents;   // 条文内容列表

  // 计算过程
  final String upperGua;                // "乾卦"
  final String lowerGua;                // "坤卦"
  final int upperGuaNumber;             // 6
  final int lowerGuaNumber;             // 2
  final int upperGuaSum;                // 上卦总和
  final int lowerGuaSum;                // 下卦总和
  final List<TaiXuanYaoUIModel> yaoList; // 六爻详情
  final String formula;                 // 计算公式
}

class TaiXuanYaoUIModel {
  final int position;                   // 爻位（0-5）
  final String positionLabel;           // "初" / "二" / "三" / "四" / "五" / "上"
  final String yinYang;                 // "阳" / "阴"
  final String tianGan;                 // "甲"
  final String diZhi;                   // "子"
  final int ganNumber;                  // 天干太玄数
  final int zhiNumber;                  // 地支太玄数
  final int totalNumber;                // 总太玄数
  final bool isFiltered;                // 是否被过滤
}
```

**验收标准**:
- [ ] 数据结构定义完整
- [ ] fromDomain() 方法实现正确
- [ ] 包含所有UI展示所需信息

---

#### Task 5.2: 创建 TaiXuanCard Widget
**文件**: `lib/presentation/widgets/tai_xuan_card.dart`

**要求**:
- [ ] 展示单个结果的卡片
- [ ] 显示柱名和纳甲方案
- [ ] 显示基础数
- [ ] 可展开显示详细计算过程
- [ ] 六爻信息可视化展示
- [ ] 条文列表展示

**UI结构**:
```dart
Card(
  child: ExpansionTile(
    title: Text('${model.pillarName} - ${model.naJiaMethod}'),
    subtitle: Text('基础数: ${model.baseNumber}'),
    children: [
      // 卦象信息
      _buildGuaInfo(model),

      // 六爻详情
      _buildYaoDetails(model.yaoList),

      // 计算结果
      _buildCalculationResult(model),

      // 条文列表
      _buildTiaoWenList(model.tiaoWenNumbers, model.tiaoWenContents),
    ],
  ),
)
```

**验收标准**:
- [ ] 卡片布局美观
- [ ] 展开/收起功能正常
- [ ] 六爻详情显示清晰
- [ ] 条文列表展示完整

---

#### Task 5.3: 创建 TaiXuanResultsWidget
**文件**: `lib/presentation/widgets/tai_xuan_results_widget.dart`

**要求**:
- [ ] 包含多选框控制显示
- [ ] 分别展示两种纳甲方案的结果
- [ ] 支持分组显示（按柱分组）
- [ ] 实现下拉刷新

**UI结构**:
```dart
Column(
  children: [
    // 多选框区域
    CheckboxListTile(
      title: Text('年干阴阳纳甲'),
      value: viewModel.showYearGanYinYang,
      onChanged: (value) => viewModel.toggleYearGanYinYang(value!),
    ),
    CheckboxListTile(
      title: Text('传统内外卦纳甲'),
      value: viewModel.showInnerOuterGua,
      onChanged: (value) => viewModel.toggleInnerOuterGua(value!),
    ),

    Divider(),

    // 结果展示区
    Expanded(
      child: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: ListView(
          children: [
            // 年干阴阳纳甲结果
            if (viewModel.showYearGanYinYang && viewModel.hasYearGanYinYangResult)
              _buildMethodSection(
                '年干阴阳纳甲',
                viewModel.yearGanYinYangUIModels,
              ),

            // 传统内外卦纳甲结果
            if (viewModel.showInnerOuterGua && viewModel.hasInnerOuterGuaResult)
              _buildMethodSection(
                '传统内外卦纳甲',
                viewModel.innerOuterGuaUIModels,
              ),
          ],
        ),
      ),
    ),
  ],
)
```

**验收标准**:
- [ ] 多选框功能正常
- [ ] 两种方案同时显示
- [ ] 下拉刷新工作正常
- [ ] 分组显示清晰

---

#### Task 5.4: 更新 StrategyDemoPage
**文件**: `lib/presentation/pages/strategy_demo_page.dart`

**要求**:
- [ ] 修改太玄取数页面，使用新的 TaiXuanResultsWidget
- [ ] 更新初始化逻辑，调用 `calculateBothMethods()`
- [ ] 更新刷新逻辑

**修改要点**:
```dart
// 在 _buildTaiXuanFourZhuContent() 中
Widget _buildTaiXuanFourZhuContent() {
  return Consumer<TaiXuanFourZhuViewModel>(
    builder: (context, viewModel, child) {
      if (viewModel.isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (viewModel.hasError) {
        return Center(child: Text('错误: ${viewModel.errorMessage}'));
      }

      return TaiXuanResultsWidget(viewModel: viewModel);
    },
  );
}

// 初始化时调用
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final taiXuanViewModel = context.read<TaiXuanFourZhuViewModel>();
    final eightChars = _getEightCharsFromContext();
    taiXuanViewModel.calculateBothMethods(eightChars);
  });
}
```

**验收标准**:
- [ ] 页面集成成功
- [ ] 初始化逻辑正确
- [ ] 刷新逻辑工作正常

---

### Phase 6: 依赖注入配置 (预计1小时)

#### Task 6.1: 更新 strategy_providers.dart
**文件**: `lib/infrastructure/di/strategy_providers.dart`

**要求**:
- [ ] 确认 TaiXuanFourZhuStrategy 已注入
- [ ] 确认 TaiXuanFourZhuTiaoWenListUseCase 已注入
- [ ] 确认 TaiXuanFourZhuViewModel 已注入
- [ ] 验证依赖关系正确

**Provider配置**:
```dart
MultiProvider(
  providers: [
    // Strategy
    Provider<TaiXuanFourZhuStrategy>(
      create: (_) => TaiXuanFourZhuStrategy(),
    ),

    // UseCase
    ProxyProvider2<TaiXuanFourZhuStrategy, TiaoWenRepository, TaiXuanFourZhuTiaoWenListUseCase>(
      update: (_, strategy, repository, __) =>
          TaiXuanFourZhuTiaoWenListUseCase(strategy, repository),
    ),

    // ViewModel
    ChangeNotifierProxyProvider<TaiXuanFourZhuTiaoWenListUseCase, TaiXuanFourZhuViewModel>(
      create: (context) {
        final useCase = context.read<TaiXuanFourZhuTiaoWenListUseCase>();
        return TaiXuanFourZhuViewModel(useCase);
      },
      update: (_, useCase, viewModel) =>
          viewModel ?? TaiXuanFourZhuViewModel(useCase),
    ),
  ],
)
```

**验收标准**:
- [ ] 所有Provider配置正确
- [ ] 依赖注入工作正常
- [ ] 无运行时错误

---

### Phase 7: 测试实现 (预计3-4小时)

#### Task 7.1: 创建Strategy单元测试
**文件**: `test/service/strategy/tai_xuan_four_zhu_strategy_v2_test.dart`

**测试数据**: "癸未 癸亥 壬午 戊申" → "坤艮 坤坎 乾离 坎乾" → "3342 3326 3945 2648"

**要求**:
- [ ] 测试年干阴阳纳甲法（已存在）
- [ ] 测试传统内外卦纳甲法（新增）
- [ ] 测试两种方法产生不同结果
- [ ] 测试干支配卦正确性
- [ ] 测试六爻详情完整性
- [ ] 测试过滤和为10的爻
- [ ] 测试边界条件

**测试组**:
```dart
group('TaiXuanFourZhuStrategy - 传统内外卦纳甲法', () {
  test('应该返回4个基础数结果', () { });
  test('年柱癸未应配为坤艮卦，太玄数3342', () { });
  test('月柱癸亥应配为坤坎卦，太玄数3326', () { });
  test('日柱壬午应配为乾离卦，太玄数3945', () { });
  test('时柱戊申应配为坎乾卦，太玄数2648', () { });
  test('所有4个基础数应该符合预期值', () { });
  test('内外卦法和年干阴阳法应该产生不同的结果', () { });
});

group('TaiXuanFourZhuStrategy - 六爻详细信息验证', () {
  test('六爻应该包含天干地支和太玄数', () { });
  test('应该正确标记被过滤的爻（和为10）', () { });
  test('六爻详情应该包含位置标签', () { });
});
```

**验收标准**:
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 80%
- [ ] 测试数据验证正确

---

#### Task 7.2: 创建调试测试
**文件**: `test/service/strategy/tai_xuan_four_zhu_strategy_v2_debug_test.dart`

**要求**:
- [ ] 打印传统内外卦纳甲法的详细计算结果
- [ ] 包含六爻详情
- [ ] 包含计算公式
- [ ] 对比两种方法的结果

**输出格式**:
```
========== 太玄取数法（传统内外卦纳甲）计算结果 ==========
八字: 癸未 癸亥 壬午 戊申

年柱:
  干支: 癸未
  上卦: 坤(2)
  下卦: 艮(8)
  纳甲方法: 传统内外卦纳甲
  六爻详情:
    初爻(阴): 乙未 = 8+8 = 16 (已过滤)
    ...
  上卦总和: 33
  下卦总和: 42
  基础数: 3342

预期值: 3342, 3326, 3945, 2648
实际值: 3342, 3326, 3945, 2648
========================================
```

**验收标准**:
- [ ] 打印输出清晰
- [ ] 包含所有关键信息
- [ ] 实际值匹配预期值

---

#### Task 7.3: 创建UseCase测试
**文件**: `test/usecases/tai_xuan_four_zhu_use_case_test.dart`

**要求**:
- [ ] 测试 execute() 方法支持 naJiaMethod 参数
- [ ] 测试 calculateBothMethods() 返回两种结果
- [ ] 测试条文扩展逻辑（± 96）
- [ ] 测试错误处理

**验收标准**:
- [ ] 所有测试通过
- [ ] 测试用例覆盖主要场景

---

#### Task 7.4: 创建ViewModel测试
**文件**: `test/presentation/viewmodels/tai_xuan_view_model_test.dart`

**要求**:
- [ ] 测试 calculateBothMethods() 方法
- [ ] 测试显示控制状态
- [ ] 测试刷新功能
- [ ] 测试错误处理

**验收标准**:
- [ ] 所有测试通过
- [ ] 状态管理测试完整

---

### Phase 8: 文档和测试报告 (预计1-2小时)

#### Task 8.1: 创建测试报告
**文件**: `test/service/strategy/TAI_XUAN_V2_TEST_REPORT.md`

**要求**:
- [ ] 测试概述和状态
- [ ] 测试数据说明
- [ ] 两种纳甲方法对比表
- [ ] 干支配卦结果表
- [ ] 计算结果对比表
- [ ] 测试用例分组说明
- [ ] 重要发现和差异分析
- [ ] 运行测试命令
- [ ] 结论和建议

**验收标准**:
- [ ] 文档结构完整
- [ ] 数据表格清晰
- [ ] 对比分析详细

---

#### Task 8.2: 更新 PRD 文档
**文件**: `docs/normal_alg/PRD.md`

**要求**:
- [x] 更新太玄四柱计算模块说明
- [ ] 添加双纳甲方案描述
- [ ] 更新用户交互说明
- [ ] 更新验收标准

**验收标准**:
- [x] PRD 更新完整
- [ ] 描述清晰准确

---

#### Task 8.3: 创建用户使用文档
**文件**: `docs/normal_alg/tai_xuan_user_guide.md`

**要求**:
- [ ] 功能介绍
- [ ] 两种纳甲方案说明
- [ ] 操作步骤
- [ ] 界面截图
- [ ] 常见问题解答

**验收标准**:
- [ ] 文档易于理解
- [ ] 操作步骤清晰
- [ ] 包含示例

---

## 📝 开发检查清单

### 代码质量
- [ ] 所有方法都有文档注释
- [ ] 代码符合Dart风格规范
- [ ] 没有硬编码的Magic Number
- [ ] 异常处理完善
- [ ] 日志输出合理

### 功能完整性
- [ ] 年干阴阳纳甲法计算正确
- [ ] 传统内外卦纳甲法计算正确
- [ ] 四柱都能正确处理
- [ ] 两种方法同时显示
- [ ] 条文扩展正确（± 96）
- [ ] 多选框控制工作正常

### UI/UX
- [ ] 界面美观统一
- [ ] 交互流畅
- [ ] 错误提示友好
- [ ] 加载状态清晰
- [ ] 计算过程展示详细
- [ ] 六爻详情可视化清晰

### 测试
- [ ] Strategy单元测试通过
- [ ] UseCase测试通过
- [ ] ViewModel测试通过
- [ ] 调试测试输出正确
- [ ] 测试覆盖率达标

### 文档
- [x] PRD文档更新
- [ ] 测试报告完成
- [ ] 用户指南完成
- [ ] API文档更新
- [ ] CHANGELOG更新

---

## 🐛 已知问题与风险

### 潜在问题
1. **内外卦阴阳判断**:
   - 风险：内外卦阴阳判断逻辑可能与预期不符
   - 解决：通过测试数据验证，确保逻辑正确

2. **天干配置差异**:
   - 风险：两种方法的天干配置可能混淆
   - 解决：清晰命名，充分测试

3. **性能考虑**:
   - 风险：同时计算两种方法可能较慢
   - 优化：考虑并发计算或缓存

4. **UI复杂度**:
   - 风险：同时显示两种方法可能导致界面过于复杂
   - 解决：使用多选框控制显示，支持折叠

### 待讨论事项
- [ ] 条文扩展配置是否需要可自定义（当前固定 ± 96）
- [ ] 是否需要添加两种方法的对比视图
- [ ] UI展示是否需要更多可视化元素（如卦象图）

---

## 📅 里程碑

### M1: 数据模型完成 (2-3小时)
- [ ] TaiXuanYaoDetail 创建完成
- [ ] TaiXuanNaJiaMethod 枚举创建完成
- [ ] TaiXuanBaseNumberModel 创建完成

### M2: Strategy实现完成 (3-4小时)
- [ ] 现有逻辑重构为 _calculateByYearGanYinYang()
- [ ] _calculateByInnerOuterGua() 实现完成
- [ ] calculate() 主方法支持两种方法

### M3: UseCase实现完成 (1-2小时)
- [ ] execute() 支持 naJiaMethod 参数
- [ ] calculateBothMethods() 实现完成

### M4: ViewModel实现完成 (2-3小时)
- [ ] TaiXuanFourZhuViewModel 修改完成
- [ ] 状态管理支持两种方法

### M5: UI实现完成 (3-4小时)
- [ ] TaiXuanUIModel 创建完成
- [ ] TaiXuanCard Widget 创建完成
- [ ] TaiXuanResultsWidget 创建完成
- [ ] StrategyDemoPage 集成完成

### M6: 测试完成 (3-4小时)
- [ ] Strategy单元测试完成
- [ ] UseCase测试完成
- [ ] ViewModel测试完成
- [ ] 调试测试完成
- [ ] 所有测试通过

### M7: 文档完成 (1-2小时)
- [x] PRD更新完成
- [ ] 测试报告完成
- [ ] 用户指南完成

**预计总时间**: 16-23小时

---

## 🔗 相关资源

### 代码参考
- 现有太玄Strategy: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`
- 八卦加则Strategy: `lib/service/strategy/ba_gua_jia_ze_strategy.dart`
- PureSixYaoGua: `lib/domain/pure_six_yao_gua.dart`
- Constants: `lib/constant/constants.dart`

### 文档
- PRD: `docs/normal_alg/PRD.md`
- 八卦加则TODO: `docs/normal_alg/eight_gua_jia_ze_todo_list.md`
- 八卦加则测试报告: `test/service/strategy/BA_GUA_JIA_ZE_TEST_REPORT.md`

### 测试数据
- 年干阴阳纳甲测试: "癸巳 甲子 丁酉 癸卯" → 4245, 4826, 2648, 4248
- 传统内外卦纳甲测试: "癸未 癸亥 壬午 戊申" → 3342, 3326, 3945, 2648

### 关键常量
- yangGuaYaoTianGan: 年干阴阳法阳年天干配置
- yinGuaYaoTianGan: 年干阴阳法阴年天干配置
- outerGuaYaoTianGan: 传统法外卦（阳卦）天干配置
- innerGuaYaoTianGan: 传统法内卦（阴卦）天干配置
- innerGuaYaoDiZhi: 下卦地支配置（两种方法通用）
- outerGuaYaoDiZhi: 上卦地支配置（两种方法通用）
- yangGua: 阳卦集合 {"乾", "震", "坎", "艮"}
- yinGua: 阴卦集合 {"坤", "巽", "离", "兑"}

---

## 📧 联系方式

**技术问题**: 请提Issue或联系项目维护者
**需求变更**: 请更新PRD并通知团队
**进度更新**: 每完成一项任务则在此TODO清单中勾选

---

**创建日期**: 2025-10-10
**文档版本**: v1.0
**最后更新**: 2025-10-10
