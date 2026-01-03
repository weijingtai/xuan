import 'package:flutter/material.dart';

import '../../themes/editable_four_zhu_card_theme.dart';
import 'editable_four_zhu_style_editor_panel.dart';

/// ThemeEditPreviewSidebar
/// 侧边栏专用的“主题编辑”组件：将 Demo 页的主题编辑能力进行压缩适配，
/// 在 320px 左侧栏内提供基本主题编辑能力。
///
/// 职责：
/// - 提供 `EditableFourZhuStyleEditorPanel` 的精简承载
class ThemeEditPreviewSidebar extends StatelessWidget {
  const ThemeEditPreviewSidebar({super.key, this.initialTheme});

  final EditableFourZhuCardTheme? initialTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '主题编辑与预览',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '在侧栏中快速调整主题并预览效果',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: EditableFourZhuStyleEditorPanel(),
          ),
        ),
      ],
    );
  }
}
