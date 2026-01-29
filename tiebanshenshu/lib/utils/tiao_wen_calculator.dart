import 'package:common/enums.dart';

import '../features/six_yao_gua/pure_six_yao_gua.dart';
import 'utils.dart' as GuaUtils;

import '../constant/constants.dart' as NumberMaps;

@Deprecated("使用TiaoWenCalculator")
class TiaowenCalculator {
  /// 加则法计算条文数字（使用爻序法）
  ///
  /// 1. 加则法，将每爻配上地支，再累加计算地支对应的数字。
  /// 2. 上卦后天数*1000 + 累加基数 - 下卦后天数
  /// 3. 使用爻序法：阳爻依次配子寅辰午申戌，阴爻依次配丑卯巳未酉亥
  ///
  /// [guaName] 基本卦的名称 如 "坤艮" 之类
  /// 返回计算结果
  static int getTiaowenNumberByJiaZe(Enum64Gua guaName) {
    // 将卦转换为二进制列表
    List<int> binaryGua = GuaUtils.guaToBinaryList(guaName);

    // 使用爻序法将地支装到卦上
    List<String> zhiTopToBottom = GuaUtils.yaoxuZhuangGua(guaName);

    // 计算卦的总数
    int guaTotalNumber = 0;
    for (int i = 0; i < binaryGua.length; i++) {
      guaTotalNumber += NumberMaps.dizhiNumberMapper[zhiTopToBottom[i]]!;
    }

    // 计算条文
    int tiaowenBaseNumber = calculateTiaowen(
      guaName.top,
      guaName.bottom,
      guaTotalNumber,
    );

    return tiaowenBaseNumber;
  }

  /// 纳甲法计算条文数字
  ///
  /// 1. 纳甲法，将每爻配上地支，再累加计算地支对应的数字。
  /// 2. 上卦后天数*1000 + 累加基数 - 下卦后天数
  ///
  /// [guaName] 基本卦的名称 如 "坤艮" 之类
  /// 返回计算结果
  static int getTiaoWenNumberByNaJia(Enum64Gua guaName) {
    // 将卦转换为二进制列表
    List<int> binaryGua = GuaUtils.guaToBinaryList(guaName);

    // 将地支装到卦上（纳甲方式）
    List<String> zhiTopToBottom = GuaUtils.najiaZhuangGua(guaName);

    // 计算卦的总数
    int guaTotalNumber = 0;
    for (int i = 0; i < binaryGua.length; i++) {
      guaTotalNumber += NumberMaps.dizhiNumberMapper[zhiTopToBottom[i]]!;
    }

    // 计算条文
    int tiaowenBaseNumber = calculateTiaowen(
      guaName.top,
      guaName.bottom,
      guaTotalNumber,
    );

    return tiaowenBaseNumber;
  }

  /// 太玄数法计算条文数字
  ///
  /// 根据给定干支，使用纳甲方式装卦算出条后，用每一爻的干支，取其太玄数相加，
  /// 作为此爻的数，如果为10则不用。将上卦三爻相加，下卦三爻相加。
  ///
  /// [guaName] 基本卦的名称 如 "坤艮" 之类
  /// 返回计算结果
  static int getTiaowenNumberByTaixuan(Enum64Gua guaName) {
    // 将地支装到卦上（纳甲方式）
    List<String> zhiTopToBottom = GuaUtils.najiaZhuangGua(guaName);
    List<String> ganTopToBottom = GuaUtils.najiaGanZhuangGua(guaName);

    // 计算太玄数列表
    List<int> taixuanNumberList = [];
    for (int i = 0; i < zhiTopToBottom.length; i++) {
      String zhi = zhiTopToBottom[i];
      String gan = ganTopToBottom[i];

      int taixuanZhiNumber = NumberMaps.taixuanZhiNumberMapper[zhi]!;
      int taixuanGanNumber = NumberMaps.taixuanGanNumberMapper[gan]!;
      int yaoNumber = taixuanZhiNumber + taixuanGanNumber;

      // 警告：当总和为10时不用，故为0
      if (yaoNumber == 10) {
        yaoNumber = 0;
      }
      taixuanNumberList.add(yaoNumber);
    }

    // 上卦三爻相加
    int uponGua = taixuanNumberList.sublist(0, 3).reduce((a, b) => a + b);
    // 下卦三爻相加
    int underGua = taixuanNumberList.sublist(3).reduce((a, b) => a + b);

    // 上卦三爻太玄数和为前两位，下卦三爻太玄数为后两位，四位数为条数
    return int.parse('$uponGua$underGua');
  }

  /// 计算条文的辅助方法
  ///
  /// [upperGua] 上卦
  /// [lowerGua] 下卦
  /// [totalNumber] 总数
  /// 返回条文基础数字
  static int calculateTiaowen(
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
    int totalNumber,
  ) {
    // 获取上卦和下卦的后天数
    int upperHoutianNumber = NumberMaps.houGuaNumberMapper[upperGua]!;
    int lowerHoutianNumber = NumberMaps.houGuaNumberMapper[lowerGua]!;

    // 计算：上卦后天数*1000 + 累加基数 - 下卦后天数
    return upperHoutianNumber * 1000 + totalNumber - lowerHoutianNumber;
  }

  /// 根据给定的基数，进行times次递减，每次递减defaultFactor
  ///
  /// [baseNumber] 基本数
  /// [times] 递减次数
  /// [defaultFactor] 递减因子，默认为96
  /// [returnWithBase] 是否包含基数，默认为true
  /// 返回结果列表，包含baseNumber和递减后的结果列表
  static List<int> calculateTiaoWenListBySubFactorTimes(
    int baseNumber,
    int times, {
    int defaultFactor = 96,
    bool returnWithBase = true,
  }) {
    int counterSub = baseNumber;
    List<int> subResult = [];

    if (returnWithBase) {
      subResult.add(baseNumber);
    }

    for (int i = 0; i < times; i++) {
      counterSub -= defaultFactor;
      subResult.add(counterSub);
    }

    return subResult;
  }

  /// 根据给定的基数，进行times次递增，每次递增defaultFactor
  ///
  /// [baseNumber] 基本数
  /// [times] 递增次数
  /// [defaultFactor] 递增因子，默认为96
  /// [returnWithBase] 是否包含基数，默认为true
  /// 返回结果列表，包含baseNumber和递增后的结果列表
  static List<int> calculateTiaoWenListByAddFactorTimes(
    int baseNumber,
    int times, {
    int defaultFactor = 96,
    bool returnWithBase = true,
  }) {
    List<int> resultList = [];

    if (returnWithBase) {
      resultList.add(baseNumber);
    }

    int counter = baseNumber;
    for (int i = 0; i < times; i++) {
      counter += defaultFactor;
      resultList.add(counter);
    }

    return resultList;
  }

  /// 根据给定的基数，进行times次递增，每次递增defaultFactor
  /// 如果withSub为true，则会进行同等次数的递减
  ///
  /// [baseNumber] 基本数
  /// [times] 递增(或减)次数
  /// [defaultFactor] 递增(或减)因子，默认为96
  /// [withSub] 是否进行递减，默认为true
  /// 返回结果列表，包含baseNumber和递增(或减)后的结果列表，顺序为从小到大
  static List<int> calculateTiaoWenListByFactorTimes(
    int baseNumber,
    int times, {
    int defaultFactor = 96,
    bool withSub = true,
  }) {
    List<int> resultList = [baseNumber];
    int counter = baseNumber;

    for (int i = 0; i < times; i++) {
      counter += defaultFactor;
      resultList.add(counter);
    }

    if (withSub) {
      int counterSub = baseNumber;
      List<int> subResult = [];

      for (int i = 0; i < times; i++) {
        counterSub -= defaultFactor;
        subResult.add(counterSub);
      }

      subResult = subResult.reversed.toList();
      return [...subResult, ...resultList];
    }

    return resultList;
  }

  /// 根据给定的基数，进行multipleList次递减，
  /// 每次递减defaultFactor * multipleList[i]
  ///
  /// [baseNumber] 基本数
  /// [multipleList] 递减倍数列表
  /// [defaultFactor] 递减因子，默认为48
  /// [returnWithBase] 是否包含基数，默认为false
  /// 返回结果列表，包含递减后的结果列表
  static List<int> calculateTiaoWenListBySubMultipleFactorTimes(
    int baseNumber,
    List<int> list, {
    List<int> multipleList = const [2, 4, 8, 16],
    int defaultFactor = 48,
    bool returnWithBase = false,
  }) {
    List<int> subResult = [];

    if (returnWithBase) {
      subResult.add(baseNumber);
    }

    for (int i in multipleList) {
      subResult.add(baseNumber - defaultFactor * i);
    }

    return subResult;
  }

  /// 根据给定的基数，进行multipleList次递增，
  /// 每次递增defaultFactor * multipleList[i]
  ///
  /// [baseNumber] 基本数
  /// [multipleList] 递增倍数列表
  /// [defaultFactor] 递增因子，默认为48
  /// [returnWithBase] 是否包含基数，默认为false
  /// 返回结果列表，包含递增后的结果列表
  static List<int> calculateTiaoWenListByAddMultipleFactorTimes(
    int baseNumber, {
    List<int> multipleList = const [2, 4, 8, 16],
    int defaultFactor = 48,
    bool returnWithBase = false,
  }) {
    List<int> addResult = [];

    if (returnWithBase) {
      addResult.add(baseNumber);
    }

    for (int i in multipleList) {
      addResult.add(baseNumber + defaultFactor * i);
    }

    return addResult;
  }

  /// 根据给定的基数，进行96次递增，每次递增96
  ///
  /// [baseNumber] 基本数
  /// [times] 递增次数
  /// [withBaseNumber] 是否包含基数，默认为false
  /// [withSubtractList] 是否包含递减列表，默认为true
  /// 返回结果列表，包含递增后的结果列表，顺序为从小到大
  static List<int> calculateTiaowenNumberList96(
    int baseNumber,
    int times, {
    bool withBaseNumber = false,
    bool withSubtractList = true,
  }) {
    List<int> result = calculateTiaoWenListByAddFactorTimes(
      baseNumber,
      times,
      defaultFactor: 96,
      returnWithBase: false,
    );

    if (withSubtractList) {
      result.addAll(
        calculateTiaoWenListBySubFactorTimes(
          baseNumber,
          times,
          defaultFactor: 96,
          returnWithBase: false,
        ),
      );
    }

    if (withBaseNumber) {
      result.add(baseNumber);
    }

    result.sort();
    return result;
  }

  /// 根据给定的基数，进行48次递增，每次递增48
  ///
  /// [baseNumber] 基本数
  /// [withBaseNumber] 是否包含基数，默认为false
  /// [withSubtractList] 是否包含递减列表，默认为true
  /// 返回结果列表，包含递增后的结果列表，顺序为从小到大
  static List<int> calculateTiaowenNumberList48(
    int baseNumber, {
    bool withBaseNumber = false,
    bool withSubtractList = true,
  }) {
    List<int> result = calculateTiaoWenListByAddMultipleFactorTimes(
      baseNumber,
      multipleList: [2, 4, 8, 16],
      defaultFactor: 48,
      returnWithBase: false,
    );

    if (withSubtractList) {
      result.addAll(
        calculateTiaoWenListBySubMultipleFactorTimes(
          baseNumber,
          [2, 4, 8, 16],
          defaultFactor: 48,
          returnWithBase: false,
        ),
      );
    }

    if (withBaseNumber) {
      result.add(baseNumber);
    }

    result.sort();
    return result;
  }

  /// 计算条文列表
  ///
  /// [baseNumber] 基本数
  /// [defaultFactor] 默认因子，默认为48
  /// [isOnlyAdd] 是否只计算加法，默认为true
  /// 返回(递增列表, 递减列表)的元组
  static (List<int>, List<int>) calculateTiaoWenList(
    int baseNumber, {
    int defaultFactor = 48,
    bool isOnlyAdd = true,
  }) {
    List<int> numberN = [2, 4, 8, 16];

    List<int> subList = [];
    if (isOnlyAdd) {
      for (int i = 0; i < numberN.length; i++) {
        subList.add(baseNumber - 48 * numberN[i]);
      }
    }

    List<int> addedList = [];
    for (int i = 0; i < numberN.length; i++) {
      addedList.add(baseNumber + 48 * numberN[i]);
    }

    return (addedList, subList);
  }
}
