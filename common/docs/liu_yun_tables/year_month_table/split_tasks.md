# TASK - 原子化执行清单

## 任务 1: 基础组件提取
- **内容**: 提取 `_InkTheme`, `_DayCellDashedLinePainter`, `_InkHoverRegion` 到独立工具文件。
- **验收**: 代码可被各组件引用。

## 任务 2: 顶部 Tab 与月份轴拆分
- **内容**: 创建 `da_yun_tabs.dart` 和 `month_axis.dart`。
- **验收**: UI 显示一致，Tab 切换正常。

## 任务 3: 年份网格与单元格拆分
- **内容**: 创建 `year_grid.dart` 和 `gan_zhi_cell.dart`。
- **验收**: 年月表格高度恢复正常 (2/3 比例)。

## 任务 4: 日历面板与溢出修复
- **内容**: 创建 `calendar_panel.dart`, `calendar_grid.dart`, `liu_day_cell_widget.dart`。
- **验收**: 
  - 彻底修复 `LiuDayCellWidget` 溢出。
  - 修复 `ShiChenPanel` 高度计算。

## 任务 5: 主文件重构与集成
- **内容**: 清理 `ink_five_dim_yunliu_table.dart`，作为容器调用上述组件。
- **验收**: 整体编译通过，功能闭环。