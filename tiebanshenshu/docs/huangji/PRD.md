# 皇极取数法 V2 架构 - 产品需求文档 (PRD)

**版本**: 2.0
**文档创建日期**: 2025-10-06
**最后更新**: 2025-10-06
**状态**: 已实现 ✅
**负责人**: Claude Code

---

## 1. 产品概述

### 1.1 产品简介

皇极取数法 V2 是铁板神数计算系统的核心模块，实现了基于会话管理的完整计算流程。该系统支持：
- 多公式并行计算
- 基础数去重选择
- 会话状态管理
- 完整的回滚机制
- 候选数智能生成

### 1.2 核心价值

**传统痛点**:
1. 用户需要重复选择相同的基础数定义
2. 计算过程无法保存和恢复
3. 选择错误后无法回退
4. 不支持多公式批量计算

**V2架构解决方案**:
1. ✅ 基于name的去重逻辑 - 同名基础数只选择一次
2. ✅ 完整的会话管理 - 支持保存/加载/回滚
3. ✅ 阶段化流程控制 - 清晰的状态转换
4. ✅ 批量公式计算 - 一次选择，计算所有公式

---

## 2. 用户场景

### 2.1 主要用户角色

**铁板神数实践者**
- 需要快速计算多个公式的条文结果
- 需要在不同候选数之间进行选择
- 需要保存计算会话供后续分析

### 2.2 核心用户故事

#### 用户故事 1: 完整计算流程

**作为** 铁板神数实践者
**我想要** 输入八字后自动生成所有公式的候选条文
**以便** 快速找到最合适的条文

**接受标准**:
- [x] 系统自动加载所有可用公式（3个）
- [x] 自动计算元会运世
- [x] 生成去重后的基础数选择列表
- [x] 每个选择项显示21个候选数（前后各10个）
- [x] 显示完整的条文内容而非仅编号
- [x] 最终生成29条结果（13+8+8）

#### 用户故事 2: 基础数选择去重

**作为** 用户
**我想要** 相同名称的基础数只选择一次
**以便** 节省时间并保证一致性

**接受标准**:
- [x] 系统自动识别同名基础数定义
- [x] UI上只显示去重后的选择项
- [x] 选择结果自动应用到所有使用该基础数的组
- [x] 显示该定义被哪些组使用（relatedGroupIds）

#### 用户故事 3: 会话回滚

**作为** 用户
**我想要** 在选择错误后能回到之前的阶段
**以便** 重新选择而不用从头开始

**接受标准**:
- [x] 系统在每个阶段自动创建快照
- [x] 支持回滚到任意历史阶段
- [x] 回滚后保留该阶段的所有数据
- [x] 可重新进行后续操作

---

## 3. 功能需求

### 3.1 核心功能模块

#### 3.1.1 会话管理 (Session Management)

**功能描述**: 管理完整的计算会话生命周期

**子功能**:

1. **创建会话**
   - 输入: 八字 (EightChars), 公式列表 (List<Formula>)
   - 输出: 新会话 (HuangJiSession)
   - 自动生成唯一会话ID
   - 初始状态: `initialized`

2. **保存会话**
   - 支持会话持久化（当前使用内存存储）
   - 包含完整状态的JSON序列化

3. **加载会话**
   - 根据sessionId恢复会话
   - 完整恢复所有状态和历史

4. **快照管理**
   - 在每个阶段转换时自动创建快照
   - 快照包含完整会话状态
   - 支持通过snapshotId回滚

#### 3.1.2 元会运世计算

**功能描述**: 根据八字自动计算元会运世基础数

**计算逻辑**:
```
元 = 年干支相加
会 = 月干支相加
运 = 日干支相加
世 = 时干支相加
```

**输出字段**:
- `yuanNumber`: 元数
- `huiNumber`: 会数
- `yunNumber`: 运数
- `shiNumber`: 世数
- `yuanHuiMergeNumber`: 元会互合数
- `yunShiMergeNumber`: 运世互合数

#### 3.1.3 基础数选择准备

**功能描述**: 生成去重后的基础数候选列表

**核心流程**:

1. **遍历所有公式的所有组**
   ```
   for formula in formulas:
     for group in formula.groups:
       baseNumberDefinition = group.baseNumberDefinition
   ```

2. **判断是否需要用户选择**

   V2架构中,所有类型的基础数都需要用户选择:
   - `PredefinedBaseNumber`: 需要选择 ✅ (提供以预定义值为中心的候选列表)
   - `DerivedBaseNumber`: 需要选择 ✅ (基于派生计算的初始值生成候选列表)
   - `SelectableBaseNumber`: 需要选择 ✅ (包装其他定义类型)

3. **基于name进行去重**
   ```dart
   final definitionId = baseNumDef.name;  // 使用name作为唯一标识
   if (uniqueDefinitions.containsKey(definitionId)) {
     continue;  // 跳过重复定义
   }
   ```

4. **记录关联关系**
   ```dart
   definitionToGroups[definitionId].add(group.groupId);
   ```

5. **生成候选数列表**
   - 计算初始基础数
   - 使用配置生成候选数: `initialNumber ± offset*N`
   - 默认配置: offset=30, count=10 (前后各10个)
   - 范围限制: 1000-13000

6. **批量获取条文内容**
   ```dart
   final tiaoWenContentMap = await repository.getTiaoWenContentByNumbers(numbers);
   ```

**输出数据结构**:
```dart
BaseNumberSelectionBatch {
  items: [
    BaseNumberSelectionItem {
      definitionId: "元会·基础数一",
      name: "元会·基础数一",
      description: "...",
      derivationChain: DerivationChain,
      candidates: [
        BaseNumberCandidate {
          number: 5000,
          tiaoWenContent: "条文内容...",
          offset: 0
        },
        // ... 共21个候选
      ],
      relatedGroupIds: ["group1", "group3"]  // 显示该定义被哪些组使用
    },
    // ... 更多选择项
  ]
}
```

#### 3.1.4 用户选择提交

**功能描述**: 验证并保存用户的基础数选择

**验证规则**:
1. 所有必需的基础数都已选择
2. 选择的候选数在有效范围内
3. 选择的候选数存在于候选列表中

**状态更新**:
- 更新 `baseNumberSelections` 中的 `selectedCandidate`
- 将 `status` 从 `pending` 改为 `completed`
- 推进到下一阶段

#### 3.1.5 最终条文计算

**功能描述**: 基于用户选择计算所有公式的所有条文

**计算流程**:

```dart
results = []
for formula in session.formulas:           // 遍历所有公式
  for group in formula.groups:             // 遍历每个公式的所有组
    baseNumber = userSelection[group.baseNumberDefinition.name]

    for tiaoWenFormula in group.formulas:  // 遍历每个组的所有条文公式
      tiaoWenNumber = calculate(baseNumber, tiaoWenFormula)
      tiaoWenContent = getTiaoWenContent(tiaoWenNumber)
      results.add(TiaoWenResult)
```

**关键点**:
- ✅ 不会因为去重而跳过任何计算
- ✅ 每个组都独立计算自己的条文
- ✅ 同名基础数使用相同的用户选择值

**输出示例**:
```
公式1:
  元会·基础数一 (5030) → [条文1, 条文2, ..., 条文8]  // 8条
  运世基础数 (6789) → [条文9, ..., 条文13]         // 5条

公式2:
  元会·基础数一 (5030) → [条文14, ..., 条文17]    // 4条
  运世·基础数一 (7890) → [条文18, ..., 条文21]    // 4条

公式3:
  元会·基础数一 (5030) → [条文22, 条文23]        // 2条
  元会·基础数二 (5100) → [条文24, 条文25]        // 2条
  运世·基础数一 (7890) → [条文26, 条文27]        // 2条
  运世·基础数二 (7960) → [条文28, 条文29]        // 2条

总计: 29条结果
```

### 3.2 会话状态机

#### 3.2.1 阶段定义 (SessionPhase)

```dart
enum SessionPhase {
  initialized,                  // 初始化完成
  yuanHuiYunShiCalculated,     // 元会运世已计算
  baseNumberSelectionReady,    // 基础数选择准备完成
  baseNumberSelected,          // 基础数已选择
  finalCalculationComplete     // 最终计算完成
}
```

#### 3.2.2 状态定义 (HuangJiSessionStatus)

```dart
enum HuangJiSessionStatus {
  notStarted,           // 未开始
  inProgress,           // 进行中
  waitingForSelection,  // 等待用户选择
  paused,               // 暂停
  completed,            // 完成
  cancelled,            // 取消
  error                 // 错误
}
```

#### 3.2.3 阶段转换规则

```
initialized → yuanHuiYunShiCalculated → baseNumberSelectionReady
    → baseNumberSelected → finalCalculationComplete
```

**验证规则**:
- 只能按顺序向前推进
- 回滚可以跳转到任意历史阶段
- 每次转换都创建快照

### 3.3 数据模型

#### 3.3.1 核心模型

**HuangJiSession** - 会话主模型
```dart
class HuangJiSession {
  final String sessionId;
  final String sessionName;
  final EightChars eightChars;
  final List<HuangJiCalculationFormula> formulas;  // 支持多公式
  final YuanHuiYunShi? yuanHuiYunShi;
  final Map<String, BaseNumberSelectionRecord> baseNumberSelections;
  final List<TiaoWenResult>? finalTiaoWenList;
  final SessionPhase currentPhase;
  final HuangJiSessionStatus status;
  final List<SessionSnapshot> phaseHistory;
  final DateTime startTime;
  final DateTime lastActivityAt;
  final DateTime? endTime;
  final String? errorMessage;
}
```

**BaseNumberSelectionRecord** - 选择记录
```dart
class BaseNumberSelectionRecord {
  final String baseNumberDefinitionId;  // 使用name作为ID
  final String name;
  final BaseNumberDerivationChain derivationChain;
  final CandidateGenerationConfig candidateConfig;
  final List<BaseNumberCandidate> candidates;
  final BaseNumberCandidate? selectedCandidate;
  final SelectionStatus status;
  final List<String> relatedGroupIds;  // 关联的组ID列表
}
```

**BaseNumberDerivationChain** - 派生链
```dart
class BaseNumberDerivationChain {
  final DataPredefinedBaseNumber source;        // 源头（元/会/运/世）
  final List<DerivationStep> derivationSteps;   // 派生步骤
  final DataBaseNumberDefinition finalDefinition;

  int get finalValue {
    int value = source.number;
    for (final step in derivationSteps) {
      value += step.value;
    }
    return value;
  }

  String getFullPath() {
    // "元(1234) → +年干*1000(5000) → 元会·基础数一(6234)"
  }
}
```

**TiaoWenResult** - 条文结果
```dart
class TiaoWenResult {
  final String groupId;
  final String formulaName;
  final int baseNumber;
  final int tiaoWenNumber;
  final String tiaoWenContent;
  final String calculationDetail;
}
```

#### 3.3.2 候选数生成配置

```dart
class CandidateGenerationConfig {
  final int initialNumber;  // 初始数
  final int offset;         // 步长（默认30）
  final int count;          // 前后各生成数量（默认10）
  final int minValue;       // 最小值（默认1000）
  final int maxValue;       // 最大值（默认13000）
}

// 生成结果示例 (initialNumber=5000, offset=30, count=10):
// [4700, 4730, 4760, ..., 4970, 5000, 5030, ..., 5270, 5300]
```

---

## 4. 技术架构

### 4.1 架构层次

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │   ViewModel  │ ◄────── │   Page (UI)     │  │
│  │  (Flutter    │         │   (Widgets)     │  │
│  │   Provider)  │         │                 │  │
│  └──────┬───────┘         └─────────────────┘  │
└─────────┼──────────────────────────────────────┘
          │
┌─────────▼──────────────────────────────────────┐
│           Application Layer                     │
│  ┌──────────────────────────────────────────┐  │
│  │    HuangJiV2UseCase                      │  │
│  │  - initializeSession()                   │  │
│  │  - prepareBaseNumberSelection() ★核心★   │  │
│  │  - submitBaseNumberSelections()          │  │
│  │  - calculateFinalTiaoWenList()           │  │
│  │  - rollbackToPhase()                     │  │
│  └─────┬────────────────────────────────────┘  │
│        │                                        │
│  ┌─────▼─────────────────────┐                 │
│  │  HuangJiSessionManager    │                 │
│  │  - 会话生命周期管理        │                 │
│  │  - 阶段转换与验证          │                 │
│  │  - 快照创建与回滚          │                 │
│  └─────┬─────────────────────┘                 │
└────────┼──────────────────────────────────────┘
         │
┌────────▼──────────────────────────────────────┐
│              Domain Layer                      │
│  ┌──────────────────────────────────────────┐ │
│  │  Data Models                             │ │
│  │  - HuangJiSession (会话模型)             │ │
│  │  - BaseNumberSelectionRecord             │ │
│  │  - BaseNumberDerivationChain             │ │
│  │  - TiaoWenResult                         │ │
│  │  - SessionSnapshot                       │ │
│  └──────────────────────────────────────────┘ │
└───────────────────────────────────────────────┘
         │
┌────────▼──────────────────────────────────────┐
│          Infrastructure Layer                  │
│  ┌──────────────┐    ┌────────────────────┐   │
│  │  Strategy    │    │   Repository       │   │
│  │  - 计算逻辑  │    │   - 数据持久化     │   │
│  │  - 候选生成  │    │   - 会话存储       │   │
│  │  - 派生链    │    │   - 条文查询       │   │
│  └──────────────┘    └────────────────────┘   │
└───────────────────────────────────────────────┘
```

### 4.2 关键组件

#### 4.2.1 HuangJiV2UseCase

**职责**: 核心业务逻辑编排

**关键方法**:
1. `initializeSession()` - 创建会话并计算元会运世
2. `prepareBaseNumberSelection()` - **核心去重逻辑**
3. `submitBaseNumberSelections()` - 验证并保存用户选择
4. `calculateFinalTiaoWenList()` - 计算所有条文
5. `rollbackToPhase()` - 回滚到指定阶段

**去重算法伪代码**:
```python
uniqueDefinitions = {}
definitionToGroups = {}

for formula in session.formulas:
    for group in formula.groups:
        baseNumDef = group.baseNumberDefinition
        definitionId = baseNumDef.name  # 使用name作为唯一标识

        # 记录该定义被哪些组使用
        definitionToGroups[definitionId].append(group.groupId)

        # 去重：已处理过的跳过
        if definitionId in uniqueDefinitions:
            continue

        # 为该定义生成候选数...
        candidates = generateCandidates(baseNumDef)
        uniqueDefinitions[definitionId] = SelectionItem(
            definitionId=definitionId,
            candidates=candidates,
            relatedGroupIds=definitionToGroups[definitionId]
        )

return uniqueDefinitions.values()
```

#### 4.2.2 HuangJiSessionManager

**职责**: 会话生命周期和状态管理

**核心功能**:
- 创建/保存/加载会话
- 阶段转换验证
- 自动创建快照
- 回滚到历史快照

**阶段转换验证**:
```dart
void _validatePhaseTransition(SessionPhase current, SessionPhase target) {
  final validTransitions = {
    SessionPhase.initialized: [SessionPhase.yuanHuiYunShiCalculated],
    SessionPhase.yuanHuiYunShiCalculated: [SessionPhase.baseNumberSelectionReady],
    SessionPhase.baseNumberSelectionReady: [SessionPhase.baseNumberSelected],
    SessionPhase.baseNumberSelected: [SessionPhase.finalCalculationComplete],
  };

  if (!validTransitions[current]?.contains(target) ?? true) {
    throw InvalidPhaseTransitionException(current, target);
  }
}
```

#### 4.2.3 HuangJiV2CalculationStrategy

**职责**: 纯计算逻辑（无状态）

**核心方法**:
1. `calculateYuanHuiYunShi()` - 计算元会运世
2. `generateCandidates()` - 生成候选数列表
3. `calculateDerivedBaseNumber()` - 计算派生基础数
4. `buildDerivationChain()` - 构建派生链路
5. `calculateTiaoWenNumber()` - 计算条文数

---

## 5. 界面设计

### 5.1 主界面流程

```
┌─────────────────────────────────────────┐
│  皇极取数法 V2 演示 - 所有公式          │
│  [🔄 刷新]                              │
├─────────────────────────────────────────┤
│                                         │
│  [阶段指示器]                           │
│  ● 初始化 → ● 元会运世 → ○ 准备选择    │
│    → ○ 已选择 → ○ 完成                 │
│                                         │
│  [会话信息卡片]                         │
│  会话: 测试会话 - 所有公式              │
│  元: 1234                               │
│  会: 5678                               │
│  运: 9012                               │
│  世: 3456                               │
│                                         │
│  [操作按钮]                             │
│  [准备基础数选择]                       │
│                                         │
└─────────────────────────────────────────┘
```

### 5.2 选择界面

```
┌─────────────────────────────────────────┐
│  需要选择 4 个基础数（已去重）          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 元会·基础数一 ⭐                 │  │
│  │ 元会数 + 年干(千位）= 条文数     │  │
│  │ 推导链: 元会(5678) → +年干*1000 │  │
│  │         (4000) → 9678            │  │
│  │ 应用于组: group1, group3, group5 │  │
│  │                                  │  │
│  │ 请从以下条文中选择一个 (共21个): │  │
│  │                                  │  │
│  │ ○ 编号: 9378                    │  │
│  │   男命先贫后富渐入佳境...        │  │
│  │                                  │  │
│  │ ○ 编号: 9408                    │  │
│  │   夫妻宫平顺但需注意沟通...      │  │
│  │                                  │  │
│  │ ● 编号: 9438 ✓                  │  │
│  │   事业有成财运亨通贵人相助...    │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  [更多选择项...]                        │
│                                         │
│  [提交选择 (4/4)] ✓                    │
│                                         │
└─────────────────────────────────────────┘
```

### 5.3 结果展示

```
┌─────────────────────────────────────────┐
│  ✅ 计算完成！共 29 条结果              │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 年支(千位数）                    │  │
│  │ 基础数: 9438                     │  │
│  │ 条文数: 12345                    │  │
│  │ 条文内容: 男命先贫后富...        │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 月支(百位数）                    │  │
│  │ 基础数: 9438                     │  │
│  │ 条文数: 12456                    │  │
│  │ 条文内容: 夫妻宫平顺...          │  │
│  └──────────────────────────────────┘  │
│                                         │
│  [... 共29条 ...]                       │
│                                         │
└─────────────────────────────────────────┘
```

---

## 6. 数据流

### 6.1 完整流程数据流

```
用户输入八字
    ↓
[ViewModel] initializeSession()
    ↓
[UseCase] 创建Session + 计算元会运世
    ↓
[Manager] 保存Session + 推进到yuanHuiYunShiCalculated
    ↓
用户点击"准备基础数选择"
    ↓
[ViewModel] prepareBaseNumberSelection()
    ↓
[UseCase] 遍历所有公式 → 去重 → 生成候选数 → 批量获取条文
    ↓
[Manager] 推进到baseNumberSelectionReady
    ↓
[UI] 显示选择界面（去重后的列表）
    ↓
用户选择基础数
    ↓
[ViewModel] submitSelections(Map<定义ID, 选择的数值>)
    ↓
[UseCase] 验证选择 → 更新Session
    ↓
[Manager] 推进到baseNumberSelected
    ↓
用户点击"计算最终条文"
    ↓
[ViewModel] calculateFinalTiaoWenList()
    ↓
[UseCase] 遍历所有公式的所有组 → 使用用户选择 → 计算每个条文
    ↓
[Manager] 推进到finalCalculationComplete
    ↓
[UI] 显示29条结果
```

### 6.2 去重逻辑数据流

```
输入: session.formulas (3个公式)

公式1: {
  组1: { name: "元会·基础数一", formulas: 8条 }
  组2: { name: "运世基础数", formulas: 5条 }
}

公式2: {
  组1: { name: "元会·基础数一", formulas: 4条 }  ← 重复
  组2: { name: "运世·基础数一", formulas: 4条 }
}

公式3: {
  组1: { name: "元会·基础数一", formulas: 2条 }  ← 重复
  组2: { name: "元会·基础数二", formulas: 2条 }
  组3: { name: "运世·基础数一", formulas: 2条 }  ← 重复
  组4: { name: "运世·基础数二", formulas: 2条 }
}

↓ 去重处理

唯一定义: {
  "元会·基础数一": {
    relatedGroupIds: ["公式1-组1", "公式2-组1", "公式3-组1"],
    candidates: 21个
  },
  "运世基础数": {
    relatedGroupIds: ["公式1-组2"],
    candidates: 21个
  },
  "运世·基础数一": {
    relatedGroupIds: ["公式2-组2", "公式3-组3"],
    candidates: 21个
  },
  "元会·基础数二": {
    relatedGroupIds: ["公式3-组2"],
    candidates: 21个
  },
  "运世·基础数二": {
    relatedGroupIds: ["公式3-组4"],
    candidates: 21个
  }
}

输出: 5个选择项（UI上显示）

用户选择:
  "元会·基础数一" → 5030
  "运世基础数" → 6789
  "运世·基础数一" → 7890
  "元会·基础数二" → 5100
  "运世·基础数二" → 7960

↓ 计算阶段（不去重，所有组都计算）

公式1-组1: 用5030计算 → 8条结果
公式1-组2: 用6789计算 → 5条结果
公式2-组1: 用5030计算 → 4条结果 (使用相同的选择值)
公式2-组2: 用7890计算 → 4条结果
公式3-组1: 用5030计算 → 2条结果 (使用相同的选择值)
公式3-组2: 用5100计算 → 2条结果
公式3-组3: 用7890计算 → 2条结果 (使用相同的选择值)
公式3-组4: 用7960计算 → 2条结果

总计: 29条结果
```

---

## 7. 非功能需求

### 7.1 性能要求

| 指标 | 目标值 | 测量方法 |
|------|--------|----------|
| 会话初始化时间 | < 500ms | 从调用到完成 |
| 候选数生成时间 | < 2s | 包含批量条文查询 |
| 最终计算时间 | < 3s | 29条结果 |
| 快照创建时间 | < 100ms | JSON序列化 |
| 回滚恢复时间 | < 200ms | JSON反序列化 |

### 7.2 数据要求

**会话数据大小估算**:
- 基础会话信息: ~2KB
- 元会运世数据: ~1KB
- 每个选择项（含21个候选）: ~10KB
- 5个选择项: ~50KB
- 29条最终结果: ~15KB
- **总计: ~68KB**

**存储要求**:
- 支持100个活跃会话
- 总存储: ~6.8MB（可接受）

### 7.3 可靠性要求

1. **数据完整性**
   - ✅ 所有模型支持JSON序列化/反序列化
   - ✅ 快照包含完整状态
   - ✅ 阶段转换原子性

2. **错误处理**
   - ✅ 无效阶段转换抛出异常
   - ✅ 缺失选择抛出异常
   - ✅ 条文缺失显示"（条文缺失）"

3. **状态一致性**
   - ✅ 阶段与数据状态一致
   - ✅ 回滚完整恢复状态

### 7.4 可扩展性

**已支持的扩展点**:

1. **存储层可替换**
   ```dart
   abstract class SessionRepository {
     Future<void> saveSession(HuangJiSession session);
     Future<HuangJiSession?> loadSession(String sessionId);
     // ... 可实现: 文件存储、数据库存储、云存储
   }
   ```

2. **计算策略可替换**
   ```dart
   abstract class HuangJiV2CalculationStrategy {
     YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars);
     // ... 可实现不同的计算算法
   }
   ```

3. **候选数生成可配置**
   ```dart
   CandidateGenerationConfig(
     offset: 30,   // 可调整步长
     count: 10,    // 可调整数量
     minValue: 1000,
     maxValue: 13000,
   )
   ```

---

## 8. 测试要求

### 8.1 单元测试

**已完成** ✅ (9/9 通过)

测试文件: `test/features/huang_ji_v2_models_test.dart`

覆盖范围:
- ✅ 候选配置验证
- ✅ 候选数偏移追踪
- ✅ 会话阶段枚举
- ✅ 会话状态枚举
- ✅ 派生步骤描述
- ✅ 选择状态枚举
- ✅ 快照时间戳
- ✅ 记录copyWith更新
- ✅ 阶段转换规则

### 8.2 集成测试需求

**待实现**:

1. **完整流程测试**
   ```dart
   test('完整流程: 初始化 → 选择 → 计算', () async {
     // 1. 初始化
     final session = await useCase.initializeSession(...);
     expect(session.currentPhase, SessionPhase.yuanHuiYunShiCalculated);

     // 2. 准备选择
     final session2 = await useCase.prepareBaseNumberSelection(session);
     expect(session2.baseNumberSelections.length, 5);

     // 3. 提交选择
     final session3 = await useCase.submitBaseNumberSelections(...);

     // 4. 计算结果
     final session4 = await useCase.calculateFinalTiaoWenList(session3);
     expect(session4.finalTiaoWenList.length, 29);
   });
   ```

2. **去重逻辑测试**
   ```dart
   test('去重: 同名基础数只生成一次候选', () async {
     final batch = await useCase.prepareBaseNumberSelection(session);

     // 验证"元会·基础数一"只有一个选择项
     final items = batch.items.where((i) => i.name == "元会·基础数一");
     expect(items.length, 1);

     // 验证关联了3个组
     expect(items.first.relatedGroupIds.length, 3);
   });
   ```

3. **回滚测试**
   ```dart
   test('回滚: 可以回到任意阶段', () async {
     // ... 完成所有阶段
     final completedSession = ...;

     // 回滚到选择阶段
     final rolledBack = await useCase.rollbackToPhase(
       session: completedSession,
       targetPhase: SessionPhase.baseNumberSelectionReady,
     );

     expect(rolledBack.currentPhase, SessionPhase.baseNumberSelectionReady);
     expect(rolledBack.finalTiaoWenList, isEmpty);
   });
   ```

### 8.3 UI测试需求

**待实现**:

1. 选择界面显示正确的候选数数量
2. 提交按钮在未完成选择时禁用
3. 结果列表显示29条
4. 阶段指示器正确更新

---

## 9. 发布计划

### 9.1 当前状态 (v2.0)

**已完成功能** ✅:
- ✅ 完整的会话管理
- ✅ 元会运世计算
- ✅ 基础数去重选择
- ✅ 候选数生成（21个）
- ✅ 条文内容显示
- ✅ 最终计算（29条结果）
- ✅ 快照和回滚
- ✅ 基础UI界面

**已知限制**:
- ⚠️ 使用内存存储（会话不持久化）
- ⚠️ 仅支持web-server模式测试
- ⚠️ 缺少完整的集成测试

### 9.2 未来版本规划

#### v2.1 - 持久化支持
- [ ] 实现文件存储Repository
- [ ] 支持会话保存/加载
- [ ] 会话列表管理

#### v2.2 - UI增强
- [ ] 更美观的选择界面
- [ ] 条文内容搜索/过滤
- [ ] 结果导出功能（PDF/Excel）

#### v2.3 - 高级功能
- [ ] 多八字批量计算
- [ ] 历史会话对比
- [ ] 自定义候选数配置界面

---

## 10. 附录

### 10.1 术语表

| 术语 | 解释 |
|------|------|
| 八字 | 年月日时的天干地支组合 |
| 元会运世 | 基于八字计算的四个基础数 |
| 基础数 | 用于计算条文的核心数值 |
| 条文 | 铁板神数的预测文本 |
| 去重 | 基于name识别相同定义，避免重复选择 |
| 派生链 | 从源头（元/会/运/世）到最终基础数的推导过程 |
| 候选数 | 围绕初始值生成的可选数值列表 |
| 会话快照 | 某个阶段的完整状态存档 |

### 10.2 公式文件说明

**huang_ji_1_formula.json**:
- 2个组，13条结果
- 包含predefined和derived类型

**huang_ji_2_formula.json**:
- 2个组，8条结果
- 全部为derived类型

**huang_ji_3_formula.json**:
- 4个组，8条结果
- 全部为derived类型

### 10.3 参考资料

- 铁板神数预测学
- 皇极取数法传统文献
- Flutter Provider状态管理
- JSON序列化最佳实践

---

**文档结束**

如有任何问题或建议，请联系开发团队。
