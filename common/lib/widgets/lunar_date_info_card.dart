
import 'package:common/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/divination_datetime.dart';
import '../themes/gan_zhi_gua_colors.dart';

import '../helpers/solar_lunar_datetime_helper.dart';

class LunarDateInfoCard extends StatelessWidget {
  final DateTimeDetailsBundle bundle;
  final EnumDatetimeType inUsed;
  final bool isHiddenDatetimeType;
  double underlingWidth = 1.0;



  LunarDateInfoCard({
    Key? key,
    required this.bundle,
    required this.inUsed,
    this.isHiddenDatetimeType = false,
  }) : super(key: key);

  Color get mainlyTextThemeColor => AppColors.zodiacZhiColors[chineseDateInfo!.eightChars.month.diZhi]!;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthBranch = chineseDateInfo?.eightChars.month.diZhi;

    final themeData = monthBranch != null
        ? AppThemes.getThemeForDiZhi(monthBranch, isDarkMode ? Brightness.dark : Brightness.light)
        : (isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme);

    return Theme(
      data: themeData,
      child: Builder(builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDateSection(context),
                  const SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).dividerColor,
                  ),
                  const SizedBox(height: 10),
                  _buildSolarTermAndPhenologySection(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  ChineseDateInfo? get chineseDateInfo {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredChineseInfo;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTChineseInfo;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarChineseInfo;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarChineseInfo;
    }
  }

  DateTime? get dateTime {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredDatetime;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTDatetime;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarDatetime;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarDatetime;
    }
  }

  Widget _buildDateSection(BuildContext context) {
    if (dateTime == null || chineseDateInfo == null) {
      return const SizedBox.shrink();
    }
    final eightChars = chineseDateInfo!.eightChars;
    final lunarMonthName = chineseDateInfo!.lunarMonth;
    final lunarDayName = chineseDateInfo!.lunarDay;
    final monthBranchName = eightChars.month.diZhi.asMonthToken.diZhi.name;
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('yyyy年MM月dd日').format(dateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: secondaryTextColor,
                  ),
                ),
                if (!isHiddenDatetimeType)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inUsed.name,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(dateTime!),
                  style: const TextStyle(
                    fontFamily: 'DIN Alternate',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${eightChars.year.name}年 ${chineseDateInfo!.isLeapMonth ? "[闰]":""}${SolarLunarDateTimeHelper.intMonth2ChineseMap[lunarMonthName]}月${SolarLunarDateTimeHelper.intDay2ChineseMap[lunarDayName]}日 ${eightChars.time.diZhi.name}时',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${SolarLunarDateTimeHelper.intMonthTo4SeasonsMap[chineseDateInfo!.lunarMonth]}',
              style: TextStyle(
                fontSize: 14,
                color: mainlyTextThemeColor,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: '月令',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    monthBranchName,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.1,
                      color: mainlyTextThemeColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSolarTermAndPhenologySection(BuildContext context) {
    if (dateTime == null || chineseDateInfo == null) {
      return const SizedBox.shrink();
    }
    final jieQiInfo = chineseDateInfo!.jieQiInfo;
    final phenology = chineseDateInfo!.phenology;
    final now = dateTime!.millisecondsSinceEpoch;
    final start = jieQiInfo.startAt.millisecondsSinceEpoch;
    final end = jieQiInfo.endAt.millisecondsSinceEpoch;
    final progress = (now - start) / (end - start);
    final secondaryTextColor = Theme.of(context).textTheme.titleMedium?.color;

    final phenologies = Phenology.phenologyList
        .where((p) => p.jieqi == jieQiInfo.jieQi)
        .toList();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: '交节：${DateFormat('yyyy/MM/dd HH:mm:ss').format(jieQiInfo.startAt)}',
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Noto Sans SC',
                          color: secondaryTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${jieQiInfo.jieQi.name} ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: mainlyTextThemeColor,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat('MM/dd').format(jieQiInfo.startAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tooltip(
                    message: '交节：${DateFormat('yyyy/MM/dd HH:mm:ss').format(jieQiInfo.endAt)}',
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Noto Sans SC',
                          color: secondaryTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${jieQiInfo.nextJieQi.name} ',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(text: DateFormat('MM/dd').format(jieQiInfo.endAt)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: mainlyTextThemeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(phenologies.length, (index) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: phenologies[index] == phenology
                            ? mainlyTextThemeColor
                            : Colors.transparent,
                        width: underlingWidth,
                      ),
                    ),
                  ),
                  child: Text(
                    phenologies[index].name,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                if (index < phenologies.length - 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '·',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
