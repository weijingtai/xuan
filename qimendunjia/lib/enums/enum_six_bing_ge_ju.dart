import 'package:common/enums.dart';

import '../model/each_gong.dart';
import '../model/shi_jia_qi_men.dart';

enum EnumSixBingGeJu {
  // 六丙
  Year("悖格·年悖", JiXiongEnum.XIONG), // 天盘丙 加 地盘年、月干
  Month("悖格·月悖", JiXiongEnum.XIONG), // 天盘丙 加 地盘年、月干
  Day("悖格·日悖", JiXiongEnum.XIONG), // 天盘丙 加地盘日干
  Time("悖格·时悖", JiXiongEnum.XIONG), // 天盘丙 加地盘时干

  Fly("悖格·飞悖", JiXiongEnum.XIONG), // 地盘丙 加天盘值符
  Fu("悖格·符悖", JiXiongEnum.XIONG); // 天盘丙 加地盘值符

  final String name;
  final JiXiongEnum jiXiong;
  const EnumSixBingGeJu(this.name, this.jiXiong);
  static List<EnumSixBingGeJu> checkBingGeForPanel(ShiJiaQiMen pan) {
    TianGan yearGan = pan.yearJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.yearJiaZi.tianGan;
    TianGan monthGan = pan.monthJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.monthJiaZi.tianGan;
    TianGan timeGan = pan.timeJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.timeJiaZi.tianGan;
    TianGan dayGan = pan.dayJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.dayJiaZi.tianGan;
    List<EnumSixBingGeJu> finalResults = [];
    List<EnumSixBingGeJu> ganAsTianPan(TianGan diPanGan) {
      List<EnumSixBingGeJu> res = [];
      if (diPanGan == yearGan) {
        res.add(Year);
      }
      if (diPanGan == monthGan) {
        res.add(Month);
      }
      if (diPanGan == dayGan) {
        res.add(Day);
      }
      if (diPanGan == timeGan) {
        res.add(Time);
      }
      if (diPanGan == pan.zhiFuGan) {
        res.add(Fu);
      }
      return res;
    }

    for (var entries in pan.gongMapper.entries) {
      EachGong gong = entries.value;
      if (gong.tianPan == TianGan.BING) {
        finalResults.addAll(ganAsTianPan(gong.diPan));
        // 检查此宫的地盘是否存在 “寄干”
        if (gong.diPanJiGan != null) {
          finalResults.addAll(ganAsTianPan(gong.diPanJiGan!));
        }
      }
      if (gong.tianPanJiGan != null && gong.tianPanJiGan == TianGan.BING) {
        finalResults.addAll(ganAsTianPan(gong.diPan));

        // 检查此宫的地盘是否存在 “寄干”
        if (gong.diPanJiGan != null) {
          finalResults.addAll(ganAsTianPan(gong.diPanJiGan!));
        }
      }

      if (gong.diPan == TianGan.BING && gong.tianPan == pan.zhiFuGan) {
        finalResults.add(Fly);
      }
      if (gong.diPanJiGan != null &&
          gong.diPanJiGan == TianGan.BING &&
          gong.tianPan == pan.zhiFuGan) {
        finalResults.add(Fly);
      }
    }
    return finalResults;
  }
}
