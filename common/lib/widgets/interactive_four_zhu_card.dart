import 'dart:async';

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_card.dart';
import 'package:flutter/material.dart';

class InteractiveFourZhuCard extends StatefulWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final JiaZi? keZhu;
  final double width;

  const InteractiveFourZhuCard({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
    this.width = 380.0,
  }) : super(key: key);

  @override
  _InteractiveFourZhuCardState createState() => _InteractiveFourZhuCardState();
}

class _InteractiveFourZhuCardState extends State<InteractiveFourZhuCard> {
  // --- STATE VARIABLES ---
  // Options state
  bool _showTaiYuan = false;
  bool _showXunShou = false;
  bool _showNaYin = false;
  bool _showKongWang = false;
  bool _showKe = false;

  Widget _buildOptionChip(
      String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }


  @override
  Widget build(BuildContext context) {

    final pillars = {
      '年': widget.eightChars.year,
      '月': widget.eightChars.month,
      '日': widget.eightChars.day,
      '时': widget.eightChars.time,
    };
    final yunPillars = {
      '大运': JiaZi.JIA_ZI,
      '流年': widget.eightChars.year,
      '流月': widget.eightChars.month,
      '流日': widget.eightChars.day,
      '流时': widget.eightChars.time,
    };

    if (_showTaiYuan) {
      pillars['胎元'] = widget.taiYuan.taiYuanGanZhi;
    }
    if (_showKe && widget.keZhu != null) {
      pillars['刻'] = widget.keZhu!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EightCharsCard(
                title: '流运',
                pillars: yunPillars,
                showXunShou: _showXunShou,
                showNaYin: _showNaYin,
                showKongWang: _showKongWang,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: EightCharsCard(
                title: '本命',
                pillars: pillars,
                showXunShou: _showXunShou,
                showNaYin: _showNaYin,
                showKongWang: _showKongWang,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: [
              _buildOptionChip('胎元', _showTaiYuan,
                  (val) => setState(() => _showTaiYuan = val)),
              _buildOptionChip('旬首', _showXunShou,
                  (val) => setState(() => _showXunShou = val)),
              _buildOptionChip('纳音', _showNaYin,
                  (val) => setState(() => _showNaYin = val)),
              _buildOptionChip('空亡', _showKongWang,
                  (val) => setState(() => _showKongWang = val)),
              if (widget.keZhu != null)
                _buildOptionChip(
                    '刻', _showKe, (val) => setState(() => _showKe = val)),
            ],
          ),
        ),
      ],
    );
  }
}
