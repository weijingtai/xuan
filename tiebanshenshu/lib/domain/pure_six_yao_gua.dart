import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pure_six_yao_gua.g.dart';

enum Gua64Enum {
  @JsonValue("乾")
  qian_wei_tian("乾为天", "乾", Enum8Gua.Qian, Enum8Gua.Qian),
  @JsonValue("姤")
  tian_feng_gou("天风姤", "姤", Enum8Gua.Qian, Enum8Gua.Xun),
  @JsonValue("遁")
  tian_shan_dun("天山遁", "遁", Enum8Gua.Qian, Enum8Gua.Gen),
  @JsonValue("否")
  tian_di_pi("天地否", "否", Enum8Gua.Qian, Enum8Gua.Kun),
  @JsonValue("观")
  feng_di_guan("风地观", "观", Enum8Gua.Xun, Enum8Gua.Gen),
  @JsonValue("剥")
  shan_di_bo("山地剥", "剥", Enum8Gua.Gen, Enum8Gua.Kun),
  @JsonValue("晋")
  huo_di_jin("火地晋", "晋", Enum8Gua.Li, Enum8Gua.Kun),
  @JsonValue("大有")
  huo_tian_da_you("火天大有", "大有", Enum8Gua.Li, Enum8Gua.Qian),

  @JsonValue("兑")
  dui_wei_ze("兑为泽", "泽", Enum8Gua.Dui, Enum8Gua.Dui),
  @JsonValue("困")
  ze_shui_kun("泽水困", "困", Enum8Gua.Dui, Enum8Gua.Kan),
  @JsonValue("萃")
  ze_di_cui("泽地萃", "萃", Enum8Gua.Dui, Enum8Gua.Kun),
  @JsonValue("咸")
  ze_shan_xian("泽山咸", "咸", Enum8Gua.Dui, Enum8Gua.Gen),
  @JsonValue("蹇")
  shui_shan_jian("水山蹇", "蹇", Enum8Gua.Kun, Enum8Gua.Gen),
  @JsonValue("谦")
  di_shan_qi("地山谦", "谦", Enum8Gua.Kun, Enum8Gua.Gen),
  @JsonValue("小过")
  lei_shan_xiao_gu("雷山小过", "小过", Enum8Gua.Zhen, Enum8Gua.Gen),
  @JsonValue("归妹")
  lei_ze_gui_mei("雷泽归妹", "归妹", Enum8Gua.Zhen, Enum8Gua.Dui),

  @JsonValue("离")
  li_wei_huo("离为火", "火", Enum8Gua.Li, Enum8Gua.Li),
  @JsonValue("旅")
  huo_shan_lv("火山旅", "旅", Enum8Gua.Li, Enum8Gua.Gen),
  @JsonValue("鼎")
  huo_feng_ding("火风鼎", "鼎", Enum8Gua.Li, Enum8Gua.Xun),
  @JsonValue("未济")
  huo_shui_wei_ji("火水未济", "未济", Enum8Gua.Li, Enum8Gua.Kan),
  @JsonValue("蒙")
  shan_shui_meng("山水蒙", "蒙", Enum8Gua.Gen, Enum8Gua.Kan),
  @JsonValue("涣")
  feng_shui_huan("风水涣", "涣", Enum8Gua.Xun, Enum8Gua.Kan),
  @JsonValue("讼")
  tian_shui_song("天水讼", "讼", Enum8Gua.Qian, Enum8Gua.Kan),
  @JsonValue("同人")
  tian_huo_tong_ren("天火同人", "同人", Enum8Gua.Qian, Enum8Gua.Li),

  @JsonValue("震")
  zhen_wei_lei("震为雷", "雷", Enum8Gua.Zhen, Enum8Gua.Zhen),
  @JsonValue("豫")
  lei_di_yu("雷地豫", "豫", Enum8Gua.Zhen, Enum8Gua.Kun),
  @JsonValue("解")
  lei_shui_jie("雷水解", "解", Enum8Gua.Zhen, Enum8Gua.Kan),
  @JsonValue("恒")
  lei_feng_heng("雷风恒", "恒", Enum8Gua.Zhen, Enum8Gua.Xun),
  @JsonValue("升")
  di_feng_shen("地风升", "升", Enum8Gua.Kun, Enum8Gua.Xun),
  @JsonValue("井")
  shui_feng_jing("水风井", "井", Enum8Gua.Kan, Enum8Gua.Xun),
  @JsonValue("大过")
  ze_feng_da_guo("泽风大过", "大过", Enum8Gua.Dui, Enum8Gua.Xun),
  @JsonValue("随")
  ze_lei_sui("泽雷随", "随", Enum8Gua.Dui, Enum8Gua.Zhen),

  @JsonValue("巽")
  xun_wei_feng("巽为风", "风", Enum8Gua.Xun, Enum8Gua.Xun),
  @JsonValue("小畜")
  feng_tian_xiao_xu("风天小畜", "小畜", Enum8Gua.Xun, Enum8Gua.Qian),
  @JsonValue("家人")
  feng_huo_jia_ren("风火家人", "家人", Enum8Gua.Xun, Enum8Gua.Li),
  @JsonValue("益")
  feng_lei_yi("风雷益", "益", Enum8Gua.Xun, Enum8Gua.Zhen),
  @JsonValue("无妄")
  tian_lei_wu_wang("天雷无妄", "无妄", Enum8Gua.Qian, Enum8Gua.Zhen),
  @JsonValue("噬嗑")
  huo_lei_shi_he("火雷噬嗑", "噬嗑", Enum8Gua.Li, Enum8Gua.Zhen),
  @JsonValue("颐")
  shan_lei_yi("山雷颐", "颐", Enum8Gua.Gen, Enum8Gua.Zhen),
  @JsonValue("蛊")
  shan_feng_gu("山风蛊", "蛊", Enum8Gua.Gen, Enum8Gua.Xun),

  @JsonValue("坎")
  kan_wei_shui("坎为水", "水", Enum8Gua.Kan, Enum8Gua.Kan),
  @JsonValue("节")
  shui_ze_jie("水泽节", "节", Enum8Gua.Kan, Enum8Gua.Dui),
  @JsonValue("屯")
  shui_lei_chun("水雷屯", "屯", Enum8Gua.Kan, Enum8Gua.Zhen),
  @JsonValue("既济")
  shui_huo_ji_ji("水火既济", "既济", Enum8Gua.Kan, Enum8Gua.Li),
  @JsonValue("革")
  ze_huo_ge("泽火革", "革", Enum8Gua.Dui, Enum8Gua.Li),
  @JsonValue("丰")
  lei_huo_feng("雷火丰", "丰", Enum8Gua.Zhen, Enum8Gua.Li),
  @JsonValue("明夷")
  di_huo_ming_yi("地火明夷", "明夷", Enum8Gua.Kun, Enum8Gua.Li),
  @JsonValue("师")
  di_shui_shi("地水师", "师", Enum8Gua.Kun, Enum8Gua.Kan),

  @JsonValue("艮")
  gen_wei_shan("艮为山", "山", Enum8Gua.Gen, Enum8Gua.Gen),
  @JsonValue("贲")
  shan_huo_ben("山火贲", "贲", Enum8Gua.Gen, Enum8Gua.Li),
  @JsonValue("大畜")
  shan_tian_da_xu("山天大畜", "大畜", Enum8Gua.Gen, Enum8Gua.Qian),
  @JsonValue("损")
  shan_ze_sun("山泽损", "损", Enum8Gua.Gen, Enum8Gua.Dui),
  @JsonValue("睽")
  huo_ze_kui("火泽睽", "睽", Enum8Gua.Li, Enum8Gua.Dui),
  @JsonValue("履")
  tian_ze_lv("天泽履", "履", Enum8Gua.Qian, Enum8Gua.Dui),
  @JsonValue("中孚")
  feng_ze_zhong_fu("风泽中孚", "中孚", Enum8Gua.Xun, Enum8Gua.Dui),
  @JsonValue("渐")
  feng_shan_jian("风山渐", "渐", Enum8Gua.Xun, Enum8Gua.Gen),
  @JsonValue("坤")
  kun_wei_di("坤为地", "地", Enum8Gua.Kun, Enum8Gua.Kun),
  @JsonValue("复")
  di_lei_fu("地雷复", "复", Enum8Gua.Kun, Enum8Gua.Zhen),
  @JsonValue("临")
  di_ze_lin("地泽临", "临", Enum8Gua.Kun, Enum8Gua.Dui),
  @JsonValue("泰")
  di_tian_tai("地天泰", "泰", Enum8Gua.Kun, Enum8Gua.Qian),
  @JsonValue("大壮")
  lei_tian_da_zhuang("雷天大壮", "大壮", Enum8Gua.Zhen, Enum8Gua.Qian),
  @JsonValue("夬")
  ze_tian_guai("泽天夬", "夬", Enum8Gua.Dui, Enum8Gua.Qian),
  @JsonValue("需")
  shui_tian_xu("水天需", "需", Enum8Gua.Kan, Enum8Gua.Qian),
  @JsonValue("比")
  shui_di_bi("水地比", "比", Enum8Gua.Kan, Enum8Gua.Kun);

  final String name;
  final String fullname;

  final Enum8Gua top;
  final Enum8Gua bottom;

  const Gua64Enum(this.fullname, this.name, this.top, this.bottom);
  static Gua64Enum fromName(String name) {
    return Gua64Enum.values.firstWhere((element) => element.name == name);
  }

  static Gua64Enum fromFullName(String fullname) {
    return Gua64Enum.values.firstWhere(
      (element) => element.fullname == fullname,
    );
  }

  static Gua64Enum getBy8Gua(Enum8Gua topGua, Enum8Gua bottomGua) {
    if (topGua == bottomGua) {
      switch (topGua) {
        case Enum8Gua.Qian:
          return Gua64Enum.qian_wei_tian;
        case Enum8Gua.Dui:
          return Gua64Enum.dui_wei_ze;
        case Enum8Gua.Li:
          return Gua64Enum.li_wei_huo;

        case Enum8Gua.Zhen:
          return Gua64Enum.zhen_wei_lei;

        case Enum8Gua.Xun:
          return Gua64Enum.xun_wei_feng;
        case Enum8Gua.Kan:
          return Gua64Enum.kan_wei_shui;
        case Enum8Gua.Gen:
          return Gua64Enum.gen_wei_shan;
        case Enum8Gua.Kun:
          return Gua64Enum.kun_wei_di;
      }
    }
    return Gua64Enum.values.firstWhere(
      (e) => e.fullname.startsWith(topGua.nickname + bottomGua.nickname),
    );
  }

  static Gua64Enum fromBinaryStr(String binaryStr) {
    return fromBinaryList(
      binaryStr.split("").map((e) => int.parse(e)).toList(),
    );
  }

  static Gua64Enum fromBinaryList(List<int> binaryList) {
    final topGua = Enum8Gua.fromBottomTopBinaryStr(
      binaryList.sublist(0, 3).join(""),
    );
    final bottomGua = Enum8Gua.fromBottomTopBinaryStr(
      binaryList.sublist(3).join(""),
    );
    return Gua64Enum.getBy8Gua(bottomGua, topGua);
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
  String get binStr =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? "0" : "1").join("");
  List<int> get binaryList =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? 0 : 1).toList();
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

  Gua64Enum get zong {
    // print(binaryList);
    final newBinaryList = binaryList.reversed.toList();
    // print(newBinaryList);
    // print(Gua64Enum.fromBinaryList(newBinaryList));
    return Gua64Enum.fromBinaryList(newBinaryList);
  }

  Gua64Enum get cuo {
    // 所有的爻，进行 阴变阳、阳变阴的转换
    final newBinaryList = binaryList.map((e) => e == 0 ? 1 : 0).toList();
    return Gua64Enum.fromBinaryList(newBinaryList);
  }

  Gua64Enum get hu {
    // 二、三、四爻为互卦的 初、二、三爻
    final binaryList = this.binaryList;
    final downBinStr = binaryList.sublist(1, 4).join("");
    // 三/四/五爻为互卦的四、五、上 爻
    final upBinStr = binaryList.sublist(2, 5).join("");
    final downGua = Enum8Gua.fromBottomTopBinaryStr(downBinStr);
    final upGua = Enum8Gua.fromBottomTopBinaryStr(upBinStr);
    return Gua64Enum.getBy8Gua(upGua, downGua);
  }
}
