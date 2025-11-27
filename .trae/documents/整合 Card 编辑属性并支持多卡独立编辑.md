## 问题概述
- 现状：Card 编辑属性分散在 EditorWorkspace、本地 ValueNotifier、Demo 页与 V3 组件构造参数中，出现大量 prop drilling。
- 影响：可维护性差、样式优先级不一致、彩色模式与逐项颜色覆写逻辑重复；未来 gallery 持多卡时难以保证每卡独立编辑。
- 关键证据：
  - V3 构造参数过多（editable_fourzhu_card_impl.dart:35–127）。
  - EditorWorkspace 的 `groupTextStyles` 构建与传递被注释（editor_workspace.dart:324–339、200–203）。
  - Provider+ValueNotifier+setState 混用（editor_workspace.dart:121–126、37–53、152–177）。

## 目标
- 集中管理 Card 编辑属性，统一样式与颜色解析策略。
- 支持 gallery 中多个 Card 的独立编辑、选择与切换。
- 降低组件间参数传递复杂度，提升可测试性与扩展性。

## 总体架构
- 单一来源：以 ViewModel 作为单一事实来源（FourZhuEditorViewModel）。
- 上下文注入：为 `EditableFourZhuCardV3` 引入 `EditableCardContext`（通过 Provider 注入），统一承载编辑状态与样式策略，减少构造参数。
- 模块边界：
  - ViewModel：维护每个卡片的 `CardEditingState`（按 `cardId` 管理）。
  - EditorWorkspace：仅负责把当前选中卡的状态映射到上下文并渲染 V3。
  - Gallery：无状态展示+通知选择；选择状态由 ViewModel 持有并应用模板。

## 数据模型
- 新建 `CardEditingState`（每卡一份）：
  - `pillars`, `rowList`, `padding`（现有三 Notifier 的数据）。
  - `brightness`, `colorPreviewMode`（开关状态）。
  - `cardStyle`（含 `globalFontFamily/globalFontSize/globalFontColor` 与 `groupTextStyles`）。
- 在 `FourZhuEditorViewModel` 中以 `Map<CardId, CardEditingState>` 管理，并暴露当前选中卡 `currentCardId` 与其状态。

## 状态管理与数据流
- Provider：保持 `Consumer<FourZhuEditorViewModel>`（editor_workspace.dart:121–126），但把本地 Notifier 合并为从 VM 派生的只读/可写句柄放入 `EditableCardContext`。
- 事件流：
  - Gallery 点击 → VM `applyPreset`/切换 `currentCardId`（template_gallery_view.dart:47；four_zhu_editor_view_model.dart:347–362、1282–1294）。
  - EditorWorkspace 的编辑操作 → 通过上下文回到 VM 更新对应 `CardEditingState`。
- 迁移策略：暂保留现有 Notifier 接口的适配层，逐步替换为上下文访问。

## 样式与颜色策略
- 统一优先级：行级（RowConfig）→ 分组（groupTextStyles）→ 全局（cardStyle）→ 临时入参覆写。
- 单入口：用 `TextStyleConfig.toTextStyle()` 作为唯一样式生成入口，V3 内移除硬编码默认与分散分支（参考 editable_fourzhu_card_impl.dart:4300–4420；text_style_config.dart:81–96）。
- 颜色解析器：把 `colorfulMode` 与 `perGan/perZhi` 逐项覆写合并为“颜色解析策略接口”，内聚到 V3 的渲染层；外部仅提供开关与策略实现。

## 组件拆分
- EditorWorkspace 拆分：
  - `WorkspaceTopBar`（主题/彩色开关与亮度切换）。
  - `RowConfigMapper`（从 VM 映射 `rowConfigs` → 行视图模型）。
  - `StylePanel`（全局/分组样式编辑）。
- V3 保持渲染职责，移除状态拼接职责；通过 `EditableCardContext` 获取数据。

## 画廊多卡支持
- Gallery 保持无状态，列表源自 VM 的模板与卡集合；点击后仅触发 `currentCardId` 切换与 preset 应用。
- 为每个卡渲染独立缩略图（统一缩略生成器，避免重复解析）。

## API 调整（向后兼容）
- `EditableFourZhuCardV3`：
  - 新增 `context: EditableCardContext`。
  - 标记旧参数为 Deprecated（如 `pillarsNotifier/rowListNotifier/paddingNotifier/globalFont*`）。
  - 恢复并启用 `groupTextStyles` 传入（editor_workspace.dart:200–203、324–339）。

## 迁移步骤
1. 引入 `CardEditingState` 与 `EditableCardContext` 类型与 Provider。
2. 在 VM 中按 `cardId` 管理状态，并提供选中卡的派生 selector。
3. EditorWorkspace 改为从 VM 构建上下文，移除本地重复 Notifier。
4. V3 构造改为接收上下文，保留旧参数适配，逐页迁移（包含 demo 页）。
5. 统一样式解析入口，删除 V3 内硬编码默认分支，落实优先级模型。
6. 统一颜色策略接口，整合 `colorfulMode` 与 per-item 覆写。
7. 拆分 EditorWorkspace 子组件，理清职责与依赖。
8. 为 Gallery 增加缩略图生成器，提升预览与选择体验。
9. 增加单元测试与黄金图（golden tests）：样式优先级、颜色策略、行重排与可见性、multi-card 独立编辑。
10. 渐进式移除 Deprecated 构造参数与适配层。

## 验证与测试
- 单元测试覆盖：
  - `TextStyleConfig` 优先级解析、颜色策略组合。
  - VM 对多卡状态的增删改查与切换。
  - V3 渲染在不同上下文输入下的稳定性。
- UI 验证：Demo 页与 EditorWorkspace 对比；OpenPreview 验证多卡切换与独立编辑。

## 风险与回滚
- 风险：构造参数变更对现有页面影响；样式策略统一可能改变部分视觉。
- 缓解：保留适配层与 Deprecated 参数一个版本周期；提供开关逐项比对（A/B）。
- 回滚：上下文注入失败时，可回退到旧参数路径。

## 交付与里程碑
- Phase 1：`CardEditingState`/Context 引入与 VM 集成。
- Phase 2：V3 适配与样式/颜色策略统一。
- Phase 3：EditorWorkspace 拆分与 Gallery 缩略图。
- Phase 4：测试完善与移除 Deprecated。