# 皇极取数法 V2 - API 参考文档

**版本**: 2.0.0
**最后更新**: 2025-10-06
**适用于**: Flutter/Dart 应用

---

## 目录

1. [概述](#概述)
2. [快速开始](#快速开始)
3. [核心API](#核心api)
   - [HuangJiV2UseCase](#huangjiv2usecase)
   - [HuangJiSessionManager](#huangjisessionmanager)
   - [HuangJiV2CalculationStrategy](#huangjiv2calculationstrategy)
   - [SessionRepository](#sessionrepository)
   - [TiaoWenRepository](#tiaowanrepository)
4. [数据模型](#数据模型)
5. [枚举类型](#枚举类型)
6. [异常类型](#异常类型)
7. [使用示例](#使用示例)
8. [最佳实践](#最佳实践)

---

## 概述

皇极取数法 V2 API 提供了一套完整的接口，用于管理铁板神数的计算会话、基础数选择和条文生成。

### 架构层次

```
Presentation Layer (UI/ViewModel)
         ↓
Application Layer (UseCase/Manager)
         ↓
Domain Layer (Models/Entities)
         ↓
Infrastructure Layer (Repository/Strategy)
```

### 主要组件

| 组件 | 职责 | 层次 |
|------|------|------|
| `HuangJiV2UseCase` | 业务逻辑编排 | Application |
| `HuangJiSessionManager` | 会话生命周期管理 | Application |
| `HuangJiV2CalculationStrategy` | 计算逻辑 | Infrastructure |
| `SessionRepository` | 会话数据存储 | Infrastructure |
| `TiaoWenRepository` | 条文数据访问 | Infrastructure |

---

## 快速开始

### 安装依赖

```yaml
# pubspec.yaml
dependencies:
  common:
    path: ../common
  provider: ^6.0.0
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.3.0
  json_serializable: ^6.6.0
```

### 依赖注入配置

```dart
import 'package:provider/provider.dart';

// 在main.dart中配置Provider
MultiProvider(
  providers: [
    // Infrastructure层
    Provider<HuangJiV2CalculationStrategy>(
      create: (_) => HuangJiV2CalculationStrategyImpl(),
    ),
    Provider<SessionRepository>(
      create: (_) => InMemorySessionRepository(),
    ),
    Provider<TiaoWenRepository>(
      create: (_) => YourTiaoWenRepository(),
    ),

    // Application层
    Provider<HuangJiSessionManager>(
      create: (context) => HuangJiSessionManager(
        sessionRepository: context.read<SessionRepository>(),
        calculationStrategy: context.read<HuangJiV2CalculationStrategy>(),
      ),
    ),
    Provider<HuangJiV2UseCase>(
      create: (context) => HuangJiV2UseCase(
        sessionManager: context.read<HuangJiSessionManager>(),
        calculationStrategy: context.read<HuangJiV2CalculationStrategy>(),
        tiaoWenRepository: context.read<TiaoWenRepository>(),
      ),
    ),

    // Presentation层
    ChangeNotifierProvider<HuangJiV2ViewModel>(
      create: (context) => HuangJiV2ViewModel(
        useCase: context.read<HuangJiV2UseCase>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 基础使用

```dart
// 在Widget中使用
final viewModel = context.read<HuangJiV2ViewModel>();

// 初始化会话
await viewModel.initializeSession(
  eightChars: myEightChars,
  formulas: allFormulas,
  sessionName: '测试会话',
);

// 准备基础数选择
await viewModel.prepareBaseNumberSelection();

// 提交用户选择
await viewModel.submitSelections(userSelections);

// 计算最终条文
await viewModel.calculateFinalTiaoWenList();
```

---

## 核心API

### HuangJiV2UseCase

**路径**: `lib/features/huang_ji/huang_ji_v2_use_case.dart`

**职责**: 核心业务逻辑编排，协调Manager、Strategy和Repository完成完整流程

#### 构造函数

```dart
HuangJiV2UseCase({
  required HuangJiSessionManager sessionManager,
  required HuangJiV2CalculationStrategy calculationStrategy,
  required TiaoWenRepository tiaoWenRepository,
})
```

**参数**:
- `sessionManager`: 会话管理器
- `calculationStrategy`: 计算策略
- `tiaoWenRepository`: 条文数据仓储

---

#### initializeSession

初始化新的皇极会话并计算元会运世。

```dart
Future<HuangJiSession> initializeSession({
  required EightChars eightChars,
  required List<HuangJiCalculationFormula> formulas,
  String? sessionName,
})
```

**参数**:
- `eightChars` **(必需)**: 八字信息（年月日时的天干地支）
  - 类型: `EightChars`
  - 示例: `EightChars(year: JiaZi.GUI_SI, month: JiaZi.JIA_ZI, ...)`

- `formulas` **(必需)**: 要使用的公式列表
  - 类型: `List<HuangJiCalculationFormula>`
  - 通常使用: `HuangJiFormulaManager.instance.getAllFormulas()`
  - 约束: 不能为空列表

- `sessionName` *(可选)*: 会话名称
  - 类型: `String?`
  - 默认值: `'Session_<timestamp>'`

**返回值**:
- 类型: `Future<HuangJiSession>`
- 会话状态:
  - `currentPhase`: `SessionPhase.yuanHuiYunShiCalculated`
  - `yuanHuiYunShi`: 已计算完成（包含元、会、运、世）

**抛出异常**:
- `Exception`: 当formulas为空时
- `Exception`: 当八字数据无效时

**示例**:

```dart
final useCase = context.read<HuangJiV2UseCase>();

final eightChars = EightChars(
  year: JiaZi.GUI_SI,    // 癸巳
  month: JiaZi.JIA_ZI,   // 甲子
  day: JiaZi.DING_YOU,   // 丁酉
  time: JiaZi.GUI_MAO,   // 癸卯
);

final formulas = HuangJiFormulaManager.instance.getAllFormulas();

final session = await useCase.initializeSession(
  eightChars: eightChars,
  formulas: formulas,
  sessionName: '张三的命盘',
);

print('会话ID: ${session.sessionId}');
print('元: ${session.yuanHuiYunShi!.yuanNumber}');
print('会: ${session.yuanHuiYunShi!.huiNumber}');
print('运: ${session.yuanHuiYunShi!.yunNumber}');
print('世: ${session.yuanHuiYunShi!.shiNumber}');
```

**内部流程**:

1. 调用 `sessionManager.createSession()` 创建会话
2. 调用 `calculationStrategy.calculateYuanHuiYunShi()` 计算元会运世
3. 更新会话并保存
4. 推进阶段到 `yuanHuiYunShiCalculated`

---

#### prepareBaseNumberSelection

准备基础数选择，执行核心去重逻辑并生成候选数列表。

```dart
Future<HuangJiSession> prepareBaseNumberSelection(
  HuangJiSession session,
)
```

**参数**:
- `session` **(必需)**: 当前会话
  - 类型: `HuangJiSession`
  - 前置条件: `currentPhase` 必须为 `yuanHuiYunShiCalculated`
  - 前置条件: `yuanHuiYunShi` 不能为 null

**返回值**:
- 类型: `Future<HuangJiSession>`
- 会话状态:
  - `currentPhase`: `SessionPhase.baseNumberSelectionReady`
  - `baseNumberSelections`: 包含所有去重后的基础数定义（通常5个）

**抛出异常**:
- `Exception`: 当 `yuanHuiYunShi` 为 null 时
- `InvalidPhaseTransitionException`: 当会话阶段不正确时

**去重逻辑说明**:

此方法实现了核心的去重算法：

1. **遍历所有公式组**: 收集所有需要用户选择的基础数定义
2. **基于name去重**: 使用 `baseNumberDefinition.name` 作为唯一标识
3. **记录关联关系**: 追踪每个定义被哪些组使用
4. **生成候选数**: 为每个唯一定义生成21个候选数（初始值±10×offset）
5. **批量获取条文**: 一次性查询所有候选数的条文内容

**去重示例**:

假设3个公式中都有"元会·基础数一"：
- 公式1-组1: 元会·基础数一
- 公式2-组1: 元会·基础数一
- 公式3-组1: 元会·基础数一

去重后只生成1个选择项，但记录关联了3个组。用户选择后，该值应用到所有3个组的计算。

**示例**:

```dart
var session = await useCase.initializeSession(...);

// 准备基础数选择
session = await useCase.prepareBaseNumberSelection(session);

// 获取选择批次（用于UI显示）
final batch = useCase.getSelectionBatch(session);

print('需要选择 ${batch!.items.length} 个基础数');

for (final item in batch.items) {
  print('定义: ${item.name}');
  print('描述: ${item.description}');
  print('候选数数量: ${item.candidates.length}');
  print('应用于组: ${item.relatedGroupIds.join(", ")}');
  print('推导链: ${item.derivationChain.getFullPath()}');
  print('---');

  // 显示候选数
  for (final candidate in item.candidates) {
    print('  ${candidate.number}: ${candidate.tiaoWenContent}');
  }
}
```

**性能考虑**:

- 时间复杂度: O(F × G × C)，其中 F=公式数，G=每公式组数，C=候选数数量
- 实际值: O(3 × 4 × 21) = O(252) - 常数级别
- 批量查询优化: 条文内容一次性批量获取，避免多次IO

---

#### submitBaseNumberSelections

验证并保存用户的基础数选择。

```dart
Future<HuangJiSession> submitBaseNumberSelections({
  required HuangJiSession session,
  required Map<String, int> selections,
})
```

**参数**:
- `session` **(必需)**: 当前会话
  - 类型: `HuangJiSession`
  - 前置条件: `currentPhase` 必须为 `baseNumberSelectionReady`

- `selections` **(必需)**: 用户的选择映射
  - 类型: `Map<String, int>`
  - 键: `baseNumberDefinitionId` (即 `name`)
  - 值: 用户选择的候选数编号
  - 约束: 必须包含所有定义的选择

**返回值**:
- 类型: `Future<HuangJiSession>`
- 会话状态:
  - `currentPhase`: `SessionPhase.baseNumberSelected`
  - `baseNumberSelections`: 所有记录的 `status` 更新为 `completed`

**抛出异常**:
- `Exception`: 当 `definitionId` 不存在时
- `Exception`: 当选择的候选数不在候选列表中时
- `Exception`: 当缺少必需的选择时
- `InvalidPhaseTransitionException`: 当会话阶段不正确时

**验证规则**:

1. 所有 `baseNumberSelections` 中的定义都必须有选择
2. 选择的候选数必须存在于对应的候选列表中
3. 候选数编号必须在有效范围内（1000-13000）

**示例**:

```dart
// 准备选择
var session = await useCase.prepareBaseNumberSelection(session);
final batch = useCase.getSelectionBatch(session);

// 构建用户选择
final selections = <String, int>{};

for (final item in batch!.items) {
  // 示例: 用户选择每个定义的中间候选数（第11个，offset=0）
  final selectedCandidate = item.candidates[10];
  selections[item.definitionId] = selectedCandidate.number;
}

// 提交选择
session = await useCase.submitBaseNumberSelections(
  session: session,
  selections: selections,
);

print('选择已提交，当前阶段: ${session.currentPhase}');

// 验证所有选择都已完成
for (final record in session.baseNumberSelections.values) {
  assert(record.status == SelectionStatus.completed);
  print('${record.name}: ${record.selectedCandidate!.number}');
}
```

**UI集成示例**:

```dart
class SelectionWidget extends StatefulWidget {
  final HuangJiSession session;
  final BaseNumberSelectionBatch batch;

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  final Map<String, int> _userSelections = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.batch.items.map((item) =>
          RadioListGroup(
            item: item,
            selectedValue: _userSelections[item.definitionId],
            onChanged: (value) {
              setState(() {
                _userSelections[item.definitionId] = value;
              });
            },
          ),
        ),
        ElevatedButton(
          onPressed: _userSelections.length == widget.batch.items.length
            ? () async {
                final useCase = context.read<HuangJiV2UseCase>();
                await useCase.submitBaseNumberSelections(
                  session: widget.session,
                  selections: _userSelections,
                );
              }
            : null,
          child: Text('提交选择 (${_userSelections.length}/${widget.batch.items.length})'),
        ),
      ],
    );
  }
}
```

---

#### calculateFinalTiaoWenList

基于用户选择计算所有公式的所有条文。

```dart
Future<HuangJiSession> calculateFinalTiaoWenList(
  HuangJiSession session,
)
```

**参数**:
- `session` **(必需)**: 当前会话
  - 类型: `HuangJiSession`
  - 前置条件: `currentPhase` 必须为 `baseNumberSelected`
  - 前置条件: 所有 `baseNumberSelections` 都有 `selectedCandidate`

**返回值**:
- 类型: `Future<HuangJiSession>`
- 会话状态:
  - `currentPhase`: `SessionPhase.finalCalculationComplete`
  - `status`: `HuangJiSessionStatus.completed`
  - `finalTiaoWenList`: 包含所有计算结果（通常29条）

**抛出异常**:
- `Exception`: 当会话阶段不正确时
- `Exception`: 当缺少基础数选择时
- `InvalidPhaseTransitionException`: 当阶段转换失败时

**计算逻辑说明**:

此方法遍历所有公式的所有组，为每个组的每个条文公式计算结果：

```
for 每个公式:
  for 每个组:
    baseNumber = 用户选择[组.基础数定义.name]
    for 每个条文公式:
      tiaoWenNumber = calculate(baseNumber, 条文公式)
      tiaoWenContent = getTiaoWenContent(tiaoWenNumber)
      results.add(TiaoWenResult)
```

**结果数量计算**:

假设有3个公式：
- 公式1: 2组，共13个条文公式 → 13条结果
- 公式2: 2组，共8个条文公式 → 8条结果
- 公式3: 4组，共8个条文公式 → 8条结果
- **总计**: 29条结果

**示例**:

```dart
// 完整流程
var session = await useCase.initializeSession(...);
session = await useCase.prepareBaseNumberSelection(session);
session = await useCase.submitBaseNumberSelections(
  session: session,
  selections: userSelections,
);

// 计算最终条文
session = await useCase.calculateFinalTiaoWenList(session);

print('✅ 计算完成！');
print('总条文数: ${session.finalTiaoWenList.length}');

// 显示结果
for (final result in session.finalTiaoWenList) {
  print('---');
  print('公式: ${result.formulaName}');
  print('组ID: ${result.groupId}');
  print('基础数: ${result.baseNumber}');
  print('条文编号: ${result.tiaoWenNumber}');
  print('条文内容: ${result.tiaoWenContent}');
  print('计算详情: ${result.calculationDetail}');
}
```

**性能优化建议**:

当前实现每个条文单独查询内容（29次IO），建议优化为批量查询：

```dart
// 推荐的优化方案
final tiaoWenNumbers = <int>[];

// 第一遍: 收集所有条文编号
for (final formula in session.formulas) {
  for (final group in formula.groups) {
    for (final tiaoWenFormula in group.formulas) {
      final tiaoWenNumber = calculateTiaoWenNumber(...);
      tiaoWenNumbers.add(tiaoWenNumber);
    }
  }
}

// 批量查询（1次IO）
final contentMap = await tiaoWenRepository.getTiaoWenContentByNumbers(tiaoWenNumbers);

// 第二遍: 组装结果
// ...
```

---

#### rollbackToPhase

回滚会话到指定的历史阶段。

```dart
Future<HuangJiSession> rollbackToPhase({
  required HuangJiSession session,
  required SessionPhase targetPhase,
})
```

**参数**:
- `session` **(必需)**: 当前会话
  - 类型: `HuangJiSession`

- `targetPhase` **(必需)**: 目标阶段
  - 类型: `SessionPhase`
  - 约束: 必须是历史阶段（存在于 `phaseHistory` 中）

**返回值**:
- 类型: `Future<HuangJiSession>`
- 会话状态: 恢复到目标阶段的完整状态

**抛出异常**:
- `Exception`: 当目标阶段的快照不存在时

**回滚规则**:

1. 只能回滚到已经完成过的阶段（存在快照）
2. 回滚会恢复该阶段的完整状态
3. 回滚后的阶段之后的所有数据都会被清除
4. 回滚后可以重新执行后续流程

**示例**:

```dart
// 完成所有阶段
var session = await completeAllPhases();
assert(session.currentPhase == SessionPhase.finalCalculationComplete);
assert(session.finalTiaoWenList.length == 29);

// 回滚到选择阶段
session = await useCase.rollbackToPhase(
  session: session,
  targetPhase: SessionPhase.baseNumberSelectionReady,
);

// 验证状态
assert(session.currentPhase == SessionPhase.baseNumberSelectionReady);
assert(session.finalTiaoWenList.isEmpty);
assert(session.baseNumberSelections.isNotEmpty);

// 可以重新选择
final newSelections = {...};
session = await useCase.submitBaseNumberSelections(
  session: session,
  selections: newSelections,
);

// 重新计算
session = await useCase.calculateFinalTiaoWenList(session);
```

**UI集成示例**:

```dart
class SessionHistoryWidget extends StatelessWidget {
  final HuangJiSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('会话历史（共 ${session.phaseHistory.length} 个快照）'),
        ...session.phaseHistory.map((snapshot) =>
          ListTile(
            title: Text(_getPhaseLabel(snapshot.phase)),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(snapshot.timestamp)),
            trailing: snapshot.phase == session.currentPhase
              ? Icon(Icons.check_circle, color: Colors.green)
              : IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () async {
                    final useCase = context.read<HuangJiV2UseCase>();
                    await useCase.rollbackToPhase(
                      session: session,
                      targetPhase: snapshot.phase,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已回滚到: ${_getPhaseLabel(snapshot.phase)}')),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }
}
```

---

#### getSelectionBatch

获取批量选择数据，用于UI展示。

```dart
BaseNumberSelectionBatch? getSelectionBatch(HuangJiSession session)
```

**参数**:
- `session` **(必需)**: 当前会话
  - 类型: `HuangJiSession`

**返回值**:
- 类型: `BaseNumberSelectionBatch?`
- 如果会话没有基础数选择数据，返回 `null`

**使用场景**: UI渲染选择界面时使用

**示例**:

```dart
final session = await useCase.prepareBaseNumberSelection(currentSession);
final batch = useCase.getSelectionBatch(session);

if (batch != null) {
  print('选择项数量: ${batch.items.length}');

  for (final item in batch.items) {
    print('${item.name}: ${item.candidates.length} 个候选');
  }
} else {
  print('没有选择数据');
}
```

---

### HuangJiSessionManager

**路径**: `lib/features/huang_ji/huang_ji_session_manager.dart`

**职责**: 会话生命周期和状态管理，负责会话的创建、保存、加载、阶段转换和快照管理

#### 构造函数

```dart
HuangJiSessionManager({
  required SessionRepository sessionRepository,
  required HuangJiV2CalculationStrategy calculationStrategy,
})
```

---

#### createSession

创建新的会话。

```dart
Future<HuangJiSession> createSession({
  required EightChars eightChars,
  required List<HuangJiCalculationFormula> formulas,
  String? sessionName,
})
```

**参数**:
- `eightChars` **(必需)**: 八字
- `formulas` **(必需)**: 公式列表
- `sessionName` *(可选)*: 会话名称

**返回值**:
- 类型: `Future<HuangJiSession>`
- 初始状态: `currentPhase = SessionPhase.initialized`

**示例**:

```dart
final manager = context.read<HuangJiSessionManager>();

final session = await manager.createSession(
  eightChars: myEightChars,
  formulas: allFormulas,
  sessionName: '测试会话',
);

print('会话已创建: ${session.sessionId}');
```

---

#### saveSession

保存会话到仓储。

```dart
Future<void> saveSession(HuangJiSession session)
```

**参数**:
- `session` **(必需)**: 要保存的会话

**示例**:

```dart
final updatedSession = session.copyWith(
  sessionName: '新名称',
);

await manager.saveSession(updatedSession);
```

---

#### restoreSession

从仓储恢复会话。

```dart
Future<HuangJiSession?> restoreSession(String sessionId)
```

**参数**:
- `sessionId` **(必需)**: 会话ID

**返回值**:
- 类型: `Future<HuangJiSession?>`
- 如果会话不存在，返回 `null`

**示例**:

```dart
final session = await manager.restoreSession('session_1234567890');

if (session != null) {
  print('会话已恢复: ${session.sessionName}');
  print('当前阶段: ${session.currentPhase}');
} else {
  print('会话不存在');
}
```

---

#### advanceToPhase

推进会话到下一阶段。

```dart
Future<HuangJiSession> advanceToPhase({
  required HuangJiSession session,
  required SessionPhase targetPhase,
})
```

**参数**:
- `session` **(必需)**: 当前会话
- `targetPhase` **(必需)**: 目标阶段

**返回值**:
- 类型: `Future<HuangJiSession>`
- 更新后的会话，包含新快照

**抛出异常**:
- `InvalidPhaseTransitionException`: 当阶段转换不合法时

**阶段转换规则**:

```
initialized → yuanHuiYunShiCalculated → baseNumberSelectionReady
    → baseNumberSelected → finalCalculationComplete
```

**示例**:

```dart
var session = await manager.createSession(...);

// 只能按顺序推进
session = await manager.advanceToPhase(
  session: session,
  targetPhase: SessionPhase.yuanHuiYunShiCalculated,  // ✅ 合法
);

// 尝试跳过阶段会抛出异常
await manager.advanceToPhase(
  session: session,
  targetPhase: SessionPhase.finalCalculationComplete,  // ❌ 非法
);
// 抛出: InvalidPhaseTransitionException
```

---

#### createSnapshot

创建当前会话的快照。

```dart
SessionSnapshot createSnapshot(HuangJiSession session)
```

**参数**:
- `session` **(必需)**: 要创建快照的会话

**返回值**:
- 类型: `SessionSnapshot`
- 包含完整的会话状态（JSON格式）

**示例**:

```dart
final snapshot = manager.createSnapshot(session);

print('快照ID: ${snapshot.snapshotId}');
print('阶段: ${snapshot.phase}');
print('时间: ${snapshot.timestamp}');
```

---

#### rollbackToSnapshot

回滚到指定快照。

```dart
Future<HuangJiSession> rollbackToSnapshot({
  required HuangJiSession session,
  required String snapshotId,
})
```

**参数**:
- `session` **(必需)**: 当前会话
- `snapshotId` **(必需)**: 快照ID

**返回值**:
- 类型: `Future<HuangJiSession>`
- 恢复后的会话

**抛出异常**:
- `Exception`: 当快照不存在时

---

### HuangJiV2CalculationStrategy

**路径**: `lib/features/huang_ji/huang_ji_v2_calculation_strategy.dart`

**实现路径**: `lib/features/huang_ji/huang_ji_v2_calculation_strategy_impl.dart`

**职责**: 纯计算逻辑（无状态），封装所有数学计算

#### calculateYuanHuiYunShi

计算元会运世。

```dart
YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars)
```

**参数**:
- `eightChars` **(必需)**: 八字

**返回值**:
- 类型: `YuanHuiYunShi`
- 包含: `yuanNumber`, `huiNumber`, `yunNumber`, `shiNumber`, `yuanHuiMergeNumber`, `yunShiMergeNumber`

**计算公式**:

```
元 = 年干支相加
会 = 月干支相加
运 = 日干支相加
世 = 时干支相加
元会互合数 = 元 + 会
运世互合数 = 运 + 世
```

**示例**:

```dart
final strategy = HuangJiV2CalculationStrategyImpl();

final eightChars = EightChars(
  year: JiaZi.GUI_SI,    // 癸巳 = 30
  month: JiaZi.JIA_ZI,   // 甲子 = 1
  day: JiaZi.DING_YOU,   // 丁酉 = 34
  time: JiaZi.GUI_MAO,   // 癸卯 = 40
);

final yhys = strategy.calculateYuanHuiYunShi(eightChars);

print('元: ${yhys.yuanNumber}');        // 30
print('会: ${yhys.huiNumber}');        // 1
print('运: ${yhys.yunNumber}');        // 34
print('世: ${yhys.shiNumber}');        // 40
print('元会互合: ${yhys.yuanHuiMergeNumber}');  // 31
print('运世互合: ${yhys.yunShiMergeNumber}');  // 74
```

---

#### generateCandidates

生成候选数列表。

```dart
List<BaseNumberCandidate> generateCandidates({
  required int initialNumber,
  required CandidateGenerationConfig config,
})
```

**参数**:
- `initialNumber` **(必需)**: 初始数值
- `config` **(必需)**: 候选生成配置

**返回值**:
- 类型: `List<BaseNumberCandidate>`
- 候选数列表（通常21个）

**生成算法**:

```
for i from -count to +count:
  number = initialNumber + (i × offset)
  if minValue ≤ number ≤ maxValue:
    candidates.add(BaseNumberCandidate(
      number: number,
      offsetFromInitial: i × offset,
      isInitial: i == 0
    ))
```

**示例**:

```dart
final config = CandidateGenerationConfig(
  initialNumber: 5000,
  offset: 30,
  count: 10,
  minValue: 1000,
  maxValue: 13000,
);

final candidates = strategy.generateCandidates(
  initialNumber: 5000,
  config: config,
);

print('候选数数量: ${candidates.length}');  // 21

for (final candidate in candidates) {
  print('${candidate.number} (offset: ${candidate.offset})');
}
// 输出:
// 4700 (offset: -10)
// 4730 (offset: -9)
// ...
// 5000 (offset: 0)
// ...
// 5300 (offset: 10)
```

---

#### calculateDerivedBaseNumber

计算派生基础数。

```dart
int calculateDerivedBaseNumber({
  required DataBaseNumberDefinition baseDefinition,
  required YuanHuiYunShi yhys,
})
```

**参数**:
- `baseDefinition` **(必需)**: 基础数定义
- `yhys` **(必需)**: 元会运世

**返回值**:
- 类型: `int`
- 计算后的基础数

---

#### buildDerivationChain

构建派生链路。

```dart
BaseNumberDerivationChain buildDerivationChain({
  required DataBaseNumberDefinition definition,
  required YuanHuiYunShi yhys,
})
```

**参数**:
- `definition` **(必需)**: 基础数定义
- `yhys` **(必需)**: 元会运世

**返回值**:
- 类型: `BaseNumberDerivationChain`
- 包含完整的推导路径

**示例**:

```dart
final chain = strategy.buildDerivationChain(
  definition: derivedDefinition,
  yhys: yhys,
);

print(chain.getFullPath());
// 输出: "元(30) → +年干×1000(3000) → 元会·基础数一(3030)"
```

---

#### calculateTiaoWenNumber

计算条文编号。

```dart
int calculateTiaoWenNumber({
  required int baseNumber,
  required TiaoWenFormulaData formula,
})
```

**参数**:
- `baseNumber` **(必需)**: 基础数
- `formula` **(必需)**: 条文公式数据

**返回值**:
- 类型: `int`
- 条文编号

**计算逻辑**:
```dart
// 条文数 = 基础数 + sum(formula.parts)
final partsSum = formula.parts.fold<int>(
  0,
  (sum, part) => sum + part.rawNumber,
);

final result = baseNumber + partsSum;

// 确保结果在范围内 (≤13000)
return HuangJiBaseNumber.checkToTiaoWenNumber(result);
```

---

### SessionRepository

**路径**: `lib/repository/session_repository.dart`

**职责**: 会话数据存储抽象接口

#### 接口定义

```dart
abstract class SessionRepository {
  Future<void> saveSession(HuangJiSession session);
  Future<HuangJiSession?> loadSession(String sessionId);
}
```

#### 实现: InMemorySessionRepository

内存存储实现（默认），当前实际使用的实现。

```dart
class InMemorySessionRepository implements SessionRepository {
  final Map<String, HuangJiSession> _sessions = {};

  @override
  Future<void> saveSession(HuangJiSession session) async {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<HuangJiSession?> loadSession(String sessionId) async {
    return _sessions[sessionId];
  }
}
```

**限制**:
- 应用重启后数据丢失
- 不支持跨设备同步
- 仅适用于演示和测试

**注意**: SessionManager内部已经实现了内存存储，因此在当前架构中可能不需要额外的Repository层。

#### 自定义实现示例

```dart
// 文件存储实现
class FileSessionRepository implements SessionRepository {
  final Directory storageDir;

  FileSessionRepository({required this.storageDir});

  @override
  Future<void> saveSession(HuangJiSession session) async {
    final file = File('${storageDir.path}/${session.sessionId}.json');
    await file.writeAsString(jsonEncode(session.toJson()));
  }

  @override
  Future<HuangJiSession?> loadSession(String sessionId) async {
    final file = File('${storageDir.path}/$sessionId.json');
    if (!await file.exists()) return null;

    final json = jsonDecode(await file.readAsString());
    return HuangJiSession.fromJson(json);
  }
}

// 在DI中替换
Provider<SessionRepository>(
  create: (_) => FileSessionRepository(
    storageDir: await getApplicationDocumentsDirectory(),
  ),
)
```

---

### TiaoWenRepository

**路径**: `lib/repository/tiao_wen_repository.dart`

**职责**: 条文数据访问

#### 接口定义

```dart
abstract class TiaoWenRepository {
  Future<String?> getTiaoWenContentByNumber(int tiaoWenNumber);
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> tiaoWenNumbers);
}
```

#### getTiaoWenContentByNumber

获取单个条文内容。

```dart
Future<String?> getTiaoWenContentByNumber(int tiaoWenNumber)
```

**参数**:
- `tiaoWenNumber` **(必需)**: 条文编号

**返回值**:
- 类型: `Future<String?>`
- 条文内容，如果不存在返回 `null`

---

#### getTiaoWenContentByNumbers

批量获取条文内容。

```dart
Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> tiaoWenNumbers)
```

**参数**:
- `tiaoWenNumbers` **(必需)**: 条文编号列表

**返回值**:
- 类型: `Future<Map<int, String>>`
- 条文编号到内容的映射

**示例**:

```dart
final numbers = [5000, 5030, 5060];
final contentMap = await repository.getTiaoWenContentByNumbers(numbers);

for (final entry in contentMap.entries) {
  print('${entry.key}: ${entry.value}');
}
```

---

## 数据模型

### HuangJiSession

**路径**: `lib/features/huang_ji_v2_session_models.dart`

会话主模型，包含完整的会话状态。

```dart
class HuangJiSession {
  final String sessionId;
  final String sessionName;
  final EightChars eightChars;
  final List<HuangJiCalculationFormula> formulas;
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

**关键字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `sessionId` | String | 唯一标识符 |
| `formulas` | List | 使用的公式列表（通常3个） |
| `yuanHuiYunShi` | YuanHuiYunShi? | 元会运世数据 |
| `baseNumberSelections` | Map | 基础数选择记录（键为name） |
| `finalTiaoWenList` | List? | 最终条文结果（通常29条），可能为null |
| `currentPhase` | SessionPhase | 当前所处阶段 |
| `status` | HuangJiSessionStatus | 会话状态 |
| `phaseHistory` | List | 所有阶段快照 |
| `startTime` | DateTime | 会话创建时间 |
| `lastActivityAt` | DateTime | 最后活动时间 |
| `endTime` | DateTime? | 会话结束时间，可能为null |
| `errorMessage` | String? | 错误信息，可能为null |

**方法**:

```dart
// 创建新会话
static HuangJiSession create({
  required String sessionId,
  required String sessionName,
  required EightChars eightChars,
  required List<HuangJiCalculationFormula> formulas,
})

// 复制并更新
HuangJiSession copyWith({...})

// 序列化
Map<String, dynamic> toJson()
static HuangJiSession fromJson(Map<String, dynamic> json)

// 辅助属性
bool get canRollback  // 是否可以回滚
```

---

### YuanHuiYunShi

**路径**: `lib/domain/models/yuan_hui_yun_shi.dart`

元会运世数据模型。

```dart
class YuanHuiYunShi {
  final int yuanNumber;          // 元
  final int huiNumber;           // 会
  final int yunNumber;           // 运
  final int shiNumber;           // 世
  final int yuanHuiMergeNumber;  // 元会互合数
  final int yunShiMergeNumber;   // 运世互合数
}
```

---

### BaseNumberSelectionRecord

**路径**: `lib/domain/models/base_number_selection_record.dart`

基础数选择记录。

```dart
class BaseNumberSelectionRecord {
  final String baseNumberDefinitionId;  // 定义ID（使用name）
  final String name;                    // 定义名称
  final BaseNumberDerivationChain derivationChain;  // 推导链
  final CandidateGenerationConfig candidateConfig;  // 候选配置
  final List<BaseNumberCandidate> candidates;       // 候选列表
  final BaseNumberCandidate? selectedCandidate;     // 用户选择
  final SelectionStatus status;                     // 选择状态
  final List<String> relatedGroupIds;              // 关联的组ID
}
```

---

### BaseNumberSelectionBatch

**路径**: `lib/domain/models/base_number_selection_batch.dart`

批量选择数据（用于UI）。

```dart
class BaseNumberSelectionBatch {
  final List<BaseNumberSelectionItem> items;
  final Map<String, List<String>> definitionToGroupsMap;
}
```

---

### BaseNumberSelectionItem

选择项（UI展示）。

```dart
class BaseNumberSelectionItem {
  final String definitionId;
  final String name;
  final String description;
  final BaseNumberDerivationChain derivationChain;
  final List<BaseNumberCandidate> candidates;
  final List<String> relatedGroupIds;
}
```

---

### BaseNumberCandidate

候选数。

```dart
class BaseNumberCandidate {
  final String id;              // 候选ID
  final int number;             // 候选数值
  final int offsetFromInitial;  // 相对于初始值的偏移量
  final String tiaoWenContent;  // 条文内容
  final bool isInitial;         // 是否为初始候选数（偏移量为0）
}
```

**字段说明**:
- `id`: 候选项的唯一标识符
- `number`: 实际的候选数值
- `offsetFromInitial`: 相对于初始数的偏移（例如：初始数5000，候选数5030，偏移为30）
- `tiaoWenContent`: 该候选数对应的条文内容
- `isInitial`: 标记是否为中间的初始候选数（偏移为0的那个）

---

### BaseNumberDerivationChain

**路径**: `lib/domain/models/base_number_selection_record.dart`

派生链路。

```dart
class BaseNumberDerivationChain {
  final DataPredefinedBaseNumber source;         // 源头（元/会/运/世）
  final List<DerivationStep> derivationSteps;    // 派生步骤
  final DataBaseNumberDefinition finalDefinition; // 最终定义

  // 计算最终值
  int get finalValue {
    int value = source.number;
    for (final step in derivationSteps) {
      value += step.value;
    }
    return value;
  }

  // 获取完整路径描述
  String getFullPath() {
    // 示例: "元(30) → +年干×1000(3000) → 元会·基础数一(3030)"
  }
}
```

---

### TiaoWenResult

**路径**: `lib/domain/models/tiao_wen_result.dart`

条文结果。

```dart
class TiaoWenResult {
  final String groupId;           // 组ID
  final String formulaName;       // 公式名称
  final int baseNumber;           // 基础数
  final int tiaoWenNumber;        // 条文编号
  final String tiaoWenContent;    // 条文内容
  final String calculationDetail; // 计算详情
}
```

---

### CandidateGenerationConfig

**路径**: `lib/domain/models/base_number_selection_record.dart`

候选数生成配置。

```dart
class CandidateGenerationConfig {
  final int initialNumber;  // 初始数
  final int offset;         // 步长（默认30）
  final int count;          // 前后各生成数量（默认10）
  final int minValue;       // 最小值（默认1000）
  final int maxValue;       // 最大值（默认13000）
}
```

**生成示例**:

```dart
final config = CandidateGenerationConfig(
  initialNumber: 5000,
  offset: 30,
  count: 10,
  minValue: 1000,
  maxValue: 13000,
);

// 生成: [4700, 4730, ..., 5000, ..., 5300]
// 共21个候选数
```

---

### SessionSnapshot

**路径**: `lib/features/huang_ji_v2_session_models.dart`

会话快照。

```dart
class SessionSnapshot {
  final String snapshotId;            // 快照ID
  final SessionPhase phase;           // 所属阶段
  final DateTime timestamp;           // 创建时间
  final Map<String, dynamic> state;   // 完整状态（JSON）
}
```

---

## 枚举类型

### SessionPhase

**路径**: `lib/features/huang_ji_v2_session_models.dart`

会话阶段。

```dart
enum SessionPhase {
  initialized,                  // 初始化完成
  yuanHuiYunShiCalculated,     // 元会运世已计算
  baseNumberSelectionReady,    // 基础数选择准备完成
  baseNumberSelected,          // 基础数已选择
  finalCalculationComplete,    // 最终计算完成
}
```

**阶段转换规则**:

```
initialized
    ↓
yuanHuiYunShiCalculated
    ↓
baseNumberSelectionReady
    ↓
baseNumberSelected
    ↓
finalCalculationComplete
```

---

### HuangJiSessionStatus

会话状态。

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

---

### SelectionStatus

选择状态。

```dart
enum SelectionStatus {
  pending,    // 待选择
  completed,  // 已完成
}
```

---

## 异常类型

### InvalidPhaseTransitionException

**路径**: `lib/application/managers/huang_ji_session_manager.dart`

无效的阶段转换异常。

```dart
class InvalidPhaseTransitionException implements Exception {
  final SessionPhase currentPhase;
  final SessionPhase targetPhase;

  const InvalidPhaseTransitionException(this.currentPhase, this.targetPhase);

  @override
  String toString() => 'Invalid phase transition: $currentPhase -> $targetPhase';
}
```

**抛出场景**:

```dart
// 尝试跳过阶段
await manager.advanceToPhase(
  session: session,
  targetPhase: SessionPhase.finalCalculationComplete,
);
// 抛出: InvalidPhaseTransitionException(initialized, finalCalculationComplete)
```

---

## 使用示例

### 完整流程示例

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HuangJiDemo extends StatefulWidget {
  @override
  State<HuangJiDemo> createState() => _HuangJiDemoState();
}

class _HuangJiDemoState extends State<HuangJiDemo> {
  HuangJiSession? _session;
  BaseNumberSelectionBatch? _batch;
  Map<String, int> _selections = {};

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final useCase = context.read<HuangJiV2UseCase>();

    // 1. 初始化会话
    final eightChars = EightChars(
      year: JiaZi.GUI_SI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.DING_YOU,
      time: JiaZi.GUI_MAO,
    );

    final formulas = HuangJiFormulaManager.instance.getAllFormulas();

    var session = await useCase.initializeSession(
      eightChars: eightChars,
      formulas: formulas,
      sessionName: '演示会话',
    );

    setState(() {
      _session = session;
    });

    print('✅ 步骤1完成: 会话初始化');
    print('元: ${session.yuanHuiYunShi!.yuanNumber}');
  }

  Future<void> _prepareSelection() async {
    final useCase = context.read<HuangJiV2UseCase>();

    // 2. 准备基础数选择
    var session = await useCase.prepareBaseNumberSelection(_session!);

    final batch = useCase.getSelectionBatch(session);

    setState(() {
      _session = session;
      _batch = batch;
    });

    print('✅ 步骤2完成: 准备选择');
    print('需要选择 ${batch!.items.length} 个基础数');
  }

  Future<void> _submitSelections() async {
    final useCase = context.read<HuangJiV2UseCase>();

    // 3. 提交选择
    var session = await useCase.submitBaseNumberSelections(
      session: _session!,
      selections: _selections,
    );

    setState(() {
      _session = session;
    });

    print('✅ 步骤3完成: 选择已提交');
  }

  Future<void> _calculateFinal() async {
    final useCase = context.read<HuangJiV2UseCase>();

    // 4. 计算最终条文
    var session = await useCase.calculateFinalTiaoWenList(_session!);

    setState(() {
      _session = session;
    });

    print('✅ 步骤4完成: 计算完成');
    print('共生成 ${session.finalTiaoWenList.length} 条结果');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('皇极取数法 V2 演示')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示当前阶段
            if (_session != null)
              Text('当前阶段: ${_session!.currentPhase}'),

            SizedBox(height: 16),

            // 步骤1: 初始化（自动完成）
            if (_session != null &&
                _session!.currentPhase == SessionPhase.yuanHuiYunShiCalculated)
              ElevatedButton(
                onPressed: _prepareSelection,
                child: Text('准备基础数选择'),
              ),

            // 步骤2: 显示选择界面
            if (_batch != null)
              ...[
                Text('需要选择 ${_batch!.items.length} 个基础数'),
                ..._batch!.items.map((item) => _buildSelectionItem(item)),
                ElevatedButton(
                  onPressed: _selections.length == _batch!.items.length
                      ? _submitSelections
                      : null,
                  child: Text('提交选择 (${_selections.length}/${_batch!.items.length})'),
                ),
              ],

            // 步骤3: 计算按钮
            if (_session != null &&
                _session!.currentPhase == SessionPhase.baseNumberSelected)
              ElevatedButton(
                onPressed: _calculateFinal,
                child: Text('计算最终条文'),
              ),

            // 步骤4: 显示结果
            if (_session != null &&
                _session!.currentPhase == SessionPhase.finalCalculationComplete)
              ...[
                Text('✅ 计算完成！共 ${_session!.finalTiaoWenList.length} 条结果'),
                ..._session!.finalTiaoWenList.map((result) => Card(
                  child: ListTile(
                    title: Text(result.formulaName),
                    subtitle: Text('${result.tiaoWenNumber}: ${result.tiaoWenContent}'),
                  ),
                )),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionItem(BaseNumberSelectionItem item) {
    return Card(
      child: ExpansionTile(
        title: Text(item.name),
        subtitle: Text(item.description),
        children: item.candidates.map((candidate) {
          final isSelected = _selections[item.definitionId] == candidate.number;
          return RadioListTile<int>(
            value: candidate.number,
            groupValue: _selections[item.definitionId],
            onChanged: (value) {
              setState(() {
                _selections[item.definitionId] = value!;
              });
            },
            title: Text('编号: ${candidate.number}'),
            subtitle: Text(candidate.tiaoWenContent),
            selected: isSelected,
          );
        }).toList(),
      ),
    );
  }
}
```

---

### 使用ViewModel的示例

```dart
class HuangJiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HuangJiV2ViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('错误: ${viewModel.errorMessage}'));
          }

          switch (viewModel.currentPhase) {
            case SessionPhase.yuanHuiYunShiCalculated:
              return _buildPrepareButton(viewModel);
            case SessionPhase.baseNumberSelectionReady:
              return _buildSelectionUI(viewModel);
            case SessionPhase.baseNumberSelected:
              return _buildCalculateButton(viewModel);
            case SessionPhase.finalCalculationComplete:
              return _buildResults(viewModel);
            default:
              return Center(child: Text('未知状态'));
          }
        },
      ),
    );
  }

  Widget _buildPrepareButton(HuangJiV2ViewModel viewModel) {
    return Center(
      child: ElevatedButton(
        onPressed: () => viewModel.prepareBaseNumberSelection(),
        child: Text('准备基础数选择'),
      ),
    );
  }

  // ... 其他UI构建方法
}
```

---

### 错误处理示例

```dart
try {
  var session = await useCase.initializeSession(
    eightChars: eightChars,
    formulas: formulas,
  );

  session = await useCase.prepareBaseNumberSelection(session);

  session = await useCase.submitBaseNumberSelections(
    session: session,
    selections: selections,
  );

  session = await useCase.calculateFinalTiaoWenList(session);

  print('✅ 成功: ${session.finalTiaoWenList.length} 条结果');
} on InvalidPhaseTransitionException catch (e) {
  print('❌ 阶段转换错误: $e');
} catch (e, stackTrace) {
  print('❌ 未知错误: $e');
  print('堆栈: $stackTrace');
}
```

---

### 测试示例

```dart
import 'package:test/test.dart';

void main() {
  group('HuangJiV2UseCase Tests', () {
    late HuangJiV2UseCase useCase;

    setUp(() {
      final sessionRepo = InMemorySessionRepository();
      final tiaoWenRepo = MockTiaoWenRepository();
      final strategy = HuangJiV2CalculationStrategyImpl();

      final manager = HuangJiSessionManager(
        sessionRepository: sessionRepo,
        calculationStrategy: strategy,
      );

      useCase = HuangJiV2UseCase(
        sessionManager: manager,
        calculationStrategy: strategy,
        tiaoWenRepository: tiaoWenRepo,
      );
    });

    test('完整流程测试', () async {
      // 初始化
      var session = await useCase.initializeSession(
        eightChars: testEightChars,
        formulas: testFormulas,
      );
      expect(session.currentPhase, SessionPhase.yuanHuiYunShiCalculated);

      // 准备选择
      session = await useCase.prepareBaseNumberSelection(session);
      expect(session.currentPhase, SessionPhase.baseNumberSelectionReady);
      expect(session.baseNumberSelections.length, greaterThan(0));

      // 提交选择
      session = await useCase.submitBaseNumberSelections(
        session: session,
        selections: testSelections,
      );
      expect(session.currentPhase, SessionPhase.baseNumberSelected);

      // 计算结果
      session = await useCase.calculateFinalTiaoWenList(session);
      expect(session.currentPhase, SessionPhase.finalCalculationComplete);
      expect(session.finalTiaoWenList.length, equals(29));
    });

    test('回滚测试', () async {
      final completedSession = await completeAllPhases(useCase);

      final rolledBack = await useCase.rollbackToPhase(
        session: completedSession,
        targetPhase: SessionPhase.baseNumberSelectionReady,
      );

      expect(rolledBack.currentPhase, SessionPhase.baseNumberSelectionReady);
      expect(rolledBack.finalTiaoWenList, isEmpty);
    });
  });
}
```

---

## 最佳实践

### 1. 始终使用依赖注入

```dart
// ✅ 好的做法
final useCase = context.read<HuangJiV2UseCase>();
await useCase.initializeSession(...);

// ❌ 不好的做法
final useCase = HuangJiV2UseCase(
  sessionManager: HuangJiSessionManager(...),  // 直接创建
  ...
);
```

### 2. 使用ViewModel管理UI状态

```dart
// ✅ 好的做法 - 通过ViewModel
final viewModel = context.read<HuangJiV2ViewModel>();
await viewModel.initializeSession(...);

// ❌ 不好的做法 - 在Widget中直接调用UseCase
final useCase = context.read<HuangJiV2UseCase>();
await useCase.initializeSession(...);
setState(() { ... });
```

### 3. 错误处理

```dart
// ✅ 好的做法 - 捕获特定异常
try {
  await useCase.advanceToPhase(...);
} on InvalidPhaseTransitionException catch (e) {
  // 处理阶段转换错误
} on Exception catch (e) {
  // 处理其他错误
}

// ❌ 不好的做法 - 捕获所有异常
try {
  await useCase.advanceToPhase(...);
} catch (e) {
  // 过于宽泛
}
```

### 4. 验证前置条件

```dart
// ✅ 好的做法
if (session.currentPhase == SessionPhase.baseNumberSelectionReady) {
  await useCase.submitBaseNumberSelections(...);
} else {
  print('错误: 会话阶段不正确');
}

// ❌ 不好的做法 - 直接调用，依赖异常
await useCase.submitBaseNumberSelections(...);  // 可能抛出异常
```

### 5. 批量操作优化

```dart
// ✅ 好的做法 - 批量查询
final numbers = [5000, 5030, 5060, ...];
final contentMap = await tiaoWenRepo.getTiaoWenContentByNumbers(numbers);

// ❌ 不好的做法 - 循环查询
for (final number in numbers) {
  final content = await tiaoWenRepo.getTiaoWenContentByNumber(number);
}
```

### 6. 使用快照进行实验性操作

```dart
// ✅ 好的做法 - 回滚支持
final originalPhase = session.currentPhase;

try {
  // 尝试新的选择
  session = await useCase.submitBaseNumberSelections(...);
  session = await useCase.calculateFinalTiaoWenList(session);

  // 检查结果
  if (!isResultSatisfactory(session)) {
    // 回滚
    session = await useCase.rollbackToPhase(
      session: session,
      targetPhase: originalPhase,
    );
  }
} catch (e) {
  // 出错也回滚
  session = await useCase.rollbackToPhase(
    session: session,
    targetPhase: originalPhase,
  );
}
```

### 7. 资源管理

```dart
// ✅ 好的做法 - 清理资源
class MyViewModel extends ChangeNotifier {
  @override
  void dispose() {
    _session = null;
    _batch = null;
    super.dispose();
  }
}
```

---

## 版本信息

**当前版本**: 2.0.0
**发布日期**: 2025-10-06
**API稳定性**: Stable

### 变更日志

#### v2.0.0 (2025-10-06)
- ✅ 完整的会话管理系统
- ✅ 基于name的去重逻辑
- ✅ 多公式并行计算支持
- ✅ 快照和回滚机制
- ✅ 批量条文查询优化

---

## 支持和反馈

**文档问题**: 如发现文档错误或不清晰之处，请提交Issue
**API建议**: 欢迎提出API改进建议
**示例需求**: 如需要更多使用示例，请联系开发团队

---

**文档版本**: 1.0
**最后更新**: 2025-10-06
**维护者**: Claude Code
