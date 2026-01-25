import 'package:common/enums.dart';
import 'package:common/enums/enum_chinese_12_zodic.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'liu_day_cell_widget.dart';
import 'liu_gan_zhi_mini_cell.dart';
import 'yun_liu_table_month_widget.dart';
import 'yun_liu_table_year_header_cell_widget.dart';
import 'yun_liu_table_common.dart';

import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

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
  GanZhiLineColorMode? _previousGanZhiLineColorMode;

  static Color get _inkBorderColor => InkTheme.line(70);

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
    _previousGanZhiLineColorMode = YunLiuHelper.ganZhiLineColorMode;
    YunLiuHelper.ganZhiLineColorMode = GanZhiLineColorMode.naYin;
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
    if (_previousGanZhiLineColorMode != null) {
      YunLiuHelper.ganZhiLineColorMode = _previousGanZhiLineColorMode!;
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
            color: InkTheme.paper,
            border: Border.all(color: _inkBorderColor, width: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      CustomPaint(painter: PaperTexturePainter()),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              InkTheme.paperHi.withAlpha(160),
                              Colors.transparent,
                              InkTheme.ink.withAlpha(10),
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

    const selectedPaper = InkTheme.paperSoft;
    const unselectedPaper = InkTheme.paperMuted;

    final borderActive = InkTheme.ink;
    final gold = InkTheme.gold;
    final cinnabar = InkTheme.seal;

    final is9 = _yearsPerDaYun == 9;

    final toggleLabelStyle = TextStyle(
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w800,
      color: InkTheme.ink.withAlpha(160),
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
              borderColor: InkTheme.ink.withAlpha(35),
              selectedBorderColor: InkTheme.seal.withAlpha(160),
              fillColor: InkTheme.sealWash(36),
              color: InkTheme.ink.withAlpha(170),
              selectedColor: InkTheme.seal.withAlpha(230),
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
                  color: InkTheme.paperHi.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(alignment: Alignment.centerRight, child: toggle),
                    const SizedBox(height: 10),
                    ScrollConfiguration(
                      behavior: InkScrollBehavior(),
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
                                color: InkTheme.ink,
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
                                color: InkTheme.ink,
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
                                                      : InkTheme.neutralGray,
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
                                                      : InkTheme.neutralGray,
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
      behavior: InkScrollBehavior(),
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
      color: InkTheme.ink.withAlpha(120),
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
                colors: [InkTheme.paperHi.withAlpha(220), InkTheme.paper],
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
                  color: InkTheme.wash(10),
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
    final zebraColor = InkTheme.wash(isPhone ? 6 : 4);

    return ScrollConfiguration(
      behavior: InkScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _yearHorizontalControllers[daYunIndex],
        child: SizedBox(
          width: yearsWidth,
          child: Stack(
            children: [
              Positioned(
                top: headerH,
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  children: [
                    for (var i = 0; i < _yearsPerDaYun; i++)
                      Container(
                        width: cellW,
                        color: i.isEven ? zebraColor : Colors.transparent,
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
                              backgroundColor: i.isEven ? zebraColor : null,
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
                              backgroundColor: y.isEven ? zebraColor : null,
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
    Color? backgroundColor,
    required bool isPhone,
  }) {
    final isExpanded =
        _expandedMonthByDaYun[daYunIndex] == monthIndex &&
        _expandedYearByDaYun[daYunIndex] == yearIndex;

    final year = _yearAt(daYunIndex, yearIndex);
    final seed = (daYunIndex * 97) + (yearIndex * 19) + (monthIndex * 7);

    final jiaZi = JiaZi.listAll[seed % JiaZi.listAll.length];
    final tianGan = jiaZi.tianGan;
    final diZhi = jiaZi.diZhi;
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
                      backgroundColor: backgroundColor,
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
                            color: InkTheme.seal.withAlpha(70),
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
                    child: DoubleInkBorder(
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
                              InkTheme.paperHi.withAlpha(240),
                              Colors.white.withAlpha(150),
                              InkTheme.washHi(10),
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
      color: InkTheme.ink.withAlpha(200),
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
            color: InkTheme.ink.withAlpha(200),
            fontWeight: FontWeight.w800,
          );

          return DoubleInkBorder(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: InkTheme.paper,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.12,
                        child: CustomPaint(painter: PaperTexturePainter()),
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
                                      color: InkTheme.line(60),
                                      width: 0.6,
                                    ),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return YunLiuHelper.getStrategyColor(
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
                                        return YunLiuHelper.getStrategyColor(
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
                                        color: InkTheme.line(60),
                                        width: 0.6,
                                      ),
                                      color: Colors.white.withAlpha(140),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '关闭',
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.0,
                                        color: InkTheme.ink.withAlpha(170),
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
                                timeRangeColor: YunLiuHelper.getStrategyColor(
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
                                    color: InkTheme.sealWash(34),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: InkTheme.seal.withAlpha(140),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    '进入「人生万年历」>>>',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.0,
                                      color: InkTheme.seal.withAlpha(220),
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
                  border: Border.all(color: InkTheme.borderStone, width: 0.6),
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
                            color: InkTheme.line(60),
                            width: 0.6,
                          ),
                          color: Colors.white.withAlpha(140),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '关闭',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.0,
                            color: InkTheme.ink.withAlpha(170),
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
                              color: InkTheme.ink.withAlpha(160),
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
        return InkTheme.elementWood.withAlpha(22);
      case 1:
        return InkTheme.seal.withAlpha(18);
      case 2:
        return InkTheme.elementEarth.withAlpha(18);
      case 3:
        return InkTheme.elementMetal.withAlpha(16);
      default:
        return InkTheme.elementWater.withAlpha(18);
    }
  }

  final Map<String, GlobalKey> _calendarKeys = {};

  GlobalKey _calendarKey(int daYunIndex, int monthIndex, int yearIndex) {
    final k = '$daYunIndex-$monthIndex-$yearIndex';
    return _calendarKeys.putIfAbsent(k, () => GlobalKey());
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

    return DoubleInkBorder(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: InkTheme.paper,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    CustomPaint(painter: PaperTexturePainter()),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            InkTheme.paperHi.withAlpha(170),
                            Colors.transparent,
                            InkTheme.ink.withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, child: Corner()),
            const Positioned(top: 0, right: 0, child: Corner(flipX: true)),
            const Positioned(bottom: 0, left: 0, child: Corner(flipY: true)),
            const Positioned(
              bottom: 0,
              right: 0,
              child: Corner(flipX: true, flipY: true),
            ),
            Column(
              children: [
                Container(
                  height: isPhone ? 52 : 56,
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [InkTheme.paperHi.withAlpha(210), InkTheme.paper],
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
                          color: InkTheme.sealWash(55),
                          border: Border.all(
                            color: InkTheme.seal.withAlpha(120),
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
                              color: InkTheme.seal.withAlpha(220),
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
                              color: InkTheme.ink.withAlpha(230),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '刻/分择时',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              color: InkTheme.ink.withAlpha(140),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkIconButton(
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
            child: DoubleInkBorder(
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
                      InkTheme.washHi(10),
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
                                    color: InkTheme.line(70),
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
                                        color: InkTheme.line(70),
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
      color: InkTheme.ink.withAlpha(210),
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
              BorderSide(color: InkTheme.line(70), width: 0.6),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return InkTheme.sealWash(40);
              }
              return Colors.white.withAlpha(150);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return InkTheme.sealWash(26);
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
              color: InkTheme.ink.withAlpha(140),
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
          bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
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
                  color: InkTheme.ink.withAlpha(170),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(width: 1, color: InkTheme.line(70)),
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
                    color: InkTheme.ink.withAlpha(170),
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
                      border: Border.all(color: InkTheme.line(55), width: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: ConstUIResourcesMapper.tianGanTextStyle.copyWith(
                          fontSize: isPhone ? 16 : 18,
                          shadows: const [],
                          height: 1.0,
                          color: InkTheme.ink.withAlpha(220),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1)
                Divider(height: 1, color: InkTheme.line(70)),
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
                          return InkTheme.sealWash(26);
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
                                ? InkTheme.seal.withAlpha(150)
                                : InkTheme.line(55),
                            width: selectedQuarter == i ? 1.0 : 0.6,
                          ),
                          color: selectedQuarter == i
                              ? InkTheme.sealWash(38)
                              : Colors.white.withAlpha(150),
                        ),
                        child: Center(
                          child: Text(
                            '${i * 15}',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.0,
                              color: selectedQuarter == i
                                  ? InkTheme.seal.withAlpha(210)
                                  : InkTheme.ink.withAlpha(170),
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
                  return InkTheme.sealWash(26);
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
                  border: Border.all(color: InkTheme.line(70), width: 0.6),
                  color: Colors.white.withAlpha(150),
                  borderRadius: radius,
                ),
                child: CustomPaint(
                  painter: MinuteRulerPainter(selectedMinute: selectedMinute),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
