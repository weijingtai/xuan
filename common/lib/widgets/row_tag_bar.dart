import 'package:flutter/material.dart';
import '../enums/layout_template_enums.dart';
import '../models/drag_payloads.dart';
import '../models/row_data.dart';

/// RowTagBar - 用于拖拽添加行的 Tag 列表
///
/// 功能：
/// - 以标签形式展示各"行"类型入口
/// - 支持将标签拖拽到卡片（DragTarget）以添加对应行
/// - 标签内提供抓手图标（drag_indicator），直观的拖拽提示
class RowTagBar extends StatelessWidget {
  const RowTagBar({super.key, this.disabledTypes = const {}});

  final Set<RowType> disabledTypes;

  static const double _barHeight = 28;
  static const double _tagHeight = 28;
  static const double _tagWidth = 76;

  /// 定义可拖拽的行类型及其显示标签
  List<RowData> get rows => const [
        RowData(
          rowId: 'row_separator',
          rowType: RowType.separator,
          label: '分隔符',
        ),
        RowData(
          rowId: 'title_row',
          rowType: RowType.columnHeaderRow,
          label: '标题行',
        ),
        RowData(
          rowId: 'heavenly_stem',
          rowType: RowType.heavenlyStem,
          label: '天干',
        ),
        RowData(
          rowId: 'earthly_branch',
          rowType: RowType.earthlyBranch,
          label: '地支',
        ),
        RowData(
          rowId: 'na_yin',
          rowType: RowType.naYin,
          label: '纳音',
        ),
        RowData(
          rowId: 'ten_god',
          rowType: RowType.tenGod,
          label: '十神',
        ),
        RowData(
          rowId: 'hidden_stems',
          rowType: RowType.hiddenStems,
          label: '藏干',
        ),
        RowData(
          rowId: 'hidden_stems_ten_god',
          rowType: RowType.hiddenStemsTenGod,
          label: '藏神',
        ),
        RowData(
          rowId: 'hidden_stems_primary',
          rowType: RowType.hiddenStemsPrimary,
          label: '主气',
        ),
        RowData(
          rowId: 'hidden_stems_secondary',
          rowType: RowType.hiddenStemsSecondary,
          label: '中气',
        ),
        RowData(
          rowId: 'hidden_stems_tertiary',
          rowType: RowType.hiddenStemsTertiary,
          label: '余气',
        ),
        RowData(
          rowId: 'hidden_stems_primary_gods',
          rowType: RowType.hiddenStemsPrimaryGods,
          label: '主神',
        ),
        RowData(
          rowId: 'hidden_stems_secondary_gods',
          rowType: RowType.hiddenStemsSecondaryGods,
          label: '中神',
        ),
        RowData(
          rowId: 'hidden_stems_tertiary_gods',
          rowType: RowType.hiddenStemsTertiaryGods,
          label: '余神',
        ),
        RowData(
          rowId: 'star_yun',
          rowType: RowType.starYun,
          label: '星运',
        ),
        RowData(
          rowId: 'star_yun_ten_god',
          rowType: RowType.selfSiting,
          label: '自座',
        ),
        RowData(
          rowId: 'kong_wang',
          rowType: RowType.kongWang,
          label: '空亡',
        ),
        RowData(
          rowId: 'gu',
          rowType: RowType.gu,
          label: '孤',
        ),
        RowData(
          rowId: 'xu',
          rowType: RowType.xu,
          label: '虚',
        ),
        RowData(
          rowId: 'xun_shou',
          rowType: RowType.xunShou,
          label: '旬首',
        ),
        RowData(
          rowId: 'yi_ma',
          rowType: RowType.yiMa,
          label: '驿马',
        ),
        RowData(
          rowId: 'separator',
          rowType: RowType.separator,
          label: '分隔符',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sort items: enabled first, disabled last.
    // Use stable partitioning to maintain relative order within groups.
    final enabledRows =
        rows.where((r) => !disabledTypes.contains(r.rowType)).toList();
    final disabledRowsList =
        rows.where((r) => disabledTypes.contains(r.rowType)).toList();
    final sortedRows = [...enabledRows, ...disabledRowsList];

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: SizedBox(
        height: _barHeight,
        child: ListView.separated(
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: sortedRows.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final rowData = sortedRows[index];
            final isDisabled = disabledTypes.contains(rowData.rowType);

            if (isDisabled) {
              return Opacity(
                opacity: 0.5,
                child: _RowTagWidget(
                  label: rowData.label,
                  icon: Icons.drag_indicator,
                ),
              );
            }

            return Draggable<RowData>(
              data: rowData,
              feedback: _RowTagFeedback(
                label: rowData.label,
                icon: Icons.drag_indicator,
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _RowTagWidget(
                  label: rowData.label,
                  icon: Icons.drag_indicator,
                ),
              ),
              child: _RowTagWidget(
                label: rowData.label,
                icon: Icons.drag_indicator,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 行标签的常态样式
class _RowTagWidget extends StatelessWidget {
  const _RowTagWidget({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: RowTagBar._tagWidth,
      height: RowTagBar._tagHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.secondary, // 使用不同颜色区分行/列
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 行标签的拖拽反馈
class _RowTagFeedback extends StatelessWidget {
  const _RowTagFeedback({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        width: 112,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.secondary, // 使用不同颜色区分行/列
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
