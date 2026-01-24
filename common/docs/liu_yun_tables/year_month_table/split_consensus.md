# CONSENSUS - ink_five_dim_yunliu_table 任务共识

## 验收标准
1. **功能完整性**: 拆分后所有交互（Tab 切换、日历展开、时辰切换）功能正常。
2. **Bug 修复**: 
   - 彻底解决日历单元格底部溢出（采用 `FittedBox` 优化或滚动支持）。
   - 年月表格 cell 高度恢复为 `cellW * 2 / 3`。
3. **代码质量**: 
   - 单个文件行数降至 500 行以内。
   - 所有函数具备完整注释。
4. **集成方案**: `ink_five_dim_yunliu_table.dart` 作为入口文件，引用新拆分的组件。

## 技术约束
- 保持现有的 `_InkTheme` 风格。
- 必须兼容 iOS/macOS 渲染特性。
- 严禁修改 `.env` 以外的环境配置。