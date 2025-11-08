# CONSENSUS · 样式集中化迁移（EditableFourZhuCardV3）

## 1. 明确需求与验收标准
- 需求：
  - 引入分组默认样式集中入口，清除散落硬编码；保障 Global/Group 覆盖与 Gan/Zhi 彩色模式逻辑不变。
- 验收标准：
  - 代码编译通过，定向测试通过（卡片纯拖拽、拖拽节流测试）。
  - 默认值与历史常量一致，视觉无变化（默认情况下）。
  - 说明文档与 TODO 清单同步更新。

## 2. 技术实现方案与约束
- 实现方案：
  - 新增 `_defaultTextStyleForGroup(TextGroup)`，集中维护默认样式。
  - `_resolveTextStyle` 以集中默认为基准，按入参 → 全局 → 分组 → Gan/Zhi 非彩色补黑的顺序合并；彩色模式下全局色抑制（Gan/Zhi）。
  - builder 端（rowTitle/columnTitle/naYin/kongWang）统一改为仅传 `group`，避免局部硬编码。
- 约束：
  - 不修改 palette 或 ElementColorResolver 的行为。
  - 不引入 UI 改动；不影响测量与 Drag 行为。

## 3. 集成方案
- 与现有 `groupTextStyles`/`globalFont*` 保持兼容与优先级一致。
- 在非 colorfulMode 下，Gan/Zhi 默认黑色；在 colorfulMode 下，颜色通过 resolver 与 per-token 覆写确定。

## 4. 任务边界与验收
- 边界：本阶段仅覆盖四个 builder 的迁移与集中入口引入。
- 验收：
  - 执行定向测试：`editable_fourzhu_card_v3_pure_drag_test.dart`、`drag_controller_throttle_test.dart` → 全部通过。
  - 文档更新到位：`common/docs/说明文档.md` 与 `EditableFourZhuCardV3_refactor/TODO_CHECKLIST.md`。

## 5. 未决问题与后续计划
- 未决（需人工确认）：
  - 新增行（旬首/十神/藏干系列）的默认样式建议与 Dark/Light 适配策略。
- 后续计划（阶段 2）：
  - 扩展默认样式到更多行类型，补充 Widget 测试与编辑器联动验证。