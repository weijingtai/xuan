import 'package:common/enums.dart';

import 'da_liu_ren_ke_pan.dart';

abstract class DaLiuRenPanel {
  JiaZi getDayJiaZi();
  FourClass getFourClass();
  ThreeChuan getThreeChuan();
  Map<DiZhi, EachGong> getGongMapper();
}
