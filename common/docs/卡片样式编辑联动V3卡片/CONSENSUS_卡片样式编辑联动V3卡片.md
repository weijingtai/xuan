# 阶段1：最终共识（Consensus）

## 明确需求与验收标准
- 需求：侧栏编辑（排版与行配置）应实时影响 EditorWorkspace 内的 V3 卡片。
- 验收：
  - 修改侧栏全局字体家族、字号、颜色，工作区 V3 文本样式即时更新。
  - 修改侧栏行可见性、标题可见性，工作区 V3 行呈现即时更新。

## 技术实现方案
- 将 `EditorWorkspace` 改为订阅 `FourZhuEditorViewModel`：
  - 在 `build` 中通过 `Consumer<FourZhuEditorViewModel>` 读取 `cardStyle` 与 `rowConfigs`。
  - 将 `cardStyle.globalFontFamily/globalFontSize/globalFontColorHex` 传入 `EditableFourZhuCardV3` 的对应属性。
  - 将 `rowConfigs` 转换为 `List<RowInfoPayload>` 并更新 `_rowListNotifier.value`。
  - 标题隐藏通过将 `rowLabel` 置空实现。

## 技术约束与集成
- 保持最小改动，不引入新的状态容器；沿用现有 Provider。
- 不改变 Demo 页或侧栏组件的内部逻辑，仅增加 Workspace 的绑定。

## 任务边界与限制
- 暂不处理卡片装饰（圆角、阴影、背景）与柱间分隔线的完整主题同步。
- 若后续需要扩大范围，另行更新设计与任务拆分。

## 质量门控
- 与现有架构保持一致（Provider 管理的 ViewModel）。
- 验收标准可测试：通过运行 Web 预览手动验证联动效果。
- 不引入破坏性改动，保留默认数据与本地主题切换能力。