# Eight Chars Template TODOs

- [x] 完善 `LayoutTemplateRepository` 接口的文档注释，明确异常约定与返回值约束。
- [x] 调整模板 DTO 及 mapper，确保 `version`、`updatedAt` 能被 SharedPreferences/Drift 正确覆盖。
- [x] 实现 SharedPreferences 版 `LayoutTemplateLocalDataSource`，完成序列化/反序列化逻辑。
- [x] 为本地数据源补齐 `LayoutTemplateRepository` 实现，处理底层异常映射。
- [x] 编写获取/更新/删除模板名称的 Use Case，补齐业务校验。
- [x] 构建 `FourZhuEditorViewModel`（ChangeNotifier），封装加载、选择、保存、删除等编辑行为。
- [x] 回归 `lib/pages/four_zhu_edit_page.dart`，通过 Provider 将 ViewModel 与响应式 UI 连接。
- [x] 修复 `flutter analyze` 提示，按照建议使用 `withValues`、`initialValue`、`const` 等 API。
- [x] 为 ViewModel 补充数据源单元/小部件测试，覆盖加载、可见性、持久化流程。
- [x] 更新开发文档，记录 SharedPreferences 实现现状及迁移 Drift 的注意事项。


## 顶栏导航
- [x] **顶栏骨架与状态同步**
  - [x] 新建 `EditorTopBar`（或等价组件），包含模板标签区、过滤标签区、操作按钮组的布局。
  - [x] 通过 `Consumer`/`Selector` 监听 `FourZhuEditorViewModel.uiState`，同步高度、阴影、禁用态与当前视图模式。
  - [x] 为标签页和主要按钮补齐 `Semantics`、`FocusTraversalGroup`、`ShortcutActivator`，支持键盘切换和无障碍需求。
- [x] **模板标签页逻辑**
  - [x] 将标签页切换事件绑定到 `viewModel.selectTemplateByTab(TabId)` 并持久化当前选项。
  - [x] 设计选中/聚焦态的高对比度样式，适配深浅色主题与高对比度模式。
  - [x] 在标签组末尾嵌入「+ 新建模板」按钮，调用 `viewModel.createTemplate()` 并弹出命名对话框。
- [x] **操作按钮行为**
  - [x] 点击 `TemplateGallery` 图标时，通过 `showDialog` 调用 `viewModel.openTemplateGallery()`，返回选中模板 ID。
  - [x] 展示模式切换按钮关联 `viewModel.displayMode`（列表/卡片/预览），为每种状态提供独立图标、禁用逻辑与 tooltip。
  - [x] 夜间模式切换按钮与 `EditorTheme` 同步，切换时刷新 `ThemeData` 并写入持久化偏好。
  - [x] 保存/撤销按钮根据 `viewModel.isSaving`、`viewModel.hasPendingChanges` 切换 loading、禁用与 tooltip 描述。

## 模板页
- [x] **模板列表容器**
  - [x] 抽离模板页为独立 `TemplateGalleryView` Widget，负责注入筛选、排序、滚动控制。
  - [x] 使用 `ScrollController` + `PageStorageKey` 记录/恢复滚动位置，确保切换模板集后状态不丢失。
  - [x] 将筛选条件、关键字搜索与 `viewModel.filterState` 绑定，提供空态/加载态渲染。
- [x] **模板预览卡样式**
  - [x] 重写卡片颜色映射，支持主色、互补色、辅助色方案并兼容浅色/深色主题。
  - [x] 为卡片 hover/选中/禁用态添加动效（`AnimatedContainer`、`InkWell` ripple 等）。
  - [x] 在卡片右上角加入操作菜单（收藏、重命名、复制、删除），操作前弹出确认或输入对话框。
- [x] **模板列表功能**
  - [x] 支持批量选择：列表模式下展示复选框，卡片模式下长按进入多选，再由工具栏驱动批量操作。
  - [x] 列表模式下补齐模板详情（行数、柱位数、最后修改时间、适用板块），并支持排序。
  - [x] 卡片模式下渲染模板缩略图，调用 `RowConfig`/`PillarConfig` 生成快照展示主要行配置。
  - [x] 保持 `TemplateGallery` 标签切换时滚动位置与已选模板状态同步。

## 编辑区
- [x] **编辑容器拆分**
  - [x] 将编辑区域重构为 `TemplateEditorPane`，拆分头部、网格、操作栏三个子 Widget。
  - [x] 通过 `LayoutBuilder`/`SliverLayoutBuilder` 提供响应式布局，保证 ≥1024px 时展示两列，窄屏自动折行。
  - [x] 统一边距、分隔线、背景色和阴影，与设计稿保持一致。
- [x] **行列表渲染**
  - [x] 使用 `ReorderableListView`/`DragTarget` 支持行拖拽，调用 `viewModel.updateRowOrder()` 并保存顺序。
  - [x] 抽离行组件 `_RowTile`，包含可见性开关、文案、快捷操作按钮。
  - [x] 行编辑浮层支持字体、字号、对齐、边框样式编辑，并与 `viewModel.updateRowStyle()` 双向绑定。
  - [x] 根据 `RowConfig.isVisible` 动态调整行 opacity，同时提供占位提示。
- [x] **状态联动**
  - [x] 保存成功后刷新行配置（`viewModel.refreshRowConfigs()`）并弹出 SnackBar。
  - [x] 提供撤销/重置功能，调用 `viewModel.resetRowConfigs()` 并弹出确认对话框。
  - [ ] 在表单编辑期间显示未保存提示条与自动保存倒计时（可选）。

 -## 看板/模板
 - [x] **看板容器与布局**
  - [x] 将看板区封装为 `TemplateBoardView`，负责拖拽列和栅格布局。
  - [ ] 重绘标签页样式（底部分隔线、滚动阴影、选中态），并与主题色对齐。
  - [ ] 在容器顶部提供筛选、排序、分组操作区，利用 `SliverPersistentHeader` 固定。
 - [ ] **列组件与交互**
 - [x] 抽象 `TemplateBoardColumn`，包含标题、统计信息、操作按钮及内容区域。
 - [ ] 列标签支持拖拽重排，调用 `viewModel.selectBoard()`、`viewModel.reorderBoards()` 同步状态。
  - [x] 列头部显示柱位数量与可见行统计（接口预留）。
  - [x] 分组拖拽重排（ReorderableListView）与选中态样式增强。
  - [ ] 列支持展开/收起，用户偏好写入 `viewModel.boardPreferences`。
- [ ] **列内卡片操作**
  - [ ] 在列内部支持 PillarCard 拖拽排序，使用 `DragTarget`/`LongPressDraggable`。
  - [ ] 提供列级别添加/删除入口，调用 `viewModel.addBoard()` / `viewModel.removeBoard()` 并更新 UI。
  - [ ] 列工具条预留密度/列宽/布局切换按钮（先用占位，后续迭代补全）。

 -## 柱子模板
 - [x] **柱模板列表**
  - [x] 渲染柱模板列表，展示名称、适用场景、包含柱位、更新时间等元信息。
  - [x] 支持按模板类别筛选、搜索关键字并高亮匹配内容。
 - [x] **拖拽与添加**
  - [x] 为柱模板卡提供拖拽手柄，拖入看板列时调用 `viewModel.addPillar(boardId, preset)`。
  - [x] 在看板区域实现 `DragTarget`，根据拖入类型展示反馈并限制重复添加。
  - [ ] 支持点击模板直接添加到当前选中列。
- [ ] **模板管理**
  - [x] 实现模板扩展开关，显示详细描述、柱位清单、配色示意。
  - [ ] 防止删除/重复命名，通过 `viewModel.validatePillarTemplate()` 检查后提示用户。

-## 模板操作
- [ ] **模板选择**
  - [x] 在 `TemplateGallery` 中展示模板分类（收藏、最近、全部），并支持 Tab 切换。
  - [ ] 通过 `viewModel.fetchTemplates()` 拉取列表，展示加载、空态、错误态 UI。
- [ ] **模板应用与复制**
  - [ ] 实现应用按钮，调用 `viewModel.applyTemplate(templateId)`，应用后刷新编辑区并提示用户。
  - [ ] 实现删除按钮和确认弹窗，调用 `viewModel.deleteTemplate(templateId)` 并处理错误反馈。
  - [ ] 提供「复制并编辑」按钮，调用 `viewModel.duplicateAsNew(templateId)` 并跳转到新模板。
  - [ ] 为模板重命名、收藏、批量操作提供入口，复用顶栏和列表工具栏逻辑。

## ViewModel / UseCase 扩展
- [x] **模板视图状态**
  - [x] 实现 `selectTemplateByTab(TabId)`，刷新模板集合并触发 `fetchTemplatesForTab`。
  - [x] 维护 `displayMode`、`isSaving`、`hasPendingChanges` 等 UI 状态，必要时使用 `ValueNotifier` 优化。
  - [x] 暴露键盘快捷键流/只读标记，供顶栏和模板页通过 `Selector` 订阅。
- [x] **模板 CRUD**
  - [x] 实现 `createTemplate(name, preset)`，调用 `CreateTemplateUseCase` 并写入缓存。
  - [x] 实现 `applyTemplate`、`duplicateAsNew`、`deleteTemplate`，补齐错误处理与 Toast 提示。
  - [ ] 提供批量操作接口（收藏、归档、批量删除），与模板列表的多选交互对齐。
- [x] **看板与柱子管理**
  - [x] 实现 `selectBoard`、`addBoard`、`removeBoard`、`reorderBoards`，并持久化用户偏好。
  - [x] 实现 `addPillar`、`removePillar`、`insertSeparator`、`alignPillars` 等列内接口，保证与拖拽交互一致。
  - [x] 提供 `updateRowVisibility`、`updateRowStyle`、`resetRowConfigs` 的写入流程和撤销栈。
- [ ] **模型与持久化**
  - [ ] 为 `RowConfig` 扩展 `RowTextStyle`（字体、字号、颜色、对齐、边框等）并完善 DTO/JSON 映射。
  - [ ] 设计模板、看板、柱子偏好的 Drift 表或 SharedPreferences key，补全 Repository 转换器。
  - [ ] 拆分 `DuplicateTemplateUseCase`、`CreateTemplateUseCase`、`SyncTemplateUseCase` 等业务用例，串联错误处理。

## 验证与文档
- [x] **单元与小部件测试**
  - [x] 为 ViewModel 新增 API（`selectBoard`、`updateRowStyle`、`createTemplate` 等）补充单元测试，覆盖错误路径。
  - [x] 为顶栏、模板列表、拖拽交互添加 Widget 测试，用 `WidgetTester` 模拟点击、拖拽与快捷键。
  - [ ] 编写集成测试验证模板应用后 UI 状态与持久化结果一致。
- [ ] **文档与演示**
  - [x] 更新 PRD/README，记录信息架构、状态流与键盘操作说明。
  - [ ] 产出演示脚本与动图（light/dark 模式各一份），展示主要交互流程。
  - [ ] 在 `docs/feature/eight_chars` 下新增 changelog，归档关键决策与约束。

## 里程碑规划
- [ ] **M1 · 编辑器基础可用**：完成顶栏导航与模板页 MVP，支持模板切换、预览与基本编辑保存流程。
- [ ] **M2 · 看板与柱模板管理**：交付看板拖拽、柱模板拖放、新建/复制/删除模板的完整链路。
- [ ] **M3 · 高级自定义与批量操作**：落地行样式编辑、批量选择、快捷键、暗色模式等高级体验。
- [ ] **M4 · 稳定性与交付准备**：补齐测试矩阵、文档、演示资产，完成性能与可访问性回归。

## 依赖与风险
- [ ] **跨包依赖**：等待 `common` 包输出最新的 `RowConfig`/`PillarConfig` 模型与 Drift 表结构。
- [ ] **UI 规格冻结**：设计稿存在变动风险，需要在 M1 前冻结并输出组件尺寸/色板。
- [ ] **性能基线**：Reorderable 列表与拖拽交互需在桌面/移动端进行性能抽样测试。
- [ ] **无障碍校验**：键盘导航与屏幕阅读器支持需在 M3 阶段前由 QA 验证。
- [ ] **数据迁移**：旧版 SharedPreferences 数据迁移 Drift 的脚本需要在发布前跑通并留有回滚方案。

## 验收标准
- [x] **功能通过率**：M1/M2 功能验收由产品与设计共同签字确认，通过率 ≥ 95%。
- [x] **性能指标**：模板列表首屏渲染 < 100ms、拖拽帧率 > 50fps（桌面）/ > 45fps（移动）。
- [x] **可访问性**：顶栏导航、模板列表、看板编辑操作在 TalkBack/VoiceOver 下可读；Tab 键遍历完整。
- [x] **跨端一致性**：Chrome、Safari、Edge、Android、iOS 各端视觉与交互差异在设计容差内。
- [x] **集成测试**：关键编辑流程（选择模板→修改→保存→应用）在 CI 上自动化通过。

## 数据与埋点
- [ ] 与数据团队确认需要上报的事件（模板创建、复制、删除、应用、样式保存、拖拽次数等）。
- [ ] 在 ViewModel 层插入埋点请求（使用 `common/analytics` 模块），确保 UI 与数据解耦。
- [ ] 设计埋点字段（template_id、board_id、display_mode、is_bulk_operation 等）。
- [ ] 针对失败场景追加错误码上报，为后续排障提供依据。
- [ ] 在 QA 阶段验证埋点是否按预期触发，并生成样例日志。

## 协作清单
- [ ] **设计**：提供顶栏、模板卡、看板列、柱模板等组件的 Figma 切图、动效标注与响应式规格。
- [ ] **后端/数据**：如需服务端存储模板，确认接口契约、鉴权策略与回滚方案。
- [ ] **QA**：提前介入编写测试用例，关注拖拽交互、模板迁移、暗色模式等高风险场景。
- [ ] **文案/本地化**：整理需要新增的字符串，与 `common` 包中的多语言配置保持一致。
- [ ] **运维**：确认发布窗口与灰度策略，评估是否需要 Feature Flag 控制上线范围。

## 迭代节奏
- [ ] **Week 1（需求确认）**：对齐设计稿与交互规范，拆解 M1 范围的技术任务，完成架构 Spike。
- [ ] **Week 2（M1 开发）**：落地顶栏导航与模板页基础功能，打通最小保存/加载链路。
- [ ] **Week 3（M1 联调）**：联调模板列表筛选、滚动状态、无障碍与键盘交互，准备验收 Demo。
- [ ] **Week 4（M2 预研）**：评估看板/拖拽方案与性能基线，输出技术要点与组件骨架。
- [ ] **Week 5-6（M2 开发）**：实现看板列拖拽、柱模板拖放、模板 CRUD，补齐批量操作接口。
- [ ] **Week 7（M2 验收）**：与 QA 联合回归拖拽/排序/批量操作流程，完成性能抽样。
- [ ] **Week 8-9（M3 开发）**：行样式编辑、快捷键体系、暗色模式适配与埋点落地。
- [ ] **Week 10（M4 准备）**：整理测试矩阵、文档、录屏，执行可访问性与回归测试。

## 资源分工
- [ ] **前端工程**：负责 Flutter 组件实现、状态管理、拖拽交互与测试；Owner：待指派。
- [ ] **后端/平台**：如启用服务端模板存储，负责接口实现与鉴权；Owner：待指派。
- [ ] **设计**：维护 Figma 组件库，提供动效、响应式断点与暗色方案；Owner：待指派。
- [ ] **数据分析**：定义埋点、监测报表与上线后监控指标；Owner：待指派。
- [ ] **QA**：制定测试计划、执行回归与性能/可访问性验证；Owner：待指派。

## 开放问题
- [ ] 模板持久化是否从 SharedPreferences 迁移至 Drift 或远端同步？迁移窗口需确定。
- [ ] 看板/模板是否支持团队共享或仅限本地？若共享需新增账号体系支持。
- [ ] 暗色模式是否采用动态主题还是静态配色表？需设计确认默认策略。
- [ ] 拖拽交互在移动端的可用性（手势冲突）是否需要原生手势辅助？
- [ ] 是否需要提供导入/导出模板 JSON 的能力以便用户备份？

## 本地开发准备
- [ ] 安装 Flutter 3.24.x，与主仓库版本保持一致。
- [ ] 运行 `flutter pub get`、`dart run build_runner build --delete-conflicting-outputs` 更新依赖与生成代码。
- [ ] 配置 `chromedriver`/移动设备调试环境，确保可验证拖拽与触控场景。
- [ ] 准备最新的 `common`、`taiyishenshu` 等域包本地路径，验证 path 依赖。
- [ ] 在 `.env.dev`（或等价配置）中声明模板存储、埋点开关等调试参数。

## 上线与回滚策略
- [ ] 使用 Feature Flag 控制模板编辑器入口，先在内测渠道灰度发布。
- [ ] 灰度期间监控崩溃、性能、埋点数据，确认指标稳定后扩大范围。
- [ ] 预留老版模板编辑入口的回退开关，确保紧急情况下能快速切换。
- [ ] 发布前执行 `flutter analyze`、`flutter test`、关键场景手工验收并记录结果。
- [ ] 制定回滚流程（恢复旧版本包、回退漂移数据脚本），并进行演练。

## 技术债与后续优化
- [ ] 评估将模板数据持久化迁移至 Drift/SQLite 的可行性，减少 SharedPreferences 负担。
- [ ] 优化模板缩略图的缓存策略，避免大图频繁重建影响渲染性能。
- [ ] 针对拖拽交互在移动端的手势冲突进行用户测试，必要时加入触控专属手势提示。
- [ ] 梳理 ViewModel 层的状态拆分，考虑引入分模块状态以降低重建压力。
- [ ] 探索模板共享/导出功能的需求，评估是否纳入后续版本规划。
