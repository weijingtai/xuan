// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_formula.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HuangJiFormulaBasePart _$HuangJiFormulaBasePartFromJson(
  Map<String, dynamic> json,
) => HuangJiFormulaBasePart(
  baseNumberType: $enumDecode(_$BaseNumberTypeEnumMap, json['baseNumberType']),
  numberSource: $enumDecode(_$NumberSourceEnumMap, json['numberSource']),
);

Map<String, dynamic> _$HuangJiFormulaBasePartToJson(
  HuangJiFormulaBasePart instance,
) => <String, dynamic>{
  'baseNumberType': _$BaseNumberTypeEnumMap[instance.baseNumberType]!,
  'numberSource': _$NumberSourceEnumMap[instance.numberSource]!,
};

const _$BaseNumberTypeEnumMap = {
  BaseNumberType.basic: '基础',
  BaseNumberType.primary: '主数',
  BaseNumberType.secondary: '次数',
  BaseNumberType.tiaoWen: '条文',
  BaseNumberType.selection: '选择',
};

const _$NumberSourceEnumMap = {
  NumberSource.yuanHui: '元会',
  NumberSource.yunShi: '运世',
};

HuangJiFormulaOtherPart _$HuangJiFormulaOtherPartFromJson(
  Map<String, dynamic> json,
) => HuangJiFormulaOtherPart(
  forBaseOperator: $enumDecode(
    _$EnumHuangJiOperatorEnumMap,
    json['forBaseOperator'],
  ),
);

Map<String, dynamic> _$HuangJiFormulaOtherPartToJson(
  HuangJiFormulaOtherPart instance,
) => <String, dynamic>{
  'forBaseOperator': _$EnumHuangJiOperatorEnumMap[instance.forBaseOperator]!,
};

const _$EnumHuangJiOperatorEnumMap = {
  EnumHuangJiOperator.add: 'add',
  EnumHuangJiOperator.merge: 'merge',
};

HuangJiFormulaOtherSingleNumberPart
_$HuangJiFormulaOtherSingleNumberPartFromJson(Map<String, dynamic> json) =>
    HuangJiFormulaOtherSingleNumberPart(
      forBaseOperator: $enumDecode(
        _$EnumHuangJiOperatorEnumMap,
        json['forBaseOperator'],
      ),
      fourZhuGanZhiType: $enumDecode(
        _$FourZhuGanZhiTypeEnumMap,
        json['fourZhuGanZhiType'],
      ),
      fourZhuName: $enumDecode(_$FourZhuNameEnumMap, json['fourZhuName']),
      numberPlace: $enumDecode(_$EnumNumberPlaceEnumMap, json['numberPlace']),
    );

Map<String, dynamic> _$HuangJiFormulaOtherSingleNumberPartToJson(
  HuangJiFormulaOtherSingleNumberPart instance,
) => <String, dynamic>{
  'forBaseOperator': _$EnumHuangJiOperatorEnumMap[instance.forBaseOperator]!,
  'fourZhuGanZhiType': _$FourZhuGanZhiTypeEnumMap[instance.fourZhuGanZhiType]!,
  'fourZhuName': _$FourZhuNameEnumMap[instance.fourZhuName]!,
  'numberPlace': _$EnumNumberPlaceEnumMap[instance.numberPlace]!,
};

const _$FourZhuGanZhiTypeEnumMap = {
  FourZhuGanZhiType.gan: '天干',
  FourZhuGanZhiType.zhi: '地支',
};

const _$FourZhuNameEnumMap = {
  FourZhuName.year: '年柱',
  FourZhuName.month: '月柱',
  FourZhuName.day: '日柱',
  FourZhuName.time: '时柱',
};

const _$EnumNumberPlaceEnumMap = {
  EnumNumberPlace.Units: '个',
  EnumNumberPlace.Tens: '十',
  EnumNumberPlace.Hundreds: '百',
  EnumNumberPlace.Thousands: '千',
};

HuangJiTiaoWenCalculationFormula _$HuangJiTiaoWenCalculationFormulaFromJson(
  Map<String, dynamic> json,
) => HuangJiTiaoWenCalculationFormula(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  basePart: HuangJiFormulaBasePart.fromJson(
    json['basePart'] as Map<String, dynamic>,
  ),
  otherPartsList: (json['otherPartsList'] as List<dynamic>)
      .map((e) => HuangJiFormulaOtherPart.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HuangJiTiaoWenCalculationFormulaToJson(
  HuangJiTiaoWenCalculationFormula instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'basePart': instance.basePart,
  'otherPartsList': instance.otherPartsList,
};
