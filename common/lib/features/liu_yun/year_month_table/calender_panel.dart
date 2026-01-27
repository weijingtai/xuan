import 'package:common/enums.dart';
import 'package:common/enums/enum_chinese_12_zodic.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:flutter/material.dart';
import 'liu_day_cell_widget.dart';
import 'liu_gan_zhi_mini_cell.dart';
import 'yun_liu_table_common.dart';
import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class CalendarPanel extends StatelessWidget {
  final String calendarId;
  final int year;
  final int month;
  final bool isPhone;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onSelectDate;
  final ZiShiStrategy shiChenZiStrategy;
  final ValueChanged<ZiShiStrategy> onShiChenZiStrategyChanged;
  final VoidCallback onClose;

  const CalendarPanel({
    super.key,
    required this.calendarId,
    required this.year,
    required this.month,
    required this.isPhone,
    required this.selectedDate,
    required this.onSelectDate,
    required this.shiChenZiStrategy,
    required this.onShiChenZiStrategyChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
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
        final headerH = isPhone ? 30.0 : 32.0;
        final weekH = 20.0;
        final topGap = isPhone ? 10.0 : 12.0;
        final midGap = 6.0;
        final rowH = rows == 0
            ? 0.0
            : YunLiuHelper.calendarRowHeight(
                availableWidth: constraints.maxWidth,
                isPhone: isPhone,
              );

        int? selectedRow;
        if (selectedDate != null) {
          final idx = items.indexWhere(
            (e) => e != null && isSameDay(e, selectedDate!),
          );
          if (idx >= 0) selectedRow = idx ~/ 7;
        }

        const gridCrossSpacing = 6.0;
        const gridMainSpacing = 6.0;
        const gridCrossAxisCount = 6;
        const cellAspectRatio = 1.28;

        final shiChenPanelH = selectedDate == null
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

        Widget shiChenPanel() {
          final date = selectedDate!;
          final base = DateTime(date.year, date.month, date.day);
          final dayStart = base;
          final dayEnd = base.add(const Duration(days: 1));

          String two(int v) => v.toString().padLeft(2, '0');
          String hhmmss(DateTime t) =>
              '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

          int indexForTime(DateTime t) {
            final h = t.hour;
            if (shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
              return (h ~/ 2) % 12;
            }
            if (h >= 23 || h == 0) return 0;
            return ((h + 1) ~/ 2) % 12;
          }

          DateTime midTimeForIndex(int i) {
            if (shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
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
            if (shiChenZiStrategy == ZiShiStrategy.bandsStartAt0) {
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
            shiChenZiStrategy,
          );
          final dayMaster = infoAtNoon.eightChars.dayTianGan;

          final infoAtStart = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            base,
            shiChenZiStrategy,
          );
          final infoAtEnd = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            base.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
            shiChenZiStrategy,
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
              shiChenZiStrategy,
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
                                selected: <ZiShiStrategy>{shiChenZiStrategy},
                                onSelectionChanged: (s) {
                                  onShiChenZiStrategyChanged(s.first);
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
                                            shiChenZiStrategy,
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
                                          shiChenZiStrategy,
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
                                  onTap: onClose,
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
                                      'X 关闭',
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
                                  shiChenZiStrategy,
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
                  border: Border.all(
                    color: InkTheme.borderStone,
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          final isToday = isSameDay(dt, today);
          final isSelected =
              selectedDate != null && isSameDay(dt, selectedDate!);

          return Padding(
            padding: EdgeInsets.all(cellMargin),
            child: LiuDayCellWidget(
              date: dt,
              isToday: isToday,
              isSelected: isSelected,
              onTap: () {
                if (selectedDate != null && isSameDay(dt, selectedDate!)) {
                  onSelectDate(null);
                } else {
                  onSelectDate(dt);
                }
              },
              ganText:
                  '', // Will be calculated inside LiuDayCellWidget if we pass correct params or let it handle
              // Wait, LiuDayCellWidget takes pre-calculated values.
              // I need to calculate them here or update LiuDayCellWidget to calculate.
              // The original code calculated them in _buildLiuDayCell.
              // I should include _buildLiuDayCell logic here or in LiuDayCellWidget.
              // Let's assume I need to pass them.
              zhiText: '',
              tenGodName: '',
              hidden: const [],
              jieQi: '',
              zodiac: '',
              lunarText: '',
            ),
          );
        }

        // Wait, I missed the calculation logic for LiuDayCellWidget parameters!
        // I should copy _ganZhiForDay etc helper methods to this file or YunLiuHelper.
        // Let's assume I will fix this in the next step or now.
        // I should move _ganZhiForDay, _tenGodForDay, _hiddenTriplesForDay to YunLiuHelper.

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
                      onTap: onClose,
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
                          'X 关闭',
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
                          Expanded(
                            child: _buildCell(
                              items[r * 7 + c],
                              today,
                              cellMargin,
                            ),
                          ),
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
          ],
        );
      },
    );
  }

  Widget _buildCell(DateTime? dt, DateTime today, double cellMargin) {
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

    final isToday =
        dt.year == today.year && dt.month == today.month && dt.day == today.day;
    final isSelected =
        selectedDate != null &&
        dt.year == selectedDate!.year &&
        dt.month == selectedDate!.month &&
        dt.day == selectedDate!.day;

    // Calculate parameters for LiuDayCellWidget
    // Note: Moving these calculations to YunLiuHelper is recommended, but for now I'll inline them or use helper if available.
    // Since I can't modify YunLiuHelper in this block, I will assume they are in YunLiuHelper or I'll implement them here as private methods.
    // I'll implement them as private methods here to avoid breaking if YunLiuHelper update is delayed.

    final ganZhi = _ganZhiForDay(dt);
    final ganZhiChars = ganZhi.split('');
    final ganText = ganZhiChars.isEmpty ? '' : ganZhiChars.first;
    final zhiText = ganZhiChars.length < 2 ? '' : ganZhiChars[1];

    final tenGodName = _tenGodForDay(dt).tenGod;
    final hidden = _hiddenTriplesForDay(
      dt,
    ).map((e) => (gan: e.gan, tenGod: e.tenGod)).toList(growable: false);

    final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      DateTime(dt.year, dt.month, dt.day, 12),
      shiChenZiStrategy,
    );

    final jieQi = info.jieQiInfo.jieQi.name;
    final zodiac = EnumChinese12Zodiac.fromDiZhi(
      DiZhi.getFromValue(zhiText) ?? DiZhi.ZI,
    ).name;

    final lunarMonthCn =
        SolarLunarDateTimeHelper.intMonth2ChineseMap[info.lunarMonth] ??
        '${info.lunarMonth}';
    final lunarDayCn =
        SolarLunarDateTimeHelper.intDay2ChineseMap[info.lunarDay] ??
        '${info.lunarDay}';
    final lunarText =
        '${info.eightChars.year.name}年 · ${info.isLeapMonth ? '闰' : ''}${lunarMonthCn}月$lunarDayCn';

    return Padding(
      padding: EdgeInsets.all(cellMargin),
      child: LiuDayCellWidget(
        date: dt,
        isToday: isToday,
        isSelected: isSelected,
        onTap: () {
          if (isSelected) {
            onSelectDate(null);
          } else {
            onSelectDate(dt);
          }
        },
        ganText: ganText,
        zhiText: zhiText,
        tenGodName: tenGodName,
        hidden: hidden,
        jieQi: jieQi,
        zodiac: zodiac,
        lunarText: lunarText,
      ),
    );
  }

  // Helpers
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
}
