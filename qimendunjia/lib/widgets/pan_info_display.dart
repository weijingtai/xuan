import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:common/widgets/four_zhu_eight_char.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:qimendunjia/model/shi_jia_qi_men.dart';
import 'package:qimendunjia/utils/constant_ui_resources_of_qi_men.dart';

import '../enums/enum_arrange_plate_type.dart'; // For text styles if defined there

/// 盘面信息展示Widget。
///
/// 负责显示奇门遁甲盘的核心信息，如排盘时间、农历、节气、
/// 局数、值符、值使、四柱等。
class PanInfoDisplay extends StatelessWidget {
  /// 当前的奇门遁甲盘面数据。如果为null，则不显示大部分盘面信息。
  final ShiJiaQiMen? shiJiaQiMen;

  /// 当前排盘的公历日期和时间。
  final DateTime? panDateTime;

  /// 盘面信息文本样式。
  final TextStyle panInfoTextStyle;

  /// 十二地支文本样式。
  final TextStyle twelveDiZhiTextStyle;

  /// 天干文本样式。
  final TextStyle tianGanTextStyle;

  /// 八门文本样式。
  final TextStyle eightDoorTextStyle;

  /// 九星文本样式。
  final TextStyle nineStarTextStyle;

  /// 盘面类型（转盘/飞盘），用于显示在标题中。
  final PlateType? plateType;

  /// 构建一个盘面信息展示Widget。
  const PanInfoDisplay({
    super.key,
    required this.shiJiaQiMen,
    required this.panDateTime,
    required this.panInfoTextStyle,
    required this.twelveDiZhiTextStyle,
    required this.tianGanTextStyle,
    required this.eightDoorTextStyle,
    required this.nineStarTextStyle,
    required this.plateType,
  });

  Color _getTianGanColor(TianGan tianGan) {
    return ConstResourcesMapper.zodiacGanColors[tianGan]!;
  }

  Widget _buildCenterPanTime(BuildContext context, DateTime? time) {
    if (time == null) {
      return const SizedBox(
          height: 120, width: 220); // Match size of content when available
    }
    Lunar lunar = Lunar.fromDate(time);
    return Card(
        child: Container(
            width: 220,
            height: 120,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                          flex: 3,
                          child: Text("时间：", style: TextStyle(fontSize: 12))),
                      Flexible(
                          flex: 7,
                          child: Text(
                            DateFormat("yyyy/MM/dd HH:mm").format(time),
                            style: TextStyle(
                                fontSize: 12, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                          flex: 3,
                          child: Text("农历：", style: TextStyle(fontSize: 12))),
                      Flexible(
                          flex: 7,
                          child: Text(
                            "${lunar.getYearInGanZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()} ${lunar.getTimeZhi()}时",
                            style: TextStyle(
                                fontSize: 12, color: Colors.blueGrey.shade800),
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 3,
                          child: Text("${lunar.getPrevJieQi().getName()}:",
                              style: const TextStyle(fontSize: 12))),
                      Flexible(
                          flex: 7,
                          child: Text(
                            lunar
                                .getPrevJieQi()
                                .getSolar()
                                .toYmdHms()
                                .replaceAll("-", "/"),
                            style: TextStyle(
                                fontSize: 12, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 3,
                          child: Text("${lunar.getNextJieQi().getName()}:",
                              style: const TextStyle(fontSize: 12))),
                      Flexible(
                          flex: 7,
                          child: Text(
                            lunar
                                .getNextJieQi()
                                .getSolar()
                                .toYmdHms()
                                .replaceAll("-", "/"),
                            style: TextStyle(
                                fontSize: 12, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  )
                ])));
  }

  Widget _buildPanInfo(
      BuildContext context, ShiJiaQiMen pan, PlateType? currentPlateType) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        width: 240,
        height: 160, // Adjusted for consistent layout
        padding: const EdgeInsets.all(4),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                      text:
                          "${currentPlateType?.name ?? pan.plateType.name}·${pan.arrangeType.name} ${pan.yinYangDun.name}${ConstResourcesMapper.chineseNumberMapper[pan.juNumber]}局"),
                ],
                style: panInfoTextStyle,
              )),
              const Divider(height: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      flex: 4,
                      child: Text("旬首：", style: TextStyle(fontSize: 13))),
                  Flexible(
                      flex: 6,
                      child: RichText(
                          text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .black), // Base style for this RichText
                              children: [
                            TextSpan(
                                text: pan.xunShou.name.split("").first,
                                style: tianGanTextStyle.copyWith(
                                    fontSize: 16,
                                    color: _getTianGanColor(
                                        TianGan.getFromValue(pan.xunShou.name
                                            .split("")
                                            .first)!))),
                            TextSpan(
                                text: pan.xunShou.name.split("").last,
                                style: twelveDiZhiTextStyle.copyWith(
                                    fontSize: 17,
                                    color: ConstResourcesMapper.zodiacZhiColors[
                                        DiZhi.getFromValue(pan.xunShou.name
                                            .split("")
                                            .last)!])),
                            TextSpan(
                                text: " ${pan.xunHeaderTianGan.name}",
                                style: tianGanTextStyle.copyWith(
                                    fontSize: 16,
                                    color:
                                        _getTianGanColor(pan.xunHeaderTianGan)))
                          ]))),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      flex: 4,
                      child: Text("节气：", style: TextStyle(fontSize: 13))),
                  Flexible(
                      flex: 6,
                      child: RichText(
                          text: TextSpan(
                              text: pan.shiJiaJu.panJuJieQi?.name ??
                                  pan.jieQi.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey.shade800),
                              children: [
                            TextSpan(
                                text: "  ${pan.shiJiaJu.atThreeYuan.name}",
                                style: const TextStyle(fontSize: 13)),
                            pan.shiJiaJu.juDayNumber == null
                                ? const TextSpan(text: "")
                                : TextSpan(
                                    text: " 第 ${pan.shiJiaJu.juDayNumber!} 天",
                                    style: const TextStyle(fontSize: 13))
                          ]))),
                ],
              ),
              SizedBox(
                height: 22, // Adjusted for consistent layout
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Align items vertically
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                        flex: 4,
                        child: Text("值符星：", style: TextStyle(fontSize: 13))),
                    Flexible(
                      flex: 6,
                      child: Row(children: [
                        SizedBox(
                          // Wrapper for icon-like text
                          height: 22,
                          child: Text("${pan.zhiFuStar.name}星",
                              style: nineStarTextStyle.copyWith(
                                  fontSize: 14,
                                  color: ConstantUiResourcesOfQiMen
                                      .nineStarsColorMapper[pan.zhiFuStar])),
                        ),
                        RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueGrey.shade800),
                                children: [
                              const TextSpan(
                                  text: " 落 ",
                                  style: TextStyle(color: Colors.grey)),
                              TextSpan(
                                  text:
                                      "${pan.zhiFuStarAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiFuStarAtGong.houTianOrder]}宫")
                            ]))
                      ]),
                    )
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      flex: 4,
                      child: Text("值使门：", style: TextStyle(fontSize: 13))),
                  Flexible(
                    flex: 6,
                    child: Row(children: [
                      SizedBox(
                        // Wrapper for icon-like text
                        height: 22,
                        child: Text(pan.zhiShiDoor.name,
                            style: eightDoorTextStyle.copyWith(
                                fontSize: 14,
                                color: ConstantUiResourcesOfQiMen
                                    .eightDoorColorMapper[pan.zhiShiDoor])),
                      ),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey.shade800),
                              children: [
                            const TextSpan(
                                text: " 落 ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text:
                                    "${pan.zhiShiDoorAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiShiDoorAtGong.houTianOrder]}宫")
                          ]))
                    ]),
                  )
                ],
              )
            ]),
      ),
    );
  }

  Widget _buildCenterFourZhu(BuildContext context, ShiJiaQiMen pan) {
    return Card(
        child: Align(
      alignment: Alignment.center,
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FourZhuEightChar(
            year: pan.yearJiaZi,
            month: pan.monthJiaZi,
            day: pan.dayJiaZi,
            chen: pan.timeJiaZi,
            isColorful: true,
            zodiacGanColors: ConstResourcesMapper.zodiacGanColors,
            zodiacZhiColors: ConstResourcesMapper.zodiacZhiColors,
            // customGanStyle:
            // const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            // customZhiStyle:
            // const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (shiJiaQiMen == null) {
      // Return a placeholder or empty container if no data
      return const SizedBox(
          height: 160); // Match height of content when available
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 120,
          child: _buildCenterPanTime(
              context, panDateTime ?? shiJiaQiMen!.panDateTime),
        ),
        SizedBox(
          width: 240,
          height: 160,
          child: _buildPanInfo(context, shiJiaQiMen!, plateType),
        ),
        SizedBox(
          width: 260,
          height: 150,
          child: _buildCenterFourZhu(context, shiJiaQiMen!),
        ),
      ],
    );
  }
}
