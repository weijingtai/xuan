# 多基础数模型使用指南

## 概述

多基础数模型系统用于处理算法中可能存在的多个基础数，每个基础数都能产生对应的条文列表。该系统包含以下核心组件：

- `BaseNumberModel`: 单个基础数模型
- `MultiBaseNumberResult`: 多基础数算法结果（继承自BaseCalculationResult）
- `BaseNumberSource`: 基础数来源枚举

## 核心特性

### 1. 基础数模型 (BaseNumberModel)

包含以下信息：
- **基础数值**: 算法计算得出的基础数字
- **基础数名称**: 便于识别的名称（如"年柱基础数"）
- **基础数描述**: 详细描述信息
- **基础数来源**: 来源类型（年柱、月柱、日柱、时柱、综合、初始数、次数、自定义）
- **基础数条文**: 可选的基础数对应的条文（当基础数本身就是条文编号时）
- **条文列表生成配置**: 如何从基础数生成条文列表的配置
- **条文编号列表**: 生成的条文编号
- **条文数据列表**: 从Repository获取的完整条文数据

### 2. 多基础数结果 (MultiBaseNumberResult)

继承自 `BaseCalculationResult`，管理包含多个基础数的算法结果：
- 算法名称和描述
- 计算参数
- 基础数模型列表
- 计算状态和错误信息
- 计算时间戳和源数据

## 使用示例

### 1. 太玄四柱算法示例

```dart
// 在UseCase中使用
class TaiXuanFourZhuTiaoWenListUseCase extends BaseGetTiaoWenListUseCase<TaiXuanFourZhuUseCaseParams> {
  final TaiXuanFourZhuStrategy _strategy;
  final TiaoWenRepository _repository;

  @override
  Future<MultiBaseNumberResult> execute(TaiXuanFourZhuUseCaseParams params) async {
    try {
      // 1. 调用Strategy计算四柱基础数
      final strategyResult = _strategy.calculate(strategyParams);
      final fourZhuBaseNumbers = strategyResult.baseTiaoWenList;

      // 2. 创建条文列表计算配置
      final calculationConfig = TiaoWenListCalculationConfig.listAdd(
        customList: [96, 192, 384, 768],
        withSub: true,
      );

      // 3. 创建基础数模型列表
      final baseNumbers = <BaseNumberModel>[];
      final sources = [
        BaseNumberSource.yearZhu,
        BaseNumberSource.monthZhu,
        BaseNumberSource.dayZhu,
        BaseNumberSource.timeZhu,
      ];
      final names = ['年柱基础数', '月柱基础数', '日柱基础数', '时柱基础数'];

      for (int i = 0; i < fourZhuBaseNumbers.length && i < 4; i++) {
        // 创建基础数模型
        final baseNumberModel = BaseNumberModel.create(
          baseNumber: fourZhuBaseNumbers[i],
          name: names[i],
          description: '${names[i]}：${fourZhuBaseNumbers[i]}',
          source: sources[i],
          calculationConfig: calculationConfig,
        );

        // 获取条文数据
        final tiaoWenDataList = await _repository.getByIdList(
          queryList: baseNumberModel.tiaoWenNumbers,
        );

        // 更新模型数据
        final completeModel = baseNumberModel.copyWithTiaoWenData(tiaoWenDataList);
        baseNumbers.add(completeModel);
      }

      // 4. 返回多基础数结果
      return MultiBaseNumberResult.success(
        algorithmName: '太玄四柱',
        algorithmDescription: '太玄四柱取数法，生成四个基础数',
        calculationParams: params.description,
        baseNumbers: baseNumbers,
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'fourZhuBaseNumbers': fourZhuBaseNumbers,
        },
      );
    } catch (e) {
      return MultiBaseNumberResult.error(
        algorithmName: '太玄四柱',
        algorithmDescription: '太玄四柱取数法',
        calculationParams: params.description,
        errorMessage: e.toString(),
      );
    }
  }
}
```

### 2. 皇极算法示例

```dart
class HuangJiTiaoWenListUseCase extends BaseGetTiaoWenListUseCase<HuangJiUseCaseParams> {
  final HuangJiStrategy _strategy;
  final TiaoWenRepository _repository;

  @override
  Future<MultiBaseNumberResult> execute(HuangJiUseCaseParams params) async {
    try {
      // 1. 调用Strategy计算
      final strategyResult = _strategy.calculate(strategyParams);
      final initialNumber = strategyResult.initialNumber;
      final secondaryNumber = strategyResult.secondaryNumber;
      final selectedBaseNumber = strategyResult.selectedBaseNumber;

      // 2. 创建配置
      final calculationConfig = TiaoWenListCalculationConfig.listAdd(
        customList: [96, 192, 384, 768],
        withSub: true,
      );

      // 3. 创建基础数模型
      final baseNumbers = <BaseNumberModel>[];

      // 初始数
      final initialModel = BaseNumberModel.create(
        baseNumber: initialNumber,
        name: '初始数',
        description: '皇极算法初始数：$initialNumber',
        source: BaseNumberSource.initial,
        calculationConfig: calculationConfig,
      );
      final initialTiaoWenData = await _repository.getByIdList(
        queryList: initialModel.tiaoWenNumbers,
      );
      baseNumbers.add(initialModel.copyWithTiaoWenData(initialTiaoWenData));

      // 次数
      final secondaryModel = BaseNumberModel.create(
        baseNumber: secondaryNumber,
        name: '次数',
        description: '皇极算法次数：$secondaryNumber',
        source: BaseNumberSource.secondary,
        calculationConfig: calculationConfig,
      );
      final secondaryTiaoWenData = await _repository.getByIdList(
        queryList: secondaryModel.tiaoWenNumbers,
      );
      baseNumbers.add(secondaryModel.copyWithTiaoWenData(secondaryTiaoWenData));

      // 如果选择的基础数与初始数和次数都不同，则添加为综合计算结果
      if (selectedBaseNumber != initialNumber && selectedBaseNumber != secondaryNumber) {
        final combinedModel = BaseNumberModel.create(
          baseNumber: selectedBaseNumber,
          name: '综合基础数',
          description: '皇极算法综合计算结果：$selectedBaseNumber',
          source: BaseNumberSource.combined,
          calculationConfig: calculationConfig,
        );
        final combinedTiaoWenData = await _repository.getByIdList(
          queryList: combinedModel.tiaoWenNumbers,
        );
        baseNumbers.add(combinedModel.copyWithTiaoWenData(combinedTiaoWenData));
      }

      // 4. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '皇极取数法',
        algorithmDescription: '皇极取数法，包含初始数、次数和综合基础数',
        calculationParams: params.description,
        baseNumbers: baseNumbers,
        sourceData: {
          'initialNumber': initialNumber,
          'secondaryNumber': secondaryNumber,
          'selectedBaseNumber': selectedBaseNumber,
        },
      );
    } catch (e) {
      return MultiBaseNumberResult.error(
        algorithmName: '皇极取数法',
        algorithmDescription: '皇极取数法',
        calculationParams: params.description,
        errorMessage: e.toString(),
      );
    }
  }
}
```

### 3. 在ViewModel中使用

```dart
class MultiBaseNumberViewModel extends ChangeNotifier {
  MultiBaseNumberResult? _result;
  
  MultiBaseNumberResult? get result => _result;
  
  Future<void> calculateMultiBaseNumbers(params) async {
    try {
      _result = MultiBaseNumberResult.loading(
        algorithmName: '算法名称',
        algorithmDescription: '算法描述',
        calculationParams: params.toString(),
      );
      notifyListeners();
      
      final useCase = GetMultiBaseNumberUseCase();
      _result = await useCase.execute(params);
      notifyListeners();
    } catch (e) {
      _result = MultiBaseNumberResult.error(
        algorithmName: '算法名称',
        algorithmDescription: '算法描述',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
  
  // 获取特定来源的基础数
  List<BaseNumberModel> getBaseNumbersBySource(BaseNumberSource source) {
    return _result?.getBaseNumbersBySource(source) ?? [];
  }
  
  // 获取所有条文编号
  List<int> getAllTiaoWenNumbers() {
    return _result?.allTiaoWenNumbers ?? [];
  }
}
```

## 配置选项

### 条文列表生成配置

1. **默认配置**（固定列表）:
```dart
TiaoWenListCalculationConfig.listAdd(
  customList: [96, 192, 384, 768],
  withSub: true,
)
```

2. **倍数配置**:
```dart
TiaoWenListCalculationConfig.fromMultiples(
  baseNumber: 48,
  multipleList: [2, 4, 8, 16],
  withSub: true,
)
```

3. **循环配置**:
```dart
TiaoWenListCalculationConfig.loopAddTimes(
  baseNumber: 96,
  times: 7,
  withSub: false,
)
```

## 最佳实践

1. **直接创建**: 使用 `BaseNumberModel.create()` 和 `BaseNumberModel.withData()` 工厂方法创建模型
2. **异步数据加载**: 条文数据通过Repository异步加载，避免阻塞UI
3. **错误处理**: 使用 `MultiBaseNumberResult.error()` 统一处理错误状态
4. **状态管理**: 在ViewModel中使用 `MultiBaseNumberResult` 管理复杂的多基础数状态
5. **继承架构**: `MultiBaseNumberResult` 继承自 `BaseCalculationResult`，符合现有Strategy架构

## 扩展性

该模型系统具有良好的扩展性：

1. **新增基础数来源**: 在 `BaseNumberSource` 枚举中添加新类型
2. **新增算法支持**: 直接在UseCase中使用 `BaseNumberModel` 和 `MultiBaseNumberResult`
3. **自定义配置**: 支持自定义的条文列表生成配置
4. **灵活的数据结构**: 支持任意数量的基础数和条文列表
5. **架构兼容**: 继承自 `BaseCalculationResult`，与现有Strategy系统完全兼容

这个简化的设计移除了工厂模式的复杂性，同时保持了核心功能和扩展性，更符合项目的实际需求。