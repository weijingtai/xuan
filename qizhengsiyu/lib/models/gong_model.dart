import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';

import '../enums/enum_twelve_gong.dart';

class GongModel {
  EnumTwelveGong gong;
  EnumDestinyTwelveGong destinyGong;
  List<ElevenStarsInfo> enteredStars;
  ElevenStarsInfo masterStars;

  TwelveZhangSheng zhangSheng;
  EnumBeforeTaiSuiShenSha taiSuiCirclingSha;
  Set<TianGanShenSha> tianGanShenShaSet;
  Set<DiZhiShenSha> diZhiShenShaSet;
  Set<ShenSha> otherShenShaSet;
  GongModel(
      {required this.gong,
      required this.destinyGong,
      required this.enteredStars,
      required this.masterStars,
      required this.zhangSheng,
      required this.taiSuiCirclingSha,
      required this.diZhiShenShaSet,
      required this.tianGanShenShaSet,
      required this.otherShenShaSet});
}
