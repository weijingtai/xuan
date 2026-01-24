# ALIGNMENT - ink_five_dim_yunliu_table 组件拆分与修复

## 项目和任务特性规范
- **技术栈**: Flutter (Dart)
- **核心组件**: `InkFiveDimYunLiuTable` (原 monolithic 文件)
- **目标**: 模块化拆分、解决 RenderFlex 溢出、恢复年月表格正确高度。

## 原始需求
1. 修复日历详情面板底部溢出问题。
2. 修复年月表格 cell 高度意外缩减的问题。
3. 将代码拆分为独立的 Widget 和文件以降低复杂度。

## 边界确认
- **任务范围**: 仅限于 `ink_five_dim_yunliu_table.dart` 的重构与相关 Bug 修复。
- **非目标**: 不修改底层数据模型（如 `SolarLunarDateTimeHelper`），不增加新功能。

## 需求理解
- **溢出根源**: `LiuDayCellWidget` 内部的 `Column` (line 1825) 在受限容器中使用了 `mainAxisSize: max` 且缺乏滚动支持。
- **高度混淆**: `_calendarExpandedRowHeight` 计算逻辑被错误地应用或影响了 `_buildGanZhiCell` 的渲染参数。
- **拆分结构**: 
  - `InkFiveDimYunLiuTable`: 骨架
  - `DaYunTabs`: 顶部 Tab
  - `MonthAxis`: 左侧月份轴
  - `YearGrid`: 年份网格区域
  - `CalendarPanel`: 展开的日历容器
  - `CalendarGrid`: 日历网格
  - `LiuDayCellWidget`: 日历天单元格
  - `ShiChenPanel`: 时辰面板

## 疑问澄清
1. **文件组织**: 建议将拆分出的 Widget 放在 `lib/widgets/yun_liu/` 目录下，还是保持在 `lib/` 下？(假设保持在 `lib/` 以减少重构成本，除非用户另有要求)
2. **状态管理**: 目前使用 `setState`，拆分后将通过构造函数传递状态和回调，不引入额外的状态管理库。