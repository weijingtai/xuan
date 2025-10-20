import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:common/widgets/card_row.dart';
import 'package:common/widgets/card_row_widget.dart';
import 'eight_chars_card.dart';

class GenericPillarCard extends StatefulWidget {
  final String? title;
  final List<PillarData> pillars;
  final TianGan dayMaster;
  final bool isBenMing;
  final Gender? gender;

  final bool showTenGods;
  final bool showCangGanMain;
  final bool showCangGanMainTenGods;
  final bool showCangGanZhong;
  final bool showCangGanZhongTenGods;
  final bool showCangGanYu;
  final bool showCangGanYuTenGods;
  final bool showXunShou;
  final bool showNaYin;
  final bool showKongWang;

  final bool isEditMode;
  final bool isColumnReorderMode;
  final void Function(int, int) onRowReorder;
  final void Function(int, int) onPillarReorder;

  const GenericPillarCard({
    Key? key,
    this.title,
    required this.pillars,
    required this.dayMaster,
    required this.isBenMing,
    this.gender,
    this.showTenGods = false,
    this.showCangGanMain = false,
    this.showCangGanMainTenGods = false,
    this.showCangGanZhong = false,
    this.showCangGanZhongTenGods = false,
    this.showCangGanYu = false,
    this.showCangGanYuTenGods = false,
    this.showXunShou = false,
    this.showNaYin = false,
    this.showKongWang = false,
    this.isEditMode = false,
    this.isColumnReorderMode = false,
    required this.onRowReorder,
    required this.onPillarReorder,
  }) : super(key: key);

  @override
  _GenericPillarCardState createState() => _GenericPillarCardState();
}

class _GenericPillarCardState extends State<GenericPillarCard> with SingleTickerProviderStateMixin {
  late List<String> _rowOrder;
  late List<String> _pillarOrder;

  @override
  void initState() {
    super.initState();
    _buildOrders();
  }

  @override
  void didUpdateWidget(covariant GenericPillarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const DeepCollectionEquality().equals(widget.pillars, oldWidget.pillars) ||
        widget.showTenGods != oldWidget.showTenGods ||
        widget.showCangGanMain != oldWidget.showCangGanMain ||
        widget.showCangGanMainTenGods != oldWidget.showCangGanMainTenGods ||
        widget.showCangGanZhong != oldWidget.showCangGanZhong ||
        widget.showCangGanZhongTenGods != oldWidget.showCangGanZhongTenGods ||
        widget.showCangGanYu != oldWidget.showCangGanYu ||
        widget.showCangGanYuTenGods != oldWidget.showCangGanYuTenGods ||
        widget.showXunShou != oldWidget.showXunShou ||
        widget.showNaYin != oldWidget.showNaYin ||
        widget.showKongWang != oldWidget.showKongWang) {
      _buildOrders();
    }
  }

  void _buildOrders() {
    _pillarOrder = widget.pillars.map((p) => p.label).toList();
    final newRowOrder = [CardRow.pillarHeader, CardRow.tianGan];
    if (widget.showTenGods) newRowOrder.add(CardRow.tenGods);
    newRowOrder.add(CardRow.diZhi);
    if (widget.showCangGanMain) newRowOrder.add(CardRow.cangGanMain);
    if (widget.showCangGanMainTenGods) newRowOrder.add(CardRow.cangGanMainTenGods);
    if (widget.showCangGanZhong) newRowOrder.add(CardRow.cangGanZhong);
    if (widget.showCangGanZhongTenGods) newRowOrder.add(CardRow.cangGanZhongTenGods);
    if (widget.showCangGanYu) newRowOrder.add(CardRow.cangGanYu);
    if (widget.showCangGanYuTenGods) newRowOrder.add(CardRow.cangGanYuTenGods);
    if (widget.showXunShou) newRowOrder.add(CardRow.xunShou);
    if (widget.showNaYin) newRowOrder.add(CardRow.naYin);
    if (widget.showKongWang) newRowOrder.add(CardRow.kongWang);
    _rowOrder = newRowOrder;
  }

  TextStyle get _tianGanTextStyle => GoogleFonts.zhiMangXing(fontWeight: FontWeight.w200, fontSize: 28, height: 1,);
  TextStyle get _diZhiTextStyle => GoogleFonts.longCang(fontSize: 28, height: 1, fontWeight: FontWeight.w500,);
  TextStyle get _labelTextStyle => GoogleFonts.zhiMangXing(fontSize: 14, height: 1.0,);

  // All build methods here, adapted

  @override
  Widget build(BuildContext context) {
    final pillarsMap = {for (var p in widget.pillars) p.label: p.jiaZi};

    Widget buildCardContent() {
      if (!widget.isEditMode) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _rowOrder.map((rowType) {
              return _buildRow(
                rowType: rowType,
                pillarOrder: _pillarOrder,
                pillars: pillarsMap,
              );
            }).toList(),
          ),
        );
      } else {
        if (widget.isColumnReorderMode) {
          // Horizontal Reorder for Pillars
          return SizedBox(
            height: 400, // Adjust height as needed
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pillarOrder.length,
              itemBuilder: (context, index) {
                final pillarLabel = _pillarOrder[index];
                return Card(
                  key: ValueKey(pillarLabel),
                  child: Center(child: Text(pillarLabel)),
                );
              },
              onReorder: widget.onPillarReorder,
            ),
          );
        } else {
          // Vertical Reorder for Rows
          return ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rowOrder.length,
            itemBuilder: (context, index) {
              final rowType = _rowOrder[index];
              return _buildRow(
                key: ValueKey(rowType),
                rowType: rowType,
                pillarOrder: _pillarOrder,
                pillars: pillarsMap,
              );
            },
            onReorder: widget.onRowReorder,
          );
        }
      }
    }

    return EightCharsCard(
      title: widget.title,
      child: buildCardContent(),
    );
  }

  Widget _buildRow({
    required String rowType,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    Key? key,
  }) {
    switch (rowType) {
      case CardRow.pillarHeader:
        return _buildPillarHeaderRow(
            key: key, pillarOrder: pillarOrder, pillars: pillars, isBenMing: widget.isBenMing, gender: widget.gender);
      case CardRow.tianGan:
        return _buildTianGanRow(key: key, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.tenGods:
        return _buildTenGodsRow(
            key: key,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: widget.dayMaster,
            isBenMing: widget.isBenMing);
      case CardRow.diZhi:
        return _buildDiZhiRow(key: key, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.cangGanMain:
        return _buildHiddenGanRow(
            key: key,
            label: '本气',
            cangGanIndex: 0,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanMainTenGods:
        return _buildHiddenGanTenGodsRow(
            key: key,
            label: '本气神',
            cangGanIndex: 0,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: widget.dayMaster);
      case CardRow.cangGanZhong:
        return _buildHiddenGanRow(
            key: key,
            label: '中气',
            cangGanIndex: 1,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanZhongTenGods:
        return _buildHiddenGanTenGodsRow(
            key: key,
            label: '中气神',
            cangGanIndex: 1,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: widget.dayMaster);
      case CardRow.cangGanYu:
        return _buildHiddenGanRow(
            key: key,
            label: '余气',
            cangGanIndex: 2,
            pillarOrder: pillarOrder,
            pillars: pillars);
      case CardRow.cangGanYuTenGods:
        return _buildHiddenGanTenGodsRow(
            key: key,
            label: '余气神',
            cangGanIndex: 2,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: widget.dayMaster);
      case CardRow.xunShou:
        return _buildInfoRow(
            key: key,
            label: '旬首',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) => jiazi.getXunHeader().ganZhiStr);
      case CardRow.naYin:
        return _buildInfoRow(
            key: key,
            label: '纳音',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) => jiazi.naYin.name);
      case CardRow.kongWang:
        return _buildInfoRow(
            key: key,
            label: '空亡',
            pillarOrder: pillarOrder,
            pillars: pillars,
            extractor: (jiazi) {
              final kongWang = jiazi.getKongWang();
              return '${kongWang.item1.value}${kongWang.item2.value}';
            });
      default:
        return SizedBox.shrink(key: key);
    }
  }

  Widget _buildInfoRow({
    Key? key,
    required String label,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required String Function(JiaZi) extractor,
  }) {
    return CardRowWidget(
      key: key,
      label: Text(label, style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        return Text(
          extractor(jiaZi),
          style: _labelTextStyle,
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildPillarHeaderRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required bool isBenMing,
    Gender? gender,
  }) {
    return CardRowWidget(
      key: key,
      label: Text(isBenMing ? (gender == Gender.male ? '乾造' : (gender == Gender.female ? '坤造' : '')) : '流运', style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        return Text(pillarLabel, style: _labelTextStyle, textAlign: TextAlign.center);
      }).toList(),
    );
  }

  Widget _buildTianGanRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    return CardRowWidget(
      key: key,
      label: Text('天干', style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        return Text(
          jiaZi.tianGan.value,
          style: _tianGanTextStyle.copyWith(color: AppColors.zodiacGanColors[jiaZi.tianGan]),
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildDiZhiRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    return CardRowWidget(
      key: key,
      label: Text('地支', style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        return Text(
          jiaZi.diZhi.value,
          style: _diZhiTextStyle.copyWith(color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildTenGodsRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
    required bool isBenMing,
  }) {
    return CardRowWidget(
      key: key,
      label: Text('十神', style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        String tenGodText;
        if (isBenMing && pillarLabel == '日') {
          tenGodText = '日元';
        } else {
          tenGodText = jiaZi.tianGan.getTenGods(dayMaster).name;
        }
        return Text(
          tenGodText,
          style: _labelTextStyle,
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildHiddenGanRow({
    Key? key,
    required String label,
    required int cangGanIndex,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    return CardRowWidget(
      key: key,
      label: Text(label, style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        final cangGanList = jiaZi.diZhi.cangGan;
        final text = cangGanList.length > cangGanIndex ? cangGanList[cangGanIndex].value : '';
        return Text(
          text,
          style: _tianGanTextStyle.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildHiddenGanTenGodsRow({
    Key? key,
    required String label,
    required int cangGanIndex,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
  }) {
    return CardRowWidget(
      key: key,
      label: Text(label, style: _labelTextStyle),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        final cangGanList = jiaZi.diZhi.cangGan;
        String text = '';
        if (cangGanList.length > cangGanIndex) {
          final hiddenStem = cangGanList[cangGanIndex];
          text = hiddenStem.getTenGods(dayMaster).name;
        }
        return Text(
          text,
          style: _labelTextStyle,
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }
}