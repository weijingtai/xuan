# 皇极取数法 V2 快速参考

## 核心流程速查

```
┌──────────────────────────────────────────────────────────────────────┐
│                         皇极取数法三大阶段                           │
└──────────────────────────────────────────────────────────────────────┘

阶段1: 计算元会运世
  Input:  EightChars (四柱八字)
  Action: YuanHuiYunShi.fromEightChars()
  Output: 元会基础数 (左旋), 运世基础数 (右旋)
  ────────────────────────────────────────────────────────────────────
阶段2: 基础数选择
  Input:  HuangJiV2Session (含 YuanHuiYunShi)
  Action:
    ├─ 遍历 groups → 收集 baseNumberDefinition
    ├─ 去重 (基于 name)
    ├─ 生成候选列表 (初刻数 ± 30*N, N=0..10)
    ├─ 查询条文内容
    └─ 用户选择
  Output: Map<definitionId, selectedCandidate>
  ────────────────────────────────────────────────────────────────────
阶段3: 计算最终条文
  Input:  Session (含用户选择)
  Action:
    ├─ 获取基础数 (用户选择值或默认值)
    ├─ 遍历 formulas
    └─ 条文数 = 基础数 + sum(formula.parts)
  Output: List<TiaoWenResult>
```

---

## 关键类速查

### 数据模型

| 类名 | 用途 | 关键字段 |
|-----|------|---------|
| `HuangJiV2Session` | 会话主体 | `yuanHuiYunShi`, `baseNumberSelections`, `currentPhase` |
| `BaseNumberSelectionRecord` | 选择记录 | `selectedCandidate`, `derivationChain`, `relatedGroupIds` |
| `BaseNumberDerivationChain` | 派生链路 | `source`, `derivationSteps`, `finalDefinition` |
| `BaseNumberCandidate` | 候选项 | `number`, `offsetFromInitial`, `tiaoWenContent` |
| `SessionSnapshot` | 快照 | `phase`, `timestamp`, `state` (完整JSON) |

### 服务层

| 类名 | 职责 | 关键方法 |
|-----|------|---------|
| `HuangJiCalculationStrategy` | 纯计算 | `calculateYuanHuiYunShi`, `generateCandidates`, `buildDerivationChain` |
| `HuangJiV2SessionManager` | 状态管理 | `createSession`, `advanceToPhase`, `createSnapshot`, `rollbackToSnapshot` |
| `HuangJiInteractiveUseCase` | 业务编排 | `initializeSession`, `prepareBaseNumberSelection`, `submitBaseNumberSelections` |

---

## 去重逻辑速查

### 问题
多个 `CalculationGroup` 可能使用同一个 `BaseNumberDefinition`，如何避免用户重复选择？

### 方案
```dart
// 使用 name 作为唯一标识
final definitionId = baseNumDef.name; // 关键!

// 记录关联的 groups
definitionToGroups[definitionId] = [...groupIds];

// 去重检查
if (uniqueDefinitions.containsKey(definitionId)) {
  continue; // 已存在,跳过
}

// 第一次出现,生成候选列表
uniqueDefinitions[definitionId] = createSelectionItem(...);
```

### 结果
- 相同 `name` 的定义只生成一次候选列表
- 用户只需选择一次
- 选择值在所有 `relatedGroupIds` 中复用

---

## 派生链路追踪速查

### 示例
```
原始: 元会基础数(2000)
  ↓ +年干*1000(1000)
派生: 派生基础数一(3000)
  ↓ +日干支合数(56)
派生: 派生基础数二(3056)
  ↓ 用户选择 +30
最终: 3086
```

### 实现
```dart
BaseNumberDerivationChain buildDerivationChain(definition, yhys) {
  if (definition is DataPredefinedBaseNumber) {
    // 到达根源
    return BaseNumberDerivationChain(source: definition, steps: []);
  }

  if (definition is DataDerivedBaseNumber) {
    // 递归追溯父级
    final parentChain = buildDerivationChain(definition.baseNumberDefinition, yhys);

    // 添加当前步骤
    final step = DerivationStep(
      operation: "+年干*1000",
      value: 1000,
      description: "...",
    );

    return parentChain.addStep(step);
  }
}
```

---

## 候选列表生成速查

### 配置
```dart
CandidateGenerationConfig(
  initialNumber: 2718,  // 初刻数
  offset: 30,           // 偏移量
  count: 10,            // 前后各10个
  minValue: 1000,       // 最小值
  maxValue: 13000,      // 最大值
)
```

### 生成逻辑
```dart
for (int i = -count; i <= count; i++) {
  final number = initialNumber + (i * offset);

  // 过滤范围
  if (number < minValue || number > maxValue) continue;

  candidates.add(BaseNumberCandidate(
    number: number,
    offsetFromInitial: i * offset,
    isInitial: i == 0,
  ));
}
```

### 结果
```
2418 (-300)
2448 (-270)
...
2718 (0)    ← 初刻数
...
3018 (+300)
```

---

## 快照与回滚速查

### 创建快照
```dart
SessionSnapshot createSnapshot(HuangJiV2Session session) {
  return SessionSnapshot(
    snapshotId: 'snapshot_${timestamp}',
    phase: session.currentPhase,
    timestamp: DateTime.now(),
    state: session.toJson(), // 完整序列化
  );
}
```

### 回滚
```dart
Future<HuangJiV2Session> rollbackToSnapshot(session, snapshotId) {
  // 1. 查找快照
  final snapshot = session.phaseHistory.firstWhere(...);

  // 2. 从 JSON 恢复
  final restored = HuangJiV2Session.fromJson(snapshot.state);

  // 3. 截断历史
  final truncatedHistory = phaseHistory.sublist(0, snapshotIndex);

  // 4. 保存
  await repository.saveSession(restored);
  return restored;
}
```

---

## TiaoWenRepository 扩展速查

### 新增接口
```dart
/// 批量查询条文内容
Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers);

/// 单个查询条文内容
Future<String?> getTiaoWenContentByNumber(int number);
```

### 实现
```dart
Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) async {
  final tiaoWenList = await getByIdList(queryList: numbers, skipNotFound: true);

  return {
    for (var tw in tiaoWenList)
      tw.id: tw.content1
  };
}

Future<String?> getTiaoWenContentByNumber(int number) async {
  final tiaoWen = await getById(number);
  return tiaoWen?.content1;
}
```

---

## 常用 API 速查

### UseCase 调用流程
```dart
// 1. 初始化
final session = await useCase.initializeSession(
  eightChars: eightChars,
  formulaId: 3,
);

// 2. 准备选择
final batch = await useCase.prepareBaseNumberSelection(session.sessionId);

// 3. 提交选择
final updatedSession = await useCase.submitBaseNumberSelections(
  sessionId: session.sessionId,
  selections: {
    '元会基础数': 'candidate_2748',
    '运世基础数': 'candidate_9132',
  },
);

// 4. 计算条文
final results = await useCase.calculateFinalTiaoWenList(session.sessionId);

// 5. 回滚 (如果需要)
final rolledBack = await useCase.rollbackToPhase(
  sessionId: session.sessionId,
  targetPhase: SessionPhase.baseNumberSelectionReady,
);
```

---

## 阶段状态机速查

```
initialized
    ↓ calculateYuanHuiYunShi()
yuanHuiYunShiCalculated
    ↓ prepareBaseNumberSelection()
baseNumberSelectionReady
    ↓ submitSelections()
baseNumberSelected
    ↓ calculateFinalTiaoWen()
finalCalculationComplete
    ↑
    └─ rollback() ──┐
                    ↓
    可回滚到任意历史阶段
```

---

## 测试命令速查

### 运行单元测试
```bash
flutter test test/service/strategy/huang_ji_calculation_strategy_test.dart
```

### 运行集成测试
```bash
flutter test test/application/usecases/huang_ji_interactive_use_case_test.dart
```

### 生成 JSON 序列化代码
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 运行所有测试
```bash
flutter test
```

---

## 常见问题速查

### Q1: 如何判断两个 baseNumberDefinition 是否相同?
**A**: 基于 `name` 字段。相同 `name` 视为同一个定义。

### Q2: 候选列表的条文内容从哪里来?
**A**: 通过 `TiaoWenRepository.getTiaoWenContentByNumbers()` 批量查询。

### Q3: 如果条文不存在怎么办?
**A**: 显示 "条文未找到 (条文数)"。

### Q4: 快照包含哪些内容?
**A**: Session 的完整 JSON 序列化 (`session.toJson()`)。

### Q5: 如何扩展新的公式?
**A**: 在 `assets/formulas/` 下添加新的 JSON 文件，无需修改代码。

### Q6: 派生链路追溯到什么时候停止?
**A**: 追溯到 `DataPredefinedBaseNumber` (元会或运世)。

### Q7: 去重后的选择值如何复用?
**A**: 存储在 `session.baseNumberSelections[definitionId]`，所有 `relatedGroupIds` 都使用该值。

---

## 文件结构速查

```
lib/
├── domain/
│   └── models/
│       ├── base_number_selection_record.dart    // 选择记录
│       ├── base_number_selection_batch.dart     // 批量选择
│       ├── tiao_wen_result.dart                 // 条文结果
│       └── yuan_hui_yun_shi.dart                // 元会运世
├── service/
│   └── strategy/
│       ├── huang_ji_calculation_strategy.dart      // 策略接口
│       └── huang_ji_calculation_strategy_impl.dart // 策略实现
├── repository/
│   ├── session_repository.dart              // Session仓库接口
│   ├── session_repository_impl.dart         // 内存实现
│   └── tiao_wen_repository.dart             // 条文仓库 (扩展)
├── application/
│   ├── managers/
│   │   └── huang_ji_v2_session_manager.dart // 状态管理
│   └── usecases/
│       └── huang_ji_interactive_use_case.dart // 业务编排
└── presentation/
    ├── viewmodels/
    │   └── huang_ji_interactive_view_model.dart
    ├── pages/
    │   ├── huang_ji_interactive_page.dart
    │   └── base_number_batch_selection_page.dart
    └── widgets/
        ├── base_number_selection_item_widget.dart
        └── candidate_list_widget.dart
```

---

## 依赖注入速查

### 推荐使用 Riverpod

```dart
// Providers
final tiaoWenRepositoryProvider = Provider<TiaoWenRepository>((ref) {
  return TiaoWenRepositoryImpl(dataPath: '...');
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return InMemorySessionRepository();
});

final calculationStrategyProvider = Provider<HuangJiCalculationStrategy>((ref) {
  return HuangJiCalculationStrategyImpl();
});

final sessionManagerProvider = Provider<HuangJiV2SessionManager>((ref) {
  return HuangJiV2SessionManager(
    sessionRepository: ref.read(sessionRepositoryProvider),
    calculationStrategy: ref.read(calculationStrategyProvider),
  );
});

final interactiveUseCaseProvider = Provider<HuangJiInteractiveUseCase>((ref) {
  return HuangJiInteractiveUseCase(
    sessionManager: ref.read(sessionManagerProvider),
    calculationStrategy: ref.read(calculationStrategyProvider),
    tiaoWenRepository: ref.read(tiaoWenRepositoryProvider),
    formulaManager: ref.read(formulaManagerProvider),
  );
});

final huangJiViewModelProvider = ChangeNotifierProvider<HuangJiInteractiveViewModel>((ref) {
  return HuangJiInteractiveViewModel(
    useCase: ref.read(interactiveUseCaseProvider),
  );
});
```

---

**最后更新**: 2025-01-XX
**适用版本**: v1.0
