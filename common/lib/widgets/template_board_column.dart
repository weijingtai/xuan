import 'package:flutter/material.dart';

class TemplateBoardColumn extends StatelessWidget {
  const TemplateBoardColumn({
    super.key,
    required this.label,
    required this.index,
    required this.locked,
    required this.borderColor,
    required this.onRemove,
    this.highlight = false,
  });

    final String label;
    final int index;
    final bool locked;
    final Color borderColor;
    final VoidCallback onRemove;
    final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '列 $label，位置 ${index + 1}',
      enabled: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight && !locked
                ? theme.colorScheme.primary
                : borderColor,
            width: highlight && !locked ? 2 : 1,
          ),
          color: highlight && !locked
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: highlight && !locked ? 8 : 2,
              offset: Offset(0, highlight && !locked ? 2 : 1),
              color: highlight && !locked
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : const Color(0x14000000),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_indicator, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: '移除',
                  onPressed: locked ? null : onRemove,
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '#${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.black45),
              ),
            ),
            if (highlight && !locked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '释放以插入',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

