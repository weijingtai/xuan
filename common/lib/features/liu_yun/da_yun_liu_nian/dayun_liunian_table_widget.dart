import 'package:flutter/material.dart';

import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class DaYunLiuNianTableDemoWidget extends StatefulWidget {
  final double scale;
  final bool fitHeight;

  const DaYunLiuNianTableDemoWidget({
    super.key,
    this.scale = 0.82,
    this.fitHeight = true,
  });

  @override
  State<DaYunLiuNianTableDemoWidget> createState() =>
      _DaYunLiuNianTableDemoWidgetState();
}

class _DaYunLiuNianTableDemoWidgetState
    extends State<DaYunLiuNianTableDemoWidget> {
  int _yearsPerDaYun = 10;

  @override
  Widget build(BuildContext context) {
    final data = DaYunLiuNianTableViewData.demo(yearsPerDaYun: _yearsPerDaYun);

    return Stack(
      children: [
        Positioned.fill(
          child: DaYunLiuNianTableWidget(
            data: data,
            scale: widget.scale,
            fitHeight: widget.fitHeight,
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: _YearsPerDaYunToggle(
            selectedYears: _yearsPerDaYun,
            onChanged: (v) {
              setState(() {
                _yearsPerDaYun = v;
              });
            },
          ),
        ),
      ],
    );
  }
}

class DaYunLiuNianTinyTableDemoWidget extends StatefulWidget {
  final bool fitHeight;

  const DaYunLiuNianTinyTableDemoWidget({super.key, this.fitHeight = true});

  @override
  State<DaYunLiuNianTinyTableDemoWidget> createState() =>
      _DaYunLiuNianTinyTableDemoWidgetState();
}

class _DaYunLiuNianTinyTableDemoWidgetState
    extends State<DaYunLiuNianTinyTableDemoWidget> {
  int _yearsPerDaYun = 10;

  @override
  Widget build(BuildContext context) {
    final data = DaYunLiuNianTableViewData.demo(yearsPerDaYun: _yearsPerDaYun);

    return Stack(
      children: [
        Positioned.fill(
          child: DaYunLiuNianTinyTableWidget(
            data: data,
            fitHeight: widget.fitHeight,
          ),
        ),
        Positioned(
          left: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'TINY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: _YearsPerDaYunToggle(
            selectedYears: _yearsPerDaYun,
            onChanged: (v) {
              setState(() {
                _yearsPerDaYun = v;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _YearsPerDaYunToggle extends StatelessWidget {
  final int selectedYears;
  final ValueChanged<int> onChanged;

  const _YearsPerDaYunToggle({
    required this.selectedYears,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final is9 = selectedYears == 9;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ToggleButtons(
          isSelected: [is9, !is9],
          onPressed: (index) {
            onChanged(index == 0 ? 9 : 10);
          },
          borderRadius: BorderRadius.circular(10),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 52),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('9年'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('10年'),
            ),
          ],
        ),
      ),
    );
  }
}

class DaYunLiuNianTableWidget extends StatelessWidget {
  final DaYunLiuNianTableViewData data;
  final double scale;
  final bool fitHeight;
  final double outerPadding;
  final double cardPadding;

  const DaYunLiuNianTableWidget({
    super.key,
    required this.data,
    this.scale = 1.0,
    this.fitHeight = true,
    this.outerPadding = 20,
    this.cardPadding = 20,
  });

  DaYunLiuNianTableWidget.demo({
    super.key,
    this.scale = 0.82,
    this.fitHeight = true,
    this.outerPadding = 20,
    this.cardPadding = 20,
  }) : data = DaYunLiuNianTableViewData.demo();

  static const Color _paper = InkTheme.paperSoft;
  static const Color _paperAlt = InkTheme.paperAlt;
  static const Color _ink = InkTheme.inkDeep;
  static const Color _cinnabar = InkTheme.cinnabar;
  static const Color _gold = InkTheme.gold;

  static const double _gap = 8;
  static const double _sidebarW = 52;
  static const double _dayunW = 170;
  static const double _yearCellW = 155;
  static const double _yearCellH = 115;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowCount = data.rowSidebars.length;

        final outerPad = outerPadding;
        final cardPad = cardPadding;
        final availableMatrixH = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - outerPad * 2 - cardPad * 2).clamp(
                0.0,
                double.infinity,
              )
            : double.infinity;

        final baseMatrixH = _estimateMatrixHeight(rowCount: rowCount);
        final fitScale = availableMatrixH.isFinite && baseMatrixH > 0
            ? (availableMatrixH / baseMatrixH).clamp(0.2, 1.0)
            : 1.0;

        const fitSafety = 0.975;
        final safeFitScale = (fitScale * fitSafety).clamp(0.2, 1.0);

        final effectiveScale = fitHeight
            ? (scale < safeFitScale ? scale : safeFitScale)
            : scale;

        return ColoredBox(
          color: InkTheme.backgroundMuted,
          child: Padding(
            padding: EdgeInsets.all(outerPad),
            child: Container(
              padding: EdgeInsets.all(cardPad),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildMatrix(
                  layoutScale: effectiveScale,
                  textScale: effectiveScale < scale
                      ? (effectiveScale * 1.18).clamp(effectiveScale, scale)
                      : effectiveScale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _estimateMatrixHeight({required int rowCount}) {
    const headerApproxH = 194.0;
    return headerApproxH + _gap + rowCount * (_yearCellH + _gap);
  }

  Widget _buildMatrix({
    required double layoutScale,
    required double textScale,
  }) {
    final rowCount = data.rowSidebars.length;
    final gap = _gap * layoutScale;
    final sidebarW = _sidebarW * layoutScale;
    final dayunW = _dayunW * layoutScale;
    final columnCount = data.columns.length;
    final totalW =
        sidebarW + gap + (columnCount * dayunW) + ((columnCount - 1) * gap);

    return SizedBox(
      width: totalW,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                SizedBox(width: sidebarW + gap),
                for (var c = 0; c < columnCount; c++) ...[
                  Container(
                    width: dayunW,
                    color: c.isEven
                        ? Colors.transparent
                        : _gold.withOpacity(0.12),
                  ),
                  if (c != columnCount - 1) SizedBox(width: gap),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: sidebarW),
                  SizedBox(width: gap),
                  for (var c = 0; c < data.columns.length; c++) ...[
                    _DaYunHeaderCell(
                      data: data.columns[c].header,
                      layoutScale: layoutScale,
                      textScale: textScale,
                    ),
                    if (c != data.columns.length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
              SizedBox(height: gap),
              for (var r = 0; r < rowCount; r++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _IndexSidebar(
                      text: data.rowSidebars[r],
                      layoutScale: layoutScale,
                      textScale: textScale,
                    ),
                    SizedBox(width: gap),
                    for (var c = 0; c < data.columns.length; c++) ...[
                      SizedBox(
                        width: dayunW,
                        height:
                            DaYunLiuNianTableWidget._yearCellH * layoutScale,
                        child: Align(
                          alignment: Alignment.center,
                          child: _YearCell(
                            data: data.columns[c].years[r],
                            layoutScale: layoutScale,
                            textScale: textScale,
                          ),
                        ),
                      ),
                      if (c != data.columns.length - 1) SizedBox(width: gap),
                    ],
                  ],
                ),
                SizedBox(height: gap),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class DaYunLiuNianTinyTableWidget extends StatelessWidget {
  final DaYunLiuNianTableViewData data;
  final double scale;
  final bool fitHeight;

  const DaYunLiuNianTinyTableWidget({
    super.key,
    required this.data,
    this.scale = 0.52,
    this.fitHeight = true,
  });

  DaYunLiuNianTinyTableWidget.demo({
    super.key,
    this.scale = 0.52,
    this.fitHeight = true,
  }) : data = DaYunLiuNianTableViewData.demo();

  @override
  Widget build(BuildContext context) {
    return DaYunLiuNianTableWidget(
      data: data,
      scale: scale,
      fitHeight: fitHeight,
      outerPadding: 8,
      cardPadding: 8,
    );
  }
}

class DaYunLiuNianTableViewData {
  final List<DaYunColumnViewData> columns;
  final List<String> rowSidebars;

  const DaYunLiuNianTableViewData({
    required this.columns,
    required this.rowSidebars,
  });

  factory DaYunLiuNianTableViewData.demo({int yearsPerDaYun = 10}) {
    const daYunPillars = <String>[
      '甲辰',
      '乙巳',
      '丙午',
      '丁未',
      '戊申',
      '己酉',
      '庚戌',
      '辛亥',
      '壬子',
      '癸丑',
      '甲寅',
    ];

    const daYunIndexZh = <String>[
      '一',
      '二',
      '三',
      '四',
      '五',
      '六',
      '七',
      '八',
      '九',
      '十',
      '十一',
    ];

    const yearPillars = <String>[
      '甲子',
      '乙丑',
      '丙寅',
      '丁卯',
      '戊辰',
      '己巳',
      '庚午',
      '辛未',
      '壬申',
      '癸酉',
      '甲戌',
      '乙亥',
    ];

    const headerGods = <GodLineData>[
      GodLineData(mark: '干', label: '正财'),
      GodLineData(stem: '乙', label: '劫财'),
      GodLineData(stem: '癸', label: '正印'),
      GodLineData(stem: '戊', label: '偏财'),
    ];

    const startYear = 2024;
    const startAge = 28;

    const yearIndexZhUpper = <String>[
      '壹',
      '贰',
      '叁',
      '肆',
      '伍',
      '陆',
      '柒',
      '捌',
      '玖',
      '拾',
    ];

    final columns = <DaYunColumnViewData>[];
    for (var c = 0; c < daYunPillars.length; c++) {
      final colStartYear = startYear + c * yearsPerDaYun;
      final colEndYear = colStartYear + yearsPerDaYun - 1;
      final colStartAge = startAge + c * yearsPerDaYun;
      final colEndAge = colStartAge + yearsPerDaYun;

      final years = <YearCellViewData>[];
      for (var r = 0; r < yearsPerDaYun; r++) {
        final year = colStartYear + r;
        final age = colStartAge + r;
        final pillar =
            yearPillars[(c * yearsPerDaYun + r) % yearPillars.length];

        years.add(
          YearCellViewData(
            year: year,
            ageTagText: '${age}岁',
            pillarText: pillar,
            gods: _demoYearGods(c * 100 + r),
          ),
        );
      }

      columns.add(
        DaYunColumnViewData(
          header: DaYunHeaderViewData(
            bannerText: '大运·${daYunIndexZh[c]}',
            pillarText: daYunPillars[c],
            gods: headerGods,
            footerText:
                '${colStartYear}-${colEndYear}\n${colStartAge}-${colEndAge}岁',
          ),
          years: years,
        ),
      );
    }

    final rowSidebars = List<String>.generate(yearsPerDaYun, (i) {
      final idx = i < yearIndexZhUpper.length
          ? yearIndexZhUpper[i]
          : '${i + 1}';
      return '年·$idx';
    });

    return DaYunLiuNianTableViewData(
      columns: columns,
      rowSidebars: rowSidebars,
    );
  }

  static List<GodLineData> _demoYearGods(int seed) {
    const stems = <String>['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const labels = <String>[
      '比肩',
      '劫财',
      '食神',
      '伤官',
      '偏财',
      '正财',
      '七杀',
      '正官',
      '偏印',
      '正印',
    ];

    final mainLabel = labels[(seed + 2) % labels.length];
    final lineCount = 3 + (seed % 2);

    final lines = <GodLineData>[GodLineData(mark: '干', label: mainLabel)];
    for (var i = 0; i < lineCount - 1; i++) {
      lines.add(
        GodLineData(
          stem: stems[(seed + i) % stems.length],
          label: labels[(seed + i + 3) % labels.length],
        ),
      );
    }

    return lines;
  }
}

class DaYunColumnViewData {
  final DaYunHeaderViewData header;
  final List<YearCellViewData> years;

  const DaYunColumnViewData({required this.header, required this.years});
}

class DaYunHeaderViewData {
  final String bannerText;
  final String pillarText;
  final List<GodLineData> gods;
  final String footerText;

  const DaYunHeaderViewData({
    required this.bannerText,
    required this.pillarText,
    required this.gods,
    required this.footerText,
  });
}

class YearCellViewData {
  final int year;
  final String ageTagText;
  final String pillarText;
  final List<GodLineData> gods;

  const YearCellViewData({
    required this.year,
    required this.ageTagText,
    required this.pillarText,
    required this.gods,
  });
}

class GodLineData {
  final String label;
  final String? mark;
  final String? stem;

  const GodLineData({required this.label, this.mark, this.stem});
}

class _DaYunHeaderCell extends StatelessWidget {
  final DaYunHeaderViewData data;
  final double layoutScale;
  final double textScale;

  const _DaYunHeaderCell({
    required this.data,
    required this.layoutScale,
    required this.textScale,
  });

  static const Color _paper = DaYunLiuNianTableWidget._paper;
  static const Color _ink = DaYunLiuNianTableWidget._ink;
  static const Color _cinnabar = DaYunLiuNianTableWidget._cinnabar;
  static const Color _gold = DaYunLiuNianTableWidget._gold;

  @override
  Widget build(BuildContext context) {
    final dayunW = DaYunLiuNianTableWidget._dayunW * layoutScale;
    return SizedBox(
      width: dayunW,
      child: Container(
        decoration: BoxDecoration(
          color: _paper,
          borderRadius: BorderRadius.circular(10 * layoutScale),
          border: Border.all(color: _ink, width: 2 * layoutScale),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4 * layoutScale),
              decoration: BoxDecoration(
                color: _cinnabar,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8 * layoutScale),
                ),
              ),
              child: Text(
                data.bannerText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13 * textScale,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10 * layoutScale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: _VerticalText(
                        text: data.pillarText,
                        style: TextStyle(
                          fontSize: 28 * textScale,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          color: _ink,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * layoutScale),
                  SizedBox(
                    width: 1 * layoutScale,
                    height: 68 * layoutScale,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        axis: Axis.vertical,
                        color: _gold.withOpacity(0.9),
                        dashLength: 2 * layoutScale,
                        gapLength: 2 * layoutScale,
                        strokeWidth: 1 * layoutScale,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * layoutScale),
                  Expanded(
                    flex: 12,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.gods.isNotEmpty)
                            _GodLine(
                              data: data.gods.first,
                              layoutScale: layoutScale,
                              textScale: textScale,
                            ),
                          if (data.gods.length > 1) ...[
                            SizedBox(height: 4 * layoutScale),
                            Container(
                              height: 0.8 * layoutScale,
                              color: _gold.withOpacity(0.55),
                            ),
                            SizedBox(height: 4 * layoutScale),
                            for (final g in data.gods.sublist(1))
                              _GodLine(
                                data: g,
                                layoutScale: layoutScale,
                                textScale: textScale,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6 * layoutScale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8 * layoutScale),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final parts = data.footerText.split('\n');
                    final yearRange = parts.isNotEmpty ? parts.first : '';
                    final ageRange = parts.length > 1 ? parts[1] : '';
                    final ageOnly = ageRange.replaceAll(RegExp(r'\s'), '');
                    String ageNums = ageOnly;
                    String ageSuffix = '';
                    final ageSuffixMatch = RegExp(
                      r'^(.*?)(岁.*)$',
                    ).firstMatch(ageOnly);
                    if (ageSuffixMatch != null) {
                      ageNums = ageSuffixMatch.group(1) ?? ageOnly;
                      ageSuffix = ageSuffixMatch.group(2) ?? '';
                    }

                    final lineGap = 4 * layoutScale;

                    final yearPillTextStyle = TextStyle(
                      color: _gold,
                      fontSize: (12.5 * textScale) + 2,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    );

                    final ageColor = Colors.black.withOpacity(0.18);
                    final ageNumStyle = TextStyle(
                      color: ageColor,
                      fontSize: (13.5 * textScale) + 2,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    );
                    final ageUnitStyle = TextStyle(
                      color: Colors.black.withOpacity(0.14),
                      fontSize: 11.0 * textScale,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    );

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * layoutScale,
                            vertical: 1 * layoutScale,
                          ),
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              4 * layoutScale,
                            ),
                          ),
                          child: Text(
                            yearRange,
                            textAlign: TextAlign.center,
                            style: yearPillTextStyle,
                          ),
                        ),
                        SizedBox(height: lineGap),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: ageNums, style: ageNumStyle),
                              if (ageSuffix.isNotEmpty)
                                TextSpan(text: ageSuffix, style: ageUnitStyle),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexSidebar extends StatelessWidget {
  final String text;
  final double layoutScale;
  final double textScale;

  const _IndexSidebar({
    required this.text,
    required this.layoutScale,
    required this.textScale,
  });

  static const Color _paper = DaYunLiuNianTableWidget._paper;
  static const Color _ink = DaYunLiuNianTableWidget._ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DaYunLiuNianTableWidget._sidebarW * layoutScale,
      height: DaYunLiuNianTableWidget._yearCellH * layoutScale,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(6 * layoutScale),
        ),
        child: _VerticalText(
          text: text,
          style: TextStyle(
            color: _paper,
            fontSize: 14 * textScale,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _YearCell extends StatelessWidget {
  final YearCellViewData data;
  final double layoutScale;
  final double textScale;
  final Color paperColor;

  const _YearCell({
    required this.data,
    required this.layoutScale,
    required this.textScale,
    this.paperColor = _paper,
  });

  static const Color _paper = DaYunLiuNianTableWidget._paper;
  static const Color _ink = DaYunLiuNianTableWidget._ink;
  static const Color _gold = DaYunLiuNianTableWidget._gold;

  @override
  Widget build(BuildContext context) {
    final cellPaper = paperColor;
    final ageMatch = RegExp(r'(\d+)').firstMatch(data.ageTagText);
    final ageNum = ageMatch?.group(1) ?? data.ageTagText;
    return SizedBox(
      width: DaYunLiuNianTableWidget._yearCellW * layoutScale,
      height: DaYunLiuNianTableWidget._yearCellH * layoutScale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * layoutScale),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cellPaper,
            borderRadius: BorderRadius.circular(10 * layoutScale),
            border: Border.all(
              color: Colors.black.withOpacity(0.06),
              width: 1.5 * layoutScale,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      6 * layoutScale,
                      2 * layoutScale,
                      6 * layoutScale,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Text(
                          ageNum,
                          style: TextStyle(
                            fontSize: 140 * layoutScale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: Colors.black.withOpacity(0.08),
                            fontFamily: 'Arial',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 6 * layoutScale,
                bottom: 6 * layoutScale,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * layoutScale,
                    vertical: 1 * layoutScale,
                  ),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4 * layoutScale),
                  ),
                  child: Text(
                    '${data.year}',
                    style: TextStyle(
                      color: _gold,
                      fontSize: (12.5 * textScale) + 2,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  8 * layoutScale,
                  12 * layoutScale,
                  8 * layoutScale,
                  8 * layoutScale,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: Offset(0, -8 * layoutScale),
                              child: _VerticalText(
                                text: data.pillarText,
                                style: TextStyle(
                                  fontSize: 28 * textScale,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  color: _ink,
                                  letterSpacing: 2 * layoutScale,
                                  shadows: [
                                    Shadow(
                                      color: cellPaper,
                                      blurRadius: 10 * layoutScale,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 1 * layoutScale,
                      height: 74 * layoutScale,
                      child: CustomPaint(
                        painter: DashedLinePainter(
                          axis: Axis.vertical,
                          color: _gold.withOpacity(0.9),
                          dashLength: 2 * layoutScale,
                          gapLength: 2 * layoutScale,
                          strokeWidth: 1 * layoutScale,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10 * layoutScale),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.gods.isNotEmpty)
                                _GodLine(
                                  data: data.gods.first,
                                  layoutScale: layoutScale,
                                  textScale: textScale,
                                ),
                              if (data.gods.length > 1) ...[
                                SizedBox(height: 4 * layoutScale),
                                Container(
                                  height: 0.8 * layoutScale,
                                  color: _gold.withOpacity(0.55),
                                ),
                                SizedBox(height: 4 * layoutScale),
                                for (final g in data.gods.sublist(1))
                                  _GodLine(
                                    data: g,
                                    layoutScale: layoutScale,
                                    textScale: textScale,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GodLine extends StatelessWidget {
  final GodLineData data;
  final double layoutScale;
  final double textScale;

  const _GodLine({
    required this.data,
    required this.layoutScale,
    required this.textScale,
  });

  static const Color _ink = DaYunLiuNianTableWidget._ink;
  static const Color _cinnabar = DaYunLiuNianTableWidget._cinnabar;

  @override
  Widget build(BuildContext context) {
    final token = 16 * textScale;
    final tokenRadius = 4 * layoutScale;
    final valueFontSize = 13 * textScale;

    final leading = SizedBox(
      width: token,
      height: token,
      child: data.mark != null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: _cinnabar,
                borderRadius: BorderRadius.circular(tokenRadius),
              ),
              child: Center(
                child: Text(
                  data.mark!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                data.stem ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2 * layoutScale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          SizedBox(width: 6 * layoutScale),
          Text(
            data.label,
            style: TextStyle(
              color: _cinnabar,
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _VerticalText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final chars = text.characters.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }
}
