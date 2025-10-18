import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import '../../../constant/kao_ke_constants.dart';

/// 刻选择表格Widget
///
/// 展示12时辰×8刻的选择表格
/// 用户出生时辰行使用黑色字体高亮,其他行使用灰色字体
class KeSelectionTable extends StatelessWidget {
  /// 12时辰×8刻的完整数据
  final Map<DiZhi, List<KaoEigthKeNumber>> keData;

  /// 用户出生时辰
  final DiZhi birthShiChen;

  /// 用户点击单元格的回调
  final Function(KaoEigthKeNumber) onKeSelected;

  const KeSelectionTable({
    Key? key,
    required this.keData,
    required this.birthShiChen,
    required this.onKeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: _buildTable(context),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    // 12时辰顺序
    final shiChenOrder = [
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
    ];

    // 8刻顺序
    final keOrder = [
      EigthKe.first,
      EigthKe.second,
      EigthKe.third,
      EigthKe.fourth,
      EigthKe.fifth,
      EigthKe.sixth,
      EigthKe.seventh,
      EigthKe.eighth,
    ];

    return DataTable(
      headingRowColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
        const DataColumn(label: Text('时辰', style: TextStyle(fontWeight: FontWeight.bold))),
        ...keOrder.map(
          (ke) => DataColumn(
            label: Text(
              ke.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      rows: shiChenOrder.map((shiChen) {
        final isUserBirthShiChen = shiChen == birthShiChen;
        final rowColor = isUserBirthShiChen
            ? Colors.black87
            : Colors.grey.shade600;

        final keList = keData[shiChen] ?? [];

        return DataRow(
          color: MaterialStateProperty.all(
            isUserBirthShiChen
                ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
                : null,
          ),
          cells: [
            // 时辰列
            DataCell(
              Text(
                shiChen.name,
                style: TextStyle(
                  color: rowColor,
                  fontWeight: isUserBirthShiChen ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // 8刻列
            ...keOrder.map((ke) {
              final keNumber = keList.firstWhere(
                (k) => k.ke == ke,
                orElse: () => KaoEigthKeNumber(
                  shiChen: shiChen,
                  ke: ke,
                  tiaoWenNumber: 0,
                  cipherText: '',
                  originalText: '',
                ),
              );

              return DataCell(
                InkWell(
                  onTap: () => onKeSelected(keNumber),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          keNumber.cipherText,
                          style: TextStyle(
                            color: rowColor,
                            fontSize: 12,
                            fontWeight: isUserBirthShiChen ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          keNumber.tiaoWenNumber.toString(),
                          style: TextStyle(
                            color: rowColor,
                            fontSize: 11,
                            fontWeight: isUserBirthShiChen ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          keNumber.originalText.length > 20
                              ? '${keNumber.originalText.substring(0, 20)}...'
                              : keNumber.originalText,
                          style: TextStyle(
                            color: rowColor.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: isUserBirthShiChen ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
}
