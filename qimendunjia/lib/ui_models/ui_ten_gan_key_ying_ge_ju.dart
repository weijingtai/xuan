import 'package:common/enums.dart';

import '../model/ten_gan_ke_ying_ge_ju.dart';

class UITenGanKeYingGeJu {
  final HouTianGua gongGua;
  final TianGan tianGan;
  final TianGan diGan;
  final TenGanKeYingGeJu tianGeJu;
  final bool isTianGanDunJia; // 天干是遁甲
  final TenGanKeYingGeJu? tianDunJiaGeJu; // 天干为遁甲格局
  final bool isDiGanDunJia; // 地干是遁甲
  final TenGanKeYingGeJu? diDunJiaGeJu; // 地干为遁甲格局

  final TianGan? tianPanJiGan; // 本宫存在寄干，往往只考虑寄干为当值天干
  final TianGan? diPanJiGan; // 本宫存在寄干，往往只考虑寄干为当值天干
  final TenGanKeYingGeJu? tianPanJiGanGeJu; // 天盘寄干格局
  final TenGanKeYingGeJu? diPanJiGanGeJu; // 地盘 寄干格局
  final bool isTianJiGanJia; // 天盘寄干，寄干为遁甲干
  final bool isDiJiGanJia; // 地盘寄干，寄干为遁甲干
  final TenGanKeYingGeJu? tianJiGanJiaGeJu;
  final TenGanKeYingGeJu? diJiGanJiaGeJu;
  final TenGanKeYingGeJu? tianDiJiGanGeJu; // 天地盘同时为寄干 且寄干为值符天干 有可能为“遁甲”
  final TenGanKeYingGeJu? tianDiPanGanGeJu; // 天地盘同时遁甲 且天地盘位值符天干 有可能为“遁甲”
  final TenGanKeYingGeJu? tianDiJiaGanJiaGeJu; // 天地寄干同为甲 有可能为“遁甲”

  final TenGanKeYingGeJu? tianPanJiGanDiPanJia; // 天盘存在寄干 时 地盘干为遁甲
  final TenGanKeYingGeJu? tianDunJiaDiPanJi; // 天盘干为遁甲，地盘寄干

  UITenGanKeYingGeJu({
    required this.gongGua,
    required this.tianGan,
    required this.tianGeJu,
    required this.diGan,
    required this.isTianGanDunJia,
    required this.isDiGanDunJia,
    required this.tianDunJiaGeJu,
    required this.diDunJiaGeJu,
    required this.tianPanJiGan,
    required this.tianPanJiGanGeJu,
    required this.diPanJiGan,
    required this.diPanJiGanGeJu,
    required this.isTianJiGanJia,
    required this.isDiJiGanJia,
    required this.tianJiGanJiaGeJu,
    required this.diJiGanJiaGeJu,
    required this.tianDiJiGanGeJu,
    required this.tianDiPanGanGeJu,
    required this.tianDiJiaGanJiaGeJu,
    required this.tianPanJiGanDiPanJia,
    required this.tianDunJiaDiPanJi,
  });
}
