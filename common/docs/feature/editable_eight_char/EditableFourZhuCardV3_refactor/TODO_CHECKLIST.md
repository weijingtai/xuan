EditableFourZhuCardV3 重构原子任务清单（可勾选）

更新时间：2025-11-07
依据文档：HEALTH_REPORT.md、OPTIMIZATION_PLAN.md、MVVM_UseCase_Repository_Interface.md

提示：勾选顺序遵循阶段与依赖关系；每完成一项，请在 common/docs/说明文档.md 的进度记录中同步标注完成与结果说明。

准备与对齐
- [ ] 复核 HEALTH_REPORT.md 与 OPTIMIZATION_PLAN.md 的最新内容
- [ ] 确认拆分方案与不变承诺（对外 API 不变、Demo 与 navigator 保持稳定）

阶段 1：文件拆分与组件统一（建议 2~3 天）
1) 布局模型（card_layout_model.dart）
- [x] 创建文件骨架与基础类型/类定义
- [x] 分割线有效尺寸 API 与 EditableFourZhuCardV3 接入（已完成并通过分析与单测）
- [x] 抓手有效高度 API（effectiveGripHeight）与单元测试补充（已通过）
- [ ] 迁移测量逻辑（padding、抓手有效尺寸、装饰尺寸）
- [ ] 提供更新通知接口（与 ValueNotifier/布局状态联动）
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

2) 拖拽控制器（card_drag_controller.dart）
- [x] 创建文件骨架与控制器类
- [ ] 迁移插入/删除/幽灵列行/吸附阈值逻辑
- [ ] 实现拖拽 onMove 节流窗口（8–16ms 可配置）
- [ ] 仅跨单元/阈值变化时触发通知，减少重建
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

3) 装饰与主题桥接（card_decorators.dart）
- [ ] 拆分卡片装饰解析与 ThemeController 的适配层
- [ ] 合并多处细粒度通知为批处理更新
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

4) 网格与单元绘制（card_grid_painter.dart）
- [ ] 将 CustomPainter 的网格/单元绘制逻辑独立到文件
- [ ] 避免调试绘制器混入（改为独立 debug 文件）
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证
- [ ] 产出首个 Golden 基线快照（典型布局）

5) 调试绘制器（card_debug_painters.dart）
- [ ] 将 _ColumnHysteresisPainter/_RowHysteresisPainter 等迁移到独立文件
- [ ] 增加 debug-only 开关或 assert 控制（发布态默认关闭）
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

6) 颜色映射策略（card_palette.dart）
- [ ] 外置 _colorForTianGanChar/_colorForDiZhiChar 映射与策略注入
- [ ] 使用类型安全键（TianGan/DiZhi），禁止字符串键；统一采用 Map<TianGan, Color> / Map<DiZhi, Color>，并同步更新调用方的签名与访问逻辑（如 ElementColorResolver/ColorfulCellWidget 等）
- [ ] 支持主题化/国际化扩展（预留接口）
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

7) 统一 GroupTextStyleEditorPanel（group_text_style_editor_panel.dart）
- [ ] 新增唯一导出组件（参数 isColorful 或 editorStrategy 控制差异）
- [ ] 统一 onChanged: Map<TextGroup, TextStyle> 契约
- [ ] 更新 Demo 引用；移除重复定义（保留具体 editor widget）
- [ ] 补齐所有函数级注释
- [ ] 编译通过与 Demo 页面回归验证

8) 导入与历史清理
- [ ] 清理 demo 页面冗余 import 与旧版本路径
- [ ] 校验 navigator.dart 指向最新 Demo 页面组件
- [ ] 编译通过

9) 行逻辑统一（RowType 驱动，移除字符串比较）
- [ ] 全量清点：搜索并列出所有以字符串比较进行行类型判断的代码位置，例如 `rowName == '天干' / '地支' / '纳音' / '空亡'`
- [ ] 签名改造：将相关函数/方法的参数从 `rowName: String` 改为 `rowType: RowType`（或从 payload 派生 RowType），显示标题仅在 UI 层通过映射函数生成
- [ ] 逻辑迁移：将分支判断统一改为 `switch(rowType)` 或枚举映射，禁止任何基于中文标题字符串的逻辑分支
- [ ] 标题生成统一：集中到 `_defaultRowLabel(RowType)` 或统一的 resolver；逻辑层不再依赖字符串标题
- [ ] 调用方更新：EditableFourZhuCardV3、Demo 与相关组件按 RowType 传递；移除历史 `CardRow`/字符串路径上的逻辑判断（保留兼容性映射在显示/持久化层）
- [ ] 验收与回归：
  - 编译通过，Demo 页面交互与显示无回归异常
  - 代码扫描验证：项目中不再存在上述字符串比较分支
  - 单元/Widget 测试覆盖关键渲染路径与行类型识别（RowType → 内容）
- [ ] 补齐所有函数级注释（功能、参数、返回、异常/边界）

阶段 2：注释补齐与文档更新（建议 1~2 天）
- [ ] 为阶段 1 新增的所有文件与函数补齐函数级注释（功能、参数、返回、异常/边界）
- [ ] 可选：新增简易静态检查脚本，确保无注释函数数量为 0
- [ ] 更新 common/docs/说明文档.md：新增“阶段 1 完成记录”，列出完成项与回归结果

阶段 3：测试与性能优化（建议 2~3 天）
1) 单元测试（common/test/）
- [x] card_layout_model_test.dart：抓手隐藏有效尺寸为 0；pillars/rows 变化同步（已新增并通过）
- [x] card_drag_controller_test.dart：事件计数与 onMove 节流行为（已新增并通过）
- [ ] theme_controller_test.dart：字体回退顺序与非负校验、异常参数处理

2) Widget 测试（common/test/widgets/）
- [ ] editable_four_zhu_card_drag_test.dart：插入/删除、幽灵列/行显示、吸附阈值与节流有效性

3) Golden 测试（common/test/widgets/golden/）
- [ ] 典型布局与主题样例的截图对比，保障视觉稳定性

4) 性能优化落地
- [ ] 拖拽节流窗口与阈值变更通知策略生效（日志或计数验证）
- [ ] ValueNotifier 批处理策略生效（重建次数降低）
- [ ] Debug 绘制器按需启用（发布态关闭）
- [ ] 更新说明文档：新增“阶段 3 完成记录与性能报告摘要”

阶段 4：MVVM + UseCase + Repository（建议 2~3 天）
1) Repository（domain/repositories）
- [ ] 定义 EditableFourZhuStyleRepository 接口文件
- [ ] MemoryEditableFourZhuStyleRepository 实现（内存 Map + 广播流）
- [ ] LocalJsonEditableFourZhuStyleRepository 实现（schemaVersion + 读写校验）

2) UseCase（domain/usecases/style）
- [ ] LoadThemeUseCase
- [ ] SaveThemeUseCase（保存前校验）
- [ ] UpdateGroupTextStyleUseCase（不可变更新）
- [ ] ValidateThemeUseCase

3) ViewModel（viewmodels）
- [ ] EditableFourZhuThemeViewModel：加载/更新/保存/校验；可选订阅 watchTheme
- [ ] 函数级注释完整

4) Demo 集成与示例
- [ ] Demo 初始化仓库、用例与 ViewModel
- [ ] 编辑器面板 onChanged → updateGroupStyle 联动
- [ ] “保存”按钮 → saveCurrentTheme 接入
- [ ] 配置档切换与管理（列出/删除/新建）示例（可选）
- [ ] 更新说明文档：新增“阶段 4 完成记录与接口使用指引”

5) 文档与测试
- [ ] 完成 Repository/UseCase/ViewModel 的单元测试
- [ ] 完成 Widget/Goden 的回归测试（关键路径）

里程碑与验收
- [ ] 阶段 1 完成：编译通过、Demo 回归无异常；新文件结构清晰、依赖无循环；每个新文件函数注释完整
- [ ] 阶段 2 完成：注释覆盖达标；说明文档更新到位
- [ ] 阶段 3 完成：单元/Widget/Golden 测试通过；性能优化生效（重建次数/日志）
- [ ] 阶段 4 完成：开箱即用接口可用；Demo 成功接入；说明文档含使用指引

时间线（建议）
- [ ] 2025-11-07：阶段 1 启动与拆分方案确定
- [ ] 2025-11-08：完成文件拆分与组件统一；Demo 编译与回归通过
- [ ] 2025-11-09：注释补齐与说明文档更新
- [ ] 2025-11-10~2025-11-11：测试与性能优化完成（阶段 3）
- [ ] 2025-11-12~2025-11-14：阶段 4 接口层落地与 Demo 接入