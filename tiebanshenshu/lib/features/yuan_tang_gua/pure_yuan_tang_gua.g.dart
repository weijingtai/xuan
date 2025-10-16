// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pure_yuan_tang_gua.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YuanTangYao _$YuanTangYaoFromJson(Map<String, dynamic> json) =>
    YuanTangYao(
        order: $enumDecode(_$EnumYaoOrderEnumMap, json['order']),
        yinYang: $enumDecode(_$YinYangEnumMap, json['yinYang']),
        isYuanTang: json['isYuanTang'] as bool? ?? false,
        yangTangZhiList: (json['yangTangZhiList'] as List<dynamic>?)
            ?.map((e) => $enumDecode(_$DiZhiEnumMap, e))
            .toList(),
      )
      ..naJia = $enumDecodeNullable(_$TianGanEnumMap, json['naJia'])
      ..naZhi = $enumDecodeNullable(_$DiZhiEnumMap, json['naZhi'])
      ..liuQin = $enumDecodeNullable(_$LiuQinEnumMap, json['liuQin'])
      ..sixShou = $enumDecodeNullable(_$Enum6ShouEnumMap, json['sixShou'])
      ..isShiYao = json['isShiYao'] as bool
      ..isYingYao = json['isYingYao'] as bool;

Map<String, dynamic> _$YuanTangYaoToJson(YuanTangYao instance) =>
    <String, dynamic>{
      'order': _$EnumYaoOrderEnumMap[instance.order]!,
      'yinYang': _$YinYangEnumMap[instance.yinYang]!,
      'naJia': _$TianGanEnumMap[instance.naJia],
      'naZhi': _$DiZhiEnumMap[instance.naZhi],
      'liuQin': _$LiuQinEnumMap[instance.liuQin],
      'sixShou': _$Enum6ShouEnumMap[instance.sixShou],
      'isShiYao': instance.isShiYao,
      'isYingYao': instance.isYingYao,
      'yangTangZhiList': instance.yangTangZhiList
          ?.map((e) => _$DiZhiEnumMap[e]!)
          .toList(),
      'isYuanTang': instance.isYuanTang,
    };

const _$EnumYaoOrderEnumMap = {
  EnumYaoOrder.init: '初',
  EnumYaoOrder.second: '二',
  EnumYaoOrder.third: '三',
  EnumYaoOrder.fourth: '四',
  EnumYaoOrder.fifth: '五',
  EnumYaoOrder.top: '上',
  EnumYaoOrder.none: '无',
};

const _$YinYangEnumMap = {YinYang.YANG: '阳', YinYang.YIN: '阴'};

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

const _$LiuQinEnumMap = {
  LiuQin.JI_SHEN: '己身',
  LiuQin.XIONG_DI: '兄弟',
  LiuQin.FU_MU: '父母',
  LiuQin.QI_CAI: '妻财',
  LiuQin.GUAN_GUI: '官鬼',
  LiuQin.ZI_SUN: '子孙',
};

const _$Enum6ShouEnumMap = {
  Enum6Shou.qingLong: '青龙',
  Enum6Shou.zhuQue: '朱雀',
  Enum6Shou.gouChen: '勾陈',
  Enum6Shou.tengShe: '腾蛇',
  Enum6Shou.baiHu: '白虎',
  Enum6Shou.xuanWu: '玄武',
};

PureYuanTangGua _$PureYuanTangGuaFromJson(Map<String, dynamic> json) =>
    PureYuanTangGua(
      gua: $enumDecode(_$Enum64GuaEnumMap, json['gua']),
      yaoList: (json['yaoList'] as List<dynamic>)
          .map((e) => YuanTangYao.fromJson(e as Map<String, dynamic>))
          .toList(),
      yuanTangYao: $enumDecode(_$EnumYaoOrderEnumMap, json['yuanTangYao']),
    );

Map<String, dynamic> _$PureYuanTangGuaToJson(PureYuanTangGua instance) =>
    <String, dynamic>{
      'gua': _$Enum64GuaEnumMap[instance.gua]!,
      'yaoList': instance.yaoList,
      'yuanTangYao': _$EnumYaoOrderEnumMap[instance.yuanTangYao]!,
    };

const _$Enum64GuaEnumMap = {
  Enum64Gua.qian_wei_tian: '乾',
  Enum64Gua.tian_feng_gou: '姤',
  Enum64Gua.tian_shan_dun: '遁',
  Enum64Gua.tian_di_pi: '否',
  Enum64Gua.feng_di_guan: '观',
  Enum64Gua.shan_di_bo: '剥',
  Enum64Gua.huo_di_jin: '晋',
  Enum64Gua.huo_tian_da_you: '大有',
  Enum64Gua.dui_wei_ze: '兑',
  Enum64Gua.ze_shui_kun: '困',
  Enum64Gua.ze_di_cui: '萃',
  Enum64Gua.ze_shan_xian: '咸',
  Enum64Gua.shui_shan_jian: '蹇',
  Enum64Gua.di_shan_qian: '谦',
  Enum64Gua.lei_shan_xiao_gu: '小过',
  Enum64Gua.lei_ze_gui_mei: '归妹',
  Enum64Gua.li_wei_huo: '离',
  Enum64Gua.huo_shan_lv: '旅',
  Enum64Gua.huo_feng_ding: '鼎',
  Enum64Gua.huo_shui_wei_ji: '未济',
  Enum64Gua.shan_shui_meng: '蒙',
  Enum64Gua.feng_shui_huan: '涣',
  Enum64Gua.tian_shui_song: '讼',
  Enum64Gua.tian_huo_tong_ren: '同人',
  Enum64Gua.zhen_wei_lei: '震',
  Enum64Gua.lei_di_yu: '豫',
  Enum64Gua.lei_shui_jie: '解',
  Enum64Gua.lei_feng_heng: '恒',
  Enum64Gua.di_feng_sheng: '升',
  Enum64Gua.shui_feng_jing: '井',
  Enum64Gua.ze_feng_da_guo: '大过',
  Enum64Gua.ze_lei_sui: '随',
  Enum64Gua.xun_wei_feng: '巽',
  Enum64Gua.feng_tian_xiao_xu: '小畜',
  Enum64Gua.feng_huo_jia_ren: '家人',
  Enum64Gua.feng_lei_yi: '益',
  Enum64Gua.tian_lei_wu_wang: '无妄',
  Enum64Gua.huo_lei_shi_he: '噬嗑',
  Enum64Gua.shan_lei_yi: '颐',
  Enum64Gua.shan_feng_gu: '蛊',
  Enum64Gua.kan_wei_shui: '坎',
  Enum64Gua.shui_ze_jie: '节',
  Enum64Gua.shui_lei_tun: '屯',
  Enum64Gua.shui_huo_ji_ji: '既济',
  Enum64Gua.ze_huo_ge: '革',
  Enum64Gua.lei_huo_feng: '丰',
  Enum64Gua.di_huo_ming_yi: '明夷',
  Enum64Gua.di_shui_shi: '师',
  Enum64Gua.gen_wei_shan: '艮',
  Enum64Gua.shan_huo_bi: '贲',
  Enum64Gua.shan_tian_da_xu: '大畜',
  Enum64Gua.shan_ze_sun: '损',
  Enum64Gua.huo_ze_kui: '睽',
  Enum64Gua.tian_ze_lv: '履',
  Enum64Gua.feng_ze_zhong_fu: '中孚',
  Enum64Gua.feng_shan_jian: '渐',
  Enum64Gua.kun_wei_di: '坤',
  Enum64Gua.di_lei_fu: '复',
  Enum64Gua.di_ze_lin: '临',
  Enum64Gua.di_tian_tai: '泰',
  Enum64Gua.lei_tian_da_zhuang: '大壮',
  Enum64Gua.ze_tian_guai: '夬',
  Enum64Gua.shui_tian_xu: '需',
  Enum64Gua.shui_di_bi: '比',
};

YuanTangDaYunPeriod _$YuanTangDaYunPeriodFromJson(Map<String, dynamic> json) =>
    YuanTangDaYunPeriod(
      order: $enumDecode(_$EnumYaoOrderEnumMap, json['order']),
      yinYang: $enumDecode(_$YinYangEnumMap, json['yinYang']),
      startAge: (json['startAge'] as num).toInt(),
      diZhiList: (json['diZhiList'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DiZhiEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$YuanTangDaYunPeriodToJson(
  YuanTangDaYunPeriod instance,
) => <String, dynamic>{
  'order': _$EnumYaoOrderEnumMap[instance.order]!,
  'yinYang': _$YinYangEnumMap[instance.yinYang]!,
  'startAge': instance.startAge,
  'diZhiList': instance.diZhiList?.map((e) => _$DiZhiEnumMap[e]!).toList(),
};

YuanTangLiuYearGua _$YuanTangLiuYearGuaFromJson(Map<String, dynamic> json) =>
    YuanTangLiuYearGua(
      age: (json['age'] as num).toInt(),
      yearIndex: (json['yearIndex'] as num).toInt(),
      gua: $enumDecode(_$Enum64GuaEnumMap, json['gua']),
      guaSource: json['guaSource'] as String,
      dayunPeriod: YuanTangDaYunPeriod.fromJson(
        json['dayunPeriod'] as Map<String, dynamic>,
      ),
      changedYao: $enumDecode(_$EnumYaoOrderEnumMap, json['changedYao']),
      previousGua: $enumDecodeNullable(_$Enum64GuaEnumMap, json['previousGua']),
    );

Map<String, dynamic> _$YuanTangLiuYearGuaToJson(YuanTangLiuYearGua instance) =>
    <String, dynamic>{
      'age': instance.age,
      'yearIndex': instance.yearIndex,
      'gua': _$Enum64GuaEnumMap[instance.gua]!,
      'guaSource': instance.guaSource,
      'dayunPeriod': instance.dayunPeriod,
      'changedYao': _$EnumYaoOrderEnumMap[instance.changedYao]!,
      'previousGua': _$Enum64GuaEnumMap[instance.previousGua],
    };

YuanTangLiuMonthGua _$YuanTangLiuMonthGuaFromJson(Map<String, dynamic> json) =>
    YuanTangLiuMonthGua(
      month: (json['month'] as num).toInt(),
      isYangMonth: json['isYangMonth'] as bool,
      gua: $enumDecode(_$Enum64GuaEnumMap, json['gua']),
      age: (json['age'] as num).toInt(),
      changedYaoIndex: $enumDecode(
        _$EnumYaoOrderEnumMap,
        json['changedYaoIndex'],
      ),
      sourceGua: $enumDecodeNullable(_$Enum64GuaEnumMap, json['sourceGua']),
      yingYaoIndex: $enumDecodeNullable(
        _$EnumYaoOrderEnumMap,
        json['yingYaoIndex'],
      ),
    );

Map<String, dynamic> _$YuanTangLiuMonthGuaToJson(
  YuanTangLiuMonthGua instance,
) => <String, dynamic>{
  'month': instance.month,
  'isYangMonth': instance.isYangMonth,
  'gua': _$Enum64GuaEnumMap[instance.gua]!,
  'age': instance.age,
  'changedYaoIndex': _$EnumYaoOrderEnumMap[instance.changedYaoIndex]!,
  'sourceGua': _$Enum64GuaEnumMap[instance.sourceGua],
  'yingYaoIndex': _$EnumYaoOrderEnumMap[instance.yingYaoIndex],
};
