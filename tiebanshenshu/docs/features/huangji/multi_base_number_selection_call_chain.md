# 皇极模块：多基础数选择调用链与数据流

## 概览
- 目标：梳理 `MultiBaseNumberSelection` 在皇极场景下的端到端调用链与数据流，覆盖 `Domain → Service → ViewModel → UI`。
- 范围：`tiebanshenshu/lib/domain/models/multi_base_number_selection.dart`、`presentation/viewmodels/multi_base_number_selection_view_model.dart`、`presentation/pages/multi_base_number_selection_page.dart`、`domain/services/multi_base_number_selection_service.dart`、`domain/services/candidate_generation_service.dart`、`data/repositories/tiao_wen_repository.dart`。

## 角色与职责
- `MultiBaseNumberSelectionManager`：维护所有基础数选择的集合、当前活跃类型、整体流程状态与阶段。
- `MultiBaseNumberSelectionService`：业务核心，负责初始化主/衍生选择、生成候选、处理选择事件、维护依赖关系。
- `CandidateGenerationService`：通用候选生成器，根据基础数及调整生成条文候选，访问 `TiaoWenRepository`。
- `TiaoWenRepositoryImpl`：数据访问层，从 CSV 资产加载条文列表，提供多种查询函数与缓存。
- `MultiBaseNumberSelectionViewModel`：界面状态与交互协调，封装初始化、选择、重置/重建等逻辑，向 UI 暴露 `MultiSelectionViewState`。
- `MultiBaseNumberSelectionPage`：页面容器，承载顶部导航、主体状态渲染、底部操作区，绑定 ViewModel。

## 核心模型
- `BaseNumberSelectionType`：区分主类型与衍生类型，包含依赖关系信息。
- `BaseNumberSelection`：单一基础数选择的聚合，含状态、候选、已选基础数。
- `BaseNumberSelectionStatus`：`waiting | ready | selecting | selected | error`。

## 调用链（初始化）
1. UI 调用 `MultiBaseNumberSelectionViewModel.initialize(yuanHuiYunShi, requiredTypes, optionalTypes)`。
2. ViewModel 创建 `MultiBaseNumberSelectionManager`，状态置为 `initializing`。
3. ViewModel 调用 Service：`service.initializePrimarySelections(manager, context)`。
   - Service 内部：
     - 读取 `requiredTypes/optionalTypes` 中的主类型集合。
     - 对每个主类型调用 `_generatePrimaryCandidates(type, yuanHuiYunShi)`：
       - 计算该类型基础数来源（`NumberSource: yuanHui | yunShi`）。
       - 调用 `_generateCandidatesAroundNumber(baseNumber)`，交给 `CandidateGenerationServiceImpl`：
         - 生成候选编号（如固定增量列表 `[96, 192, 384, 768]`）与加减调整。
         - `TiaoWenRepository.getByIdList(...)` 拉取条文数据，封装候选。
       - 返回候选集合，更新 `manager` 中对应选择的 `status=ready`。
     - 若所有主类型准备就绪，ViewModel 状态更新为 `selecting`。

## 调用链（用户选择）
1. UI 触发 `viewModel.selectBaseNumber(type, number)`。
2. ViewModel 委托 Service：
   - 若为主类型：标记选中并尝试推进衍生类型初始化。
   - 若为衍生类型：校验其父类型已选中，生成依赖候选并选中。
3. Service `_initializeDerivedSelections(parentType)`：
   - 找到依赖于 `parentType` 的衍生类型集合。
   - 取父类型的选中基础数，调用 `_generateDerivedCandidates(derivedType, parentNumber)`。
   - 更新 `manager` 中该衍生选择的 `status=ready`；当用户选中后置为 `selected`。
4. 当所有 `requiredTypes` 都 `selected`，`manager.status=completed`，ViewModel 状态更新为 `completed`，回调 `onCompleted`。

## 数据流
- 输入：`YuanHuiYunShi`（包含四柱与合并数）、`requiredTypes` 与 `optionalTypes`。
- 中间态：
  - `manager` 存储各类型的候选与选中数。
  - `CandidateGenerationService` 基于基础数与调整生成候选编号列表并回填 `TiaoWenRepository` 的数据。
- 输出：每个类型的最终基础数选择，供后续条文展示与分析使用。

### YuanHuiYunShi 与候选生成的具体关系
- `YuanHuiYunShi` 提供四柱（年、月、日、时）的天干地支与对应 `HuangJiBaseNumber`，以及 `yuanNumber/huiNumber/yunNumber/shiNumber` 与合并数：
  - `yuanHuiMergeNumber`：合并四柱（元/会）计算的基础数。
  - `yunShiMergeNumber`：合并四柱（运/世）计算的基础数。
- 在皇极场景中：
  - 主类型通常来源于 `yuanHuiMergeNumber` 或 `yunShiMergeNumber`（由 `_getNumberSource` 决定）。
  - 衍生类型则依赖于父类型的选中数（可能是上述合并数的调整结果）。
- `CandidateGenerationServiceImpl` 接收基础数与调整策略，产出候选编号（如：基础数 ± 固定增量），并利用 `TiaoWenRepository` 拉取条文数据，形成完整候选。

## 依赖映射与来源规则
- `_getBaseNumberType(type) → BaseNumberType.tiaoWen`（皇极场景统一为条文类基础数）。
- `_getNumberSource(type) → NumberSource.yuanHui | yunShi`（按类型配置映射）。
- 衍生类型从其父类型的选中基础数派生候选。

## 错误与并发处理
- `TiaoWenRepositoryImpl` 使用 `Completer` 保证 CSV 加载并发安全，缓存列表与 Map 加速查询。
- 初始化失败（仓库异常或候选为空）时，将选择状态置为 `error`，ViewModel 切换到 `error` 并提供重试入口（`reinitialize`）。

## 边界与测试建议
- 主类型候选为空：页面显示空态与说明，允许重试或切换类型。
- 父类型未选中时尝试选择衍生：阻止并提示依赖未满足。
- 条文仓库未加载或缺失：Service 捕获异常，ViewModel 进入 `error`。
- 测试建议：
  - Service：主/衍生候选生成、依赖推进、完成态判定。
  - ViewModel：状态迁移（initial → initializing → selecting → completed/error）、重置/重建。
  - Repository：CSV 解析健壮性、并发加载、缓存一致性。

## 与多基础数模型协同
- 若后续需要与 `MultiBaseNumberResult` 聚合：
  - 将各类型选中基础数转为 `BaseNumberModel`。
  - 使用统一的 `TiaoWenListCalculationConfig` 补齐条文编号与数据。
  - 聚合为 `MultiBaseNumberResult`，供上层分析或展示。

## 待办
- [x] 梳理调用链与数据流
- [ ] 结合真实数据样例补充候选生成示例
- [ ] 衍生类型与父类型映射表补充具体枚举