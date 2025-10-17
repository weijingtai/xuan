import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../../utils/utils.dart' as GuaUtils;
import '../../utils/yuan_tang_gua_helper.dart';

// 元堂卦类
class YuanTangGua {
  /// 三元五宫映射表
  /// 上元：男艮女坤，中元：阳(年)男艮阴坤，阳(年)女坤阴艮；下元：男离女兑
  static final Map<YuanYunOrder, Map<Gender, Map<YinYang, Enum8Gua>>>
  _threeYuan5GongMapper = YuanTangGuaHelper.threeYuan5GongMapper;

  final EightChars fourZhu;
  final Gender gender;
  final YuanYunOrder threeYuan;
  final TwentyFourJieQi birthAfterZhi;
  final int yuantanYaoIndex;
  final Enum64Gua xiantianGua;
  final Enum64Gua houtianGua;
  final List<List<String>> zhiList;

  YuanTangGua({
    required this.fourZhu,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    required this.yuantanYaoIndex,
    required this.xiantianGua,
    required this.houtianGua,
    required this.zhiList,
  });

  /// 生成上下卦
  static (Enum8Gua, Enum8Gua) generateUponUnderGua(
    Enum8Gua tianGua,
    Enum8Gua diGua,
    YinYang yearYinYang,
    Gender gender,
  ) {
    Enum8Gua uponGua;
    Enum8Gua underGua;

    if (yearYinYang == YinYang.YANG) {
      if (gender == Gender.male) {
        uponGua = tianGua;
        underGua = diGua;
      } else {
        uponGua = diGua;
        underGua = tianGua;
      }
    } else {
      if (gender == Gender.female) {
        uponGua = tianGua;
        underGua = diGua;
      } else {
        uponGua = diGua;
        underGua = tianGua;
      }
    }
    return (uponGua, underGua);
  }

  /// 生成天地卦
  static (Enum8Gua, Enum8Gua) generateTianDiGua(
    Gender gender,
    bool isYangYear,
    YuanYunOrder threeYuan,
    List<int> ganNumTotalList,
    List<int> zhiNumTotalList,
  ) {
    // 两个数组中所有的奇数相加，偶数相加
    int oddNumTotal =
        ganNumTotalList.where((i) => i % 2 == 1).fold(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 1).fold(0, (a, b) => a + b);
    int evenNumTotal =
        ganNumTotalList.where((i) => i % 2 == 0).fold(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 0).fold(0, (a, b) => a + b);

    // 2.1. 天数为25, 求得奇数和 ==25 用"5"; >25 以25取模，<25，不用十位
    int tianGuaNum = GuaUtils.calculateGuaNum(oddNumTotal, 25, 5);
    // 2.2. 地数为30 求得偶数和 ==30 用"3"; >30 以30取模，<30，不用十位。
    int diGuaNum = GuaUtils.calculateGuaNum(evenNumTotal, 30, 3);

    // 数配卦 -- 后天卦
    YinYang yearYinYang = isYangYear ? YinYang.YANG : YinYang.YIN;
    Enum8Gua tianGua;
    Enum8Gua diGua;

    if (tianGuaNum == 5) {
      tianGua = _threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    } else {
      tianGua = Constants.yuanTangHuaTianNumberGuaMapper[tianGuaNum]!;
    }

    if (diGuaNum == 5) {
      diGua = _threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    } else {
      diGua = Constants.yuanTangHuaTianNumberGuaMapper[diGuaNum]!;
    }

    return (tianGua, diGua);
  }

  /// 先天卦，加则法获得条文编号
  int get tiaowenNumberJiazeXiantiangua {
    return TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);
  }

  /// 后天卦，加则法获得条文编号
  int get tiaowenNumberJiazeHoutiangua {
    return TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);
  }

  /// 先天卦，纳甲太玄数条文编号
  int get tiaowenNumberNajiaTaixuanXiantiangua {
    return TiaowenCalculator.getTiaowenNumberByTaixuan(xiantianGua);
  }

  /// 后天卦，纳甲太玄数条文编号
  int get tiaowenNumberNajiaTaixuanHoutiangua {
    return TiaowenCalculator.getTiaowenNumberByTaixuan(houtianGua);
  }

  /// 先天卦互卦
  Enum64Gua get xiantianGuaHu {
    return GuaUtils.guaToHuGua(xiantianGua);
  }

  /// 后天卦互卦
  Enum64Gua get houtianGuaHu {
    return GuaUtils.guaToHuGua(houtianGua);
  }

  /// 先天卦本互条文编号
  /// 先天卦：上卦为千位，下卦为百位，
  /// 先天卦互卦：上卦为十位，下卦为个位
  /// 数取卦的先天数
  int get tiaowenNumberXiantianBenhu {
    Enum64Gua ben = xiantianGua;
    Enum8Gua benUpon = ben.top;
    Enum8Gua benUnder = ben.bottom;
    Enum64Gua hu = xiantianGuaHu;
    Enum8Gua huUpon = hu.top;
    Enum8Gua huUnder = hu.bottom;

    int benUponNum = Constants.xianGuaNumberMapper[benUpon]!;
    int benUnderNum = Constants.xianGuaNumberMapper[benUnder]!;
    int huUponNum = Constants.xianGuaNumberMapper[huUpon]!;
    int huUnderNum = Constants.xianGuaNumberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 后天卦本互条文编号
  /// 后天卦：上卦为千位，下卦为百位，
  /// 后天卦互卦：上卦为十位，下卦为个位
  /// 数取卦的后天数
  int get tiaowenNumberHoutianBenhu {
    Enum64Gua ben = houtianGua;
    Enum8Gua benUpon = ben.top;
    Enum8Gua benUnder = ben.bottom;
    Enum64Gua hu = houtianGuaHu;
    Enum8Gua huUpon = hu.top;
    Enum8Gua huUnder = hu.bottom;

    int benUponNum = Constants.houGuaNumberMapper[benUpon]!;
    int benUnderNum = Constants.houGuaNumberMapper[benUnder]!;
    int huUponNum = Constants.houGuaNumberMapper[huUpon]!;
    int huUnderNum = Constants.houGuaNumberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 先后天卦取数 - 先天卦+其互卦
  List<int> get tiaowenNumberListXiantianGuahu {
    return [
      ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
        tiaowenNumberXiantianBenhu,
        [2, 4, 8, 16],
      ),
      ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
        tiaowenNumberXiantianBenhu,
      ),
    ];
  }

  /// 先后天卦取数 - 后天卦+其互卦
  List<int> get tiaowenNumberListHoutianGuahu {
    return [
      ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
        tiaowenNumberHoutianBenhu,
        [2, 4, 8, 16],
      ),
      ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
        tiaowenNumberHoutianBenhu,
      ),
    ];
  }

  /// 生成元堂卦
  static YuanTangGua generateYuantanGua({
    required EightChars fourZhu,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    bool isYangYear = fourZhu.year.gan.isYang;
    List<int> ganNumTotalList = [
      Constants.ganNumberMapper[fourZhu.year.gan]!,
      Constants.ganNumberMapper[fourZhu.month.gan]!,
      Constants.ganNumberMapper[fourZhu.day.gan]!,
      Constants.ganNumberMapper[fourZhu.time.gan]!,
    ];
    List<int> zhiNumTotalList = [
      ...Constants.zhiNumberMapper[fourZhu.year.zhi]!,
      ...Constants.zhiNumberMapper[fourZhu.month.zhi]!,
      ...Constants.zhiNumberMapper[fourZhu.day.zhi]!,
      ...Constants.zhiNumberMapper[fourZhu.time.zhi]!,
    ];

    final tuple = generateTianDiGua(
      gender,
      isYangYear,
      threeYuan,
      ganNumTotalList,
      zhiNumTotalList,
    );
    Enum8Gua tianGua = tuple.$1;
    Enum8Gua diGua = tuple.$2;

    YinYang yearYinYang = isYangYear ? YinYang.YANG : YinYang.YIN;
    final (uponGua, underGua) = generateUponUnderGua(
      tianGua,
      diGua,
      yearYinYang,
      gender,
    );

    final yuantanBenGua = Enum64Gua.getBy8Gua(uponGua, underGua);

    final (yuantangYaoIndex, dizhiList) = yuantangZhuanggua(
      yuantanBenGua,
      fourZhu.time,
      gender,
      birthAfterZhi,
    );

    PureSixYaoGua.by8Gua(
      yuantanBenGua.top,
      yuantanBenGua.bottom,
    ).bianYaoByOrder(yuantangYaoIndex + 1);
    List<int> benBinaryGua = GuaUtils.guaToBinaryList(yuantanBenGua);

    // 5. 计算全部条文
    Enum64Gua houtianGua = yuantangHoutianGuaFromXiantianGua(
      benBinaryGua,
      yuantangYaoIndex,
    );
    return YuanTangGua(
      fourZhu: fourZhu,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      yuantanYaoIndex: yuantangYaoIndex,
      xiantianGua: yuantanBenGua,
      houtianGua: houtianGua,
      zhiList: dizhiList,
    );
  }

  /// 元堂装卦
  static (int, List<List<String>>) yuantangZhuanggua(
    Enum64Gua guaName,
    JiaZi timeGanzhi,
    Gender gender,
    TwentyFourJieQi birthAfterZhi,
  ) {
    // 1. 阳时生人取阳爻为元堂爻，阴时生人取阴爻为元堂爻
    List<String> yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    List<String> yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];
    YinYang timeYinyang = YinYang.YANG;
    if (!yuantangYangTimeSet.contains(timeGanzhi.zhi.name)) {
      timeYinyang = YinYang.YIN;
    }

    // 2. 卦中不同阴阳爻数量装卦不同
    List<int> uponBinary = Constants.guaBinaryMapper[guaName.top.name]!;
    List<int> underBinary = Constants.guaBinaryMapper[guaName.bottom.name]!;
    List<int> allGuaBinary = [...uponBinary, ...underBinary];
    int totalYangYao = allGuaBinary.where((x) => x == 1).length;
    int totalYinYao = allGuaBinary.where((x) => x == 0).length;

    List<List<String>> resultList = [];
    if (timeYinyang == YinYang.YANG) {
      // 2.1. 阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        resultList = yuantanZhuangguaLowerThan3(
          allGuaBinary,
          yuantangYangTimeSet,
          totalYangYao,
          true,
        );
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        resultList = yuantanZhuanggua45(
          allGuaBinary,
          yuantangYangTimeSet,
          totalYangYao,
          true,
        );
      } else {
        resultList = yuantanZhuanggua6Yang(
          totalYangYao == 6,
          yuantangYangTimeSet,
          true,
          gender,
          birthAfterZhi,
        );
      }
    } else {
      if (totalYinYao > 0 && totalYinYao <= 3) {
        resultList = yuantanZhuangguaLowerThan3(
          allGuaBinary,
          yuantangYinTimeSet,
          totalYinYao,
          false,
        );
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        resultList = yuantanZhuanggua45(
          allGuaBinary,
          yuantangYinTimeSet,
          totalYinYao,
          false,
        );
      } else {
        resultList = yuantanZhuanggua6Yang(
          totalYinYao == 0,
          yuantangYinTimeSet,
          false,
          gender,
          birthAfterZhi,
        );
      }
    }
    int resultYuantanYaoIndex = getYuantanYaoIndex(timeGanzhi, resultList);
    return (resultYuantanYaoIndex, resultList);
  }

  /// 获取元堂爻索引
  static int getYuantanYaoIndex(
    JiaZi timeGanzhi,
    List<List<String>> yangTangYaoZhiList,
  ) {
    int resultYuantanYaoIndex = -1;
    for (int i = 0; i < yangTangYaoZhiList.length; i++) {
      if (yangTangYaoZhiList[i].contains(timeGanzhi.zhi.name)) {
        resultYuantanYaoIndex = i;
        break;
      }
    }
    return resultYuantanYaoIndex;
  }

  /// 元堂装卦，6爻全阳
  static List<List<String>> yuantanZhuanggua6Yang(
    bool isSixYang,
    List<String> timeZhiList,
    bool isYang,
    Gender gender,
    TwentyFourJieQi birthAfterZhi,
  ) {
    List<List<String>> threeYaoZhuang(List<String> dizhiList, bool isUp2Down) {
      List<String> tmpDizhiList = List.from(dizhiList);
      List<List<String>> result = [[], [], []];
      for (int i = 0; i < dizhiList.length; i++) {
        if (tmpDizhiList.isEmpty) {
          break;
        }
        for (int j = 0; j < 3; j++) {
          if (tmpDizhiList.isNotEmpty) {
            result[j].add(tmpDizhiList.removeAt(0));
          }
        }
      }
      if (isUp2Down) {
        return result;
      } else {
        return result.reversed.toList();
      }
    }

    if (isSixYang) {
      // 六阳爻
      if (gender == "男") {
        List<List<String>> tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [[], [], [], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, [], [], []];
        }
      } else {
        // gender == "女"
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [[], [], [], ...threeYaoZhuang(timeZhiList, false)];
          } else {
            // 冬至后出生 上卦自上而下
            return [...threeYaoZhuang(timeZhiList, true), [], [], []];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [...threeYaoZhuang(timeZhiList, false), [], [], []];
          } else {
            // 冬至后出生 上卦自上而下
            return [[], [], [], ...threeYaoZhuang(timeZhiList, true)];
          }
        }
      }
    } else {
      // 六阴爻
      if (gender == "女") {
        List<List<String>> tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [[], [], [], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, [], [], []];
        }
      } else {
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [[], [], [], ...threeYaoZhuang(timeZhiList, false)];
          } else {
            // 冬至后出生 上卦自上而下
            return [...threeYaoZhuang(timeZhiList, true), [], [], []];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [...threeYaoZhuang(timeZhiList, false), [], [], []];
          } else {
            // 冬至后出生 上卦自上而下
            return [[], [], [], ...threeYaoZhuang(timeZhiList, true)];
          }
        }
      }
    }
  }

  /// 元堂装卦 4-5爻
  static List<List<String>> yuantanZhuanggua45(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    // 子丑寅卯自上而下排在阳爻，辰巳排在阴爻也是自上而下
    List<String> tmpTimeList = List.from(timeZhiList);
    List<String> firstFourZhi = tmpTimeList.sublist(0, totalYao);
    List<String> leftZhiList = tmpTimeList.sublist(totalYao);
    List<int> tmpBinList = List.from(guaBinaryList);
    tmpBinList = tmpBinList.reversed.toList();
    List<List<String>> resultList = [];

    int firstIndex = 0;
    int leftIndex = 0;

    for (int i = 0; i < tmpBinList.length; i++) {
      if (isYang) {
        if (tmpBinList[i] == 1) {
          resultList.add(
            firstIndex < firstFourZhi.length
                ? [firstFourZhi[firstIndex++]]
                : [],
          );
        } else {
          resultList.add(
            leftIndex < leftZhiList.length ? [leftZhiList[leftIndex++]] : [],
          );
        }
      } else {
        if (tmpBinList[i] == 0) {
          resultList.add(
            firstIndex < firstFourZhi.length
                ? [firstFourZhi[firstIndex++]]
                : [],
          );
        } else {
          resultList.add(
            leftIndex < leftZhiList.length ? [leftZhiList[leftIndex++]] : [],
          );
        }
      }
    }

    return resultList.reversed.toList();
  }

  /// 元堂爻数小于3的情况
  static List<List<String>> yuantanZhuangguaLowerThan3(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    List<String> yinyangZhiList = List.from(timeZhiList);
    List<String> doubleZhi4Yang = yinyangZhiList.sublist(0, 2 * totalYao);
    int totalDoubleZhi = doubleZhi4Yang.length;
    List<String> leftZhiList = yinyangZhiList.sublist(2 * totalYao);

    List<List<String>> zhiList = List.generate(6, (_) => <String>[]);
    List<int> tmpBinaryList = List.from(guaBinaryList);
    tmpBinaryList = tmpBinaryList.reversed.toList();

    int doubleZhiIndex = 0;

    for (int i = 0; i < totalDoubleZhi; i++) {
      for (int j = 0; j < 6; j++) {
        if (isYang) {
          if (tmpBinaryList[j] == 1 && doubleZhiIndex < doubleZhi4Yang.length) {
            zhiList[j].add(doubleZhi4Yang[doubleZhiIndex++]);
          }
        } else {
          if (tmpBinaryList[j] == 0 && doubleZhiIndex < doubleZhi4Yang.length) {
            zhiList[j].add(doubleZhi4Yang[doubleZhiIndex++]);
          }
        }
      }
    }

    List<List<String>> resultList = [];
    int leftIndex = 0;

    for (int i = 0; i < 6; i++) {
      // 当还有剩余的地支时，将其装填到没有地支的爻中
      if (zhiList[i].isEmpty && leftIndex < leftZhiList.length) {
        resultList.add([leftZhiList[leftIndex++]]);
      } else {
        resultList.add(zhiList[i]);
      }
    }

    return resultList.reversed.toList();
  }
}

/// 根据基本卦和元堂爻，计算出后天卦
Enum64Gua yuantangHoutianGuaFromXiantianGua(
  List<int> benBinaryList,
  int yuantangYaoIndex,
) {
  List<int> benBinaryListCopy = List.from(benBinaryList);
  // 1. 元堂爻 进行爻变， 阴转阳 阳转阴
  if (benBinaryListCopy[yuantangYaoIndex] == 0) {
    benBinaryListCopy[yuantangYaoIndex] = 1;
  } else {
    benBinaryListCopy[yuantangYaoIndex] = 0;
  }
  // 2. 将转换后的两个八经卦，上下互换
  // 2.1. 拆分成两个卦
  String oldUpon = benBinaryListCopy.sublist(0, 3).join();
  String oldUnder = benBinaryListCopy.sublist(3).join();
  // 2.2. 根据list[int] -> str(binary_str) 找到八经卦
  String oldUponGua = Constants.binaryStrGuaMapper[oldUpon]!;
  String oldUnderGua = Constants.binaryStrGuaMapper[oldUnder]!;
  // 3. 互换 并返回
  return Enum64Gua.getBy8Gua(
    Enum8Gua.fromValue(oldUnderGua),
    Enum8Gua.fromValue(oldUponGua),
  );
}

/// 元堂取数（已弃用的函数）
@deprecated
(List<int>, String) yuantangQushu(
  String yearGanzhi,
  String monthGanzhi,
  String dayGanzhi,
  String timeGanzhi,
  bool isYangYear,
  String gender,
  String threeYuan,
  String birthAfterZhi,
  Function getTiaowenFunc,
) {
  // 这是一个已弃用的函数，保留用于兼容性
  // 实际使用应该使用 YuanTangGua.generateYuantanGua 方法
  throw UnimplementedError(
    'This function is deprecated. Use YuanTangGua.generateYuantanGua instead.',
  );
}

/// 测试函数示例
void testYuantangGua() {
  // 创建测试用的四柱
  EightChars fourZhu = EightChars(
    year: JiaZi.getFromGanZhiValue("甲戌")!,
    month: JiaZi.getFromGanZhiValue("己巳")!,
    day: JiaZi.getFromGanZhiValue("辛丑")!,
    time: JiaZi.getFromGanZhiValue("丁酉")!,
  );

  // 生成元堂卦
  YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
    fourZhu: fourZhu,
    gender: Gender.male,
    threeYuan: YuanYunOrder.upper,
    birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
  );

  print('先天卦: ${yuanTangGua.xiantianGua}');
  print('后天卦: ${yuanTangGua.houtianGua}');
  print('元堂爻索引: ${yuanTangGua.yuantanYaoIndex}');
  print('地支列表: ${yuanTangGua.zhiList}');
  print('先天卦条文编号(加则法): ${yuanTangGua.tiaowenNumberJiazeXiantiangua}');
  print('后天卦条文编号(加则法): ${yuanTangGua.tiaowenNumberJiazeHoutiangua}');
  print('先天卦本互条文编号: ${yuanTangGua.tiaowenNumberXiantianBenhu}');
  print('后天卦本互条文编号: ${yuanTangGua.tiaowenNumberHoutianBenhu}');
}
