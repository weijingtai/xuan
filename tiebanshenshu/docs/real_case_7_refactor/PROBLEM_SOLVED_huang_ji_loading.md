# 皇极交互页面"一直在准备中"问题解决报告

## 问题描述

皇极交互页面在启动会话后一直显示"准备中"状态，无法进入用户选择阶段。

## 问题根因 ✅ 已发现

**核心问题：** `HuangJiInteractiveStrategy.startSession` 方法中 `currentStep` 设置错误

**详细分析：**
1. 会话启动时，`currentStep` 被设置为 `HuangJiInteractiveStep.initialization.id`
2. 但初始化计算（初刻数、次条文数）在会话启动时已经完成
3. 应该直接进入 `HuangJiInteractiveStep.userSelection.id` 阶段
4. 由于 `needsUserSelection` 判断逻辑是 `_currentStep == HuangJiInteractiveStep.userSelection`
5. 当 `currentStep` 为 `initialization` 时，`needsUserSelection` 返回 `false`
6. 导致 `loadCandidates()` 方法未被调用
7. UI 进入等待状态，显示"准备中"

## 修复方案 ✅ 已修复

### 修复1：currentStep设置错误

**文件：** `lib/service/strategy/huang_ji_interactive_strategy.dart`

**修改内容：**
```dart
// 修改前
'currentStep': HuangJiInteractiveStep.initialization.id,

// 修改后  
'currentStep': HuangJiInteractiveStep.userSelection.id, // 初始化计算已完成，进入用户选择阶段
```

### 修复2：数据读取源错误

**文件：** `lib/presentation/viewmodels/huang_ji_interactive_view_model.dart`

**问题：** `_updateSessionData` 方法只从 `session.resultData` 读取数据，但数据存储在 `session.sessionConfig` 中

**修改内容：**
```dart
// 修改前：只从resultData读取
final data = session.resultData ?? {};
final currentStepId = data['currentStep'] as String?;

// 修改后：优先从resultData读取，如果没有则从sessionConfig读取
final configData = session.sessionConfig ?? {};
final resultData = session.resultData ?? {};
final currentStepId = resultData['currentStep'] as String? ?? 
                     configData['currentStep'] as String?;
```

## 调试过程

### 1. 添加调试日志
在以下组件中添加了详细的调试日志：
- `HuangJiInteractiveViewModel`
- `HuangJiInteractiveUseCase` 
- `HuangJiInteractiveStrategy`
- `HuangJiCalculationStrategy`
- `HuangJiInteractivePage`

### 2. 问题定位
通过调试日志发现：
- ViewModel 层的 `startSession` 方法正常完成
- 会话启动成功，但 `needsUserSelection` 为 `false`
- UI 进入 `_buildWaitingContent` 状态

### 3. 根因分析
追踪 `needsUserSelection` 的判断逻辑，发现 `currentStep` 设置错误。

## 业务逻辑说明

皇极取数法交互式计算的正确流程：

1. **初始化阶段** (`initialization`)：
   - 计算初刻数（基于年月日时的太玄数）
   - 计算次条文数
   - **在 `startSession` 时已完成**

2. **用户选择阶段** (`userSelection`)：
   - 展示次条文数和调整候选项
   - 用户选择基础数
   - **会话启动后应立即进入此阶段**

3. **最终计算阶段** (`finalCalculation`)：
   - 基于用户选择的基础数计算最终结果

4. **完成阶段** (`completed`)：
   - 展示计算结果

## 验证方法

1. 运行调试版本
2. 触发皇极交互计算
3. 观察调试日志：
   - 应该看到 `needsUserSelection: true`
   - 应该看到 `loadCandidates` 被调用
   - UI 应该显示候选项选择界面

## 相关文件

- `lib/service/strategy/huang_ji_interactive_strategy.dart` - 主要修复文件
- `lib/presentation/viewmodels/huang_ji_interactive_view_model.dart` - 状态管理
- `lib/presentation/pages/huang_ji_interactive_page.dart` - UI 显示
- `lib/domain/models/huang_ji_interactive_step.dart` - 步骤定义

## 总结

这是一个典型的状态管理问题，由于业务流程理解偏差导致的状态设置错误。修复后，皇极交互页面应该能够正常进入用户选择阶段。