import 'package:common/enums.dart';

import '../enums/enum_three_yuan.dart';

class ShiJiaJu {
  int juNumber;

  JiaZi fuTouJiaZi;
  YinYang yinYangDun;
  TwentyFourJieQi jieQiAt;
  DateTime? jieQiStartAt;
  TwentyFourJieQi jieQiEnd;
  DateTime? jieQiEndAt;
  TwentyFourJieQi? panJuJieQi; // 盘局使用的节气
  EnumThreeYuan atThreeYuan;
  String fourZhuEightChar;
  int? juDayNumber; // 起局为 局的第几天

  DateTime panDateTime;
  ShiJiaJu(
      {required this.panDateTime,
      required this.juNumber,
      required this.fuTouJiaZi,
      required this.yinYangDun,
      required this.jieQiAt,
      this.jieQiStartAt,
      required this.jieQiEnd,
      this.jieQiEndAt,
      required this.atThreeYuan,
      required this.fourZhuEightChar,
      this.panJuJieQi,
      this.juDayNumber});
}
