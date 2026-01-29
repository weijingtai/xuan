# Interactive Strategy & UseCase 架构设计

## 设计目标

基于现有的"Standard"模式Strategy和UseCase，设计"Interactive"版本，支持用户参与式的条文选择流程。

## 核心需求分析

### 用户交互流程
1. **初始计算** → 用户输入 → 基础条文数 → 展示条文内容
2. **用户确认** → 用户选择是否接受当前条文
3. **迭代调整** → 如不接受，按策略调整条文数（±30/±1/±5等）
4. **循环确认** → 重复直到用户确认
5. **批量优化** → 提供条文列表供用户选择

### 技术需求
- **边界**: 暂定无限大
- **动态配置**: 支持步长、范围动态调整
- **多条文对比**: 一次展示多个候选条文
- **中断恢复**: 支持会话保存和恢复
- **撤销功能**: 支持操作回退
- **跳转功能**: 支持直接跳转到指定条文
- **无限列表**: 支持全量条文展示

## 架构设计

### 1. Interactive Strategy 层

#### 1.1 基础接口扩展

```dart
/// Interactive Strategy 配置
class InteractiveStrategyConfig {
  /// 调整步长（如30、1、5等）
  final int stepSize;
  
  /// 候选条文数量（一次展示多少个）
  final int candidateCount;
  
  /// 调整方向（双向、仅增加、仅减少）
  final AdjustmentDirection direction;
  
  /// 边界限制（可选）
  final int? minBoundary;
  final int? maxBoundary;
  
  /// 是否支持跳转
  final bool allowJump;
  
  /// 是否支持自定义步长
  final bool allowCustomStep;
}

/// Interactive Strategy 基类
abstract class BaseInteractiveStrategy<TParams, TResult> 
    extends BaseCalculationStrategy<TParams, TResult> {
  
  /// 获取候选条文数列表
  /// [baseNumber] 基础条文数
  /// [config] 交互配置
  /// [currentStep] 当前调整步数（用于计算偏移）
  List<int> getCandidateNumbers(
    int baseNumber, 
    InteractiveStrategyConfig config,
    {int currentStep = 0}
  );
  
  /// 验证条文数是否在有效范围内
  bool isValidTiaoWenNumber(int number, InteractiveStrategyConfig config);
  
  /// 计算下一步的候选数字
  List<int> getNextCandidates(
    int currentNumber, 
    InteractiveStrategyConfig config,
    AdjustmentDirection direction
  );
}
```

### 2. Interactive UseCase 层

#### 2.1 交互会话管理

```dart
/// 交互会话状态
class InteractiveSession {
  /// 会话ID
  final String sessionId;
  
  /// 基础条文数
  final int baseNumber;
  
  /// 当前条文数
  final int currentNumber;
  
  /// 交互配置
  final InteractiveStrategyConfig config;
  
  /// 操作历史
  final List<InteractiveOperation> history;
  
  /// 候选条文列表
  final List<TiaoWenCandidate> candidates;
  
  /// 会话状态
  final InteractiveSessionState state;
}

/// 条文候选项
class TiaoWenCandidate {
  /// 条文数
  final int number;
  
  /// 条文内容
  final TiaoWenEntity entity;
  
  /// 与基础数的偏移
  final int offset;
  
  /// 调整步数
  final int stepCount;
  
  /// 是否为基础条文
  final bool isBase;
}
```

#### 2.2 Interactive UseCase 基类

```dart
/// Interactive UseCase 基类
abstract class BaseInteractiveUseCase<TParams> {
  
  /// 开始交互会话
  Future<InteractiveSession> startSession(
    TParams params,
    InteractiveStrategyConfig config
  );
  
  /// 获取候选条文列表
  Future<List<TiaoWenCandidate>> getCandidates(
    String sessionId,
    {int? centerNumber, int? stepOffset}
  );
  
  /// 选择条文（确认选择）
  Future<TiaoWenListResult> selectCandidate(
    String sessionId,
    int selectedNumber
  );
  
  /// 调整步长
  Future<InteractiveSession> adjustStep(
    String sessionId,
    int newStepSize
  );
  
  /// 跳转到指定条文
  Future<List<TiaoWenCandidate>> jumpTo(
    String sessionId,
    int targetNumber
  );
  
  /// 撤销操作
  Future<InteractiveSession> undo(String sessionId);
  
  /// 获取无限列表数据
  Stream<List<TiaoWenCandidate>> getInfiniteList(
    String sessionId,
    {int pageSize = 20}
  );
}
```

## 与现有架构的关系

### 复用现有组件
- **Standard Strategy**: Interactive Strategy内部调用标准Strategy进行基础计算
- **Repository**: 复用现有的TiaoWenRepository获取条文数据
- **Models**: 复用现有的TiaoWenEntity等模型

### 扩展点
- **配置系统**: 扩展TiaoWenListCalculationConfig支持交互式配置
- **状态管理**: 新增会话状态管理
- **UI组件**: 新增交互式UI组件

### 向后兼容
- 现有的Standard模式保持不变
- Interactive模式作为可选功能
- 可以在同一个应用中同时使用两种模式

## 实现计划

### 阶段1：核心接口和模型
1. 创建Interactive Strategy配置和基类
2. 创建Interactive Session相关模型
3. 创建Interactive UseCase基类

### 阶段2：Strategy层实现
1. 实现DayGanZhiGuaInteractiveStrategy
2. 实现FourZhuTianGanInteractiveStrategy  
3. 实现TaiXuanFourZhuInteractiveStrategy

### 阶段3：UseCase层实现
1. 实现会话管理Repository
2. 实现具体的Interactive UseCase
3. 添加无限列表支持

### 阶段4：ViewModel和UI层
1. 实现Interactive ViewModel基类和具体实现
2. 创建交互式UI组件
3. 集成到现有页面

## 总结

这个设计方案通过扩展现有的"Standard"模式，创建了"Interactive"版本的Strategy和UseCase，支持：

1. **用户参与式选择流程**
2. **动态配置和调整**
3. **会话管理和状态持久化**
4. **撤销和跳转功能**
5. **无限列表展示**
6. **与现有架构的良好集成**

设计遵循了现有的架构模式，保持了代码的一致性和可维护性。