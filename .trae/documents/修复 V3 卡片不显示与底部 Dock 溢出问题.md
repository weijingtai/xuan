## 现象与原因
- 现象：V3 卡片区域空白且出现黄色斜纹溢出提示。
- 初步原因：
  - 底部 Dock 纵向占用过高，导致上方 `Expanded` 的卡片区域被挤压；窄视口下溢出（Column 总高度超约束）。
  - V3 卡尺寸依赖 `_sizeNotifier`；若行/列或装饰参与计算后返回近 0 尺寸，AnimatedContainer 的宽高趋近 0，视觉上等同“未显示”。

## 改造目标
- 保证卡片区始终有足够空间并能显示正常尺寸；底部 Dock 在内容增多时滚动，不挤压卡片。
- 加入保底尺寸与约束，避免 V3 因计算返回极小值而不可见。

## 调整方案
1. 页面底部 Dock 高度约束与滚动：
  - 为底部 Dock 外层加 `ConstrainedBox(maxHeight: 240)`，内部仍保持左右拆分；
  - 左侧标签栏保留横向滚动（`SingleChildScrollView(horizontal)`）；
  - 右侧面板保持纵向滚动（`SingleChildScrollView`）。
2. EditorWorkspace 布局稳固：
  - 顶部开关行保持原样；卡片区域继续用 `Expanded` 承载（不变）。
3. V3 卡尺寸保底：
  - 在 `_sizeNotifier` 计算尺寸后加入下限：当 `width<64` 或 `height<64` 时，提升到保底尺寸（如 `minCardWidth`, `minCardHeight`）。
  - 或者在 AnimatedContainer 前计算 `safeSize = Size(max(width,64), max(height,64))` 使用。
4. 防御式装饰解析：
  - 读取 Demo VM 主题控制器失败时，卡片与柱装饰落回到默认值，避免参与计算时得到 0 尺寸。

## 修改点
- `common/lib/pages/four_zhu_edit_page.dart`
  - 在底部 Dock 容器外层添加 `ConstrainedBox(maxHeight: 240)`；左右两侧保持当前滚动布局。
- `common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
  - 在 `builder:` 使用尺寸时增加保底 `safeSize`，确保最小宽高（不修改计算链，仅在展示阶段防御）。

## 验证
- 缩小窗口高度或增多面板内容时，卡片仍显示；底部 Dock 出现滚动条，无溢出条纹；
- 拖拽标签插入列/行正常，尺寸随行列与装饰变化联动。

## 风险与回滚
- 风险：保底尺寸可能在极端情况下与布局产生视觉差异。
- 回滚：仅移除保底尺寸逻辑，Dock 高度约束与滚动保留即可保障不溢出。