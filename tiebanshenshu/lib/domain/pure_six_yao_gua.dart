import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pure_six_yao_gua.g.dart';

enum Gua64Enum {
  @JsonValue("乾")
  qian_wei_tian("乾为天", "乾"),
  @JsonValue("姤")
  tian_feng_gou("天风姤", "姤"),
  @JsonValue("遁")
  tian_shan_dun("天山遁", "遁"),
  @JsonValue("否")
  tian_di_pi("天地否", "否"),
  @JsonValue("观")
  feng_di_guan("风地观", "观"),
  @JsonValue("剥")
  shan_di_bo("山地剥", "剥"),
  @JsonValue("晋")
  huo_di_jin("火地晋", "晋"),
  @JsonValue("大有")
  huo_tian_da_you("火天大有", "大有"),

  @JsonValue("兑")
  dui_wei_ze("兑为泽", "泽"),
  @JsonValue("困")
  ze_shui_kun("泽水困", "困"),
  @JsonValue("萃")
  ze_di_cui("泽地萃", "萃"),
  @JsonValue("咸")
  ze_shan_xian("泽山咸", "咸"),
  @JsonValue("蹇")
  shui_shan_jian("水山蹇", "蹇"),
  @JsonValue("谦")
  di_shan_qi("地山谦", "谦"),
  @JsonValue("小过")
  lei_shan_xiao_gu("雷山小过", "小过"),
  @JsonValue("归妹")
  lei_ze_gui_mei("雷泽归妹", "归妹"),

  @JsonValue("离")
  li_wei_huo("离为火", "火"),
  @JsonValue("旅")
  huo_shan_lv("火山旅", "旅"),
  @JsonValue("鼎")
  huo_feng_ding("火风鼎", "鼎"),
  @JsonValue("未济")
  huo_shui_wei_ji("火水未济", "未济"),
  @JsonValue("蒙")
  shan_shui_meng("山水蒙", "蒙"),
  @JsonValue("涣")
  feng_shui_huan("风水涣", "涣"),
  @JsonValue("讼")
  tian_shui_song("天水讼", "讼"),
  @JsonValue("同人")
  tian_huo_tong_ren("天火同人", "同人"),

  @JsonValue("震")
  zhen_wei_lei("震为雷", "雷"),
  @JsonValue("豫")
  lei_di_yu("雷地豫", "豫"),
  @JsonValue("解")
  lei_shui_jie("雷水解", "解"),
  @JsonValue("恒")
  lei_feng_heng("雷风恒", "恒"),
  @JsonValue("升")
  di_feng_shen("地风升", "升"),
  @JsonValue("井")
  shui_feng_jing("水风井", "井"),
  @JsonValue("大过")
  ze_feng_da_guo("泽风大过", "大过"),
  @JsonValue("随")
  ze_lei_sui("泽雷随", "随"),

  @JsonValue("巽")
  xun_wei_feng("巽为风", "风"),
  @JsonValue("小畜")
  feng_tian_xiao_xu("风天小畜", "小畜"),
  @JsonValue("家人")
  feng_huo_jia_ren("风火家人", "家人"),
  @JsonValue("益")
  feng_lei_yi("风雷益", "益"),
  @JsonValue("无妄")
  tian_lei_wu_wang("天雷无妄", "无妄"),
  @JsonValue("噬嗑")
  huo_lei_shi_he("火雷噬嗑", "噬嗑"),
  @JsonValue("颐")
  shan_lei_yi("山雷颐", "颐"),
  @JsonValue("蛊")
  shan_feng_gu("山风蛊", "蛊"),

  @JsonValue("坎")
  kan_wei_shui("坎为水", "水"),
  @JsonValue("节")
  shui_ze_jie("水泽节", "节"),
  @JsonValue("屯")
  shui_lei_chun("水雷屯", "屯"),
  @JsonValue("既济")
  shui_huo_ji_ji("水火既济", "既济"),
  @JsonValue("革")
  ze_huo_ge("泽火革", "革"),
  @JsonValue("丰")
  lei_huo_feng("雷火丰", "丰"),
  @JsonValue("明夷")
  di_huo_ming_yi("地火明夷", "明夷"),
  @JsonValue("师")
  di_shui_shi("地水师", "师"),

  @JsonValue("艮")
  gen_wei_shan("艮为山", "山"),
  @JsonValue("贲")
  shan_huo_ben("山火贲", "贲"),
  @JsonValue("大畜")
  shan_tian_da_xu("山天大畜", "大畜"),
  @JsonValue("损")
  shan_ze_sun("山泽损", "损"),
  @JsonValue("睽")
  huo_ze_kui("火泽睽", "睽"),
  @JsonValue("履")
  tian_ze_lv("天泽履", "履"),
  @JsonValue("中孚")
  feng_ze_zhong_fu("风泽中孚", "中孚"),
  @JsonValue("渐")
  feng_shan_jian("风山渐", "渐"),

  @JsonValue("坤")
  kun_wei_di("坤为地", "地"),
  @JsonValue("复")
  di_lei_fu("地雷复", "复"),
  @JsonValue("临")
  di_ze_lin("地泽临", "临"),
  @JsonValue("泰")
  di_tian_tai("地天泰", "泰"),
  @JsonValue("大壮")
  lei_tian_da_zhuang("雷天大壮", "大壮"),
  @JsonValue("夬")
  ze_tian_guai("泽天夬", "夬"),
  @JsonValue("需")
  shui_tian_xu("水天需", "需"),
  @JsonValue("比")
  shui_di_bi("水地比", "比");

  final String name;
  final String fullname;

  const Gua64Enum(this.fullname, this.name);
  static Gua64Enum fromName(String name) {
    return Gua64Enum.values.firstWhere((element) => element.name == name);
  }

  static Gua64Enum fromFullName(String fullname) {
    return Gua64Enum.values.firstWhere(
      (element) => element.fullname == fullname,
    );
  }

  static Gua64Enum getBy8Gua(Enum8Gua topGua, Enum8Gua bottomGua) {
    return Gua64Enum.values.firstWhere(
      (e) => e.fullname.startsWith(topGua.nickname + bottomGua.nickname),
    );
  }
}

@JsonSerializable()
class GuaYao {
  final YinYang yinYang; // 爻位的阴阳
  TianGan? naJia; // 爻纳甲
  DiZhi? naZhi; // 爻纳支
  LiuQin? liuQin; // 六亲
  JiaZi? get ganZhi => naJia != null && naZhi != null
      ? JiaZi.getFromGanZhiEnum(naJia!, naZhi!)
      : null;

  GuaYao({required this.yinYang, this.naJia, this.naZhi, this.liuQin});

  factory GuaYao.fromJson(Map<String, dynamic> json) => _$GuaYaoFromJson(json);

  Map<String, dynamic> toJson() => _$GuaYaoToJson(this);
}

@JsonSerializable()
class PureSixYaoGua {
  final Gua64Enum gua;
  final Enum8Gua topGua;
  final Enum8Gua bottomGua;

  final List<GuaYao> yaoList; // 下爻->上爻

  List<GuaYao> get topBottomYaoList => yaoList.reversed.toList(); // 上爻->下爻

  List<TianGan?> get bottomTopGanList =>
      topBottomYaoList.map((e) => e.naJia).toList();
  List<TianGan?> get topBottomGanList =>
      topBottomYaoList.map((e) => e.naJia).toList().reversed.toList();

  List<DiZhi?> get bottomTopZhiList =>
      topBottomYaoList.map((e) => e.naZhi).toList();
  List<DiZhi?> get topBottomZhiList =>
      topBottomYaoList.map((e) => e.naZhi).toList().reversed.toList();

  List<JiaZi?> get bottomTopJiaZiList => topBottomYaoList.map((e) {
    if (e.naJia == null || e.naZhi == null) {
      return null;
    }
    return JiaZi.getFromGanZhiEnum(e.naJia!, e.naZhi!);
  }).toList();
  List<JiaZi?> get topBottomJiaZiList =>
      bottomTopJiaZiList.toList().reversed.toList();

  String get yaoBinStr =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? "0" : "1").join("");
  String get topBotYaoBinStr => topBottomYaoList
      .map((e) => e.yinYang == YinYang.YIN ? "0" : "1")
      .join("");

  PureSixYaoGua({
    required this.gua,
    required this.topGua,
    required this.bottomGua,
    required this.yaoList,
  });
  factory PureSixYaoGua.by8Gua(Enum8Gua topGua, Enum8Gua bottomGua) {
    final bottomTopBinaryStr =
        "${bottomGua.bottomTopBinaryStr}${topGua.bottomTopBinaryStr}";
    final botTopBinStrList = bottomTopBinaryStr.split("");

    return PureSixYaoGua(
      gua: Gua64Enum.getBy8Gua(topGua, bottomGua),
      topGua: topGua,
      bottomGua: bottomGua,
      yaoList: botTopBinStrList
          .map((b) => GuaYao(yinYang: YinYang.getByBinaryStr(b)))
          .toList(),
    );
  }

  factory PureSixYaoGua.fromJson(Map<String, dynamic> json) =>
      _$PureSixYaoGuaFromJson(json);

  Map<String, dynamic> toJson() => _$PureSixYaoGuaToJson(this);

  copyWith({
    Gua64Enum? gua,
    Enum8Gua? topGua,
    Enum8Gua? bottomGua,
    List<GuaYao>? yaoList,
  }) {
    return PureSixYaoGua(
      gua: gua ?? this.gua,
      topGua: topGua ?? this.topGua,
      bottomGua: bottomGua ?? this.bottomGua,
      yaoList: yaoList ?? this.yaoList,
    );
  }
}
