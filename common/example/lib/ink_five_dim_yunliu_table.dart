import 'package:common/enums.dart';
import 'package:common/enums/enum_chinese_12_zodic.dart';
import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'yun_liu_table_month_widget.dart';
import 'yun_liu_table_year_header_cell_widget.dart';

class _InkTheme {
  static const paper = Color(0xFFF7F2E8);
  static const paperHi = Color(0xFFFFFBF2);
  static const ink = Color(0xFF2D2D2D);
  static const seal = Color(0xFFB23A2B);

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

  final Map<String, DateTime> _selectedDateByCalendar = <String, DateTime>{};

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

  static const int _yearCount = 10;
  static const int _yearStartBase = 2024;

  int _yearAt(int daYunIndex, int yearIndex) {
    return _yearStartBase + (daYunIndex * _yearCount) + yearIndex;
  }

  JiaZi _jiaZiOfYear(int year) {
    final list = JiaZi.listAll;
    final raw = year - 1984;
    final idx = ((raw % list.length) + list.length) % list.length;
    return list[idx];
  }

  List<({TianGan gan, EnumTenGods hiddenGods})> _hiddenGansForSeed(int seed) {
    final stems = TianGan.listAll;
    final gods = EnumTenGods.values;

    return <({TianGan gan, EnumTenGods hiddenGods})>[
      (
        gan: stems[seed % stems.length],
        hiddenGods: gods[(seed + 1) % gods.length],
      ),
      (
        gan: stems[(seed + 3) % stems.length],
        hiddenGods: gods[(seed + 2) % gods.length],
      ),
      (
        gan: stems[(seed + 6) % stems.length],
        hiddenGods: gods[(seed + 3) % gods.length],
      ),
    ];
  }

  List<({TianGan gan, EnumTenGods tenGod})> _tenGodDetailsForSeed(int seed) {
    final stems = TianGan.listAll;
    final gods = EnumTenGods.values;

    return <({TianGan gan, EnumTenGods tenGod})>[
      (gan: stems[seed % stems.length], tenGod: gods[(seed + 1) % gods.length]),
      (
        gan: stems[(seed + 2) % stems.length],
        tenGod: gods[(seed + 2) % gods.length],
      ),
      (
        gan: stems[(seed + 4) % stems.length],
        tenGod: gods[(seed + 3) % gods.length],
      ),
    ];
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
    final target = cellW * 1.04;
    return target
        .clamp(isPhone ? 72.0 : 84.0, isPhone ? 128.0 : 148.0)
        .toDouble();
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

    final calendarH = headerH + topGap + weekH + midGap + (rows * rowH);
    final detailGap = showDetail ? 12.0 : 0.0;
    final detailH = showDetail ? (isPhone ? 360.0 : 420.0) : 0.0;
    return outerTop +
        outerBottom +
        (innerPad * 2) +
        calendarH +
        detailGap +
        detailH +
        6;
  }

  final List<String> _months = const [
    '正月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '冬月',
    '腊月',
  ];

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

        final cellW = 120.0;
        final cellH = 96.0;
        final headerH = 115.0;
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
    final itemPadding = EdgeInsets.symmetric(
      horizontal: isPhone ? 12 : 14,
      vertical: isPhone ? 10 : 12,
    );

    return AnimatedBuilder(
      animation: _daYunTabController,
      builder: (context, _) {
        final selectedIndex = _daYunTabController.index;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: _inkBorderColor, width: 0.6),
            color: _InkTheme.paperHi.withAlpha(180),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _daYunTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStatePropertyAll(_InkTheme.ink.withAlpha(12)),
            indicator: _StampIndicator(
              stampWidth: isPhone ? 58 : 70,
              stampHeight: 16,
              rotation: -0.06,
            ),
            labelColor: _InkTheme.seal.withAlpha(220),
            unselectedLabelColor: _InkTheme.ink.withAlpha(200),
            labelStyle: TextStyle(
              fontSize: isPhone ? 12 : 14,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isPhone ? 12 : 14,
              height: 1.0,
              fontWeight: FontWeight.w500,
            ),
            tabs: List<Widget>.generate(_daYun.length, (i) {
              final selected = i == selectedIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: itemPadding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? _InkTheme.seal.withAlpha(110)
                        : _inkBorderColor,
                    width: selected ? 0.8 : 0.6,
                  ),
                  color: selected
                      ? _InkTheme.sealWash(34)
                      : Colors.white.withAlpha(120),
                ),
                child: Text(_daYun[i]),
              );
            }),
          ),
        );
      },
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
        for (var m = 0; m < _months.length; m++) ...[
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
            child: _buildVerticalLabel(_months[m], monthStyle),
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
                      yearsWidth: _yearCount * cellW,
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
    final yearsWidth = _yearCount * cellW;

    return ScrollConfiguration(
      behavior: _InkScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _yearHorizontalControllers[daYunIndex],
        child: SizedBox(
          width: yearsWidth,
          child: Column(
            children: [
              SizedBox(
                height: headerH,
                child: Row(
                  children: [
                    for (var i = 0; i < _yearCount; i++)
                      SizedBox(
                        width: cellW,
                        height: headerH,
                        child: DaYunHeaderCell(
                          year: _yearAt(daYunIndex, i),
                          age: 28 + (_yearAt(daYunIndex, i) - _yearStartBase),
                          yearGanZhi: _jiaZiOfYear(_yearAt(daYunIndex, i)),
                          ganGod:
                              EnumTenGods.values[(daYunIndex + i) %
                                  EnumTenGods.values.length],
                          hiddenGans: _hiddenGansForSeed(
                            (daYunIndex * 37) + (i * 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              for (var m = 0; m < _months.length; m++) ...[
                SizedBox(
                  height: cellH,
                  child: Row(
                    children: [
                      for (var y = 0; y < _yearCount; y++)
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
    final tenGodDetails = _tenGodDetailsForSeed(seed);

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
        final gridH = rows * rowH;

        final emptyCellBg = Colors.white.withAlpha(70);
        final cellRadius = BorderRadius.circular(12);
        final selected = _selectedDateByCalendar[calendarId];
        final detailH = isPhone ? 360.0 : 420.0;
        const detailGap = 12.0;

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _InkTheme.line(60), width: 0.6),
                      color: Colors.white.withAlpha(140),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      selected == null ? '点选日期' : '已选日期',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.0,
                        color: _InkTheme.ink.withAlpha(160),
                        fontWeight: FontWeight.w600,
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
            SizedBox(
              height: gridH,
              child: Column(
                children: [
                  for (var r = 0; r < rows; r++)
                    SizedBox(
                      height: rowH,
                      child: Row(
                        children: [
                          for (var c = 0; c < 7; c++)
                            Expanded(child: cell(items[r * 7 + c])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (selected != null) ...[
              const SizedBox(height: detailGap),
              SizedBox(
                height: detailH,
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
  }) {
    final ganZhi = _ganZhiForDay(date);
    final ganZhiChars = ganZhi.split('');
    final ganText = ganZhiChars.isEmpty ? '' : ganZhiChars.first;
    final zhiText = ganZhiChars.length < 2 ? '' : ganZhiChars[1];

    final tenGodShortName = _tenGodForDay(date).shortName;
    final hidden = _hiddenTriplesForDay(
      date,
    ).map((e) => (gan: e.gan, shortName: e.shortName)).toList(growable: false);

    final jieQi = TwentyFourJieQi.fromOrder(
      ((date.year * 37) + (date.month * 11) + date.day) % 24,
    ).name;
    final zodiac = EnumChinese12Zodiac.fromDiZhi(
      DiZhi.getFromValue(zhiText) ?? DiZhi.ZI,
    ).name;

    return LiuDayCellWidget(
      date: date,
      isToday: isToday,
      isSelected: isSelected,
      onTap: onTap,
      ganText: ganText,
      zhiText: zhiText,
      tenGodShortName: tenGodShortName,
      hidden: hidden,
      jieQi: jieQi,
      zodiac: zodiac,
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
  final String tenGodShortName;
  final List<({String gan, String shortName})> hidden;
  final String jieQi;
  final String zodiac;

  const LiuDayCellWidget({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.ganText,
    required this.zhiText,
    required this.tenGodShortName,
    required this.hidden,
    required this.jieQi,
    required this.zodiac,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const sealRed = Color(0xFFB22D2A);
    const paperBase = Color(0xFFF9F6F0);
    const paperHover = Color(0xFFF2EFE5);

    const inkBlack = Color(0xFF2D2D2D);
    const inkLight = Color(0xFFE5E5E5);
    const dayMutedLight = Color(0xFF7A7A7A);
    const hiddenMutedLight = Color(0xFFA9A9A9);
    const borderLight = Color(0xFFD1CDC2);
    const borderDark = Color(0xFF33302C);

    final ink = isDark ? inkLight : inkBlack;
    final dayMuted = isDark ? ink.withAlpha(150) : dayMutedLight;
    final hiddenMuted = isDark ? ink.withAlpha(70) : hiddenMutedLight;
    final seal = isDark ? const Color(0xFFD64545) : sealRed;
    final border = isDark ? borderDark : borderLight;

    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return _InkHoverRegion(
      builder: (context, isHovered) {
        return LayoutBuilder(
          builder: (context, c) {
            final compact = c.maxHeight <= 76 || c.maxWidth <= 56;

            final radius = BorderRadius.circular(compact ? 10 : 12);
            final pad = 6.0;

            final dayFont = (compact ? 11.0 : 12.0) + 6;
            final jieQiFont = (compact ? 9.0 : 10.0) + 4;
            final ganZhiFont = (compact ? 18.0 : 20.0) + 4;
            final tenGodFont = (compact ? 13.0 : 14.0) + 4;
            final hiddenLineGap = compact ? 1.0 : 2.0;
            final watermarkFont = (compact ? 7.0 : 8.0) + 4;

            final ganZhiColW = ganZhiFont + 2;
            final tenGodColumnW = tenGodFont + 10;
            const colGap = 0.0;

            const ganZhiGap = 4.0;

            final dayStyle = TextStyle(
              fontSize: dayFont,
              height: 1.0,
              color: isWeekend ? dayMuted.withAlpha(190) : dayMuted,
              fontWeight: FontWeight.w700,
              fontFamilyFallback: const [
                'ZCOOL XiaoWei',
                'Noto Serif SC',
                'serif',
              ],
            );

            final jieQiStyle = TextStyle(
              fontSize: jieQiFont,
              height: 1.0,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: seal,
              fontFamilyFallback: const ['Noto Serif SC', 'serif'],
            );

            final ganZhiStyle = TextStyle(
              fontSize: ganZhiFont,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: ink,
              fontFamilyFallback: const [
                'ZCOOL XiaoWei',
                'Noto Serif SC',
                'serif',
              ],
            );

            final tenGodStyle = TextStyle(
              fontSize: tenGodFont,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: seal,
              fontFamilyFallback: const [
                'ZCOOL XiaoWei',
                'Noto Serif SC',
                'serif',
              ],
            );

            final hiddenGanStyle = tenGodStyle.copyWith(
              color: hiddenMuted,
              fontWeight: FontWeight.w700,
            );

            final body = Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: isDark ? 0.12 : 0.18,
                      child: CustomPaint(painter: _PaperTexturePainter()),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${date.day}', style: dayStyle),
                                if (isToday) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      color: seal.withAlpha(170),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(jieQi, style: jieQiStyle),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: ganZhiColW),
                                      SizedBox(width: colGap),
                                      SizedBox(
                                        width: ganZhiColW,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            ganText,
                                            style: ganZhiStyle,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: colGap),
                                      SizedBox(
                                        width: tenGodColumnW,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            tenGodShortName,
                                            style: tenGodStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (hidden.isNotEmpty) ...[
                                    SizedBox(height: hiddenLineGap),
                                    for (var i = 0; i < hidden.length; i++) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: ganZhiColW,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                hidden[i].gan,
                                                style: hiddenGanStyle,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: colGap),
                                          SizedBox(
                                            width: ganZhiColW,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: i == 0
                                                  ? Text(
                                                      zhiText,
                                                      style: ganZhiStyle,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                          SizedBox(width: colGap),
                                          SizedBox(
                                            width: tenGodColumnW,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                hidden[i].shortName,
                                                style: tenGodStyle,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (i != hidden.length - 1)
                                        SizedBox(height: hiddenLineGap),
                                    ],
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
                Positioned(
                  bottom: 1,
                  right: 4,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.20,
                      child: Text(
                        zodiac,
                        style: TextStyle(
                          fontSize: watermarkFont,
                          height: 1.0,
                          color: hiddenMuted,
                          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            final content = Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox.square(
                        dimension: compact ? 124 : 124,
                        child: body,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Container(
                        width: compact ? 5 : 6,
                        height: compact ? 5 : 6,
                        decoration: BoxDecoration(
                          color: seal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return _InkTheme.sealWash(26);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.white.withAlpha(isDark ? 18 : 60);
                  }
                  return null;
                }),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: isSelected
                          ? (isDark ? Colors.white.withAlpha(10) : paperHover)
                          : (isDark
                                ? (isHovered
                                      ? const Color(0xFF24231F)
                                      : const Color(0xFF1C1B18))
                                : (isHovered ? paperHover : paperBase)),
                      border: Border.all(
                        color: isSelected ? seal.withAlpha(160) : border,
                        width: isSelected ? 1.0 : 0.6,
                      ),
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          },
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
