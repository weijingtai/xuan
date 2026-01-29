import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constant/kao_ke_constants.dart';
import '../../../repository/tiao_wen_repository.dart';

/// 斗甲乙宫（三宫之数）选择表格
///
/// 展示当前宫的四支（刻）× 每支 1-5 条目
/// 单元格显示条文内容（并附带编号），点击进行选择
class DouJiaYiSelectionTable extends StatefulWidget {
  /// 当前宫的四支 × 1-5 条目
  final Map<DiZhi, List<DouJiaYiNumber>> douData;

  /// 用户出生时辰（用于文案显示与样式）
  final DiZhi birthShiChen;

  /// 点击单元格回调
  final void Function(DouJiaYiNumber) onItemSelected;

  const DouJiaYiSelectionTable({
    super.key,
    required this.douData,
    required this.birthShiChen,
    required this.onItemSelected,
  });

  @override
  State<DouJiaYiSelectionTable> createState() => _DouJiaYiSelectionTableState();
}

class _DouJiaYiSelectionTableState extends State<DouJiaYiSelectionTable> {
  Map<int, String>? _contentMap;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    try {
      final repo = Provider.of<TiaoWenRepository>(context, listen: false);
      final numbers = widget.douData.values
          .expand((list) => list.map((e) => e.tiaoWenNumber))
          .toSet()
          .toList();
      final map = await repo.getTiaoWenContentByNumbers(numbers);
      if (mounted) {
        setState(() {
          _contentMap = map;
        });
      }
    } catch (e) {
      // 仓库未注入或读取失败时，不阻断UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(child: _buildTable(context)),
    );
  }

  Widget _buildTable(BuildContext context) {
    // 列：序 1-5
    final orders = [1, 2, 3, 4, 5];

    // 行顺序：按宫的四支固定排序
    final keys = widget.douData.keys.toSet();
    final possibleOrders = const [
      [DiZhi.ZI, DiZhi.WU, DiZhi.MAO, DiZhi.YOU],
      [DiZhi.CHEN, DiZhi.XU, DiZhi.CHOU, DiZhi.WEI],
      [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI],
    ];
    List<DiZhi> rowOrder = possibleOrders.firstWhere(
      (o) => o.every(keys.contains),
      orElse: () => keys.toList(),
    );

    return DataTable(
      headingRowColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
        const DataColumn(
          label: Text('刻（地支）', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...orders.map(
          (ord) => const DataColumn(
            label: Text('序', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
      rows: rowOrder.map((zhi) {
        final rowColor = Colors.black87;
        final items = widget.douData[zhi] ?? const [];

        return DataRow(
          color: MaterialStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.12),
          ),
          cells: [
            DataCell(
              Text(
                '${zhi.name}刻',
                style: TextStyle(color: rowColor, fontWeight: FontWeight.w600),
              ),
            ),
            ...orders.map((ord) {
              final item = items
                  .where((e) => e.order == ord)
                  .cast<DouJiaYiNumber?>()
                  .firstWhere((e) => e != null, orElse: () => null);

              return DataCell(
                InkWell(
                  onTap: item == null
                      ? null
                      : () => widget.onItemSelected(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: item == null
                        ? Text(
                            '-',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '条文内容',
                                style: TextStyle(
                                  color: rowColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _displayContent(item.tiaoWenNumber),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: rowColor, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '编号 ${item.tiaoWenNumber}',
                                style: TextStyle(
                                  color: rowColor.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  String _displayContent(int number) {
    if (_contentMap == null) {
      return '加载中…';
    }
    final content = _contentMap![number];
    return content ?? '未找到内容';
  }
}
