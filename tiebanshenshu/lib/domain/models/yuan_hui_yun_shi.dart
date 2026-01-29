import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../constant/constants.dart' as Constants;
import 'huang_ji_number.dart';

part 'yuan_hui_yun_shi.g.dart';

@JsonSerializable()
class YuanHuiYunShi extends EightChars {
  // 年柱
  late final DiZhi yearZhi;
  late final TianGan yearGan;
  late final int yearZhiNumber;
  late final int yearGanNumber;

  // 月柱
  late final DiZhi monthZhi;
  late final TianGan monthGan;
  late final int monthZhiNumber;
  late final int monthGanNumber;

  // 日柱
  late final DiZhi dayZhi;
  late final TianGan dayGan;
  late final int dayZhiNumber;
  late final int dayGanNumber;

  // 时柱
  late final DiZhi timeZhi;
  late final TianGan timeGan;
  late final int timeZhiNumber;
  late final int timeGanNumber;

  // 计算结果
  late final int yuanNumber; // 年干支相加为"元"
  late final int huiNumber; // 月干支相加为"会"
  late final int yunNumber; // 日干支相加为"运"
  late final int shiNumber; // 时干支相加为"世"

  // 互合成数
  late final HuangJiBaseNumber yuanHuiMergeNumber; // 年+月 互合成数顺左旋取数（元会基本数）
  late final HuangJiBaseNumber yunShiMergeNumber; // 日+时 互合成数逆右旋取数（运世基础数）
  YuanHuiYunShi({
    required JiaZi year,
    required JiaZi month,
    required JiaZi day,
    required JiaZi time,
    Map<TianGan, int> ganMapper = Constants.taiXuanGanNumberMapper,
    Map<DiZhi, int> zhiMapper = Constants.taiXuanZhiNumberMapper,
  }) : super(year: year, month: month, day: day, time: time) {
    // 年柱初始化
    yearZhi = year.diZhi;
    yearGan = year.tianGan;
    yearZhiNumber = zhiMapper[year.diZhi]!;
    yearGanNumber = ganMapper[year.tianGan]!;

    // 月柱初始化
    monthZhi = month.diZhi;
    monthGan = month.tianGan;
    monthZhiNumber = zhiMapper[month.diZhi]!;
    monthGanNumber = ganMapper[month.tianGan]!;

    // 日柱初始化
    dayZhi = day.diZhi;
    dayGan = day.tianGan;
    dayZhiNumber = zhiMapper[day.diZhi]!;
    dayGanNumber = ganMapper[day.tianGan]!;

    // 时柱初始化
    timeZhi = time.diZhi;
    timeGan = time.tianGan;
    timeZhiNumber = zhiMapper[time.diZhi]!;
    timeGanNumber = ganMapper[time.tianGan]!;

    // 计算结果初始化
    int _yuanNumber = ganMapper[year.tianGan]! + zhiMapper[year.diZhi]!;
    yuanNumber = _yuanNumber < 10 ? _yuanNumber * 10 : _yuanNumber;
    int _huiNumber = ganMapper[month.tianGan]! + zhiMapper[month.diZhi]!;
    huiNumber = _huiNumber < 10 ? _huiNumber * 10 : _huiNumber;
    int _yunNumber = ganMapper[day.tianGan]! + zhiMapper[day.diZhi]!;
    yunNumber = _yunNumber < 10 ? _yunNumber * 10 : _yunNumber;
    int _shiNumber = ganMapper[time.tianGan]! + zhiMapper[time.diZhi]!;
    shiNumber = _shiNumber < 10 ? _shiNumber * 10 : _shiNumber;

    // 互合成数初始化
    // 年+月 互合成数顺左旋取数（元会基本数）：如年元数为"9"，月会数为"18"，元会互合成数为9018
    yuanHuiMergeNumber = HuangJiBaseNumber(
      name: "元会基础数",
      description: "元会互合数",
      orinialNumber: int.parse('${yuanNumber}${huiNumber}'),
      baseNumberType: BaseNumberType.basic,
      numberSource: NumberSource.yuanHui,
    );
    // 日+时 互合成数逆右旋取数（运世基础数）：如日运数为12，时世数为11，逆右旋取数，运世互合成数为2111 并非"1211"

    this.yunShiMergeNumber = HuangJiBaseNumber(
      name: "运世基础数",
      description: "运与世互合数(右旋)",
      orinialNumber: int.parse(
        '${(yunNumber).toString().split('').reversed.join()}${(shiNumber).toString().split('').reversed.join()}',
      ),

      baseNumberType: BaseNumberType.basic,
      numberSource: NumberSource.yunShi,
    );
  }

  /// 从EightChars创建YuanHuiYunShi的工厂构造函数
  factory YuanHuiYunShi.fromEightChars(
    EightChars eightChars, {
    Map<TianGan, int> ganMapper = Constants.taiXuanGanNumberMapper,
    Map<DiZhi, int> zhiMapper = Constants.taiXuanZhiNumberMapper,
  }) {
    return YuanHuiYunShi(
      year: eightChars.year,
      month: eightChars.month,
      day: eightChars.day,
      time: eightChars.time,
      ganMapper: ganMapper,
      zhiMapper: zhiMapper,
    );
  }

  int getTaiXuanNumberBy({
    required FourZhuGanZhiType ganZhiType,
    required FourZhuName fourZhu,
  }) {
    switch (fourZhu) {
      case FourZhuName.year:
        return ganZhiType == FourZhuGanZhiType.gan
            ? yearGanNumber
            : yearZhiNumber;
      case FourZhuName.month:
        return ganZhiType == FourZhuGanZhiType.gan
            ? monthGanNumber
            : monthZhiNumber;
      case FourZhuName.day:
        return ganZhiType == FourZhuGanZhiType.gan
            ? dayGanNumber
            : dayZhiNumber;
      case FourZhuName.time:
        return ganZhiType == FourZhuGanZhiType.gan
            ? timeGanNumber
            : timeZhiNumber;
    }
  }

  @override
  factory YuanHuiYunShi.fromJson(Map<String, dynamic> json) =>
      _$YuanHuiYunShiFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$YuanHuiYunShiToJson(this);
}
