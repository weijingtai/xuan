import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:flutter/material.dart';
import 'calender_panel.dart';
import 'yun_liu_table_common.dart';
import 'yun_liu_table_month_widget.dart';
import 'yun_liu_table_year_header_cell_widget.dart';
import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class YearGrid extends StatefulWidget {
  final int daYunIndex;
  final double cellW;
  final double cellH;
  final double headerH;
  final bool isPhone;
  final ScrollController scrollController;
  final int? expandedMonth;
  final int? expandedYear;
  final void Function(int month, int year) onExpand;
  final VoidCallback onCollapse;
  final Map<String, DateTime> selectedDateByCalendar;
  final void Function(String calendarId, DateTime? date) onSelectDate;
  final ZiShiStrategy shiChenZiStrategy;
  final ValueChanged<ZiShiStrategy> onShiChenZiStrategyChanged;

  const YearGrid({
    super.key,
    required this.daYunIndex,
    required this.cellW,
    required this.cellH,
    required this.headerH,
    required this.isPhone,
    required this.scrollController,
    required this.expandedMonth,
    required this.expandedYear,
    required this.onExpand,
    required this.onCollapse,
    required this.selectedDateByCalendar,
    required this.onSelectDate,
    required this.shiChenZiStrategy,
    required this.onShiChenZiStrategyChanged,
  });

  @override
  State<YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<YearGrid> {
  final Map<String, GlobalKey> _calendarKeys = {};

  GlobalKey _calendarKey(int daYunIndex, int monthIndex, int yearIndex) {
    final k = '$daYunIndex-$monthIndex-$yearIndex';
    return _calendarKeys.putIfAbsent(k, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    final yearsWidth = YunLiuHelper.yearCount * widget.cellW;

    return ScrollConfiguration(
      behavior: InkScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: widget.scrollController,
        child: SizedBox(
          width: yearsWidth,
          child: Column(
            children: [
              SizedBox(
                height: widget.headerH,
                child: Row(
                  children: [
                    for (var i = 0; i < YunLiuHelper.yearCount; i++)
                      SizedBox(
                        width: widget.cellW,
                        height: widget.headerH,
                        child: DaYunHeaderCell(
                          year: YunLiuHelper.yearAt(widget.daYunIndex, i),
                          age:
                              28 +
                              (YunLiuHelper.yearAt(widget.daYunIndex, i) -
                                  YunLiuHelper.yearStartBase),
                          yearGanZhi:
                              JiaZi.listAll[(YunLiuHelper.yearAt(
                                        widget.daYunIndex,
                                        i,
                                      ) -
                                      1984) %
                                  60],
                          ganGod:
                              EnumTenGods.values[(widget.daYunIndex + i) %
                                  EnumTenGods.values.length],
                          hiddenGans: YunLiuHelper.hiddenGansForSeed(
                            (widget.daYunIndex * 37) + (i * 11),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              for (var m = 0; m < YunLiuHelper.months.length; m++) ...[
                Row(
                  children: [
                    for (var y = 0; y < YunLiuHelper.yearCount; y++)
                      _buildGanZhiCell(
                        daYunIndex: widget.daYunIndex,
                        yearIndex: y,
                        monthIndex: m,
                        width: widget.cellW,
                        height: widget.cellH,
                        isPhone: widget.isPhone,
                      ),
                  ],
                ),
                _buildExpandedCalendarRow(
                  daYunIndex: widget.daYunIndex,
                  monthIndex: m,
                  yearsWidth: yearsWidth,
                  isPhone: widget.isPhone,
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
        widget.expandedMonth == monthIndex && widget.expandedYear == yearIndex;

    final year = YunLiuHelper.yearAt(daYunIndex, yearIndex);
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
            if (isExpanded) {
              widget.onSelectDate(
                YunLiuHelper.calendarId(daYunIndex, monthIndex, yearIndex),
                null,
              );
              widget.onCollapse();
            } else {
              widget.onExpand(monthIndex, yearIndex);
            }

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
                bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
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
    final expanded = widget.expandedMonth == monthIndex;
    final yearIndex = widget.expandedYear;
    final panelW = YunLiuHelper.calendarPanelWidth(
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
                  height: YunLiuHelper.calendarExpandedRowHeight(
                    yearsWidth: yearsWidth,
                    isPhone: isPhone,
                    year: YunLiuHelper.yearAt(daYunIndex, yearIndex),
                    month: monthIndex + 1,
                    showDetail: widget.selectedDateByCalendar.containsKey(
                      YunLiuHelper.calendarId(
                        daYunIndex,
                        monthIndex,
                        yearIndex,
                      ),
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
                        child: CalendarPanel(
                          calendarId: YunLiuHelper.calendarId(
                            daYunIndex,
                            monthIndex,
                            yearIndex,
                          ),
                          year: YunLiuHelper.yearAt(daYunIndex, yearIndex),
                          month: monthIndex + 1,
                          isPhone: isPhone,
                          selectedDate:
                              widget
                                  .selectedDateByCalendar[YunLiuHelper.calendarId(
                                daYunIndex,
                                monthIndex,
                                yearIndex,
                              )],
                          onSelectDate: (date) {
                            widget.onSelectDate(
                              YunLiuHelper.calendarId(
                                daYunIndex,
                                monthIndex,
                                yearIndex,
                              ),
                              date,
                            );
                          },
                          shiChenZiStrategy: widget.shiChenZiStrategy,
                          onShiChenZiStrategyChanged:
                              widget.onShiChenZiStrategyChanged,
                          onClose: () {
                            widget.onSelectDate(
                              YunLiuHelper.calendarId(
                                daYunIndex,
                                monthIndex,
                                yearIndex,
                              ),
                              null,
                            );
                            widget.onCollapse();
                          },
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
}
