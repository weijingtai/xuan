# Editable Content Text Color - TODO List

## 目标
在现有 `ColorPreviewMode(pure/colorful)` 基础上完成“对齐 + 扩展”：
1) 对齐已有功能：统一 V4 渲染主链路的取色语义，避免并行/哨兵逻辑影响最终渲染。
2) 扩展为三模式（命名保持直观）：
   - blackwhite（黑白模式）：同一主题下全体同色；允许调节黑/白深浅以弱化 UI（黑→灰、白→灰）；每行可独立配置深浅。
   - pure（原纯色）：使用纯色表（每个字符可独立配置纯色）；缺失 key 时走“按模式默认色”。
   - colorful（原色彩）：使用色彩表（每个字符可独立配置色彩）；缺失 key 时走“按模式默认色”。
3) 卡片级切换到 blackwhite 后：所有行统一进入 blackwhite 模式渲染，但使用各自行的 blackwhite 深浅配置（“每行独立调整”仍保留）。
4) 阴影 followTextColor：在 blackwhite 下也跟随 blackwhite 解析出的文字颜色。

## 推荐决策（已内置到任务拆分）
- 推荐 1：blackwhite 深浅存“强度参数”而不是存最终色值
  - 原因：更容易保持整体风格一致（只调弱/调强），并且对默认值/兼容更友好。
- 推荐 2：blackwhite 深浅的编辑交互默认“联动 Light/Dark”，并支持切换为分别调节
  - 默认联动可覆盖大多数弱化需求，减少用户操作成本；需要精细控制时再分离两侧。

## 范围边界
- ✅ 覆盖 V4 卡片渲染链路颜色解析：`TextStyleConfig.toTextStyle(...) -> ColorMapperDataModel.getBy/getMapperBy(...)`
- ✅ 覆盖样式编辑器（行样式字体颜色相关）对 `ColorPreviewMode` 的切换与配置写回
- ✅ 兼容旧数据（模板/主题 JSON）加载：缺字段使用默认值，不崩溃、不出现不可预测颜色
- ✅ blackwhite 作为最终卡片渲染可选模式（不仅编辑预览）
- ❌ 暂不引入无障碍/对比度硬限制（后续再加）
- ❌ 不做“按五行/元素自动调色策略”的重构（保持现状，只保证不再与 V4 主链路冲突）

## 关键定义（最终渲染结果）
- blackwhite：
  - Light：颜色可调，从“灰”渐变到“黑”（用于弱化非关键内容）
  - Dark：颜色可调，从“灰”渐变到“白”
  - 对同一主题：与 content 无关，所有字符同色
  - 粒度：每行（RowType 对应的 `TextStyleConfig`）独立配置深浅参数
- pure：
  - 从 `pureLightMapper/pureDarkMapper` 取色（每字符可独立配置）
  - 缺失 key 时走“纯色默认值”（按模式默认色）
- colorful：
  - 从 `colorfulLightMapper/colorfulDarkMapper` 取色（每字符可独立配置）
  - 缺失 key 时走“色彩默认值”（按模式默认色）

---

## 任务清单（原子任务，全部位于 common/lib 链路）

### A0 - 盘点（只读排查，不改逻辑）
- [x] A0.1 盘点 `ColorPreviewMode` 的所有使用点（枚举/序列化/UI 状态/渲染入口）并记录文件路径与职责
- [x] A0.2 盘点并行“颜色模式”体系（`TextColorMode`、`TextStyle.color==null` 哨兵、`bool colorful` 等）并标注是否影响 V4
- [x] A0.3 画出 V4 取色主链路（从 `ValueNotifier<ColorPreviewMode>` → `CardDataAdapter.getCellStyle` → `TextStyleConfig.toTextStyle` → `ColorMapperDataModel.getBy/getMapperBy`）

### A1 - 枚举与命名（保持 pure/colorful；新增 blackwhite）
- [x] A1.1 在 `common/lib/models/text_style_config.dart` 将 `ColorPreviewMode` 扩展为 `pure/colorful/blackwhite`（含 JSON 值）
- [x] A1.2 全局搜索并补齐所有 `switch(ColorPreviewMode ...)` 的分支覆盖（编译期兜底）
- [x] A1.3 更新所有模式标签文案：pure=纯色，colorful=色彩，blackwhite=黑白

### A2 - blackwhite 数据建模（每行独立可调）
- [x] A2.1 在 `ColorMapperDataModel` 增加 `blackwhiteLightStrength/blackwhiteDarkStrength` 字段（0..1）
- [x] A2.2 为上述字段补齐 JSON 读写与默认值（旧数据缺字段时默认 1.0）
- [x] A2.3 定义并固化 strength→颜色规则：Light `lerp(grey, black87, s)`；Dark `lerp(grey, white70, s)`

### A3 - 取色规则对齐（V4 唯一生效入口）
- [x] A3.1 改造 `ColorMapperDataModel.getMapperBy(...)`：
  - pure/colorful：返回对应 mapper
  - blackwhite：不返回 mapper（或返回空），由 `getBy(...)` 统一返回 blackwhite 颜色
- [x] A3.2 改造 `ColorMapperDataModel.getBy(...)`：
  - blackwhite：忽略 content，直接返回当前 brightness 的 blackwhite 颜色（由该行 strength 决定）
  - pure/colorful：按 mapper 取色；缺 key 走“按模式默认色”（不要落到 defaultColor 的蓝灰）
- [ ] A3.3 回归验证：在 pure/colorful 下，现有天干/地支逐字色与固定值行逐字色行为不变化

### A4 - 卡片级切换（blackwhite 覆盖全行，但每行深浅不同）
- [x] A4.1 在编辑器工作区把“二态开关”改为“三态选择”（pure/colorful/blackwhite），输出到同一个 `ValueNotifier<ColorPreviewMode>`
- [x] A4.2 验证：切到 blackwhite 后所有行统一走 blackwhite 分支，但各行显示深浅仍来自各自 `TextStyleConfig` 配置

### A5 - 行样式编辑：blackwhite 深浅调节（写回每行 TextStyleConfig）
- [x] A5.1 在行样式字体颜色编辑器中：当预览模式为 blackwhite 时显示 strength 控件
- [x] A5.2 实现“默认联动 + 可取消联动”的交互：联动时一个滑块同时写两侧 strength
- [x] A5.3 拖动滑块即时更新预览（Light/Dark 均可直观看到变灰/变深）
- [x] A5.4 将 strength 写回当前行的 `TextStyleConfig.colorMapperDataModel`（切换行再回来保持）
- [x] A5.5 blackwhite 下禁用/隐藏逐字调色 UI，避免用户误以为逐字色会生效

### A6 - 固定值行 keys 归一化（防缺 key）
- [x] A6.1 确保十神/旬首/纳音/空亡等固定值行传入稳定 values 列表（用于补齐 mapper keys）
- [x] A6.2 在构建/加载 `TextStyleConfig` 时执行 mapper keys 归一化：缺 key 自动补齐为“按模式默认色”

### A7 - 阴影 followTextColor 与 blackwhite 对齐
- [x] A7.1 验证 blackwhite 下 `followTextColor` 的阴影基色取值来自 blackwhite 文字颜色
- [ ] A7.2 回归验证 pure/colorful 下阴影行为不变

### A8 - 测试（最小可行覆盖）
- [ ] A8.1 单测：blackwhite 模式下不同 content 返回同色；strength 改变能改变颜色（Light/Dark 各一组）
- [ ] A8.2 单测：pure/colorful 模式下缺 key 使用“按模式默认色”，不会落入蓝灰 defaultColor
- [ ] A8.3 组件/集成测试（如已有 harness）：切换模式 → 调 blackwhite 深浅 → 写回 → V4 渲染生效

---

## 影响文件（初步清单，执行时以实际引用为准）
- 核心模型：
  - `common/lib/models/text_style_config.dart`
- V4 渲染链路：
  - `common/lib/widgets/editable_fourzhu_card/internal/card_data_adapter.dart`
- 编辑器入口与预览状态：
  - `common/lib/widgets/four_zhu_card_editor_page/editor_workspace.dart`
  - `common/lib/widgets/style_editor/colorful_text_style_editor_widget_v2.dart`
- 固定值行 values：
  - `common/lib/widgets/style_editor/row_style_editor_panel.dart`
- 遗留/并行体系（仅做隔离或确认不影响）：
  - `common/lib/widgets/editable_fourzhu_card/models/theme_color_mode.dart`
  - `common/lib/widgets/editable_fourzhu_card/models/text_style_config.dart`

## 完成定义（Definition of Done）
- 三模式在 V4 渲染下行为与定义一致
- blackwhite 可调深浅（每行独立生效），并能明显弱化 UI（黑→灰/白→灰）
- 卡片切到 blackwhite 后所有行统一按 blackwhite 渲染，但各行深浅仍不同
- 旧 pure/colorful 行为不回归
- 固定值行不再出现错误 values 列表或缺 key 导致的不可配置问题
- 至少包含单测覆盖三模式取色逻辑（Light/Dark）

---

# 资产色卡颜色选择器（assets/colors/*.json）- TODO List

## 目标
- 在颜色选择器中展示 `assets/colors/*.json` 的关键信息（不展示 `meta.id`）
- 统一颜色选择入口，优雅嵌入现有样式编辑器：逐字改色/阴影颜色/边框与背景
- 兼容现有调用方式：继续以 `Future<Color?>` 返回选中色

## 数据源与字段
- 数据源：
  - `assets/colors/zhongguose_color.json`
  - `assets/colors/forbidden_city_color.json`
- 每个条目展示字段（排除 id）：
  - `meta.name`
  - `schema.hex`
  - `schema.rgb`

## 原子任务清单

### C0 - 盘点与接入点梳理（只读排查）
- [x] C0.1 枚举当前所有颜色选择入口（`showColorPickerDialog` / `showAppPalettePickerDialog`）的调用点与用途
- [x] C0.2 确认文本样式编辑器 V2 的逐字改色入口（如 `_pickGanColor`）与阴影入口（如 `_pickLightShadowColor/_pickDarkShadowColor`）的位置
- [x] C0.3 确认 `common/pubspec.yaml` 已包含 `../assets/colors/`（避免运行期 rootBundle 找不到资源）

### C1 - 数据模型增强（PaletteEntry 承载 key info）
- [x] C1.1 扩展 `PaletteEntry`：增加 `hex`、`rgb` 字段（保留 `name`、`color`）
- [x] C1.2 加强 `PaletteEntry.fromJson(...)`：对缺失字段做容错（例如缺 `rgb/hex` 时不崩溃）
- [x] C1.3 统一 hex 解析与规范化（支持 `#RRGGBB` 与 `#AARRGGBB`）并确保 `Color` 解析稳定
- [x] C1.4 为 `_loadPalette(...)` 增加缓存（memoize），避免每次打开对话框重复解析 JSON

### C2 - UI：网格条目展示关键信息（除 id）
- [x] C2.1 改造 `_PaletteGrid` item 布局：色块 + 三行信息（name/hex/rgb）
- [x] C2.2 处理长文本：name 单行省略号；hex/rgb 使用等宽字体或较小字号以保持对齐
- [x] C2.3 处理深色/浅色主题可读性：信息区增加半透明底或自动切换文字色

### C3 - UI：详情与复制能力（不改变主选择流程）
- [x] C3.1 增加长按/信息按钮：弹出详情视图（大色块 + name/hex/rgb）
- [x] C3.2 在详情视图提供复制按钮：复制 hex、复制 rgb（剪贴板）

### C4 - UI：搜索（提升 300+ 色可用性）
- [x] C4.1 在“中华色/故宫色”Tab 顶部加入搜索框
- [x] C4.2 搜索匹配：name/hex/rgb 三字段 `contains`（大小写不敏感）
- [x] C4.3 搜索状态下保持 Grid 的滚动与性能稳定（仍用 `GridView.builder`）

### C5 - 交互：选中态与确定返回（兼顾效率与可控性）
- [x] C5.1 设计交互：单击条目更新“当前选中”，不立即关闭
- [x] C5.2 增加底部“当前选中信息条”：展示 name/hex/rgb + 小色块
- [x] C5.3 支持快速返回：双击条目直接返回，或提供“快速选择”开关
- [x] C5.4 保持原有 `Future<Color?>` 返回语义：取消返回 null，确定返回 selected

### C6 - 统一入口：showAppPalettePickerDialog 升级（优雅嵌入）
- [x] C6.1 保持现有 API 不变（`initialColor/title` + `Future<Color?>`）
- [x] C6.2 将新 Grid/搜索/详情能力全部落在 `showAppPalettePickerDialog` 内部，业务侧零感知

### C7 - 业务接入：逐字改色与阴影改色统一到新选择器
- [x] C7.1 将 V2 文本编辑器逐字改色入口由 `showColorPickerDialog` 改为 `showAppPalettePickerDialog`
- [x] C7.2 将 V2 阴影颜色入口由 `showColorPickerDialog` 改为 `showAppPalettePickerDialog`
- [x] C7.3 保持写回逻辑不变：继续使用 `ColorMapperDataModel.update(...)` / shadow model copyWith

### C8 - 回归与验收
- [ ] C8.1 验证“关键信息展示”不包含 `meta.id`
- [ ] C8.2 验证 BoxBorder/BoxStyle/BoxShadow 等现有入口自动获得新能力且不回归
- [ ] C8.3 验证逐字改色在 pure/colorful 下写回后卡片立即生效（含 Light/Dark 侧切换）
- [ ] C8.4 验证搜索、选中态、确定/取消返回值符合预期

## 影响文件（预期）
- `common/lib/widgets/style_editor/widgets/app_palette_picker_dialog.dart`
- `common/lib/widgets/style_editor/colorful_text_style_editor_widget_v2.dart`
- （间接受益，无需改动调用方）
  - `common/lib/widgets/style_editor/widgets/box_border_style_editor.dart`
  - `common/lib/widgets/style_editor/widgets/box_style_config_editor.dart`
  - `common/lib/widgets/style_editor/widgets/box_shadow_style_editor.dart`

---

# 透明度统一（移除独立 opacity 字段）- TODO List

## 目标
- 统一“透明度”的唯一来源：仅存在于 `Color.alpha`（`#AARRGGBB`）中
- 移除/停用所有独立透明度字段（如 `shadowOpacity`、`BoxShadowStyle.opacity`），避免“双体系叠加/覆盖”导致的不可控
- 保持向后兼容：旧数据仍可加载，并在保存/写回后自然完成迁移（透明度收敛到颜色自身）

## 范围边界
- ✅ 文本阴影（TextStyle.shadows）透明度：由阴影颜色 `Color.alpha` 决定
- ✅ 卡片容器阴影（BoxShadow）透明度：由阴影颜色 `Color.alpha` 决定
- ✅ 颜色选择器：提供 alpha 调节能力，但只通过返回的 `Color` 体现（不新增独立透明度字段）
- ✅ 兼容旧 JSON：读入旧字段时做一次性融合（alpha = 旧 opacity 映射），写出时不再输出旧字段
- ❌ 不做颜色策略（五行/自动配色）与渲染链路的其他重构

## 关键决策（收敛规则）
- 决策 1：阴影强度只由“阴影色的 alpha”表达
  - 文本阴影：`Shadow.color.alpha` 直接决定强度
  - 容器阴影：`BoxShadow.color.alpha` 直接决定强度
- 决策 2：follow 逻辑只跟随 RGB，不跟随 alpha
  - followTextColor：阴影 RGB = 文字 RGB；阴影 alpha = 当前阴影色 alpha
  - followCardBackgroundColor：阴影 RGB = 背景 RGB；阴影 alpha = 当前阴影色 alpha
- 决策 3：兼容旧数据时仅在 fromJson 做融合，不保留“双写双读”

## 原子任务清单

### D0 - 盘点与影响面确认（只读排查）
- [ ] D0.1 搜索全仓：列出所有 `shadowOpacity` 的定义与读写点（模型/序列化/UI/渲染）
- [ ] D0.2 搜索全仓：列出所有 `BoxShadowStyle.opacity` 的定义与读写点（模型/序列化/UI/渲染）
- [ ] D0.3 确认所有阴影最终落到 `Shadow.color`/`BoxShadow.color` 的路径中是否存在 `withAlpha/withOpacity` 覆盖行为
- [ ] D0.4 记录需要迁移的 JSON 字段名清单（旧字段→新语义）与默认值策略

### D1 - 文本阴影模型收敛（TextShadowDataModel）
- [ ] D1.1 移除 `TextShadowDataModel.shadowOpacity`（或标记废弃并停止使用），将强度完全交给 `lightShadowColor/darkShadowColor.alpha`
- [ ] D1.2 修改 `TextStyleConfig.toTextStyle...`：不再对阴影做 `withAlpha(255*shadowOpacity)` 覆盖，直接使用解析出的阴影颜色
- [ ] D1.3 修改 `TextShadowDataModel.resolveColor(...)` 的 followTextColor 语义：只跟随 RGB，alpha 取阴影自身 alpha
- [ ] D1.4 fromJson 兼容迁移：若读到旧 `shadowOpacity`，将其融合进 `shadowColor`（alpha = round(opacity*255)），并忽略旧字段
- [ ] D1.5 toJson 输出收敛：不再输出旧 `shadowOpacity` 字段（确保一次保存后完成迁移）

### D2 - 容器阴影模型收敛（BoxShadowStyle）
- [ ] D2.1 移除 `BoxShadowStyle.opacity`（或标记废弃并停止使用），将强度完全交给 `lightThemeColor/darkThemeColor.alpha`
- [ ] D2.2 修改阴影构建：不再 `baseColor.withOpacity(opacity)` 覆盖；follow 背景时只替换 RGB，alpha 取阴影自身 alpha
- [ ] D2.3 fromJson 兼容迁移：若读到旧 `opacity`，融合进 `lightThemeColor/darkThemeColor` 的 alpha
- [ ] D2.4 toJson 输出收敛：不再输出旧 `opacity` 字段（确保一次保存后完成迁移）

### D3 - 编辑器 UI 对齐（移除独立透明度滑块）
- [ ] D3.1 文本阴影编辑 UI：移除“阴影透明度”滑块与相关状态写回，改为修改阴影色 alpha
- [ ] D3.2 容器阴影编辑 UI（box shadow editor）：移除“阴影透明度”滑块与 `opacity` 写回，改为修改阴影色 alpha
- [ ] D3.3 follow 模式下的交互约束：
  - 允许用户调 alpha（强度）
  - RGB 由 follow 目标决定，但不影响 alpha

### D4 - 颜色选择器增强（仅通过 Color.alpha 表达）
- [ ] D4.1 为 `showAppPalettePickerDialog` 增加 alpha 调节区（例如 Slider 0..255 或 0..100%）并实时作用于 `selected.withAlpha(...)`
- [ ] D4.2 选中信息条展示 alpha：HEX 若非不透明显示 `#AARRGGBB`，并展示 `A: xx%` 或 `Alpha: 0..255`
- [ ] D4.3 详情弹窗补充 alpha 信息与复制：复制 HEX 时按当前 alpha 输出
- [ ] D4.4 保持返回值语义不变：仍返回 `Future<Color?>`，透明度只体现在返回的 `Color` 中

### D5 - 回归验证与验收
- [ ] D5.1 回归：旧数据加载后阴影视觉一致（或符合“alpha=旧opacity”融合规则），并且保存一次后完成迁移
- [ ] D5.2 回归：followTextColor / followCardBackgroundColor 行为符合“只跟随 RGB，不跟随 alpha”
- [ ] D5.3 回归：所有阴影不再出现“颜色 alpha 与 opacity 二次叠加/覆盖”导致的意外变淡/变深
- [ ] D5.4 冒烟测试：逐字改色、阴影改色、卡片阴影改色都可通过同一颜色选择器调整 alpha

## 影响文件（预期）
- 模型与渲染：
  - `common/lib/models/text_style_config.dart`
  - `common/lib/widgets/editable_fourzhu_card/models/base_style_config.dart`
- 编辑器：
  - `common/lib/widgets/style_editor/colorful_text_style_editor_widget_v2.dart`
  - `common/lib/widgets/style_editor/widgets/box_shadow_style_editor.dart`
- 颜色选择器：
  - `common/lib/widgets/style_editor/widgets/app_palette_picker_dialog.dart`
