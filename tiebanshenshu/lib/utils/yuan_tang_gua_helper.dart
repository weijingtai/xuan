/// 元堂卦辅助工具类
///
/// 提供元堂卦相关的静态方法，供各种策略复用
library;

import 'package:common/models/eight_chars.dart';

import '../domain/four_zhu.dart';
import '../constant/constants.dart' as constants;
import 'utils.dart' as gua_utils;

/// 元堂卦辅助类
///
/// 封装元堂卦的核心逻辑，包括：
/// - 生成天地卦
/// - 生成先天卦
/// - 元堂装卦
/// - 生成后天卦
/// - 后天卦元堂装卦
class YuanTangGuaHelper {
  /// 三元五宫映射表（当天数或地数为5时使用）
  static const Map<String, Map<String, Map<String, String>>>
  threeYuan5GongMapper = {
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
    String, // tianGua
    String, // diGua
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
    required String gender,
    required String threeYuan,
  }) {
    // 提取四柱天干数列表
    final ganNumList = [
      constants.tianGanNumberMapper[eightChars.year.gan.name]!,
      constants.tianGanNumberMapper[eightChars.month.gan.name]!,
      constants.tianGanNumberMapper[eightChars.day.gan.name]!,
      constants.tianGanNumberMapper[eightChars.time.gan.name]!,
    ];

    // 提取四柱地支数列表（每个地支两个数）
    final zhiNumList = [
      constants.diZhiNumberMapper[eightChars.year.zhi.name]!,
      constants.diZhiNumberMapper[eightChars.month.zhi.name]!,
      constants.diZhiNumberMapper[eightChars.day.zhi.name]!,
      constants.diZhiNumberMapper[eightChars.time.zhi.name]!,
    ];

    // 展开地支数列表用于计算奇偶和
    final zhiNumTotalList = [
      ...constants.diZhiNumberMapper[eightChars.year.zhi.name]!,
      ...constants.diZhiNumberMapper[eightChars.month.zhi.name]!,
      ...constants.diZhiNumberMapper[eightChars.day.zhi.name]!,
      ...constants.diZhiNumberMapper[eightChars.time.zhi.name]!,
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
    final yearYinYang = eightChars.yearTianGan.isYang ? "阳" : "阴";
    String tianGua;
    String diGua;
    bool usedThreeYuanWuGong = false;

    // 天卦配卦（天数为5时查询三元五宫）
    if (tianGuaNum == 5) {
      tianGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
      usedThreeYuanWuGong = true;
    } else {
      if (!constants.yuantangHuaTianNumberGuaMapper.containsKey(tianGuaNum)) {
        throw ArgumentError('无效的天数: $tianGuaNum，映射表中不存在该键');
      }
      tianGua = constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
    }

    // 地卦配卦（地数为5时查询三元五宫）
    if (diGuaNum == 5) {
      diGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
      usedThreeYuanWuGong = true;
    } else {
      if (!constants.yuantangHuaTianNumberGuaMapper.containsKey(diGuaNum)) {
        throw ArgumentError('无效的地数: $diGuaNum，映射表中不存在该键');
      }
      diGua = constants.yuantangHuaTianNumberGuaMapper[diGuaNum]!;
    }

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

  /// 生成先天卦（上下卦）
  ///
  /// 参数：
  /// - [eightChars]: 四柱信息
  /// - [gender]: 性别（"男" / "女"）
  /// - [tianGua]: 天卦
  /// - [diGua]: 地卦
  ///
  /// 返回: (yearYinYang, upperGua, lowerGua, xiantianGua,
  ///        xiantianUpperGuaNumber, xiantianLowerGuaNumber)
  static (
    String, // yearYinYang
    String, // upperGua
    String, // lowerGua
    String, // xiantianGua
    int, // xiantianUpperGuaNumber
    int, // xiantianLowerGuaNumber
  )
  generateXiantianGua({
    required EightChars eightChars,
    required String gender,
    required String tianGua,
    required String diGua,
  }) {
    final yearYinYang = eightChars.yearTianGan.isYang ? "阳" : "阴";
    String upperGua;
    String lowerGua;

    // 根据年份阴阳和性别决定上下卦位置
    if (yearYinYang == "阳") {
      if (gender == "男") {
        upperGua = tianGua;
        lowerGua = diGua;
      } else {
        upperGua = diGua;
        lowerGua = tianGua;
      }
    } else {
      if (gender == "女") {
        upperGua = tianGua;
        lowerGua = diGua;
      } else {
        upperGua = diGua;
        lowerGua = tianGua;
      }
    }

    final xiantianGua = upperGua + lowerGua;

    // 查询后天数
    final xiantianUpperGuaNumber = constants.houTianGuaNumberMapper[upperGua]!;
    final xiantianLowerGuaNumber = constants.houTianGuaNumberMapper[lowerGua]!;

    return (
      yearYinYang,
      upperGua,
      lowerGua,
      xiantianGua,
      xiantianUpperGuaNumber,
      xiantianLowerGuaNumber,
    );
  }

  /// 元堂装卦
  ///
  /// 参数：
  /// - [eightChars]: 四柱信息
  /// - [xiantianGua]: 先天卦
  /// - [gender]: 性别（"男" / "女"）
  /// - [birthAfterZhi]: 出生节气后（"夏至" / "冬至"）
  ///
  /// 返回: (yuantangYaoIndex, yuantangYaoLabel, zhiList, timeGanzhi,
  ///        timeYinYang, totalYangYao, totalYinYao)
  static (
    int, // yuantangYaoIndex
    String, // yuantangYaoLabel
    List<List<String>>, // zhiList
    String, // timeGanzhi
    String, // timeYinYang
    int, // totalYangYao
    int, // totalYinYao
  )
  yuantangZhuanggua({
    required EightChars eightChars,
    required String xiantianGua,
    required String gender,
    required String birthAfterZhi,
  }) {
    final timeGanzhi = eightChars.time.name;

    // 判断时辰阴阳
    const yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    const yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];

    final timeZhi = timeGanzhi.substring(timeGanzhi.length - 1);
    final timeYinYang = yuantangYangTimeSet.contains(timeZhi) ? "阳" : "阴";

    // 将卦转换为二进制列表
    final upperBinary = constants.guaBinaryMapper[xiantianGua[0]]!;
    final lowerBinary = constants.guaBinaryMapper[xiantianGua[1]]!;
    final allGuaBinary = [...upperBinary, ...lowerBinary];

    // 计算阳爻和阴爻数量
    final totalYangYao = allGuaBinary.where((x) => x == 1).length;
    final totalYinYao = allGuaBinary.where((x) => x == 0).length;

    // 根据时辰阴阳和爻数分类处理
    List<List<String>> zhiList;
    if (timeYinYang == "阳") {
      // 阳时取阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          totalYangYao,
          true,
        );
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        zhiList = _zhuanggua45(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          totalYangYao,
          true,
        );
      } else {
        zhiList = _zhuanggua6Yang(
          totalYangYao == 6,
          List.from(yuantangYangTimeSet),
          true,
          gender,
          birthAfterZhi,
        );
      }
    } else {
      // 阴时取阴爻
      if (totalYinYao > 0 && totalYinYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          totalYinYao,
          false,
        );
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        zhiList = _zhuanggua45(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          totalYinYao,
          false,
        );
      } else {
        zhiList = _zhuanggua6Yang(
          totalYinYao == 0,
          List.from(yuantangYinTimeSet),
          false,
          gender,
          birthAfterZhi,
        );
      }
    }

    // 获取元堂爻索引
    final yuantangYaoIndex = _getYuantangYaoIndex(timeGanzhi, zhiList);

    // 获取元堂爻位标签
    final yuantangYaoLabel = _getYaoPositionLabel(yuantangYaoIndex);

    return (
      yuantangYaoIndex,
      yuantangYaoLabel,
      zhiList,
      timeGanzhi,
      timeYinYang,
      totalYangYao,
      totalYinYao,
    );
  }

  /// 生成后天卦
  ///
  /// 参数：
  /// - [xiantianGua]: 先天卦
  /// - [yuantangYaoIndex]: 元堂爻索引（0-5）
  /// - [birthMonth]: 出生月份(1-12,从monthZhi提取)
  ///
  /// 返回: (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber)
  ///
  /// 算法：
  /// 1. 判断是否为至尊卦(坎坎、坎震、坎艮)且元堂爻在九五(4)或上六(5)
  /// 2. 如果是至尊卦特殊情况，根据月份阴阳决定是否互换上下卦
  /// 3. 否则，将先天卦转换为二进制列表，对元堂爻进行爻变（阴转阳，阳转阴），上下卦互换
  static (
    String, // houtianGua
    int, // houtianUpperGuaNumber
    int, // houtianLowerGuaNumber
  )
  generateHoutianGua({
    required String xiantianGua,
    required int yuantangYaoIndex,
    required int birthMonth,
  }) {
    // 判断是否为至尊卦且在特殊爻位
    final isZhiZunGua = ['坎坎', '坎震', '坎艮'].contains(xiantianGua);
    final isSpecialYao = (yuantangYaoIndex == 4 || yuantangYaoIndex == 5);

    if (isZhiZunGua && isSpecialYao) {
      return _generateHoutianGuaForZhiZunGua(
        xiantianGua,
        yuantangYaoIndex,
        birthMonth,
      );
    }

    // 原有通用逻辑: 爻变 + 上下卦互换
    // 将卦转换为二进制列表
    final binaryList = gua_utils.guaToBinaryList(xiantianGua);

    // 转换索引：zhiList使用从下到上的索引(0=初爻,5=上爻)
    // 而binaryList使用从上到下的索引(0=上卦第1爻,5=下卦第3爻)
    // 转换公式：binaryIndex = 5 - zhiListIndex
    final binaryIndex = 5 - yuantangYaoIndex;

    // 元堂爻爻变（阴转阳，阳转阴）
    binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

    // 拆分成两个卦
    final oldUpon = binaryList.sublist(0, 3).join();
    final oldUnder = binaryList.sublist(3).join();

    // 根据二进制找到八经卦
    final oldUponGua = constants.binaryStrGuaMapper[oldUpon]!;
    final oldUnderGua = constants.binaryStrGuaMapper[oldUnder]!;

    // 上下卦互换
    final houtianGua = oldUnderGua + oldUponGua;

    // 查询后天数
    final houtianUpperGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[0]]!;
    final houtianLowerGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[1]]!;

    return (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
  }

  /// 至尊卦专用后天卦生成
  ///
  /// 参数：
  /// - [xiantianGua]: 先天卦（坎坎/坎震/坎艮）
  /// - [yuantangYaoIndex]: 元堂爻索引（4=九五，5=上六）
  /// - [birthMonth]: 出生月份(1-12)
  ///
  /// 返回: (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber)
  ///
  /// 规则：
  /// - 九五爻(4): 阴月不换，阳月互换
  /// - 上六爻(5): 阴月互换，阳月不换
  /// - 阳月: 1,3,5,7,9,11
  /// - 阴月: 2,4,6,8,10,12
  static (String, int, int) _generateHoutianGuaForZhiZunGua(
    String xiantianGua,
    int yuantangYaoIndex,
    int birthMonth,
  ) {
    // 判断月份阴阳
    final isYangMonth = [1, 3, 5, 7, 9, 11].contains(birthMonth);

    // 爻变
    final binaryList = gua_utils.guaToBinaryList(xiantianGua);
    final binaryIndex = 5 - yuantangYaoIndex;
    binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

    final oldUpon = binaryList.sublist(0, 3).join();
    final oldUnder = binaryList.sublist(3).join();
    final oldUponGua = constants.binaryStrGuaMapper[oldUpon]!;
    final oldUnderGua = constants.binaryStrGuaMapper[oldUnder]!;

    // 根据爻位和月份决定是否互换
    String houtianGua;

    if (yuantangYaoIndex == 4) {
      // 九五爻: 阴月不换, 阳月互换
      if (isYangMonth) {
        houtianGua = oldUnderGua + oldUponGua; // 互换
      } else {
        houtianGua = oldUponGua + oldUnderGua; // 不互换
      }
    } else {
      // 上六爻: 阴月互换, 阳月不换
      if (isYangMonth) {
        houtianGua = oldUponGua + oldUnderGua; // 不互换
      } else {
        houtianGua = oldUnderGua + oldUponGua; // 互换
      }
    }

    final houtianUpperGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[0]]!;
    final houtianLowerGuaNumber =
        constants.houTianGuaNumberMapper[houtianGua[1]]!;

    return (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
  }

  /// 后天卦元堂装卦
  ///
  /// 参数：
  /// - [eightChars]: 四柱信息
  /// - [houtianGua]: 后天卦
  /// - [gender]: 性别（"男" / "女"）
  /// - [birthAfterZhi]: 出生节气后（"夏至" / "冬至"）
  ///
  /// 返回: (houtianYuantangYaoIndex, houtianYuantangYaoLabel, houtianZhiList)
  ///
  /// 规则：与先天卦相同，根据时辰阴阳和后天卦的阴阳爻数装配地支
  static (
    int, // houtianYuantangYaoIndex
    String, // houtianYuantangYaoLabel
    List<List<String>>, // houtianZhiList
  )
  houtianYuantangZhuanggua({
    required EightChars eightChars,
    required String houtianGua,
    required String gender,
    required String birthAfterZhi,
  }) {
    final timeGanzhi = eightChars.time.name;

    // 判断时辰阴阳（与先天卦相同）
    const yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
    const yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];

    final timeZhi = timeGanzhi.substring(timeGanzhi.length - 1);
    final timeYinYang = yuantangYangTimeSet.contains(timeZhi) ? "阳" : "阴";

    // 将后天卦转换为二进制列表
    final upperBinary = constants.guaBinaryMapper[houtianGua[0]]!;
    final lowerBinary = constants.guaBinaryMapper[houtianGua[1]]!;
    final allGuaBinary = [...upperBinary, ...lowerBinary];

    // 计算阳爻和阴爻数量
    final totalYangYao = allGuaBinary.where((x) => x == 1).length;
    final totalYinYao = allGuaBinary.where((x) => x == 0).length;

    // 根据时辰阴阳和爻数分类处理（复用现有装卦方法）
    List<List<String>> zhiList;
    if (timeYinYang == "阳") {
      // 阳时取阳爻
      if (totalYangYao > 0 && totalYangYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          totalYangYao,
          true,
        );
      } else if (totalYangYao >= 4 && totalYangYao <= 5) {
        zhiList = _zhuanggua45(
          allGuaBinary,
          List.from(yuantangYangTimeSet),
          totalYangYao,
          true,
        );
      } else {
        zhiList = _zhuanggua6Yang(
          totalYangYao == 6,
          List.from(yuantangYangTimeSet),
          true,
          gender,
          birthAfterZhi,
        );
      }
    } else {
      // 阴时取阴爻
      if (totalYinYao > 0 && totalYinYao <= 3) {
        zhiList = _zhuangguaLowerThan3(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          totalYinYao,
          false,
        );
      } else if (totalYinYao >= 4 && totalYinYao <= 5) {
        zhiList = _zhuanggua45(
          allGuaBinary,
          List.from(yuantangYinTimeSet),
          totalYinYao,
          false,
        );
      } else {
        zhiList = _zhuanggua6Yang(
          totalYinYao == 0,
          List.from(yuantangYinTimeSet),
          false,
          gender,
          birthAfterZhi,
        );
      }
    }

    // 获取后天卦元堂爻索引
    final houtianYuantangYaoIndex = _getYuantangYaoIndex(timeGanzhi, zhiList);

    // 获取后天卦元堂爻位标签
    final houtianYuantangYaoLabel = _getYaoPositionLabel(
      houtianYuantangYaoIndex,
    );

    return (houtianYuantangYaoIndex, houtianYuantangYaoLabel, zhiList);
  }

  // ========== 私有辅助方法 ==========

  /// 元堂装卦 - 爻数小于3的情况（双重装配）
  static List<List<String>> _zhuangguaLowerThan3(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    final yinyangZhiList = List<String>.from(timeZhiList);
    final doubleZhi4Yang = yinyangZhiList.sublist(0, 2 * totalYao);
    final totalDoubleZhi = doubleZhi4Yang.length;
    final leftZhiList = yinyangZhiList.sublist(2 * totalYao);

    final zhiList = List.generate(6, (_) => <String>[]);
    var tmpBinaryList = List<int>.from(guaBinaryList);
    tmpBinaryList = tmpBinaryList.reversed.toList();

    var doubleZhiIndex = 0;

    for (var i = 0; i < totalDoubleZhi; i++) {
      for (var j = 0; j < 6; j++) {
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

    final resultList = <List<String>>[];
    var leftIndex = 0;

    for (var i = 0; i < 6; i++) {
      if (zhiList[i].isEmpty && leftIndex < leftZhiList.length) {
        resultList.add([leftZhiList[leftIndex++]]);
      } else {
        resultList.add(zhiList[i]);
      }
    }

    return resultList;
  }

  /// 元堂装卦 - 4-5爻（自上而下排列）
  static List<List<String>> _zhuanggua45(
    List<int> guaBinaryList,
    List<String> timeZhiList,
    int totalYao,
    bool isYang,
  ) {
    final tmpTimeList = List<String>.from(timeZhiList);
    final firstFourZhi = tmpTimeList.sublist(0, totalYao);
    final leftZhiList = tmpTimeList.sublist(totalYao);
    var tmpBinList = List<int>.from(guaBinaryList);
    tmpBinList = tmpBinList.reversed.toList();
    final resultList = <List<String>>[];

    var firstIndex = 0;
    var leftIndex = 0;

    for (var i = 0; i < tmpBinList.length; i++) {
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

    return resultList;
  }

  /// 元堂装卦 - 6爻全阳或全阴（三爻分组）
  static List<List<String>> _zhuanggua6Yang(
    bool isSixYang,
    List<String> timeZhiList,
    bool isYang,
    String gender,
    String birthAfterZhi,
  ) {
    // 三爻装配辅助函数
    List<List<String>> threeYaoZhuang(List<String> dizhiList, bool isUp2Down) {
      final tmpDizhiList = List<String>.from(dizhiList);
      final result = <List<String>>[[], [], []];
      for (var i = 0; i < dizhiList.length; i++) {
        if (tmpDizhiList.isEmpty) {
          break;
        }
        for (var j = 0; j < 3; j++) {
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
        final tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [<String>[], <String>[], <String>[], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, <String>[], <String>[], <String>[]];
        }
      } else {
        // gender == "女"
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [
              <String>[],
              <String>[],
              <String>[],
              ...threeYaoZhuang(timeZhiList, false),
            ];
          } else {
            // 冬至后出生 上卦自上而下
            return [
              ...threeYaoZhuang(timeZhiList, true),
              <String>[],
              <String>[],
              <String>[],
            ];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 上卦自下而上
            return [
              ...threeYaoZhuang(timeZhiList, false),
              <String>[],
              <String>[],
              <String>[],
            ];
          } else {
            // 冬至后出生 下卦自上而下
            return [
              <String>[],
              <String>[],
              <String>[],
              ...threeYaoZhuang(timeZhiList, true),
            ];
          }
        }
      }
    } else {
      // 六阴爻
      if (gender == "女") {
        final tmpResultList = threeYaoZhuang(timeZhiList, false);
        if (isYang) {
          // 阳时出生 - 下卦自下而上
          return [<String>[], <String>[], <String>[], ...tmpResultList];
        } else {
          // 阴时出生 - 上卦自下而上
          return [...tmpResultList, <String>[], <String>[], <String>[]];
        }
      } else {
        if (isYang) {
          // 阳时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 下卦自下而上
            return [
              <String>[],
              <String>[],
              <String>[],
              ...threeYaoZhuang(timeZhiList, false),
            ];
          } else {
            // 冬至后出生 上卦自上而下
            return [
              ...threeYaoZhuang(timeZhiList, true),
              <String>[],
              <String>[],
              <String>[],
            ];
          }
        } else {
          // 阴时生
          if (birthAfterZhi == "夏至") {
            // 夏至后出生 上卦自下而上
            return [
              ...threeYaoZhuang(timeZhiList, false),
              <String>[],
              <String>[],
              <String>[],
            ];
          } else {
            // 冬至后出生 下卦自上而下
            return [
              <String>[],
              <String>[],
              <String>[],
              ...threeYaoZhuang(timeZhiList, true),
            ];
          }
        }
      }
    }
  }

  /// 获取元堂爻索引
  static int _getYuantangYaoIndex(
    String timeZhi,
    List<List<String>> yangTangYaoZhiList,
  ) {
    var resultYuantangYaoIndex = -1;
    for (var i = 0; i < yangTangYaoZhiList.length; i++) {
      if (yangTangYaoZhiList[i].contains(
        timeZhi.substring(timeZhi.length - 1),
      )) {
        resultYuantangYaoIndex = i;
        break;
      }
    }
    return resultYuantangYaoIndex;
  }

  /// 获取爻位标签
  static String _getYaoPositionLabel(int index) {
    switch (index) {
      case 0:
        return '初';
      case 1:
        return '二';
      case 2:
        return '三';
      case 3:
        return '四';
      case 4:
        return '五';
      case 5:
        return '上';
      default:
        return '未知';
    }
  }
}
