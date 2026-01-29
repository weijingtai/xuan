import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/shared/utils/collections_utils.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/utils/utils.dart' as gua_utils;

import '../../constant/constants.dart' as constants;
import 'pure_yuan_tang_gua.dart';
import 'yuan_tang_info_ext.dart';

enum YuanTangMonthType {
  monthYinYan("月阴阳", "1/3/5/7/9/11为【阳月】，2/4/6/8/10/12为【阴月】"),
  monthTokenYinYang("月令阴阳", "11/12/1/2/3/4为【阳令】，5/6/7/8/9/10为【阴令】");

  final String monthYingYangType;
  final String description;

  const YuanTangMonthType(this.monthYingYangType, this.description);
}

class YuanTangCalculator {
  /// 三元五宫映射表（当天数或地数为5时使用）
  /// 上元 男艮女坤
  /// 中元：阳男阴女 艮宫；阴男阳女 坤宫
  /// 下元 男离女兑
  static Map<YuanYunOrder, Map<Gender, Map<YinYang, Enum8Gua>>>
  threeYuan5GongMapper = {
    YuanYunOrder.upper: {
      Gender.male: {YinYang.YANG: Enum8Gua.Gen, YinYang.YIN: Enum8Gua.Gen},
      Gender.female: {YinYang.YANG: Enum8Gua.Kun, YinYang.YIN: Enum8Gua.Kun},
    },
    YuanYunOrder.middle: {
      Gender.male: {YinYang.YANG: Enum8Gua.Gen, YinYang.YIN: Enum8Gua.Kun},
      Gender.female: {YinYang.YANG: Enum8Gua.Kun, YinYang.YIN: Enum8Gua.Gen},
    },
    YuanYunOrder.lower: {
      Gender.male: {YinYang.YANG: Enum8Gua.Li, YinYang.YIN: Enum8Gua.Li},
      Gender.female: {YinYang.YANG: Enum8Gua.Dui, YinYang.YIN: Enum8Gua.Dui},
    },
  };

  /// 根据八字、年份阴阳、性别、三元五宫计算先天卦
  ///
  /// 参数：
  /// - [eightChars]: 八字对象
  /// - [yearYinYang]: 年份阴阳（"阳" / "阴"）
  /// - [gender]: 性别（"男" / "女"）
  /// - [threeYuan]: 三元（"上" / "中" / "下"）
  /// - [birthJieQi]: 出生节气（二十四节气） 用于计算 出生在哪个节气（冬至、夏至）之后
  /// - [monthType]: 月阴阳类型（"月阴阳" / "月令阴阳"）
  ///                + 1/3/5/7/9/11为【阳月】，2/4/6/8/10/12为【阴月】
  ///                + 11/12/1/2/3/4为【阳令】，5/6/7/8/9/10为【阴令】
  /// - [calanderType]: 历法类型（"阳历" / "阴历"）
  /// - [birthMonth]: 出生月份（1..12）
  YuanTangInfo calculate({
    required EightChars eightChars,
    required YinYang yearYinYang,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthJieQi,
    required YuanTangMonthType monthType,
    required CalanderType calanderType,
    required int birthMonth,
  }) {
    TwentyFourJieQi birthAfterJieQi = birthJieQi.yinYangDun.isYang
        ? TwentyFourJieQi.DONG_ZHI
        : TwentyFourJieQi.XIAO_HAN;

    // 计算先天卦并获取天地卦数据
    final (xiantianGua, tianDiGuaData) = calculateXianTianGuaWithTianDiData(
      eightChars: eightChars,
      yearYinYang: yearYinYang,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterJieQi: birthAfterJieQi,
    );

    YinYang monthYinYang;
    if (monthType == YuanTangMonthType.monthTokenYinYang) {
      if ([11, 12, 1, 2, 3, 4].contains(birthMonth)) {
        monthYinYang = YinYang.YANG;
      } else {
        monthYinYang = YinYang.YIN;
      }
    } else {
      if ([1, 3, 5, 7, 9, 11].contains(birthMonth)) {
        monthYinYang = YinYang.YANG;
      } else {
        monthYinYang = YinYang.YIN;
      }
    }
    PureYuanTangGua houtianGua = xianTianGuaToHouTianGua(
      xiantianGua,
      monthYinYang,
    );

    return YuanTangInfo(
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterJieQi: birthAfterJieQi,
      xianTanGua: xiantianGua,
      houTianGua: houtianGua,
      calanderType: calanderType,
      birthMonth: birthMonth,
      tianDiGuaData: tianDiGuaData,
    );
  }

  /// 根据八字、年份阴阳、性别、三元五宫计算先天卦
  ///
  /// 参数：
  /// - [eightChars]: 八字对象
  /// - [yearYinYang]: 年份阴阳（"阳" / "阴"）
  /// - [gender]: 性别（"男" / "女"）
  /// - [threeYuan]: 三元（"上" / "中" / "下"）
  PureYuanTangGua calculateXianTianGua({
    required EightChars eightChars,
    required YinYang yearYinYang,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterJieQi,
  }) {
    // 1. 四柱八字取数
    // 合并天干数列表与地支数列表
    final List<int> combined = [
      /// 天干洛书数
      ...eightChars.allTianGan.map((t) => constants.ganNumberMapper[t]!),

      /// 地支洛书数
      ...eightChars.allDiZhi.expand((t) => constants.zhiNumberMapper[t]!),
    ];
    // 2.1. 分成奇数与偶数两组
    /// 奇数组
    final List<int> oddList = combined.where((n) => n % 2 == 1).toList();

    /// 偶数组
    final List<int> evenList = combined.where((n) => n % 2 == 0).toList();

    // 2.2. 奇数组相加为天数，偶数数组相加为地数
    // 2.2.1. 奇数组总和为天数
    final int tianNumTotal = oddList.fold(0, (a, b) => a + b);

    /// 2.2.2. 偶数组总和为地数
    final int diNumNumTotal = evenList.fold(0, (a, b) => a + b);

    // 3. 天地数化后天卦
    // 3.1.1. 处理天数
    final int tianGuaNum = calculateGuaNum(tianNumTotal, 25, 5);
    // 3.1.2. 处理地数
    final int diGuaNum = calculateGuaNum(diNumNumTotal, 30, 3);

    // 3.2. 天地数化卦
    // 3.2.1. 天数卦卦
    final Enum8Gua tianGua = numberToHouTianGua(
      number: tianGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );
    // 3.2.2. 地数卦卦
    final Enum8Gua diGua = numberToHouTianGua(
      number: diGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );
    // 1. 得到先天卦
    Enum64Gua xiantianGua = tianDiGuaToGua64(
      gender: gender,
      yearYinYang: yearYinYang,
      tianGua: tianGua,
      diGua: diGua,
    );

    return yuanTangZhuangGua(
      eightChars: eightChars,
      gua: xiantianGua,
      gender: gender,
      birthAfterZhi: birthAfterJieQi,
    );
  }

  /// 计算先天卦并返回天地卦数据
  ///
  /// 返回: (PureYuanTangGua, TianDiGuaData)
  ///
  /// 参数：
  /// - [eightChars]: 八字对象
  /// - [yearYinYang]: 年份阴阳（"阳" / "阴"）
  /// - [gender]: 性别（"男" / "女"）
  /// - [threeYuan]: 三元（"上" / "中" / "下"）
  /// - [birthAfterJieQi]: 出生节气后（"夏至" / "冬至"）
  (PureYuanTangGua, TianDiGuaData) calculateXianTianGuaWithTianDiData({
    required EightChars eightChars,
    required YinYang yearYinYang,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterJieQi,
  }) {
    // 1. 四柱八字取数
    // 提取天干数列表
    final List<int> ganNumList = eightChars.allTianGan
        .map((t) => constants.ganNumberMapper[t]!)
        .toList();

    // 提取地支数列表（每个地支对应多个数字）
    final List<List<int>> zhiNumList = eightChars.allDiZhi
        .map((t) => constants.zhiNumberMapper[t]!)
        .toList();

    // 合并天干数列表与地支数列表
    final List<int> combined = [...ganNumList, ...zhiNumList.expand((x) => x)];

    // 2.1. 分成奇数与偶数两组
    /// 奇数组
    final List<int> oddList = combined.where((n) => n % 2 == 1).toList();

    /// 偶数组
    final List<int> evenList = combined.where((n) => n % 2 == 0).toList();

    // 2.2. 奇数组相加为天数，偶数数组相加为地数
    // 2.2.1. 奇数组总和为天数
    final int oddNumTotal = oddList.fold(0, (a, b) => a + b);

    /// 2.2.2. 偶数组总和为地数
    final int evenNumTotal = evenList.fold(0, (a, b) => a + b);

    // 3. 天地数化后天卦
    // 3.1.1. 处理天数
    final int tianGuaNum = calculateGuaNum(oddNumTotal, 25, 5);
    // 3.1.2. 处理地数
    final int diGuaNum = calculateGuaNum(evenNumTotal, 30, 3);

    // 判断是否使用三元五宫
    final bool usedThreeYuanWuGong = tianGuaNum == 5 || diGuaNum == 5;

    // 3.2. 天地数化卦
    // 3.2.1. 天数化卦
    final Enum8Gua tianGua = numberToHouTianGua(
      number: tianGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );
    // 3.2.2. 地数化卦
    final Enum8Gua diGua = numberToHouTianGua(
      number: diGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );

    // 4. 得到先天卦
    Enum64Gua xiantianGua = tianDiGuaToGua64(
      gender: gender,
      yearYinYang: yearYinYang,
      tianGua: tianGua,
      diGua: diGua,
    );

    // 5. 元堂装卦
    final PureYuanTangGua pureYuanTangGua = yuanTangZhuangGua(
      eightChars: eightChars,
      gua: xiantianGua,
      gender: gender,
      birthAfterZhi: birthAfterJieQi,
    );

    // 6. 构建天地卦数据
    final tianDiGuaData = TianDiGuaData(
      ganNumList: ganNumList,
      zhiNumList: zhiNumList,
      oddNumTotal: oddNumTotal,
      evenNumTotal: evenNumTotal,
      tianGuaNum: tianGuaNum,
      diGuaNum: diGuaNum,
      tianGua: tianGua,
      diGua: diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong,
    );

    return (pureYuanTangGua, tianDiGuaData);
  }

  /// 先天卦转换为后天卦
  /// 基础处理：将元堂爻 阴阳转换后，上下卦呼唤
  /// 三至尊卦：坎、屯、蹇。且元堂爻为九五或上六。
  ///   根据月份阴阳（1. "1/3/5/7/9/11为阳月，2/4/6/8/10/12为阴月"）
  ///   根据月令阴阳（1. 冬至后->夏至前11/12/1/2/3/4为阳令，夏至后->冬至前5/6/7/8/9/10为阴令）
  /// 情况一：九五生于阴令或阴月（变而不易），即 "坎"->"地水师"，水雷屯->地雷复，水山蹇->地山谦。且元堂爻保持不变依旧在 五爻
  /// 情况二：九五生于阴令或阳月（易而变）--- 与基础处理一样
  /// 情况三：上六生于阴令或阴月（变而易）--- 与基础处理一样
  /// 情况四：上六生于阳令或阳月（变而不易），即 “坎为水”->"风水涣"，水雷屯->风雷益，水山蹇->山风蛊
  static PureYuanTangGua xianTianGuaToHouTianGua(
    PureYuanTangGua xianTianGua,
    YinYang monthYingYang,
  ) {
    var gua;
    // 三至尊卦检测
    if ({
      Enum64Gua.kan_wei_shui,
      Enum64Gua.shui_lei_tun,
      Enum64Gua.shui_shan_jian,
    }.contains(xianTianGua.gua)) {
      if (monthYingYang.isYang) {
        // 阳月 或 阳令
        if (xianTianGua.yuanTangYao.indexAtYaoList == 5) {
          // 上六为元堂爻 ,变而不易
          if (xianTianGua.gua == Enum64Gua.kan_wei_shui) {
            gua = Enum64Gua.feng_shui_huan;
          } else if (xianTianGua.gua == Enum64Gua.shui_lei_tun) {
            gua = Enum64Gua.feng_lei_yi;
          } else if (xianTianGua.gua == Enum64Gua.shui_shan_jian) {
            gua = Enum64Gua.shan_feng_gu;
          }
        }
      } else {
        if (xianTianGua.yuanTangYao.indexAtYaoList == 4) {
          // 九五为元堂爻 ,变而不易
          if (xianTianGua.gua == Enum64Gua.kan_wei_shui) {
            gua = Enum64Gua.di_shui_shi;
          } else if (xianTianGua.gua == Enum64Gua.shui_lei_tun) {
            gua = Enum64Gua.di_lei_fu;
          } else if (xianTianGua.gua == Enum64Gua.shui_shan_jian) {
            gua = Enum64Gua.di_shan_qian;
          }
        }
      }
    }
    // 1. 元堂爻阴阳转换
    var yaoListCopy = xianTianGua.yaoList.map((e) => e.yinYang).toList();
    yaoListCopy[xianTianGua.yuanTangYao.indexAtYaoList] =
        yaoListCopy[xianTianGua.yuanTangYao.indexAtYaoList].isYang
        ? YinYang.YIN
        : YinYang.YANG;
    var yaoBinList = yaoListCopy.map((y) => y.isYang ? 1 : 0).toList();

    final originalBottom = Enum8Gua.fromBottomTopBinaryStr(
      yaoBinList.sublist(0, 3).join(""),
    );
    final originalTop = Enum8Gua.fromBottomTopBinaryStr(
      yaoBinList.sublist(3).join(""),
    );
    // 2. 上下卦呼唤
    gua = Enum64Gua.getBy8Gua(originalBottom, originalTop);
    return PureYuanTangGua.from64Gua(gua, xianTianGua.yuanTangYao);
  }

  /// 获取元堂爻索引
  static int getYuanTangYaoIndex(
    DiZhi timeZhi,
    List<List<DiZhi>> yangTangYaoZhiList,
  ) {
    var resultYuantangYaoIndex = -1;
    for (var i = 0; i < yangTangYaoZhiList.length; i++) {
      if (yangTangYaoZhiList[i].contains(timeZhi)) {
        resultYuantangYaoIndex = i;
        break;
      }
    }
    return resultYuantangYaoIndex;
  }

  ///实现细则
  // - 天数规则
  //   - >25 ：减去25取个位（例 39 → 14 → 4 ）
  //   - ==25 ：取默认值 5
  //   - <25 ：舍去十位取个位（例 24 → 4 ）
  //   - >25 且 -25=10/20 ：取十位数 1/2 （例 35 → 1 、 45 → 2 ）
  // - 地数规则
  //   - ==30 ：取默认值 3
  //   - <30 ：舍去十位取个位（例 26 → 6 ）
  //   - >30 且 -30=10/20 ：取十位数 1/2 （例 40 → 1 、 50 → 2 ）

  /// 一个通用的计算卦数的方法。
  /// [total]: 输入的总和。
  /// [threshold]: 阈值 (例如 25 或 30)。
  /// [defaultValue]: 当总和等于阈值时使用的默认值 (例如 5 或 3)。
  int calculateGuaNum(int total, int threshold, int defaultValue) {
    if (total == threshold) {
      return defaultValue;
    }

    int remainder = total;
    if (total > threshold) {
      remainder = total % threshold;
    }

    // 规则：
    // - 当 total > threshold 且 (total - threshold) 为 10 或 20 时，取十位数（1 或 2）。
    // - 其它情况：舍去十位取个位。
    if (total > threshold && (remainder == 10 || remainder == 20)) {
      return remainder ~/ 10;
    }
    // <25或<30时，以及>25或>30的其它余数，不用十位 (即取个位)
    return remainder % 10;
  }

  // 三元五宫配卦（当天数或地数为5时使用）
  static Enum8Gua numberToHouTianGua({
    required int number,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required YinYang yearYinYang,
  }) {
    Enum8Gua gua;
    if (number == 5) {
      gua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    } else {
      if (!constants.yuanTangHuaTianNumberGuaMapper.containsKey(number)) {
        throw ArgumentError('无效的地数: $number，映射表中不存在该键');
      }
      gua = constants.yuanTangHuaTianNumberGuaMapper[number]!;
    }
    return gua;
  }

  /// 元堂装卦
  ///
  /// 参数：
  /// - [eightChars]: 四柱信息
  /// - [gua]: 先天卦
  /// - [gender]: 性别（"男" / "女"）
  /// - [birthAfterZhi]: 出生节气后（"夏至" / "冬至"）
  ///
  /// 返回: (yuantangYaoIndex, yuantangYaoLabel, zhiList, timeGanzhi,
  ///        timeYinYang, totalYangYao, totalYinYao)
  static PureYuanTangGua yuanTangZhuangGua({
    required EightChars eightChars,
    required Enum64Gua gua,
    required Gender gender,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    // 判断时辰阴阳
    const yuantangYangTimeSet = [
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
    ];
    const yuantangYinTimeSet = [
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
    ];

    final timeYinYang = yuantangYangTimeSet.contains(eightChars.time.zhi)
        ? YinYang.YANG
        : YinYang.YIN;

    // 将卦转换为二进制列表
    // final allGuaBinary = gua_utils.guaToBinaryList(xiantianGua);
    final allGuaBinary = gua.bottomTopBinaryList;

    // 计算阳爻和阴爻数量
    final totalYangYao = allGuaBinary.where((x) => x == 1).length;
    final totalYinYao = allGuaBinary.where((x) => x == 0).length;

    // 根据时辰阴阳和爻数分类处理
    List<List<DiZhi>> zhiList;
    if (timeYinYang.isYang) {
      // 阳时取阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        zhiList = zhuangGua123(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          YinYang.YANG,
        );
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        zhiList = zhuangGua45(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          YinYang.YANG,
        );
      } else {
        zhiList = zhuangGua6(YinYang.YANG, gender, timeYinYang, birthAfterZhi);
      }
    } else {
      // 阴时取阴爻
      if (totalYinYao > 0 && totalYinYao <= 3) {
        zhiList = zhuangGua123(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          YinYang.YIN,
        );
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        zhiList = zhuangGua45(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          YinYang.YIN,
        );
      } else {
        zhiList = zhuangGua6(YinYang.YIN, gender, timeYinYang, birthAfterZhi);
      }
    }

    // 获取元堂爻索引
    final yuantangYaoIndex = getYuanTangYaoIndex(eightChars.time.zhi, zhiList);

    // 获取元堂爻位标签
    // final yuantangYaoLabel = _getYaoPositionLabel(yuantangYaoIndex);

    List<YuanTangYao> yaoList = [];
    for (var i = 0; i < gua.bottomTopBinaryList.length; i++) {
      yaoList.add(
        YuanTangYao(
          order: EnumYaoOrder.fromIndex(i),
          yinYang: gua.bottomTopBinaryList[i] == 1 ? YinYang.YANG : YinYang.YIN,
          yangTangZhiList: zhiList[i],
          isYuanTang: i == yuantangYaoIndex,
        ),
      );
    }

    return PureYuanTangGua(
      gua: gua,
      yaoList: yaoList,
      yuanTangYao: EnumYaoOrder.fromIndex(yuantangYaoIndex),
    );
  }

  /// 天地数化64卦
  /// 阳男阴女，天数在上，地数在下；阳女阴男，地数在上，天数在下。
  Enum64Gua tianDiGuaToGua64({
    required Gender gender,
    required YinYang yearYinYang,
    required Enum8Gua tianGua,
    required Enum8Gua diGua,
  }) {
    if (gender == Gender.male) {
      if (yearYinYang.isYang) {
        // 阳男 天卦在上 地卦在下
        return Enum64Gua.getBy8Gua(tianGua, diGua);
      } else {
        // 阴男 地卦在上 天卦在下
        return Enum64Gua.getBy8Gua(diGua, tianGua);
      }
    } else {
      if (yearYinYang.isYang) {
        // 阳女 地卦在上 天卦在下
        return Enum64Gua.getBy8Gua(diGua, tianGua);
      } else {
        // 阴女 天卦在上 地卦在下
        return Enum64Gua.getBy8Gua(tianGua, diGua);
      }
    }
  }

  /// 元堂装卦 - 1-3个阳爻或阴爻（自上而下排列）
  /// 装卦规则为，
  /// 当为‘阳’时将阳支按照从下相向的顺序装配到阳爻上，一个阳爻上可能1或2个地支，剩下的装配阳支到阴爻上，有些阴爻上可能没有装配到
  /// 当为‘阴’时将阴支按照从下相向的顺序装配到阴爻上，一个阴爻上可能1或2个地支，剩下的装配阴支到阳爻上，有些阳爻上可能没有装配到
  static List<List<DiZhi>> zhuangGua123(
    List<int> guaBinaryList,
    List<DiZhi> zhiList,
    YinYang yinYang,
  ) {
    final List<YinYang> yinYangList = guaBinaryList
        .map((x) => x == 1 ? YinYang.YANG : YinYang.YIN)
        .toList();
    // print(yinYangList.map((y) => y.name).toList());

    // 获取所有 yinYangList 中 isYang 的下标列表
    final yangIndices = <int>[];
    // 获取所有 yinYangList 中 isYin 的下标列表
    final yinIndices = <int>[];
    for (var i = 0; i < yinYangList.length; i++) {
      if (yinYangList[i].isYang) {
        yangIndices.add(i);
      } else if (yinYangList[i].isYin) {
        yinIndices.add(i);
      }
    }

    // 为阳时 阳爻index在前，为阴时阴爻index在前
    // final allIndices = yinYang.isYang
    //     ? [...yangIndices, ...yinIndices]
    //     : [...yinIndices, ...yangIndices];

    Map<int, List<DiZhi>> tmp = {};
    if (yinYang.isYang) {
      final allYangSlotIndices = [...yangIndices, ...yangIndices];
      final tmpList = zhiList.map((e) => e).toList();
      for (var i = 0; i < allYangSlotIndices.length; i++) {
        if (tmp[allYangSlotIndices[i]] == null) {
          tmp[allYangSlotIndices[i]] = [];
        }
        tmp[allYangSlotIndices[i]]!.add(tmpList[i]!);
      }
      List<DiZhi> leftZhiForYinList = tmpList
          .skip(allYangSlotIndices.length)
          .toList();
      for (var i = 0; i < leftZhiForYinList.length; i++) {
        if (tmp[yinIndices[i]] == null) {
          tmp[yinIndices[i]] = [];
        }
        tmp[yinIndices[i]]!.add(leftZhiForYinList[i]);
      }
    } else {
      final allYinSlotIndices = [...yinIndices, ...yinIndices];
      final tmpList = zhiList.map((e) => e).toList();
      for (var i = 0; i < allYinSlotIndices.length; i++) {
        if (tmp[allYinSlotIndices[i]] == null) {
          tmp[allYinSlotIndices[i]] = [];
        }
        tmp[allYinSlotIndices[i]]!.add(tmpList[i]!);
      }
      List<DiZhi> leftZhiForYangList = tmpList
          .skip(allYinSlotIndices.length)
          .toList();
      for (var i = 0; i < leftZhiForYangList.length; i++) {
        if (tmp[yangIndices[i]] == null) {
          tmp[yangIndices[i]] = [];
        }
        tmp[yangIndices[i]]!.add(leftZhiForYangList[i]);
      }
    }

    List<List<DiZhi>> finalList = [];
    for (var i = 0; i < 6; i++) {
      if (tmp[i] == null) {
        finalList.add([]);
      } else {
        finalList.add(tmp[i]!);
      }
    }

    return finalList;
  }

  /// 元堂装卦 - 4-5个阳爻或阴爻（自上而下排列）
  /// 装卦规则为，
  /// 当为‘阳’时将阳支按照从下相向的顺序装配到阳爻上，剩下的装配阳支到阴爻上
  /// 当为‘阴’时将阴支按照从下相向的顺序装配到阴爻上，剩下的装配阴支到阳爻上
  static List<List<DiZhi>> zhuangGua45(
    List<int> guaBinaryList,
    List<DiZhi> zhiList,
    YinYang yinYang,
  ) {
    final List<YinYang> yinYangList = guaBinaryList
        .map((x) => x == 1 ? YinYang.YANG : YinYang.YIN)
        .toList();
    // print(yinYangList.map((y) => y.name).toList());

    // 获取所有 yinYangList 中 isYang 的下标列表
    final yangIndices = <int>[];
    // 获取所有 yinYangList 中 isYin 的下标列表
    final yinIndices = <int>[];
    for (var i = 0; i < yinYangList.length; i++) {
      if (yinYangList[i].isYang) {
        yangIndices.add(i);
      } else if (yinYangList[i].isYin) {
        yinIndices.add(i);
      }
    }

    // 为阳时 阳爻index在前，为阴时阴爻index在前
    final allIndices = yinYang.isYang
        ? [...yangIndices, ...yinIndices]
        : [...yinIndices, ...yangIndices];

    // print(allIndices);
    Map<int, DiZhi> tmp = {};
    for (var i = 0; i < allIndices.length; i++) {
      tmp[allIndices[i]] = zhiList[i];
    }
    List<List<DiZhi>> finalList = [];
    for (var i = 0; i < allIndices.length; i++) {
      finalList.add([tmp[i]!]);
    }
    return finalList;
  }

  static List<List<DiZhi>> zhuangGua6(
    YinYang sixYaoYingYang,
    Gender gender,
    YinYang timeYinYang,
    TwentyFourJieQi jieQi,
  ) {
    if (sixYaoYingYang.isYang) {
      if (gender == Gender.male) {
        if (timeYinYang.isYang) {
          return [
            [DiZhi.ZI, DiZhi.MAO],
            [DiZhi.CHOU, DiZhi.CHEN],
            [DiZhi.YIN, DiZhi.SI],
            [],
            [],
            [],
          ];
        } else {
          return [
            [],
            [],
            [],
            [DiZhi.YOU, DiZhi.WU],
            [DiZhi.WEI, DiZhi.XU],
            [DiZhi.SHEN, DiZhi.HAI],
          ];
        }
      } else {
        if (timeYinYang.isYang) {
          // 女命 阳时
          if (jieQi == TwentyFourJieQi.DONG_ZHI) {
            // 冬至->夏至
            return [
              [],
              [],
              [],
              [DiZhi.YIN, DiZhi.SI],
              [DiZhi.CHOU, DiZhi.CHEN],
              [DiZhi.ZI, DiZhi.MAO],
            ];
          } else {
            // 夏至->冬至
            return [
              [DiZhi.ZI, DiZhi.MAO],
              [DiZhi.CHOU, DiZhi.CHEN],
              [DiZhi.YIN, DiZhi.SI],
              [],
              [],
              [],
            ];
          }
        } else {
          // 女命 阴时
          if (jieQi == TwentyFourJieQi.DONG_ZHI) {
            // 冬至->夏至
            return [
              [DiZhi.SHEN, DiZhi.HAI],
              [DiZhi.WEI, DiZhi.XU],
              [DiZhi.WU, DiZhi.YOU],
              [],
              [],
              [],
            ];
          } else {
            // 夏至->冬至
            return [
              [],
              [],
              [],
              [DiZhi.WU, DiZhi.YOU],
              [DiZhi.WEI, DiZhi.XU],
              [DiZhi.SHEN, DiZhi.HAI],
            ];
          }
        }
      }
    } else {
      if (gender == Gender.female) {
        if (timeYinYang.isYang) {
          return [
            [DiZhi.ZI, DiZhi.MAO],
            [DiZhi.CHOU, DiZhi.CHEN],
            [DiZhi.YIN, DiZhi.SI],
            [],
            [],
            [],
          ];
        } else {
          return [
            [],
            [],
            [],
            [DiZhi.YOU, DiZhi.WU],
            [DiZhi.WEI, DiZhi.XU],
            [DiZhi.SHEN, DiZhi.HAI],
          ];
        }
      } else {
        if (timeYinYang.isYang) {
          // 男命 阳时
          if (jieQi == TwentyFourJieQi.DONG_ZHI) {
            // 冬至->夏至
            return [
              [],
              [],
              [],
              [DiZhi.YIN, DiZhi.SI],
              [DiZhi.CHOU, DiZhi.CHEN],
              [DiZhi.ZI, DiZhi.MAO],
            ];
          } else {
            // 夏至->冬至
            return [
              [DiZhi.ZI, DiZhi.MAO],
              [DiZhi.CHOU, DiZhi.CHEN],
              [DiZhi.YIN, DiZhi.SI],
              [],
              [],
              [],
            ];
          }
        } else {
          // 男命 阴时
          if (jieQi == TwentyFourJieQi.DONG_ZHI) {
            // 冬至->夏至
            return [
              [DiZhi.SHEN, DiZhi.HAI],
              [DiZhi.WEI, DiZhi.XU],
              [DiZhi.WU, DiZhi.YOU],
              [],
              [],
              [],
            ];
          } else {
            // 夏至->冬至
            return [
              [],
              [],
              [],
              [DiZhi.WU, DiZhi.YOU],
              [DiZhi.WEI, DiZhi.XU],
              [DiZhi.SHEN, DiZhi.HAI],
            ];
          }
        }
      }
    }
  }

  /// 计算大运列表
  ///
  /// [guaName] 卦名（如"震坤"）
  /// [yuantangYaoIndex] 元堂爻索引（0-5）
  /// [zhiList] 六爻地支配置
  /// [startAge] 起始年龄
  ///
  /// 返回: `List<YuanTangDayunPeriod>`
  ///
  /// 规则：
  /// 1. 从元堂爻开始，按照 元堂→下一爻→...→上爻→初爻→... 的顺序循环6个爻位
  /// 2. 阳爻9年，阴爻6年
  /// 3. 年龄连续累加
  static List<YuanTangDaYunPeriod> calculateDaYun(
    PureYuanTangGua yuanTangGua,
    int startAge,
  ) {
    final dayunList = <YuanTangDaYunPeriod>[];

    var currentAge = startAge;

    // 从元堂爻开始，循环6个爻位
    // 顺序：元堂爻 → 下一爻(+1) → ... → 上爻 → 初爻 → ...
    // 1. 首先 获得 元堂爻 的index
    // 2. 根据元堂爻的index，调整爻的排序，将元堂爻放到第一个位置
    final List<YuanTangYao> newYuanTangYaoList = CollectUtils.changeSeq(
      yuanTangGua.yuanTangYaoList[yuanTangGua.yuanTangYao.indexAtYaoList],
      yuanTangGua.yuanTangYaoList,
    );
    for (var y in newYuanTangYaoList) {
      final yuanTangDaYun = YuanTangDaYunPeriod(
        order: y.order,
        yinYang: y.yinYang,
        startAge: currentAge,
        diZhiList: y.yangTangZhiList,
      );
      dayunList.add(yuanTangDaYun);

      currentAge = yuanTangDaYun.endAge + 1;
    }

    return dayunList;
  }

  /// 计算单个大运期的流年卦列表
  ///
  /// 根据大运爻的阴阳性分派到不同的计算方法
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象（先天卦或后天卦）
  /// - [guaSource]: 卦象来源标识（"先天卦" / "后天卦"）
  /// - [daYunStartJiaZi]: 出生年份（公元纪年）
  ///
  /// 返回: 该大运期的所有流年卦列表（阳爻9个，阴爻6个）
  static List<YuanTangLiuYearGua> calculateLiuYearForDayun(
    YuanTangDaYunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    JiaZi daYunStartJiaZi,
  ) {
    if (dayun.yinYang.isYang) {
      return _calculateLiunianForYangYaoDayun(
        dayun,
        baseGua,
        guaSource,
        daYunStartJiaZi,
      );
    } else {
      return _calculateLiunianForYinYaoDayun(
        dayun,
        baseGua,
        guaSource,
        daYunStartJiaZi,
      );
    }
  }

  /// 计算阳爻大运的流年卦（9年）
  ///
  /// 阳爻大运规则：
  /// 1. 判断大运初年的阴阳（出生年 + 大运起始年龄 - 1）
  /// 2. 如果初年为阳年：第1年直接使用基础卦，不变换
  /// 3. 如果初年为阴年：第1年先变换大运爻
  /// 4. 第2-9年：按照 (大运爻-2) → 大运爻 → (大运爻+1) → (大运爻+2) 循环变换
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象
  /// - [guaSource]: 卦象来源标识
  /// - [birthYear]: 出生年份
  ///
  /// 返回: 9个流年卦
  static List<YuanTangLiuYearGua> _calculateLiunianForYangYaoDayun(
    YuanTangDaYunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    JiaZi daYunStartJiaZi,
  ) {
    final liunianList = <YuanTangLiuYearGua>[];

    // 判断大运初年的阴阳
    final isYangStartYear = daYunStartJiaZi.gan.isYang;

    // 大运用爻索引与其应爻索引
    final dayunYaoIndex = dayun.order.indexAtYaoList;
    final yingYaoIndex = _getYingYaoIndex(dayunYaoIndex);

    Enum64Gua currentGua = baseGua;

    // 第1年：阳年起不变卦（但标记用爻），阴年起先变用爻
    if (!isYangStartYear) {
      currentGua = _changeYao(baseGua, dayunYaoIndex);
    }

    liunianList.add(
      YuanTangLiuYearGua(
        age: dayun.startAge,
        yearIndex: 0,
        gua: currentGua,
        guaSource: guaSource,
        dayunPeriod: dayun,
        changedYao: dayun.order,
        previousGua: null,
      ),
    );

    // 第2年：统一取应爻
    {
      final previousGua = currentGua;
      currentGua = _changeYao(currentGua, yingYaoIndex);
      liunianList.add(
        YuanTangLiuYearGua(
          age: dayun.startAge + 1,
          yearIndex: 1,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYao: EnumYaoOrder.fromIndex(yingYaoIndex),
          previousGua: previousGua,
        ),
      );
    }

    // 第3年：复取用爻
    {
      final previousGua = currentGua;
      currentGua = _changeYao(currentGua, dayunYaoIndex);
      liunianList.add(
        YuanTangLiuYearGua(
          age: dayun.startAge + 2,
          yearIndex: 2,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYao: dayun.order,
          previousGua: previousGua,
        ),
      );
    }

    // 第4-9年：自下而上依次取位（用爻后一位起，直至上爻）
    for (int i = 4; i <= 9; i++) {
      final previousGua = currentGua;
      final offset = i - 3; // 1..6
      final yaoToChange = (dayunYaoIndex + offset) % 6;
      currentGua = _changeYao(currentGua, yaoToChange);

      liunianList.add(
        YuanTangLiuYearGua(
          age: dayun.startAge + (i - 1),
          yearIndex: i - 1,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYao: EnumYaoOrder.fromIndex(yaoToChange),
          previousGua: previousGua,
        ),
      );
    }

    return liunianList;
  }

  /// 判断年份是否为阳年（用于流年卦计算）
  ///
  /// 根据天干判断年份阴阳性：
  /// - 阳年：甲丙戊庚壬（天干索引：0, 2, 4, 6, 8）
  /// - 阴年：乙丁己辛癸（天干索引：1, 3, 5, 7, 9）
  ///
  /// 算法：
  /// - 公元4年为甲子年（天干索引0）
  /// - ganIndex = (year - 4) % 10
  /// - 索引为偶数(0,2,4,6,8)的是阳年
  ///
  /// 参数：
  /// - [year]: 公元纪年（如2024）
  ///
  /// 返回: true表示阳年，false表示阴年
  static bool _isYangGanYear(int year) {
    // 公元4年为甲子年(天干索引0)
    final ganIndex = (year - 4) % 10;

    // 甲(0)、丙(2)、戊(4)、庚(6)、壬(8)为阳年
    return [0, 2, 4, 6, 8].contains(ganIndex);
  }

  /// 爻变方法（用于流年卦和流月卦计算）
  ///
  /// 对指定爻位进行爻变（阴转阳，阳转阴）
  ///
  /// 参数：
  /// - [gua]: 卦象（如"震坤"）
  /// - [yaoIndex]: 爻位索引（0-5，0=初爻，5=上爻）
  ///
  /// 返回: 变换后的新卦象
  static Enum64Gua _changeYao(Enum64Gua gua, int yaoIndex) {
    // 将卦转换为二进制列表
    final binaryList = gua_utils.guaToBinaryList(gua);

    // 转换索引：yaoIndex使用从下到上的索引(0=初爻,5=上爻)
    // 而binaryList使用从上到下的索引(0=上卦第1爻,5=下卦第3爻)
    // 转换公式：binaryIndex = 5 - yaoIndex
    final binaryIndex = 5 - yaoIndex;

    // 爻变：阴变阳(0→1)，阳变阴(1→0)
    binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

    // 重组卦象
    final upper = binaryList.sublist(0, 3).join();
    final lower = binaryList.sublist(3).join();
    final upperGua = constants.binaryStrGuaMapper[upper]!;
    final lowerGua = constants.binaryStrGuaMapper[lower]!;
    return Enum64Gua.getBy8Gua(
      Enum8Gua.fromValue(upperGua),
      Enum8Gua.fromValue(lowerGua),
    );
  }

  /// 计算阴爻大运的流年卦（6年）
  ///
  /// 阴爻大运规则：
  /// 1. 不论大运初年是阴年还是阳年
  /// 2. 第1年：先变换大运爻
  /// 3. 第2-6年：依次变换大运爻的下一爻、下两爻...
  /// 4. 变换顺序：大运爻 → (大运爻+1) → (大运爻+2) → (大运爻+3) → (大运爻+4) → (大运爻+5)
  ///
  /// 参数：
  /// - [dayun]: 大运期信息
  /// - [baseGua]: 基础卦象
  /// - [guaSource]: 卦象来源标识
  /// - [daYunStartJiaZi]: 出生年份干支
  ///
  /// 返回: 6个流年卦
  static List<YuanTangLiuYearGua> _calculateLiunianForYinYaoDayun(
    YuanTangDaYunPeriod dayun,
    Enum64Gua baseGua,
    String guaSource,
    JiaZi daYunStartJiaZi,
  ) {
    final liunianList = <YuanTangLiuYearGua>[];

    // 第1年: 先变换大运爻(不论初年阴阳)
    Enum64Gua currentGua = _changeYao(baseGua, dayun.order.indexAtYaoList);

    liunianList.add(
      YuanTangLiuYearGua(
        age: dayun.startAge,
        yearIndex: 0,
        gua: currentGua,
        guaSource: guaSource,
        dayunPeriod: dayun,
        previousGua: null,
        changedYao: dayun.order,
      ),
    );

    // 第2-6年: 逐爻变换
    for (int i = 1; i < 6; i++) {
      final previousGua = currentGua;
      final yaoToChange = (dayun.order.indexAtYaoList + i) % 6;
      currentGua = _changeYao(currentGua, yaoToChange);

      liunianList.add(
        YuanTangLiuYearGua(
          age: dayun.startAge + i,
          yearIndex: i,
          gua: currentGua,
          guaSource: guaSource,
          dayunPeriod: dayun,
          changedYao: EnumYaoOrder.fromIndex(yaoToChange),
          previousGua: previousGua,
        ),
      );
    }

    return liunianList;
  }

  ///
  /// 流月卦计算规则：
  /// 1. 阳月卦(1,3,5,7,9,11月): 从正月卦开始, 逐月变换下一爻
  /// 2. 阴月卦(2,4,6,8,10,12月): 取对应阳月卦, 变换其"应爻"
  /// 3. 正月卦起法: 变换(元堂爻 - 1)的爻位
  ///
  /// 参数：
  /// - [targetAge]: 目标年龄（虚岁）
  /// - [liunianGua]: 该年的流年卦
  /// - [yuantangYaoIndex]: 元堂爻位置（0-5）
  /// - [isNextYaoStart]: 当前有两种方案，一种是以“元堂爻”的前一爻为正月，另一种是以“元堂爻”的后一爻为正月。
  ///
  /// 返回: 12个流月卦列表（已按月份排序）
  static List<YuanTangLiuMonthGua> calculateLiuMonthForAge(
    int targetAge,
    Enum64Gua liunianGua,
    int yuantangYaoIndex,
    bool isNextYaoStart,
  ) {
    final liuyueList = <YuanTangLiuMonthGua>[];

    // 步骤1: 计算正月卦(变换元堂爻前一爻)
    final zhengYueYaoIndex = isNextYaoStart
        ? (yuantangYaoIndex + 1 + 6) % 6
        : (yuantangYaoIndex - 1 + 6) % 6;
    Enum64Gua zhengYueGua = _changeYao(liunianGua, zhengYueYaoIndex);

    liuyueList.add(
      YuanTangLiuMonthGua(
        month: 1,
        isYangMonth: true,
        gua: zhengYueGua,
        age: targetAge,
        changedYaoIndex: EnumYaoOrder.fromIndex(zhengYueYaoIndex),
        sourceGua: liunianGua,
        yingYaoIndex: null,
      ),
    );

    // 步骤2: 计算其他阳月卦(3,5,7,9,11月)
    Enum64Gua currentYangGua = zhengYueGua;
    int lastChangedYaoIndex = zhengYueYaoIndex;

    for (int month in [3, 5, 7, 9, 11]) {
      final previousGua = currentYangGua;
      // 逐月向前变换(变换上一次变换爻的下一爻)
      final nextYaoIndex = (lastChangedYaoIndex + 1) % 6;
      currentYangGua = _changeYao(currentYangGua, nextYaoIndex);

      liuyueList.add(
        YuanTangLiuMonthGua(
          month: month,
          isYangMonth: true,
          gua: currentYangGua,
          age: targetAge,
          changedYaoIndex: EnumYaoOrder.fromIndex(nextYaoIndex),
          sourceGua: previousGua,
          yingYaoIndex: null,
        ),
      );

      lastChangedYaoIndex = nextYaoIndex;
    }

    // 步骤3: 计算阴月卦(2,4,6,8,10,12月)
    final yangMonths = [1, 3, 5, 7, 9, 11];
    final yinMonths = [2, 4, 6, 8, 10, 12];

    for (int i = 0; i < 6; i++) {
      final yangMonth = yangMonths[i];
      final yinMonth = yinMonths[i];

      // 找到对应阳月卦
      final yangGua = liuyueList.firstWhere((g) => g.month == yangMonth).gua;

      // 计算该阳月的变爻位置
      final yangYaoIndex = i == 0
          ? zhengYueYaoIndex
          : (zhengYueYaoIndex + i) % 6;

      // 变换应爻
      final yingYaoIndex = _getYingYaoIndex(yangYaoIndex);
      final yinGua = _changeYao(yangGua, yingYaoIndex);

      liuyueList.add(
        YuanTangLiuMonthGua(
          month: yinMonth,
          isYangMonth: false,
          gua: yinGua,
          age: targetAge,
          changedYaoIndex: EnumYaoOrder.fromIndex(yingYaoIndex),
          sourceGua: yangGua,
          yingYaoIndex: EnumYaoOrder.fromIndex(yingYaoIndex),
        ),
      );
    }

    // 按月份排序
    liuyueList.sort((a, b) => a.month.compareTo(b.month));

    return liuyueList;
  }

  /// 生成天地卦
  ///
  /// 参数：
  /// - [eightChars]: 四柱信息
  /// - [gender]: 性别（"男" / "女"）
  /// - [threeYuan]: 三元（"上" / "中" / "下"）
  ///
  /// 返回: (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
  ///        tianGuaNum, diGuaNum, usedThreeYuanWuGong)
  static (
    Enum8Gua, // tianGua
    Enum8Gua, // diGua
    List<int>, // ganNumList
    List<List<int>>, // zhiNumList
    int, // oddNumTotal
    int, // evenNumTotal
    int, // tianGuaNum
    int, // diGuaNum
    bool, // usedThreeYuanWuGong
  )
  generateTianDiGua({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
  }) {
    // print("~~~~~~~~");
    // 提取四柱天干数列表
    final ganNumList = [
      constants.ganNumberMapper[eightChars.year.gan]!,
      constants.ganNumberMapper[eightChars.month.gan]!,
      constants.ganNumberMapper[eightChars.day.gan]!,
      constants.ganNumberMapper[eightChars.time.gan]!,
    ];

    // 提取四柱地支数列表（每个地支两个数）
    final zhiNumList = [
      constants.zhiNumberMapper[eightChars.year.zhi]!,
      constants.zhiNumberMapper[eightChars.month.zhi]!,
      constants.zhiNumberMapper[eightChars.day.zhi]!,
      constants.zhiNumberMapper[eightChars.time.zhi]!,
    ];

    // 展开地支数列表用于计算奇偶和
    final zhiNumTotalList = [
      ...constants.zhiNumberMapper[eightChars.year.zhi]!,
      ...constants.zhiNumberMapper[eightChars.month.zhi]!,
      ...constants.zhiNumberMapper[eightChars.day.zhi]!,
      ...constants.zhiNumberMapper[eightChars.time.zhi]!,
    ];

    // 计算奇数和、偶数和
    final oddNumTotal =
        (ganNumList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b));

    final evenNumTotal =
        (ganNumList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b));

    // 计算天数（奇数和 模25）
    final tianGuaNum = gua_utils.calculateGuaNum(oddNumTotal, 25, 5);

    // 计算地数（偶数和 模30）
    final diGuaNum = gua_utils.calculateGuaNum(evenNumTotal, 30, 3);
    // 数配卦
    final yearYinYang = eightChars.yearTianGan.yinYang;
    Enum8Gua tianGua;
    Enum8Gua diGua;
    bool usedThreeYuanWuGong = true;

    // 天卦配卦（天数为5时查询三元五宫）
    tianGua = numberToHouTianGua(
      number: tianGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );

    // 地卦配卦（地数为5时查询三元五宫）
    diGua = numberToHouTianGua(
      number: diGuaNum,
      gender: gender,
      threeYuan: threeYuan,
      yearYinYang: yearYinYang,
    );

    return (
      tianGua,
      diGua,
      ganNumList,
      zhiNumList,
      oddNumTotal,
      evenNumTotal,
      tianGuaNum,
      diGuaNum,
      usedThreeYuanWuGong,
    );
  }

  /// 获取应爻位置（用于流月卦计算）
  ///
  /// 传统六爻术数中的应爻对应关系：
  /// - 初爻(0) ←→ 四爻(3)
  /// - 二爻(1) ←→ 五爻(4)
  /// - 三爻(2) ←→ 上爻(5)
  ///
  /// 参数：
  /// - [yaoIndex]: 爻位索引（0-5）
  ///
  /// 返回: 对应的应爻索引（0-5）
  static int _getYingYaoIndex(int yaoIndex) {
    return (yaoIndex + 3) % 6;
  }
}
