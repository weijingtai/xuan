// utils.dart
// 导入包含所有静态数据映射的常量文件
import '../../constant/constants.dart' as constants;
import '../constant/constants.dart' as Constants;

// ===================================================================
// 核心卦象变换函数 (Core Hexagram Transformation Functions)
// ===================================================================

/// 将双经卦名（如 "乾坤"）转换为6个元素的二进制列表（从上爻到下爻）。
List<int> guaToBinaryList(String guaName) {
  if (guaName.length != 2) {
    throw ArgumentError("卦名必须是两个字符，例如 '乾坤'");
  }
  final uponGua = guaName.substring(0, 1);
  final underGua = guaName.substring(1, 2);

  final uponBinary = constants.guaBinaryMapper[uponGua];
  final underBinary = constants.guaBinaryMapper[underGua];

  if (uponBinary == null || underBinary == null) {
    throw ArgumentError("无效的卦名: $guaName");
  }

  // 合并上卦和下卦的二进制列表
  return [...uponBinary, ...underBinary];
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
String guaToHuGua(String guaName) {
  final binaryList = guaToBinaryList(guaName);

  // 互卦由2,3,4爻（上互）和3,4,5爻（下互）组成
  final huUponBinary = binaryList.sublist(1, 4);
  final huUnderBinary = binaryList.sublist(2, 5);

  return binaryListToGua([...huUponBinary, ...huUnderBinary]);
}

/// 计算给定卦的“错卦”（所有爻阴阳相反）。
String guaToCuoGua(String guaName) {
  final binaryList = guaToBinaryList(guaName);
  final cuoBinaryList = binaryList.map((yao) => 1 - yao).toList();
  return binaryListToGua(cuoBinaryList);
}

// ===================================================================
// 基础装卦与查询函数 (Basic Installation & Lookup Functions)
// ===================================================================

/// 根据双经卦名进行纳甲，安装“地支”。
/// 返回一个从上爻到初爻的6元素地支列表。
List<String> najiaZhuangGua(String guaName) {
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

  final uponGua = guaName.substring(0, 1);
  final underGua = guaName.substring(1, 2);

  // 将上卦和下卦的地支字符串合并成一个数组，从上爻到下爻
  final uponZhi = uponGuaMapper[uponGua]!.split('');
  final underZhi = underGuaMapper[underGua]!.split('');

  return [...uponZhi, ...underZhi];
}

/// 根据双经卦名进行纳甲，安装“天干”。
/// 返回一个从上爻到初爻的6元素天干列表。
List<String> najiaGanZhuangGua(String guaName) {
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

  final uponGua = guaName.substring(0, 1);
  final underGua = guaName.substring(1, 2);

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

  // <25或<30时，以及>25或>30的余数，不用十位 (即取个位)
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
///   List<String> 如：["官鬼","子孙".....] 从上爻到下爻
List<String> liuqinZhuanggua(
  String doubleEightGuaName,
  List<String> yaoGanzhiList,
) {
  // 1.1. 根据 guaName 获取 卦的object名
  final String uponGuaObjectName =
      Constants.guaName2ObjectName[doubleEightGuaName[0]]!;
  final String underGuaObjectName = Constants
      .guaName2ObjectName[doubleEightGuaName[doubleEightGuaName.length - 1]]!;

  // 1.2. 根据 object名获取卦本名 如："遁"，"履" 等
  final String guaBenMing = Constants
      .objectName2GuaNameMapper[uponGuaObjectName + underGuaObjectName]!;

  // 1.3. 根据卦的本命 找到其所在卦宫
  final String gongGua = getGuagongByBenname(guaBenMing);

  // 1.4. 确定 "己身"五行
  final String fivexingSelf = Constants.guaFivexingMapper[gongGua]!;

  // 2. 根据 每一爻地支 与 "己身" 五行排六亲
  final List<String> resultSixqingList = [];
  final Map<String, String> mapper4Self =
      Constants.fivexingLiuqingMapper[fivexingSelf]!;

  for (int i = 0; i < yaoGanzhiList.length; i++) {
    final String gz = yaoGanzhiList[i];
    final String z = gz[gz.length - 1]; // dizhi
    final String otherFivexing = Constants.dizhiFivexingMapper[z]!; // 地支五行
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
  for (final String gong in Constants.guaNameEightGongMapper.keys) {
    try {
      // 查找卦名在当前宫中的位置
      final List<String> guaList = Constants.guaNameEightGongMapper[gong]!;
      final int index = guaList.indexOf(singleGuaName);

      if (index != -1) {
        return Constants.gongGuaName[index];
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
  return Constants.objectName2GuaNameMapper[combinedKey]!;
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

  String firstGua = Constants.houTianNumberGuaMapper[first]!;
  String secondGua = Constants.houTianNumberGuaMapper[second]!;

  if (shouldReverse) {
    final String temp = firstGua;
    firstGua = secondGua;
    secondGua = temp;
  }

  return firstGua + secondGua;
}
