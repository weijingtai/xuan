import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/shen_sha_di_zhi.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/models/shen_sha_tian_gan.dart';
import 'package:common/module.dart';
import 'package:common/utils/collections_utils.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:tuple/tuple.dart';

class ShenShaManager {
  List<TianGanShenSha> tianGanShenSha = [];
  List<DiZhiShenSha> yearDiZhiShenSha = [];
  List<DiZhiShenSha> monthDiZhiShenSha = [];
  List<GanZhiShenSha> ganZhiShenSha = [];
  List<BundledShenSha> bundledShenSha = [];
  List<OtherShenSha> otherShenSha = [];

  ShenSha qingTian = ShenSha("擎天", JiXiongEnum.PING, [
    "擎天五行属火",
    "象征着力量、担当、支撑、成就，在面对困难时有能力支撑起一定的局面，并且在事业、工作等方面可能会取得一定的成就，成为团队或家庭中的重要支柱。",
    "男怕擎天，女怕游奕",
  ], [
    "甲子、庚午、乙亥、辛巳、丙戌、壬辰、丁酉、戊申、癸丑、己未；子",
    "己巳、甲戌、庚辰、乙酉、辛卯、丙辰、壬寅、丁未、戊午、癸亥；卯",
    "庚寅、辛丑，壬子；辰",
    "戊辰、癸酉、己卯、甲申、乙未、丙午、丁巳；巳",
    "己丑、庚子、辛亥、壬戌、戊寅；午",
    "乙巳、丁卯、甲午、丙戌、癸未；未",
    "丙寅、壬申、丁丑、戊子、己亥、庚戌、辛酉；申",
    "乙卯、甲辰、癸巳；酉",
    "乙丑、辛未、丙子、壬午、丁亥、戊戌、己酉、甲寅、庚申；戌",
    "癸卯；亥",
  ]);
  ShenSha youYi = ShenSha("游奕", JiXiongEnum.PING, [
    "游奕五行属水",
    "与擎天为对宫",
    "象征着变动、奔波、游走，预示着命主在流年中可能会有较多的出行、搬迁、工作变动等情况，生活不太安定，需要不断适应新的环境和变化。",
    "男怕擎天，女怕游奕",
  ], [
    "甲子、庚午、乙亥、辛巳、丙戌、壬辰、丁酉、戊申、癸丑、己未；午",
    "己巳、甲戌、庚辰、乙酉、辛卯、丙辰、壬寅、丁未、戊午、癸亥；酉",
    "庚寅、辛丑，壬子；戌",
    "戊辰、癸酉、己卯、甲申、乙未、丙午、丁巳；亥",
    "己丑、庚子、辛亥、壬戌、戊寅；子",
    "乙巳、丁卯、甲午、丙戌、癸未；丑",
    "丙寅、壬申、丁丑、戊子、己亥、庚戌、辛酉；申",
    "乙卯、甲辰、癸巳；卯",
    "乙丑、辛未、丙子、壬午、丁亥、戊戌、己酉、甲寅、庚申；辰",
    "癸卯；巳",
  ]);

  ShenSha kongWang = ShenSha("空亡", JiXiongEnum.PING, [
    "空宫内神煞",
  ], [
    "甲子、丙寅、戊辰、庚午、壬申；戌",
    "乙丑、丁卯、己巳、辛未、癸酉；亥",
    "甲戌、丙子、戊寅、庚辰、壬午；申",
    "乙亥、丁丑、己卯、辛巳、癸未；酉",
    "甲申、丙子、戊寅、庚辰、壬午；午",
    "乙酉、丁亥、己丑、辛卯、癸巳；未",
    "甲午、丙申、戊戌、庚子、壬寅；辰",
    "乙未、丁酉、己亥、辛丑、癸卯；巳",
    "甲辰、丙午、戊申、庚戌、壬子；寅",
    "乙巳、丁未、己酉、辛亥、癸丑；卯",
    "甲寅、丙辰、戊午、庚申、壬戌；子",
    "乙卯、丁巳、己未、辛酉、癸亥；丑",
  ]);
  ShenSha guXu = ShenSha("孤虚", JiXiongEnum.PING, [
    "孤虚五行属土",
    "与空亡为对宫",
  ], [
    "甲子、丙寅、戊辰、庚午、壬申；辰",
    "乙丑、丁卯、己巳、辛未、癸酉；巳",
    "甲戌、丙子、戊寅、庚辰、壬午；寅",
    "乙亥、丁丑、己卯、辛巳、癸未；卯",
    "甲申、丙子、戊寅、庚辰、壬午；子",
    "乙酉、丁亥、己丑、辛卯、癸巳；丑",
    "甲午、丙申、戊戌、庚子、壬寅；戌",
    "乙未、丁酉、己亥、辛丑、癸卯；亥",
    "甲辰、丙午、戊申、庚戌、壬子；申",
    "乙巳、丁未、己酉、辛亥、癸丑；酉",
    "甲寅、丙辰、戊午、庚申、壬戌；午",
    "乙卯、丁巳、己未、辛酉、癸亥；未",
  ]);
  ShenShaManager({
    required this.tianGanShenSha,
    required this.yearDiZhiShenSha,
    required this.monthDiZhiShenSha,
    required this.ganZhiShenSha,
    required this.bundledShenSha,
    required this.otherShenSha,
  });

  // 宫位逆时针数
  // 天干顺时针数
  static EnumTwelveGong _countingGong(EnumTwelveGong countingFromGong,
      TianGan startCountingGan, TianGan endCountingGan) {
    final startCountingFromGong = countingFromGong;

    final starCountingAt = startCountingGan;
    final endCountingAt = endCountingGan;

    final countingSeq = CollectUtils.changeSeq(
        starCountingAt, TianGan.listAll.reversed.toList());
    final countingIndex = countingSeq.indexOf(endCountingAt);

    final countingGongSeq = CollectUtils.changeSeq(
        startCountingFromGong, EnumTwelveGong.listAll.reversed.toList());

    return countingGongSeq[countingIndex];
  }

  // 宫位逆时针数
  // 地支逆时针数
  static EnumTwelveGong _countingDiZhi(EnumTwelveGong countingFromGong,
      DiZhi starCountingZhi, DiZhi endCountingZhi) {
    final startCountingFromGong = countingFromGong;

    final endCountingAt = endCountingZhi;
    final starCountingAt = starCountingZhi;

    final countingSeq =
        CollectUtils.changeSeq(starCountingAt, DiZhi.listAll.reversed.toList());
    final countingIndex = countingSeq.indexOf(endCountingAt);

    final countingGongSeq = CollectUtils.changeSeq(
        startCountingFromGong, EnumTwelveGong.listAll.reversed.toList());

    return countingGongSeq[countingIndex];
  }

  // 斗杓，戌时加临月建宫，顺子丑寅...亥，数到生时，即为斗杓
  static EnumTwelveGong generateDouBiao(JiaZi monthJiaZi, JiaZi hourJiaZi) {
    // 以戌加在月建宫，顺数至生时即时。
    // 如卯月午时，则戌加在卯，则亥加在辰，子加在巳。。午加亥。则亥为斗标所在。
    final startCountingFromGong =
        EnumTwelveGong.getEnumTwelveGongByZhi(monthJiaZi.zhi);
    final endCountingAt = hourJiaZi.zhi;
    // const starCountingAt = DiZhi.XU;

    final countingTimeZhi = CollectUtils.changeSeq(DiZhi.XU, DiZhi.listAll);
    final targetIndex = countingTimeZhi.indexOf(endCountingAt);
    final countingGongSeq =
        CollectUtils.changeSeq(startCountingFromGong, EnumTwelveGong.listAll);

    return countingGongSeq[targetIndex];
    // return _countingDiZhi(startCountingFromGong, starCountingAt, endCountingAt);
  }

  // 天禄卦气
  static EnumTwelveGong generateGuaQiShenShaMapper(
      JiaZi yearJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) {
    // 即以年干依纳甲开始，由宫数起。如乾纳壬甲，则甲壬生人，将壬加在亥（即乾）逆数至昼日夜月，看得什么干，此干的禄宫即卦气宫
    // （如甲生人昼生，太阳在酉宫，则将甲加在亥上，逆数，甲加亥，乙加戌，丙加酉，酉为太阳所在，即得出丙，丙的禄为巳，则巳宫为卦气所在）
    // 天禄之余，与禄贵事交切。问对云，官贵命无卦气，安能食天禄。
    final stopCountingGong = isDayBirth ? sunGong : moonGong;
    final startCountingGong = EightGua_NaJia_Gong[yearJiaZi.gan.naJiaGua]!;
    final tianGanFrom = yearJiaZi.gan;
    final countingGongSeq = CollectUtils.changeSeq(
        startCountingGong, EnumTwelveGong.listAll.reversed.toList());
    final countingNnumber = countingGongSeq.indexOf(stopCountingGong);

    final countinTianGanSeq =
        CollectUtils.changeSeq(tianGanFrom, TianGan.listAll);
    final countingTianGan = [...countinTianGanSeq, ...countinTianGanSeq];
    final countinTianGan = countingTianGan[countingNnumber];
    final DiZhi luZhi = TwelveZhangSheng.getLuZhi(countinTianGan);
    final EnumTwelveGong luGong = EnumTwelveGong.getEnumTwelveGongByZhi(luZhi);
    return luGong;
  }

  Map<EnumTwelveGong, List<ShenSha>> calculate(
      JiaZi yearJiaZi,
      JiaZi monthJiaZi,
      JiaZi hourJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) {
    final result = <EnumTwelveGong, List<ShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      result[e] = [];
    });
    // 斗杓
    final douBiaoGong = generateDouBiao(monthJiaZi, hourJiaZi);
    result[douBiaoGong]!.add(otherShenSha.firstWhere((t) => t.name == "斗杓"));

    // 其他神煞 卦气、禄卦(天禄卦气)、岁殿、月廉
    final otherShenShaMapper = generateOtherShenShaMapper(
        yearJiaZi, monthJiaZi, mingGong, sunGong, moonGong, isDayBirth);
    otherShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞 空亡、孤虚、擎天、游奕
    final kongWangGongMapper = calculateGanZhiShenSha(yearJiaZi);
    kongWangGongMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 驾前、驾后、驿马神煞
    final bundledShenShaMapper = generateBundledShenSha(yearJiaZi);
    bundledShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞
    final tianGanShenShaMapper = generateTianGanShenShaMapper(yearJiaZi);
    tianGanShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 年 地支神煞
    final yearDiZhiShenShaMapper = generateYearDiZhiShenShaMapper(yearJiaZi);
    yearDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 月 地支神煞
    final monthDiZhiShenShaMapper = generateMonthDiZhiShenShaMapper(monthJiaZi);
    monthDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });
    return result;
  }

  Map<EnumTwelveGong, List<OtherShenSha>> generateOtherShenShaMapper(
      JiaZi yearJiaZi,
      JiaZi monthJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) {
    final result = <EnumTwelveGong, List<OtherShenSha>>{};
    // 卦气
    final EnumTwelveGong guaQiGong =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    result[guaQiGong] = [otherShenSha.firstWhere((t) => t.name == "卦气")];
    // 禄卦
    final luGong = generateGuaQiShenShaMapper(
        yearJiaZi, mingGong, sunGong, moonGong, isDayBirth);
    if (!result.containsKey(luGong)) {
      result[luGong] = [];
    }
    result[luGong]!.add(otherShenSha.firstWhere((t) => t.name == "禄卦"));
    // 岁殿, 从生年年支上起甲，数至生年年干，对应宫位即为岁殿
    final suiDianGong = generateSuiDian(yearJiaZi);
    if (!result.containsKey(suiDianGong)) {
      result[suiDianGong] = [];
    }
    result[suiDianGong]!.add(otherShenSha.firstWhere((t) => t.name == "岁殿"));

    // 月廉
    // 申宫 起正月，顺时针数到生月，对应宫位即为月廉
    final yueLianGong = generateYueLian(monthJiaZi);
    if (!result.containsKey(yueLianGong)) {
      result[yueLianGong] = [];
    }
    result[yueLianGong]!.add(otherShenSha.firstWhere((t) => t.name == "月廉"));
    return result;
  }

  static EnumTwelveGong generateYueLian(JiaZi monthJiaZi) {
    final gongList =
        CollectUtils.changeSeq(EnumTwelveGong.Shen, EnumTwelveGong.listAll);
    final targetIndex = CollectUtils.changeSeq(DiZhi.YIN, DiZhi.listAll)
        .indexOf(monthJiaZi.diZhi);
    return gongList[targetIndex];
  }

  static EnumTwelveGong generateSuiDian(JiaZi yearJiaZi) {
    final orderedYearZhiSeq =
        CollectUtils.changeSeq(yearJiaZi.diZhi, DiZhi.values);
    final yearGan = yearJiaZi.gan;
    int targetIndex = TianGan.values.indexOf(yearGan);
    DiZhi dizhi = orderedYearZhiSeq[targetIndex];
    final suiDianGong = EnumTwelveGong.getEnumTwelveGongByZhi(dizhi);
    return suiDianGong;
  }

  // 计算其他神煞
  // 孤虚、空亡、擎天、游奕
  Map<EnumTwelveGong, List<ShenSha>> calculateGanZhiShenSha(JiaZi yearJiaZi) {
    final result = <EnumTwelveGong, List<ShenSha>>{};
    ganZhiShenSha.forEach((sh) {
      sh.locationMapper.entries.forEach((e) {
        if (e.value.contains(yearJiaZi)) {
          final gong = EnumTwelveGong.getEnumTwelveGongByZhi(e.key);
          result[gong] = [sh];
        }
      });
    });
    return result;
  }

  Map<EnumTwelveGong, List<TianGanShenSha>> generateTianGanShenShaMapper(
      JiaZi yearJiaZi) {
    // 生成天干神煞映射
    final tianGanShenShaMapper = <EnumTwelveGong, List<TianGanShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      tianGanShenShaMapper[e] = [];
    });
    for (var i = 0; i < tianGanShenSha.length; i++) {
      final tianGanShenShaItem = tianGanShenSha[i];
      DiZhi atDiZhi = tianGanShenShaItem.locationMapper[yearJiaZi.gan]!;
      tianGanShenShaMapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!
          .add(tianGanShenShaItem);
    }
    return tianGanShenShaMapper;
  }

  Map<EnumTwelveGong, List<DiZhiShenSha>> generateYearDiZhiShenShaMapper(
      JiaZi yearJiaZi) {
    // 生成地支神煞映射
    final yearDiZhiShenShaMapper = <EnumTwelveGong, List<DiZhiShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      yearDiZhiShenShaMapper[e] = [];
    });

    for (var i = 0; i < yearDiZhiShenSha.length; i++) {
      final yearDiZhiShenShaItem = yearDiZhiShenSha[i];
      DiZhi atDiZhi = yearDiZhiShenShaItem.locationMapper[yearJiaZi.zhi]!;
      yearDiZhiShenShaMapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!
          .add(yearDiZhiShenShaItem);
    }

    return yearDiZhiShenShaMapper;
    // 生成十二宫的地支神煞映射
    // return Map.fromEntries(yearDiZhiShenShaMapper.entries.map((entry) {
    //   return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
    //       entry.value.toList());
    // }));
  }

  Map<EnumTwelveGong, List<GanZhiShenSha>> generateGanZhiShenShaMapper(
      JiaZi yearJiaZi) {
    // 生成地支神煞映射
    final ganzhiShenShaMapper = <EnumTwelveGong, List<GanZhiShenSha>>{};
    ganZhiShenSha.forEach((e) {
      e.locationMapper.forEach((key, value) {
        if (value.contains(yearJiaZi)) {
          final gong = EnumTwelveGong.getEnumTwelveGongByZhi(key);
          if (ganzhiShenShaMapper[gong] == null) {
            ganzhiShenShaMapper[gong] = [];
          }
          ganzhiShenShaMapper[gong]!.add(e);
        }
      });
    });
    return ganzhiShenShaMapper;
  }

  Map<EnumTwelveGong, List<DiZhiShenSha>> generateMonthDiZhiShenShaMapper(
      JiaZi monthJiaZi) {
    // 生成地支神煞映射
    final monthDiZhiShenShaMapper = <DiZhi, List<DiZhiShenSha>>{};

    DiZhi.listAll.forEach((e) {
      monthDiZhiShenShaMapper[e] = [];
    });

    for (var i = 0; i < monthDiZhiShenSha.length; i++) {
      final monthDiZhiShenShaItem = monthDiZhiShenSha[i];
      DiZhi atDiZhi = monthDiZhiShenShaItem.locationMapper[monthJiaZi.zhi]!;
      monthDiZhiShenShaMapper[atDiZhi]!.add(monthDiZhiShenShaItem);
    }

    // 生成十二宫的地支神煞映射
    return Map.fromEntries(monthDiZhiShenShaMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  Future<Map<EnumTwelveGong, List<TianGanShenSha>>>
      generateTianGanShenShaMapperFromJson(JiaZi yearJiaZi) async {
    // 加载天干神煞数据
    final tianGanData =
        await rootBundle.loadString('assets/shen_sha/74_tiangan_shensha.json');
    final tianGanList = json.decode(tianGanData) as List;
    tianGanShenSha =
        tianGanList.map((e) => TianGanShenSha.fromJson(e)).toList();

    // 生成天干神煞映射
    final tianGanShenShaMapper = <DiZhi, List<TianGanShenSha>>{};
    DiZhi.listAll.map((e) {
      tianGanShenShaMapper[e] = [];
    });

    for (var i = 0; i < tianGanShenSha.length; i++) {
      final tianGanShenShaItem = tianGanShenSha[i];
      DiZhi atDiZhi = tianGanShenShaItem.locationMapper[yearJiaZi.gan]!;
      tianGanShenShaMapper[atDiZhi]!.add(tianGanShenShaItem);
    }
    // 生成十二宫的天干神煞映射
    return Map.fromEntries(tianGanShenShaMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  Future<Map<EnumTwelveGong, List<DiZhiShenSha>>>
      generateYearDiZhiShenShaMapperFromJson(JiaZi yearJiaZi) async {
    // 生成地支神煞映射
    final yearDiZhiShenShaMapper = <DiZhi, List<DiZhiShenSha>>{};
    DiZhi.listAll.map((e) {
      yearDiZhiShenShaMapper[e] = [];
    });

    for (var i = 0; i < yearDiZhiShenSha.length; i++) {
      final yearDiZhiShenShaItem = yearDiZhiShenSha[i];
      DiZhi atDiZhi = yearDiZhiShenShaItem.locationMapper[yearJiaZi.zhi]!;
      yearDiZhiShenShaMapper[atDiZhi]!.add(yearDiZhiShenShaItem);
    }

    // 生成十二宫的地支神煞映射
    return Map.fromEntries(yearDiZhiShenShaMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  Future<Map<EnumTwelveGong, List<DiZhiShenSha>>>
      generateMonthDiZhiShenShaMapperFromJson(JiaZi monthJiaZi) async {
    // 生成地支神煞映射
    final monthDiZhiShenShaMapper = <DiZhi, List<DiZhiShenSha>>{};
    DiZhi.listAll.map((e) {
      monthDiZhiShenShaMapper[e] = [];
    });

    for (var i = 0; i < monthDiZhiShenSha.length; i++) {
      final monthDiZhiShenShaItem = monthDiZhiShenSha[i];
      DiZhi atDiZhi = monthDiZhiShenShaItem.locationMapper[monthJiaZi.zhi]!;
      monthDiZhiShenShaMapper[atDiZhi]!.add(monthDiZhiShenShaItem);
    }

    // 生成十二宫的地支神煞映射
    return Map.fromEntries(monthDiZhiShenShaMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBundledShenSha(
      JiaZi yearGanZhi) {
    // 根据年支获得太岁所在位置
    final yearZhi = yearGanZhi.zhi;

    final beforeJiaList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.beforeJia)
        .toList();
    final afterJiaList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.afterJia)
        .toList();
    final beforeHorseSuiList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.beforeHorse)
        .toList();
    final yearTaiSuiGong =
        EnumTwelveGong.getEnumTwelveGongByZhi(yearGanZhi.zhi);
    // 获取驾前
    final beforeJia = generateBeforeTaiSui(yearTaiSuiGong, beforeJiaList);
    final afterJia = generateAfterTaiSui(yearTaiSuiGong, afterJiaList);
    final beforeHorse = generateBeforeHorse(yearGanZhi, beforeHorseSuiList);

    final result = <EnumTwelveGong, List<BundledShenSha>>{};
    for (EnumTwelveGong gong in EnumTwelveGong.listAll) {
      result[gong] = [];
      if (beforeJia.containsKey(gong)) {
        result[gong]!.addAll(beforeJia[gong]!);
      }
      if (afterJia.containsKey(gong)) {
        result[gong]!.addAll(afterJia[gong]!);
      }
      if (beforeHorse.containsKey(gong)) {
        result[gong]!.addAll(beforeHorse[gong]!);
      }
    }
    return result;
    // return {
    //   ...beforeJia,
    //   ...afterJia,
    //   ...beforeHorse,
    // };
  }

  Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> generateBeforeTaiShenSha(
      JiaZi yearGanZhi) {
    // 根据年支获得太岁所在位置
    final yearZhi = yearGanZhi.zhi;
    // 根据太岁所在位置获得太岁所在宫位
    final yearTaiSuiGong = EnumTwelveGong.getEnumTwelveGongByZhi(yearZhi);
    return EnumBeforeTaiSuiShenSha.getByTiaSui(yearTaiSuiGong);
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeTaiSui(
      EnumTwelveGong taiSui, List<BundledShenSha> shenShaList) {
    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    shenShaList.forEach((e) {
      int index = (e.offset + taiSuiAt) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      if (!result.containsKey(gong)) {
        result[gong] = [];
      }
      result[gong]!.add(e);
    });
    return result;
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateAfterTaiSui(
      EnumTwelveGong taiSui, List<BundledShenSha> shenShaList) {
    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    // 红鸾
    int hongLuanAtDiZhiIndex =
        EnumAfterTaiSuiShenSha.getHongLuanPositionByDiZhiOrder(taiSuiAt);

    DiZhi hongLuanAtDiZhi = DiZhi.getByOrder(hongLuanAtDiZhiIndex + 1);

    // 红鸾
    shenShaList.whereNot((t) => t.name == "红鸾").forEach((e) {
      int index = (e.offset + hongLuanAtDiZhiIndex) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      if (!result.containsKey(gong)) {
        result[gong] = [];
      }
      result[gong]!.add(e);
    });

    // 红鸾位置
    EnumTwelveGong hongLuanAtGong = EnumTwelveGong.getEnumTwelveGongByZhi(
        DiZhi.getByOrder(hongLuanAtDiZhiIndex + 1));

    BundledShenSha hongLuan = shenShaList.firstWhere((t) => t.name == "红鸾");

    if (!result.containsKey(hongLuanAtGong)) {
      result[hongLuanAtGong] = [];
    }
    result[hongLuanAtGong]!.add(hongLuan);
    return result;
  }

  Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> generateAfterTaiShenSha(
      JiaZi yearGanZhi) {
    // 根据年支获得太岁所在位置
    final yearZhi = yearGanZhi.zhi;
    // 根据太岁所在位置获得太岁所在宫位
    final yearTaiSuiGong = EnumTwelveGong.getEnumTwelveGongByZhi(yearZhi);
    return EnumAfterTaiSuiShenSha.getByTiaSui(yearTaiSuiGong);
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeHorse(
      JiaZi yearGanZhi, List<BundledShenSha> beforeHorseList) {
    final yearHouseDiZhi = DiZhiSanHe.getHorseBySingleDiZhi(yearGanZhi.zhi);
    final yearHouseGong = EnumTwelveGong.getEnumTwelveGongByZhi(yearHouseDiZhi);

    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    beforeHorseList.forEach((e) {
      int index = (e.offset + yearHouseGong.index) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      result[gong] = [e];
    });
    return result;
  }

  Map<EnumTwelveGong, EnumShenShaBeforeHouseStar> generateBeforeHouseStar(
      JiaZi yearGanZhi) {
    // 根据年支获得太岁所在位置
    final yearHouseStar = DiZhiSanHe.getHorseBySingleDiZhi(yearGanZhi.zhi);
    // 根据太岁所在位置获得太岁所在宫位
    return EnumShenShaBeforeHouseStar.getByHousePosition(
        EnumTwelveGong.getEnumTwelveGongByZhi(yearHouseStar));
  }
}
