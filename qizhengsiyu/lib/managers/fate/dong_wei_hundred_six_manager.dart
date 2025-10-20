import 'package:common/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart'; // 使用domain层的模型
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart'; // 使用domain层的模型
import 'package:tuple/tuple.dart';

import '../../models/fate_dong_wei_da_xian.dart';
import '../../models/fate_year_month_pair.dart';

// 百六限
// 固定命宫 15岁
class DongWeiHundredSixManager {
  // 十二宫位年限配置
  static const Map<EnumDestinyTwelveGong, double> PALACE_YEARS_Modern = {
    EnumDestinyTwelveGong.Ming: 15.0,
    EnumDestinyTwelveGong.XiangMao: 10.0,
    EnumDestinyTwelveGong.FuDe: 11.0,
    EnumDestinyTwelveGong.GuanLu: 15.0,
    EnumDestinyTwelveGong.QianYi: 8.0,
    EnumDestinyTwelveGong.JiE: 7.0,
    EnumDestinyTwelveGong.FuQi: 11.0,
    EnumDestinyTwelveGong.NuPu: 4.5,
    EnumDestinyTwelveGong.NanNv: 4.5,
    EnumDestinyTwelveGong.TianZhai: 4.5,
    EnumDestinyTwelveGong.XiongDi: 5.0,
    EnumDestinyTwelveGong.CaiBo: 5.0,
  };
  static const Map<EnumDestinyTwelveGong, double> PALACE_YEARS_Ancient = {
    EnumDestinyTwelveGong.Ming: 15.0,
    EnumDestinyTwelveGong.XiangMao: 10.0,
    EnumDestinyTwelveGong.FuDe: 11.0,
    EnumDestinyTwelveGong.GuanLu: 15.0,
    EnumDestinyTwelveGong.QianYi: 8.0,
    EnumDestinyTwelveGong.JiE: 7.0,
    EnumDestinyTwelveGong.FuQi: 11.0,
    EnumDestinyTwelveGong.NuPu: 5,
    EnumDestinyTwelveGong.NanNv: 5,
    EnumDestinyTwelveGong.TianZhai: 5,
    EnumDestinyTwelveGong.XiongDi: 5.0,
    EnumDestinyTwelveGong.CaiBo: 5.0,
  };

  // @return Map.key是对应的命理宫，
  // value是Tuple2<Tuple2<int, int>, Tuple2<int, int>>，
  // 第一个Tuple2<int, int>是开始的年与月，
  // 第二个Tuple2<int, int>是结束的年与月
  DongWeiFate calculate(DongWeiDaXianMingGongCountingType mingCountingType,
      BodyLifeModel bodyLifeModel) {
    // 这里应该从输入参数中获取太阳度数
    // 为了示例，我们假设太阳度数为30度
    final res =
        <EnumDestinyTwelveGong, Tuple2<Tuple2<int, int>, Tuple2<int, int>>>{};
    final YearMonthPair mingXian;

    mingXian = calculateMingXianWithFixed15(bodyLifeModel.lifeGongInfo);
    // Map<EnumDestinyTwelveGong, Tuple2<YearMonthPair, YearMonthPair>> mapper =
    //     {};
    final daXianGongs = <DaXianGong>[];
    YearMonthPair _tmpEnd = YearMonthPair.zero();
    final List<EnumTwelveGong> gongSeq =
        CollectUtils.changeSeq(bodyLifeModel.lifeGong, EnumTwelveGong.listAll);
    int order = 0;

    late Map<EnumDestinyTwelveGong, double> gongYears;
    switch (mingCountingType) {
      case DongWeiDaXianMingGongCountingType.HundredSix:
        gongYears = PALACE_YEARS_Modern;
        break;
      case DongWeiDaXianMingGongCountingType.Ancient:
        gongYears = PALACE_YEARS_Ancient;
        break;
      case DongWeiDaXianMingGongCountingType.Modern:
        gongYears = PALACE_YEARS_Modern;
        break;
    }
    for (var entry in gongYears.entries) {
      final palace = entry.key;
      if (entry.key == EnumDestinyTwelveGong.Ming) {
        _tmpEnd = _tmpEnd.addOther(mingXian);

        // _tmpEnd = Tuple2(
        // mingXian.item1 + _tmpEnd.item1, mingXian.item2 + _tmpEnd.item2);
        daXianGongs.add(DaXianGong(
            order: order,
            destinyGong: palace,
            gong: gongSeq[order],
            start: YearMonthPair.zero(),
            end: _tmpEnd,
            totalYears: mingXian));
        // mapper[palace] = Tuple2(YearMonthPair.zero(), _tmpEnd);
      } else {
        YearMonthPair _newTmpEnd;
        YearMonthPair yearMonthCurrentPair;
        if ((entry.value - entry.value.toInt()) != 0) {
          // 有小数
          // _newTmpEnd = Tuple2(_tmp, item2)
          yearMonthCurrentPair =
              YearMonthPair(year: entry.value.toInt(), month: 6);
          _newTmpEnd = _tmpEnd.addOther(yearMonthCurrentPair);
        } else {
          // 没有小数
          yearMonthCurrentPair =
              YearMonthPair(year: entry.value.toInt(), month: 0);
          _newTmpEnd = _tmpEnd.addOther(yearMonthCurrentPair);
        }
        daXianGongs.add(DaXianGong(
            order: order,
            destinyGong: palace,
            gong: gongSeq[order],
            start: _tmpEnd,
            end: _newTmpEnd,
            totalYears: yearMonthCurrentPair));
        _tmpEnd = _newTmpEnd;
      }
      order++;
    }
    return DongWeiFate(type: mingCountingType, daXianGongs: daXianGongs);
  }

  YearMonthPair calculateMingXianWithFixed15(GongDegree gongDegree) {
    return YearMonthPair(year: 15, month: 0);
  }
}
