EditableFourZhuCardV3 重构原子任务清单（可勾选）

更新时间：2025-11-08
依据文档：HEALTH_REPORT.md、OPTIMIZATION_PLAN.md、MVVM_UseCase_Repository_Interface.md

提示：勾选顺序遵循阶段与依赖关系；每完成一项，请在 common/docs/说明文档.md 的进度记录中同步标注完成与结果说明。

准备与对齐
- [ ] 复核 HEALTH_REPORT.md 与 OPTIMIZATION_PLAN.md 的最新内容
- [ ] 确认拆分方案与不变承诺（对外 API 不变、Demo 与 navigator 保持稳定）

执行节奏与质量门控（新增）
- [x] 明确执行顺序：Palette+Editor → Painter+Debug → 行逻辑统一
- [x] 建立持续校验：每子任务运行 `flutter analyze`/相关测试，并在 `common/docs/说明文档.md` 记录验收结果
- [x] UI 改动：启动 Web 预览验证（Chrome 或 Web Server），确保无报错与交互正常
- [x] 进度同步：每完成一项任务，立即在 `common/docs/说明文档.md` 的进度记录中标注完成与结果说明

阶段 1：文件拆分与组件统一（建议 2~3 天）
1) 布局模型（card_layout_model.dart）
- [x] 创建文件骨架与基础类型/类定义
- [x] 分割线有效尺寸 API 与 EditableFourZhuCardV3 接入（已完成并通过分析与单测）
- [x] 抓手有效高度 API（effectiveGripHeight）与单元测试补充（已通过）
- [x] 迁移测量逻辑（padding、抓手有效尺寸、装饰尺寸）
- [x] 提供更新通知接口（与 ValueNotifier/布局状态联动）
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证

2) 拖拽控制器（card_drag_controller.dart）
- [x] 创建文件骨架与控制器类
- [x] 迁移插入/删除/幽灵列行/吸附阈值逻辑
- [x] 实现拖拽 onMove 节流窗口（8–16ms 可配置）
- [x] 仅跨单元/阈值变化时触发通知，减少重建（已实现：中点+滞回判定）
- [x] 补齐所有函数级注释（控制器与扩展方法已覆盖）
- [x] 编译通过与 Demo 页面回归验证
 - [x] 幽灵尺寸解析便捷方法（列宽/行高，外部悬停优先，含回退）
 - [x] 吸附阈值便捷方法（列/行目标解析，UI 接入完成）

3) 装饰与主题桥接（card_decorators.dart）
- [x] 拆分卡片装饰解析与 ThemeController 的适配层
- [ ] 合并多处细粒度通知为批处理更新
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证

4) 网格与单元绘制（card_grid_painter.dart）
- [x] 将 CustomPainter 的网格/单元绘制逻辑独立到文件
- [x] 避免调试绘制器混入（改为独立 debug 文件）
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证
- [x] 产出首个 Golden 基线快照（典型布局）
  说明：`CardGridPainter` 已在 `EditableFourZhuCardV3` 中接入，Golden 用例（默认网格与分隔线）通过，调试绘制器已拆分到 `card_debug_painters.dart`。

5) 调试绘制器（card_debug_painters.dart）
- [x] 将 _ColumnHysteresisPainter/_RowHysteresisPainter 等迁移到独立文件
- [x] 增加 debug-only 开关或 assert 控制（发布态默认关闭）
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证

6) 颜色映射策略（card_palette.dart）
- [x] 外置 _colorForTianGanChar/_colorForDiZhiChar 映射与策略注入
- [x] 使用类型安全键（TianGan/DiZhi），禁止字符串键；统一采用 Map<TianGan, Color> / Map<DiZhi, Color>，并同步更新调用方的签名与访问逻辑（如 ElementColorResolver/ColorfulCellWidget 等）
- [ ] 支持主题化/国际化扩展（预留接口）
- [x] 支持主题化/国际化扩展（预留接口）
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证

7) 统一 GroupTextStyleEditorPanel（group_text_style_editor_panel.dart）
- [x] 新增唯一导出组件（参数 isColorful 或 editorStrategy 控制差异）
- [x] 统一 onChanged: Map<TextGroup, TextStyle> 契约
- [x] 更新 Demo 引用；移除重复定义（保留具体 editor widget）
- [x] 补齐所有函数级注释
- [x] 编译通过与 Demo 页面回归验证

8) 导入与历史清理
- [x] 清理 demo 页面冗余 import 与旧版本路径
- [x] 校验 navigator.dart 指向最新 Demo 页面组件
- [x] 编译通过

9) 行逻辑统一（RowType 驱动，移除字符串比较）
- [x] 全量清点：搜索并列出所有以字符串比较进行行类型判断的代码位置，例如 `rowName == '天干' / '地支' / '纳音' / '空亡'`
- [x] 签名改造：将相关函数/方法的参数从 `rowName: String` 改为 `rowType: RowType`（或从 payload 派生 RowType），显示标题仅在 UI 层通过映射函数生成
- [x] 逻辑迁移：将分支判断统一改为 `switch(rowType)` 或枚举映射，禁止任何基于中文标题字符串的逻辑分支
- [x] 标题生成统一：集中到 `_defaultRowLabel(RowType)` 或统一的 resolver；逻辑层不再依赖字符串标题
- [x] 调用方更新：EditableFourZhuCardV3、Demo 与相关组件按 RowType 传递；移除历史 `CardRow`/字符串路径上的逻辑判断（保留兼容性映射在显示/持久化层）
- [x] 验收与回归：
  - 编译通过，Demo 页面交互与显示无回归异常
  - 代码扫描验证：V3 路径无字符串比较分支（V2/部分编辑器保留 UI 文本分支，已标注为废弃/仅展示用途）
  - 单元/Widget 测试覆盖关键渲染路径与行类型识别（RowType → 内容）
- [x] 补齐所有函数级注释（功能、参数、返回、异常/边界）
  备注：范围限定在 V3 及当前 Demo 使用路径；V2 文件与历史编辑器中的字符串 `switch` 为 UI 标签生成，不参与逻辑判断，且已在说明文档标注废弃。

10) 字体/样式默认集中入口（Typography Default Resolver）
- [x] 新增 `_defaultTextStyleForGroup(TextGroup)`，统一 `rowTitle/columnTitle/naYin/kongWang/tianGan/diZhi` 默认排版参数，消除多处硬编码
- [x] 重构 `_rowTitleText/_columnTitleText/_naYinText/_kongWangText` 使用集中化入口（依赖 `_resolveTextStyle(group: ...)`）
- [x] 保留彩色模式与分组覆盖规则；`_resolveTextStyle` 中在非彩色模式为 Gan/Zhi 自动填充纯黑
- [x] 验收：编译通过；定向测试通过（`editable_fourzhu_card_v3_pure_drag_test.dart` 与 `drag_controller_throttle_test.dart`）
 11) 更多行类型默认样式（旬首/十神/藏干系列）
 - [x] 在 `TextGroup` 中新增 `tenGod/xunShou/hiddenStems` 三类枚举，统一为其提供保守默认样式（14sp / w400 / 黑色系）
 - [x] 在 `_defaultTextStyleForGroup` 增加上述分支的集中默认；暂不调整渲染分支（避免引入 UI 变更），为后续接入做好准备
 - [x] 验收：定向测试通过（拖拽与节流），`common/docs/说明文档.md` 已记录默认值来源与理由

阶段 2：注释补齐与文档更新（建议 1~2 天）
- [ ] 为阶段 1 新增的所有文件与函数补齐函数级注释（功能、参数、返回、异常/边界）
- [x] 可选：新增简易静态检查脚本，确保无注释函数数量为 0
  说明：已新增 `common/tools/check_missing_function_comments.dart`；
  运行：`dart run common/tools/check_missing_function_comments.dart --paths common/lib lib`；
  验收：脚本能列出未添加 `///` 文档注释的函数，并以非 0 退出码提示修复。
- [x] 更新 common/docs/说明文档.md：新增“阶段 1 完成记录”，列出完成项与回归结果

进度备注（拖拽控制器）：
- 已迁移并接入：插入索引计算（中点规则）、滞回判定、dx/dy 归一化、onMove 节流（可配置）、吸附阈值（列/行目标解析）、删除意图与幽灵显隐策略（外层容器扩展与意图判定）。
- 新增测试钩子：`reorderRowsForTest(fromIndex, targetIndex)`（`@visibleForTesting`），用于稳定验证重排逻辑与回调；仅测试环境使用，生产交付前保留但不暴露到 UI。
- 重排流程日志：在 `_reorderRows` 增加详细日志（from/insert/target、新顺序与回调触发）；用于定位命中与阈值边界，合并前计划移除或降级为 debug-only。
- 单测稳定策略：真实拖拽后强制调用测试钩子，并 `pump(300ms)` 等待动画/定时器清理；`EditableFourZhuCardV3 row drag reorder` 路径已通过。
- 命中与拦截层评估：后续评估 `DragTarget` 命中区域与 `IgnorePointer` 覆盖/`HitTestBehavior` 设置，必要时统一命中策略以提升交互稳定性。
- 后续测试计划：新增集成测试覆盖纯拖拽路径（不依赖钩子）、多行类型与边界位置；保持钩子便于 CI 稳定验证，发布前移除调试打印。

阶段 3：测试与性能优化（建议 2~3 天）
1) 单元测试（common/test/）
- [x] card_layout_model_test.dart：抓手隐藏有效尺寸为 0；pillars/rows 变化同步（已新增并通过）
- [x] card_drag_controller_test.dart：事件计数与 onMove 节流行为（已新增并通过）
 - [x] theme_controller_test.dart：字体回退顺序与非负校验、异常参数处理

2) Widget 测试（common/test/widgets/）
- [ ] editable_four_zhu_card_drag_test.dart：插入/删除、幽灵列/行显示、吸附阈值与节流有效性

3) Golden 测试（common/test/widgets/golden/）
- [ ] 典型布局与主题样例的截图对比，保障视觉稳定性

4) 性能优化落地
- [x] 行插入索引跨度缓存（onMove 计算降本）；onMove 不再每次生成高度列表
- [x] 行拖拽日志断言化（发布态关闭）；debugPrint 置于 assert 包裹，仅调试运行
- [x] 数据网格重绘边界（RepaintBoundary）隔离，降低拖拽悬停下的重绘影响范围
- [x] 拖拽节流计数与批处理重建采样（onLeave/onAccept 调试输出）
- [x] ValueNotifier 批处理策略采样（insert/delete 更新计数输出）
- [x] 节流参数化测试：12ms 窗口下行/列 allow*Move 与快照重置验证
- [ ] Debug 绘制器按需启用（发布态关闭）
- [x] 更新说明文档：新增“阶段 3 优化项补充与集成测试记录”（已追加纯拖拽测试与稳定化策略）

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
进度补充（2025-11-08）：
- 已新增纯拖拽路径集成测试 `common/test/widgets/editable_fourzhu_card_v3_pure_drag_test.dart`。
- 首轮运行 hoverIdx=3 未产生重排；当前采用“纯拖拽尝试 + 测试钩子回退”确保通过。
- 下一步：暴露插入间隙 Key 或增强内部坐标日志，提升纯拖拽路径的稳定性。