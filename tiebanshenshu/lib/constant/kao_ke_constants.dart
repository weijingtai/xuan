import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
part 'kao_ke_constants.g.dart';

// 鐵板神數之八刻
// 不少人都相信兩小時有八刻，頭十五分鐘為初刻。
// 如是八時八分出生便是初刻出生，這是不對的。
// 只是一種記號，考其六親。
// 不同師傅有不同的方法，同一命主，給不同師傅會定不同的刻。
// 大至上八刻有兩種定方法。
// 第一種
// 初刻，初一刻，初二刻，初三刻，正刻，正一刻，正二刻，正三刻。
// 主要是用父母兄弟定八刻，所以有時候批命時父還在時定刻前後不同。
// 當然師傅在初批命時也知道父母如何，兄弟多少。

// 第二種:
// 初一，二刻，三刻，四刻，五刻，六刻，七刻，八刻。
// 主要用八刻天干數，毎一刻有八條數，在其中一刻選擇最適合之條文定那一刻。
enum EigthKe {
  @JsonValue(1)
  first("一刻", "初刻", 1),
  @JsonValue(2)
  second("二刻", "初一刻", 2),
  @JsonValue(3)
  third("三刻", "初二刻", 3),
  @JsonValue(4)
  fourth("四刻", "初三刻", 4),
  @JsonValue(5)
  fifth("五刻", "正刻", 5),
  @JsonValue(6)
  sixth("六刻", "正一刻", 6),
  @JsonValue(7)
  seventh("七刻", "正二刻", 7),
  @JsonValue(8)
  eighth("八刻", "正三刻", 8);

  final String name;
  final String nickname;
  final int order;
  const EigthKe(this.name, this.nickname, this.order);
}

@JsonSerializable()
class KaoEigthKeNumber {
  DiZhi shiChen;
  EigthKe ke;
  int tiaoWenNumber;
  String cipherText;
  String originalText;
  KaoEigthKeNumber({
    required this.shiChen,
    required this.ke,
    required this.cipherText,
    required this.originalText,
    required this.tiaoWenNumber,
  });
  factory KaoEigthKeNumber.fromJson(Map<String, dynamic> json) =>
      _$KaoEigthKeNumberFromJson(json);
  Map<String, dynamic> toJson() => _$KaoEigthKeNumberToJson(this);
}

@JsonSerializable()
class KaoEigthKeTiaoWen extends KaoEigthKeNumber {
  TiaoWenDataModel tiaoWen;
  KaoEigthKeTiaoWen({
    required super.shiChen,
    required super.ke,
    required super.tiaoWenNumber,
    required this.tiaoWen,
    required super.cipherText,
    required super.originalText,
  });
  static KaoEigthKeTiaoWen generateFrom({
    required KaoEigthKeNumber kaoEigthKeNumber,
    required TiaoWenDataModel tiaoWenDataModel,
  }) {
    return KaoEigthKeTiaoWen(
      shiChen: kaoEigthKeNumber.shiChen,
      ke: kaoEigthKeNumber.ke,
      tiaoWenNumber: kaoEigthKeNumber.tiaoWenNumber,
      cipherText: kaoEigthKeNumber.cipherText,
      originalText: kaoEigthKeNumber.originalText,
      tiaoWen: tiaoWenDataModel,
    );
  }

  factory KaoEigthKeTiaoWen.fromJson(Map<String, dynamic> json) =>
      _$KaoEigthKeTiaoWenFromJson(json);
  Map<String, dynamic> toJson() => _$KaoEigthKeTiaoWenToJson(this);
}

enum DouJiaYiType {
  dou("斗"),
  jia("甲"),
  yi("乙");

  final String name;
  const DouJiaYiType(this.name);
}

@JsonSerializable()
class DouJiaYiNumber {
  DouJiaYiType type;
  DiZhi ke;
  int order; // 1-5
  int tiaoWenNumber;
  DouJiaYiNumber({
    required this.type,
    required this.ke,
    required this.order,
    required this.tiaoWenNumber,
  });
  factory DouJiaYiNumber.fromJson(Map<String, dynamic> json) =>
      _$DouJiaYiNumberFromJson(json);
  Map<String, dynamic> toJson() => _$DouJiaYiNumberToJson(this);
}

@JsonSerializable()
class DouJiaYiTiaoWen extends DouJiaYiNumber {
  TiaoWenDataModel tiaoWen;
  DouJiaYiTiaoWen({
    required super.ke,
    required super.tiaoWenNumber,
    required this.tiaoWen,
    required super.type,
    required super.order,
  });
  static DouJiaYiTiaoWen generateFrom({
    required DouJiaYiNumber douJiaYiNumber,
    required TiaoWenDataModel tiaoWenDataModel,
  }) {
    return DouJiaYiTiaoWen(
      type: douJiaYiNumber.type,
      order: douJiaYiNumber.order,
      ke: douJiaYiNumber.ke,
      tiaoWenNumber: douJiaYiNumber.tiaoWenNumber,
      tiaoWen: tiaoWenDataModel,
    );
  }

  factory DouJiaYiTiaoWen.fromJson(Map<String, dynamic> json) =>
      _$DouJiaYiTiaoWenFromJson(json);
  Map<String, dynamic> toJson() => _$DouJiaYiTiaoWenToJson(this);
}

@JsonSerializable()
class SixQinFenNumber {
  DiZhi shiChen;
  int fen;
  String wifeInfo;
  String childInfo;
  String husbandInfo;
  SixQinFenNumber({
    required this.shiChen,
    required this.fen,
    required this.wifeInfo,
    required this.childInfo,
    required this.husbandInfo,
  });
  factory SixQinFenNumber.fromJson(Map<String, dynamic> json) =>
      _$SixQinFenNumberFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinFenNumberToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SixQinFenNumberMapper {
  String name;
  String source;
  List<String> description;
  Map<DiZhi, List<SixQinFenNumber>> shiChenKeMapper;
  SixQinFenNumberMapper({
    required this.name,
    required this.source,
    required this.description,
    required this.shiChenKeMapper,
  });
  factory SixQinFenNumberMapper.fromJson(Map<String, dynamic> json) =>
      _$SixQinFenNumberMapperFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinFenNumberMapperToJson(this);
}

@JsonSerializable()
class SixQinKeNumber {
  DiZhi shiChen;
  EigthKe ke;
  String parentsInfo;
  String siblingsInfo;
  String guaYaoInfo;
  SixQinKeNumber({
    required this.shiChen,
    required this.ke,
    required this.parentsInfo,
    required this.siblingsInfo,
    required this.guaYaoInfo,
  });
  factory SixQinKeNumber.fromJson(Map<String, dynamic> json) =>
      _$SixQinKeNumberFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinKeNumberToJson(this);
}

@JsonSerializable()
class SixQinKeNumberMapper {
  String name;
  String source;
  List<String> description;
  Map<DiZhi, List<SixQinKeNumber>> shiChenKeMapper;
  SixQinKeNumberMapper({
    required this.name,
    required this.source,
    required this.description,
    required this.shiChenKeMapper,
  });
  factory SixQinKeNumberMapper.fromJson(Map<String, dynamic> json) =>
      _$SixQinKeNumberMapperFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinKeNumberMapperToJson(this);
}

@JsonSerializable()
class SixQinGongEach {
  String chiperText;
  int chiperNumber;
  String? siblingsInfo;
  JiaZi? yearGanZhi;

  SixQinGongEach({
    required this.chiperText,
    required this.chiperNumber,
    this.siblingsInfo,
    this.yearGanZhi,
  });
  factory SixQinGongEach.fromJson(Map<String, dynamic> json) =>
      _$SixQinGongEachFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinGongEachToJson(this);
}

@JsonSerializable()
class SixQinGongInfo {
  String name;
  String description;
  Map<DiZhi, List<SixQinGongEach>>? zhiMapper;
  List<SixQinGongEach>? gongEachList;
  SixQinGongInfo({
    required this.name,
    required this.description,
    this.zhiMapper,
    this.gongEachList,
  });
  factory SixQinGongInfo.fromJson(Map<String, dynamic> json) =>
      _$SixQinGongInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinGongInfoToJson(this);
}

@JsonSerializable()
class SixQinGongEachTiaoWen extends SixQinGongEach {
  TiaoWenDataModel tiaoWen;
  SixQinGongEachTiaoWen({
    required super.chiperText,
    required super.chiperNumber,
    super.siblingsInfo,
    super.yearGanZhi,
    required this.tiaoWen,
  });
  static SixQinGongEachTiaoWen generateFrom({
    required SixQinGongEach sixQinGongEach,
    required TiaoWenDataModel tiaoWenDataModel,
  }) {
    return SixQinGongEachTiaoWen(
      chiperText: sixQinGongEach.chiperText,
      chiperNumber: sixQinGongEach.chiperNumber,
      siblingsInfo: sixQinGongEach.siblingsInfo,
      yearGanZhi: sixQinGongEach.yearGanZhi,
      tiaoWen: tiaoWenDataModel,
    );
  }

  factory SixQinGongEachTiaoWen.fromJson(Map<String, dynamic> json) =>
      _$SixQinGongEachTiaoWenFromJson(json);
  Map<String, dynamic> toJson() => _$SixQinGongEachTiaoWenToJson(this);
}

class KaoKeConstants {
  final Map<DiZhi, List<KaoEigthKeNumber>> keNumbers = {
    DiZhi.ZI: [
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.first,
        tiaoWenNumber: 3543,
        cipherText: '戊壬庚戌',
        originalText: '杏林春秀，其祖悬壶为生。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.second,
        tiaoWenNumber: 9585,
        cipherText: '辛壬己戊',
        originalText: '父命辛亥生。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.third,
        tiaoWenNumber: 7545,
        cipherText: '丁壬庚壬',
        originalText: '生子之年。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.fourth,
        tiaoWenNumber: 3675,
        cipherText: '戊已丁壬',
        originalText: '丹桂先结子，来年荷花香。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.fifth,
        tiaoWenNumber: 7656,
        cipherText: '丁壬已壬',
        originalText: '三十六，鸳鸯两分飞 ，独立溪边影自孤。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.sixth,
        tiaoWenNumber: 1907,
        cipherText: '甲辛月丁',
        originalText: '三十五，三十六，西风料峭，白云生寒。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.seventh,
        tiaoWenNumber: 7086,
        cipherText: '丁月己已',
        originalText: '一父一母，兄弟二人。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.ZI,
        ke: EigthKe.eighth,
        tiaoWenNumber: 1008,
        cipherText: '甲月月己',
        originalText: '已亥金榜题名，方合此刻。',
      ),
    ],
    DiZhi.CHOU: [
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.first,
        tiaoWenNumber: 5365,
        cipherText: '壬戊已壬',
        originalText: '战功彪炳，三代有余威。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.second,
        tiaoWenNumber: 4003,
        cipherText: '庚月月戊',
        originalText: '红花绿叶，才子佳人乐尧天。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.third,
        tiaoWenNumber: 5993,
        cipherText: '壬辛辛戊',
        originalText: '甲辰拜师，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.fourth,
        tiaoWenNumber: 6374,
        cipherText: '已戊丁庚',
        originalText: '喜得双胞，男英妞淑。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.fifth,
        tiaoWenNumber: 6777,
        cipherText: '已丁丁丁',
        originalText: '兄弟如陌路，楚河汉界边。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.sixth,
        tiaoWenNumber: 6981,
        cipherText: '已辛己甲',
        originalText: '命中二子高飞。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.seventh,
        tiaoWenNumber: 9665,
        cipherText: '丁月己已',
        originalText: '一父一母，兄弟二人。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHOU,
        ke: EigthKe.eighth,
        tiaoWenNumber: 7068,
        cipherText: '甲月月己',
        originalText: '已亥金榜题名，方合此刻。',
      ),
    ],
    DiZhi.YIN: [
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.first,
        tiaoWenNumber: 6349,
        cipherText: '已戊庚辛',
        originalText: '七，八岁，平静无风雪。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.second,
        tiaoWenNumber: 6576,
        cipherText: '已辛丁壬',
        originalText: '二十三金榜题名,身宴琼林.',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.third,
        tiaoWenNumber: 5303,
        cipherText: '壬戊月戊',
        originalText: '戊寅拜师，方合此刻',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.fourth,
        tiaoWenNumber: 4867,
        cipherText: '庚己已丁',
        originalText: '莫道香灯无继，独子足可兴家。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.fifth,
        tiaoWenNumber: 3336,
        cipherText: '戊戊戊已',
        originalText: '姊妹同侍一夫。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.sixth,
        tiaoWenNumber: 5004,
        cipherText: '壬月月庚',
        originalText: '百尺竿头堪进步，君能碾转莫回头。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.seventh,
        tiaoWenNumber: 3652,
        cipherText: '戊已壬丙',
        originalText: '一父一母，兄弟四人。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YIN,
        ke: EigthKe.eighth,
        tiaoWenNumber: 4638,
        cipherText: '庚已戊己',
        originalText: '分别七八载，破镜又重圆。',
      ),
    ],
    DiZhi.MAO: [
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.first,
        tiaoWenNumber: 2172,
        cipherText: '丙甲丁丙',
        originalText: '金年母先终，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.second,
        tiaoWenNumber: 2375,
        cipherText: '丙戊丁壬',
        originalText: '名锁利关最缚人，长享云暗掩风尘。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.third,
        tiaoWenNumber: 3877,
        cipherText: '戊己丁丁',
        originalText: '时运不济，命途多刧。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.fourth,
        tiaoWenNumber: 6505,
        cipherText: '已壬月已',
        originalText: '我无亲生子，淑女钓金龟。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.fifth,
        tiaoWenNumber: 6758,
        cipherText: '已丁壬己',
        originalText: '骨肉有刑伤，秋风泪两行。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.sixth,
        tiaoWenNumber: 3768,
        cipherText: '戊丁已己',
        originalText: '万绪千端，宝镜尚磨仔细看。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.seventh,
        tiaoWenNumber: 3568,
        cipherText: '戊壬已己',
        originalText: '上苑奇花呈富贵，亭前瑞草报平安。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.MAO,
        ke: EigthKe.eighth,
        tiaoWenNumber: 2506,
        cipherText: '丙壬月己',
        originalText: '己酉金榜题名。',
      ),
    ],
    DiZhi.CHEN: [
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.first,
        tiaoWenNumber: 3798,
        cipherText: '戊丁辛己',
        originalText: '父故于水年，母尚犹芳，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.second,
        tiaoWenNumber: 7937,
        cipherText: '丁辛戊丁',
        originalText: '东窗望月年复一年，游人薄幸无归期。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.third,
        tiaoWenNumber: 1005,
        cipherText: '甲月月壬',
        originalText: '十一，十二，日照纱窗紫颜明，柳荫枝上报新春。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.fourth,
        tiaoWenNumber: 6707,
        cipherText: '已丁月丁',
        originalText: '三十九，夫别阳关去，千愁泪万行。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.fifth,
        tiaoWenNumber: 7056,
        cipherText: '丁月壬已',
        originalText: '姊妹三人，婚姻奇配。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.sixth,
        tiaoWenNumber: 7556,
        cipherText: '丁壬壬已',
        originalText: '戊午祸起，萧墙燕分飞 。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.seventh,
        tiaoWenNumber: 9565,
        cipherText: '辛壬已壬',
        originalText: '夫大二十七年，婚姻前定。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.CHEN,
        ke: EigthKe.eighth,
        tiaoWenNumber: 3666,
        cipherText: '戊已已已',
        originalText: '丁未金榜名。',
      ),
    ],
    DiZhi.SI: [
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.first,
        tiaoWenNumber: 4435,
        cipherText: '庚庚戊壬',
        originalText: '鲁班门中，喜得麟儿。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.second,
        tiaoWenNumber: 7467,
        cipherText: '丁庚已庚',
        originalText: '同床人，貌合神离。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.third,
        tiaoWenNumber: 6186,
        cipherText: '已甲己已',
        originalText: '七星伴月有奇格，一女如珠掌上擎.',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.fourth,
        tiaoWenNumber: 1857,
        cipherText: '甲己壬丁',
        originalText: '戊申拜师，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.fifth,
        tiaoWenNumber: 6981,
        cipherText: '已辛己甲',
        originalText: '三十五，际遇既亨，事多就绪。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.sixth,
        tiaoWenNumber: 3076,
        cipherText: '戊月丁已',
        originalText: '戊辰得功名，父子同庆。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.seventh,
        tiaoWenNumber: 2167,
        cipherText: '丙甲乙丁',
        originalText: '兄弟四人，数有三贵。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SI,
        ke: EigthKe.eighth,
        tiaoWenNumber: 9205,
        cipherText: '辛丙月壬',
        originalText: '一母二父，方合此刻。',
      ),
    ],
    DiZhi.WU: [
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.first,
        tiaoWenNumber: 3073,
        cipherText: '戊月丁戊',
        originalText: '四一，小家碧玉值千金。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.second,
        tiaoWenNumber: 5206,
        cipherText: '壬丙月乙',
        originalText: '一声猿啼三千里，万里寻夫不见人。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.third,
        tiaoWenNumber: 7060,
        cipherText: '丁月乙月',
        originalText: '丙午年拜师，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.fourth,
        tiaoWenNumber: 5760,
        cipherText: '壬丁乙辛',
        originalText: '正妻从未得结子，娶得偏房许生儿。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.fifth,
        tiaoWenNumber: 3897,
        cipherText: '戊己辛丁',
        originalText: '兄为弟谋皮，弟为兄落石。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.sixth,
        tiaoWenNumber: 1007,
        cipherText: '甲甲月丁',
        originalText: '一字记之曰一，住不得买不得。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.seventh,
        tiaoWenNumber: 1069,
        cipherText: '甲月乙辛',
        originalText: '一父一母，兄弟三人。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WU,
        ke: EigthKe.eighth,
        tiaoWenNumber: 9706,
        cipherText: '辛丁月乙',
        originalText: '恩爱夫妻，时有龋齬 。',
      ),
    ],
    DiZhi.WEI: [
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.first,
        tiaoWenNumber: 6887,
        cipherText: '乙己己丁',
        originalText: '殷殷贾人家，佳儿复淑。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.second,
        tiaoWenNumber: 4778,
        cipherText: '庚丁丁己',
        originalText: '十三，走到羊肠，得人指引。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.third,
        tiaoWenNumber: 5367,
        cipherText: '壬戊乙丁',
        originalText: '癸未拜师，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.fourth,
        tiaoWenNumber: 5378,
        cipherText: '壬戊丁己',
        originalText: '生就愚人福，同年得妻又得子。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.fifth,
        tiaoWenNumber: 5378,
        cipherText: '甲辛月壬',
        originalText: '三十九，泪痕未干，破镜残妆。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.sixth,
        tiaoWenNumber: 3006,
        cipherText: '戊月月乙',
        originalText: '官至吏部，文选解组林下。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.seventh,
        tiaoWenNumber: 1167,
        cipherText: '甲甲乙丁',
        originalText: '庚辰金榜题名，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.WEI,
        ke: EigthKe.eighth,
        tiaoWenNumber: 7786,
        cipherText: '丁丁己乙',
        originalText: '少年失牯，母子相依凭。',
      ),
    ],
    DiZhi.SHEN: [
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.first,
        tiaoWenNumber: 3920,
        cipherText: '戊辛丙支',
        originalText: '诗礼传家，一门书香。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.second,
        tiaoWenNumber: 6587,
        cipherText: '乙壬己丁',
        originalText: '喜逢黄道日，仓膳姓名扬。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.third,
        tiaoWenNumber: 3786,
        cipherText: '戊丁己乙',
        originalText: '己酉拜师，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.fourth,
        tiaoWenNumber: 4547,
        cipherText: '庚丙庚丁',
        originalText: '以受道者君馨香，长安城内姓名扬。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.fifth,
        tiaoWenNumber: 7106,
        cipherText: '丁甲月乙',
        originalText: '有王佐之才，无管氏之望。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.sixth,
        tiaoWenNumber: 6387,
        cipherText: '乙戊己丁',
        originalText: '文昌祠畔有一猿啼，一领青衫换布衣。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.seventh,
        tiaoWenNumber: 3866,
        cipherText: '戊己乙乙',
        originalText: '父已逝，随母改姓。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.SHEN,
        ke: EigthKe.eighth,
        tiaoWenNumber: 6578,
        cipherText: '乙壬丁己',
        originalText: '庚申金榜题名，方合此刻。',
      ),
    ],
    DiZhi.YOU: [
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.first,
        tiaoWenNumber: 1676,
        cipherText: '甲乙丁乙',
        originalText: '乡间老翁，喜得男儿。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.second,
        tiaoWenNumber: 6705,
        cipherText: '乙丁月壬',
        originalText: '为伊人薄幸，长伴木鱼青灯。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.third,
        tiaoWenNumber: 7056,
        cipherText: '丁月壬乙',
        originalText: '姊妹三人，婚姻奇配。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.fourth,
        tiaoWenNumber: 5624,
        cipherText: '壬乙戊庚',
        originalText: '梧桐结三子，秋来双落地。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.fifth,
        tiaoWenNumber: 6797,
        cipherText: '乙丁辛丁',
        originalText: '二十七，敬以造事，克以厥成。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.sixth,
        tiaoWenNumber: 3333,
        cipherText: '戊戊戊戊',
        originalText: '壬辰得子得利，喜事相饶。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.seventh,
        tiaoWenNumber: 4768,
        cipherText: '庚丁乙己',
        originalText: '少年失慈亲，严父是亲娘。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.YOU,
        ke: EigthKe.eighth,
        tiaoWenNumber: 7777,
        cipherText: '丁丁丁丁',
        originalText: '辛卯年金榜题名，方合此刻。',
      ),
    ],
    DiZhi.XU: [
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.first,
        tiaoWenNumber: 1667,
        cipherText: '辛乙乙丁',
        originalText: '二子送终，先天注定。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.second,
        tiaoWenNumber: 1112,
        cipherText: '甲甲甲甲',
        originalText: '四一，四二金匮相扶，喜气频频而至。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.third,
        tiaoWenNumber: 9675,
        cipherText: '辛乙丁壬',
        originalText: '母命己丑生方合。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.fourth,
        tiaoWenNumber: 6006,
        cipherText: '乙月月乙',
        originalText: '终生无子，方合此刻。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.fifth,
        tiaoWenNumber: 9568,
        cipherText: '辛壬乙己',
        originalText: '六十三，春光多富贵，晈月正光辉。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.sixth,
        tiaoWenNumber: 2165,
        cipherText: '丙甲乙壬',
        originalText: '壬年大病有救，枯木逢春。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.seventh,
        tiaoWenNumber: 3000,
        cipherText: '戊月月支',
        originalText: '钗于盒中，玉在柜中。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.XU,
        ke: EigthKe.eighth,
        tiaoWenNumber: 5657,
        cipherText: '壬乙丁乙',
        originalText: '丁酉金榜题名，方合此刻。',
      ),
    ],
    DiZhi.HAI: [
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.first,
        tiaoWenNumber: 2167,
        cipherText: '丙甲乙丁',
        originalText: '一父一母，我为庶出。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.second,
        tiaoWenNumber: 5057,
        cipherText: '壬月壬丁',
        originalText: '有贤淑妇，又作入幕之宾。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.third,
        tiaoWenNumber: 2305,
        cipherText: '丙戊月壬',
        originalText: '十九，二十，山岗虎豹送行人，朝暮当慎。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.fourth,
        tiaoWenNumber: 4657,
        cipherText: '庚乙壬丁',
        originalText: '琼林之宴，抡元之职。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.fifth,
        tiaoWenNumber: 3867,
        cipherText: '戊己乙丁',
        originalText: '屈指光阴有几何，愁肠阵阵奈君何。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.sixth,
        tiaoWenNumber: 3930,
        cipherText: '戊辛戊支',
        originalText: '数注其人，活计四海生涯。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.seventh,
        tiaoWenNumber: 6068,
        cipherText: '乙月己乙',
        originalText: '六十三，超然物外时，梅月松风。',
      ),
      KaoEigthKeNumber(
        shiChen: DiZhi.HAI,
        ke: EigthKe.eighth,
        tiaoWenNumber: 7608,
        cipherText: '丁乙月己',
        originalText: '数定乾坤真出奇，总无一子结枝头。',
      ),
    ],
  };

  // 斗甲乙宫
  final Map<DouJiaYiType, Map<DiZhi, List<DouJiaYiNumber>>>
  eightKeNumberMapper = {
    DouJiaYiType.dou: {
      DiZhi.ZI: [
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 1,
          ke: DiZhi.ZI,
          tiaoWenNumber: 4192,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 2,
          ke: DiZhi.ZI,
          tiaoWenNumber: 4382,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 3,
          ke: DiZhi.ZI,
          tiaoWenNumber: 7400,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 4,
          ke: DiZhi.ZI,
          tiaoWenNumber: 7353,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 5,
          ke: DiZhi.ZI,
          tiaoWenNumber: 7112,
        ),
      ],
      DiZhi.WU: [
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 1,
          ke: DiZhi.WU,
          tiaoWenNumber: 4262,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 2,
          ke: DiZhi.WU,
          tiaoWenNumber: 7298,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 3,
          ke: DiZhi.WU,
          tiaoWenNumber: 7749,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 4,
          ke: DiZhi.WU,
          tiaoWenNumber: 7531,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 5,
          ke: DiZhi.WU,
          tiaoWenNumber: 4491,
        ),
      ],
      DiZhi.MAO: [
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 1,
          ke: DiZhi.MAO,
          tiaoWenNumber: 7228,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 2,
          ke: DiZhi.MAO,
          tiaoWenNumber: 4636,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 3,
          ke: DiZhi.MAO,
          tiaoWenNumber: 7851,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 4,
          ke: DiZhi.MAO,
          tiaoWenNumber: 4754,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 5,
          ke: DiZhi.MAO,
          tiaoWenNumber: 4885,
        ),
      ],
      DiZhi.YOU: [
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 1,
          ke: DiZhi.YOU,
          tiaoWenNumber: 7131,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 2,
          ke: DiZhi.YOU,
          tiaoWenNumber: 4892,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 3,
          ke: DiZhi.YOU,
          tiaoWenNumber: 4414,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 4,
          ke: DiZhi.YOU,
          tiaoWenNumber: 7664,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.dou,
          order: 5,
          ke: DiZhi.YOU,
          tiaoWenNumber: 4876,
        ),
      ],
    },
    DouJiaYiType.jia: {
      DiZhi.CHEN: [
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 1,
          ke: DiZhi.CHEN,
          tiaoWenNumber: 7614,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 2,
          ke: DiZhi.CHEN,
          tiaoWenNumber: 8312,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 3,
          ke: DiZhi.CHEN,
          tiaoWenNumber: 8153,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 4,
          ke: DiZhi.CHEN,
          tiaoWenNumber: 5654,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 5,
          ke: DiZhi.CHEN,
          tiaoWenNumber: 8193,
        ),
      ],
      DiZhi.XU: [
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 1,
          ke: DiZhi.XU,
          tiaoWenNumber: 5734,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 2,
          ke: DiZhi.XU,
          tiaoWenNumber: 2176,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 3,
          ke: DiZhi.XU,
          tiaoWenNumber: 5639,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 4,
          ke: DiZhi.XU,
          tiaoWenNumber: 8764,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 5,
          ke: DiZhi.XU,
          tiaoWenNumber: 8133,
        ),
      ],
      DiZhi.CHOU: [
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 1,
          ke: DiZhi.CHOU,
          tiaoWenNumber: 5986,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 2,
          ke: DiZhi.CHOU,
          tiaoWenNumber: 8169,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 3,
          ke: DiZhi.CHOU,
          tiaoWenNumber: 8491,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 4,
          ke: DiZhi.CHOU,
          tiaoWenNumber: 5958,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 5,
          ke: DiZhi.CHOU,
          tiaoWenNumber: 8394,
        ),
      ],
      DiZhi.WEI: [
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 1,
          ke: DiZhi.WEI,
          tiaoWenNumber: 8416,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 2,
          ke: DiZhi.WEI,
          tiaoWenNumber: 5889,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 3,
          ke: DiZhi.WEI,
          tiaoWenNumber: 8877,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 4,
          ke: DiZhi.WEI,
          tiaoWenNumber: 8532,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.jia,
          order: 5,
          ke: DiZhi.WEI,
          tiaoWenNumber: 8487,
        ),
      ],
    },
    DouJiaYiType.yi: {
      DiZhi.YIN: [
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 1,
          ke: DiZhi.YIN,
          tiaoWenNumber: 1545,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 2,
          ke: DiZhi.YIN,
          tiaoWenNumber: 2524,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 3,
          ke: DiZhi.YIN,
          tiaoWenNumber: 3936,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 4,
          ke: DiZhi.YIN,
          tiaoWenNumber: 2016,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 5,
          ke: DiZhi.YIN,
          tiaoWenNumber: 8555,
        ),
      ],
      DiZhi.SHEN: [
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 1,
          ke: DiZhi.SHEN,
          tiaoWenNumber: 3168,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 2,
          ke: DiZhi.SHEN,
          tiaoWenNumber: 1053,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 3,
          ke: DiZhi.SHEN,
          tiaoWenNumber: 2461,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 4,
          ke: DiZhi.SHEN,
          tiaoWenNumber: 1599,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 5,
          ke: DiZhi.SHEN,
          tiaoWenNumber: 5839,
        ),
      ],
      DiZhi.SI: [
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 1,
          ke: DiZhi.SI,
          tiaoWenNumber: 5339,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 2,
          ke: DiZhi.SI,
          tiaoWenNumber: 6041,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 3,
          ke: DiZhi.SI,
          tiaoWenNumber: 6773,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 4,
          ke: DiZhi.SI,
          tiaoWenNumber: 7366,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 5,
          ke: DiZhi.SI,
          tiaoWenNumber: 7659,
        ),
      ],
      DiZhi.HAI: [
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 1,
          ke: DiZhi.HAI,
          tiaoWenNumber: 2456,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 2,
          ke: DiZhi.HAI,
          tiaoWenNumber: 3289,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 3,
          ke: DiZhi.HAI,
          tiaoWenNumber: 4409,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 4,
          ke: DiZhi.HAI,
          tiaoWenNumber: 5346,
        ),
        DouJiaYiNumber(
          type: DouJiaYiType.yi,
          order: 5,
          ke: DiZhi.HAI,
          tiaoWenNumber: 6474,
        ),
      ],
    },
  };
}
