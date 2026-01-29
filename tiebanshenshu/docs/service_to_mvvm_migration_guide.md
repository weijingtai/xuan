# Service 层到 MVVM+UseCase 架构迁移指南

## 概述

本文档详细说明如何将现有的 `service/*.dart` 代码迁移到标准的 MVVM+UseCase 架构。基于已完成的日干支卦、四柱天干、太玄四柱三个模块的成功迁移经验，提供可复制的迁移路径。

## 目标架构

## 迁移前准备

### 1. 分析现有Service结构
- 识别Service中的核心算法逻辑
- 确定输入参数和输出结果
- 梳理依赖关系和数据流

### 2. 确定迁移范围
- 单个算法策略为一个迁移单元
- 相关的计算逻辑保持在同一个Strategy中
- 确保迁移后功能完整性

## 详细迁移步骤

### 阶段1: Domain层重构 (Strategy模式)

#### 1.1 创建Strategy基础结构

**文件路径**: `lib/service/strategy/[algorithm_name]_strategy.dart`

```dart
/// [算法名称]Strategy实现
///
/// 将[算法名称]算法封装为标准计算策略
library;

import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// [算法名称]计算参数
class [AlgorithmName]StrategyParams extends BaseCalculationParams {
  // 定义所需的输入参数
  final InputType inputParam;

  [AlgorithmName]StrategyParams({required this.inputParam});

  @override
  String get description => "[算法名称]计算参数：参数描述($inputParam)";
}

/// [算法名称]计算结果
class [AlgorithmName]StrategyResult extends BaseCalculationResult {
  final int tiaoWenNumber; // 或其他结果类型

  [AlgorithmName]StrategyResult({required this.tiaoWenNumber});

  @override
  int get baseNumber => tiaoWenNumber;
}

/// [算法名称]计算策略
class [AlgorithmName]Strategy extends StandardCalculationStrategy<
    [AlgorithmName]StrategyParams,
    [AlgorithmName]StrategyResult> {
  
  @override
  String get name => "[算法中文名称]";

  @override
  String get description => "[算法详细描述]";

  @override
  List<String> get detailSteps => [
    "1. 步骤一描述",
    "2. 步骤二描述",
    // ... 更多步骤
  ];

  @override
  String get school => "[算法流派]";

  @override
  [AlgorithmName]StrategyResult calculate([AlgorithmName]StrategyParams params) {
    // 实现核心算法逻辑
    // 从原Service中迁移计算逻辑
    
    return [AlgorithmName]StrategyResult(tiaoWenNumber: result);
  }
}
```

#### 1.2 迁移核心算法逻辑

**关键原则**:
- 保持算法逻辑不变
- 移除UI相关代码
- 移除数据持久化逻辑
- 专注于纯计算功能

**示例迁移**:
```dart
// 原Service代码
class OriginalService {
  Future<List<TiaoWen>> calculateTiaoWenList(InputParams params) async {
    // 1. 参数验证
    // 2. 核心计算逻辑 ← 这部分迁移到Strategy
    // 3. 数据库查询 ← 这部分移到Repository
    // 4. UI状态更新 ← 这部分移到ViewModel
  }
}

// 迁移后Strategy代码
class NewStrategy {
  StrategyResult calculate(StrategyParams params) {
    // 只保留核心计算逻辑
    return StrategyResult(result: calculatedValue);
  }
}
```

### 阶段2: Application层实现 (UseCase模式)

#### 2.1 创建UseCase参数模型

**文件路径**: `lib/usecases/[algorithm_name]_tiao_wen_list_use_case.dart`

```dart
/// [算法名称]UseCase参数
class [AlgorithmName]UseCaseParams extends BaseUseCaseParams {
  final InputType inputParam;

  [AlgorithmName]UseCaseParams({required this.inputParam});

  @override
  String get description => "[算法名称]UseCase参数：$inputParam";
}
```

#### 2.2 实现UseCase核心逻辑

```dart
/// [算法名称]条文列表UseCase实现
class [AlgorithmName]TiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<[AlgorithmName]UseCaseParams> {
  
  final [AlgorithmName]Strategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  [AlgorithmName]TiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  String get name => '[算法名称]UseCase';

  @override
  String get description => '基于[算法名称]计算条文列表的UseCase';

  @override
  Future<TiaoWenListResult> execute(
    [AlgorithmName]UseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础条文
      final strategyParams = [AlgorithmName]StrategyParams(
        inputParam: params.inputParam,
      );
      final strategyResult = _strategy.calculate(strategyParams);
      final baseTiaoWenNumber = strategyResult.tiaoWenNumber;

      // 3. 根据基础条文和计算配置生成条文列表
      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;
      final tiaoWenIdList = effectiveConfig.calculateTiaoWenList(baseTiaoWenNumber);

      // 4. 从Repository获取条文数据
      final tiaoWenDataList = await _repository.getByIdsWithPageRange(
        ids: tiaoWenIdList,
        pageRange: [0, tiaoWenIdList.length - 1],
      );

      // 5. 构建返回结果
      return TiaoWenListResult(
        sourceData: TiaoWenListSourceData(
          algorithmName: name,
          inputParams: params.description,
          calculationConfig: effectiveConfig,
          baseNumber: baseTiaoWenNumber,
          calculatedIds: tiaoWenIdList,
        ),
        tiaoWenDataList: tiaoWenDataList,
        state: TiaoWenListState.success,
      );
    } catch (e) {
      // 异常处理
      return TiaoWenListResult.error(
        TiaoWenCalculationException('UseCase执行失败: $e'),
      );
    }
  }

  @override
  void validateParams([AlgorithmName]UseCaseParams params) {
    // 实现参数验证逻辑
    if (params.inputParam == null) {
      throw InvalidParamsException('输入参数不能为空');
    }
  }
}
```

### 阶段3: Presentation层实现 (ViewModel模式)

#### 3.1 创建ViewModel

**文件路径**: `lib/presentation/viewmodels/[algorithm_name]_view_model.dart`

```dart
/// [算法名称]条文列表ViewModel
class [AlgorithmName]ViewModel extends BaseTiaoWenListViewModel {
  final [AlgorithmName]TiaoWenListUseCase _useCase;

  /// 当前选择的输入参数
  InputType? _selectedInput;

  [AlgorithmName]ViewModel(this._useCase);

  @override
  String get name => '[算法名称]ViewModel';

  @override
  String get description => '基于[算法名称]计算条文列表的ViewModel';

  /// 当前选择的输入参数
  InputType? get selectedInput => _selectedInput;

  /// 设置输入参数并计算条文列表
  Future<void> setInput(InputType input) async {
    _selectedInput = input;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  Future<void> calculateTiaoWenList({
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    if (_selectedInput == null) {
      return;
    }

    await executeUseCase(() async {
      final params = [AlgorithmName]UseCaseParams(inputParam: _selectedInput!);
      return await _useCase.execute(params, calculationConfig: calculationConfig);
    });
  }
}
```

### 阶段4: Infrastructure层配置 (依赖注入)

#### 4.1 更新Provider配置

**文件路径**: `lib/infrastructure/di/strategy_providers.dart`

```dart
// 添加新的Strategy、UseCase和ViewModel配置
static List<SingleChildWidget> get providers => [
  // 现有配置...

  // 新Strategy
  Provider<[AlgorithmName]Strategy>(
    create: (_) => [AlgorithmName]Strategy(),
  ),

  // 新UseCase
  Provider<[AlgorithmName]TiaoWenListUseCase>(
    create: (context) => [AlgorithmName]TiaoWenListUseCase(
      context.read<[AlgorithmName]Strategy>(),
      context.read<TiaoWenRepository>(),
      context.read<TiaoWenListCalculationConfig>(),
    ),
  ),

  // 新ViewModel
  ChangeNotifierProvider<[AlgorithmName]ViewModel>(
    create: (context) => [AlgorithmName]ViewModel(
      context.read<[AlgorithmName]TiaoWenListUseCase>(),
    ),
  ),
];
```

### 阶段5: UI层集成

#### 5.1 创建或更新UI页面

```dart
class [AlgorithmName]Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<[AlgorithmName]ViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('[算法名称]')),
          body: Column(
            children: [
              // 输入参数选择UI
              _buildInputSelector(context, viewModel),
              
              // 结果显示UI
              _buildResultDisplay(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputSelector(BuildContext context, [AlgorithmName]ViewModel viewModel) {
    // 实现输入参数选择UI
  }

  Widget _buildResultDisplay(BuildContext context, [AlgorithmName]ViewModel viewModel) {
    // 实现结果显示UI
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    
    if (viewModel.hasError) {
      return ErrorWidget(viewModel.errorMessage);
    }
    
    if (viewModel.hasResult) {
      return TiaoWenListWidget(viewModel.uiResult);
    }
    
    return EmptyStateWidget();
  }
}
```

## 迁移检查清单

### 代码质量检查
- [ ] Strategy实现了标准接口
- [ ] UseCase继承了BaseGetTiaoWenListUseCase
- [ ] ViewModel继承了BaseTiaoWenListViewModel
- [ ] 所有类都有完整的文档注释
- [ ] 参数验证逻辑完整
- [ ] 异常处理机制完善

### 功能完整性检查
- [ ] 核心算法逻辑迁移完整
- [ ] 输入参数验证正确
- [ ] 输出结果格式一致
- [ ] 错误处理覆盖全面
- [ ] 性能表现符合预期

### 架构一致性检查
- [ ] 依赖注入配置正确
- [ ] 层次分离清晰
- [ ] 接口定义标准
- [ ] 命名规范统一
- [ ] 文件组织合理

### 集成测试检查
- [ ] Provider配置无冲突
- [ ] UI集成正常
- [ ] 数据流转正确
- [ ] 状态管理稳定
- [ ] 用户体验良好

## 常见问题和解决方案

### 1. 复杂算法拆分
**问题**: 原Service包含多个相关算法
**解决**: 按算法职责拆分为多个Strategy，通过UseCase组合

### 2. 状态管理复杂
**问题**: 原Service管理复杂的UI状态
**解决**: 使用BaseTiaoWenListViewModel提供的标准状态管理

### 3. 数据依赖处理
**问题**: 算法需要多种数据源
**解决**: 通过Repository接口抽象，UseCase中组合多个Repository

### 4. 性能优化
**问题**: 迁移后性能下降
**解决**: 
- Strategy中避免重复计算
- UseCase中实现结果缓存
- ViewModel中优化状态更新频率

### 5. 测试覆盖
**问题**: 迁移后测试用例失效
**解决**:
- Strategy层：单元测试核心算法
- UseCase层：集成测试业务流程
- ViewModel层：状态变化测试

## 迁移时间估算

### 简单算法 (1-2天)
- 单一输入输出
- 逻辑相对简单
- 无复杂依赖

### 中等复杂算法 (3-5天)
- 多个输入参数
- 中等复杂逻辑
- 少量外部依赖

### 复杂算法 (5-10天)
- 复杂输入验证
- 多步骤计算逻辑
- 多个数据源依赖

## 成功案例参考

### 已完成迁移的模块
1. **日干支卦条文列表** (`DayGanZhiGuaTiaoWenListUseCase`)
2. **四柱天干条文列表** (`FourZhuTianGanTiaoWenListUseCase`)
3. **太玄四柱条文列表** (`TaiXuanFourZhuTiaoWenListUseCase`)

### 参考文件路径
- Strategy: `lib/service/strategy/[algorithm_name]_strategy.dart`
- UseCase: `lib/usecases/[algorithm_name]_tiao_wen_list_use_case.dart`
- ViewModel: `lib/presentation/viewmodels/[algorithm_name]_view_model.dart`
- Provider: `lib/infrastructure/di/strategy_providers.dart`

## 总结

通过遵循本迁移指南，可以系统性地将现有Service层代码迁移到标准的MVVM+UseCase架构。关键成功因素包括：

1. **分层清晰**: 严格按照架构层次分离关注点
2. **接口标准**: 使用统一的基类和接口
3. **渐进迁移**: 按模块逐步迁移，确保稳定性
4. **充分测试**: 每个层次都有对应的测试覆盖
5. **文档完善**: 保持代码注释和文档的完整性

遵循这个路径，可以确保迁移后的代码具有更好的可维护性、可测试性和可扩展性。