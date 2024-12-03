// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ten_gan_ke_ying.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenGanKeYing _$TenGanKeYingFromJson(Map<String, dynamic> json) => TenGanKeYing(
      juName: json['juName'] as String,
      shortExplain: json['shortExplain'] as String,
      longExplain: json['longExplain'] as String?,
      zhu: (json['zhu'] as List<dynamic>?)
          ?.map((e) => TenGanKeYingZhu.fromJson(e as Map<String, dynamic>))
          .toList(),
      yiXiang: json['yiXiang'] as String?,
      diseaseAtGongMapper:
          (json['diseaseAtGongMapper'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      xiangList: (json['xiangList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      others: (json['others'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
    )..thingOnLocation = json['thingOnLocation'] as String?;

Map<String, dynamic> _$TenGanKeYingToJson(TenGanKeYing instance) =>
    <String, dynamic>{
      'juName': instance.juName,
      'shortExplain': instance.shortExplain,
      'longExplain': instance.longExplain,
      'zhu': instance.zhu,
      'yiXiang': instance.yiXiang,
      'diseaseAtGongMapper': instance.diseaseAtGongMapper,
      'xiangList': instance.xiangList,
      'thingOnLocation': instance.thingOnLocation,
      'others': instance.others,
    };

TenGanKeYingZhu _$TenGanKeYingZhuFromJson(Map<String, dynamic> json) =>
    TenGanKeYingZhu(
      author: json['author'] as String?,
      content: json['content'] as String,
    );

Map<String, dynamic> _$TenGanKeYingZhuToJson(TenGanKeYingZhu instance) =>
    <String, dynamic>{
      'author': instance.author,
      'content': instance.content,
    };
