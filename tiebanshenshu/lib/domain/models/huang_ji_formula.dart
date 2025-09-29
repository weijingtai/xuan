import 'package:json_annotation/json_annotation.dart';
import 'huang_ji_number.dart';

part 'huang_ji_formula.g.dart';

@JsonSerializable()
class HuangJiFormulaBasePart {
  BaseNumberType baseNumberType;
  NumberSource numberSource;

  HuangJiFormulaBasePart({
    required this.baseNumberType,
    required this.numberSource,
  });

  factory HuangJiFormulaBasePart.fromJson(Map<String, dynamic> json) =>
      _$HuangJiFormulaBasePartFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiFormulaBasePartToJson(this);

  HuangJiFormulaBasePart copyWith({
    BaseNumberType? baseNumberType,
    NumberSource? numberSource,
  }) {
    return HuangJiFormulaBasePart(
      baseNumberType: baseNumberType ?? this.baseNumberType,
      numberSource: numberSource ?? this.numberSource,
    );
  }
}

@JsonSerializable()
class HuangJiFormulaOtherPart {
  final EnumHuangJiOperator forBaseOperator;

  HuangJiFormulaOtherPart({required this.forBaseOperator});

  factory HuangJiFormulaOtherPart.fromJson(Map<String, dynamic> json) =>
      _$HuangJiFormulaOtherPartFromJson(json);

  Map<String, dynamic> toJson() => _$HuangJiFormulaOtherPartToJson(this);

  HuangJiFormulaOtherPart copyWith({EnumHuangJiOperator? forBaseOperator}) {
    return HuangJiFormulaOtherPart(
      forBaseOperator: forBaseOperator ?? this.forBaseOperator,
    );
  }
}

@JsonSerializable()
class HuangJiFormulaOtherSingleNumberPart extends HuangJiFormulaOtherPart {
  final FourZhuGanZhiType fourZhuGanZhiType;
  final FourZhuName fourZhuName;
  final EnumNumberPlace numberPlace;

  HuangJiFormulaOtherSingleNumberPart({
    required super.forBaseOperator,
    required this.fourZhuGanZhiType,
    required this.fourZhuName,
    required this.numberPlace,
  });

  factory HuangJiFormulaOtherSingleNumberPart.fromJson(
    Map<String, dynamic> json,
  ) => _$HuangJiFormulaOtherSingleNumberPartFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HuangJiFormulaOtherSingleNumberPartToJson(this);

  HuangJiFormulaOtherSingleNumberPart copyWith({
    EnumHuangJiOperator? forBaseOperator,
    FourZhuGanZhiType? fourZhuGanZhiType,
    FourZhuName? fourZhuName,
    EnumNumberPlace? numberPlace,
  }) {
    return HuangJiFormulaOtherSingleNumberPart(
      forBaseOperator: forBaseOperator ?? this.forBaseOperator,
      fourZhuGanZhiType: fourZhuGanZhiType ?? this.fourZhuGanZhiType,
      fourZhuName: fourZhuName ?? this.fourZhuName,
      numberPlace: numberPlace ?? this.numberPlace,
    );
  }
}

// @JsonSerializable()
// class HuangJiFormulaOtherNumbersPart extends HuangJiFormulaOtherPart {
//   final EnumHuangJiOperator firstSecondOperator;
//   final FourZhuGanZhiType firstFourZhuGanZhiType;
//   final FourZhuName firstFourZhuName;
//   final FourZhuGanZhiType secondFourZhuGanZhiType;
//   final FourZhuName secondFourZhuName;

//   HuangJiFormulaOtherNumbersPart({
//     required super.forBaseOperator,
//     required this.firstSecondOperator,
//     required this.firstFourZhuGanZhiType,
//     required this.firstFourZhuName,
//     required this.secondFourZhuGanZhiType,
//     required this.secondFourZhuName,
//   });

//   factory HuangJiFormulaOtherNumbersPart.fromJson(Map<String, dynamic> json) =>
//       _$HuangJiFormulaOtherNumbersPartFromJson(json);

//   Map<String, dynamic> toJson() => _$HuangJiFormulaOtherNumbersPartToJson(this);

//   HuangJiFormulaOtherNumbersPart copyWith({
//     String? name,
//     String? description,
//     EnumHuangJiOperator? forBaseOperator,
//     EnumHuangJiOperator? firstSecondOperator,
//     FourZhuGanZhiType? firstFourZhuGanZhiType,
//     FourZhuName? firstFourZhuName,
//     FourZhuGanZhiType? secondFourZhuGanZhiType,
//     FourZhuName? secondFourZhuName,
//   }) {
//     return HuangJiFormulaOtherNumbersPart(
//       forBaseOperator: forBaseOperator ?? this.forBaseOperator,
//       firstSecondOperator: firstSecondOperator ?? this.firstSecondOperator,
//       firstFourZhuGanZhiType:
//           firstFourZhuGanZhiType ?? this.firstFourZhuGanZhiType,
//       firstFourZhuName: firstFourZhuName ?? this.firstFourZhuName,
//       secondFourZhuGanZhiType:
//           secondFourZhuGanZhiType ?? this.secondFourZhuGanZhiType,
//       secondFourZhuName: secondFourZhuName ?? this.secondFourZhuName,
//     );
//   }
// }

// @JsonSerializable()
// class HuangJiFormulaOtherMergedNumbersPart extends HuangJiFormulaOtherPart {
//   final EnumNumberPlace
//   maxNumberPlace; // 最大单位，如 ‘13’ maxNumberPlace = handurds 那么结果则为 ‘130’

//   /// Warning: first always is first, first:11 second:22 则 => "1122"
//   final FourZhuGanZhiType firstFourZhuGanZhiType;
//   final FourZhuName firstFourZhuName;
//   final FourZhuGanZhiType secondFourZhuGanZhiType;
//   final FourZhuName secondFourZhuName;

//   HuangJiFormulaOtherMergedNumbersPart({
//     required this.maxNumberPlace,
//     required this.firstFourZhuGanZhiType,
//     required this.firstFourZhuName,
//     required this.secondFourZhuGanZhiType,
//     required this.secondFourZhuName,
//     required super.forBaseOperator,
//   });

//   factory HuangJiFormulaOtherMergedNumbersPart.fromJson(
//     Map<String, dynamic> json,
//   ) => _$HuangJiFormulaOtherMergedNumbersPartFromJson(json);

//   Map<String, dynamic> toJson() =>
//       _$HuangJiFormulaOtherMergedNumbersPartToJson(this);

//   HuangJiFormulaOtherMergedNumbersPart copyWith({
//     String? name,
//     String? description,
//     EnumHuangJiOperator? forBaseOperator,
//     EnumNumberPlace? maxNumberPlace,
//     FourZhuGanZhiType? firstFourZhuGanZhiType,
//     FourZhuName? firstFourZhuName,
//     FourZhuGanZhiType? secondFourZhuGanZhiType,
//     FourZhuName? secondFourZhuName,
//   }) {
//     return HuangJiFormulaOtherMergedNumbersPart(
//       forBaseOperator: forBaseOperator ?? this.forBaseOperator,
//       maxNumberPlace: maxNumberPlace ?? this.maxNumberPlace,
//       firstFourZhuGanZhiType:
//           firstFourZhuGanZhiType ?? this.firstFourZhuGanZhiType,
//       firstFourZhuName: firstFourZhuName ?? this.firstFourZhuName,
//       secondFourZhuGanZhiType:
//           secondFourZhuGanZhiType ?? this.secondFourZhuGanZhiType,
//       secondFourZhuName: secondFourZhuName ?? this.secondFourZhuName,
//     );
//   }
// }

@JsonSerializable()
class HuangJiTiaoWenCalculationFormula {
  final int id;
  final String name;
  final String description;
  final HuangJiFormulaBasePart basePart;
  final List<HuangJiFormulaOtherPart> otherPartsList;

  HuangJiTiaoWenCalculationFormula({
    required this.id,
    required this.name,
    required this.description,
    required this.basePart,
    required this.otherPartsList,
  });

  factory HuangJiTiaoWenCalculationFormula.fromJson(
    Map<String, dynamic> json,
  ) => _$HuangJiTiaoWenCalculationFormulaFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HuangJiTiaoWenCalculationFormulaToJson(this);

  HuangJiTiaoWenCalculationFormula copyWith({
    int? id,
    String? name,
    String? description,
    HuangJiFormulaBasePart? basePart,
    List<HuangJiFormulaOtherPart>? otherPartsList,
  }) {
    return HuangJiTiaoWenCalculationFormula(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePart: basePart ?? this.basePart,
      otherPartsList: otherPartsList ?? this.otherPartsList,
    );
  }
}
