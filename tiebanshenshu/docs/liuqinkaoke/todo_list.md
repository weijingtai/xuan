# 六亲考刻取数法 TODO 列表（可勾选）

说明：所有开发基于 `tiebanshenshu` 子项目，尽量避免改动现有代码。新增代码统一放置在 `lib/features/liuqinkaoke` 目录。整体架构与“皇极取数 v2”保持贴近，满足可回滚、可跳步、可恢复的 Session；同页选择先天/后天；一次性展示 7 个先天与 7 个后天候选；Strategy 仅做计算，Repository 拉取条文，UseCase 负责编排。

## 里程碑 A：文档与接口对齐
- [x] 定义策略输入输出规范，明确不涉及 Session/Repository
- [x] 明确候选的来源标注（先天/后天、变爻位、基本卦/互卦）
- [x] 明确 UseCase 阶段推进与回滚/跳步策略

## 里程碑 B：目录与占位文件
- [x] 创建目录 `lib/features/liuqinkaoke/`
- [x] 添加 `strategy/`、`usecase/`、`models/`、`viewmodels/`、`pages/` 子目录
- [x] 添加占位实现文件：`liuqinkaoke_calculation_strategy.dart`
- [x] 添加占位实现文件：`liuqinkaoke_use_case.dart`
- [x] 添加占位模型文件：`liuqinkaoke_models.dart`
- [x] 添加占位视图模型文件：`liuqinkaoke_view_model.dart`
- [x] 添加占位页面：`liuqinkaoke_selection_page.dart`

## 里程碑 C：策略实现（仅计算）
- [x] 实现 Innate/Acquired 上/下卦确定逻辑（基于太玄映射，性别、年干阴阳）
- [x] 集成 `PureSixYaoGua` 生成基本卦与互卦
- [x] 遍历变爻位（不变 + 初到六爻），为先天与后天各生成 7 个候选
- [x] 四位拼合规则（上/下卦先/后天数 + 互卦上/下卦数），并折返 ≤13000
- [x] 保留原始数值 `rawNumber`，并提供 `number` 只读计算属性（>13000 则返回 `rawNumber - 12000`），与 `DataBaseNumberDefinition` 设计一致
- [x] 返回候选集合（包含来源标注与变爻位），不含条文内容

## 里程碑 D：UseCase 编排（贴近皇极 v2）
- [x] 初始化 Session（记录八字、年干阴阳、性别、必要上下文）
- [x] 调用策略生成 14 个候选，批量拉取条文内容，构造 `BaseNumberSelectionItem`
- [ ] 持久化 `BaseNumberSelectionRecord`（两项分组：先天/后天）
- [x] 进入 `baseNumberSelectionReady` 阶段
- [x] 同页提交选择（必须包含先天与后天），进入 `baseNumberSelectionCompleted`
- [x] 计算最终条文列表（±48*n，n∈[2,4,8,16]），并标注来源与变爻位；保留派生计算的 `rawNumber`
- [x] 进入 `finalTiaoWenListReady` 阶段；支持回滚/跳步/恢复

## 补充：Session 设计与讨论摘要（源自此前共识）
- 目标与原则：
  - 会话可回滚（rollbackTo）、可跳步（jumpTo）、可恢复（resumeFromSnapshot），幂等、可审计。
  - 阶段推进严格校验，禁止越权推进；提交选择前必须完成先天/后天双项。
  - 保留原始数 `rawNumber` 与派生链 `derivationChain`，确保可追溯。
- 生命周期/阶段（有限状态机）：
  - `init` → `baseNumberSelectionReady` → `baseNumberSelectionCompleted` → `finalTiaoWenListReady`
  - 约束：
    - 仅当先天与后天均已选择且校验通过，方可进入 `baseNumberSelectionCompleted`。
    - 回滚只能回到已完成的前一阶段；跳步需满足目标阶段的前置校验。
- 数据结构（建议）：
  - `LiuQinKaokeSession`：`id`、`version`、`stage`、`fourZhu`、`gender`、`candidateSet`、`selectedInnate`、`selectedAcquired`、`finalTiaoWenList`、`derivationChain`、`createdAt`、`updatedAt`。
  - `SessionSnapshot`：快照 `id`、会话 `id`、`stage`、`payload`（JSON）、`timestamp`。
- 快照与恢复：
  - `snapshot()` 在关键阶段落盘；`resumeFromSnapshot(id)` 恢复上下文并重新计算不可持久化的派生结果。
  - 当前使用 `InMemorySessionRepository`（开发态），后续可切换到持久化实现。
- 依赖注入与职责：
  - `LiuQinKaokeSessionManager` 负责状态推进、回滚/跳步、快照；
  - `LiuQinKaokeUseCase` 编排策略计算与仓库访问；
  - `ViewModel` 持有 UseCase/SessionManager，并暴露只读 UI 状态与提交动作。

### 待办（新增，与 Session 相关）
- [x] 定义 `LiuQinKaokeSession` 模型与阶段枚举（含快照/版本字段）
- [x] 实现 `LiuQinKaokeSessionManager`（start/rollback/jump/resume/snapshot）
- [x] 集成 `SessionRepository`（默认 InMemory，实现接口可替换）
- [x] 在 `LiuQinKaokeUseCase` 接入会话推进与校验逻辑
- [x] 在页面初始化时尝试恢复最近一次会话（若存在快照）
- [ ] 输出阶段事件日志（便于审计与调试）

## 里程碑 E：UI 页面与交互
- [x] 新增 `liuqinkaoke_selection_page`，同页展示先天/后天候选（各 7 项）
- [x] 候选卡片展示：数字、条文摘要、变爻位、基本卦/互卦名称
- [x] 选择校验与提交：必须完成先天与后天两项
- [x] 最终条文列表页：按先天/后天分组并显示偏移标注
- [x] 接入导航与依赖注入，保持与 `navigator.dart`、`strategy_providers.dart` 用法一致

## 里程碑 F：测试与验收
- [x] 策略单元测试（映射正确性、互卦/变爻遍历、折返逻辑、rawNumber 保留）
- [x] UseCase 流程测试（阶段推进、回滚、提交校验、条文标注）
- [ ] UI 交互测试（双栏选择、一致性校验、预览条文）
- [ ] 文档补充与示例数据（基于 `DevConstant.dev_usa`）

## 风险与约束
- [ ] 避免修改现有“皇极 v2”代码，仅新增并复用公共模型与服务
- [ ] 候选来源标注如需额外字段，优先使用扩展模型或 `derivationChain` 描述，减少跨模块改动
- [ ] 条文拉取以数字直取，必要时在 UseCase 中做标注拼接

## 补充：条文拉取与 UI 展示（按编号）
- 目标：
  - 基于候选的 `rawNumber` 及派生偏移（±48*n，n∈[2,4,8,16]）生成最终条文编号列表；
  - 通过 `TiaoWenRepository` 按编号批量获取条文内容，并在 UI 分组展示（先天/后天），保留来源与变爻位标注。
- 设计要点：
  - UseCase 中完成编号计算与分组，组装成可展示模型（编号、标题/摘要、来源标签、变爻位、基本卦/互卦名称、rawNumber）。
  - Repository 支持按编号批量查询；优先启用缓存，避免重复拉取。
  - ViewModel 暴露加载状态（loading/loaded/error）、空态与错误态；支持分页或懒加载以优化长列表。
  - UI 卡片信息：条文编号、标题/摘要、来源（先天/后天）、变爻位、基本卦/互卦；点击可展开详情或进入详情页。
- 待办：
  - [x] 在 UseCase 中实现条文编号列表计算与分组（含偏移与来源/变爻位标注）
  - [x] 集成 `TiaoWenRepository` 的按编号批量获取能力（含缓存/并发优化）
  - [x] 定义用于展示的条文项模型（编号、摘要、标签、派生链/rawNumber）
  - [ ] 在 ViewModel 增加条文加载/刷新逻辑与状态管理
  - [ ] 新增最终条文列表页 UI（分组：先天/后天），卡片包含编号与摘要等信息
  - [ ] 处理空态与错误态（无条文/加载失败提示），完善交互与回滚支持
## 补充：UseCase 与会话编排
- 目标：
  - 用 UseCase 串联：候选生成 → 编号计算 → 仓库拉取 → 分组 → 会话推进；
  - 支持会话快照恢复、回滚与跳跃，确保幂等与一致性。
- 设计要点：
  - 阶段枚举 `LiuQinKaokeStage` 与会话模型 `LiuQinKaokeSession` 的定义；
  - `LiuQinKaokeSessionManager` 提供推进、回滚、跳跃与快照能力；
  - `SessionRepository` 负责持久化与读取；通过依赖注入将 `SessionManager/UseCase/ViewModel` 串联；
  - 页面初始化触发快照恢复；会话变更事件记录日志与指标，便于诊断。
- 待办：
  - [x] 定义 `LiuQinKaokeSession` 模型与阶段枚举
  - [x] 实现 `LiuQinKaokeSessionManager`（推进、回滚、跳跃、快照）
  - [x] 集成 `SessionRepository`（持久化、读取、清理）
  - [x] 将编号计算管线接入 `LiuQinKaokeUseCase`
  - [x] 在页面初始化实现会话快照恢复
  - [ ] 添加会话阶段变化日志与指标埋点
  - [x] 处理回滚/跳跃的边界校验与幂等
  - [x] 暴露 ViewModel 状态与事件（`loading/loaded/error` + `stage`）
  - [x] 为会话提供测试覆盖（生命周期、恢复、边界条件）