# 经典算法Strategy转换任务对齐文档

## 项目上下文分析

### 现有项目架构
- **技术栈**: Dart/Flutter项目
- **模块结构**: 铁板神数计算系统，包含多种算法实现
- **现有Strategy架构**:
  - `BaseCalculationStrategy<P, R>`: 所有策略的基础抽象类
  - `StandardCalculationStrategy<P, R>`: 常规计算策略（无需用户交互）
  - `StrategyCategory`: 策略分类枚举（standard/interactive）
  - 参数基类: `BaseCalculationParams`
  - 结果基类: `BaseCalculationResult`

### 现有算法实现位置
- `service/classic/` 目录下包含6个经典算法
- 其中4个算法无需用户交互，可直接转换为StandardStrategy

## 原始需求分析

### 核心需求
将4个不需要用户参与的经典算法转换为Strategy模式：
1. `correct_time_and_ke_calculation.dart` - 定刻取数法
2. `day_gan_zhi_gua_calculation.dart` - 日柱变卦取数法  
3. `four_zhu_tian_gan_calculatioin.dart` - 四柱天干取数法
4. `tai_xuan_four_zhu_calculation.dart` - 太玄取数法（1）

### 技术要求
- 为每个算法创建符合当前架构的Parameters类
- 为每个算法创建符合当前架构的Result类
- **重要**: 计算结果应该都为一个数字（条文编号）
- 继承`StandardCalculationStrategy`基类

## 需求理解确认

### 边界确认
- **包含范围**: 仅转换4个无需用户交互的算法
- **排除范围**: 不包含需要用户确认的2个算法（tai_xuan_qian_hou_calculation、six_qin_correct_ke_calculation）
- **代码位置**: 新Strategy放在`service/strategy/`目录下

### 架构对齐
- 严格遵循现有Strategy架构模式
- 继承`StandardCalculationStrategy<P, R>`
- Parameters继承`BaseCalculationParams`
- Result继承`BaseCalculationResult`
- 实现`StrategyCategory.standard`分类

### 结果格式理解
- 用户强调"计算结果往往应该都为一个数字"
- 分析现有算法，它们都生成条文编号列表
- **需要澄清**: 是返回单个条文编号还是条文编号列表？

## 疑问澄清

### 关键决策点需要确认

1. **结果格式问题**:
   - 现有算法都返回条文编号列表（如`List<int> tiaoWenNumberList`）
   - 用户要求"结果应该都为一个数字"
   - **问题**: 是返回列表中的第一个数字，还是基础数字，还是需要其他逻辑？

2. **文件命名规范**:
   - 是否按照`[算法名]_strategy.dart`格式命名？
   - 如：`correct_time_and_ke_strategy.dart`

3. **依赖处理**:
   - 现有算法依赖`TiaowenCalculator`等工具类
   - 是否保持这些依赖，还是需要重构？

## 技术实现方案预览

### 基本结构模式
```dart
// Parameters类
class CorrectTimeAndKeParams extends BaseCalculationParams {
  final FourZhu fourZhu;
  // ...
}

// Result类  
class CorrectTimeAndKeResult extends BaseCalculationResult {
  final int tiaoWenNumber; // 单个数字结果
  // 或者
  final List<int> tiaoWenNumberList; // 列表结果
  // ...
}

// Strategy类
class CorrectTimeAndKeStrategy 
    extends StandardCalculationStrategy<CorrectTimeAndKeParams, CorrectTimeAndKeResult> {
  // 实现所有必需方法
}
```

## 待确认问题

**请确认以下关键决策点后继续：**

1. 计算结果格式：返回单个数字还是数字列表？如果是单个数字，应该取哪个值？
2. 文件命名规范确认
3. 是否需要保持对现有工具类的依赖？