import 'dart:async';

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:common/widgets/card_row.dart';
import 'package:common/widgets/eight_chars_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/enum_tian_gan.dart';

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

class _EightCharsCardV3State extends State<EightCharsCardV3> with SingleTickerProviderStateMixin {
  static const Map<String, String> _rowPredecessors = {
    CardRow.tenGods: CardRow.tianGan,
    CardRow.cangGanMain: CardRow.diZhi,
    CardRow.cangGanMainTenGods: CardRow.cangGanMain,
    CardRow.cangGanZhong: CardRow.cangGanMainTenGods,
    CardRow.cangGanZhongTenGods: CardRow.cangGanZhong,
    CardRow.cangGanYu: CardRow.cangGanZhongTenGods,
    CardRow.cangGanYuTenGods: CardRow.cangGanYu,
    CardRow.xunShou: CardRow.cangGanYuTenGods, // Fallback chain
    CardRow.naYin: CardRow.xunShou,
    CardRow.kongWang: CardRow.naYin,
  };

  // --- STATE VARIABLES ---
  bool _showTaiYuan = false;
  bool _showXunShou = false;
  bool _showNaYin = false;
  bool _showKongWang = false;
  bool _showTenGods = false;
  bool _showCangGanMain = false;
  bool _showCangGanMainTenGods = false;
  bool _showCangGanZhong = false;
  bool _showCangGanZhongTenGods = false;
  bool _showCangGanYu = false;
  bool _showCangGanYuTenGods = false;
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

  void _updateRowOrder(String row, bool shouldShow) {
    final listsToUpdate = [_benMingRowOrder, _liuYunRowOrder];
    for (var orderList in listsToUpdate) {
      if (shouldShow) {
        if (!orderList.contains(row)) {
          // Find predecessor and insert
          String? predecessor = _rowPredecessors[row];
          int insertIndex = -1;
          while (predecessor != null) {
            insertIndex = orderList.indexOf(predecessor);
            if (insertIndex != -1) break;
            predecessor = _rowPredecessors[predecessor];
          }
          orderList.insert(insertIndex + 1, row);
        }
      } else {
        orderList.remove(row);
      }
    }
    _saveRowOrder();
  }

  void _loadOrder() {
    print("Loading order...");
    _benMingRowOrder = [CardRow.pillarHeader, CardRow.tianGan, CardRow.diZhi];
    _liuYunRowOrder = [CardRow.pillarHeader, CardRow.tianGan, CardRow.diZhi];
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

  // --- CARD BUILDER LOGIC (inlined) ---

  TextStyle get _tianGanTextStyle => GoogleFonts.zhiMangXing(
        fontWeight: FontWeight.w200,
        fontSize: 28,
        height: 1,
      );

  TextStyle get _diZhiTextStyle => GoogleFonts.longCang(
        fontSize: 28,
        height: 1,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _labelTextStyle => GoogleFonts.zhiMangXing(
        fontSize: 14,
        height: 1.0,
      );

  Widget _buildPillarHeaderRow({
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('四柱',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 22,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillarOrder.isNotEmpty)
                  ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children: pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  String pillarKey = pillarOrder[index];

                  Widget child = Text(pillarKey,
                        style: _labelTextStyle.copyWith(
                            color: labelColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center);

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: child,
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTianGanRow({
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('天干',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillarOrder.isNotEmpty)
                  ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children: pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  String pillarKey = pillarOrder[index];

                  JiaZi jiaZi = pillars[pillarKey]!;
                  Widget child = Text(
                      jiaZi.tianGan.value,
                      style: _tianGanTextStyle.copyWith(
                          color: AppColors.zodiacGanColors[jiaZi.tianGan]),
                      textAlign: TextAlign.center,
                    );

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: child,
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDiZhiRow({
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('地支',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillarOrder.isNotEmpty)
                  ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children: pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  String pillarKey = pillarOrder[index];

                  JiaZi jiaZi = pillars[pillarKey]!;
                  Widget child = Text(
                      jiaZi.diZhi.value,
                      style: _diZhiTextStyle.copyWith(
                          color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
                      textAlign: TextAlign.center,
                    );

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: child,
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required String Function(JiaZi) extractor,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillarOrder.isNotEmpty)
                    ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillarOrder.asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    String pillarKey = pillarOrder[index];

                    JiaZi jiaZi = pillars[pillarKey]!;
                    Widget child = Text(
                        extractor(jiaZi),
                        style: _labelTextStyle.copyWith(color: labelColor),
                        textAlign: TextAlign.center,
                      );
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: child,
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPillarColumn({
    required String pillarKey,
    required List<String> rowOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    final jiaZi = pillars[pillarKey]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      width: 60, // Fixed width for a column
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Text(pillarKey,
              style: _labelTextStyle.copyWith(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          // Tian Gan
          Text(
            jiaZi.tianGan.value,
            style: _tianGanTextStyle.copyWith(
                color: AppColors.zodiacGanColors[jiaZi.tianGan]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Di Zhi
          Text(
            jiaZi.diZhi.value,
            style: _diZhiTextStyle.copyWith(
                color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
            textAlign: TextAlign.center,
          ),
          const Divider(),
          if (rowOrder.contains(CardRow.xunShou))
            Text(jiaZi.getXunHeader().ganZhiStr,
                style: _labelTextStyle.copyWith(color: labelColor)),
          if (rowOrder.contains(CardRow.naYin))
            Text(jiaZi.naYin.name,
                style: _labelTextStyle.copyWith(color: labelColor)),
          if (rowOrder.contains(CardRow.kongWang))
            Text(
                '${jiaZi.getKongWang().item1.value}${jiaZi.getKongWang().item2.value}',
                style: _labelTextStyle.copyWith(color: labelColor)),
        ],
      ),
    );
  }

  Widget _buildTenGodsRow({
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
    required bool isBenMing,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text("十神",
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillarOrder.isNotEmpty)
                    ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillarOrder.asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    String pillarKey = pillarOrder[index];

                    String tenGodText;
                    if (isBenMing && pillarKey == '日') {
                        tenGodText = '日元';
                    } else {
                        JiaZi jiaZi = pillars[pillarKey]!;
                        tenGodText = jiaZi.tianGan.getTenGods(dayMaster).name;
                    }
                    Widget child = Text(
                        tenGodText,
                        style: _labelTextStyle.copyWith(color: labelColor),
                        textAlign: TextAlign.center,
                      );
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: child,
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenGanRow({
    required String label,
    required int cangGanIndex,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillarOrder.isNotEmpty)
                    ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillarOrder.asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    String pillarKey = pillarOrder[index];

                    JiaZi jiaZi = pillars[pillarKey]!;
                    final cangGanList = jiaZi.diZhi.cangGan;
                    final text = cangGanList.length > cangGanIndex
                        ? cangGanList[cangGanIndex].value
                        : '';
                    Widget child = Text(
                        text,
                        style: _tianGanTextStyle.copyWith(
                            color: labelColor, fontSize: 18),
                        textAlign: TextAlign.center,
                      );
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: child,
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenGanTenGodsRow({
    required String label,
    required int cangGanIndex,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillarOrder.isNotEmpty)
                    ? (constraints.maxWidth / pillarOrder.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillarOrder.asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    String pillarKey = pillarOrder[index];

                    JiaZi jiaZi = pillars[pillarKey]!;
                    final cangGanList = jiaZi.diZhi.cangGan;
                    String text = '';
                    if (cangGanList.length > cangGanIndex) {
                        final hiddenStem = cangGanList[cangGanIndex];
                        text = hiddenStem.getTenGods(dayMaster).name;
                    }
                    Widget child = Text(
                        text,
                        style: _labelTextStyle.copyWith(color: labelColor),
                        textAlign: TextAlign.center,
                      );
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: child,
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String rowType,
    required List<String> rowOrder,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
    required bool isBenMing,
  }) {
    switch (rowType) {
      case CardRow.pillarHeader:
        return _buildPillarHeaderRow(
            pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.tianGan:
        return _buildTianGanRow(pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.tenGods:
        return _buildTenGodsRow(
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: dayMaster,
            isBenMing: isBenMing);
      case CardRow.diZhi:
        return _buildDiZhiRow(pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.cangGanMain:
        return _buildHiddenGanRow(
            label: '本气',
            cangGanIndex: 0,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanMainTenGods:
        return _buildHiddenGanTenGodsRow(
            label: '本气神',
            cangGanIndex: 0,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: dayMaster);
      case CardRow.cangGanZhong:
        return _buildHiddenGanRow(
            label: '中气',
            cangGanIndex: 1,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanZhongTenGods:
        return _buildHiddenGanTenGodsRow(
            label: '中气神',
            cangGanIndex: 1,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: dayMaster);
      case CardRow.cangGanYu:
        return _buildHiddenGanRow(
            label: '余气',
            cangGanIndex: 2,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanYuTenGods:
        return _buildHiddenGanTenGodsRow(
            label: '余气神',
            cangGanIndex: 2,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: dayMaster);
      case CardRow.xunShou:
        return _buildInfoRow(
            label: '旬首',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) => jiazi.getXunHeader().ganZhiStr);
      case CardRow.naYin:
        return _buildInfoRow(
            label: '纳音',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) => jiazi.naYin.name);
      case CardRow.kongWang:
        return _buildInfoRow(
            label: '空亡',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) {
              final kongWang = jiazi.getKongWang();
              return '${kongWang.item1.value}${kongWang.item2.value}';
            });
      default:
        return const SizedBox.shrink();
    }
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

    // --- 2. Build Content based on Mode ---
    Widget buildCardContent(bool isBenMing) {
      if (!_isEditMode) {
        // --- Normal Mode: Static Display ---
        final currentPillars = isBenMing ? pillars : yunPillars;
        final currentRowOrder = isBenMing ? _benMingRowOrder : _liuYunRowOrder;
        final currentPillarOrder = isBenMing ? _benMingPillarOrder : _liuYunPillarOrder;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currentRowOrder.map((rowType) {
              return _buildRow(
                rowType: rowType,
                rowOrder: currentRowOrder,
                pillarOrder: currentPillarOrder,
                pillars: currentPillars,
                dayMaster: widget.eightChars.dayTianGan,
                isBenMing: isBenMing,
              );
            }).toList(),
          ),
        );
      } else {
        // --- Edit Mode: Reorderable UI with Integrated Icons ---
        final basePillars = isBenMing ? pillars : yunPillars;
        final baseRowOrder = isBenMing ? _benMingRowOrder : _liuYunRowOrder;
        final basePillarOrder = isBenMing ? _benMingPillarOrder : _liuYunPillarOrder;

        final pillarOrderForRender = List<String>.from(basePillarOrder);
        final rowOrderForRender = List<String>.from(baseRowOrder);
        final pillarsForRender = Map<String, JiaZi>.from(basePillars);

        if (!_isColumnReorderMode) {
          // Row Reordering UI
          return ReorderableListView(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              // Prevent reordering the icon row
              if (oldIndex >= baseRowOrder.length || newIndex >= rowOrderForRender.length) return;
              // Adjust index if dropping after the original items
              if (newIndex > baseRowOrder.length) {
                newIndex = baseRowOrder.length;
              }

              setState(() {
                final orderList = isBenMing ? _benMingRowOrder : _liuYunRowOrder;
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = orderList.removeAt(oldIndex);
                orderList.insert(newIndex, item);
                _saveRowOrder();
              });
            },
            children: rowOrderForRender.map((rowType) {
              final index = rowOrderForRender.indexOf(rowType);
              return Container(
                key: ValueKey('${isBenMing ? '本命' : '流运'}_$rowType'),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRow(
                        rowType: rowType,
                        rowOrder: rowOrderForRender,
                        pillarOrder: pillarOrderForRender,
                        pillars: pillarsForRender,
                        dayMaster: widget.eightChars.dayTianGan,
                        isBenMing: isBenMing,
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const SizedBox(
                        width: 48,
                        child: Center(
                          child: Icon(Icons.drag_indicator),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          // Column Reordering UI
          return SizedBox(
            height: 250,
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                // Prevent reordering the icon column
                if (oldIndex >= basePillarOrder.length || newIndex >= pillarOrderForRender.length) return;
                if (newIndex > basePillarOrder.length) {
                  newIndex = basePillarOrder.length;
                }

                setState(() {
                  final orderList = isBenMing ? _benMingPillarOrder : _liuYunPillarOrder;
                   if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = orderList.removeAt(oldIndex);
                  orderList.insert(newIndex, item);
                  _savePillarOrder();
                });
              },
              children: pillarOrderForRender.map((pillarKey) {
                final index = pillarOrderForRender.indexOf(pillarKey);
                return Column(
                  key: ValueKey('${isBenMing ? '本命' : '流运'}_${pillarKey}_col'),
                  children: [
                    Expanded(
                      child: _buildPillarColumn(
                        pillarKey: pillarKey,
                        rowOrder: rowOrderForRender,
                        pillars: pillarsForRender,
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const SizedBox(
                        height: 48,
                        child: Center(
                          child: Icon(Icons.drag_indicator),
                        ),
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          );
        }
      }
    }

    // --- 3. Main Widget Tree ---
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 616; // Breakpoint for 2 cards + spacing
            final cardWidth = isMobile ? constraints.maxWidth : 300.0;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: EightCharsCard(
                    child: buildCardContent(false),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: EightCharsCard(
                    child: buildCardContent(true),
                  ),
                ),
              ],
            );
          }),
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
                  avatar: Icon(_isColumnReorderMode
                      ? Icons.view_column_outlined
                      : Icons.view_headline_outlined),
                  label: Text(_isColumnReorderMode ? '列排序' : '行排序'),
                  onPressed: () =>
                      setState(() => _isColumnReorderMode = !_isColumnReorderMode),
                ),
              _buildOptionChip('胎元', _showTaiYuan, (val) {
                setState(() {
                  _showTaiYuan = val;
                  if (val) {
                    if (!_benMingPillarOrder.contains('胎元')) {
                      _benMingPillarOrder.add('胎元');
                    }
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
                    if (!_benMingRowOrder.contains(CardRow.xunShou)) {
                      _benMingRowOrder.add(CardRow.xunShou);
                    }
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
                    if (!_benMingRowOrder.contains(CardRow.naYin)) {
                      _benMingRowOrder.add(CardRow.naYin);
                    }
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
                    if (!_benMingRowOrder.contains(CardRow.kongWang)) {
                      _benMingRowOrder.add(CardRow.kongWang);
                    }
                  } else {
                    _benMingRowOrder.remove(CardRow.kongWang);
                  }
                  _saveRowOrder();
                });
              }),
              _buildOptionChip('十神', _showTenGods, (val) {
                setState(() {
                  _showTenGods = val;
                  final listsToUpdate = [_benMingRowOrder, _liuYunRowOrder];
                  for (var orderList in listsToUpdate) {
                    if (val) {
                      final index = orderList.indexOf(CardRow.tianGan);
                      if (index != -1 && !orderList.contains(CardRow.tenGods)) {
                        orderList.insert(index + 1, CardRow.tenGods);
                      }
                    } else {
                      orderList.remove(CardRow.tenGods);
                    }
                  }
                  _saveRowOrder();
                });
              }),
              _buildOptionChip('本气', _showCangGanMain, (val) {
                setState(() {
                  _showCangGanMain = val;
                  _updateRowOrder(CardRow.cangGanMain, val);
                });
              }),
              _buildOptionChip('本气神', _showCangGanMainTenGods, (val) {
                setState(() {
                  _showCangGanMainTenGods = val;
                  _updateRowOrder(CardRow.cangGanMainTenGods, val);
                });
              }),
              _buildOptionChip('中气', _showCangGanZhong, (val) {
                setState(() {
                  _showCangGanZhong = val;
                  _updateRowOrder(CardRow.cangGanZhong, val);
                });
              }),
              _buildOptionChip('中气神', _showCangGanZhongTenGods, (val) {
                setState(() {
                  _showCangGanZhongTenGods = val;
                  _updateRowOrder(CardRow.cangGanZhongTenGods, val);
                });
              }),
              _buildOptionChip('余气', _showCangGanYu, (val) {
                setState(() {
                  _showCangGanYu = val;
                  _updateRowOrder(CardRow.cangGanYu, val);
                });
              }),
              _buildOptionChip('余气神', _showCangGanYuTenGods, (val) {
                setState(() {
                  _showCangGanYuTenGods = val;
                  _updateRowOrder(CardRow.cangGanYuTenGods, val);
                });
              }),
              if (widget.keZhu != null)
                _buildOptionChip('刻', _showKe, (val) {
                  setState(() {
                    _showKe = val;
                    if (val) {
                      if (!_benMingPillarOrder.contains('刻')) {
                        _benMingPillarOrder.add('刻');
                      }
                    } else {
                      _benMingPillarOrder.remove('刻');
                    }
                    _savePillarOrder();
                  });
                }),
            ],
          ),
        ),
      ]),
    );
  }
}