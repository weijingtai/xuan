// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_strategy_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculationStrategyConfig _$CalculationStrategyConfigFromJson(
        Map<String, dynamic> json) =>
    CalculationStrategyConfig(
      ziStrategy: $enumDecode(_$ZiShiStrategyEnumMap, json['ziStrategy']),
      jieQiType: $enumDecode(_$JieQiTypeEnumMap, json['jieQiType']),
      jieQiStrategy: $enumDecode(_$JieQiStrategyEnumMap, json['jieQiStrategy']),
    );

Map<String, dynamic> _$CalculationStrategyConfigToJson(
        CalculationStrategyConfig instance) =>
    <String, dynamic>{
      'ziStrategy': _$ZiShiStrategyEnumMap[instance.ziStrategy]!,
      'jieQiType': _$JieQiTypeEnumMap[instance.jieQiType]!,
      'jieQiStrategy': _$JieQiStrategyEnumMap[instance.jieQiStrategy]!,
    };

const _$ZiShiStrategyEnumMap = {
  ZiShiStrategy.noDistinguishAt23: 'noDistinguishAt23',
  ZiShiStrategy.distinguishAt0FiveMouse: 'distinguishAt0FiveMouse',
  ZiShiStrategy.distinguishAt0Fixed: 'distinguishAt0Fixed',
  ZiShiStrategy.bandsStartAt0: 'bandsStartAt0',
  ZiShiStrategy.startFrom23: 'startFrom23',
  ZiShiStrategy.startFrom0: 'startFrom0',
  ZiShiStrategy.splitedZi: 'splitedZi',
};

const _$JieQiTypeEnumMap = {
  JieQiType.leveling: 'leveling',
  JieQiType.stabilizing: 'stabilizing',
};

const _$JieQiStrategyEnumMap = {
  JieQiStrategy.day: 'day',
  JieQiStrategy.hour: 'hour',
  JieQiStrategy.minute: 'minute',
};
