# Editable Eight Char - 0.x 像素溢出系统化修复计划

## 背景与目标
- 背景：在 Flutter Web 的 Flex 布局中，列宽/行高、幽灵列、装饰（margin/padding/border）、分隔线与文本测量的浮点数累加，常引发 0.xxx px 级别的 bottom/right 溢出告警，尤其在复合调整（多项样式与拖拽同时进行）时更显著。
- 目标：提供一套“像素网格对齐 + 总和守恒”的系统方案，跨组件统一治理，确保任何组合调整下不出现 0.xxx 溢出，同时保持视觉与交互一致性。

## 修复原则
- 像素网格对齐（Pixel Snapping）：所有参与父约束比较的最终几何尺寸，统一对齐到物理像素栅格。
- 总和守恒（Sum Preservation）：在数组级别（列宽、行高）先对齐再修正总和，使最终总和与父容器约束严格一致，不溢出也不留缝隙。
- 输入量化（Quantization at Source）：样式编辑输入（padding/margin/border/thickness）按 `devicePixelRatio` 量化，减少浮点误差的源头。
- 动画对齐（Animated Snap）：过渡帧同样需要对齐，避免动画中间帧产生子像素累积误差。
- 绘制精度（Painter Consistency）：分隔线与绘制坐标使用适当的对齐策略（厚度 round、坐标 floor），兼顾锐度与不溢出。

## 技术方案总览
1) 像素网格对齐工具集
- `snapDouble(double v, {mode=floor})`：逻辑 → 物理（乘以 DPR）→ `floor/round` → 逻辑。用于所有参与父约束比较的 `width/height/offset`。
- `snapSize(Size s, {mode=floor})`、`snapInsets(EdgeInsets e, {mode=round})`：批量对齐尺寸与装饰边距。
- `SnapMode` 策略：
  - `floor`：保证不超出父约束（Flex 子项、总宽高、装饰偏移）。
  - `round`：绘制厚度更锐利（分隔线 thickness 等）。

2) 总和守恒算法
- `snapAndFixSum(List<double> values, double targetTotalLogical)`：
  - 将 `values` 转为物理像素并 `floor`，得到 `sumFloor`；与 `targetTotalPhysical` 比较差值 `delta`。
  - 按“1 像素粒度”将 `delta` 分配到一组“可调项”（如最后一列或声明为 flexible 的列/行）。
  - 转回逻辑尺寸后渲染，确保总和与父约束一致、无溢出/缝隙。

3) 输入量化
- 样式编辑器滑块/输入框的步进值按 DPR 量化：一个物理像素对应逻辑步进 `1.0 / dpr`。
- 例如 `dpr=1.25` 时，逻辑步进 0.8，可确保每次调整都落在整数物理像素。

4) 动画过渡对齐
- 对 `AnimatedContainer/AnimatedSlide/Tween<double>` 的中间帧值应用 `snapDouble`，规避动画期间的子像素误差。

5) 绘制层与分隔线
- 分隔线厚度 `thickness` 采用 `round` 对齐；坐标与列/行累计位置采用 `floor` 对齐。
- Painter 所用的 `midYs/rowHeights/colXs` 等数组统一使用 `snapAndFixSum` 或逐项 `snapDouble`，确保绘制层与布局层一致。

## 改造范围与插入点
- 列宽路径：
  - `_colWidthAtIndex(...)`：返回值逐项 `snapDouble(floor)`。
  - `_totalColsWidth(...)`：累积后 `snapDouble(floor)` 或改为 `snapAndFixSum` 对齐数组并守恒总和。
  - 顶/底部抓手行的 `SizedBox.width` 与反馈 `widthOverride` 对齐。
- 行高路径：
  - `_rowCellSize(...)`、`_rowHeightByName(...)` 与 `_rowHeightOverrides[...]` 的最终使用值对齐。
  - 总行高 `totalRowsHeight(...)` 输出 `snapDouble(floor)`；行插入指示 `ghostRowHeight` 对齐。
- 幽灵列/行：
  - `_getGhostColumnWidth(...)`、`_getGhostRowHeight(...)` 输出 `snapDouble(floor)`；网格让位 `AnimatedContainer.width/height` 对齐。
- 装饰偏移与内容宽度：
  - `_pillarDecorationTopOffsetEff/_BottomOffsetEff` 已对齐；内容宽度 `totalColW - decorationW` 的最终使用处也 `snapDouble(floor)`。
- 分隔列与分隔行：
  - `_colDividerWidthEffective` 与 `_rowDividerThickness/_rowDividerHeightEffective` 按策略对齐（宽度/厚度 round，位置/累计 floor）。
- Painter 与叠加层：
  - `midYs/rowHeights/cardWidth/columnXPositions` 统一用 `snapDouble` 或 `snapAndFixSum`，与布局层保持一致。
- 编辑器输入：
  - `padding/margin/border/Divider` 值的 UI 控件步进统一为 `1 / dpr`；
  - 文本颜色、圆角等不影响几何尺寸但需保持对齐使用的装饰值一致。

## 分阶段实施与里程碑
1) 工具落地（D1）
- 在 `common/lib/widgets/editable_fourzhu_card` 引入 `snapDouble/snapSize/snapInsets/snapAndFixSum` 工具（文件或私有方法）。
- 单元测试：不同 `dpr` 下的对齐与总和守恒行为。

2) 列宽/总宽改造（D2）
- `_colWidthAtIndex/_totalColsWidth` 应用对齐与总和守恒，抓手行/数据网格宽度更新。
- 验证：固定/拖拽/插入幽灵列时无溢出。

3) 行高/总高改造（D3）
- 行相关路径与幽灵行对齐，Painter 纵向坐标修正。
- 验证：分隔行、表头行、普通行组合无溢出。

4) 分隔线与绘制层（D4）
- 分隔线厚度 round，对应坐标 floor，贯穿列/行叠加层对齐。
- 验证：不同 DPI 下线条锐度与无溢出并存。

5) 输入量化与动画（D5）
- 编辑器控件步进量化；动画过渡值 `snapDouble`。
- 验证：复合调整（同时改 padding/margin/分隔线/拖拽）无溢出。

6) 交叉场景回归（D6）
- 文本测量波动与极端装饰（超大 padding/border）下仍稳定；
- 多浏览器与不同 DPR 下回归（1.0/1.25/1.5/2.0）。

## 验收标准（可测试）
- 在以下场景中，控制台无 `overflow` 告警：
  - 默认样式 → 逐项调大/调小水平/垂直 `padding` 与每列独立 `margin`；
  - 增加/移除分隔列，调整 `divider` 厚度/高度；
  - 拖拽列/行（含幽灵占位）、插入到任意位置；
  - 顶/底抓手行与数据网格宽度严格一致；
  - 动画过程中（持续拖拽、插入/删除）无瞬时溢出；
  - 在 DPR=1.0/1.25/1.5/2.0 的浏览器中均无告警。

## 风险与回退方案
- 风险：
  - 单纯 `floor` 可能导致总和略小出现“细缝”；通过 `snapAndFixSum` 分配 `delta` 消除。
  - 文本测量在不同渲染后端有微抖动：在“使用处”进行对齐，避免把抖动传递到总和比较。
- 回退：
  - 提供开关（feature flag）以禁用总和守恒仅保留对齐，便于对比与定位；
  - 分支回滚策略：改动集中在工具与有限入口点，易于回退。

## 验证清单（QA）
- 组合调整场景脚本：
  - 同时调节 `padding(H/V)`、每列独立 `margin(H/V)`、分隔线厚度、拖拽插入列/行；
  - 在动画中快速连续调整；
  - 表头/分隔行穿插；
  - 验证右侧/底部无溢出，用例覆盖不同列数与行数。

## 后续计划
- 将该方案抽象为通用布局工具，复用到其它“可编辑栅格/卡片”组件中；
- 总结跨浏览器 DPI 行为差异，形成最佳实践文档；
- 引入自动化 UI 验证（截图对比）与日志监控，持续防回归。