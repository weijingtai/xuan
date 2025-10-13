import 'dart:async';

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_card_v3.dart';
import 'package:flutter/material.dart';

import 'card_row.dart';

class EightCharsCardV3 extends StatefulWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final JiaZi? keZhu;

  const EightCharsCardV3({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
  }) : super(key: key);

  @override
  _EightCharsCardV3State createState() => _EightCharsCardV3State();
}

class _EightCharsCardV3State extends State<EightCharsCardV3> {
  // --- STATE VARIABLES ---
  // Option state
  bool _showTaiYuan = false;
  bool _showXunShou = false;
  bool _showNaYin = false;
  bool _showKongWang = false;
  bool _showKe = false;
  bool _isEditMode = false;

  // Order state
  late List<String> _benMingRowOrder;
  late List<String> _liuYunRowOrder;
  late List<String> _benMingPillarOrder;
  late List<String> _liuYunPillarOrder;

  // --- LIFECYCLE ---
  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  // --- PERSISTENCE INTERFACES ---
  Future<void> _saveRowOrder() async {
    print("Saving benMing row order: $_benMingRowOrder");
    print("Saving liuYun row order: $_liuYunRowOrder");
  }

  Future<void> _savePillarOrder() async {
    print("Saving benMing pillar order: $_benMingPillarOrder");
    print("Saving liuYun pillar order: $_liuYunPillarOrder");
  }

  void _loadOrder() {
    print("Loading order...");
    _benMingRowOrder = [ CardRow.pillarHeader, CardRow.tianGan, CardRow.diZhi ];
    _liuYunRowOrder = [ CardRow.pillarHeader, CardRow.tianGan, CardRow.diZhi ];
    _benMingPillarOrder = ['年', '月', '日', '时'];
    _liuYunPillarOrder = ['大运', '流年', '流月', '流日', '流时'];
  }

  // --- UI HELPERS ---
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

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // --- Data Preparation ---
    final List<String> benMingPillarOrderWithExtras = List.from(_benMingPillarOrder);
    if (_showTaiYuan) benMingPillarOrderWithExtras.add('胎元');
    if (_showKe && widget.keZhu != null) benMingPillarOrderWithExtras.add('刻');

    final allBenMingPillarData = {
      '年': widget.eightChars.year,
      '月': widget.eightChars.month,
      '日': widget.eightChars.day,
      '时': widget.eightChars.time,
      '胎元': widget.taiYuan.taiYuanGanZhi,
      if (widget.keZhu != null) '刻': widget.keZhu!,
    };

    final pillars = Map.fromEntries(
      benMingPillarOrderWithExtras
          .where((key) => allBenMingPillarData.containsKey(key))
          .map((key) => MapEntry(key, allBenMingPillarData[key]!)),
    );

    final allYunPillars = {
      '大运': JiaZi.JIA_ZI, // Placeholder
      '流年': widget.eightChars.year, // Placeholder
      '流月': widget.eightChars.month, // Placeholder
      '流日': widget.eightChars.day, // Placeholder
      '流时': widget.eightChars.time, // Placeholder
    };
    final yunPillars = Map.fromEntries(
      _liuYunPillarOrder
          .where((key) => allYunPillars.containsKey(key))
          .map((key) => MapEntry(key, allYunPillars[key]!)),
    );

    final benMingRowOrderWithExtras = List.from(_benMingRowOrder);
    if (_showXunShou) benMingRowOrderWithExtras.add(CardRow.xunShou);
    if (_showNaYin) benMingRowOrderWithExtras.add(CardRow.naYin);
    if (_showKongWang) benMingRowOrderWithExtras.add(CardRow.kongWang);
    
    final liuYunRowOrderWithExtras = List.from(_liuYunRowOrder);

    // --- Widget Build ---
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   child: EightCharsCardV3(
            //     isEditMode: _isEditMode,
            //     title: '流运',
            //     pillars: yunPillars,
            //     rowOrder: liuYunRowOrderWithExtras,
            //     pillarOrder: _liuYunPillarOrder,
            //     onRowReorder: (oldIndex, newIndex) {
            //       setState(() {
            //         if (oldIndex < newIndex) newIndex -= 1;
            //         final item = _liuYunRowOrder.removeAt(oldIndex);
            //         _liuYunRowOrder.insert(newIndex, item);
            //         _saveRowOrder();
            //       });
            //     },
            //     onPillarReorder: (oldIndex, newIndex) {
            //        setState(() {
            //         if (oldIndex < newIndex) newIndex -= 1;
            //         final item = _liuYunPillarOrder.removeAt(oldIndex);
            //         _liuYunPillarOrder.insert(newIndex, item);
            //         _savePillarOrder();
            //       });
            //     },
            //   ),
            // ),
            // const SizedBox(width: 16),
            Expanded(
              child: EightCharsCardV3(
                eightChars: widget.eightChars,
                  taiYuan: widget.taiYuan,
                keZhu: widget.keZhu!

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
              ActionChip(
                avatar: Icon(_isEditMode ? Icons.done : Icons.edit_outlined),
                label: Text(_isEditMode ? '完成' : '调整顺序'),
                onPressed: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
              ),
              _buildOptionChip('胎元', _showTaiYuan, (val) => setState(() => _showTaiYuan = val)),
              _buildOptionChip('旬首', _showXunShou, (val) => setState(() => _showXunShou = val)),
              _buildOptionChip('纳音', _showNaYin, (val) => setState(() => _showNaYin = val)),
              _buildOptionChip('空亡', _showKongWang, (val) => setState(() => _showKongWang = val)),
              if (widget.keZhu != null)
                _buildOptionChip('刻', _showKe, (val) => setState(() => _showKe = val)),
            ],
          ),
        ),
      ],
    );
  }
}