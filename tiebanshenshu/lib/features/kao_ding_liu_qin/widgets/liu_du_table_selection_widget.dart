import 'package:flutter/material.dart';
import '../models/liu_du_table.dart';
import '../models/liu_qin_type.dart';

/// 流度表选择Widget
///
/// 展示流度表的所有条目，允许用户选择条文
class LiuDuTableSelectionWidget extends StatelessWidget {
  /// 六亲类型
  final LiuQinType liuQinType;

  /// 流度表条目列表（带条文内容）
  final List<LiuDuEntryWithTiaoWen> entries;

  /// 当前选择的条文编号
  final int? selectedTiaoWenNumber;

  /// 选择回调
  final ValueChanged<int> onSelect;

  const LiuDuTableSelectionWidget({
    super.key,
    required this.liuQinType,
    required this.entries,
    this.selectedTiaoWenNumber,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                liuQinType.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('无流度表数据'),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForLiuQinType(liuQinType),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  liuQinType.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                if (selectedTiaoWenNumber != null)
                  Chip(
                    label: Text('已选: $selectedTiaoWenNumber'),
                    labelStyle: theme.textTheme.labelSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
          ),

          // 条目列表
          SizedBox(
            height: 300, // 固定高度，可滚动
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isSelected =
                    entry.tiaoWenNumber == selectedTiaoWenNumber;
                final isTarget = entry.isTarget;

                return _buildEntryTile(
                  context,
                  entry,
                  isSelected,
                  isTarget,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建条���Tile
  Widget _buildEntryTile(
    BuildContext context,
    LiuDuEntryWithTiaoWen entry,
    bool isSelected,
    bool isTarget,
  ) {
    final theme = Theme.of(context);
    final tiaoWen = entry.tiaoWen;

    return InkWell(
      onTap: () => onSelect(entry.tiaoWenNumber),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondaryContainer
              : isTarget
                  ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                  : null,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 地支
                if (entry.zhi != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      entry.zhi!.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // 密语
                Expanded(
                  child: Text(
                    entry.chiperText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // 条文编号
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    '${entry.tiaoWenNumber}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 选中标记
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),

                // 目标标记
                if (isTarget && !isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.star,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
              ],
            ),

            // 条文内容
            if (tiaoWen != null) ...[
              const SizedBox(height: 8),
              Text(
                tiaoWen.content1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取六亲类型对应的图标
  IconData _getIconForLiuQinType(LiuQinType type) {
    switch (type) {
      case LiuQinType.father:
        return Icons.man;
      case LiuQinType.mother:
        return Icons.woman;
      case LiuQinType.husband:
        return Icons.man_2;
      case LiuQinType.wife:
        return Icons.woman_2;
      case LiuQinType.sibling:
        return Icons.people;
      case LiuQinType.son:
        return Icons.boy;
      case LiuQinType.daughter:
        return Icons.girl;
    }
  }
}
