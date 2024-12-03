// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eight_door_ke_ying.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EightDoorKeYing _$EightDoorKeYingFromJson(Map<String, dynamic> json) =>
    EightDoorKeYing(
      door: $enumDecode(_$EightDoorEnumEnumMap, json['door']),
      fixDoor: $enumDecode(_$EightDoorEnumEnumMap, json['fixDoor']),
      dongJingYing: $enumDecode(_$YinYangEnumMap, json['dongJingYing']),
      description: json['description'] as String,
    );

Map<String, dynamic> _$EightDoorKeYingToJson(EightDoorKeYing instance) =>
    <String, dynamic>{
      'door': _$EightDoorEnumEnumMap[instance.door]!,
      'fixDoor': _$EightDoorEnumEnumMap[instance.fixDoor]!,
      'dongJingYing': _$YinYangEnumMap[instance.dongJingYing]!,
      'description': instance.description,
    };

const _$EightDoorEnumEnumMap = {
  EightDoorEnum.XIU: '休门',
  EightDoorEnum.SHENG: '生门',
  EightDoorEnum.SHANG: '伤门',
  EightDoorEnum.DU: '杜门',
  EightDoorEnum.JING_S: '景门',
  EightDoorEnum.SI: '死门',
  EightDoorEnum.JING_W: '惊门',
  EightDoorEnum.KAI: '开门',
  EightDoorEnum.CENTER: '中央',
};

const _$YinYangEnumMap = {
  YinYang.YANG: '阳',
  YinYang.YIN: '阴',
};
