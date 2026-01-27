import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:flutter/material.dart';
import '../themes/ink_theme.dart';
import 'yun_liu_table_common.dart';

class MonthAxis extends StatelessWidget {
  final int daYunIndex;
  final double monthAxisW;
  final double headerH;
  final double cellW;
  final double cellH;
  final bool isPhone;
  final int? expandedMonth;
  final int? expandedYear;
  final Map<String, DateTime> selectedDateByCalendar;

  const MonthAxis({
    super.key,
    required this.daYunIndex,
    required this.monthAxisW,
    required this.headerH,
    required this.cellW,
    required this.cellH,
    required this.isPhone,
    required this.expandedMonth,
    required this.expandedYear,
    required this.selectedDateByCalendar,
  });

  @override
  Widget build(BuildContext context) {
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
                right: BorderSide(color: InkTheme.line(70), width: 0.6),
                bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
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
                right: BorderSide(color: InkTheme.line(70), width: 0.6),
                bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
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
              height: expandedMonth == m && expandedYear != null
                  ? YunLiuHelper.calendarExpandedRowHeight(
                      yearsWidth: YunLiuHelper.yearCount * cellW,
                      isPhone: isPhone,
                      year: YunLiuHelper.yearAt(daYunIndex, expandedYear!),
                      month: m + 1,
                      showDetail: selectedDateByCalendar.containsKey(
                        YunLiuHelper.calendarId(daYunIndex, m, expandedYear!),
                      ),
                    )
                  : 0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: InkTheme.line(70), width: 0.6),
                    bottom: BorderSide(color: InkTheme.line(70), width: 0.6),
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

  Widget _buildVerticalLabel(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }
}
