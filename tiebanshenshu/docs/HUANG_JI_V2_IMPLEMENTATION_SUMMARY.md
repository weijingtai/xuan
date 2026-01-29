# 皇极取数法 V2 架构实现总结

## 📋 实现概览

本次实现完成了**皇极取数法 V2 完整架构**，包含会话管理、状态快照、基础数去重选择等核心功能。

**实现日期**: 2025-10-06
**状态**: ✅ 核心架构完成，UI集成待完成

---

## ✅ 已完成的工作 (8个阶段)

### Phase 1: 核心数据模型
创建了完整的数据模型层：

- **`base_number_selection_record.dart`**
  - `CandidateGenerationConfig` - 候选数生成配置
  - `BaseNumberCandidate` - 候选数据模型
  - `DerivationStep` - 派生步骤
  - `BaseNumberDerivationChain` - 派生链路（含 `finalValue` 计算）
  - `BaseNumberSelectionRecord` - 选择记录
  - `SelectionStatus` - 选择状态枚举

- **`base_number_selection_batch.dart`**
  - `BaseNumberSelectionItem` - 批量选择项
  - `BaseNumberSelectionBatch` - 批量选择数据

- **`tiao_wen_result.dart`**
  - `TiaoWenResult` - 最终条文结果

- **`huang_ji_v2_session_models.dart`**
  - `SessionPhase` - 会话阶段枚举（5个阶段）
  - `HuangJiSessionStatus` - 会话状态枚举（7个状态）
  - `SessionSnapshot` - 会话快照
  - `HuangJiSession` - 完整会话模型（含JSON序列化）

### Phase 2: 计算策略层
创建了策略接口和实现：

- **`huang_ji_v2_calculation_strategy.dart`** - 策略接口
  - `calculateYuanHuiYunShi()` - 计算元会运世
  - `generateCandidates()` - 生成候选数列表
  - `calculateDerivedBaseNumber()` - 计算派生基础数
  - `calculateTiaoWenNumber()` - 计算最终条文数
  - `buildDerivationChain()` - 构建派生链路

- **`huang_ji_v2_calculation_strategy_impl.dart`** - 策略实现
  - 候选数生成算法: `initialNumber ± offset*N`
  - 范围限制: 1000-13000
  - 递归派生链构建

### Phase 3: 数据访问层扩展
扩展了TiaoWenRepository：

- 新增 `getTiaoWenContentByNumbers(List<int>)` - 批量获取条文
- 新增 `getTiaoWenContentByNumber(int)` - 单个条文查询

### Phase 4: 会话仓库层
创建了会话持久化机制：

- **`session_repository.dart`** - 仓库接口
- **`session_repository_impl.dart`** - 内存实现
  - `InMemorySessionRepository` - 支持会话和快照的内存存储

### Phase 5: 会话管理层
创建了完整的会话生命周期管理：

- **`huang_ji_session_manager.dart`**
  - `createSession()` - 创建新会话
  - `restoreSession()` - 恢复会话
  - `advanceToPhase()` - 推进阶段（含快照创建）
  - `createSnapshot()` - 创建当前阶段快照
  - `rollbackToSnapshot()` - 回滚到指定快照
  - `rollbackToPreviousPhase()` - 回滚到上一阶段
  - `_validatePhaseTransition()` - 阶段转换验证

**阶段转换规则**:
```
initialized → yuanHuiYunShiCalculated
yuanHuiYunShiCalculated → baseNumberSelectionReady
baseNumberSelectionReady → baseNumberSelected
baseNumberSelected → finalCalculationComplete
```

### Phase 6: 业务逻辑层 (UseCase)
创建了核心业务编排逻辑：

- **`huang_ji_v2_use_case.dart`** - **核心去重逻辑实现**

**5个主要方法**:

1. **`initializeSession()`** - 初始化会话并计算元会运世
   ```dart
   final session = await useCase.initializeSession(
     eightChars: eightChars,
     formula: formula,
     sessionName: 'My Session',
   );
   ```

2. **`prepareBaseNumberSelection()`** - **核心去重逻辑**
   ```dart
   // 关键实现：
   // 1. 使用 BaseNumberDefinition.name 作为唯一标识
   // 2. 记录每个定义被哪些组使用 (relatedGroupIds)
   // 3. 去重：同名定义只生成一次候选数
   // 4. 批量获取条文内容
   final session = await useCase.prepareBaseNumberSelection(session);
   ```

3. **`submitBaseNumberSelections()`** - 提交用户选择
   ```dart
   final selections = {
     'definitionId1': selectedNumber1,
     'definitionId2': selectedNumber2,
   };
   final session = await useCase.submitBaseNumberSelections(
     session: session,
     selections: selections,
   );
   ```

4. **`calculateFinalTiaoWenList()`** - 计算最终条文
   ```dart
   final session = await useCase.calculateFinalTiaoWenList(session);
   // session.finalTiaoWenList 包含所有结果
   ```

5. **`rollbackToPhase()`** - 回滚功能
   ```dart
   final session = await useCase.rollbackToPhase(
     session: session,
     targetPhase: SessionPhase.baseNumberSelectionReady,
   );
   ```

**辅助方法**:
- `getSelectionBatch()` - 获取批量选择数据（用于UI）
- `_requiresUserSelection()` - 判断是否需要用户选择
- `_toDataDefinition()` - 转换为数据层定义
- `_buildCalculationDetail()` - 构建计算详情

### Phase 7: 代码生成
成功生成所有JSON序列化代码：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**生成的文件**:
- `base_number_selection_record.g.dart`
- `base_number_selection_batch.g.dart`
- `tiao_wen_result.g.dart`
- `huang_ji_v2_session_models.g.dart`

### Phase 8: 测试验证
创建并通过了9个单元测试：

```bash
flutter test test/features/huang_ji_v2_models_test.dart
✅ All 9 tests passed!
```

**测试覆盖**:
- ✅ 候选配置验证
- ✅ 候选数偏移追踪
- ✅ 会话阶段枚举
- ✅ 会话状态枚举
- ✅ 派生步骤描述
- ✅ 选择状态枚举
- ✅ 快照时间戳
- ✅ 记录copyWith更新
- ✅ 阶段转换规则

---

## 🎯 核心特性

### 1. 去重逻辑
**基于 `BaseNumberDefinition.name` 进行去重**

```dart
// 遍历所有公式组
for (final formula in session.formulas) {
  for (final group in formula.groups) {
    final baseNumDef = group.baseNumberDefinition;
    final definitionId = baseNumDef.name; // ← 使用 name 作为唯一ID

    // 记录该定义被哪些组使用
    definitionToGroups.putIfAbsent(definitionId, () => []).add(group.groupId);

    // 去重：已处理过的定义跳过
    if (uniqueDefinitions.containsKey(definitionId)) {
      continue;
    }

    // 为该定义生成候选数...
  }
}
```

**效果**: 多个组使用同一个定义时，用户只需选择一次，选择结果应用到所有相关组。

### 2. 派生链追踪
完整记录从源头到最终值的推导过程：

```dart
class BaseNumberDerivationChain {
  final DataPredefinedBaseNumber source;      // 源头（元/会/运/世）
  final List<DerivationStep> derivationSteps; // 推导步骤
  final DataBaseNumberDefinition finalDefinition; // 最终定义

  int get finalValue {
    int value = source.number;
    for (final step in derivationSteps) {
      value += step.value;
    }
    return value;
  }

  String getFullPath() {
    // 返回: "元(1234) → +运*100(5600) → 基础数一(6834)"
  }
}
```

### 3. 会话快照
完整的JSON序列化支持回滚：

```dart
class SessionSnapshot {
  final String snapshotId;
  final SessionPhase phase;
  final DateTime timestamp;
  final Map<String, dynamic> state; // 完整会话状态
}

// 创建快照
final snapshot = sessionManager.createSnapshot(session);

// 回滚到快照
final restoredSession = await sessionManager.rollbackToSnapshot(
  session: session,
  snapshotId: snapshot.snapshotId,
);
```

### 4. 候选数生成
算法: `initialNumber ± offset*N`

```dart
final config = CandidateGenerationConfig(
  initialNumber: 5000,
  offset: 30,        // 步长
  count: 10,         // 前后各10个
  minValue: 1000,    // 最小值
  maxValue: 13000,   // 最大值
);

// 生成结果: [4700, 4730, ..., 4970, 5000, 5030, ..., 5270, 5300]
// 超出范围的会被过滤
```

### 5. 阶段验证
严格的状态转换控制：

```dart
// 有效转换
initialized → yuanHuiYunShiCalculated ✅
baseNumberSelectionReady → baseNumberSelected ✅

// 无效转换
initialized → finalCalculationComplete ❌ 抛出异常
baseNumberSelected → yuanHuiYunShiCalculated ❌ 抛出异常
```

---

## 📁 新增文件清单

### 核心架构文件
```
lib/
├── domain/models/
│   ├── base_number_selection_record.dart      ✨ 新增
│   ├── base_number_selection_record.g.dart    ✨ 生成
│   ├── base_number_selection_batch.dart       ✨ 新增
│   ├── base_number_selection_batch.g.dart     ✨ 生成
│   ├── tiao_wen_result.dart                   ✨ 新增
│   └── tiao_wen_result.g.dart                 ✨ 生成
│
├── features/
│   ├── huang_ji_v2_session_models.dart        ✨ 新增
│   └── huang_ji_v2_session_models.g.dart      ✨ 生成
│
├── service/strategy/
│   ├── huang_ji_v2_calculation_strategy.dart      ✨ 新增
│   └── huang_ji_v2_calculation_strategy_impl.dart ✨ 新增
│
├── repository/
│   ├── session_repository.dart                ✨ 新增
│   ├── session_repository_impl.dart           ✨ 新增
│   ├── tiao_wen_repository.dart              🔧 扩展
│   └── tiao_wen_repository_impl.dart         🔧 扩展
│
├── application/
│   ├── managers/
│   │   └── huang_ji_session_manager.dart      ✨ 新增
│   └── usecases/
│       └── huang_ji_v2_use_case.dart          ✨ 新增
│
└── test/features/
    └── huang_ji_v2_models_test.dart           ✨ 新增
```

---

## ⚠️ 当前状态与注意事项

### ✅ 已完成
- 核心架构全部实现（8个阶段）
- 代码编译通过（0 errors）
- 单元测试通过（9/9 tests）
- 去重逻辑、会话管理、回滚功能全部就绪

### ⏸️ 待完成 - UI集成
**当前无法直接在UI运行**，原因：

1. **存在旧代码冲突**
   - `lib/features/huang_ji_v2_usecase.dart` (旧)
   - `lib/features/huang_ji_v2_viewmodel.dart` (旧)
   - `lib/features/huang_ji_v2_demo_page.dart` (旧)

2. **DI配置需要更新**
   - `lib/infrastructure/di/strategy_providers.dart` 还在引用旧UseCase
   - 需要创建新的Provider配置

3. **缺少UI层**
   - 需要创建新的ViewModel（使用新UseCase）
   - 需要创建新的Page（适配新架构）

### 📋 下一步工作建议

#### 方案A: 完整UI集成（推荐）
1. 创建 `HuangJiV2ViewModel` 使用新的 `HuangJiV2UseCase`
2. 创建 `HuangJiV2Page` 展示批量选择界面
3. 更新DI配置注入新的UseCase
4. 测试完整流程

#### 方案B: 重命名避免冲突
1. 将新架构重命名为 `HuangJiV3*`
2. 旧代码保持不变
3. 逐步迁移

#### 方案C: 清理旧代码
1. 删除或重命名旧的V2文件
2. 直接使用新架构
3. 重建UI层

---

## 🔑 关键使用示例

### 完整流程示例

```dart
// 1. 初始化依赖
final sessionRepository = InMemorySessionRepository();
final tiaoWenRepository = TiaoWenRepositoryImpl(dataPath: '...');
final strategy = HuangJiV2CalculationStrategyImpl();
final sessionManager = HuangJiSessionManager(
  sessionRepository: sessionRepository,
  calculationStrategy: strategy,
);
final useCase = HuangJiV2UseCase(
  sessionManager: sessionManager,
  calculationStrategy: strategy,
  tiaoWenRepository: tiaoWenRepository,
);

// 2. 创建会话并计算元会运世
final session1 = await useCase.initializeSession(
  eightChars: eightChars,
  formula: formula,
);
// 此时: session1.currentPhase == SessionPhase.yuanHuiYunShiCalculated

// 3. 准备基础数选择（核心去重逻辑）
final session2 = await useCase.prepareBaseNumberSelection(session1);
// 此时: session2.currentPhase == SessionPhase.baseNumberSelectionReady
// session2.baseNumberSelections 包含去重后的选择项

// 4. 获取批量选择数据（用于UI展示）
final batch = useCase.getSelectionBatch(session2);
// batch.items 是去重后的选择项列表
// batch.definitionToGroupsMap 显示每个定义被哪些组使用

// 5. 用户选择并提交
final selections = {
  'baseNumberDef1': 5030,  // 用户选择的候选数
  'baseNumberDef2': 7260,
};
final session3 = await useCase.submitBaseNumberSelections(
  session: session2,
  selections: selections,
);
// 此时: session3.currentPhase == SessionPhase.baseNumberSelected

// 6. 计算最终条文
final session4 = await useCase.calculateFinalTiaoWenList(session3);
// 此时: session4.currentPhase == SessionPhase.finalCalculationComplete
// session4.finalTiaoWenList 包含所有结果

// 7. 回滚示例（如需重新选择）
final rolledBack = await useCase.rollbackToPhase(
  session: session4,
  targetPhase: SessionPhase.baseNumberSelectionReady,
);
// 回到选择阶段，可重新选择
```

---

## 📊 架构图

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                 │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │   ViewModel  │ ◄────── │   Page (UI)     │  │
│  └──────┬───────┘         └─────────────────┘  │
└─────────┼──────────────────────────────────────┘
          │
┌─────────▼──────────────────────────────────────┐
│           Application Layer                     │
│  ┌──────────────────────────────────────────┐  │
│  │    HuangJiV2UseCase                      │  │
│  │  - initializeSession()                   │  │
│  │  - prepareBaseNumberSelection() ★去重★   │  │
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

---

## 🎓 设计决策

### 1. 为什么使用 name 作为去重标识？
- **稳定性**: name 是人类可读的唯一标识
- **灵活性**: 支持公式配置变更
- **可追溯**: 便于调试和日志记录

### 2. 为什么分离 Manager 和 Strategy？
- **Manager**: 专注会话生命周期管理
- **Strategy**: 专注纯计算逻辑
- **解耦**: 便于单独测试和替换

### 3. 为什么使用完整JSON快照而非增量？
- **简单性**: 实现简单，不易出错
- **可靠性**: 回滚时完整恢复状态
- **调试友好**: 可直接查看快照内容

### 4. 为什么选择内存Repository？
- **开发阶段**: 快速迭代，无需数据库配置
- **易替换**: 接口设计允许无缝切换到持久化实现
- **测试友好**: 每次测试都是干净状态

---

## 📝 相关文档

如需了解更多细节，请参考：
- 原始需求文档（会话对话记录）
- 测试文件: `test/features/huang_ji_v2_models_test.dart`
- 核心UseCase: `lib/application/usecases/huang_ji_v2_use_case.dart`

---

**文档版本**: 1.0
**最后更新**: 2025-10-06
**作者**: Claude Code
