// utils.dart
// 导入包含所有静态数据映射的常量文件
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/pure_yuan_tang_gua.dart';

import '../../constant/constants.dart' as constants;

// ===================================================================
// 核心卦象变换函数 (Core Hexagram Transformation Functions)
// ===================================================================

/// 将双经卦名（如 "乾坤"）转换为6个元素的二进制列表（从上爻到下爻）。
List<int> guaToBinaryList(Enum64Gua guaName) {
  // 合并上卦和下卦的二进制列表
  return PureSixYaoGua.by8Gua(
    guaName.top,
    guaName.bottom,
  ).topBotYaoBinStr.split("").map((e) => int.parse(e)).toList();
}

/// 将6个元素的二进制列表转换为双经卦名（如 "离兑"）。
String binaryListToGua(List<int> binaryList) {
  if (binaryList.length != 6) {
    throw ArgumentError("二进制列表必须包含6个元素");
  }
  final uponBinaryStr = binaryList.sublist(0, 3).join('');
  final underBinaryStr = binaryList.sublist(3, 6).join('');

  final uponGua = constants.binaryStrGuaMapper[uponBinaryStr];
  final underGua = constants.binaryStrGuaMapper[underBinaryStr];

  if (uponGua == null || underGua == null) {
    throw ArgumentError("无效的二进制序列");
  }

  return uponGua + underGua;
}

/// 对给定的二进制卦象列表进行爻变。
/// [originalBinaryList]: 原始卦的二进制列表 (6个元素, 从上到下)。
/// [bianYaoIndices]: 需要变化的爻位索引列表 (0-5, 0是上爻)。
List<int> yaoBianGua(List<int> originalBinaryList, List<int> bianYaoIndices) {
  final newList = List<int>.from(originalBinaryList);
  for (final index in bianYaoIndices) {
    if (index >= 0 && index < 6) {
      // 阴阳互换 (0 -> 1, 1 -> 0)
      if (newList[index] == 0) {
        newList[index] = 1;
      } else {
        newList[index] = 0;
      }
    }
  }
  return newList;
}

/// 计算给定卦的“互卦”。
Enum64Gua guaToHuGua(Enum64Gua guaName) {
  return PureSixYaoGua.by8Gua(guaName.top, guaName.bottom).hu;
}

/// 计算给定卦的“错卦”（所有爻阴阳相反）。
Enum64Gua guaToCuoGua(Enum64Gua guaName) {
  return PureSixYaoGua.by8Gua(guaName.top, guaName.bottom).cuo;
}

// ===================================================================
// 基础装卦与查询函数 (Basic Installation & Lookup Functions)
// ===================================================================

/// 根据双经卦名使用爻序法进行装卦，安装"地支"。
///
/// 爻序法规则：
/// - 阳爻依次配：子、寅、辰、午、申、戌
/// - 阴爻依次配：丑、卯、巳、未、酉、亥
///
/// 返回一个从上爻到初爻的6元素地支列表。
List<String> yaoxuZhuangGua(Enum64Gua guaName) {
  // 阳爻地支序列
  final yangDiZhi = ['子', '寅', '辰', '午', '申', '戌'];

  // 阴爻地支序列
  final yinDiZhi = ['丑', '卯', '巳', '未', '酉', '亥'];

  // 将卦转换为二进制列表（从上爻到下爻）
  final binaryList = guaToBinaryList(guaName);

  int yangIndex = 0;
  int yinIndex = 0;
  final result = <String>[];

  // 从上爻到下爻装配地支（索引0是上爻，索引5是初爻）
  for (int i = 0; i < 6; i++) {
    if (binaryList[i] == 1) {
      // 阳爻
      result.add(yangDiZhi[yangIndex % yangDiZhi.length]);
      yangIndex++;
    } else {
      // 阴爻
      result.add(yinDiZhi[yinIndex % yinDiZhi.length]);
      yinIndex++;
    }
  }

  return result;
}

/// 根据双经卦名进行纳甲，安装"地支"。
/// 返回一个从上爻到初爻的6元素地支列表。
List<String> najiaZhuangGua(Enum64Gua guaName) {
  // 上卦地支映射表
  final Map<String, String> uponGuaMapper = {
    "乾": "戌申午",
    "兑": "未酉亥",
    "离": "巳未酉",
    "震": "戌申午",
    "巽": "卯巳未",
    "坎": "子戌申",
    "艮": "寅子戌",
    "坤": "酉亥丑",
  };

  // 下卦地支映射表
  final Map<String, String> underGuaMapper = {
    "乾": "辰寅子",
    "兑": "丑卯巳",
    "离": "亥丑卯",
    "震": "辰寅子",
    "巽": "酉亥丑",
    "坎": "午辰寅",
    "艮": "申午辰",
    "坤": "卯巳未",
  };

  final uponGua = guaName.top.name;
  final underGua = guaName.bottom.name;

  // 将上卦和下卦的地支字符串合并成一个数组，从上爻到下爻
  final uponZhi = uponGuaMapper[uponGua]!.split('');
  final underZhi = underGuaMapper[underGua]!.split('');

  return [...uponZhi, ...underZhi];
}

/// 根据双经卦名进行纳甲，安装“天干”。
/// 返回一个从上爻到初爻的6元素天干列表。
List<String> najiaGanZhuangGua(Enum64Gua guaName) {
  // 上卦天干映射表
  final Map<String, List<String>> uponGuaMapper = {
    "乾": ["壬", "壬", "壬"],
    "兑": ["丁", "丁", "丁"],
    "离": ["己", "己", "己"],
    "震": ["庚", "庚", "庚"],
    "巽": ["辛", "辛", "辛"],
    "坎": ["戊", "戊", "戊"],
    "艮": ["丙", "丙", "丙"],
    "坤": ["癸", "癸", "癸"],
  };

  // 下卦天干映射表
  final Map<String, List<String>> underGuaMapper = {
    "乾": ["甲", "甲", "甲"],
    "兑": ["丁", "丁", "丁"],
    "离": ["己", "己", "己"],
    "震": ["庚", "庚", "庚"],
    "巽": ["辛", "辛", "辛"],
    "坎": ["戊", "戊", "戊"],
    "艮": ["丙", "丙", "丙"],
    "坤": ["乙", "乙", "乙"],
  };

  final uponGua = guaName.top.name;
  final underGua = guaName.bottom.name;

  // 将上卦和下卦的天干合并成一个数组，从上爻到下爻
  final uponGan = uponGuaMapper[uponGua]!;
  final underGan = underGuaMapper[underGua]!;

  return [...uponGan, ...underGan];
}

/// 根据64卦名找到它所属的“宫”。
String getGuagongByBenname(String benGuaName) {
  for (final entry in constants.guaNameEightGongMapper.entries) {
    if (entry.value.contains(benGuaName)) {
      return entry.key;
    }
  }
  throw ArgumentError("找不到卦名 $benGuaName 对应的宫");
}

// ===================================================================
// 数值计算工具函数 (Numeric Calculation Utilities)
// ===================================================================

/// 根据基数、次数和因子，生成一个等差数列。
/// 可以选择是否包含减法部分。
List<int> calculateTaoWenListByFactor({
  required int baseNumber,
  required int times,
  int factor = 96,
  bool includeSubtractions = true,
  bool includeBase = true,
}) {
  final List<int> addList = [];
  final List<int> subList = [];

  int addCounter = baseNumber;
  for (int i = 0; i < times; i++) {
    addCounter += factor;
    addList.add(addCounter);
  }

  if (includeSubtractions) {
    int subCounter = baseNumber;
    for (int i = 0; i < times; i++) {
      subCounter -= factor;
      subList.add(subCounter);
    }
  }

  final result = [...subList, if (includeBase) baseNumber, ...addList];
  result.sort();
  return result;
}

/// 根据基数、一个乘数列表和因子，生成一个数列。
/// 结果为 `baseNumber ± factor * multiple`。
List<int> calculateTaoWenListByMultiples({
  required int baseNumber,
  required List<int> multiples,
  int factor = 48,
  bool includeSubtractions = true,
  bool includeBase = false,
}) {
  final List<int> addList = multiples
      .map((m) => baseNumber + factor * m)
      .toList();
  final List<int> subList = [];

  if (includeSubtractions) {
    subList.addAll(multiples.map((m) => baseNumber - factor * m));
  }

  final result = [...subList, if (includeBase) baseNumber, ...addList];
  result.sort();
  return result;
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

/// 六爻装订六亲
///
/// 1. doubleEightGuaName 卦所在的八宫卦，并根据八宫卦五行确定 "己身"的五行属性
/// 2. 根据yaoGanzhiList中地支的五行属性，与己身"确定"六亲
///
/// 参数:
///   [doubleEightGuaName] 如："乾乾"，"坎坤"等
///   [yaoGanzhiList] 干支列表 共6个，从上爻到下爻
///
/// 返回:
///   `List<String>` 如：["官鬼","子孙".....] 从上爻到下爻
List<String> liuqinZhuanggua(
  String doubleEightGuaName,
  List<String> yaoGanzhiList,
) {
  // 1.1. 根据 guaName 获取 卦的object名
  final String uponGuaObjectName =
      constants.guaName2ObjectName[doubleEightGuaName[0]]!;
  final String underGuaObjectName = constants
      .guaName2ObjectName[doubleEightGuaName[doubleEightGuaName.length - 1]]!;

  // 1.2. 根据 object名获取卦本名 如："遁"，"履" 等
  final String guaBenMing = constants
      .objectName2GuaNameMapper[uponGuaObjectName + underGuaObjectName]!;

  // 1.3. 根据卦的本命 找到其所在卦宫
  final String gongGua = getGuagongByBenname(guaBenMing);

  // 1.4. 确定 "己身"五行
  final String fivexingSelf = constants.guaFivexingMapper[gongGua]!;

  // 2. 根据 每一爻地支 与 "己身" 五行排六亲
  final List<String> resultSixqingList = [];
  final Map<String, String> mapper4Self =
      constants.fivexingLiuqingMapper[fivexingSelf]!;

  for (int i = 0; i < yaoGanzhiList.length; i++) {
    final String gz = yaoGanzhiList[i];
    final String z = gz[gz.length - 1]; // dizhi
    final String otherFivexing = constants.dizhiFivexingMapper[z]!; // 地支五行
    resultSixqingList.add(mapper4Self[otherFivexing]!);
  }

  return resultSixqingList;
}

/// 根据卦名获得八宫信息
///
/// 参数:
///   [singleGuaName] 单个卦名
///
/// 返回:
///   String 八宫信息
String getEightOrderByGuaname(String singleGuaName) {
  // 遍历所有宫
  for (final String gong in constants.guaNameEightGongMapper.keys) {
    try {
      // 查找卦名在当前宫中的位置
      final List<String> guaList = constants.guaNameEightGongMapper[gong]!;
      final int index = guaList.indexOf(singleGuaName);

      if (index != -1) {
        return constants.gongGuaName[index];
      }
    } catch (e) {
      // 继续下一个宫的查找
      continue;
    }
  }

  // 如果在八宫中没有找到，直接返回映射结果
  throw Exception('「$singleGuaName」未找到该卦名在八宫的位置');
}

String getPureGuaNameByObject(String gua1, String gua2) {
  final String combinedKey = gua1 + gua2;
  return constants.objectName2GuaNameMapper[combinedKey]!;
}

/// 将number转换为卦，千百位为上卦，十个位为下卦，两数分别相加，取"8"的余数，
/// 使用后天序数取卦
///
/// [number] 被转换的数字
/// [shouldReverse] 是否需要反转上下卦，默认为false
///
/// Returns: 如"乾坤"之类
String digit4NumberToHouGua(int number, {bool shouldReverse = false}) {
  final String numStr = number.toString();

  // 千百位相加取余8
  int first = (int.parse(numStr[0]) + int.parse(numStr[1])) % 8;
  if (first == 0) {
    first = 8;
  }

  // 十个位相加取余8
  int second = (int.parse(numStr[2]) + int.parse(numStr[3])) % 8;
  if (second == 0) {
    second = 8;
  }

  String firstGua = constants.houTianNumberGuaMapper[first]!;
  String secondGua = constants.houTianNumberGuaMapper[second]!;

  if (shouldReverse) {
    final String temp = firstGua;
    firstGua = secondGua;
    secondGua = temp;
  }

  return firstGua + secondGua;
}

// ===================================================================
// 先后天卦生成函数 (XianHoutian Gua Generation Functions)
// ===================================================================

/// 生成天地卦（从元堂卦逻辑提取）
///
/// 根据四柱天干地支计算天地卦，支持三元五宫映射
///
/// 参数：
/// - [yearGan]: 年柱天干
/// - [monthGan]: 月柱天干
/// - [dayGan]: 日柱天干
/// - [timeGan]: 时柱天干
/// - [yearZhi]: 年柱地支
/// - [monthZhi]: 月柱地支
/// - [dayZhi]: 日柱地支
/// - [timeZhi]: 时柱地支
/// - [yearYinYang]: 年份阴阳（"阳" / "阴"）
/// - [gender]: 性别（"男" / "女"）
/// - [threeYuan]: 三元（"上" / "中" / "下"）
///
/// 返回：(tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
///        tianGuaNum, diGuaNum, usedThreeYuanWuGong)
///
/// 算法步骤：
/// 1. 提取四柱天干数列表和地支数列表
/// 2. 计算奇数总和（天干奇数 + 地支奇数）
/// 3. 计算偶数总和（天干偶数 + 地支偶数）
/// 4. 天数 = 奇数总和 模25，特殊处理=25时为5
/// 5. 地数 = 偶数总和 模30，特殊处理=30时为3
/// 6. 当天数或地数为5时，查询三元五宫映射表
/// 7. 否则使用常规数配卦
@Deprecated("using calculateXianTianGua instead")
(
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
  required String yearGan,
  required String monthGan,
  required String dayGan,
  required String timeGan,
  required String yearZhi,
  required String monthZhi,
  required String dayZhi,
  required String timeZhi,
  required String yearYinYang,
  required String gender,
  required String threeYuan,
}) {
  // 三元五宫映射表（当天数或地数为5时使用）
  const threeYuan5GongMapper = {
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

  // 提取四柱天干数列表
  final ganNumList = [
    constants.tianGanNumberMapper[yearGan]!,
    constants.tianGanNumberMapper[monthGan]!,
    constants.tianGanNumberMapper[dayGan]!,
    constants.tianGanNumberMapper[timeGan]!,
  ];

  // 提取四柱地支数列表（每个地支两个数）
  final zhiNumList = [
    constants.diZhiNumberMapper[yearZhi]!,
    constants.diZhiNumberMapper[monthZhi]!,
    constants.diZhiNumberMapper[dayZhi]!,
    constants.diZhiNumberMapper[timeZhi]!,
  ];

  // 展开地支数列表用于计算奇偶和
  final zhiNumTotalList = [
    ...constants.diZhiNumberMapper[yearZhi]!,
    ...constants.diZhiNumberMapper[monthZhi]!,
    ...constants.diZhiNumberMapper[dayZhi]!,
    ...constants.diZhiNumberMapper[timeZhi]!,
  ];

  // 计算奇数和、偶数和
  final oddNumTotal =
      (ganNumList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b) +
      zhiNumTotalList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b));

  final evenNumTotal =
      (ganNumList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b) +
      zhiNumTotalList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b));

  // 计算天数（奇数和 模25）
  final tianGuaNum = calculateGuaNum(oddNumTotal, 25, 5);

  // 计算地数（偶数和 模30）
  final diGuaNum = calculateGuaNum(evenNumTotal, 30, 3);

  // 数配卦
  String tianGua;
  String diGua;
  bool usedThreeYuanWuGong = false;

  // 天卦配卦（天数为5时查询三元五宫）
  if (tianGuaNum == 5) {
    tianGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    usedThreeYuanWuGong = true;
  } else {
    tianGua = constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
  }

  // 地卦配卦（地数为5时查询三元五宫）
  if (diGuaNum == 5) {
    diGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    usedThreeYuanWuGong = true;
  } else {
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

/// 生成天地卦（使用太玄数映射，专用于前后卦取数法）
///
/// 与generateTianDiGua的唯一区别是使用太玄数映射（taixuanGanNumberMapper和taixuanZhiNumberMapper）
/// 而不是传统的天干地支数映射（tianGanNumberMapper和diZhiNumberMapper）
///
/// 参数：与generateTianDiGua相同
///
/// 返回：(tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
///        tianGuaNum, diGuaNum, usedThreeYuanWuGong)
///
/// 算法步骤：与generateTianDiGua相同，但使用太玄数配数体系
(
  String, // tianGua
  String, // diGua
  List<int>, // ganNumList
  List<int>, // zhiNumList (太玄数为单个数字，不是[奇,偶]对)
  int, // oddNumTotal
  int, // evenNumTotal
  int, // tianGuaNum
  int, // diGuaNum
  bool, // usedThreeYuanWuGong
)
generateTianDiGuaWithTaixuan({
  required String yearGan,
  required String monthGan,
  required String dayGan,
  required String timeGan,
  required String yearZhi,
  required String monthZhi,
  required String dayZhi,
  required String timeZhi,
  required String yearYinYang,
  required String gender,
  required String threeYuan,
}) {
  // 三元五宫映射表（当天数或地数为5时使用）
  const threeYuan5GongMapper = {
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

  // 使用太玄数映射提取四柱天干数列表
  final ganNumList = [
    constants.taixuanGanNumberMapper[yearGan]!,
    constants.taixuanGanNumberMapper[monthGan]!,
    constants.taixuanGanNumberMapper[dayGan]!,
    constants.taixuanGanNumberMapper[timeGan]!,
  ];

  // 使用太玄数映射提取四柱地支数列表（太玄数为单个数字）
  final zhiNumList = [
    constants.taixuanZhiNumberMapper[yearZhi]!,
    constants.taixuanZhiNumberMapper[monthZhi]!,
    constants.taixuanZhiNumberMapper[dayZhi]!,
    constants.taixuanZhiNumberMapper[timeZhi]!,
  ];

  // 展开地支数列表用于计算奇偶和
  final zhiNumTotalList = zhiNumList; // 太玄数为单个数字，直接使用

  // 计算奇数和、偶数和
  final oddNumTotal =
      (ganNumList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b) +
      zhiNumTotalList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b));

  final evenNumTotal =
      (ganNumList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b) +
      zhiNumTotalList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b));

  // 计算天数（奇数和 模25）
  final tianGuaNum = calculateGuaNum(oddNumTotal, 25, 5);

  // 计算地数（偶数和 模30）
  final diGuaNum = calculateGuaNum(evenNumTotal, 30, 3);

  // 数配卦
  String tianGua;
  String diGua;
  bool usedThreeYuanWuGong = false;

  // 天卦配卦（天数为5时查询三元五宫）
  if (tianGuaNum == 5) {
    tianGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    usedThreeYuanWuGong = true;
  } else {
    tianGua = constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
  }

  // 地卦配卦（地数为5时查询三元五宫）
  if (diGuaNum == 5) {
    diGua = threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
    usedThreeYuanWuGong = true;
  } else {
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

/// 生成先后天卦（从元堂卦逻辑提取）
///
/// 根据天地卦、年份阴阳和性别，生成先天卦和后天卦（不包含元堂爻变）
///
/// 参数：
/// - [tianGua]: 天卦名称
/// - [diGua]: 地卦名称
/// - [yearYinYang]: 年份阴阳（"阳" / "阴"）
/// - [gender]: 性别（"男" / "女"）
///
/// 返回：(xiantianGua, upperGua, lowerGua, xiantianUpperGuaNumber, xiantianLowerGuaNumber)
///
/// 算法规则：
/// - 阳年男性：天卦在上，地卦在下
/// - 阳年女性：地卦在上，天卦在下
/// - 阴年女性：天卦在上，地卦在下
/// - 阴年男性：地卦在上，天卦在下
///
/// 注意：此方法只生成先天卦，不包含后天卦的元堂爻变和互换逻辑
(
  String, // xiantianGua
  String, // upperGua
  String, // lowerGua
  int, // xiantianUpperGuaNumber
  int, // xiantianLowerGuaNumber
)
generateXiantianGua({
  required String tianGua,
  required String diGua,
  required String yearYinYang,
  required String gender,
}) {
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
    xiantianGua,
    upperGua,
    lowerGua,
    xiantianUpperGuaNumber,
    xiantianLowerGuaNumber,
  );
}
