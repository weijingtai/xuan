import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../../utils/utils.dart' as GuaUtils;

// 元堂卦类
class YuanTangGua {
  /// 三元五宫映射表
  /// 上元：男艮女坤，中元：阳(年)男艮阴坤，阳(年)女坤阴艮；下元：男离女兑
  static const Map<String, Map<String, Map<String, String>>>
  _threeYuan5GongMapper = {
    "上": {
      "男": {"阳": "艮", "阴": "艮"},
      "女": {"阳": "坤", "阴": "坤"},
    },
    "中": {
      "男": {"阳": "艮", "阴": "坤"},
      "女": {"阳": "坤", "阴": "艮"},
    },
    "下": {
      "男": {"阳": "离", "阴": "离"},
      "女": {"阳": "兑", "阴": "兑"},
    },
  };

  final FourZhu fourZhu;
  final String gender;
  final String threeYuan;
  final String birthAfterZhi;
  final int yuantanYaoIndex;
  final String xiantianGua;
  final String houtianGua;
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
  static (String, String) generateUponUnderGua(
    String tianGua,
    String diGua,
    String yearYinYang,
    String gender,
  ) {
    String uponGua;
    String underGua;

    if (yearYinYang == "阳") {
      if (gender == "男") {
        uponGua = tianGua;
        underGua = diGua;
      } else {
        uponGua = diGua;
        underGua = tianGua;
      }
    } else {
      if (gender == "女") {
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
  static (String, String) generateTianDiGua(
    String gender,
    bool isYangYear,
    String threeYuan,
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
    String yearYinYang = isYangYear ? "阳" : "阴";
    String tianGua;
    String diGua;

    if (tianGuaNum == 5) {
      tianGua = _threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    } else {
      tianGua = Constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
    }

    if (diGuaNum == 5) {
      diGua = _threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    } else {
      diGua = Constants.yuantangHuaTianNumberGuaMapper[diGuaNum]!;
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
  String get xiantianGuaHu {
    return GuaUtils.guaToHuGua(xiantianGua);
  }

  /// 后天卦互卦
  String get houtianGuaHu {
    return GuaUtils.guaToHuGua(houtianGua);
  }

  /// 先天卦本互条文编号
  /// 先天卦：上卦为千位，下卦为百位，
  /// 先天卦互卦：上卦为十位，下卦为个位
  /// 数取卦的先天数
  int get tiaowenNumberXiantianBenhu {
    String ben = xiantianGua;
    String benUpon = ben[0];
    String benUnder = ben[1];
    String hu = xiantianGuaHu;
    String huUpon = hu[0];
    String huUnder = hu[1];

    int benUponNum = Constants.xianTianGuaNumberMapper[benUpon]!;
    int benUnderNum = Constants.xianTianGuaNumberMapper[benUnder]!;
    int huUponNum = Constants.xianTianGuaNumberMapper[huUpon]!;
    int huUnderNum = Constants.xianTianGuaNumberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 后天卦本互条文编号
  /// 后天卦：上卦为千位，下卦为百位，
  /// 后天卦互卦：上卦为十位，下卦为个位
  /// 数取卦的后天数
  int get tiaowenNumberHoutianBenhu {
    String ben = houtianGua;
    String benUpon = ben[0];
    String benUnder = ben[1];
    String hu = houtianGuaHu;
    String huUpon = hu[0];
    String huUnder = hu[1];

    int benUponNum = Constants.houTianGuaNumberMapper[benUpon]!;
    int benUnderNum = Constants.houTianGuaNumberMapper[benUnder]!;
    int huUponNum = Constants.houTianGuaNumberMapper[huUpon]!;
    int huUnderNum = Constants.houTianGuaNumberMapper[huUnder]!;

    return int.parse('$benUponNum$benUnderNum$huUponNum$huUnderNum');
  }

  /// 先后天卦取数 - 先天卦+其互卦
  List<int> get tiaowenNumberListXiantianGuahu {
    return [
      ...TiaowenCalculator.calculateTiaoWenListBySubMultipleFactorTimes(
        tiaowenNumberXiantianBenhu,
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
      ),
      ...TiaowenCalculator.calculateTiaoWenListByAddMultipleFactorTimes(
        tiaowenNumberHoutianBenhu,
      ),
    ];
  }

  /// 生成元堂卦
  static YuanTangGua generateYuantanGua({
    required FourZhu fourZhu,
    required String gender,
    required String threeYuan,
    required String birthAfterZhi,
  }) {
    bool isYangYear = fourZhu.isYangGanYear;
    List<int> ganNumTotalList = [
      Constants.tianGanNumberMapper[fourZhu.yearGan]!,
      Constants.tianGanNumberMapper[fourZhu.monthGan]!,
      Constants.tianGanNumberMapper[fourZhu.dayGan]!,
      Constants.tianGanNumberMapper[fourZhu.timeGan]!,
    ];
    List<int> zhiNumTotalList = [
      ...Constants.diZhiNumberMapper[fourZhu.yearZhi]!,
      ...Constants.diZhiNumberMapper[fourZhu.monthZhi]!,
      ...Constants.diZhiNumberMapper[fourZhu.dayZhi]!,
      ...Constants.diZhiNumberMapper[fourZhu.timeZhi]!,
    ];

    final tuple = generateTianDiGua(
      gender,
      isYangYear,
      threeYuan,
      ganNumTotalList,
      zhiNumTotalList,
    );
    String tianGua = tuple.$1;
    String diGua = tuple.$2;

    String yearYinYangStr = isYangYear ? "阳" : "阴";
    final (uponGua, underGua) = generateUponUnderGua(
      tianGua,
      diGua,
      yearYinYangStr,
      gender,
    );

    final yuantanBenGua = uponGua + underGua;

    final (yuantangYaoIndex, dizhiList) = yuantangZhuanggua(
      yuantanBenGua,
      fourZhu.timeGanzhi,
      gender,
      birthAfterZhi,
    );
    List<int> benBinaryGua = GuaUtils.guaToBinaryList(yuantanBenGua);

    // 5. 计算全部条文
    String houtianGua = yuantangHoutianGuaFromXiantianGua(
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
    String guaName,
    String timeGanzhi,
    String gender,
    String birthAfterZhi,
  ) {
    // 1. 阳时生人取阳爻为元堂爻，阴时生人取阴爻为元堂爻
    List<String> yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    List<String> yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];
    String timeYinyang = "阳";
    if (!yuantangYangTimeSet.contains(
      timeGanzhi.substring(timeGanzhi.length - 1),
    )) {
      timeYinyang = "阴";
    }

    // 2. 卦中不同阴阳爻数量装卦不同
    List<int> uponBinary = Constants.guaBinaryMapper[guaName[0]]!;
    List<int> underBinary =
        Constants.guaBinaryMapper[guaName[guaName.length - 1]]!;
    List<int> allGuaBinary = [...uponBinary, ...underBinary];
    int totalYangYao = allGuaBinary.where((x) => x == 1).length;
    int totalYinYao = allGuaBinary.where((x) => x == 0).length;

    List<List<String>> resultList = [];
    if (timeYinyang == "阳") {
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
    String timeZhi,
    List<List<String>> yangTangYaoZhiList,
  ) {
    int resultYuantanYaoIndex = -1;
    for (int i = 0; i < yangTangYaoZhiList.length; i++) {
      if (yangTangYaoZhiList[i].contains(
        timeZhi.substring(timeZhi.length - 1),
      )) {
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
    String gender,
    String birthAfterZhi,
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
String yuantangHoutianGuaFromXiantianGua(
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
  return oldUnderGua + oldUponGua;
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
  FourZhu fourZhu = FourZhu(
    yearGanzhi: "甲戌",
    monthGanzhi: "己巳",
    dayGanzhi: "辛丑",
    timeGanzhi: "丁酉",
  );

  // 生成元堂卦
  YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
    fourZhu: fourZhu,
    gender: "男",
    threeYuan: "上",
    birthAfterZhi: "夏至",
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
