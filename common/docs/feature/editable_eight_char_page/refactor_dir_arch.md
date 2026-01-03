# 目录重构计划（FourZhuCard / 四柱卡片样式编辑）

## 背景
当前与“四柱可编辑卡片”相关的代码分散在 `common/lib/widgets/*`、`common/lib/themes/*`、`common/lib/models/*`、`common/lib/pages/*`、`common/lib/viewmodels/*` 等多处，导致：

- 卡片渲染（FourZhuCard）与样式编辑（Style Editor）耦合感强、定位成本高
- 依赖关系不清晰，容易引入循环依赖或错误导入（例如 `.bak` 文件被导入）
- 难以做到“高内聚、低耦合”的功能聚合

本计划将相关代码聚合为两个功能目录（features）：

1. `four_zhu_card`：纯“四柱卡片组件”能力（渲染/拖拽/度量/卡片内部模型）
2. `four_zhu_card_style_editor`：对“四柱卡片样式”的编辑 UI（侧边栏/面板/编辑控件）

同时引入一个非 feature 的共享目录（避免出现第三个 feature），存放双方共用的基础类型。

## 目标目录结构（建议）

以 `common/lib/` 为根目录：

```text
common/lib/
  features/
    four_zhu_card/
      widgets/
        editable_fourzhu_card/        # 原 editable_fourzhu_card 目录整体搬迁
        four_zhu_add_palette.dart     # 卡片“添加面板”属于卡片交互能力
      themes/
        editable_four_zhu_card_theme.dart
    four_zhu_card_style_editor/
      pages/
        four_zhu_edit_page.dart       # 编辑页面（入口）
      view/
        editor_workspace.dart         # 编辑工作区（卡片+交互）
        editor_sidebar_v2.dart        # 侧边栏（聚合样式编辑入口）
      widgets/
        style_editor/                 # 原 widgets/style_editor 目录整体搬迁
        row_style_editor_form.dart
        template_*                    # 模板相关（若仅用于编辑页）
        *_tag_bar.dart                # 行/柱选择（若仅用于编辑页）
  shared/
    four_zhu_card/
      models/
        drag_payloads.dart
        row_strategy.dart
        text_style_config.dart
      enums/
        layout_template_enums.dart
```

说明：

- `shared/four_zhu_card/*` 仅放“卡片与编辑器共同依赖”的基础类型；避免 third feature。
- `FourZhuEditorViewModel` 是否迁入 `four_zhu_card_style_editor`：可作为后续优化点，第一期可先保持原位置不动（降低改动面）。
- 现有 `common/lib/widgets/editable_fourzhu_card.dart` 建议保留为兼容层（re-export 新路径），避免一次性大范围改 imports。

## 文件归类（当前 → 迁移后）

### A. 卡片能力（four_zhu_card）

- `common/lib/widgets/editable_fourzhu_card/*` → `common/lib/features/four_zhu_card/widgets/editable_fourzhu_card/*`
- `common/lib/widgets/editable_fourzhu_card.dart` → 保留为兼容层（export 新路径）
- `common/lib/widgets/four_zhu_add_palette.dart` → `common/lib/features/four_zhu_card/widgets/four_zhu_add_palette.dart`
- `common/lib/themes/editable_four_zhu_card_theme.dart` → `common/lib/features/four_zhu_card/themes/editable_four_zhu_card_theme.dart`

### B. 样式编辑（four_zhu_card_style_editor）

- `common/lib/widgets/style_editor/*` → `common/lib/features/four_zhu_card_style_editor/widgets/style_editor/*`
- `common/lib/widgets/editor_sidebar_v2.dart` → `common/lib/features/four_zhu_card_style_editor/view/editor_sidebar_v2.dart`
- `common/lib/widgets/four_zhu_card_editor_page/editor_workspace.dart` → `common/lib/features/four_zhu_card_style_editor/view/editor_workspace.dart`
- `common/lib/pages/four_zhu_edit_page.dart` → `common/lib/features/four_zhu_card_style_editor/pages/four_zhu_edit_page.dart`

说明：`template_gallery_view.dart` / `template_board_view.dart` / `row_tag_bar.dart` / `pillar_tag_bar.dart` 是否迁入本 feature 取决于它们是否仅被编辑页使用。若被其他页面复用，则保留在原位置。

### C. 共享基础（shared/four_zhu_card）

建议以“是否被 card 与 editor 同时依赖”为准进行迁移：

- `common/lib/models/drag_payloads.dart` → `common/lib/shared/four_zhu_card/models/drag_payloads.dart`
- `common/lib/models/row_strategy.dart` → `common/lib/shared/four_zhu_card/models/row_strategy.dart`
- `common/lib/models/text_style_config.dart` 与 `common/lib/widgets/editable_fourzhu_card/models/text_style_config.dart`：需要先做一次去重/统一来源（见 TodoList）
- `common/lib/enums/layout_template_enums.dart` → `common/lib/shared/four_zhu_card/enums/layout_template_enums.dart`

## 原子化可执行 TodoList（按顺序执行）

### 0. 基线与防回归

- [ ] 拉起工程并跑通现有构建/测试基线（记录当前命令与结果）
- [ ] 识别并列出四柱卡片相关的入口页面（Demo、EditPage、Example）
- [ ] 以“可回滚”为目标建立迁移分支策略（每一阶段可独立回滚）

验收标准：基线可复现；已确认所有入口都能在迁移后验证。

### 1. 清理异常文件导入（阻断风险）

- [ ] 定位所有 `.bak`/`.bakv1` 被 import 的位置并清理（必须消除对备份文件的依赖）
- [ ] 将需要保留的备份文件移出 `lib/`（或改名为不被 analyzer 识别的目录/后缀）

验收标准：工程 analyzer 不再扫描到 `.bak` 导入；相关页面编译通过。

### 2. 创建目标目录与兼容层（最小影响）

- [ ] 创建 `common/lib/features/four_zhu_card/*` 与 `common/lib/features/four_zhu_card_style_editor/*`
- [ ] 创建 `common/lib/shared/four_zhu_card/*`
- [ ] 为外部调用保留兼容 re-export（例如保留 `common/lib/widgets/editable_fourzhu_card.dart`）

验收标准：仅新增目录/导出，不改业务逻辑；工程仍可编译。

### 3. 迁移卡片实现目录（EditableFourZhuCard）

- [ ] 迁移 `common/lib/widgets/editable_fourzhu_card/**` → `features/four_zhu_card/widgets/editable_fourzhu_card/**`
- [ ] 更新卡片内部相对 import（保持同目录结构，优先用相对路径）
- [ ] 保持原入口文件 re-export 到新路径

验收标准：卡片组件在 Demo/EditPage 中可正常渲染与拖拽；无运行时异常。

### 4. 迁移卡片主题（EditableFourZhuCardTheme）

- [ ] 迁移 `common/lib/themes/editable_four_zhu_card_theme.dart` → `features/four_zhu_card/themes/` 
- [ ] 更新所有引用方 import 路径（卡片与样式编辑器两边）

验收标准：主题 JSON 序列化/反序列化保持一致；样式编辑器修改后渲染实时生效。

### 5. 迁移样式编辑器（style_editor 目录）

- [ ] 迁移 `common/lib/widgets/style_editor/**` → `features/four_zhu_card_style_editor/widgets/style_editor/**`
- [ ] 更新内部 import 与 Provider 依赖（确保仍使用 `FourZhuEditorViewModel` 单一来源）

验收标准：侧边栏/样式面板可用；修改字体/颜色/阴影等配置，卡片实时更新。

### 6. 迁移编辑页 UI 聚合（EditPage / Workspace / Sidebar）

- [ ] 迁移 `pages/four_zhu_edit_page.dart` → `features/four_zhu_card_style_editor/pages/`
- [ ] 迁移 `widgets/four_zhu_card_editor_page/editor_workspace.dart` → `features/four_zhu_card_style_editor/view/`
- [ ] 迁移 `widgets/editor_sidebar_v2.dart` 与 `row_style_editor_form.dart` → `features/four_zhu_card_style_editor/view|widgets/`

验收标准：编辑页功能完整；模板切换、行/列拖拽、主题切换与预览模式联动均可用。

### 7. 抽取共享基础类型（shared/four_zhu_card）

- [ ] 迁移 `drag_payloads.dart`、`row_strategy.dart`、`layout_template_enums.dart` 到 `shared/four_zhu_card/`
- [ ] 统一 `TextStyleConfig` 的来源（消除 `models/text_style_config.dart` 与 `widgets/.../models/text_style_config.dart` 的重复/分裂）
- [ ] 逐步替换 import（先替换 feature 内，再替换外部调用方）

验收标准：shared 目录只包含基础类型；不存在循环依赖；工程编译通过。

### 8. 扫尾：全局引用更新与删除旧路径

- [ ] 全局搜索旧路径引用并逐一替换为新路径或兼容导出
- [ ] 删除已迁移且不再引用的旧目录文件（避免双份代码）

验收标准：无死链 import；不存在重复定义；目录结构符合预期。

### 9. 回归验证（必须执行）

- [ ] 运行 lint/analyze 与 typecheck（以项目既有命令为准）
- [ ] 运行单测（以项目既有命令为准）
- [ ] 运行 Demo/EditPage 手工回归：拖拽、模板切换、主题切换、纯色/彩色/黑白、深浅色编辑目标切换

验收标准：CI 级别检查通过；核心交互可用；无明显性能退化（拖拽/重排不卡顿）。

## 迁移顺序（依赖最小化）

推荐顺序：

1) 清理 `.bak` 导入 → 2) 迁移卡片目录 → 3) 迁移主题 → 4) 迁移 style_editor → 5) 迁移 EditPage/Workspace/Sidebar → 6) 抽取 shared 类型 → 7) 清理旧路径。

理由：先搬“被最多引用的底层（卡片/主题）”，再搬“上层聚合（编辑 UI）”，最后统一 shared，能减少每一步的改动面与回滚成本。

## 回滚策略

- 每个阶段迁移后应确保工程可编译并通过至少一次入口验证（Demo 或 EditPage）。
- 若某阶段失败：
  - 仅回滚该阶段的文件移动与 import 修改
  - 保留兼容层 re-export，确保外部调用不被破坏
- `.bak` 清理失败时优先回滚 import 修改，但不要恢复对 `.bak` 的依赖（应改为正式文件或删除）。

## 风险点与对策

- 路径移动导致 import 大面积变更：优先保留兼容 re-export，分阶段替换。
- `TextStyleConfig` 重复来源：先做统一入口（shared）再做删除，避免同名类型冲突。
- 自动生成文件（`*.g.dart`）：迁移后必须确保 build_runner 生成路径不冲突。
- feature 与 shared 的依赖方向：必须保证 `shared` 不反向依赖 `features`。
