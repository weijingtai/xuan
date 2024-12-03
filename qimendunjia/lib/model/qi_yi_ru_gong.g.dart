// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qi_yi_ru_gong.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiYiRuGong _$QiYiRuGongFromJson(Map<String, dynamic> json) => QiYiRuGong(
      gong: $enumDecode(_$HouTianGuaEnumMap, json['gong']),
      qiYi: $enumDecode(_$TianGanEnumMap, json['qiYi']),
      geJuName: json['geJuName'] as String,
      description: json['description'] as String,
      geJuJiXiong: $enumDecode(_$JiXiongEnumEnumMap, json['geJuJiXiong']),
    );

Map<String, dynamic> _$QiYiRuGongToJson(QiYiRuGong instance) =>
    <String, dynamic>{
      'gong': _$HouTianGuaEnumMap[instance.gong]!,
      'qiYi': _$TianGanEnumMap[instance.qiYi]!,
      'geJuName': instance.geJuName,
      'description': instance.description,
      'geJuJiXiong': _$JiXiongEnumEnumMap[instance.geJuJiXiong]!,
    };

const _$HouTianGuaEnumMap = {
  HouTianGua.Kan: '坎',
  HouTianGua.Kun: '坤',
  HouTianGua.Zhen: '震',
  HouTianGua.Xun: '巽',
  HouTianGua.Qian: '乾',
  HouTianGua.Dui: '兑',
  HouTianGua.Gen: '艮',
  HouTianGua.Li: '离',
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
