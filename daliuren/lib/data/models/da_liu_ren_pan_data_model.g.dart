// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_liu_ren_pan_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaLiuRenPanDataModel _$DaLiuRenPanDataModelFromJson(
        Map<String, dynamic> json) =>
    DaLiuRenPanDataModel(
      dayJiaZi: DaLiuRenPanDataModel._jiaZiFromJson(json['dayJiaZi'] as String),
      shiChen: DaLiuRenPanDataModel._diZhiFromJson(json['shiChen'] as String),
      yinYangDun:
          DaLiuRenPanDataModel._yinYangFromJson(json['yinYangDun'] as String),
      juNumberName: json['juNumberName'] as String,
      heavenPlate: (json['heavenPlate'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, DaLiuRenGongDataModel.fromJson(e as Map<String, dynamic>)),
      ),
      earthPlate: (json['earthPlate'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, DaLiuRenGongDataModel.fromJson(e as Map<String, dynamic>)),
      ),
      fourClass: FourClassDataModel.fromJson(
          json['fourClass'] as Map<String, dynamic>),
      threeChuan: ThreeChuanDataModel.fromJson(
          json['threeChuan'] as Map<String, dynamic>),
      nineZongMenName:
          $enumDecode(_$NineZongMenEnumMap, json['nineZongMenName']),
    );

Map<String, dynamic> _$DaLiuRenPanDataModelToJson(
        DaLiuRenPanDataModel instance) =>
    <String, dynamic>{
      'dayJiaZi': DaLiuRenPanDataModel._jiaZiToJson(instance.dayJiaZi),
      'shiChen': DaLiuRenPanDataModel._diZhiToJson(instance.shiChen),
      'juNumberName': instance.juNumberName,
      'heavenPlate':
          instance.heavenPlate.map((k, e) => MapEntry(k, e.toJson())),
      'earthPlate': instance.earthPlate.map((k, e) => MapEntry(k, e.toJson())),
      'fourClass': instance.fourClass.toJson(),
      'threeChuan': instance.threeChuan.toJson(),
      'nineZongMenName': _$NineZongMenEnumMap[instance.nineZongMenName]!,
      'yinYangDun': DaLiuRenPanDataModel._yinYangToJson(instance.yinYangDun),
    };

const _$NineZongMenEnumMap = {
  NineZongMen.ZEI_KE: '贼克',
  NineZongMen.BI_YONG: '比用',
  NineZongMen.SHE_HAI: '涉害',
  NineZongMen.YAO_KE: '遥克',
  NineZongMen.MAO_XING: '昴星',
  NineZongMen.BIE_ZE: '别责',
  NineZongMen.BA_ZHUAN: '八专',
  NineZongMen.FU_YIN: '伏吟',
  NineZongMen.FAN_YIN: '返吟',
  NineZongMen.UNKNOWN: '未知',
};
