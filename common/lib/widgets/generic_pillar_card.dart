import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:common/utils/constant_values_utils.dart';
import 'package:common/widgets/card_row.dart';
import 'package:common/widgets/card_row_widget.dart';
import 'eight_chars_card.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/enums/layout_template_enums.dart';

class GenericPillarCard extends StatefulWidget {
  final String? title;
  final List<PillarData> pillars;
  final TianGan dayMaster;
  final bool isBenMing;
  final Gender? gender;

  final bool showTenGods;
  final bool showTianGan;
  final bool showDiZhi;
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
  final Map<String, RowConfig>? rowStyles;

  const GenericPillarCard({
    Key? key,
    this.title,
    required this.pillars,
    required this.dayMaster,
    required this.isBenMing,
    this.gender,
    this.showTenGods = false,
    this.showTianGan = true,
    this.showDiZhi = true,
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
    this.rowStyles,
  }) : super(key: key);

  @override
  _GenericPillarCardState createState() => _GenericPillarCardState();
}

class _GenericPillarCardState extends State<GenericPillarCard>
    with SingleTickerProviderStateMixin {
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
    if (!const DeepCollectionEquality()
            .equals(widget.pillars, oldWidget.pillars) ||
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
    final newRowOrder = <String>[CardRow.pillarHeader];
    if (widget.showTianGan) newRowOrder.add(CardRow.tianGan);
    if (widget.showTenGods) newRowOrder.add(CardRow.tenGods);
    if (widget.showDiZhi) newRowOrder.add(CardRow.diZhi);
    if (widget.showCangGanMain) newRowOrder.add(CardRow.cangGanMain);
    if (widget.showCangGanMainTenGods)
      newRowOrder.add(CardRow.cangGanMainTenGods);
    if (widget.showCangGanZhong) newRowOrder.add(CardRow.cangGanZhong);
    if (widget.showCangGanZhongTenGods)
      newRowOrder.add(CardRow.cangGanZhongTenGods);
    if (widget.showCangGanYu) newRowOrder.add(CardRow.cangGanYu);
    if (widget.showCangGanYuTenGods) newRowOrder.add(CardRow.cangGanYuTenGods);
    if (widget.showXunShou) newRowOrder.add(CardRow.xunShou);
    if (widget.showNaYin) newRowOrder.add(CardRow.naYin);
    if (widget.showKongWang) newRowOrder.add(CardRow.kongWang);
    _rowOrder = newRowOrder;
  }

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

  // Row style resolver (basic mapping)
  TextStyle _resolveTextStyle(String rowType) {
    switch (rowType) {
      case CardRow.tianGan:
        return _tianGanTextStyle;
      case CardRow.diZhi:
        return _diZhiTextStyle;
      default:
        return _labelTextStyle;
    }
  }

  BoxBorder? _resolveBorder(String rowType) {
    final cfg = _cfg(rowType);
    if (cfg == null || cfg.borderType == null) return null;
    final color = _hexToColor(cfg.borderColorHex ?? '#22334155');
    switch (cfg.borderType!) {
      case BorderType.none:
        return Border.all(color: color.withValues(alpha: 0));
      case BorderType.solid:
        return Border.all(color: color);
      case BorderType.dashed:
      case BorderType.dotted:
        return Border.all(color: color.withValues(alpha: 0.6));
    }
  }

  EdgeInsets _resolvePadding(String rowType) {
    final cfg = _cfg(rowType);
    final double p = (cfg?.paddingVertical ?? 4).clamp(0, 24);
    return EdgeInsets.symmetric(vertical: p);
  }

  TextAlign _resolveAlign(String rowType) {
    final align = _cfg(rowType)?.textAlign;
    switch (align) {
      case RowTextAlign.center:
        return TextAlign.center;
      case RowTextAlign.right:
        return TextAlign.right;
      case RowTextAlign.left:
      default:
        return TextAlign.center;
    }
  }

  /// 根据指定行类型将 `RowConfig` 的样式覆盖应用到基础 `TextStyle`。
  ///
  /// 参数说明：
  /// - `rowType`：行类型键，用于查找对应的 `RowConfig`。
  /// - `base`：基础文本样式。
  ///
  /// 行为说明：
  /// - 优先从 `cfg.textStyleConfig` 中读取覆盖：`fontFamily`、`fontSize`、`color`、`fontWeight`；
  /// - 若 `textStyleConfig` 缺失，回退使用旧字段 `fontFamily`、`fontSize`、`textColorHex`；
  /// - 其他字段保持不变，确保兼容历史数据与现有 UI 渲染路径。
  TextStyle _applyOverrides(String rowType, TextStyle base) {
    final cfg = _cfg(rowType);
    if (cfg == null) return base;

    // 优先用 TextStyleConfig 转换出的样式做覆盖来源
    final fromCfg = cfg.textStyleConfig.toTextStyle();
    // final overrideFamily = fromCfg?.fontFamily ?? cfg.fontFamily;
    // final overrideSize = fromCfg?.fontSize ?? cfg.fontSize;
    // final overrideColor = fromCfg?.color ??
    //     (cfg.textColorHex != null && cfg.textColorHex!.isNotEmpty
    //         ? _hexToColor(cfg.textColorHex!)
    //         : null);
    // final overrideWeight = fromCfg?.fontWeight;

    // return base.copyWith(
    //   fontFamily: overrideFamily ?? base.fontFamily,
    //   fontSize: overrideSize ?? base.fontSize,
    //   color: overrideColor ?? base.color,
    //   fontWeight: overrideWeight ?? base.fontWeight,
    // );

    return base.copyWith(
      fontFamily: base.fontFamily,
      fontSize: base.fontSize,
      color: base.color,
      fontWeight: base.fontWeight,
    );
  }

  RowConfig? _cfg(String rowType) => widget.rowStyles?[rowType];

  Color _hexToColor(String hex) {
    final sanitized = hex.trim();
    final buffer = StringBuffer();
    if (sanitized.length == 6 || sanitized.length == 7) buffer.write('FF');
    buffer.write(sanitized.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF0F172A);
    }
  }

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
            key: key,
            pillarOrder: pillarOrder,
            pillars: pillars,
            isBenMing: widget.isBenMing,
            gender: widget.gender);
      case CardRow.tianGan:
        return _buildTianGanRow(
            key: key, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.tenGods:
        return _buildTenGodsRow(
            key: key,
            pillarOrder: pillarOrder,
            pillars: pillars,
            dayMaster: widget.dayMaster,
            isBenMing: widget.isBenMing,
            gender: widget.gender);
      case CardRow.diZhi:
        return _buildDiZhiRow(
            key: key, pillarOrder: pillarOrder, pillars: pillars);
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
      label: _buildLabel(rowType: CardRow.xunShou, defaultText: label),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        return Text(
          extractor(jiaZi),
          style: _applyOverrides(
              CardRow.xunShou, _resolveTextStyle(CardRow.xunShou)),
          textAlign: _resolveAlign(CardRow.xunShou),
        );
      }).toList(),
      padding: _resolvePadding(CardRow.xunShou),
      border: _resolveBorder(CardRow.xunShou),
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
      label: _buildLabel(
          rowType: CardRow.pillarHeader,
          defaultText: isBenMing
              ? FourZhuText.zaoLabelOrEmptyForGender(gender ?? Gender.unknown)
              : '流运'),
      cells: pillarOrder.map((pillarLabel) {
        return Text(pillarLabel,
            style: _applyOverrides(
                CardRow.pillarHeader, _resolveTextStyle(CardRow.pillarHeader)),
            textAlign: _resolveAlign(CardRow.pillarHeader));
      }).toList(),
      padding: _resolvePadding(CardRow.pillarHeader),
      border: _resolveBorder(CardRow.pillarHeader),
    );
  }

  Widget _buildTianGanRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    return CardRowWidget(
      key: key,
      label: _buildLabel(rowType: CardRow.tianGan, defaultText: '天干'),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        var style = _applyOverrides(
            CardRow.tianGan, _resolveTextStyle(CardRow.tianGan));
        // 如果未自定义颜色，保持按五行色彩
        // if (widget.rowStyles?[CardRow.tianGan]?.textColorHex == null) {
        //   style =
        //       style.copyWith(color: AppColors.zodiacGanColors[jiaZi.tianGan]);
        // }
        return Text(jiaZi.tianGan.value,
            style: style, textAlign: _resolveAlign(CardRow.tianGan));
      }).toList(),
      padding: _resolvePadding(CardRow.tianGan),
      border: _resolveBorder(CardRow.tianGan),
    );
  }

  Widget _buildDiZhiRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    return CardRowWidget(
      key: key,
      label: _buildLabel(rowType: CardRow.diZhi, defaultText: '地支'),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        var style =
            _applyOverrides(CardRow.diZhi, _resolveTextStyle(CardRow.diZhi));
        // if (widget.rowStyles?[CardRow.diZhi]?.textStyleConfig?. == null) {
        //   style = style.copyWith(color: AppColors.zodiacZhiColors[jiaZi.diZhi]);
        // }
        return Text(jiaZi.diZhi.value,
            style: style, textAlign: _resolveAlign(CardRow.diZhi));
      }).toList(),
      padding: _resolvePadding(CardRow.diZhi),
      border: _resolveBorder(CardRow.diZhi),
    );
  }

  Widget _buildTenGodsRow({
    Key? key,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required TianGan dayMaster,
    required bool isBenMing,
    Gender? gender,
  }) {
    return CardRowWidget(
      key: key,
      label: _buildLabel(rowType: CardRow.tenGods, defaultText: '十神'),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        String tenGodText;
        if (isBenMing && pillarLabel == '日') {
          tenGodText =
              FourZhuText.zaoLabelForGender(gender ?? Gender.unknown);
        } else {
          tenGodText = jiaZi.tianGan.getTenGods(dayMaster).name;
        }
        return Text(tenGodText,
            style: _applyOverrides(
                CardRow.tenGods, _resolveTextStyle(CardRow.tenGods)),
            textAlign: _resolveAlign(CardRow.tenGods));
      }).toList(),
      padding: _resolvePadding(CardRow.tenGods),
      border: _resolveBorder(CardRow.tenGods),
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
      label: _buildLabel(
          rowType: rowTypeFromIndex(cangGanIndex), defaultText: label),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        final cangGanList = jiaZi.diZhi.cangGan;
        final text = cangGanList.length > cangGanIndex
            ? cangGanList[cangGanIndex].value
            : '';
        return Text(text,
            style: _applyOverrides(
                rowTypeFromIndex(cangGanIndex),
                _resolveTextStyle(rowTypeFromIndex(cangGanIndex))
                    .copyWith(fontSize: 18)),
            textAlign: _resolveAlign(rowTypeFromIndex(cangGanIndex)));
      }).toList(),
      padding: _resolvePadding(rowTypeFromIndex(cangGanIndex)),
      border: _resolveBorder(rowTypeFromIndex(cangGanIndex)),
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
      label: _buildLabel(
          rowType: rowTypeFromIndex(cangGanIndex), defaultText: label),
      cells: pillarOrder.map((pillarLabel) {
        final jiaZi = pillars[pillarLabel];
        if (jiaZi == null) return const SizedBox.shrink();
        final cangGanList = jiaZi.diZhi.cangGan;
        String text = '';
        if (cangGanList.length > cangGanIndex) {
          final hiddenStem = cangGanList[cangGanIndex];
          text = hiddenStem.getTenGods(dayMaster).name;
        }
        return Text(text,
            style: _applyOverrides(rowTypeFromIndex(cangGanIndex),
                _resolveTextStyle(rowTypeFromIndex(cangGanIndex))),
            textAlign: _resolveAlign(rowTypeFromIndex(cangGanIndex)));
      }).toList(),
      padding: _resolvePadding(rowTypeFromIndex(cangGanIndex)),
      border: _resolveBorder(rowTypeFromIndex(cangGanIndex)),
    );
  }

  String rowTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return CardRow.cangGanMain;
      case 1:
        return CardRow.cangGanZhong;
      case 2:
        return CardRow.cangGanYu;
      default:
        return CardRow.cangGanMain;
    }
  }

  Widget _buildLabel({required String rowType, required String defaultText}) {
    final show = widget.rowStyles?[rowType]?.isTitleVisible ?? true;
    if (!show) return const SizedBox(width: 40);
    return Text(defaultText, style: _labelTextStyle);
  }
}
