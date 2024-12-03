
import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_jia_zi.dart';
import 'package:daliuren/model/three_chuan.dart';

import 'da_liu_ren_gong.dart';
import 'four_class.dart';

abstract class DaLiuRenPanel{

  JiaZi getDayJiaZi();
  FourClass getFourClass();
  ThreeChuan getThreeChuan();
  Map<DiZhi,DaLiuRenGong> getGongMapper();
}