import 'package:common/enums.dart';
import 'package:common/enums/enum_chinese_12_zodic.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'yun_liu_table_month_widget.dart';
import 'yun_liu_table_year_header_cell_widget.dart';
import 'yun_liu_table_common.dart';

class _InkTheme {
  static const paper = Color(0xFFF7F2E8);
  static const paperHi = Color(0xFFFFFBF2);
  static const ink = Color(0xFF2D2D2D);
  static const seal = Color(0xFFB23A2B);
  static const gold = Color(0xFFAA9460);

  static Color line([int a = 70]) => ink.withAlpha(a);
  static Color wash([int a = 18]) => ink.withAlpha(a);
  static Color washHi([int a = 10]) => ink.withAlpha(a);
  static Color sealWash([int a = 44]) => seal.withAlpha(a);
}

class _DayCellDashedLinePainter extends CustomPainter {
  final Color color;

  const _DayCellDashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dash = 3.0;
    const gap = 2.5;

    var y = 0.0;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y2),
        paint,
      );
      y = y2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DayCellDashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _DashedHrPainter extends CustomPainter {
  final Color color;

  const _DashedHrPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dash = 4.0;
    const gap = 3.0;

    var x = 0.0;
    while (x < size.width) {
      final x2 = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x2, size.height / 2),
        paint,
      );
      x = x2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedHrPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _InkHoverRegion extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const _InkHoverRegion({required this.builder});

  @override
  State<_InkHoverRegion> createState() => _InkHoverRegionState();
}

class _InkHoverRegionState extends State<_InkHoverRegion> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}

class InkFiveDimYunLiuTable extends StatefulWidget {
  const InkFiveDimYunLiuTable({super.key});

  @override
  State<InkFiveDimYunLiuTable> createState() => _InkFiveDimYunLiuTableState();
}

class _InkFiveDimYunLiuTableState extends State<InkFiveDimYunLiuTable>
    with TickerProviderStateMixin {
  late final TabController _daYunTabController;
  late final List<ScrollController> _verticalControllers;
  late final List<ScrollController> _yearHorizontalControllers;

  late final List<int?> _expandedMonthByDaYun;
  late final List<int?> _expandedYearByDaYun;

  int? _pendingDaYunIndex;

  final Map<String, DateTime> _selectedDateByCalendar = <String, DateTime>{};
  ZiShiStrategy _shiChenZiStrategy = ZiShiStrategy.noDistinguishAt23;
  int _yearsPerDaYun = 10;

  static Color get _inkBorderColor => _InkTheme.line(70);

  final List<String> _daYun = const [
    '甲辰大运',
    '乙巳大运',
    '丙午大运',
    '丁未大运',
    '戊申大运',
    '己酉大运',
    '庚戌大运',
    '辛亥大运',
    '壬子大运',
    '癸丑大运',
  ];

  static const int _yearStartBase = 2024;

  int _yearAt(int daYunIndex, int yearIndex) {
    return _yearStartBase + (daYunIndex * _yearsPerDaYun) + yearIndex;
  }

  void _setYearsPerDaYun(int v) {
    if (v == _yearsPerDaYun) return;
    setState(() {
      _yearsPerDaYun = v;
      _selectedDateByCalendar.clear();
      for (var i = 0; i < _daYun.length; i++) {
        _expandedMonthByDaYun[i] = null;
        _expandedYearByDaYun[i] = null;
      }
    });
  }

  JiaZi _jiaZiOfYear(int year) {
    final list = JiaZi.listAll;
    final raw = year - 1984;
    final idx = ((raw % list.length) + list.length) % list.length;
    return list[idx];
  }

  int _calendarRows({required int year, required int month}) {
    final first = DateTime(year, month, 1);
    final next = DateTime(year, month + 1, 1);
    final days = next.subtract(const Duration(days: 1)).day;
    final leading = (first.weekday - DateTime.monday) % 7;
    final total = leading + days;
    return ((total + 6) ~/ 7).clamp(4, 6);
  }

  String _calendarId(int daYunIndex, int monthIndex, int yearIndex) {
    return '$daYunIndex-$monthIndex-$yearIndex';
  }

  double _calendarPanelWidth({
    required double yearsWidth,
    required bool isPhone,
  }) {
    final maxW = isPhone ? 460.0 : 640.0;
    return yearsWidth.clamp(300.0, maxW).toDouble();
  }

  double _calendarRowHeight({
    required double availableWidth,
    required bool isPhone,
  }) {
    final cellW = availableWidth / 7;
    return cellW.toDouble();
  }

  double _calendarExpandedRowHeight({
    required double yearsWidth,
    required bool isPhone,
    required int year,
    required int month,
    required bool showDetail,
  }) {
    final outerTop = 10.0;
    final outerBottom = 14.0;
    final outerLR = isPhone ? 10.0 : 14.0;

    final innerPad = isPhone ? 12.0 : 16.0;

    final panelW = _calendarPanelWidth(
      yearsWidth: yearsWidth,
      isPhone: isPhone,
    );
    final availableWidth = (panelW - (outerLR * 2) - (innerPad * 2))
        .clamp(140.0, double.infinity)
        .toDouble();
    final rows = _calendarRows(year: year, month: month);
    final rowH = _calendarRowHeight(
      availableWidth: availableWidth,
      isPhone: isPhone,
    );

    final headerH = isPhone ? 30.0 : 32.0;
    const weekH = 20.0;
    final topGap = isPhone ? 10.0 : 12.0;
    const midGap = 6.0;

    const gridCrossSpacing = 6.0;
    const gridMainSpacing = 6.0;
    const gridCrossAxisCount = 6;
    const cellAspectRatio = 1.28;

    final detailGap = showDetail ? 8.0 : 0.0;
    final shiChenH = showDetail
        ? () {
            final outerPad = isPhone ? 3.0 : 4.0;
            final innerPad = isPhone ? 10.0 : 12.0;

            final topBarH = isPhone ? 34.0 : 36.0;
            final bottomBarH = isPhone ? 30.0 : 32.0;
            final gapTop = isPhone ? 8.0 : 10.0;
            final gapBottom = isPhone ? 6.0 : 8.0;

            final panelW = (availableWidth - (outerPad * 2)).clamp(
              0.0,
              double.infinity,
            );
            final gridW = (panelW - (innerPad * 2)).clamp(0.0, double.infinity);
            final cellW =
                (gridW - (gridCrossSpacing * (gridCrossAxisCount - 1))) /
                gridCrossAxisCount;
            final cellH = (cellW / cellAspectRatio).clamp(0.0, double.infinity);
            final gridH = (cellH * 2) + gridMainSpacing;

            final total =
                (innerPad * 2) +
                topBarH +
                gapTop +
                gridH +
                gapBottom +
                bottomBarH;
            return total + (isPhone ? 22 : 24);
          }()
        : 0.0;

    final calendarH =
        headerH +
        topGap +
        weekH +
        midGap +
        (rows * rowH) +
        detailGap +
        shiChenH;

    return outerTop + outerBottom + (innerPad * 2) + calendarH + 6;
  }

  @override
  void initState() {
    super.initState();
    _daYunTabController = TabController(length: _daYun.length, vsync: this);
    _verticalControllers = List<ScrollController>.generate(
      _daYun.length,
      (_) => ScrollController(),
    );
    _yearHorizontalControllers = List<ScrollController>.generate(
      _daYun.length,
      (_) => ScrollController(),
    );
    _expandedMonthByDaYun = List<int?>.filled(_daYun.length, null);
    _expandedYearByDaYun = List<int?>.filled(_daYun.length, null);

    _daYunTabController.addListener(() {
      if (_daYunTabController.indexIsChanging) {
        final i = _daYunTabController.index;
        final prev = _daYunTabController.previousIndex;
        setState(() {
          _expandedMonthByDaYun[i] = null;
          _expandedYearByDaYun[i] = null;
          _expandedMonthByDaYun[prev] = null;
          _expandedYearByDaYun[prev] = null;
        });
      }
      if (!_daYunTabController.indexIsChanging &&
          _pendingDaYunIndex != null &&
          _pendingDaYunIndex == _daYunTabController.index) {
        setState(() {
          _pendingDaYunIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _daYunTabController.dispose();
    for (final c in _verticalControllers) {
      c.dispose();
    }
    for (final c in _yearHorizontalControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isPhone = c.maxWidth < 600;
        final padding = isPhone ? 16.0 : 24.0;

        final cellW = 128.0;
        final cellH = cellW * 2 / 3;
        final headerH = 122.0;
        final monthAxisW = isPhone ? 56.0 : 72.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: _InkTheme.paper,
            border: Border.all(color: _inkBorderColor, width: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      CustomPaint(painter: _PaperTexturePainter()),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _InkTheme.paperHi.withAlpha(160),
                              Colors.transparent,
                              _InkTheme.ink.withAlpha(10),
                            ],
                            stops: const [0, 0.6, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 0,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(10),
                            Colors.black.withAlpha(18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildDaYunTabs(isPhone: isPhone),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _daYunTabController,
                      physics: const PageScrollPhysics(),
                      children: List<Widget>.generate(
                        _daYun.length,
                        (daYunIndex) => _buildDaYunTable(
                          daYunIndex: daYunIndex,
                          monthAxisW: monthAxisW,
                          headerH: headerH,
                          cellW: cellW,
                          cellH: cellH,
                          isPhone: isPhone,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaYunTabs({required bool isPhone}) {
    final tabW = isPhone ? 118.0 : 125.0;
    final tabH = isPhone ? 156.0 : 165.0;

    const selectedPaper = Color(0xFFFDFaf5);
    const unselectedPaper = Color(0xFFF2F2F2);

    final borderActive = _InkTheme.ink;
    final gold = _InkTheme.gold;
    final cinnabar = _InkTheme.seal;

    final is9 = _yearsPerDaYun == 9;

    final toggleLabelStyle = TextStyle(
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w800,
      color: _InkTheme.ink.withAlpha(160),
      fontFamilyFallback: const ['STKaiti', 'KaiTi', 'Noto Serif SC', 'serif'],
    );

    final toggle = Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _inkBorderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('一运', style: toggleLabelStyle),
            const SizedBox(width: 10),
            ToggleButtons(
              isSelected: [is9, !is9],
              onPressed: (index) {
                _setYearsPerDaYun(index == 0 ? 9 : 10);
              },
              borderRadius: BorderRadius.circular(999),
              constraints: const BoxConstraints(minHeight: 30, minWidth: 46),
              borderColor: _InkTheme.ink.withAlpha(35),
              selectedBorderColor: _InkTheme.seal.withAlpha(160),
              fillColor: _InkTheme.sealWash(36),
              color: _InkTheme.ink.withAlpha(170),
              selectedColor: _InkTheme.seal.withAlpha(230),
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
          ],
        ),
      ),
    );

    TextStyle kaitiTextStyle({
      required double fontSize,
      FontWeight? fontWeight,
      required Color color,
      double height = 1,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFamilyFallback: const [
          'STKaiti',
          'KaiTi',
          'Noto Serif SC',
          'serif',
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _daYunTabController,
            builder: (context, _) {
              final selectedIndex =
                  _pendingDaYunIndex ?? _daYunTabController.index;
              const highlightDuration = Duration(milliseconds: 240);
              const highlightCurve = Curves.easeOutCubic;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: _inkBorderColor, width: 0.6),
                  color: _InkTheme.paperHi.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(alignment: Alignment.centerRight, child: toggle),
                    const SizedBox(height: 10),
                    ScrollConfiguration(
                      behavior: _InkScrollBehavior(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...List<Widget>.generate(_daYun.length, (i) {
                              final selected = i == selectedIndex;

                              final startYear = _yearAt(i, 0);
                              final endYear = _yearAt(i, _yearsPerDaYun - 1);
                              final startAge =
                                  28 + (startYear - _yearStartBase);
                              final endAge = startAge + _yearsPerDaYun;

                              final pillar = _daYun[i].replaceAll('大运', '');

                              final ganGod = EnumTenGods
                                  .values[i % EnumTenGods.values.length];

                              final hiddenRaw = YunLiuHelper.hiddenGansForSeed(
                                i * 37,
                              );
                              final hidden =
                                  <({TianGan gan, EnumTenGods tenGod})>[
                                    ...hiddenRaw.map(
                                      (e) => (gan: e.gan, tenGod: e.hiddenGods),
                                    ),
                                  ];
                              while (hidden.length < 3) {
                                hidden.add((
                                  gan: TianGan.JIA,
                                  tenGod: EnumTenGods.BiJian,
                                ));
                              }

                              final labelStyle = kaitiTextStyle(
                                fontSize: 10,
                                height: 1.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              );
                              final yearStyle = kaitiTextStyle(
                                fontSize: 10.5,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              );
                              final ageStyle = kaitiTextStyle(
                                fontSize: 9.5,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withAlpha(220),
                                letterSpacing: 0.2,
                              );
                              final pillarStyle = kaitiTextStyle(
                                fontSize: isPhone ? 30 : 32,
                                fontWeight: FontWeight.w900,
                                color: _InkTheme.ink,
                                letterSpacing: isPhone ? 3 : 4,
                              );
                              final godStyle = kaitiTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: cinnabar,
                              );
                              final stemStyle = kaitiTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _InkTheme.ink,
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _pendingDaYunIndex = i;
                                    });
                                    _daYunTabController.animateTo(i);
                                  },
                                  child: AnimatedContainer(
                                    duration: highlightDuration,
                                    curve: highlightCurve,
                                    width: tabW,
                                    height: tabH,
                                    transform: selected
                                        ? Matrix4.translationValues(0, -3, 0)
                                        : null,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? selectedPaper
                                          : unselectedPaper,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: selected
                                            ? borderActive
                                            : Colors.black.withAlpha(15),
                                        width: selected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: selected
                                              ? Colors.black.withAlpha(46)
                                              : Colors.black.withAlpha(30),
                                          blurRadius: selected ? 18 : 4,
                                          offset: selected
                                              ? const Offset(0, 6)
                                              : const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              AnimatedContainer(
                                                duration: highlightDuration,
                                                curve: highlightCurve,
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? cinnabar
                                                      : const Color(0xFF9A9A9A),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(16),
                                                        topRight:
                                                            Radius.circular(16),
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withAlpha(40),
                                                    width: 0.6,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withAlpha(52),
                                                      blurRadius: 3,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$startYear - $endYear',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: yearStyle,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      '$startAge岁 - $endAge岁',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: ageStyle,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        6,
                                                        4,
                                                        6,
                                                        0,
                                                      ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 9,
                                                          child: Opacity(
                                                            opacity: selected
                                                                ? 1
                                                                : 0.6,
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  for (final c
                                                                      in pillar
                                                                          .split(
                                                                            '',
                                                                          ))
                                                                    Text(
                                                                      c,
                                                                      style:
                                                                          pillarStyle,
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1,
                                                          height:
                                                              double.infinity,
                                                          color: gold.withAlpha(
                                                            38,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 13,
                                                          child: Opacity(
                                                            opacity: selected
                                                                ? 1
                                                                : 0.5,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 10,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Transform.scale(
                                                                        scale:
                                                                            0.8,
                                                                        child: Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                1,
                                                                            vertical:
                                                                                0,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(
                                                                              color: cinnabar,
                                                                              width: 1,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(
                                                                              1,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            '干',
                                                                            style: TextStyle(
                                                                              fontSize: 8,
                                                                              height: 1,
                                                                              color: cinnabar,
                                                                              fontWeight: FontWeight.w800,
                                                                              fontFamilyFallback: const [
                                                                                'STKaiti',
                                                                                'KaiTi',
                                                                                'Noto Serif SC',
                                                                                'serif',
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        ganGod
                                                                            .name,
                                                                        style:
                                                                            godStyle,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  for (
                                                                    var j = 0;
                                                                    j < 3;
                                                                    j++
                                                                  ) ...[
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              14,
                                                                          child: Text(
                                                                            hidden[j].gan.name,
                                                                            style:
                                                                                stemStyle,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              4,
                                                                        ),
                                                                        Text(
                                                                          hidden[j]
                                                                              .tenGod
                                                                              .name,
                                                                          style:
                                                                              godStyle,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    if (j != 2)
                                                                      const SizedBox(
                                                                        height:
                                                                            3,
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
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration: highlightDuration,
                                                curve: highlightCurve,
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? cinnabar
                                                      : const Color(0xFF9A9A9A),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(16),
                                                        bottomRight:
                                                            Radius.circular(16),
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withAlpha(52),
                                                      blurRadius: 3,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  '大运',
                                                  style: labelStyle,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: SizedBox(
                                              height: 6,
                                              child: Opacity(
                                                opacity: selected ? 1 : 0.2,
                                                child: DecoratedBox(
                                                  decoration: selected
                                                      ? BoxDecoration(
                                                          color: cinnabar,
                                                        )
                                                      : BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            tileMode: TileMode
                                                                .repeated,
                                                            colors: [
                                                              gold,
                                                              gold,
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            stops: const [
                                                              0,
                                                              0.5,
                                                              0.5,
                                                              1,
                                                            ],
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaYunTable({
    required int daYunIndex,
    required double monthAxisW,
    required double headerH,
    required double cellW,
    required double cellH,
    required bool isPhone,
  }) {
    return ScrollConfiguration(
      behavior: _InkScrollBehavior(),
      child: SingleChildScrollView(
        controller: _verticalControllers[daYunIndex],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthAxis(
              daYunIndex: daYunIndex,
              monthAxisW: monthAxisW,
              headerH: headerH,
              cellW: cellW,
              cellH: cellH,
              isPhone: isPhone,
            ),
            Expanded(
              child: _buildYearArea(
                daYunIndex: daYunIndex,
                cellW: cellW,
                cellH: cellH,
                headerH: headerH,
                isPhone: isPhone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthAxis({
    required int daYunIndex,
    required double monthAxisW,
    required double headerH,
    required double cellW,
    required double cellH,
    required bool isPhone,
  }) {
    final monthStyle = ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(
      fontSize: isPhone ? 16 : 20,
      color: _InkTheme.ink.withAlpha(120),
      shadows: const [],
    );

    return Column(
      children: [
        SizedBox(
          width: monthAxisW,
          height: headerH,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _inkBorderColor, width: 0.6),
                bottom: BorderSide(color: _inkBorderColor, width: 0.6),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_InkTheme.paperHi.withAlpha(220), _InkTheme.paper],
              ),
            ),
          ),
        ),
        for (var m = 0; m < YunLiuHelper.months.length; m++) ...[
          Container(
            width: monthAxisW,
            height: cellH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _inkBorderColor, width: 0.6),
                bottom: BorderSide(color: _inkBorderColor, width: 0.6),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withAlpha(140),
                  Colors.white.withAlpha(90),
                ],
              ),
            ),
            child: _buildVerticalLabel(YunLiuHelper.months[m], monthStyle),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: monthAxisW,
              height:
                  _expandedMonthByDaYun[daYunIndex] == m &&
                      _expandedYearByDaYun[daYunIndex] != null
                  ? _calendarExpandedRowHeight(
                      yearsWidth: _yearsPerDaYun * cellW,
                      isPhone: isPhone,
                      year: _yearAt(
                        daYunIndex,
                        _expandedYearByDaYun[daYunIndex]!,
                      ),
                      month: m + 1,
                      showDetail: _selectedDateByCalendar.containsKey(
                        _calendarId(
                          daYunIndex,
                          m,
                          _expandedYearByDaYun[daYunIndex]!,
                        ),
                      ),
                    )
                  : 0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: _inkBorderColor, width: 0.6),
                    bottom: BorderSide(color: _inkBorderColor, width: 0.6),
                  ),
                  color: _InkTheme.wash(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildYearArea({
    required int daYunIndex,
    required double cellW,
    required double cellH,
    required double headerH,
    required bool isPhone,
  }) {
    final yearsWidth = _yearsPerDaYun * cellW;

    return ScrollConfiguration(
      behavior: _InkScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _yearHorizontalControllers[daYunIndex],
        child: SizedBox(
          width: yearsWidth,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    for (var i = 0; i < _yearsPerDaYun; i++)
                      Container(
                        width: cellW,
                        color: i.isEven
                            ? _InkTheme.wash(isPhone ? 6 : 4)
                            : Colors.transparent,
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: headerH,
                    child: Row(
                      children: [
                        for (var i = 0; i < _yearsPerDaYun; i++)
                          SizedBox(
                            width: cellW,
                            height: headerH,
                            child: DaYunHeaderCell(
                              year: _yearAt(daYunIndex, i),
                              age:
                                  28 +
                                  (_yearAt(daYunIndex, i) - _yearStartBase),
                              yearGanZhi: _jiaZiOfYear(_yearAt(daYunIndex, i)),
                              ganGod:
                                  EnumTenGods.values[(daYunIndex + i) %
                                      EnumTenGods.values.length],
                              hiddenGans: YunLiuHelper.hiddenGansForSeed(
                                (daYunIndex * 37) + (i * 11),
                              ),
                              backgroundColor: i.isEven
                                  ? _InkTheme.wash(isPhone ? 6 : 4)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (var m = 0; m < YunLiuHelper.months.length; m++) ...[
                    SizedBox(
                      height: cellH,
                      child: Row(
                        children: [
                          for (var y = 0; y < _yearsPerDaYun; y++)
                            _buildGanZhiCell(
                              daYunIndex: daYunIndex,
                              yearIndex: y,
                              monthIndex: m,
                              width: cellW,
                              height: cellH,
                              isPhone: isPhone,
                            ),
                        ],
                      ),
                    ),
                    _buildExpandedCalendarRow(
                      daYunIndex: daYunIndex,
                      monthIndex: m,
                      yearsWidth: yearsWidth,
                      isPhone: isPhone,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGanZhiCell({
    required int daYunIndex,
    required int yearIndex,
    required int monthIndex,
    required double width,
    required double height,
    required bool isPhone,
  }) {
    final isExpanded =
        _expandedMonthByDaYun[daYunIndex] == monthIndex &&
        _expandedYearByDaYun[daYunIndex] == yearIndex;

    final year = _yearAt(daYunIndex, yearIndex);
    final seed = (daYunIndex * 97) + (yearIndex * 19) + (monthIndex * 7);

    final tianGan = TianGan.listAll[seed % TianGan.listAll.length];
    final diZhi = DiZhi.values[(seed + 3) % DiZhi.values.length];
    final tenGod = EnumTenGods.values[(seed + 5) % EnumTenGods.values.length];
    final tenGodDetails = YunLiuHelper.tenGodDetailsForSeed(seed);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            setState(() {
              if (isExpanded) {
                _selectedDateByCalendar.remove(
                  _calendarId(daYunIndex, monthIndex, yearIndex),
                );
                _expandedMonthByDaYun[daYunIndex] = null;
                _expandedYearByDaYun[daYunIndex] = null;
              } else {
                _expandedMonthByDaYun[daYunIndex] = monthIndex;
                _expandedYearByDaYun[daYunIndex] = yearIndex;
              }
            });

            if (!isPhone) return;

            await WidgetsBinding.instance.endOfFrame;
            final key = _calendarKey(daYunIndex, monthIndex, yearIndex);
            if (key.currentContext != null) {
              Scrollable.ensureVisible(
                key.currentContext!,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: 0.35,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _inkBorderColor, width: 0.6),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SizedBox(
                    width: 120,
                    child: YunLiuTableMonthWidget(
                      tianGan: tianGan,
                      diZhi: diZhi,
                      tenGod: tenGod,
                      tenGodDetails: tenGodDetails,
                    ),
                  ),
                ),
                if (isExpanded)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _InkTheme.seal.withAlpha(70),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCalendarRow({
    required int daYunIndex,
    required int monthIndex,
    required double yearsWidth,
    required bool isPhone,
  }) {
    final expanded = _expandedMonthByDaYun[daYunIndex] == monthIndex;
    final yearIndex = _expandedYearByDaYun[daYunIndex];
    final panelW = _calendarPanelWidth(
      yearsWidth: yearsWidth,
      isPhone: isPhone,
    );

    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: expanded && yearIndex != null
            ? Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: panelW,
                  height: _calendarExpandedRowHeight(
                    yearsWidth: yearsWidth,
                    isPhone: isPhone,
                    year: _yearAt(daYunIndex, yearIndex),
                    month: monthIndex + 1,
                    showDetail: _selectedDateByCalendar.containsKey(
                      _calendarId(daYunIndex, monthIndex, yearIndex),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isPhone ? 10 : 14,
                      10,
                      isPhone ? 10 : 14,
                      14,
                    ),
                    child: _DoubleInkBorder(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        key: _calendarKey(daYunIndex, monthIndex, yearIndex),
                        padding: EdgeInsets.all(isPhone ? 12 : 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _InkTheme.paperHi.withAlpha(240),
                              Colors.white.withAlpha(150),
                              _InkTheme.washHi(10),
                            ],
                          ),
                        ),
                        child: _buildCalendar(
                          calendarId: _calendarId(
                            daYunIndex,
                            monthIndex,
                            yearIndex,
                          ),
                          year: _yearAt(daYunIndex, yearIndex),
                          month: monthIndex + 1,
                          isPhone: isPhone,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCalendar({
    required String calendarId,
    required int year,
    required int month,
    required bool isPhone,
  }) {
    final titleStyle = TextStyle(
      fontSize: isPhone ? 12 : 13,
      color: _InkTheme.ink.withAlpha(200),
      height: 1.0,
      fontWeight: FontWeight.w600,
    );

    final cellMargin = isPhone ? 3.0 : 4.0;

    final first = DateTime(year, month, 1);
    final next = DateTime(year, month + 1, 1);
    final days = next.subtract(const Duration(days: 1)).day;

    final leading = (first.weekday - DateTime.monday) % 7;

    final items = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      items.add(null);
    }
    for (var d = 1; d <= days; d++) {
      items.add(DateTime(year, month, d));
    }
    while (items.length % 7 != 0) {
      items.add(null);
    }

    final today = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final rows = items.isEmpty ? 0 : (items.length ~/ 7);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pre-calculate major lunar month for highlighting
        final lunarMonthCounts = <int, int>{};
        for (final dt in items) {
          if (dt != null) {
            final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
              DateTime(dt.year, dt.month, dt.day, 12),
              _shiChenZiStrategy,
            );
            lunarMonthCounts[info.lunarMonth] =
                (lunarMonthCounts[info.lunarMonth] ?? 0) + 1;
          }
        }
        int? majorLunarMonth;
        var maxCount = -1;
        for (final entry in lunarMonthCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            majorLunarMonth = entry.key;
          }
        }

        final currentYearGanZhi = _jiaZiOfYear(year).name;

        final headerH = isPhone ? 30.0 : 32.0;
        final weekH = 20.0;
        final topGap = isPhone ? 10.0 : 12.0;
        final midGap = 6.0;
        final rowH = rows == 0
            ? 0.0
            : _calendarRowHeight(
                availableWidth: constraints.maxWidth,
                isPhone: isPhone,
              );
        final selected = _selectedDateByCalendar[calendarId];

        int? selectedRow;
        if (selected != null) {
          final idx = items.indexWhere(
            (e) => e != null && isSameDay(e, selected),
          );
          if (idx >= 0) selectedRow = idx ~/ 7;
        }

        const gridCrossSpacing = 6.0;
        const gridMainSpacing = 6.0;
        const gridCrossAxisCount = 6;
        const cellAspectRatio = 1.28;

        final shiChenPanelH = selected == null
            ? 0.0
            : () {
                final outerPad = cellMargin;
                final innerPad = isPhone ? 10.0 : 12.0;

                final topBarH = isPhone ? 34.0 : 36.0;
                final bottomBarH = isPhone ? 30.0 : 32.0;
                final gapTop = isPhone ? 8.0 : 10.0;
                final gapBottom = isPhone ? 6.0 : 8.0;

                final panelW = (constraints.maxWidth - (outerPad * 2)).clamp(
                  0.0,
                  double.infinity,
                );
                final gridW = (panelW - (innerPad * 2)).clamp(
                  0.0,
                  double.infinity,
                );
                final cellW =
                    (gridW - (gridCrossSpacing * (gridCrossAxisCount - 1))) /
                    gridCrossAxisCount;
                final cellH = (cellW / cellAspectRatio).clamp(
                  0.0,
                  double.infinity,
                );
                final gridH = (cellH * 2) + gridMainSpacing;

                final total =
                    (innerPad * 2) +
                    topBarH +
                    gapTop +
                    gridH +
                    gapBottom +
                    bottomBarH;
                return total + (isPhone ? 12 : 14);
              }();

        const useLegacyDetailPanel = false;

        Widget shiChenPanel() {
          final date = selected!;
          final base = DateTime(date.year, date.month, date.day);
          final dayStart = base;
          final dayEnd = base.add(const Duration(days: 1));

          String two(int v) => v.toString().padLeft(2, '0');
          String hhmmss(DateTime t) =>
              '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

          int indexForTime(DateTime t) {
            final h = t.hour;
            if (_shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
              return (h ~/ 2) % 12;
            }
            if (h >= 23 || h == 0) return 0;
            return ((h + 1) ~/ 2) % 12;
          }

          DateTime midTimeForIndex(int i) {
            if (_shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
              final startH = (i * 2) % 24;
              return base.add(Duration(hours: startH, minutes: 30));
            }
            if (i == 0) {
              return base.add(const Duration(hours: 23, minutes: 30));
            }
            final startH = ((i * 2) - 1) % 24;
            return base.add(Duration(hours: startH, minutes: 30));
          }

          String rangeLabelForIndex(int i) {
            if (_shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
              final s = (i * 2) % 24;
              final e = (s + 1) % 24;
              return '${two(s)}:00~${two(e)}:59';
            }
            if (i == 0) return '23:00~00:59';
            final s = ((i * 2) - 1) % 24;
            final e = ((i * 2)) % 24;
            return '${two(s)}:00~${two(e)}:59';
          }

          final infoAtNoon = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            base.add(const Duration(hours: 12)),
            _shiChenZiStrategy,
          );
          final dayMaster = infoAtNoon.eightChars.dayTianGan;

          final infoAtStart = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            base,
            _shiChenZiStrategy,
          );
          final infoAtEnd = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            base.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
            _shiChenZiStrategy,
          );

          final candidates = <({DateTime at, TwentyFourJieQi jq})>[];
          void addCandidate(DateTime at, TwentyFourJieQi jq) {
            if (!at.isBefore(dayStart) && at.isBefore(dayEnd)) {
              candidates.add((at: at, jq: jq));
            }
          }

          addCandidate(
            infoAtStart.jieQiInfo.startAt,
            infoAtStart.jieQiInfo.jieQi,
          );
          addCandidate(
            infoAtStart.jieQiInfo.endAt,
            infoAtStart.jieQiInfo.nextJieQi,
          );
          addCandidate(infoAtEnd.jieQiInfo.startAt, infoAtEnd.jieQiInfo.jieQi);
          addCandidate(
            infoAtEnd.jieQiInfo.endAt,
            infoAtEnd.jieQiInfo.nextJieQi,
          );

          candidates.sort((a, b) => a.at.compareTo(b.at));

          ({DateTime at, TwentyFourJieQi jq})? boundary;
          if (candidates.isNotEmpty) {
            boundary = candidates.first;
          }

          final boundaryIndex = boundary == null
              ? null
              : indexForTime(boundary.at);
          final boundaryLabel = boundary == null
              ? null
              : '${boundary.jq.name} ${hhmmss(boundary.at)}';

          final twelve = List.generate(12, (i) {
            final dt = midTimeForIndex(i);
            final jz = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
              dt,
              _shiChenZiStrategy,
            ).eightChars.time;
            return (
              jz: jz,
              range: rangeLabelForIndex(i),
              jieqi: boundaryIndex == i ? boundaryLabel : null,
            );
          });

          final switcherTextStyle = TextStyle(
            fontSize: 10,
            height: 1.0,
            color: _InkTheme.ink.withAlpha(200),
            fontWeight: FontWeight.w800,
          );

          Color getStrategyColor(ZiShiStrategy s, {bool isWash = false}) {
            switch (s) {
              case ZiShiStrategy.noDistinguishAt23:
              case ZiShiStrategy.startFrom23:
                return isWash
                    ? const Color(0xFF455A64).withOpacity(0.15)
                    : const Color(0xFF455A64);
              case ZiShiStrategy.distinguishAt0FiveMouse:
              case ZiShiStrategy.startFrom0:
              case ZiShiStrategy.splitedZi:
              case ZiShiStrategy.bandsStartAt0:
                return isWash ? _InkTheme.sealWash(40) : _InkTheme.seal;
              case ZiShiStrategy.distinguishAt0Fixed:
                return isWash
                    ? const Color(0xFF2E7D32).withOpacity(0.15)
                    : const Color(0xFF2E7D32);
            }
          }

          return _DoubleInkBorder(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _InkTheme.paper,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.12,
                        child: CustomPaint(painter: _PaperTexturePainter()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isPhone ? 10 : 12),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SegmentedButton<ZiShiStrategy>(
                                segments: <ButtonSegment<ZiShiStrategy>>[
                                  ButtonSegment<ZiShiStrategy>(
                                    value: ZiShiStrategy.noDistinguishAt23,
                                    label: Text(
                                      '23统',
                                      style: switcherTextStyle,
                                    ),
                                  ),
                                  ButtonSegment<ZiShiStrategy>(
                                    value:
                                        ZiShiStrategy.distinguishAt0FiveMouse,
                                    label: Text('0五', style: switcherTextStyle),
                                  ),
                                  ButtonSegment<ZiShiStrategy>(
                                    value: ZiShiStrategy.distinguishAt0Fixed,
                                    label: Text('0定', style: switcherTextStyle),
                                  ),
                                ],
                                selected: <ZiShiStrategy>{_shiChenZiStrategy},
                                onSelectionChanged: (s) {
                                  setState(() => _shiChenZiStrategy = s.first);
                                },
                                showSelectedIcon: false,
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                  ),
                                  side: WidgetStateProperty.all(
                                    BorderSide(
                                      color: _InkTheme.line(60),
                                      width: 0.6,
                                    ),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return getStrategyColor(
                                            _shiChenZiStrategy,
                                            isWash: true,
                                          );
                                        }
                                        return Colors.white.withAlpha(170);
                                      }),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return getStrategyColor(
                                          _shiChenZiStrategy,
                                          isWash: true,
                                        ).withOpacity(0.3);
                                      }
                                      if (states.contains(
                                        WidgetState.hovered,
                                      )) {
                                        return Colors.white.withAlpha(70);
                                      }
                                      return null;
                                    },
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDateByCalendar.remove(
                                        calendarId,
                                      );
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _InkTheme.line(60),
                                        width: 0.6,
                                      ),
                                      color: Colors.white.withAlpha(140),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'X 关闭',
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.0,
                                        color: _InkTheme.ink.withAlpha(170),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isPhone ? 8 : 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: twelve.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridCrossAxisCount,
                                  crossAxisSpacing: gridCrossSpacing,
                                  mainAxisSpacing: gridMainSpacing,
                                  childAspectRatio: cellAspectRatio,
                                ),
                            itemBuilder: (context, i) {
                              final item = twelve[i];
                              return LiuGanZhiMiniCell(
                                label: item.jz.diZhi.value,
                                timeRangeLabel: item.range,
                                timeRangeColor: getStrategyColor(
                                  _shiChenZiStrategy,
                                ),
                                jieQiLabel: item.jieqi,
                                jiaZi: item.jz,
                                dayMaster: dayMaster,
                              );
                            },
                          ),
                          SizedBox(height: isPhone ? 6 : 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/common/ren_sheng_wan_nian_li');
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _InkTheme.sealWash(34),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _InkTheme.seal.withAlpha(140),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    '进入「人生万年历」>>>',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.0,
                                      color: _InkTheme.seal.withAlpha(220),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget cell(DateTime? dt) {
          if (dt == null) {
            return Padding(
              padding: EdgeInsets.all(cellMargin),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  border: Border.all(
                    color: const Color(0xFFD1CDC2),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          final isToday = isSameDay(dt, today);
          final isSelected = selected != null && isSameDay(dt, selected);

          return Padding(
            padding: EdgeInsets.all(cellMargin),
            child: _buildLiuDayCell(
              date: dt,
              isToday: isToday,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (selected != null && isSameDay(dt, selected)) {
                    _selectedDateByCalendar.remove(calendarId);
                  } else {
                    _selectedDateByCalendar[calendarId] = dt;
                  }
                });
              },
              majorLunarMonth: majorLunarMonth,
              currentYearGanZhi: currentYearGanZhi,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: headerH,
              child: Row(
                children: [
                  Text('$year 年 $month 月', style: titleStyle),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final parts = calendarId.split('-');
                        final daYunIndex = parts.isNotEmpty
                            ? int.tryParse(parts[0])
                            : null;
                        setState(() {
                          _selectedDateByCalendar.remove(calendarId);
                          if (daYunIndex != null &&
                              daYunIndex >= 0 &&
                              daYunIndex < _expandedMonthByDaYun.length) {
                            _expandedMonthByDaYun[daYunIndex] = null;
                            _expandedYearByDaYun[daYunIndex] = null;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _InkTheme.line(60),
                            width: 0.6,
                          ),
                          color: Colors.white.withAlpha(140),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'X 关闭',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.0,
                            color: _InkTheme.ink.withAlpha(170),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: topGap),
            SizedBox(
              height: weekH,
              child: Row(
                children: const ['一', '二', '三', '四', '五', '六', '日']
                    .map(
                      (e) => Expanded(
                        child: Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.0,
                              color: _InkTheme.ink.withAlpha(160),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            SizedBox(height: midGap),
            Column(
              children: [
                for (var r = 0; r < rows; r++) ...[
                  SizedBox(
                    height: rowH,
                    child: Row(
                      children: [
                        for (var c = 0; c < 7; c++)
                          Expanded(child: cell(items[r * 7 + c])),
                      ],
                    ),
                  ),
                  if (selectedRow == r) ...[
                    const SizedBox(height: 2),
                    SizedBox(
                      height: shiChenPanelH,
                      child: Padding(
                        padding: EdgeInsets.all(cellMargin),
                        child: shiChenPanel(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
            if (selected != null && useLegacyDetailPanel) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: isPhone ? 360.0 : 420.0,
                child: _InlineDayDetailPanel(
                  date: selected,
                  isPhone: isPhone,
                  onClose: () {
                    setState(() {
                      _selectedDateByCalendar.remove(calendarId);
                    });
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildVerticalLabel(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }

  String _splitTwoLines(String text) {
    final chars = text.split('');
    if (chars.length <= 1) return text;
    if (chars.length == 2) return '${chars[0]}\n${chars[1]}';
    return '${chars.take(chars.length - 1).join('')}\n${chars.last}';
  }

  String _ganZhiForDay(DateTime date) {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    final g = (date.year + date.month + date.day) % gan.length;
    final z = (date.year + (date.month * 2) + date.day) % zhi.length;
    return '${gan[g]}${zhi[z]}';
  }

  ({String tenGod, String shortName}) _tenGodForDay(DateTime date) {
    const names = ['正财', '偏财', '正印', '偏印', '食神', '伤官', '正官', '偏官', '比肩', '劫财'];
    const shortNames = ['财', '才', '印', '枭', '食', '伤', '官', '杀', '比', '劫'];
    final i = (date.day + date.month + date.year) % names.length;
    return (tenGod: names[i], shortName: shortNames[i]);
  }

  List<({String gan, String tenGod, String shortName})> _hiddenTriplesForDay(
    DateTime date,
  ) {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const tenGods = [
      '正财',
      '偏财',
      '正印',
      '偏印',
      '食神',
      '伤官',
      '正官',
      '偏官',
      '比肩',
      '劫财',
    ];
    const shortNames = ['财', '才', '印', '枭', '食', '伤', '官', '杀', '比', '劫'];
    final seed = (date.year * 37) + (date.month * 11) + date.day;
    return <({String gan, String tenGod, String shortName})>[
      (
        gan: gan[seed % gan.length],
        tenGod: tenGods[(seed + 1) % tenGods.length],
        shortName: shortNames[(seed + 1) % shortNames.length],
      ),
      (
        gan: gan[(seed + 3) % gan.length],
        tenGod: tenGods[(seed + 2) % tenGods.length],
        shortName: shortNames[(seed + 2) % shortNames.length],
      ),
      (
        gan: gan[(seed + 6) % gan.length],
        tenGod: tenGods[(seed + 3) % tenGods.length],
        shortName: shortNames[(seed + 3) % shortNames.length],
      ),
    ];
  }

  Widget _verticalGanZhi(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }

  Widget _buildLiuDayCell({
    required DateTime date,
    required bool isToday,
    required bool isSelected,
    required VoidCallback onTap,
    required int? majorLunarMonth,
    required String currentYearGanZhi,
  }) {
    final ganZhi = _ganZhiForDay(date);
    final ganZhiChars = ganZhi.split('');
    final ganText = ganZhiChars.isEmpty ? '' : ganZhiChars.first;
    final zhiText = ganZhiChars.length < 2 ? '' : ganZhiChars[1];

    final tenGodName = _tenGodForDay(date).tenGod;
    final hidden = _hiddenTriplesForDay(
      date,
    ).map((e) => (gan: e.gan, tenGod: e.tenGod)).toList(growable: false);

    final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      DateTime(date.year, date.month, date.day, 12),
      _shiChenZiStrategy,
    );

    var jieQi = '';
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final jq = info.jieQiInfo;
    if (!jq.startAt.isBefore(dayStart) && jq.startAt.isBefore(dayEnd)) {
      jieQi = jq.jieQi.name;
    } else if (!jq.endAt.isBefore(dayStart) && jq.endAt.isBefore(dayEnd)) {
      jieQi = jq.nextJieQi.name;
    }

    final zodiac = EnumChinese12Zodiac.fromDiZhi(
      DiZhi.getFromValue(zhiText) ?? DiZhi.ZI,
    ).name;

    // Lunar text formatting logic
    final lunarYear = info.eightChars.year.name;
    final showYear = lunarYear != currentYearGanZhi;

    var monthStr =
        SolarLunarDateTimeHelper.intMonth2ChineseMap[info.lunarMonth] ??
        '${info.lunarMonth}';
    if (info.lunarMonth == 1) monthStr = '一';
    if (info.lunarMonth == 11) monthStr = '十一';
    if (info.lunarMonth == 12) monthStr = '十二';

    final dayStr =
        SolarLunarDateTimeHelper.intDay2ChineseMap[info.lunarDay] ??
        '${info.lunarDay}';

    final sb = StringBuffer();
    if (showYear) {
      sb.write('$lunarYear · ');
    }
    sb.write('${info.isLeapMonth ? '闰' : ''}$monthStr月 · $dayStr');

    final lunarText = sb.toString();
    final isHighlight =
        majorLunarMonth != null && info.lunarMonth != majorLunarMonth;

    return LiuDayCellWidget(
      date: date,
      isToday: isToday,
      isSelected: isSelected,
      onTap: onTap,
      ganText: ganText,
      zhiText: zhiText,
      tenGodName: tenGodName,
      hidden: hidden,
      jieQi: jieQi,
      zodiac: zodiac,
      lunarText: lunarText,
      isLunarHighlight: isHighlight,
    );
  }

  Color _fiveElementTint({
    required int daYunIndex,
    required int yearIndex,
    required int monthIndex,
  }) {
    final k = (daYunIndex + yearIndex + monthIndex) % 5;
    switch (k) {
      case 0:
        return const Color(0xFF4E7D58).withAlpha(22);
      case 1:
        return const Color(0xFFB23A2B).withAlpha(18);
      case 2:
        return const Color(0xFFB89B4D).withAlpha(18);
      case 3:
        return const Color(0xFF7A7A7A).withAlpha(16);
      default:
        return const Color(0xFF3E6D8C).withAlpha(18);
    }
  }

  final Map<String, GlobalKey> _calendarKeys = {};

  GlobalKey _calendarKey(int daYunIndex, int monthIndex, int yearIndex) {
    final k = '$daYunIndex-$monthIndex-$yearIndex';
    return _calendarKeys.putIfAbsent(k, () => GlobalKey());
  }
}

class LiuDayCellWidget extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  final String ganText;
  final String zhiText;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String jieQi;
  final String zodiac;
  final String lunarText;
  final bool isLunarHighlight;

  const LiuDayCellWidget({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.ganText,
    required this.zhiText,
    required this.tenGodName,
    required this.hidden,
    required this.jieQi,
    required this.zodiac,
    required this.lunarText,
    this.isLunarHighlight = false,
  });

  Widget _vertical(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(chars.first, style: style),
        SizedBox(height: 8.0),
        Text(chars.last, style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFFCFAF2);
    const ink = Color(0xFF1A1A1A);
    const sealRed = Color(0xFFB22222);

    return _InkHoverRegion(
      builder: (context, isHovered) {
        const designSize = 180.0;
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: designSize,
            height: designSize,
            child: LayoutBuilder(
              builder: (context, c) {
                final s =
                    ((c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) /
                            designSize)
                        .clamp(0.35, 2.0);

                final radius = 12.0 * s;
                final borderW = 2.0 * s;

                final dateStyle = TextStyle(
                  fontSize: 32.0 * s,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  color: ink.withAlpha(100),
                  fontFamilyFallback: const [
                    'ZCOOL XiaoWei',
                    'Noto Serif SC',
                    'serif',
                  ],
                );

                final pillarStyle = TextStyle(
                  fontSize: 38.0 * s,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  letterSpacing: -2.0 * s,
                  fontFamilyFallback: const [
                    'ZCOOL XiaoWei',
                    'Noto Serif SC',
                    'serif',
                  ],
                );

                final jieQiStyle = TextStyle(
                  fontSize: 18.0 * s,
                  height: .8,
                  fontWeight: FontWeight.w800,
                  color: sealRed.withAlpha(210),
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final heavenGodStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairCharStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairGodStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final ganColW = 20.0 * s;

                final footerStyle = TextStyle(
                  fontSize: 14.0 * s,
                  height: 1.0,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final header = Padding(
                  padding: EdgeInsets.fromLTRB(8.0 * s, 8.0 * s, 8.0 * s, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${date.day}', style: dateStyle),
                          if (isToday) ...[
                            SizedBox(width: 6.0 * s),
                            Container(
                              width: 6.0 * s,
                              height: 6.0 * s,
                              margin: EdgeInsets.only(top: 4.0 * s),
                              decoration: BoxDecoration(
                                color: sealRed,
                                borderRadius: BorderRadius.circular(2.0 * s),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (jieQi.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.0 * s),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 8.0 * s,
                                height: 8.0 * s,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sealRed.withAlpha(190),
                                    // border: Border.all(
                                    //   color: ink.withOpacity(0.55),
                                    //   width: 1.2 * s,
                                    // ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.0 * s),
                              Text(
                                jieQi,
                                style: jieQiStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );

                final main = Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      10.0 * s,
                      5.0 * s,
                      10.0 * s,
                      5.0 * s,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(4.0 * s, -4.0 * s),
                              child: _vertical('$ganText$zhiText', pillarStyle),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  // color: Colors.black.withOpacity(0.10),
                                  color: sealRed,
                                  width: 1.0 * s,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(left: 10.0 * s),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: ganColW,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: ganColW,
                                          height: ganColW,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: sealRed,
                                            // color: Colors.black.withOpacity(
                                            //   0.10,
                                            // ),
                                            borderRadius: BorderRadius.circular(
                                              6.0 * s,
                                            ),
                                          ),
                                          child: Text(
                                            '干',
                                            style: pairCharStyle.copyWith(
                                              color: Colors.white,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.0 * s),
                                    Flexible(
                                      child: Text(
                                        tenGodName,
                                        style: heavenGodStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0 * s),
                                for (final it in hidden)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.0 * s),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: ganColW,
                                          child: Text(
                                            it.gan,
                                            style: pairCharStyle,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 12.0 * s),
                                        Flexible(
                                          child: Text(
                                            it.tenGod,
                                            style: pairGodStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                final footer = Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 32.0 * s),
                  padding: EdgeInsets.symmetric(vertical: 7.0 * s),
                  decoration: BoxDecoration(
                    color: isLunarHighlight
                        ? sealRed.withOpacity(0.08)
                        : Colors.black.withOpacity(0.03),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                        width: 1.0 * s,
                      ),
                    ),
                  ),
                  child: Text(
                    lunarText,
                    style: footerStyle.copyWith(
                      color: isLunarHighlight ? sealRed : null,
                      fontWeight: isLunarHighlight ? FontWeight.w900 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );

                final card = DecoratedBox(
                  decoration: BoxDecoration(
                    color: paper,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: ink, width: borderW),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        offset: Offset(4.0 * s, 4.0 * s),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(children: [header, main, footer]),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Container(
                              width: 6.0 * s,
                              height: 6.0 * s,
                              decoration: BoxDecoration(
                                color: sealRed,
                                borderRadius: BorderRadius.circular(2.0 * s),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(radius),
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return _InkTheme.sealWash(26);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.white.withAlpha(50);
                        }
                        return null;
                      }),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isHovered
                                ? const Color(0xFFF2EFE5)
                                : Colors.transparent,
                          ),
                          child: card,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class LiuGanZhiMiniCell extends StatelessWidget {
  final String label;
  final String? timeRangeLabel;
  final Color? timeRangeColor;
  final String? jieQiLabel;
  final JiaZi jiaZi;
  final TianGan dayMaster;

  const LiuGanZhiMiniCell({
    required this.label,
    this.timeRangeLabel,
    this.timeRangeColor,
    this.jieQiLabel,
    required this.jiaZi,
    required this.dayMaster,
  });

  Widget _vertical(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFFDFaf5);
    const ink = Color(0xFF1A1A1A);
    const cinnabar = Color(0xFFC0392B);
    const watermark = Color.fromRGBO(0, 0, 0, 0.06);
    const goldLine = Color.fromRGBO(170, 148, 96, 0.20);

    final range = (timeRangeLabel ?? '').trim();
    final jieQiText = (jieQiLabel ?? '').trim();

    const shichenAlias = {
      '子': '夜半',
      '丑': '鸡鸣',
      '寅': '平旦',
      '卯': '日出',
      '辰': '食时',
      '巳': '隅中',
      '午': '日中',
      '未': '日昳',
      '申': '晡时',
      '酉': '日入',
      '戌': '黄昏',
      '亥': '人定',
    };

    final heavenGod = jiaZi.tianGan.getTenGods(dayMaster).name;
    final hidden = jiaZi.diZhi.cangGan;

    return LayoutBuilder(
      builder: (context, c) {
        final s =
            ((c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) / 160.0)
                .clamp(0.35, 2.0);

        final radius = 24.0 * s;

        final headerStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          color: timeRangeColor ?? ink.withOpacity(0.6),
          fontWeight: FontWeight.w700,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final pillarStyle = TextStyle(
          fontSize: 36.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0 * s,
          color: ink,
          fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
        );

        final hGodStyle = TextStyle(
          fontSize: 20.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: cinnabar,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final rowStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: ink,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final rowGodStyle = rowStyle.copyWith(
          color: cinnabar,
          fontWeight: FontWeight.w900,
        );

        final watermarkStyle = TextStyle(
          fontSize: 130.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: watermark,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final footerTextStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: ink.withOpacity(0.5),
          letterSpacing: 1.0 * s,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1.0 * s,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -25.0 * s,
                  bottom: -40.0 * s,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.38,
                      child: Text(label, style: watermarkStyle),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          range,
                          style: headerStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 6.0 * s),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(width: 6.0 * s),
                            Expanded(
                              flex: 9,
                              child: Center(
                                child: _vertical(jiaZi.name, pillarStyle),
                              ),
                            ),
                            SizedBox(width: 10.0 * s),
                            Container(width: 1.5 * s, color: goldLine),
                            SizedBox(width: 8.0 * s),
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    heavenGod,
                                    style: hGodStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.0 * s),
                                  for (final g in hidden)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.0 * s),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 14.0 * s,
                                            child: Text(
                                              g.value,
                                              style: rowStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: 4.0 * s),
                                          Flexible(
                                            child: Text(
                                              g.getTenGods(dayMaster).name,
                                              style: rowGodStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.0 * s),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: jieQiText.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0 * s,
                                  vertical: 2.0 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: cinnabar,
                                  borderRadius: BorderRadius.circular(10.0 * s),
                                ),
                                child: Text(
                                  jieQiText,
                                  style: footerTextStyle.copyWith(
                                    color: Colors.white.withOpacity(0.95),
                                    letterSpacing: 0,
                                  ),
                                ),
                              )
                            : Text(
                                '${label}时 · ${shichenAlias[label] ?? ''}',
                                style: footerTextStyle,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    const step = 18.0;

    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        final xi = x.toInt();
        final yi = y.toInt();
        final n = (xi * 37 + yi * 17) % 19;
        final a = 6 + (n % 9);
        p.color = _InkTheme.ink.withAlpha(a);
        final r = (n % 3 == 0) ? 0.7 : 0.5;
        final dx = ((n % 5) - 2) * 0.6;
        final dy = (((n * 3) % 5) - 2) * 0.6;
        canvas.drawCircle(Offset(x + dx, y + dy), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StampIndicator extends Decoration {
  final double stampWidth;
  final double stampHeight;
  final double rotation;

  const _StampIndicator({
    required this.stampWidth,
    required this.stampHeight,
    required this.rotation,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _StampIndicatorPainter(
      stampWidth: stampWidth,
      stampHeight: stampHeight,
      rotation: rotation,
    );
  }
}

class _StampIndicatorPainter extends BoxPainter {
  final double stampWidth;
  final double stampHeight;
  final double rotation;

  _StampIndicatorPainter({
    required this.stampWidth,
    required this.stampHeight,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final tabRect = offset & size;
    final center = Offset(
      tabRect.center.dx,
      tabRect.bottom - (stampHeight / 2) - 4,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: stampWidth.clamp(0.0, tabRect.width),
      height: stampHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    final shadow = Paint()..color = _InkTheme.ink.withAlpha(18);
    canvas.drawRRect(rrect.shift(const Offset(0.6, 1.1)), shadow);

    final fill = Paint()..color = _InkTheme.seal.withAlpha(76);
    final stroke = Paint()
      ..color = _InkTheme.seal.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);

    final dot = Paint()..color = _InkTheme.seal.withAlpha(95);
    for (var i = -2; i <= 2; i++) {
      final x = rect.left + (rect.width / 5) * (i + 2.5);
      canvas.drawCircle(Offset(x, rect.top + 1.3), 0.7, dot);
      canvas.drawCircle(Offset(x, rect.bottom - 1.3), 0.7, dot);
    }
    canvas.restore();
  }
}

class _InkScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class _DoubleInkBorder extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const _DoubleInkBorder({
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _InkTheme.line(70), width: 0.6),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _InkTheme.line(55), width: 0.6),
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class _InlineDayDetailPanel extends StatelessWidget {
  final DateTime date;
  final bool isPhone;
  final VoidCallback onClose;

  const _InlineDayDetailPanel({
    required this.date,
    required this.isPhone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final weekday = weekdays[(date.weekday - DateTime.monday) % 7];
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final title = '$y-$m-$d · 周$weekday';

    return _DoubleInkBorder(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _InkTheme.paper,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    CustomPaint(painter: _PaperTexturePainter()),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _InkTheme.paperHi.withAlpha(170),
                            Colors.transparent,
                            _InkTheme.ink.withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, child: _Corner()),
            const Positioned(top: 0, right: 0, child: _Corner(flipX: true)),
            const Positioned(bottom: 0, left: 0, child: _Corner(flipY: true)),
            const Positioned(
              bottom: 0,
              right: 0,
              child: _Corner(flipX: true, flipY: true),
            ),
            Column(
              children: [
                Container(
                  height: isPhone ? 52 : 56,
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: _InkTheme.line(70), width: 0.6),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _InkTheme.paperHi.withAlpha(210),
                        _InkTheme.paper,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _InkTheme.sealWash(55),
                          border: Border.all(
                            color: _InkTheme.seal.withAlpha(120),
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '刻',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.0,
                              color: _InkTheme.seal.withAlpha(220),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              color: _InkTheme.ink.withAlpha(230),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '刻/分择时',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              color: _InkTheme.ink.withAlpha(140),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _InkIconButton(
                        tooltip: '收起',
                        onTap: onClose,
                        icon: Icons.keyboard_arrow_up_rounded,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _DayDetailContent(date: date, isPhone: isPhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InkIconButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final IconData icon;

  const _InkIconButton({
    required this.tooltip,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return _InkTheme.wash(24);
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withAlpha(90);
          }
          return null;
        }),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: _InkTheme.line(60), width: 0.6),
              color: Colors.white.withAlpha(160),
              borderRadius: radius,
            ),
            child: Icon(icon, size: 18, color: _InkTheme.ink.withAlpha(190)),
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool flipX;
  final bool flipY;

  const _Corner({this.flipX = false, this.flipY = false});

  @override
  Widget build(BuildContext context) {
    final base = SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _CornerPainter()),
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(
        flipX ? -1.0 : 1.0,
        flipY ? -1.0 : 1.0,
        1.0,
      ),
      child: base,
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _InkTheme.line(90)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, 0), Offset(w, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, h), p);
    canvas.drawLine(Offset(0, h * 0.55), Offset(w * 0.55, h), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DayDetailContent extends StatefulWidget {
  final DateTime date;
  final bool isPhone;

  const _DayDetailContent({required this.date, required this.isPhone});

  @override
  State<_DayDetailContent> createState() => _DayDetailContentState();
}

class _DayDetailContentState extends State<_DayDetailContent> {
  bool _minuteMode = false;

  late final List<int?> _selectedQuarterByRow;
  late final List<int?> _selectedMinuteByRow;

  final List<String> _shiChen = const [
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥',
  ];

  @override
  void initState() {
    super.initState();
    _selectedQuarterByRow = List<int?>.filled(_shiChen.length, null);
    _selectedMinuteByRow = List<int?>.filled(_shiChen.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.isPhone;
    final leftW = isPhone ? 54.0 : 72.0;

    return Padding(
      padding: EdgeInsets.all(isPhone ? 12 : 16),
      child: Column(
        children: [
          _InkModeSwitch(
            isPhone: isPhone,
            minuteMode: _minuteMode,
            onChange: (v) => setState(() => _minuteMode = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _DoubleInkBorder(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(160),
                      Colors.white.withAlpha(110),
                      _InkTheme.washHi(10),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    _InkGridHeader(leftW: leftW, minuteMode: _minuteMode),
                    Expanded(
                      child: Row(
                        children: [
                          _InkShiChenColumn(
                            width: leftW,
                            isPhone: isPhone,
                            labels: _shiChen,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: _InkTheme.line(70),
                                    width: 0.6,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (var i = 0; i < _shiChen.length; i++) ...[
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isPhone ? 10 : 14,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _minuteMode
                                              ? _MinuteRuler(
                                                  isPhone: isPhone,
                                                  selectedMinute:
                                                      _selectedMinuteByRow[i],
                                                  onSelect: (m) {
                                                    setState(() {
                                                      _selectedMinuteByRow[i] =
                                                          m;
                                                    });
                                                  },
                                                )
                                              : _QuarterSelectorRow(
                                                  isPhone: isPhone,
                                                  selectedQuarter:
                                                      _selectedQuarterByRow[i],
                                                  onSelect: (q) {
                                                    setState(() {
                                                      _selectedQuarterByRow[i] =
                                                          q;
                                                    });
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                    if (i != _shiChen.length - 1)
                                      Divider(
                                        height: 1,
                                        color: _InkTheme.line(70),
                                      ),
                                  ],
                                ],
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
          ),
        ],
      ),
    );
  }
}

class _InkModeSwitch extends StatelessWidget {
  final bool isPhone;
  final bool minuteMode;
  final ValueChanged<bool> onChange;

  const _InkModeSwitch({
    required this.isPhone,
    required this.minuteMode,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
      height: 1.0,
      color: _InkTheme.ink.withAlpha(210),
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        SegmentedButton<bool>(
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              label: Text('刻', style: textStyle),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text('分', style: textStyle),
            ),
          ],
          selected: <bool>{minuteMode},
          onSelectionChanged: (s) => onChange(s.first),
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: 8),
            ),
            side: WidgetStateProperty.all(
              BorderSide(color: _InkTheme.line(70), width: 0.6),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _InkTheme.sealWash(40);
              }
              return Colors.white.withAlpha(150);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return _InkTheme.sealWash(26);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withAlpha(70);
              }
              return null;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            minuteMode ? '选择分钟刻度（5 分钟步进）' : '选择刻度（每刻 15 分钟）',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.0,
              color: _InkTheme.ink.withAlpha(140),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InkGridHeader extends StatelessWidget {
  final double leftW;
  final bool minuteMode;

  const _InkGridHeader({required this.leftW, required this.minuteMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _InkTheme.line(70), width: 0.6),
        ),
        color: Colors.white.withAlpha(120),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: leftW,
            child: Center(
              child: Text(
                '时辰',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  color: _InkTheme.ink.withAlpha(170),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(width: 1, color: _InkTheme.line(70)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  minuteMode ? '分钟' : '刻度',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.0,
                    color: _InkTheme.ink.withAlpha(170),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkShiChenColumn extends StatelessWidget {
  final double width;
  final bool isPhone;
  final List<String> labels;

  const _InkShiChenColumn({
    required this.width,
    required this.isPhone,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final box = isPhone ? 30.0 : 40.0;
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(70),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(14),
          ),
        ),
        child: Column(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Expanded(
                child: Center(
                  child: Container(
                    width: box,
                    height: box,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(140),
                      border: Border.all(color: _InkTheme.line(55), width: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: ConstUIResourcesMapper.tianGanTextStyle.copyWith(
                          fontSize: isPhone ? 16 : 18,
                          shadows: const [],
                          height: 1.0,
                          color: _InkTheme.ink.withAlpha(220),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1)
                Divider(height: 1, color: _InkTheme.line(70)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuarterSelectorRow extends StatelessWidget {
  final bool isPhone;
  final int? selectedQuarter;
  final ValueChanged<int> onSelect;

  const _QuarterSelectorRow({
    required this.isPhone,
    required this.selectedQuarter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return LayoutBuilder(
      builder: (context, _) {
        return Row(
          children: [
            for (var i = 0; i < 8; i++) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 2 : 3,
                    vertical: isPhone ? 4 : 6,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: radius,
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return _InkTheme.sealWash(26);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.white.withAlpha(70);
                        }
                        return null;
                      }),
                      onTap: () => onSelect(i),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(
                            color: selectedQuarter == i
                                ? _InkTheme.seal.withAlpha(150)
                                : _InkTheme.line(55),
                            width: selectedQuarter == i ? 1.0 : 0.6,
                          ),
                          color: selectedQuarter == i
                              ? _InkTheme.sealWash(38)
                              : Colors.white.withAlpha(150),
                        ),
                        child: Center(
                          child: Text(
                            '${i * 15}',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              color: selectedQuarter == i
                                  ? _InkTheme.seal.withAlpha(210)
                                  : _InkTheme.ink.withAlpha(170),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MinuteRuler extends StatelessWidget {
  final bool isPhone;
  final int? selectedMinute;
  final ValueChanged<int> onSelect;

  const _MinuteRuler({
    required this.isPhone,
    required this.selectedMinute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final height = isPhone ? 26.0 : 28.0;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return _InkTheme.sealWash(26);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withAlpha(70);
                }
                return null;
              }),
              onTapDown: (d) {
                final x = d.localPosition.dx.clamp(0.0, c.maxWidth);
                final raw = ((x / c.maxWidth) * 60).round();
                final snapped = (raw / 5).round() * 5;
                onSelect(snapped.clamp(0, 60));
              },
              onTap: () {},
              child: Ink(
                decoration: BoxDecoration(
                  border: Border.all(color: _InkTheme.line(70), width: 0.6),
                  color: Colors.white.withAlpha(150),
                  borderRadius: radius,
                ),
                child: CustomPaint(
                  painter: _MinuteRulerPainter(selectedMinute: selectedMinute),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MinuteRulerPainter extends CustomPainter {
  final int? selectedMinute;

  const _MinuteRulerPainter({required this.selectedMinute});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _InkTheme.line(90)
      ..strokeWidth = 1;

    final w = size.width;
    final h = size.height;

    for (var m = 0; m <= 60; m += 5) {
      final x = w * (m / 60.0);
      final isQuarter = (m % 15 == 0);
      final len = isQuarter ? h * 0.8 : h * 0.45;
      canvas.drawLine(Offset(x, h), Offset(x, h - len), p);
    }

    final sel = selectedMinute;
    if (sel != null) {
      final x = w * (sel / 60.0);
      final marker = Paint()
        ..color = _InkTheme.seal.withAlpha(180)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      final fill = Paint()
        ..color = _InkTheme.sealWash(48)
        ..style = PaintingStyle.fill;

      final center = Offset(x, h * 0.35);
      canvas.drawCircle(center, 6.0, fill);
      canvas.drawCircle(center, 6.0, marker);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
