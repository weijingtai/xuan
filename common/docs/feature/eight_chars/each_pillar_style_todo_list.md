# 八字卡片 V3｜每柱样式生效与重算 Todo List

## 阶段 A：每柱写回 + margin 映射
- [ ] 启用每柱写回于子面板 onChanged（`common/lib/widgets/sidebar_pillar_editor_section.dart:92-101`）
- [ ] 新增 resolvePillarStyleFor 解析柱样式（`common/lib/viewmodels/editable_four_zhu_theme_controller.dart`）
- [ ] 映射主题到载荷 columnMargin 并重算（`common/lib/viewmodels/four_zhu_card_demo_viewmodel.dart:232-238`）
- [ ] 更新 pillarsNotifier 触发重绘与重算（`common/lib/viewmodels/four_zhu_card_demo_viewmodel.dart`）

## 阶段 B：per-index padding/borderWidth
- [ ] 扩展 PillarPayload 增加 columnPadding 字段（`common/lib/models/drag_payloads.dart:149`）
- [ ] 扩展 PillarPayload 增加 columnBorderWidth 字段（`common/lib/models/drag_payloads.dart:149`）
- [ ] 为 V3 增加 `_pillarPaddingAtIndex` 方法（`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`）
- [ ] 为 V3 增加 `_pillarBorderWidthAtIndex` 方法（`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`）
- [ ] 替换装饰宽高计算为 per-index 版本（`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart:288-306`）
- [ ] 将列宽测量引用装饰宽 per-index（`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart:495-506`）
- [ ] 在 ViewModel 写入每柱 padding/borderWidth（`common/lib/viewmodels/four_zhu_card_demo_viewmodel.dart`）
- [ ] 增加保险触发更新 `paddingNotifier.value` 等值（可选）（`common/lib/viewmodels/four_zhu_card_demo_viewmodel.dart:232-238`）

## 验证
- [ ] 验证每柱尺寸变化即时生效（列宽与装饰宽高）
- [ ] 验证未覆盖柱回退到全局样式
- [ ] 记录并更新实施进度与结果