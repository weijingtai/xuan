// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pure_six_yao_gua.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuaYao _$GuaYaoFromJson(Map<String, dynamic> json) => GuaYao(
  yinYang: $enumDecode(_$YinYangEnumMap, json['yinYang']),
  naJia: $enumDecodeNullable(_$TianGanEnumMap, json['naJia']),
  naZhi: $enumDecodeNullable(_$DiZhiEnumMap, json['naZhi']),
  liuQin: $enumDecodeNullable(_$LiuQinEnumMap, json['liuQin']),
);

Map<String, dynamic> _$GuaYaoToJson(GuaYao instance) => <String, dynamic>{
  'yinYang': _$YinYangEnumMap[instance.yinYang]!,
  'naJia': _$TianGanEnumMap[instance.naJia],
  'naZhi': _$DiZhiEnumMap[instance.naZhi],
  'liuQin': _$LiuQinEnumMap[instance.liuQin],
};

const _$YinYangEnumMap = {YinYang.YANG: '阳', YinYang.YIN: '阴'};

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

const _$LiuQinEnumMap = {
  LiuQin.JI_SHEN: '己身',
  LiuQin.XIONG_DI: '兄弟',
  LiuQin.FU_MU: '父母',
  LiuQin.QI_CAI: '妻财',
  LiuQin.GUAN_GUI: '官鬼',
  LiuQin.ZI_SUN: '子孙',
};

PureSixYaoGua _$PureSixYaoGuaFromJson(Map<String, dynamic> json) =>
    PureSixYaoGua(
      gua: $enumDecode(_$Gua64EnumEnumMap, json['gua']),
      topGua: $enumDecode(_$Enum8GuaEnumMap, json['topGua']),
      bottomGua: $enumDecode(_$Enum8GuaEnumMap, json['bottomGua']),
      yaoList: (json['yaoList'] as List<dynamic>)
          .map((e) => GuaYao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PureSixYaoGuaToJson(PureSixYaoGua instance) =>
    <String, dynamic>{
      'gua': _$Gua64EnumEnumMap[instance.gua]!,
      'topGua': _$Enum8GuaEnumMap[instance.topGua]!,
      'bottomGua': _$Enum8GuaEnumMap[instance.bottomGua]!,
      'yaoList': instance.yaoList,
    };

const _$Gua64EnumEnumMap = {
  Gua64Enum.qian_wei_tian: '乾',
  Gua64Enum.tian_feng_gou: '姤',
  Gua64Enum.tian_shan_dun: '遁',
  Gua64Enum.tian_di_pi: '否',
  Gua64Enum.feng_di_guan: '观',
  Gua64Enum.shan_di_bo: '剥',
  Gua64Enum.huo_di_jin: '晋',
  Gua64Enum.huo_tian_da_you: '大有',
  Gua64Enum.dui_wei_ze: '兑',
  Gua64Enum.ze_shui_kun: '困',
  Gua64Enum.ze_di_cui: '萃',
  Gua64Enum.ze_shan_xian: '咸',
  Gua64Enum.shui_shan_jian: '蹇',
  Gua64Enum.di_shan_qi: '谦',
  Gua64Enum.lei_shan_xiao_gu: '小过',
  Gua64Enum.lei_ze_gui_mei: '归妹',
  Gua64Enum.li_wei_huo: '离',
  Gua64Enum.huo_shan_lv: '旅',
  Gua64Enum.huo_feng_ding: '鼎',
  Gua64Enum.huo_shui_wei_ji: '未济',
  Gua64Enum.shan_shui_meng: '蒙',
  Gua64Enum.feng_shui_huan: '涣',
  Gua64Enum.tian_shui_song: '讼',
  Gua64Enum.tian_huo_tong_ren: '同人',
  Gua64Enum.zhen_wei_lei: '震',
  Gua64Enum.lei_di_yu: '豫',
  Gua64Enum.lei_shui_jie: '解',
  Gua64Enum.lei_feng_heng: '恒',
  Gua64Enum.di_feng_shen: '升',
  Gua64Enum.shui_feng_jing: '井',
  Gua64Enum.ze_feng_da_guo: '大过',
  Gua64Enum.ze_lei_sui: '随',
  Gua64Enum.xun_wei_feng: '巽',
  Gua64Enum.feng_tian_xiao_xu: '小畜',
  Gua64Enum.feng_huo_jia_ren: '家人',
  Gua64Enum.feng_lei_yi: '益',
  Gua64Enum.tian_lei_wu_wang: '无妄',
  Gua64Enum.huo_lei_shi_he: '噬嗑',
  Gua64Enum.shan_lei_yi: '颐',
  Gua64Enum.shan_feng_gu: '蛊',
  Gua64Enum.kan_wei_shui: '坎',
  Gua64Enum.shui_ze_jie: '节',
  Gua64Enum.shui_lei_tun: '屯',
  Gua64Enum.shui_huo_ji_ji: '既济',
  Gua64Enum.ze_huo_ge: '革',
  Gua64Enum.lei_huo_feng: '丰',
  Gua64Enum.di_huo_ming_yi: '明夷',
  Gua64Enum.di_shui_shi: '师',
  Gua64Enum.gen_wei_shan: '艮',
  Gua64Enum.shan_huo_ben: '贲',
  Gua64Enum.shan_tian_da_xu: '大畜',
  Gua64Enum.shan_ze_sun: '损',
  Gua64Enum.huo_ze_kui: '睽',
  Gua64Enum.tian_ze_lv: '履',
  Gua64Enum.feng_ze_zhong_fu: '中孚',
  Gua64Enum.feng_shan_jian: '渐',
  Gua64Enum.kun_wei_di: '坤',
  Gua64Enum.di_lei_fu: '复',
  Gua64Enum.di_ze_lin: '临',
  Gua64Enum.di_tian_tai: '泰',
  Gua64Enum.lei_tian_da_zhuang: '大壮',
  Gua64Enum.ze_tian_guai: '夬',
  Gua64Enum.shui_tian_xu: '需',
  Gua64Enum.shui_di_bi: '比',
};

const _$Enum8GuaEnumMap = {
  Enum8Gua.Qian: '乾',
  Enum8Gua.Dui: '兑',
  Enum8Gua.Li: '离',
  Enum8Gua.Zhen: '震',
  Enum8Gua.Xun: '巽',
  Enum8Gua.Kan: '坎',
  Enum8Gua.Gen: '艮',
  Enum8Gua.Kun: '坤',
};
