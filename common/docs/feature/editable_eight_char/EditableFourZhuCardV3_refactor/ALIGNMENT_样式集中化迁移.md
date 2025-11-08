# ALIGNMENT · 样式集中化迁移（EditableFourZhuCardV3）

## 1. 项目上下文分析
- 代码位置：`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
- 已有能力：
  - `_resolveTextStyle({ fontSize, weight, color, group })` 支持 Global 与 Group 覆写；Gan/Zhi 在 colorfulMode 下抑制全局色，非彩色模式默认黑色。
  - `elementColorResolver` 与 `perGanColors/perZhiColors` 提供天干/地支的彩色映射。
  - `groupTextStyles: Map<TextGroup, TextStyle>` 支持分组覆写（字体家族/字号/粗细/阴影/颜色）。
- 现状问题：
  - `_naYinText/_kongWangText/_rowTitleText/_columnTitleText` 中存在 fontSize、weight、color 的硬编码，导致样式默认值分散，扩展新行（旬首/十神/藏干）时容易重复与不一致。
  - 难以在主题/模式切换时统一管理默认样式。

## 2. 需求理解确认
- 目标：引入“分组默认样式集中入口”，消除散落硬编码；保持现有覆盖优先级与彩色模式逻辑不变；尽量不产生视觉回归。
- 范围：Typography 默认值与解析逻辑；不改变 palette 或布局/测量逻辑；不新增 UI 改动。
- 验收：
  - 代码编译与现有定向测试通过。
  - 默认值与历史常量一致，视觉无变化（除非用户显式提供 global/group 覆盖）。
  - 文档与待办清单同步更新。

## 3. 边界确认（任务范围）
- 仅作用于 `TextStyle` 的默认值来源与解析优先级；不变更 Drag/HitTest/布局模型。
- Gan/Zhi 彩色模式与 perGan/perZhi 覆写逻辑保持不变。
- 不引入新的持久化字段或接口签名变更。

## 4. 智能决策策略
- 集中入口方法：`_defaultTextStyleForGroup(TextGroup)` 返回各组的默认样式。
- `_resolveTextStyle` 以集中默认为基准，按“入参 → 全局 → 分组 → Gan/Zhi 非彩色补黑”的顺序合并。
- 先覆盖常用分组（行/列标题、纳音、空亡、Gan/Zhi）后扩展到旬首/十神/藏干系列，以减少一次性改动风险。

## 5. 需要澄清的问题（按优先级）
1) 新增行的默认样式建议：旬首/十神/藏干系列字号/粗细/颜色的初始值是否采用 14sp、w400 与黑色系？
2) 是否需要在 Dark/Light 模式下对 NaYin/KongWang 的默认颜色进行适配（如 amber 在 Dark 模式的可读性）？
3) 是否需要在说明文档中增加一份“样式接入规范”，作为团队约束（避免直接在 builder 中硬编码）？

## 6. 初步共识（待确认）
- 集中入口与四个 builder 的迁移可先行落地，保持视觉不变。
- 扩展更多行的默认样式在下一阶段执行，必要时在说明文档补充“统一默认风格建议”，并允许后续调整。

## 7. 对齐结论
- 执行路径：先完成集中入口与四个 builder 去硬编码 → 定向测试 → 文档与清单更新 → 进入阶段 2 扩展更多行类型的默认值与测试。