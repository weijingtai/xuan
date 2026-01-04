import 'package:common/widgets/query_time_input_card.dart';
import 'package:common/widgets/responseive_datetime_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../enums/enum_jia_zi.dart';
import '../models/divination_datetime.dart';
import '../models/eight_chars.dart';

class EightCharsSelectionCard extends StatelessWidget {
  bool isSelected = false;
  DivinationDatetimeModel queryDateTime;
  Function() onTap;

  DateFormat timeFormat = DateFormat("HH:mm");
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  Set<int> highLight = {}; // 高亮列表 1~4, 分别为年、月、日、时“柱”
  Size size;
  EdgeInsets margin;
  EightCharsSelectionCard({
    super.key,
    required this.isSelected,
    required this.queryDateTime,
    required this.onTap,
    required this.timeFormat,
    required this.dateFormat,
    required this.dateTimeFormat,
    required this.highLight,
    required this.size,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return buildEightCharCard(context);
  }

  Widget buildEightCharCard(BuildContext context) {
    // bool isSelected = selectedIndex != null && currentIndex == selectedIndex;
    Color color = Colors.black26;
    if (isSelected) {
      color = Colors.red[300]!;
    }

    // Your existing structure with Material -> Container -> Ink -> InkWell is fine
    // for the ripple effect based on your previous iteration.
    return Material(
      color: Colors.transparent, // Provides Material context for Ink/InkWell
      child: Container(
        // Removed alignment here, InkWell child will handle content alignment/padding
        // padding: const EdgeInsets.all(8), // Padding moved inside InkWell
        margin: margin,
        height: size.height,
        width: size.width,

        child: Ink(
          // Ink widget holds decoration for InkWell ripple to draw correctly
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(4, 4),
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(18), // Match decoration for ripple shape
            splashFactory: InkRipple.splashFactory, // Explicitly use ripple
            child: Padding(
                // Apply padding inside InkWell for content
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // Container inside Padding for alignment
                  alignment: Alignment.topCenter, // Center the Column content
                  child: _buildCardContent(context, isSelected,
                      color), // Build the actual card content
                )),
          ),
        ),
      ),
    );
  }

// Assume _buildCardContent is defined elsewhere as in your original code

  TextStyle titleTextStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Colors.black87,
      fontFamily: "NotoSansSC-Regular");
  TextStyle ganZhiTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black54,
      height: 1,
      fontWeight: FontWeight.w400);
  TextStyle naYinTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.black45,
      height: 1,
      fontWeight: FontWeight.w400);
  TextStyle zhuTitleTextStyle = TextStyle(
      fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w300);
  double eachColumnWidth = 42;
  double eachColumnIntervalWidth = 8;
  Widget _buildJiaZiColumn(JiaZi jiaZi, String columnName, bool isHighLighted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 32,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              columnName,
              style: isHighLighted
                  ? zhuTitleTextStyle.copyWith(color: Colors.teal.shade200)
                  : zhuTitleTextStyle,
            )),
        // SizedBox(height: 4,),
        Container(
            width: eachColumnWidth,
            height: 32,
            alignment: Alignment.center,
            child: Text(jiaZi.tianGan.name,
                style: isHighLighted
                    ? ganZhiTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade300)
                    : ganZhiTextStyle)),
        Container(
            width: eachColumnWidth,
            height: 32,
            alignment: Alignment.center,
            child: Text(jiaZi.diZhi.name,
                style: isHighLighted
                    ? ganZhiTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade300)
                    : ganZhiTextStyle)),
        Container(
            width: eachColumnWidth,
            height: 16,
            alignment: Alignment.center,
            child: Text(jiaZi.naYin.name,
                style: isHighLighted
                    ? naYinTextStyle.copyWith(color: Colors.teal.shade200)
                    : naYinTextStyle)),
      ],
    );
  }

  EightChars get eightChars => queryDateTime.bazi;
  Widget _buildCardContent(BuildContext context, bool isSelected, Color color) {
    // ... (Your existing Column structure implementing the card's content)
    double eachColumnIntervalWidth = 4;
    // EightChars eightChars = EightChars(year: JiaZi.JIA_ZI,month: JiaZi.YI_CHOU,day: JiaZi.BING_CHEN,time: JiaZi.DING_MAO);
    return Column(
      mainAxisSize: MainAxisSize
          .min, // Prevent column from expanding infinitely if needed
      children: [
        Container(
          // color: Colors.blueAccent.withAlpha(10), // Keep or remove based on design
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32, width: 18),
              _buildTitle(context, queryDateTime.observer.type),
              Container(
                alignment: Alignment.topCenter,
                height: 32,
                child: Container(
                  height: 18,
                  width: 18,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isSelected
                      ? Container(
                          // Show inner circle if selected
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: color, // Use the selected color (red[300])
                          ),
                        )
                      : Container(), // Empty container if not selected
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // SizedBox(height: 4,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              alignment: Alignment.center,
            ),
            Text(
              timeFormat.format(queryDateTime.datetime),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 28),
            ),
            SizedBox(
              width: 42,
              height: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: queryDateTime.isDst
                          ? Text("夏令时",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  height: 1,
                                  fontWeight: FontWeight.bold))
                          : Text("")),
                  Expanded(child: SizedBox())
                ],
              ),
            )
          ],
        ),
        Text(
          dateFormat.format(queryDateTime.datetime),
          style: TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black87, fontSize: 24),
        ),

        Text(
          queryDateTime.observer.timezoneStr,
          style: naYinTextStyle,
        ),

        const SizedBox(
          height: 8,
        ),
        Container(
          height: 100 + 16,
          width: 180 + 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.black12.withAlpha(10),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildJiaZiColumn(eightChars.year, "年", highLight.contains(1)),
              SizedBox(
                width: eachColumnIntervalWidth,
              ),
              _buildJiaZiColumn(eightChars.month, "月", highLight.contains(2)),
              SizedBox(
                width: eachColumnIntervalWidth,
              ),
              _buildJiaZiColumn(eightChars.day, "日", highLight.contains(3)),
              SizedBox(
                width: eachColumnIntervalWidth,
              ),
              _buildJiaZiColumn(eightChars.time, "时", highLight.contains(4)),
              // SizedBox(width: 12+18,)
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
            "${queryDateTime.bazi.year.name}年 ${queryDateTime.lunarMonthStr}月 ${queryDateTime.lunarDayStr} ${eightChars.time.zhi.name}时",
            style: TextStyle(fontSize: 16)), // Example text
        Column(
          children: [
            Text(
              queryDateTime.jieQiInfo.jieQi.name,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              "${queryDateTime.jieQiInfo.jieQi.name}：${dateTimeFormat.format(queryDateTime.jieQiInfo.startAt)}",
              style: naYinTextStyle,
            ),
            Text(
              "${queryDateTime.jieQiInfo.nextJieQi.name}：${dateTimeFormat.format(queryDateTime.jieQiInfo.endAt)}",
              style: naYinTextStyle,
            )
          ],
        )
      ],
    );
  }

  Widget _buildTitle(BuildContext context, EnumDatetimeType type) {
    return Column(
      children: [
        if (EnumDatetimeType.standard == type) _buildStandardTitle(context),
        // Text(cardTitle, style: TextStyle(color:Colors.black87,fontSize: 24,height: 1)),
        if (EnumDatetimeType.removeDST == type) _buildRemoveDSTTitle(context),
        if (EnumDatetimeType.meanSolar == type) _buildMeanSolarTitle(context),
        if (EnumDatetimeType.trueSolar == type) _buildTrueSolarTitle(context),

        // if (EnumDatetimeType.)
        queryDateTime.observer.isManualCalibration
            ? Text("<手动校准经纬纬度>",
                style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.bold))
            : Text("<行政划分中心>",
                style:
                    TextStyle(color: Colors.black26, fontSize: 14, height: 1)),
      ],
    );
  }

  Widget _buildTrueSolarTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 4,
        ),
        Text(cardTitle, style: titleTextStyle),
        Column(
          children: [
            Tooltip(
              message: "“真太阳时=平太阳时+真平太阳时差”",
              child: InkWell(
                onTap: () {
                  helpTooltipTapped(context, EnumDatetimeType.trueSolar);
                },
                child: const Icon(Icons.help, size: 12, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        )
      ],
    );
  }

  Widget _buildMeanSolarTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 4,
        ),
        Text(cardTitle, style: titleTextStyle),
        Column(
          children: [
            Tooltip(
              message: "根据出生地经度进一步精确计算时间",
              child: InkWell(
                onTap: () {
                  helpTooltipTapped(context, EnumDatetimeType.meanSolar);
                },
                child: const Icon(Icons.help, size: 12, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        )
      ],
    );
  }

  Widget _buildRemoveDSTTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 4,
        ),
        Text(cardTitle, style: titleTextStyle),
        Column(
          children: [
            Tooltip(
              message: "将夏令时见调回原本时间，通常为减慢一小时",
              child: InkWell(
                onTap: () {
                  helpTooltipTapped(context, EnumDatetimeType.standard);
                },
                child: const Icon(Icons.help, size: 12, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        )
      ],
    );
  }

  Widget _buildStandardTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 4,
        ),
        Text(cardTitle, style: titleTextStyle),
        Column(
          children: [
            Tooltip(
              message:
                  "标准时间是指一个国家或地区统一采用的基于时区划分的本地时间，通常以格林尼治时间（GMT）或协调世界时（UTC）为基准。\n如：北京时间(UTC+8,东八区)",
              child: InkWell(
                onTap: () {
                  helpTooltipTapped(context, EnumDatetimeType.standard);
                },
                child: const Icon(Icons.help, size: 12, color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        )
      ],
    );
  }

  void helpTooltipTapped(BuildContext context, EnumDatetimeType datetimeType) {
    switch (datetimeType) {
      case EnumDatetimeType.standard:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.standard]!);
        break;
      case EnumDatetimeType.removeDST:
        throw UnimplementedError();
      case EnumDatetimeType.meanSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.meanSolar]!);
        break;
      case EnumDatetimeType.trueSolar:
        showEnhancedDialog(
            context,
            QueryDateTimeHeplperModel
                .datetimeHelperMapper[EnumDatetimeType.trueSolar]!);
        break;
      default:
        throw UnimplementedError();
    }
  }

  String get cardTitle {
    switch (queryDateTime.observer.type) {
      case EnumDatetimeType.removeDST:
        return "无夏令时";
      case EnumDatetimeType.meanSolar:
        return "平太阳时";
      case EnumDatetimeType.trueSolar:
        return "真太阳时";
      default:
        return "钟表时间";
    }
  }
}
