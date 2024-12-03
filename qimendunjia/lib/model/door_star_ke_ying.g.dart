// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'door_star_ke_ying.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoorStarKeYing _$DoorStarKeYingFromJson(Map<String, dynamic> json) =>
    DoorStarKeYing(
      door: $enumDecode(_$EightDoorEnumEnumMap, json['door']),
      star: $enumDecode(_$NineStarsEnumEnumMap, json['star']),
      jiXiong: $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      description: json['description'] as String,
    );

Map<String, dynamic> _$DoorStarKeYingToJson(DoorStarKeYing instance) =>
    <String, dynamic>{
      'door': _$EightDoorEnumEnumMap[instance.door]!,
      'star': _$NineStarsEnumEnumMap[instance.star]!,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
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

const _$NineStarsEnumEnumMap = {
  NineStarsEnum.PENG: '天蓬',
  NineStarsEnum.REN: '天任',
  NineStarsEnum.CHONG: '天冲',
  NineStarsEnum.FU: '天辅',
  NineStarsEnum.YING: '天英',
  NineStarsEnum.RUI: '天芮',
  NineStarsEnum.ZHU: '天柱',
  NineStarsEnum.XIN: '天心',
  NineStarsEnum.QIN: '天禽',
};

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.DA_JI: '大吉',
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIAO_JI: '小吉',
  JiXiongEnum.PING: '平',
  JiXiongEnum.XIAO_XIONG: '小凶',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.DA_XIONG: '大凶',
  JiXiongEnum.WEI_ZHI: '未知',
};
