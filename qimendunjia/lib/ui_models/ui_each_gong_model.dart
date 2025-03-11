import 'package:common/enums.dart';

import '../model/each_gong.dart';
import '../model/each_gong_ge_ju.dart';
import '../model/each_gong_wang_shuai.dart';
import '../model/qi_yi_ru_gong.dart';
import 'ui_ten_gan_key_ying_ge_ju.dart';
import 'ui_pan_meta_model.dart';

class UIEachGongModel {
  HouTianGua gua;
  EachGong gong;
  EachGongWangShuai gongWangShuai;
  UITenGanKeYingGeJu tenGanKeYingGeJu;
  UIPanMetaModel panMete;
  EachGongGeJu eachGongGeJu;
  List<QiYiRuGong>? qiYiRuGongList;
  UIEachGongModel(
      {required this.gua,
      required this.gong,
      required this.gongWangShuai,
      required this.tenGanKeYingGeJu,
      required this.panMete,
      required this.eachGongGeJu,
      required this.qiYiRuGongList});
}
