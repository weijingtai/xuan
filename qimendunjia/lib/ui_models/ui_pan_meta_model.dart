
import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_month_token.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:common/model/enum_yin_yang.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:tuple/tuple.dart';

class UIPanMetaModel {
  YinYang yinYangDun;
  EightDoorEnum zhiShiDoor;
  NineStarsEnum zhiFuStar;
  TianGan xunHeaderTianGan;
  Tuple2<DiZhi,DiZhi> timeXunKong;
  DiZhi horseLocation;
  MonthToken monthToken;
  // bool isFuYin;
  // bool isFanYin;
  UIPanMetaModel({
    required this.yinYangDun,
    required this.zhiShiDoor,
    required this.zhiFuStar,
    required this.xunHeaderTianGan,
    required this.timeXunKong,
    required this.horseLocation,
    required this.monthToken,
    // required this.isFuYin,
    // required this.isFanYin,
  });
}