import 'package:json_annotation/json_annotation.dart';

part 'huang_ji_number.g.dart';

enum FourZhuName {
  @JsonValue("年柱")
  year("年", "年柱"),
  @JsonValue("月柱")
  month("月", "月柱"),
  @JsonValue("日柱")
  day("日", "日柱"),
  @JsonValue("时柱")
  time("时", "时柱");

  final String name;
  final String fullname;

  const FourZhuName(this.name, this.fullname);
}

enum FourZhuGanZhiType {
  @JsonValue("天干")
  gan("干", "天干"),
  @JsonValue("地支")
  zhi("支", "地支");

  final String name;
  final String fullname;

  const FourZhuGanZhiType(this.name, this.fullname);
}

enum EnumHuangJiOperator {
  // 相加
  add,
  // 合并, 两数按照"先后位置合在一起写"，如：1和1 => 11
  merge,
}

enum EnumNumberPlace {
  @JsonValue("个")
  // 个位
  Units("个", 1),
  // 十位
  @JsonValue("十")
  Tens("十", 10),
  // 百位
  @JsonValue("百")
  Hundreds("百", 100),
  // 千位
  @JsonValue("千")
  Thousands("千", 1000);

  final int factor;
  final String name;
  const EnumNumberPlace(this.name, this.factor);
}

enum BaseNumberType {
  @JsonValue("基础")
  basic,
  @JsonValue("主数")
  primary,
  @JsonValue("次数")
  secondary,

  @JsonValue("条文")
  tiaoWen,

  @JsonValue("选择")
  selection;

  BaseNumberType get next {
    switch (this) {
      case basic:
        return primary;
      case primary:
        return secondary;
      case secondary:
        return tiaoWen;
      case tiaoWen:
        return tiaoWen;
      case selection:
        return selection;
      default:
        return basic;
    }
  }
}

enum NumberSource {
  @JsonValue("元会")
  yuanHui,
  @JsonValue("运世")
  yunShi,
  @JsonValue("六亲考刻")
  sixQinCorrectKe,
}

@JsonSerializable()
class HuangJiNumber {
  String name;
  String description;
  int number;

  HuangJiNumber({
    required this.name,
    required this.description,
    required this.number,
  });

  @override
  factory HuangJiNumber.fromJson(Map<String, dynamic> json) =>
      _$HuangJiNumberFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HuangJiNumberToJson(this);
}

@JsonSerializable()
class HuangJiBaseNumber extends HuangJiNumber {
  // 用于表述 皇极取数法中，元会、运势基本数，以及基本数一、基本数二、和用户做种选择参与运算的符合条文数
  BaseNumberType baseNumberType;
  NumberSource numberSource;
  int orinialNumber;
  int get number {
    return checkToTiaoWenNumber(orinialNumber);
  }

  HuangJiBaseNumber({
    required String name,
    required String description,
    required this.orinialNumber,
    required this.baseNumberType,
    required this.numberSource,
  }) : super(
         name: name,
         description: description,
         number: HuangJiBaseNumber.checkToTiaoWenNumber(orinialNumber),
       );
  static int checkToTiaoWenNumber(int originalNumber) {
    if (originalNumber > 13000) {
      return originalNumber - 12000;
    }
    return originalNumber;
  }

  @override
  factory HuangJiBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$HuangJiBaseNumberFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HuangJiBaseNumberToJson(this);

  HuangJiBaseNumber copyWith({
    String? name,
    String? description,
    int? number,
    BaseNumberType? baseNumberType,
    NumberSource? numberSource,
  }) {
    return HuangJiBaseNumber(
      name: name ?? this.name,
      description: description ?? this.description,
      orinialNumber: number ?? this.orinialNumber,
      baseNumberType: baseNumberType ?? this.baseNumberType,
      numberSource: numberSource ?? this.numberSource,
    );
  }
}

@JsonSerializable()
class HuangJiPlacedNumber extends HuangJiNumber {
  /// 用户保存 计算的数据 ，如年干千位、时干个位等
  final int raw;
  final EnumNumberPlace place;

  final FourZhuName fourZhuName;
  final FourZhuGanZhiType ganZhiType;

  HuangJiPlacedNumber({
    required super.number,
    required super.name,
    required super.description,
    required this.raw,
    required this.place,

    required this.fourZhuName,
    required this.ganZhiType,
  });

  static HuangJiPlacedNumber generateWithGanZhi(
    int raw,
    EnumNumberPlace place,
    FourZhuName fourZhuName,
    FourZhuGanZhiType ganZhiType,
  ) {
    return HuangJiPlacedNumber(
      raw: raw,
      place: place,
      number: raw * place.factor,
      name: "${fourZhuName.name}${ganZhiType.name}(${place.name})",
      description:
          "${fourZhuName.fullname}${ganZhiType.fullname}的太玄数，放置在${place.name}上(N * ${place.factor})",
      fourZhuName: fourZhuName,
      ganZhiType: ganZhiType,
    );
  }

  @override
  factory HuangJiPlacedNumber.fromJson(Map<String, dynamic> json) =>
      _$HuangJiPlacedNumberFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HuangJiPlacedNumberToJson(this);

  @override
  HuangJiPlacedNumber copyWith({
    int? raw,
    int? number,
    EnumNumberPlace? place,
    String? name,
    String? description,
    FourZhuName? fourZhuName,
    FourZhuGanZhiType? ganZhiType,
  }) {
    return HuangJiPlacedNumber(
      raw: raw ?? this.raw,
      number: number ?? this.number,
      place: place ?? this.place,
      name: name ?? this.name,
      description: description ?? this.description,
      fourZhuName: fourZhuName ?? this.fourZhuName,
      ganZhiType: ganZhiType ?? this.ganZhiType,
    );
  }
}

@JsonSerializable()
class HuangJiOperatedNumber extends HuangJiNumber {
  /// 用于存储两数以及其关系
  /// 如 日柱加数，日柱互合数
  ///
  final HuangJiNumber scr1;
  final HuangJiNumber scr2;
  final EnumHuangJiOperator operator;

  HuangJiOperatedNumber({
    required super.name,
    required super.description,
    required this.scr1,
    required this.scr2,
    required this.operator,
  }) : super(number: _calculateNumber(scr1.number, scr2.number, operator));

  /// 根据操作符计算结果
  static int _calculateNumber(
    int scr1,
    int scr2,
    EnumHuangJiOperator operator,
  ) {
    switch (operator) {
      case EnumHuangJiOperator.add:
        return scr1 + scr2;
      case EnumHuangJiOperator.merge:
        // 合并：两数按照"先后位置合在一起写"，如：1和1 => 11
        return int.parse('$scr1$scr2');
    }
  }

  factory HuangJiOperatedNumber.fromJson(Map<String, dynamic> json) =>
      _$HuangJiOperatedNumberFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiOperatedNumberToJson(this);
}

@JsonSerializable()
class HuangJiEachPart extends HuangJiNumber {
  // 用于表示 每个部分的顺序
  // 如：运世基础数 + 日干支互合数 + 时干个位数
  // HuangJiEachPart 1 -> `+ 日干互合数`
  // HuangJiEachPart 2 -> `+ 时干个位数`
  int order;
  EnumHuangJiOperator operator;
  HuangJiNumber huangJiNumber;

  HuangJiEachPart({
    required this.order,
    required super.name,
    required super.description,
    required this.operator,
    required this.huangJiNumber,
  }) : super(number: huangJiNumber.number);

  factory HuangJiEachPart.fromJson(Map<String, dynamic> json) =>
      _$HuangJiEachPartFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiEachPartToJson(this);

  HuangJiEachPart copyWith({
    int? order,
    String? name,
    String? description,
    EnumHuangJiOperator? operator,
    HuangJiNumber? huangJiNumber,
  }) {
    return HuangJiEachPart(
      order: order ?? this.order,
      name: name ?? this.name,
      description: description ?? this.description,
      operator: operator ?? this.operator,
      huangJiNumber: huangJiNumber ?? this.huangJiNumber,
    );
  }
}

@JsonSerializable()
class HuangJiTiaoWenNumber extends HuangJiNumber {
  String name;
  String description;
  int tiaoWenNumber;
  @override
  int get number => tiaoWenNumber;
  HuangJiBaseNumber huangJiBaseNumber;
  List<HuangJiNumber> parts;
  HuangJiTiaoWenNumber({
    required this.name,
    required this.description,
    required this.tiaoWenNumber,
    required this.huangJiBaseNumber,
    required this.parts,
  }) : super(name: name, description: description, number: tiaoWenNumber);

  factory HuangJiTiaoWenNumber.fromJson(Map<String, dynamic> json) =>
      _$HuangJiTiaoWenNumberFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiTiaoWenNumberToJson(this);

  HuangJiTiaoWenNumber copyWith({
    String? name,
    String? description,
    int? tiaoWenNumber,
    List<HuangJiEachPart>? parts,
    NumberSource? numberSource,
  }) {
    return HuangJiTiaoWenNumber(
      name: name ?? this.name,
      description: description ?? this.description,
      tiaoWenNumber: tiaoWenNumber ?? this.tiaoWenNumber,
      parts: parts ?? this.parts,
      huangJiBaseNumber: huangJiBaseNumber,
    );
  }
}
