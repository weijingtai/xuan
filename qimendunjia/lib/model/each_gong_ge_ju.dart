
import 'package:qimendunjia/enums/nine_dun.dart';

import '../enums/enum_most_popular_ge_ju.dart';
import '../enums/enum_san_zha_wu_jia.dart';

class EachGongGeJu{
  final List<EnumMostPopularGeJu> tianDiPanGeJuList;
  final NineDunEnum? tianDiPanNineDun;
  final SanZhaWuJiaEnum? tianDiPanZhaJia;
  final List<EnumMostPopularGeJu>? tianPanJiGanWithDiPanList;
  final NineDunEnum? tianJiDiPanNineDun;
  final SanZhaWuJiaEnum? tianJiDiPanZhaJia;
  final List<EnumMostPopularGeJu>? tianPanWithDiPanJiGanList;
  final NineDunEnum? tianDiJiPanNineDun;
  final List<EnumMostPopularGeJu>? tianDiJiGanList;
  EachGongGeJu({
    required this.tianDiPanGeJuList,
    required this.tianPanJiGanWithDiPanList,
    required this.tianPanWithDiPanJiGanList,
    required this.tianDiJiGanList,

    required this.tianDiPanNineDun,
    required this.tianDiPanZhaJia,
    required this.tianJiDiPanNineDun,
    required this.tianJiDiPanZhaJia,
    required this.tianDiJiPanNineDun,
  });
}

class EachGongNineDun{
  final NineDunEnum? tianDiPanGeJuList;
  final NineDunEnum? tianPanJiGanWithDiPan;
  final NineDunEnum? tianPanWithDiPanJiGan;
  EachGongNineDun({
    required this.tianDiPanGeJuList,
    required this.tianPanJiGanWithDiPan,
    required this.tianPanWithDiPanJiGan,
  });
}
class EachGongSanZhaWuJia{
  final SanZhaWuJiaEnum? tianPanGan;
  final SanZhaWuJiaEnum? tianPanJiGan;

  EachGongSanZhaWuJia({
  required this.tianPanGan,
    required this.tianPanJiGan,
  });
}