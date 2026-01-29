/// 元堂卦大运展示组件
///
/// 用于展示元堂卦的大运信息（先天卦或后天卦）
library;

import 'package:flutter/material.dart';
import '../models/yuan_tang_ui_model.dart';

/// 元堂卦大运展示组件
///
/// 以表格形式展示大运信息，包括爻位、阴阳、年数、年龄区间、地支
class YuanTangDayunWidget extends StatelessWidget {
  /// 标题（"先天卦大运" / "后天卦大运"）
  final String title;

  /// 大运列表
  final List<YuanTangDayunPeriodUI> dayunList;

  /// 是否显示标题
  final bool showTitle;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 表格文字样式
  final TextStyle? cellTextStyle;

  /// 表头文字样式
  final TextStyle? headerTextStyle;

  const YuanTangDayunWidget({
    super.key,
    required this.title,
    required this.dayunList,
    this.showTitle = true,
    this.titleStyle,
    this.cellTextStyle,
    this.headerTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: titleStyle ??
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
          ),
          const SizedBox(height: 8),
        ],
        _buildDayunTable(context),
      ],
    );
  }

  /// 构建大运表格
  Widget _buildDayunTable(BuildContext context) {
    if (dayunList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('暂无大运数据'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        columns: [
          DataColumn(
            label: Text(
              '爻位',
              style: headerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '阴阳',
              style: headerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '年数',
              style: headerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '年龄区间',
              style: headerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '地支',
              style: headerTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: dayunList
            .map(
              (period) => DataRow(
                cells: [
                  DataCell(
                    Text(
                      '${period.yaoLabel}爻',
                      style: cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      period.yinYang,
                      style: cellTextStyle?.copyWith(
                            color: period.yinYang == '阳'
                                ? Colors.blue
                                : Colors.purple,
                          ) ??
                          TextStyle(
                            color: period.yinYang == '阳'
                                ? Colors.blue
                                : Colors.purple,
                          ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${period.years}年',
                      style: cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${period.ageRange}岁',
                      style: cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      period.diZhiDisplayText,
                      style: cellTextStyle,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 元堂卦大运紧凑展示组件
///
/// 以更紧凑的形式展示大运信息，适合空间受限的场景
class YuanTangDayunCompactWidget extends StatelessWidget {
  /// 标题（"先天卦大运" / "后天卦大运"）
  final String title;

  /// 大运列表
  final List<YuanTangDayunPeriodUI> dayunList;

  /// 是否显示标题
  final bool showTitle;

  const YuanTangDayunCompactWidget({
    super.key,
    required this.title,
    required this.dayunList,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
        ],
        if (dayunList.isEmpty)
          const Text('暂无大运数据')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: dayunList.map((period) => _buildDayunChip(period)).toList(),
          ),
      ],
    );
  }

  /// 构建单个大运芯片
  Widget _buildDayunChip(YuanTangDayunPeriodUI period) {
    return Chip(
      label: Text(
        '${period.yaoLabel}(${period.yinYang}-${period.years}年): ${period.ageRange}岁',
        style: const TextStyle(fontSize: 12),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
