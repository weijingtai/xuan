// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ten_gan_ke_ying_ge_ju.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenGanKeYingGeJu _$TenGanKeYingGeJuFromJson(Map<String, dynamic> json) =>
    TenGanKeYingGeJu(
      tianPan: $enumDecode(_$TianGanEnumMap, json['tianPan']),
      diPan: $enumDecode(_$TianGanEnumMap, json['diPan']),
      jiXiong: $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      geJuNames:
          (json['geJuNames'] as List<dynamic>).map((e) => e as String).toList(),
      explains:
          (json['explains'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TenGanKeYingGeJuToJson(TenGanKeYingGeJu instance) =>
    <String, dynamic>{
      'tianPan': _$TianGanEnumMap[instance.tianPan]!,
      'diPan': _$TianGanEnumMap[instance.diPan]!,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'geJuNames': instance.geJuNames,
      'explains': instance.explains,
    };

const _$TianGanEnumMap = {
  TianGan.JIA: '甲',
  TianGan.YI: '乙',
  TianGan.BING: '丙',
  TianGan.DING: '丁',
  TianGan.WU: '戊',
  TianGan.JI: '己',
  TianGan.GENG: '庚',
  TianGan.XIN: '辛',
  TianGan.REN: '壬',
  TianGan.GUI: '癸',
  TianGan.KONG_WANG: '空亡',
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
