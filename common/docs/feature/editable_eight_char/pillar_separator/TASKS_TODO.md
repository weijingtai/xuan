# 柱分段原子化待办清单

> 目标：当出现行分隔符时，每个柱视觉上分为上/下两个垂直子柱（样式相同且垂直），支持多分隔符扩展；保持度量与拖拽行为稳定。

## 核心逻辑实现 (Core Logic)
- [x] **实现数据分段逻辑 (`_splitRowsBySeparators`)**
  - 已在 `_buildEachPillar` 中内联实现：遍历 `rowPayloads` 和 `columnContent.children`，按 `RowType.separator` 分组。

## 渲染重构 (Rendering Refactor)
- [x] **提取样式构建器 (`_buildStyledPillarSegment`)**
  - 已将样式配置逻辑提取为独立方法 `_buildStyledPillarSegment`。
- [x] **重构主柱构建逻辑 (`_buildEachPillar`)**
  - 已修改 `_buildEachPillar`：
    - 检查 `columnContent` 是否为 `Column` 且子元素数量匹配（`rows.length * 2`）。
    - 遍历行数据，将子元素（GhostRow + Cell）分段。
    - 对每个段落调用 `_buildStyledPillarSegment`。
    - 对分隔符行直接添加（不包裹样式），作为段间间隙。
    - 使用 `Column(mainAxisSize: MainAxisSize.min)` 组合所有部分。
- [x] **改造内容构建器 (`_buildRealPillar`)**
  - *注：采用直接操作 `columnContent.children` 的方式，避免了修改 `_buildPillarCells` 的复杂性。此项已通过上述逻辑覆盖。*

## 侧边栏与布局适配 (Layout & Titles)
- [x] **适配左侧标题栏 (`_buildLeftGripColumn`)**
  - 检查左侧标题栏是否需要同样的视觉分段（通常标题栏背景透明，可能不需要处理，但需确保分隔符行高度正确）。
- [x] **处理分隔符高度**
  - 确认 `RowType.separator` 在 `CardLayoutModel` 中的高度计算逻辑。
  - 确保分隔符行在 UI 上表现为“间隙”或“透明区域”。

## 验证与测试 (Verification)
- [x] **验证基本渲染**
  - 运行应用，检查无分隔符时显示是否正常（回归测试）。
  - 添加分隔符，检查柱子是否被切分为两段，且样式分别应用。
- [x] **验证拖拽行为**
  - 确保分段后的行仍能正常拖拽排序。
- [x] **Golden Test**
  - 更新或新增 Golden Test 覆盖分段场景。
