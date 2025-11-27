## 修改文件

* `common/lib/widgets/style_editor/row_style_editor_panel.dart`

## 具体改动

* 删除：行项中的 `SwitchListTile`（标题：显示该行），不再提供行级可见性设置

* 保留：`SwitchListTile`（标题：显示标题）

* 文案替换：`内边距 (px)` → `上下内边距 (px)`（仅更改 UI 文案）

* 滑块联动：保持 `onChanged: (v) => vm.updateRowStyle(cfg.type, padding: v)`，`cfg.padding` 语义作为垂直内边距

* 维持：`ColorfulTextStyleEditorV2Enhanced` 组件调用与传参不变（`type/initialConfig/values/onChanged`）

## 联动验证

* 变更后在 Sidebar 的“行样式”分区拖动“上下内边距 (px)”滑块

* 通过 `updateRowStyle` → EditorWorkspace `_applyViewModelToNotifiers` → V3 `_layoutModelSyncListener`，卡片行距与整体尺寸即时更新

## 不改动范围

* 不修改 `RowConfig` 数据结构（复用 `padding` 字段作为垂直内边距）

* 不调整 V3 尺寸模型与监听链路

## 验收

* UI 中不再显示“显示该行”开关

* “上下内边距”滑块生效并触发 V3 重新布局与尺寸重算

