EditableFourZhuCardV3 重构与优化方案（可执行版）

更新时间：2025-11-07
目标与范围：基于 HEALTH_REPORT.md 的结论，围绕 EditableFourZhuCardV3 及相关编辑面板、主题控制器与 Demo 页面，实施文件拆分、组件统一、注释完善、测试补齐、性能优化与配置外置化。

一、总体目标
- 降低核心组件复杂度与认知负荷，提升可维护性与迭代效率。
- 统一样式编辑面板 API，避免重复定义与行为分叉。
- 补齐函数级注释，满足项目“所有函数需具备注释”的质量规范。
- 建立最小可用测试体系（单元 / Widget / Golden），为复杂交互提供回归保障。
- 优化拖拽交互的性能与状态通知节流，减少不必要重建。
- 外置颜色映射与主题配置，支持可扩展与国际化。

二、分阶段实施计划
阶段 1：文件拆分与组件统一（建议 2~3 天）
- 输出：完成核心文件拆分、统一 GroupTextStyleEditorPanel，清理冗余导入与历史代码。
- 任务清单：
  1) 拆分 EditableFourZhuCardV3：
     - 目标：将 editable_fourzhu_card_impl.dart 拆分为以下子模块文件（路径位于 common/lib/widgets/four_zhu/）：
       a. card_layout_model.dart（布局模型与测量，含 padding、抓手显示与有效尺寸计算）
       b. card_drag_controller.dart（拖拽控制器：插入/删除、节流、吸附阈值、幽灵状态）
       c. card_decorators.dart（装饰与主题解析的桥接，联动 EditableFourZhuThemeController）
       d. card_grid_painter.dart（网格与单元绘制，独立的 CustomPainter 实现）
       e. card_debug_painters.dart（调试绘制器，按 debug-only 条件编译或常驻但默认关闭）
       f. card_palette.dart（颜色映射策略：天干/地支字符颜色映射，可按主题注入）
       · 约束：采用类型安全键（TianGan/DiZhi），禁止字符串键；统一使用 Map<TianGan, Color> / Map<DiZhi, Color>，与现有 AppColors.zodiacGanColors/zodiacZhiColors 保持一致。
     - 输入契约：现有 EditableFourZhuCardV3 的逻辑划分与 HEALTH_REPORT 中的职责分析
     - 输出契约：上述 6 个文件及对 EditableFourZhuCardV3 的引用调整
     - 实现约束：保持现有对外 API 不变；内部私有方法迁移后需具备函数级注释
     - 验收标准：
       · 项目编译通过，Demo 页面功能无回归
       · 新文件结构清晰，依赖无循环
       · 每个新文件中的函数均具备函数级注释

  2) 统一 GroupTextStyleEditorPanel：
     - 目标：消除重复定义，采用单一组件 + 参数驱动（isColorful: bool / editorStrategy）
     - 输入契约：text_style_editor_widget.dart 与 colorful_text_style_editor_widget.dart 中现有实现与 TextGroup 枚举
     - 输出契约：common/lib/widgets/text_style/group_text_style_editor_panel.dart（唯一导出组件）
     - 实现约束：
       · 通过参数控制彩色或普通编辑器的呈现
       · 对外 onChanged: Map<TextGroup, TextStyle> 保持不变
       · 为函数与公开参数补全注释
     - 验收标准：
       · 旧两文件标注为迁移状态或仅保留内部具体 editor widget（不再定义 GroupTextStyleEditorPanel）
       · Demo 页面引用更新到新路径与新 API

  3) 清理导入与旧版本代码：
     - 目标：移除 demo 中历史 import、旧版本卡片路径；navigator.dart 保持指向最新 Demo 页面
     - 验收标准：编译通过，运行 Demo 页面无异常，交互与样式一致

阶段 2：注释补齐与文档更新（建议 1~2 天）
- 输出：函数级注释全面补齐，风格统一；项目文档“说明文档.md”记录计划与进度。
- 任务清单：
  1) 补齐函数级注释：
     - 范围：新拆分的 6 个文件 + EditableFourZhuThemeController + EditableFourZhuStyleEditorPanel + GroupTextStyleEditorPanel（统一版）
     - 标准：
       · 每个函数包含：功能描述、参数说明（类型/用途）、返回值类型与用途、边界与异常说明
       · 中文注释为主，必要时附英文术语
     - 验收：静态检查脚本通过（可选：简易脚本检索无注释函数数量为 0）

  2) 文档更新：
     - 更新 common/docs/说明文档.md，新增“EditableFourZhuCardV3 重构计划与进度”章节：
       · 计划目标、里程碑日期、当前完成项、待办项、风险与回滚策略
       · 与 HEALTH_REPORT.md、OPTIMIZATION_PLAN.md 交叉链接

阶段 3：测试与性能优化（建议 2~3 天）
- 输出：最小可用测试与性能改进，形成稳定回归基础。
- 任务清单：
  1) 单元测试（common/test/）：
     - card_layout_model_test.dart：
       · 验证 padding、抓手可见/不可见时的有效尺寸计算
       · 布局模型在 pillars/rows 变化时的同步行为
     - theme_controller_test.dart：
       · 字体回退顺序、非负数校验、异常参数处理

  2) Widget 测试（common/test/widgets/）：
     - editable_four_zhu_card_drag_test.dart：
       · 拖拽插入/删除、幽灵列/行显示、吸附阈值
       · 节流有效性（onMove 高频下重建次数统计）

  3) Golden 测试（common/test/widgets/golden/）：
     - 典型布局与主题样例的截图对比，保障视觉稳定性

  4) 性能优化：
     - 拖拽节流：在 card_drag_controller.dart 中实现节流窗口（如 8~16ms），仅在位置跨越阈值或网格单元变化时通知
     - ValueNotifier 合并：将多个细粒度通知合并为批处理更新，减少构建压力
     - Debug 绘制器按需启用：通过 bool 开关或 assert 控制调试绘制，避免发布态渲染开销

三、任务原子化定义（示例条目）
示例 A：拆分 card_debug_painters.dart
- 输入契约：现有 editable_fourzhu_card_impl.dart 中的 _ColumnHysteresisPainter、_RowHysteresisPainter 等调试绘制器
- 输出契约：common/lib/widgets/four_zhu/card_debug_painters.dart（保留类名但去除下划线，按文件私有处理或命名空间管理）；在主组件中以条件引用
- 实现约束：无对外 API 改动；补全函数级注释；发布构建默认关闭调试绘制
- 验收标准：Demo 可开启调试模式观察边界与缓冲区，不影响默认渲染

示例 B：统一 GroupTextStyleEditorPanel
- 输入契约：两个现有实现与 TextGroup 枚举
- 输出契约：group_text_style_editor_panel.dart（参数 isColorful: bool = false）
- 实现约束：
  · 保持现有 onChanged Map<TextGroup, TextStyle> 语义一致
  · 内部根据 isColorful 选择 ColorfulTextStyleEditorWidget 或 TextStyleEditorWidget
- 验收标准：Demo 页面切换 isColorful 行为一致；旧文件不再对外导出重复组件

四、依赖关系图（Mermaid）
graph TD
    A[EditableFourZhuCardV3] --> B[card_layout_model]
    A --> C[card_drag_controller]
    A --> D[card_decorators]
    A --> E[card_grid_painter]
    A --> F[card_debug_painters]
    A --> G[card_palette]
    D --> H[EditableFourZhuThemeController]
    I[GroupTextStyleEditorPanel] --> H

五、时间线与里程碑（建议）
- 2025-11-07：阶段 1 启动，完成文件结构设计与迁移草案
- 2025-11-08：完成文件拆分与组件统一，Demo 编译与功能回归通过
- 2025-11-09：阶段 2 注释补齐与说明文档更新完成
- 2025-11-10~2025-11-11：阶段 3 测试与性能优化完成，形成初始测试套件与性能报告

六、风险与回滚策略
- 风险：拆分可能引入隐性依赖与状态同步问题；拖拽节流变更可能影响交互体验
- 回滚：保留原 editable_fourzhu_card_impl.dart 的备份文件与标签；若测试未通过，逐步回滚到拆分前版本，并按模块逐一复核

七、变更影响与不变承诺
- 不改变对外 API（构造参数、通知类型与枚举值保持稳定）
- 仅重构内部实现与文件结构，向后兼容 Demo 页面与 navigator 路由

八、后续 TODO（与说明文档联动）
- 完成阶段 1 后，补充“实施记录与结果说明”，标注完成时间与验证情况
- 完成测试后，记录覆盖范围与缺口，制定增量补测计划

九、阶段 4：MVVM + UseCase + Repository（自定义样式读写“开箱即用”接口）
- 目标：提供可直接在 Demo 与正式页面接入的主题读写与订阅接口层，支持 Memory 与 Local JSON 两套仓库默认实现。
- 交付物：
  1) Repository 接口定义与两套默认实现（Memory/Local JSON）
  2) UseCase：LoadTheme、SaveTheme、UpdateGroupTextStyle、ValidateTheme
  3) ViewModel：EditableFourZhuThemeViewModel（含加载/更新/保存/校验接口）
  4) 集成示例：在 Demo 页面接入并演示配置档切换与保存
  5) 文档：MVVM_UseCase_Repository_Interface.md（已新增，详细契约与集成说明）
- 任务清单：
  · 定义仓库接口（domain/repositories）与路径
  · 内存与本地 JSON 实现（datasource/style）
  · 用例实现（domain/usecases/style）
  · 主题 ViewModel（viewmodels）
  · Demo 接入与导航保持不变
  · 单元/Widget/Golden 测试与说明文档更新
- 实现约束：
  · 不改变对外渲染 API；仅新增接口层与示例接入
  · 所有函数具备函数级注释（功能/参数/返回值/异常）
  · 保存前必须通过 Validate 用例校验
- 验收标准：
  · Demo 页面可加载/更新/保存/切换配置档，无崩溃
  · 两套仓库实现均可用（Memory/Local JSON）
  · 测试通过并形成最小可用回归基础
- 时间线建议：
  · 2025-11-12：接口与骨架实现（Memory/Local JSON + UseCase + ViewModel）
  · 2025-11-13：Demo 接入与单元/Widget/Golden 测试
  · 2025-11-14：文档与示例完善，形成“开箱即用”交付包

附录：测试样例骨架（伪代码片段）
- card_layout_model_test.dart
  · test('抓手隐藏时有效尺寸为 0') {...}
  · test('pillars/rows 变化时布局模型同步') {...}
- editable_four_zhu_card_drag_test.dart
  · testWidgets('拖拽跨越阈值时触发插入，并显示幽灵列') {...}
  · testWidgets('高频 onMove 下节流生效，重建次数受控') {...}

注：本方案与 HEALTH_REPORT.md 联动执行，按阶段输出与验收标准逐条核验。