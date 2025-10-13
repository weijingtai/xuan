import 'dart:async';

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_card.dart';
import 'package:common/widgets/eight_chars_card_builder.dart';
import 'package:common/widgets/card_row.dart';
import 'package:flutter/material.dart';

// This is the main stateful widget that controls everything.
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
  bool _showTaiYuan = false;
  bool _showXunShou = false;
  bool _showNaYin = false;
  bool _showKongWang = false;
  bool _showKe = false;
  bool _isEditMode = false;
  bool _isColumnReorderMode = false; // For the inner switch in edit mode

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

  // --- BUILD METHOD (The Conductor) ---
  @override
  Widget build(BuildContext context) {
    // --- 1. Data Preparation ---
    final allBenMingPillarData = {
      '年': widget.eightChars.year,
      '月': widget.eightChars.month,
      '日': widget.eightChars.day,
      '时': widget.eightChars.time,
      '胎元': widget.taiYuan.taiYuanGanZhi,
      if (widget.keZhu != null) '刻': widget.keZhu!,
    };

    final pillars = Map.fromEntries(
      _benMingPillarOrder
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

    final benMingRowOrderWithExtras = List<String>.from(_benMingRowOrder);
    
    final liuYunRowOrderWithExtras = List<String>.from(_liuYunRowOrder);

    // --- 2. Build Content based on Mode ---
    Widget buildCardContent(bool isBenMing) {
      final currentPillars = isBenMing ? pillars : yunPillars;
      final currentRowOrder = isBenMing ? benMingRowOrderWithExtras : liuYunRowOrderWithExtras;
      final currentPillarOrder = isBenMing ? _benMingPillarOrder : _liuYunPillarOrder;

      if (!_isEditMode) {
        // --- Normal Mode: Static Display ---
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currentRowOrder.map((rowType) {
            return EightCharsCardViewBuilder.buildRow(context, 
              rowType: rowType,
              rowOrder: currentRowOrder,
              pillarOrder: currentPillarOrder,
              pillars: currentPillars,
            );
          }).toList(),
        ),
        );
      } else {
        // --- Edit Mode: Reorderable UI ---
        if (!_isColumnReorderMode) {
          // Row Reordering UI
          return ReorderableListView(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final orderList = isBenMing ? _benMingRowOrder : _liuYunRowOrder;
                if (oldIndex < newIndex) newIndex -= 1;
                final item = orderList.removeAt(oldIndex);
                orderList.insert(newIndex, item);
                _saveRowOrder();
              });
            },
            children: currentRowOrder.map((rowType) {
              final index = currentRowOrder.indexOf(rowType);
              return Container(
                key: ValueKey('${isBenMing ? '本命' : '流运'}_$rowType'),
                child: Row(
                  children: [
                    Expanded(
                      child: EightCharsCardViewBuilder.buildRow(context, 
                        rowType: rowType,
                        rowOrder: currentRowOrder,
                        pillarOrder: currentPillarOrder,
                        pillars: currentPillars,
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const SizedBox(
                        width: 48,
                        child: Center(child: Icon(Icons.drag_indicator)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          // Column Reordering UI
          return SizedBox(
            height: 250, // Fixed height for horizontal list
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final orderList = isBenMing ? _benMingPillarOrder : _liuYunPillarOrder;
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = orderList.removeAt(oldIndex);
                  orderList.insert(newIndex, item);
                  _savePillarOrder();
                });
              },
              children: currentPillarOrder.map((pillarKey) {
                return Container(
                  key: ValueKey('${isBenMing ? '本命' : '流运'}_${pillarKey}_col'),
                  child: EightCharsCardViewBuilder.buildPillarColumn(context,
                    pillarKey: pillarKey,
                    rowOrder: currentRowOrder,
                    pillars: currentPillars,
                  ),
                );
              }).toList(),
            ),
          );
        }
      }
    }

    // --- 3. Main Widget Tree ---
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EightCharsCard(
                title: '流运',
                child: buildCardContent(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: EightCharsCard(
                title: '本命',
                child: buildCardContent(true),
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
                onPressed: () => setState(() => _isEditMode = !_isEditMode),
              ),
              if (_isEditMode)
                ActionChip(
                  avatar: Icon(_isColumnReorderMode ? Icons.view_column_outlined : Icons.view_headline_outlined),
                  label: Text(_isColumnReorderMode ? '列排序' : '行排序'),
                  onPressed: () => setState(() => _isColumnReorderMode = !_isColumnReorderMode),
                ),
              _buildOptionChip('胎元', _showTaiYuan, (val) {
                setState(() {
                  _showTaiYuan = val;
                  if (val) {
                    if(!_benMingPillarOrder.contains('胎元')) _benMingPillarOrder.add('胎元');
                  } else {
                    _benMingPillarOrder.remove('胎元');
                  }
                  _savePillarOrder();
                });
              }),
              _buildOptionChip('旬首', _showXunShou, (val) {
                setState(() {
                  _showXunShou = val;
                  if (val) {
                    if(!_benMingRowOrder.contains(CardRow.xunShou)) _benMingRowOrder.add(CardRow.xunShou);
                  } else {
                    _benMingRowOrder.remove(CardRow.xunShou);
                  }
                  _saveRowOrder();
                });
              }),
              _buildOptionChip('纳音', _showNaYin, (val) {
                setState(() {
                  _showNaYin = val;
                  if (val) {
                    if(!_benMingRowOrder.contains(CardRow.naYin)) _benMingRowOrder.add(CardRow.naYin);
                  } else {
                    _benMingRowOrder.remove(CardRow.naYin);
                  }
                  _saveRowOrder();
                });
              }),
              _buildOptionChip('空亡', _showKongWang, (val) {
                setState(() {
                  _showKongWang = val;
                  if (val) {
                    if(!_benMingRowOrder.contains(CardRow.kongWang)) _benMingRowOrder.add(CardRow.kongWang);
                  } else {
                    _benMingRowOrder.remove(CardRow.kongWang);
                  }
                  _saveRowOrder();
                });
              }),
              if (widget.keZhu != null)
                _buildOptionChip('刻', _showKe, (val) {
                  setState(() {
                    _showKe = val;
                    if (val) {
                      if(!_benMingPillarOrder.contains('刻')) _benMingPillarOrder.add('刻');
                    } else {
                      _benMingPillarOrder.remove('刻');
                    }
                    _savePillarOrder();
                  });
                }),
            ],
          ),
        ),
      ],
    );
  }
}
