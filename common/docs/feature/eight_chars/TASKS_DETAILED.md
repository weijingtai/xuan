# 八字卡片编辑器 - 详细任务列表 (Atomic Tasks)

> 本文档将设计稿与代码实现差距拆分为原子化任务
> 每个任务预计耗时：0.5-2小时
> 总预计工时：约 60-80 小时（3-4周）

---

## 阶段一：核心连接修复（Week 1, 20小时）

### 里程碑 M1.1：左侧边栏重构（8小时）

#### Task 1.1.1：创建新的 EditorSidebar 组件骨架（1h）
- [x] 在 `lib/widgets/` 下创建 `editor_sidebar_v2.dart`
- [x] 定义 Widget 骨架，接收 ViewModel 参数
- [x] 添加 `Consumer<FourZhuEditorViewModel>` 包装器
- [x] 实现三段式布局结构（柱间分隔线 / 行信息管理 / 字体设置）
- **验收标准**：编译通过，显示空白三段容器

#### Task 1.1.2：实现柱间分隔线配置 UI（1.5h）
- [x] 读取 `viewModel.cardStyle?.dividerType`
- [x] 实现分隔线样式下拉框（实线/虚线/点状/无）
- [x] 绑定 `viewModel.updateDividerType(BorderType)` 回调
- [x] 实现颜色选择器（使用 `ColorPicker` 或简单 TextField）
- [x] 绑定 `viewModel.updateDividerColor(String)` 回调
- [x] 实现粗细输入框（数字键盘）
- [x] 绑定 `viewModel.updateDividerThickness(double)` 回调
- **验收标准**：修改配置后 `viewModel.hasUnsavedChanges` 变为 true

#### Task 1.1.3：实现行信息管理 - 核心行锁定显示（0.5h）
- [x] 读取 `viewModel.rowConfigs`
- [x] 筛选出 `RowType.heavenlyStem` 和 `RowType.earthlyBranch`
- [x] 渲染两个 `ListTile`，带锁定图标
- [x] 设置灰色背景表示不可编辑
- **验收标准**：天干/地支行始终显示且无法操作

#### Task 1.1.4：实现行信息管理 - 可选行列表（2h）
- [x] 筛选出非核心行（十神、纳音、空亡等）
- [x] 创建 `_RowConfigItem` Widget
- [x] 实现可见性 Switch，绑定 `viewModel.updateRowVisibility()`
- [x] 实现标题可见性 Checkbox，绑定 `viewModel.updateRowTitleVisibility()`
- [x] 添加行标题显示（从 `RowType` 枚举映射中文名称）
- [x] 添加拖拽句柄图标（`Icons.drag_indicator`）
- **验收标准**：Switch 切换后列表更新，ViewModel 状态变更

#### Task 1.1.5：实现行排序拖拽功能（1h）
- [x] 包装可选行列表到 `ReorderableListView`
- [x] 实现 `onReorder` 回调
- [x] 调用 `viewModel.updateRowOrder(oldIndex, newIndex)`
- [x] 添加拖拽反馈动画（elevation + 阴影）
- **验收标准**：拖拽后行顺序改变，保存后持久化

#### Task 1.1.6：添加行编辑按钮（0.5h）
- [x] 在每个 `_RowConfigItem` 右侧添加 `IconButton(Icons.edit)`
- [x] 点击时调用 `_showRowStyleDialog(context, rowConfig)`（暂为空函数）
- [x] 禁用状态：当 `!rowConfig.isVisible` 时按钮置灰
- **验收标准**：点击按钮时打印日志或弹出占位对话框

#### Task 1.1.7：实现全局字体设置 UI（1h）
- [x] 在底部添加"全局样式"折叠面板
- [x] 读取 `viewModel.cardStyle?.globalFontFamily`
- [x] 实现字体下拉框（系统默认 / NotoSansSC-Regular）
- [x] 读取 `viewModel.cardStyle?.globalFontSize`
- [x] 实现字号滑块（范围 10-24）
- [x] 读取 `viewModel.cardStyle?.globalFontColorHex`
- [x] 实现颜色选择器
- [x] 绑定到 ViewModel 的 `updateGlobalFontXxx()` 方法
- **验收标准**：修改后全局样式立即生效

#### Task 1.1.8：替换旧 Sidebar 并测试（0.5h）
- [x] 在 `four_zhu_edit_page.dart` 中将 `_EditorSidebar` 替换为新组件
- [ ] 删除或重命名旧 `layout_editor_sidebar.dart` 为 `_deprecated`
- [ ] 运行 `flutter run` 测试所有交互
- [ ] 验证保存/加载流程完整性
- **验收标准**：侧边栏所有操作正常，无运行时错误

---

### 里程碑 M1.2：行样式编辑对话框（6小时）

#### Task 1.2.1：创建 RowStyleEditorDialog 骨架（1h）
- [x] 在 `lib/widgets/` 下创建 `row_style_editor_dialog.dart`
- [x] 定义 `StatefulWidget`，接收 `RowConfig` 和 `onSave` 回调
- [x] 使用 `AlertDialog` 包装，标题显示"编辑行样式 - {行名称}"
- [x] 添加"取消"和"保存"按钮
- **验收标准**：点击编辑按钮弹出空白对话框

#### Task 1.2.2：实现字体配置选项（1h）
- [x] 添加字体下拉框（继承全局 / NotoSansSC-Regular / 其他）
- [x] 使用本地状态 `_selectedFontFamily` 暂存
- [x] 添加字号数字输入框（TextField with number keyboard）
- [x] 使用本地状态 `_selectedFontSize` 暂存
- [x] 添加预览文本"示例：甲子"显示当前样式效果
- **验收标准**：修改字体/字号后预览文本实时更新

#### Task 1.2.3：实现文本颜色选择器（1h）
- [x] 添加颜色选择器（可使用 `flutter_colorpicker` 包）
- [x] 或实现简单的预设颜色面板（红、黑、蓝、绿等）
- [x] 使用本地状态 `_selectedTextColor` 暂存
- [x] 预览文本颜色实时同步
- **验收标准**：选择颜色后预览文本变色

#### Task 1.2.4：实现文本对齐选项（0.5h）
- [x] 添加对齐方式选择（居左/居中/居右）
- [x] 使用 `SegmentedButton<RowTextAlign>`
- [x] 使用本地状态 `_selectedTextAlign` 暂存
- **验收标准**：选择对齐方式后本地状态更新

#### Task 1.2.5：实现边框样式选项（1h）
- [x] 添加边框类型下拉框（无/实线/虚线/点状）
- [x] 添加边框颜色选择器
- [x] 添加边框粗细输入框
- [x] 使用本地状态暂存
- [x] 在预览区域显示边框效果
- **验收标准**：边框设置在预览中可见

#### Task 1.2.6：实现内边距配置（0.5h）
- [x] 添加内边距滑块（范围 0-24）
- [x] 使用本地状态 `_selectedPadding` 暂存
- [x] 预览文本周围间距实时更新
- **验收标准**：滑动后预览区域内边距变化

#### Task 1.2.7：实现保存逻辑（1h）
- [x] 点击"保存"按钮时，创建 `RowConfig.copyWith()`
- [x] 将所有本地状态值写入新 `RowConfig`
- [x] 调用 `onSave(updatedConfig)` 回调
- [x] 关闭对话框
- [x] 在 `_EditorSidebar` 中实现 `onSave` 回调：`viewModel.updateRowStyle(updatedConfig)`
- **验收标准**：保存后行样式在卡片中生效

---

### 里程碑 M1.3：ViewModel 方法补全（6小时）

#### Task 1.3.1：实现 updateRowStyle 方法（1h）
- [x] 在 `FourZhuEditorViewModel` 中添加 `updateRowStyle(RowConfig)` 方法
- [x] 查找 `_currentTemplate.rowConfigs` 中对应类型的行
- [x] 使用 `rowConfig.copyWith()` 更新样式字段
- [x] 更新模板并调用 `_markUnsaved()`
- [ ] 添加单元测试验证方法逻辑
- **验收标准**：调用后 ViewModel 状态更新，`hasUnsavedChanges = true`

#### Task 1.3.2：实现 updateGlobalFont 系列方法（1h）
- [x] 添加 `updateGlobalFontFamily(String family)` 方法
- [x] 添加 `updateGlobalFontSize(double size)` 方法
- [x] 添加 `updateGlobalFontColor(String colorHex)` 方法
- [x] 所有方法更新 `_currentTemplate.cardStyle` 并调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：调用后 `cardStyle` 字段正确更新

#### Task 1.3.3：实现 addGroup 方法（1h）
- [x] 添加 `addGroup({required String title})` 方法
- [x] 生成新 `ChartGroup` 对象（UUID、空柱位列表）
- [x] 添加到 `_currentTemplate.chartGroups`
- [x] 自动选中新分组（更新 `_selectedGroupId`）
- [x] 调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：新分组出现在看板区

#### Task 1.3.4：实现 removeGroup 方法（0.5h）
- [x] 添加 `removeGroup(String groupId)` 方法
- [x] 校验：至少保留一个分组
- [x] 从 `chartGroups` 中移除指定分组
- [x] 如果删除的是当前选中分组，自动选中第一个分组
- [x] 调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：删除后分组消失，不影响其他分组

#### Task 1.3.5：实现 selectGroup 方法（0.5h）
- [x] 添加 `selectGroup(String groupId)` 方法
- [x] 验证 groupId 存在于 `chartGroups` 中
- [x] 更新 `_selectedGroupId`
- [x] 调用 `notifyListeners()`
- **验收标准**：选中后看板区高亮对应分组

#### Task 1.3.6：实现 addPillarToGroup 方法（已存在，补充测试）（0.5h）
- [x] 检查 `addPillarToGroup()` 是否已实现
- [x] 如果未实现，添加方法：接收 `groupId` 和 `PillarType`
- [x] 在指定分组的 `pillarOrder` 末尾添加柱位
- [x] 调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：拖拽柱位后分组中出现新柱位

#### Task 1.3.7：实现 removePillarFromGroup 方法（0.5h）
- [x] 添加 `removePillarFromGroup({required String groupId, required int index})` 方法
- [x] 从指定分组的 `pillarOrder` 中移除指定索引的柱位
- [x] 调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：点击删除按钮后柱位消失

#### Task 1.3.8：实现 reorderPillar 方法（已存在，补充测试）（1h）
- [x] 检查 `reorderPillar()` 是否已实现
- [x] 确保方法接收 `groupId`、`oldIndex`、`newIndex`
- [x] 在指定分组的 `pillarOrder` 中重排序
- [x] 调用 `_markUnsaved()`
- [ ] 添加单元测试
- **验收标准**：拖拽柱位后顺序改变

---

## 阶段二：顶部预设模板区恢复（Week 2, 12小时）

### 里程碑 M2.1：TemplateGalleryView 组件实现（8小时）

#### Task 2.1.1：创建 TemplateGalleryView 骨架（1h)
- [x] 在 `lib/widgets/` 下创建 `template_gallery_view.dart`
- [x] 定义 Widget，接收 ViewModel
- [x] 实现横向滚动容器（SingleChildScrollView + Row）
- [x] 添加占位卡片（3个空白容器）
- **验收标准**：在 `four_zhu_edit_page.dart` 取消注释后显示占位卡片

#### Task 2.1.2：设计模板预设数据结构（1h）
- [x] 在 `lib/models/` 下创建 `template_preset.dart`
- [x] 定义 `TemplatePreset` 类：
  - `String id`
  - `String name`（如"流年盘"）
  - `String description`
  - `List<PillarType> defaultPillars`
  - `String thumbnailAsset`（可选）
- [x] 创建预设常量列表（流年盘、大运盘、胎元分析）
- **验收标准**：数据结构编译通过，可序列化

#### Task 2.1.3：实现预设卡片 UI（2h）
- [x] 创建 `_PresetCard` Widget
- [x] 布局：圆角矩形，渐变背景
- [x] 顶部显示预设名称（大字）
- [x] 中部显示柱位缩略图（简化版，显示柱位数量）
- [x] 底部显示描述文字（小字）
- [x] 添加选中状态高亮边框
- [x] 添加 hover 效果（鼠标悬浮时阴影加深）
- **验收标准**：卡片样式与设计稿接近

#### Task 2.1.4：实现点击切换预设（1.5h）
- [x] 在 `TemplateGalleryView` 中维护本地状态 `_selectedPresetId`
- [x] 卡片点击时更新选中状态
- [x] 调用 `viewModel.applyPreset(preset)` 方法（待实现）
- [x] 显示 loading 指示器（CircularProgressIndicator）
- **验收标准**：点击后卡片高亮，看板区更新

#### Task 2.1.5：实现"添加预设"按钮（0.5h）
- [x] 在预设卡片列表末尾添加"+"按钮卡片
- [x] 点击弹出创建预设对话框（暂为占位）
- [x] 对话框包含：名称输入、描述输入、柱位选择
- **验收标准**：点击后弹出对话框（功能未完成可接受）

#### Task 2.1.6：在 ViewModel 中实现 applyPreset 方法（2h）
- [x] 添加 `applyPreset(TemplatePreset preset)` 方法
- [x] 清空当前模板的所有分组
- [x] 创建新分组，名称为预设名称
- [x] 将 `preset.defaultPillars` 添加到新分组
- [x] 重置行配置为默认可见状态
- [x] 调用 `_markUnsaved()`
- [x] 添加单元测试
- **验收标准**：应用预设后看板显示对应柱位

---

### 里程碑 M2.2：顶栏增强（4小时）

#### Task 2.2.1：添加模板下拉选择器（1.5h）
- [x] 在 `EditorTopBar` 的 `_TopBarControls` 中添加 `DropdownButton<String>`
- [x] 数据源：`viewModel.templates`
- [x] 显示当前模板名称：`viewModel.currentTemplate?.name`
- [x] 下拉列表显示所有模板名称
- [x] 选择时调用 `viewModel.selectTemplate(templateId)`
- [x] 样式：与设计稿对齐（去掉下划线，添加图标）
- **验收标准**：下拉选择后模板切换

#### Task 2.2.2：实现"另存为"按钮（1h）
- [x] 在顶栏按钮组中添加 `OutlinedButton`，label="另存为..."
- [x] 点击时弹出对话框：输入新模板名称
- [x] 调用 `viewModel.saveTemplateAs(newName)` 方法（待实现）
- [x] 保存成功后显示 SnackBar 提示
- **验收标准**：点击后创建模板副本

#### Task 2.2.3：在 ViewModel 中实现 saveTemplateAs 方法（1h）
- [x] 添加 `saveTemplateAs(String newName)` 方法
- [x] 复制当前模板（`currentTemplate.copyWith()`）
- [x] 生成新 UUID
- [x] 更新名称为 `newName`
- [x] 调用 `saveTemplateUseCase` 保存新模板
- [x] 将新模板添加到 `_templates` 列表
- [x] 切换到新模板
- [ ] 添加单元测试
- **验收标准**：模板列表中出现新模板

#### Task 2.2.4：调整顶栏布局适配新元素（0.5h）
- [x] 调整 `EditorTopBar` 的 `preferredSize` 高度（如需要）
- [x] 调整按钮间距确保不拥挤
- [ ] 响应式处理：窄屏时部分按钮收起到菜单
- **验收标准**：所有元素在 1024px+ 屏幕正常显示

---

## 阶段三：看板区增强（Week 2-3, 16小时）

### 里程碑 M3.1：看板视觉完善（6小时）

#### Task 3.1.1：实现分组卡片容器（1.5h）
- [x] 在 `_EditorWorkspace` 中实现分组横向滚动容器
- [x] 每个分组渲染为独立卡片（圆角、阴影）
- [x] 分组标题栏显示：标题 + 柱位数量 + 操作菜单
- [x] 选中分组高亮边框（蓝色）
- [x] 点击分组调用 `viewModel.selectGroup(groupId)`
- **验收标准**：多分组时横向滚动，选中时高亮

#### Task 3.1.2：实现柱位卡片渲染（2h）
- [x] 在分组内渲染柱位列表（使用 `GenericPillarCard` 或自定义）
- [x] 每个柱位显示：
  - 天干/地支（大字，五行配色）
  - 十神（小字，根据 `rowConfigs` 可见性）
  - 藏干/纳音（根据 `rowConfigs` 可见性）
- [x] 读取 `viewModel.previewEightChars` 作为示例数据
- [x] 如果无数据，显示占位图标
- **验收标准**：柱位卡片显示完整信息

#### Task 3.1.3：实现五行配色系统（1h）
- [x] 在 `lib/utils/` 下创建 `five_elements_colors.dart`
- [x] 定义天干->五行->颜色映射：
  - 甲乙=木=绿色
  - 丙丁=火=红色
  - 戊己=土=黄色
  - 庚辛=金=白色
  - 壬癸=水=黑色
- [x] 创建 `getFiveElementColor(TianGan gan)` 工具函数
- [x] 在柱位卡片中应用颜色
- **验收标准**：不同天干显示不同颜色

#### Task 3.1.4：添加"添加列盘"按钮（0.5h）
- [x] 在分组滚动容器末尾添加"+"按钮卡片
- [x] 点击调用 `_promptCreateGroup(context)`（已存在）
- [x] 样式：虚线边框、居中图标
- **验收标准**：点击后弹出新建分组对话框

#### Task 3.1.5：实现分组操作菜单（1h）
- [x] 在分组标题栏添加 `PopupMenuButton`
- [x] 菜单项：重命名、复制、删除、展开/收起
- [x] 实现"重命名"：弹出输入对话框，调用 `viewModel.renameGroup()`
- [x] 实现"复制"：调用 `viewModel.duplicateGroup()`
- [x] 实现"删除"：调用现有的删除逻辑
- [x] 实现"展开/收起"：调用 `viewModel.toggleGroupExpanded()`
- **验收标准**：所有菜单项功能正常

---

### 里程碑 M3.2：拖拽交互增强（6小时）

#### Task 3.2.1：实现柱位拖拽删除（1h）
- [x] 在每个柱位卡片上添加删除按钮（hover 时显示）
- [x] 点击时调用 `viewModel.removePillarFromGroup()`
- [x] 添加删除确认对话框（可选）
- [x] 删除时播放淡出动画
**验收标准**：点击后柱位消失

#### Task 3.2.2：实现拖拽高亮反馈（1.5h）
- [x] 在 `DragTarget` 的 `builder` 中检测 `candidateData`
- [x] 当有数据悬浮时，显示蓝色虚线边框
- [x] 添加"释放以添加"提示文字
- [x] 拒绝数据时显示红色边框（如重复柱位）
- [x] 添加边框渐变动画（AnimatedContainer）
**验收标准**：拖拽时视觉反馈明确

#### Task 3.2.3：实现拖拽预览优化（1h）
- [x] 在 `Draggable` 的 `feedback` 中使用半透明卡片
- [x] 显示柱位名称和图标
- [x] 添加阴影效果
- [x] 优化 `childWhenDragging`：显示占位虚影
**验收标准**：拖拽时预览清晰美观

#### Task 3.2.4：实现柱位重排拖拽（1.5h）
- [x] 在分组内使用 `ReorderableListView` 或自定义拖拽逻辑
- [x] 柱位间拖拽时显示插入位置指示器
- [x] 调用 `viewModel.reorderPillar()` 更新顺序
- [x] 添加平滑动画过渡
**验收标准**：柱位顺序可拖拽调整

#### Task 3.2.5：实现跨分组拖拽（1h）
- [x] 扩展 `DragTarget` 接受来自其他分组的柱位
- [x] 拖拽数据携带源分组 ID
- [x] 实现 `viewModel.movePillarBetweenGroups()` 方法
- [x] 验证柱位在目标分组中不重复
**验收标准**：柱位可在分组间移动

---

### 里程碑 M3.3：ViewModel 方法补全（4小时）

#### Task 3.3.1：实现 renameGroup 方法（0.5h）
- [ ] 添加 `renameGroup({required String groupId, required String newTitle})` 方法
- [x] 查找对应分组并更新标题
- [x] 调用 `_markUnsaved()`
- [x] 添加单元测试
- **验收标准**：重命名后标题更新

#### Task 3.3.2：实现 duplicateGroup 方法（0.5h）
- [x] 添加 `duplicateGroup(String groupId)` 方法
- [x] 复制分组及其柱位列表
- [x] 生成新 UUID，标题添加"(副本)"后缀
- [x] 插入到原分组后面
- [x] 调用 `_markUnsaved()`
- [x] 添加单元测试
- **验收标准**：复制后出现新分组

#### Task 3.3.3：实现 toggleGroupExpanded 方法（0.5h）
- [x] 添加 `toggleGroupExpanded(String groupId)` 方法
- [x] 切换 `ChartGroup.expanded` 字段
- [x] 调用 `notifyListeners()`
- [x] UI 层根据 `expanded` 显示/隐藏柱位列表
- **验收标准**：点击后分组展开/收起

#### Task 3.3.4：实现 movePillarBetweenGroups 方法（1h）
- [x] 添加 `movePillarBetweenGroups({required String fromGroupId, required int fromIndex, required String toGroupId, required int toIndex})` 方法
- [x] 从源分组移除柱位
- [x] 添加到目标分组
- [ ] 验证重复性
- [x] 调用 `_markUnsaved()`
- [x] 添加单元测试
- **验收标准**：柱位跨分组移动成功

#### Task 3.3.5：补充 ViewModel 单元测试（1.5h）
- [ ] 为所有新增方法编写测试用例
- [ ] 测试边界情况（空分组、单分组、重复柱位等）
- [ ] 测试状态变更（`hasUnsavedChanges`、`notifyListeners`）
- [ ] 运行 `flutter test` 确保覆盖率 > 80%
- **验收标准**：所有测试通过

---

## 阶段四：底部面板优化（Week 3, 8小时）

### 里程碑 M4.1：底部面板布局调整（4小时）

#### Task 4.1.1：将底部面板移至 actionBar（1h）
- [x] 在 `four_zhu_edit_page.dart` 中将 `PillarPalette` 从 `header` 移到 `actionBar`
- [x] 调整布局为横向滚动
- [x] 确保不与保存按钮冲突
- **验收标准**：底部面板固定在页面底部

#### Task 4.1.2：实现面板展开/收起功能（1.5h）
- [x] 在 ViewModel 中添加 `_isPaletteExpanded` 状态
- [x] 添加 `togglePaletteExpanded()` 方法
- [x] 在底部面板右侧添加箭头按钮
- [x] 收起时仅显示图标栏，展开时显示完整内容
- [x] 添加展开/收起动画（AnimatedContainer）
- **验收标准**：点击箭头后面板收起/展开

#### Task 4.1.3：优化柱位组件显示（1h）
- [x] 限制显示柱位数量（年月日时胎元大运，共6个）
- [x] 移除"更多..."占位项
- [x] 调整组件尺寸适配底部空间
- [x] 添加 tooltip 显示柱位说明
- **验收标准**：6个柱位清晰显示

#### Task 4.1.4：持久化面板展开状态（0.5h）
- [x] 使用 SharedPreferences 保存 `isPaletteExpanded`
- [x] 初始化时加载状态
- [x] 状态变更时保存
- **验收标准**：重启应用后状态保持

---

### 里程碑 M4.2：柱位预设增强（4小时）

#### Task 4.2.1：优化 PillarPresetList 布局（1h）
- [ ] 调整为网格布局（Grid）而非 Wrap
- [ ] 每行显示 4 个预设卡片
- [ ] 窄屏时自动调整为 2-3 个
- [ ] 优化卡片间距
- **验收标准**：布局整齐美观

#### Task 4.2.2：添加预设分类筛选（1h）
- [ ] 在工具栏中添加分类 Tabs（全部/本命/运势）
- [ ] 扩展 `PillarPresetCategory` 枚举
- [ ] 在 `PillarPresetViewModel` 中实现筛选逻辑
- [ ] 点击 Tab 时更新列表
- **验收标准**：切换分类后列表过滤

#### Task 4.2.3：实现预设拖拽批量添加（1h）
- [ ] 在 `PillarPresetCard` 的 `Draggable.data` 中传递 `PillarPreset`
- [ ] 在 `TemplateBoardView` 的 `DragTarget.onAccept` 中处理
- [ ] 一次性添加预设中的所有柱位
- [ ] 显示添加成功提示
- **验收标准**：拖拽预设后批量添加柱位

#### Task 4.2.4：添加预设收藏功能（1h）
- [ ] 在预设卡片右上角添加星标按钮
- [ ] 点击时调用 `viewModel.togglePresetFavorite(presetId)`
- [ ] 在 SharedPreferences 中持久化收藏列表
- [ ] 筛选器支持"收藏"分类
- **验收标准**：收藏预设后在收藏列表中显示

---

## 阶段五：数据持久化升级（Week 3-4, 12小时）

### 里程碑 M5.1：Drift 数据库设计（4小时）

#### Task 5.1.1：设计 Drift 表结构（1h）
- [ ] 在 `lib/database/tables/` 下创建 `layout_tables.dart`
- [ ] 定义 `LayoutTemplates` 表：
  - `TextColumn id (PK)`
  - `TextColumn name`
  - `TextColumn collectionId`
  - `TextColumn configJson` (存储完整 JSON)
  - `IntColumn version`
  - `DateTimeColumn updatedAt`
  - `DateTimeColumn createdAt`
- [ ] 定义索引：`collectionId`、`updatedAt`
- **验收标准**：表结构编译通过

#### Task 5.1.2：创建 TemplateDao（1h）
- [ ] 在 `lib/database/daos/` 下创建 `layout_template_dao.dart`
- [ ] 实现 CRUD 方法：
  - `Future<List<LayoutTemplateEntity>> getAllInCollection(String collectionId)`
  - `Future<LayoutTemplateEntity?> getById(String id)`
  - `Future<void> insertOrUpdate(LayoutTemplateEntity entity)`
  - `Future<void> delete(String id)`
- [ ] 添加查询方法：按更新时间排序、搜索名称
- **验收标准**：DAO 编译通过

#### Task 5.1.3：集成到 AppDatabase（0.5h）
- [ ] 在 `app_database.dart` 的 `@DriftDatabase` 中添加 `LayoutTemplates` 表
- [ ] 添加 `LayoutTemplateDao` 到 daos 列表
- [ ] 更新 schema version（+1）
- [ ] 运行 `dart run build_runner build --delete-conflicting-outputs`
- **验收标准**：代码生成成功

#### Task 5.1.4：实现数据转换器（1.5h）
- [ ] 创建 `LayoutTemplateDtoMapper` 类
- [ ] 实现 `toEntity(LayoutTemplate)` 方法：
  - 序列化为 JSON 字符串
  - 创建 `LayoutTemplateEntity`
- [ ] 实现 `fromEntity(LayoutTemplateEntity)` 方法：
  - 反序列化 JSON
  - 构建 `LayoutTemplate` 对象
- [ ] 添加单元测试验证序列化/反序列化一致性
- **验收标准**：往返转换数据不丢失

---

### 里程碑 M5.2：数据迁移实现（4小时）

#### Task 5.2.1：创建迁移服务（1.5h）
- [ ] 在 `lib/services/` 下创建 `template_migration_service.dart`
- [ ] 实现 `migrateFromSharedPreferences()` 方法：
  - 检查迁移标记 `template_migrated_to_drift`
  - 如果已迁移，直接返回
  - 读取所有 SharedPreferences 中的模板数据
  - 批量写入 Drift 数据库
  - 设置迁移完成标记
- [ ] 添加错误处理和回滚逻辑
- **验收标准**：迁移方法运行无异常

#### Task 5.2.2：实现 Drift 版 Repository（1.5h）
- [ ] 创建 `LayoutTemplateDriftRepository` 实现 `LayoutTemplateRepository`
- [ ] 所有方法调用 `LayoutTemplateDao`
- [ ] 使用 `LayoutTemplateDtoMapper` 转换数据
- [ ] 添加单元测试
- **验收标准**：Repository 所有方法测试通过

#### Task 5.2.3：在应用启动时执行迁移（0.5h）
- [ ] 在 `FourZhuEditPage` 的 Provider create 中调用迁移服务
- [ ] 或在 `main.dart` 中全局执行一次
- [ ] 添加 loading 指示器
- [ ] 迁移失败时显示错误提示
- **验收标准**：首次启动后数据迁移成功

#### Task 5.2.4：切换到 Drift Repository（0.5h）
- [ ] 在 `FourZhuEditPage` 中将 `LayoutTemplateLocalDataSource` 替换为 `LayoutTemplateDriftRepository`
- [ ] 删除或废弃 `LayoutTemplateLocalDataSource`
- [ ] 运行完整测试验证功能
- **验收标准**：所有 CRUD 操作正常

---

### 里程碑 M5.3：性能优化（4小时）

#### Task 5.3.1：实现模板缓存（1h）
- [ ] 在 ViewModel 中添加模板缓存（Map<String, LayoutTemplate>）
- [ ] 加载时优先从缓存读取
- [ ] 保存/删除时更新缓存
- [ ] 添加缓存失效机制（版本号检查）
- **验收标准**：重复加载同一模板速度提升

#### Task 5.3.2：实现模板列表分页加载（1.5h）
- [ ] 在 ViewModel 中添加分页状态（`_currentPage`、`_hasMore`）
- [ ] 初始加载前 20 个模板
- [ ] 滚动到底部时加载下一页
- [ ] 添加"加载更多"指示器
- **验收标准**：模板超过 20 个时分页加载

#### Task 5.3.3：优化行配置更新性能（1h）
- [ ] 使用 `Selector` 替代 `Consumer` 减少不必要的重建
- [ ] 在 `_RowConfigItem` 中使用 `const` 构造函数
- [ ] 提取静态 Widget 避免重复构建
- **验收标准**：修改单行时其他行不重建

#### Task 5.3.4：添加性能监控（0.5h）
- [ ] 使用 `Timeline.startSync/finishSync` 标记关键操作
- [ ] 在 DevTools 中验证帧率 > 55fps
- [ ] 优化慢操作（如 JSON 序列化）
- **验收标准**：滚动/拖拽流畅无卡顿

---

## 阶段六：测试与文档（Week 4, 12小时）

### 里程碑 M6.1：单元测试补全（6小时）

#### Task 6.1.1：ViewModel 测试（2h）
- [ ] 为所有新增方法编写测试
- [ ] 测试状态变更逻辑
- [ ] 测试异步操作（加载/保存）
- [ ] 测试边界情况
- **验收标准**：ViewModel 测试覆盖率 > 90%

#### Task 6.1.2：Repository 测试（2h）
- [ ] Mock LayoutTemplateDao
- [ ] 测试 CRUD 操作
- [ ] 测试数据转换
- **验收标准**：Repository 测试覆盖率 > 90%

#### Task 6.1.3：Widget 测试（2h）
- [ ] 测试 EditorSidebar 交互
- [ ] 测试 RowStyleEditorDialog 表单
- [ ] 测试 TemplateGalleryView 选择
- [ ] 使用 `WidgetTester` 模拟点击/拖拽
- **验收标准**：主要 Widget 测试通过

#### Task 6.1.4：集成测试（1h）
- [ ] 创建端到端测试：创建模板 → 编辑 → 保存 → 加载
- [ ] 测试拖拽流程
- [ ] 测试迁移流程
- **验收标准**：集成测试通过

---

### 里程碑 M6.2：文档与交付（6小时）

#### Task 6.2.1：更新 README（1h）
- [ ] 添加功能说明
- [ ] 添加使用截图
- [ ] 更新安装说明
- [ ] 添加开发指南
- **验收标准**：README 清晰易懂

#### Task 6.2.2：更新 PRD 文档（1h）
- [ ] 标记已完成功能
- [ ] 记录实现决策
- [ ] 添加已知问题
- [ ] 规划后续迭代
- **验收标准**：PRD 与实现一致

#### Task 6.2.3：录制功能演示视频（2h）
- [ ] 录制浅色模式演示
- [ ] 录制深色模式演示
- [ ] 展示所有核心功能
- [ ] 添加旁白说明
- **验收标准**：视频 < 5分钟，清晰流畅

#### Task 6.2.4：代码审查与优化（2h）
- [ ] 运行 `flutter analyze` 修复所有警告
- [ ] 运行 `dart format .` 格式化代码
- [ ] 删除注释的旧代码
- [ ] 优化导入语句
- [ ] 添加必要的代码注释
- **验收标准**：无 lint 警告，代码整洁

---

## 任务统计

- **总任务数**：85 个原子任务
- **预计总工时**：60-80 小时
- **建议工期**：3-4 周（每天 3-4 小时）
- **里程碑数**：14 个
- **测试任务占比**：约 15%

---

## 优先级标记

🔴 **P0 - 必须完成**（阻塞核心功能）：
- 阶段一所有任务（左侧边栏、行样式编辑）
- Task 2.1.6（applyPreset 方法）
- Task 3.1.2（柱位卡片渲染）

🟡 **P1 - 高优先级**（重要但不紧急）：
- 阶段二所有任务（顶部预设区）
- 阶段三大部分任务（看板增强）

🟢 **P2 - 中优先级**（锦上添花）：
- 阶段四所有任务（底部面板）
- Task 3.2.5（跨分组拖拽）

🔵 **P3 - 低优先级**（可延后）：
- 阶段五所有任务（Drift 迁移）
- 部分测试和文档任务

---

## 验收标准模板

每个任务完成后需检查：
1. ✅ 代码编译通过，无错误
2. ✅ 功能按预期工作
3. ✅ 有对应的单元测试（如适用）
4. ✅ 符合设计稿规范
5. ✅ 无性能问题（帧率 > 50fps）
6. ✅ 代码已格式化（`dart format`）

---

## 开始前准备

- [ ] 创建新分支 `feature/eight-chars-editor-enhancement`
- [ ] 安装必要依赖（如 `flutter_colorpicker`）
- [ ] 备份现有数据
- [ ] 设置开发环境（hot reload、DevTools）
