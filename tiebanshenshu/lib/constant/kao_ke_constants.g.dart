// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kao_ke_constants.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KaoEigthKeNumber _$KaoEigthKeNumberFromJson(Map<String, dynamic> json) =>
    KaoEigthKeNumber(
      shiChen: $enumDecode(_$DiZhiEnumMap, json['shiChen']),
      ke: $enumDecode(_$EigthKeEnumMap, json['ke']),
      cipherText: json['cipherText'] as String,
      originalText: json['originalText'] as String,
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
    );

Map<String, dynamic> _$KaoEigthKeNumberToJson(KaoEigthKeNumber instance) =>
    <String, dynamic>{
      'shiChen': _$DiZhiEnumMap[instance.shiChen]!,
      'ke': _$EigthKeEnumMap[instance.ke]!,
      'tiaoWenNumber': instance.tiaoWenNumber,
      'cipherText': instance.cipherText,
      'originalText': instance.originalText,
    };

const _$DiZhiEnumMap = {
  DiZhi.ZI: '子',
  DiZhi.CHOU: '丑',
  DiZhi.YIN: '寅',
  DiZhi.MAO: '卯',
  DiZhi.CHEN: '辰',
  DiZhi.SI: '巳',
  DiZhi.WU: '午',
  DiZhi.WEI: '未',
  DiZhi.SHEN: '申',
  DiZhi.YOU: '酉',
  DiZhi.XU: '戌',
  DiZhi.HAI: '亥',
};

const _$EigthKeEnumMap = {
  EigthKe.first: 1,
  EigthKe.second: 2,
  EigthKe.third: 3,
  EigthKe.fourth: 4,
  EigthKe.fifth: 5,
  EigthKe.sixth: 6,
  EigthKe.seventh: 7,
  EigthKe.eighth: 8,
};

KaoEigthKeTiaoWen _$KaoEigthKeTiaoWenFromJson(Map<String, dynamic> json) =>
    KaoEigthKeTiaoWen(
      shiChen: $enumDecode(_$DiZhiEnumMap, json['shiChen']),
      ke: $enumDecode(_$EigthKeEnumMap, json['ke']),
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
      tiaoWen: TiaoWenDataModel.fromJson(
        json['tiaoWen'] as Map<String, dynamic>,
      ),
      cipherText: json['cipherText'] as String,
      originalText: json['originalText'] as String,
    );

Map<String, dynamic> _$KaoEigthKeTiaoWenToJson(KaoEigthKeTiaoWen instance) =>
    <String, dynamic>{
      'shiChen': _$DiZhiEnumMap[instance.shiChen]!,
      'ke': _$EigthKeEnumMap[instance.ke]!,
      'tiaoWenNumber': instance.tiaoWenNumber,
      'cipherText': instance.cipherText,
      'originalText': instance.originalText,
      'tiaoWen': instance.tiaoWen,
    };

DouJiaYiNumber _$DouJiaYiNumberFromJson(Map<String, dynamic> json) =>
    DouJiaYiNumber(
      type: $enumDecode(_$DouJiaYiTypeEnumMap, json['type']),
      ke: $enumDecode(_$DiZhiEnumMap, json['ke']),
      order: (json['order'] as num).toInt(),
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
    );

Map<String, dynamic> _$DouJiaYiNumberToJson(DouJiaYiNumber instance) =>
    <String, dynamic>{
      'type': _$DouJiaYiTypeEnumMap[instance.type]!,
      'ke': _$DiZhiEnumMap[instance.ke]!,
      'order': instance.order,
      'tiaoWenNumber': instance.tiaoWenNumber,
    };

const _$DouJiaYiTypeEnumMap = {
  DouJiaYiType.dou: 'dou',
  DouJiaYiType.jia: 'jia',
  DouJiaYiType.yi: 'yi',
};

DouJiaYiTiaoWen _$DouJiaYiTiaoWenFromJson(Map<String, dynamic> json) =>
    DouJiaYiTiaoWen(
      ke: $enumDecode(_$DiZhiEnumMap, json['ke']),
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
      tiaoWen: TiaoWenDataModel.fromJson(
        json['tiaoWen'] as Map<String, dynamic>,
      ),
      type: $enumDecode(_$DouJiaYiTypeEnumMap, json['type']),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$DouJiaYiTiaoWenToJson(DouJiaYiTiaoWen instance) =>
    <String, dynamic>{
      'type': _$DouJiaYiTypeEnumMap[instance.type]!,
      'ke': _$DiZhiEnumMap[instance.ke]!,
      'order': instance.order,
      'tiaoWenNumber': instance.tiaoWenNumber,
      'tiaoWen': instance.tiaoWen,
    };

SixQinFenNumber _$SixQinFenNumberFromJson(Map<String, dynamic> json) =>
    SixQinFenNumber(
      shiChen: $enumDecode(_$DiZhiEnumMap, json['shiChen']),
      fen: (json['fen'] as num).toInt(),
      wifeInfo: json['wifeInfo'] as String,
      childInfo: json['childInfo'] as String,
      husbandInfo: json['husbandInfo'] as String,
    );

Map<String, dynamic> _$SixQinFenNumberToJson(SixQinFenNumber instance) =>
    <String, dynamic>{
      'shiChen': _$DiZhiEnumMap[instance.shiChen]!,
      'fen': instance.fen,
      'wifeInfo': instance.wifeInfo,
      'childInfo': instance.childInfo,
      'husbandInfo': instance.husbandInfo,
    };

SixQinFenNumberMapper _$SixQinFenNumberMapperFromJson(
  Map<String, dynamic> json,
) => SixQinFenNumberMapper(
  name: json['name'] as String,
  source: json['source'] as String,
  description: (json['description'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  shiChenKeMapper: (json['shiChenKeMapper'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$DiZhiEnumMap, k),
      (e as List<dynamic>)
          .map((e) => SixQinFenNumber.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$SixQinFenNumberMapperToJson(
  SixQinFenNumberMapper instance,
) => <String, dynamic>{
  'name': instance.name,
  'source': instance.source,
  'description': instance.description,
  'shiChenKeMapper': instance.shiChenKeMapper.map(
    (k, e) => MapEntry(_$DiZhiEnumMap[k]!, e.map((e) => e.toJson()).toList()),
  ),
};

SixQinKeNumber _$SixQinKeNumberFromJson(Map<String, dynamic> json) =>
    SixQinKeNumber(
      shiChen: $enumDecode(_$DiZhiEnumMap, json['shiChen']),
      ke: $enumDecode(_$EigthKeEnumMap, json['ke']),
      parentsInfo: json['parentsInfo'] as String,
      siblingsInfo: json['siblingsInfo'] as String,
      guaYaoInfo: json['guaYaoInfo'] as String,
    );

Map<String, dynamic> _$SixQinKeNumberToJson(SixQinKeNumber instance) =>
    <String, dynamic>{
      'shiChen': _$DiZhiEnumMap[instance.shiChen]!,
      'ke': _$EigthKeEnumMap[instance.ke]!,
      'parentsInfo': instance.parentsInfo,
      'siblingsInfo': instance.siblingsInfo,
      'guaYaoInfo': instance.guaYaoInfo,
    };

SixQinKeNumberMapper _$SixQinKeNumberMapperFromJson(
  Map<String, dynamic> json,
) => SixQinKeNumberMapper(
  name: json['name'] as String,
  source: json['source'] as String,
  description: (json['description'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  shiChenKeMapper: (json['shiChenKeMapper'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$DiZhiEnumMap, k),
      (e as List<dynamic>)
          .map((e) => SixQinKeNumber.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$SixQinKeNumberMapperToJson(
  SixQinKeNumberMapper instance,
) => <String, dynamic>{
  'name': instance.name,
  'source': instance.source,
  'description': instance.description,
  'shiChenKeMapper': instance.shiChenKeMapper.map(
    (k, e) => MapEntry(_$DiZhiEnumMap[k]!, e),
  ),
};

SixQinGongEach _$SixQinGongEachFromJson(Map<String, dynamic> json) =>
    SixQinGongEach(
      chiperText: json['chiperText'] as String,
      chiperNumber: (json['chiperNumber'] as num).toInt(),
      siblingsInfo: json['siblingsInfo'] as String?,
      yearGanZhi: $enumDecodeNullable(_$JiaZiEnumMap, json['yearGanZhi']),
    );

Map<String, dynamic> _$SixQinGongEachToJson(SixQinGongEach instance) =>
    <String, dynamic>{
      'chiperText': instance.chiperText,
      'chiperNumber': instance.chiperNumber,
      'siblingsInfo': instance.siblingsInfo,
      'yearGanZhi': _$JiaZiEnumMap[instance.yearGanZhi],
    };

const _$JiaZiEnumMap = {
  JiaZi.JIA_ZI: '甲子',
  JiaZi.YI_CHOU: '乙丑',
  JiaZi.BING_YIN: '丙寅',
  JiaZi.DING_MAO: '丁卯',
  JiaZi.WU_CHEN: '戊辰',
  JiaZi.JI_SI: '己巳',
  JiaZi.GENG_WU: '庚午',
  JiaZi.XIN_WEI: '辛未',
  JiaZi.REN_SHEN: '壬申',
  JiaZi.GUI_YOU: '癸酉',
  JiaZi.JIA_XU: '甲戌',
  JiaZi.YI_HAI: '乙亥',
  JiaZi.BING_ZI: '丙子',
  JiaZi.DING_CHOU: '丁丑',
  JiaZi.WU_YIN: '戊寅',
  JiaZi.JI_MAO: '己卯',
  JiaZi.GENG_CHEN: '庚辰',
  JiaZi.XIN_SI: '辛巳',
  JiaZi.REN_WU: '壬午',
  JiaZi.GUI_WEI: '癸未',
  JiaZi.JIA_SHEN: '甲申',
  JiaZi.YI_YOU: '乙酉',
  JiaZi.BING_XU: '丙戌',
  JiaZi.DING_HAI: '丁亥',
  JiaZi.WU_ZI: '戊子',
  JiaZi.JI_CHOU: '己丑',
  JiaZi.GENG_YIN: '庚寅',
  JiaZi.XIN_MAO: '辛卯',
  JiaZi.REN_CHEN: '壬辰',
  JiaZi.GUI_SI: '癸巳',
  JiaZi.JIA_WU: '甲午',
  JiaZi.YI_WEI: '乙未',
  JiaZi.BING_SHEN: '丙申',
  JiaZi.DING_YOU: '丁酉',
  JiaZi.WU_XU: '戊戌',
  JiaZi.JI_HAI: '己亥',
  JiaZi.GENG_ZI: '庚子',
  JiaZi.XIN_CHOU: '辛丑',
  JiaZi.REN_YIN: '壬寅',
  JiaZi.GUI_MAO: '癸卯',
  JiaZi.JIA_CHEN: '甲辰',
  JiaZi.YI_SI: '乙巳',
  JiaZi.BING_WU: '丙午',
  JiaZi.DING_WEI: '丁未',
  JiaZi.WU_SHEN: '戊申',
  JiaZi.JI_YOU: '己酉',
  JiaZi.GENG_XU: '庚戌',
  JiaZi.XIN_HAI: '辛亥',
  JiaZi.REN_ZI: '壬子',
  JiaZi.GUI_CHOU: '癸丑',
  JiaZi.JIA_YIN: '甲寅',
  JiaZi.YI_MAO: '乙卯',
  JiaZi.BING_CHEN: '丙辰',
  JiaZi.DING_SI: '丁巳',
  JiaZi.WU_WU: '戊午',
  JiaZi.JI_WEI: '己未',
  JiaZi.GENG_SHEN: '庚申',
  JiaZi.XIN_YOU: '辛酉',
  JiaZi.REN_XU: '壬戌',
  JiaZi.GUI_HAI: '癸亥',
};

SixQinGongInfo _$SixQinGongInfoFromJson(Map<String, dynamic> json) =>
    SixQinGongInfo(
      name: json['name'] as String,
      description: json['description'] as String,
      zhiMapper: (json['zhiMapper'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$DiZhiEnumMap, k),
          (e as List<dynamic>)
              .map((e) => SixQinGongEach.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      gongEachList: (json['gongEachList'] as List<dynamic>?)
          ?.map((e) => SixQinGongEach.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SixQinGongInfoToJson(SixQinGongInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'zhiMapper': instance.zhiMapper?.map(
        (k, e) => MapEntry(_$DiZhiEnumMap[k]!, e),
      ),
      'gongEachList': instance.gongEachList,
    };

SixQinGongEachTiaoWen _$SixQinGongEachTiaoWenFromJson(
  Map<String, dynamic> json,
) => SixQinGongEachTiaoWen(
  chiperText: json['chiperText'] as String,
  chiperNumber: (json['chiperNumber'] as num).toInt(),
  siblingsInfo: json['siblingsInfo'] as String?,
  yearGanZhi: $enumDecodeNullable(_$JiaZiEnumMap, json['yearGanZhi']),
  tiaoWen: TiaoWenDataModel.fromJson(json['tiaoWen'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SixQinGongEachTiaoWenToJson(
  SixQinGongEachTiaoWen instance,
) => <String, dynamic>{
  'chiperText': instance.chiperText,
  'chiperNumber': instance.chiperNumber,
  'siblingsInfo': instance.siblingsInfo,
  'yearGanZhi': _$JiaZiEnumMap[instance.yearGanZhi],
  'tiaoWen': instance.tiaoWen,
};
