/// 先后天卦六爻干支和数法Strategy实现
///
/// 将先后天卦六爻干支和数法算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../domain/four_zhu.dart';
import '../../constant/constants.dart' as constants;
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/liu_yao_gan_zhi_he_base_number_model.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 先后天卦六爻干支和数法计算参数
///
/// 包含执行先后天卦六爻干支和数法所需的所有参数
class LiuYaoGanZhiHeStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  LiuYaoGanZhiHeStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String get description =>
      "先后天卦六爻干支和数法计算参数：四柱(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)";
}

/// 先后天卦六爻干支和数法计算策略
///
/// 实现先后天卦六爻干支和数法的标准计算策略
///
/// 算法原理：
/// 1. 排四柱
/// 2. 根据元堂卦法取先天卦和后天卦
/// 3. 对先天卦进行六爻纳甲（天干+地支）
/// 4. 纳甲的天干、地支配上太玄数，每爻的干支太玄数相加（如果和==10则不计）
/// 5. 上三爻干支相加的数总和，下三爻干支相加的数总和。前者作为千百位，后者作为十位个位，组成一个四位条文数
/// 6. 这个数递增减96四次，得到8个数
/// 7. 后天卦重复步骤3-6
class LiuYaoGanZhiHeStrategy
    extends
        StandardCalculationStrategy<
          LiuYaoGanZhiHeStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "先后天卦六爻干支和数法";

  @override
  String get description =>
      "根据元堂卦法取先天卦和后天卦，对两卦分别进行六爻纳甲装配（天干+地支），计算六爻干支太玄数之和（和为10则不计），上三爻为千百位，下三爻为十位个位，组成四位条文数";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 根据元堂卦法取先天卦和后天卦",
    "3. 先天卦六爻纳甲配置：为六爻配置天干和地支",
    "4. 先天卦干支和数计算：每爻的干支太玄数相加（和为10不计），上三爻为千百位，下三爻为十位个位",
    "5. 后天卦六爻纳甲配置：为六爻配置天干和地支",
    "6. 后天卦干支和数计算：每爻的干支太玄数相加（和为10不计），上三爻为千百位，下三爻为十位个位",
    "7. 条文扩展：先天卦和后天卦基础数分别递增减96四次，各得到8个条文编号",
  ];

  @override
  String get school => "先后天卦六爻干支和数流派";

  @override
  BaseNumberModelResult calculate(LiuYaoGanZhiHeStrategyParams params) {
    try {
      // 步骤1-2：生成天地卦和先后天卦（复用元堂卦法的逻辑）
      final (
        tianGua,
        diGua,
        ganNumList,
        zhiNumList,
        oddNumTotal,
        evenNumTotal,
        tianGuaNum,
        diGuaNum,
        usedThreeYuanWuGong,
      ) = _generateTianDiGua(
        params,
      );

      final (
        yearYinYang,
        upperGua,
        lowerGua,
        xiantianGua,
        xiantianUpperGuaNumber,
        xiantianLowerGuaNumber,
      ) = _generateXiantianGua(
        params,
        tianGua,
        diGua,
      );

      final (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber) =
          _generateHoutianGuaPlaceholder(xiantianGua);

      // 步骤3-4：先天卦六爻纳甲和干支和数计算
      final (
        xiantianBaseNumber,
        xiantianYaoTianGanList,
        xiantianYaoDiZhiList,
        xiantianYaoSumList,
        xiantianUpperSum,
        xiantianLowerSum,
      ) = _calculateLiuYaoSum(
        xiantianGua,
      );

      // 步骤5-6：后天卦六爻纳甲和干支和数计算
      final (
        houtianBaseNumber,
        houtianYaoTianGanList,
        houtianYaoDiZhiList,
        houtianYaoSumList,
        houtianUpperSum,
        houtianLowerSum,
      ) = _calculateLiuYaoSum(
        houtianGua,
      );

      // 创建数据模型
      final model = LiuYaoGanZhiHeBaseNumberModel.create(
        baseNumber: xiantianBaseNumber, // 使用先天卦基础数作为主基础数（也可以选择后天卦）
        name: "先后天卦六爻干支和数法",
        description:
            "先后天卦六爻干支和数法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
        source: BaseNumberSource.yearZhu, // 使用yearZhu作为来源标识
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        // 天地卦字段
        ganNumList: ganNumList,
        zhiNumList: zhiNumList,
        oddNumTotal: oddNumTotal,
        evenNumTotal: evenNumTotal,
        tianGuaNum: tianGuaNum,
        diGuaNum: diGuaNum,
        tianGua: tianGua,
        diGua: diGua,
        usedThreeYuanWuGong: usedThreeYuanWuGong,
        // 先后天卦字段
        yearYinYang: yearYinYang,
        upperGua: upperGua,
        lowerGua: lowerGua,
        xiantianGua: xiantianGua,
        houtianGua: houtianGua,
        xiantianUpperGuaNumber: xiantianUpperGuaNumber,
        xiantianLowerGuaNumber: xiantianLowerGuaNumber,
        houtianUpperGuaNumber: houtianUpperGuaNumber,
        houtianLowerGuaNumber: houtianLowerGuaNumber,
        // 先天卦六爻纳甲字段
        xiantianYaoTianGanList: xiantianYaoTianGanList,
        xiantianYaoDiZhiList: xiantianYaoDiZhiList,
        xiantianYaoSumList: xiantianYaoSumList,
        xiantianUpperSum: xiantianUpperSum,
        xiantianLowerSum: xiantianLowerSum,
        xiantianBaseNumber: xiantianBaseNumber,
        // 后天卦六爻纳甲字段
        houtianYaoTianGanList: houtianYaoTianGanList,
        houtianYaoDiZhiList: houtianYaoDiZhiList,
        houtianYaoSumList: houtianYaoSumList,
        houtianUpperSum: houtianUpperSum,
        houtianLowerSum: houtianLowerSum,
        houtianBaseNumber: houtianBaseNumber,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [model],
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianGua': xiantianGua,
          'houtianGua': houtianGua,
          'xiantianBaseNumber': xiantianBaseNumber,
          'houtianBaseNumber': houtianBaseNumber,
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "先后天卦六爻干支和数法计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description,
        },
      );
    }
  }

  /// 为六爻配置天干（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoTianGan
  /// - 外卦（上卦）使用 outerGuaYaoTianGan
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个天干，从初爻到上爻)
  List<String> _najiaTianGan(String guaName) {
    // 拆分成上下卦
    final upperGuaName = guaName[0];
    final lowerGuaName = guaName[1];

    // 转换为Enum8Gua
    final Enum8Gua upperGua = _stringToEnum8Gua(upperGuaName);
    final Enum8Gua lowerGua = _stringToEnum8Gua(lowerGuaName);

    // 获取纳甲天干配置
    final List<TianGan> lowerTianGanList =
        constants.innerGuaYaoTianGan[lowerGua]!; // 内卦（下卦）
    final List<TianGan> upperTianGanList =
        constants.outerGuaYaoTianGan[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var tianGan in lowerTianGanList) {
      result.add(tianGan.name);
    }
    for (var tianGan in upperTianGanList) {
      result.add(tianGan.name);
    }

    return result;
  }

  /// 为六爻配置地支（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoDiZhi
  /// - 外卦（上卦）使用 outerGuaYaoDiZhi
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个地支，从初爻到上爻)
  List<String> _najiaDiZhi(String guaName) {
    // 拆分成上下卦
    final upperGuaName = guaName[0];
    final lowerGuaName = guaName[1];

    // 转换为Enum8Gua
    final Enum8Gua upperGua = _stringToEnum8Gua(upperGuaName);
    final Enum8Gua lowerGua = _stringToEnum8Gua(lowerGuaName);

    // 获取纳甲地支配置
    final List<DiZhi> lowerDiZhiList =
        constants.innerGuaYaoDiZhi[lowerGua]!; // 内卦（下卦）
    final List<DiZhi> upperDiZhiList =
        constants.outerGuaYaoDiZhi[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var diZhi in lowerDiZhiList) {
      result.add(diZhi.name);
    }
    for (var diZhi in upperDiZhiList) {
      result.add(diZhi.name);
    }

    return result;
  }

  /// 获取天干或地支的太玄数
  ///
  /// [ganOrZhi] 天干或地支字符串
  /// 返回: int (太玄数 1-10，但实际映射范围是4-9)
  int _getTaixuanNumber(String ganOrZhi) {
    // 优先尝试天干映射
    if (constants.taixuanGanNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanGanNumberMapper[ganOrZhi]!;
    }

    // 尝试地支映射
    if (constants.taixuanZhiNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanZhiNumberMapper[ganOrZhi]!;
    }

    // 如果都不存在，抛出异常
    throw ArgumentError('无法找到 $ganOrZhi 对应的太玄数');
  }

  /// 计算单爻干支太玄数之和
  ///
  /// 规则：天干太玄数 + 地支太玄数，如果和==10则返回0（不计）
  ///
  /// [tianGan] 天干字符串
  /// [diZhi] 地支字符串
  /// 返回: int (如果和==10则返回0，否则返回和)
  int _calculateYaoGanZhiSum(String tianGan, String diZhi) {
    final ganNum = _getTaixuanNumber(tianGan);
    final zhiNum = _getTaixuanNumber(diZhi);
    final sum = ganNum + zhiNum;

    // 和为10不计
    if (sum == 10) {
      return 0;
    }

    return sum;
  }

  /// 计算六爻干支和数，组成四位数
  ///
  /// 步骤：
  /// 1. 调用 _najiaTianGan() 获取六个天干
  /// 2. 调用 _najiaDiZhi() 获取六个地支
  /// 3. 对每一爻调用 _calculateYaoGanZhiSum()
  /// 4. 上三爻（4-6爻，即索引3-5）和数作为千百位
  /// 5. 下三爻（1-3爻，即索引0-2）和数作为十位个位
  /// 6. 组合成四位基础数
  ///
  /// [guaName] 卦名（如"震坤"）
  /// 返回: (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum)
  (int, List<String>, List<String>, List<int>, int, int) _calculateLiuYaoSum(
    String guaName,
  ) {
    // 步骤1-2：获取六爻纳甲配置
    final tianGanList = _najiaTianGan(guaName);
    final diZhiList = _najiaDiZhi(guaName);

    // 步骤3：计算每一爻的干支和数
    final yaoSumList = <int>[];
    for (var i = 0; i < 6; i++) {
      final sum = _calculateYaoGanZhiSum(tianGanList[i], diZhiList[i]);
      yaoSumList.add(sum);
    }

    // 步骤4：下三爻（初、二、三爻，索引0-2）和数作为十位个位
    final lowerSum = yaoSumList[0] + yaoSumList[1] + yaoSumList[2];

    // 步骤5：上三爻（四、五、上爻，索引3-5）和数作为千百位
    final upperSum = yaoSumList[3] + yaoSumList[4] + yaoSumList[5];

    // 步骤6：组合成四位基础数
    // 千百位（上三爻） + 十位个位（下三爻）
    final baseNumber = upperSum * 100 + lowerSum;

    return (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum);
  }

  /// 获取默认的条文计算配置
  ///
  /// 先天卦和后天卦都使用递增减96四次：[0, 96, 192, 288, 384, -96, -192, -288]
  /// 每个卦生成8个条文编号
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "递增减96四次",
      description: "先天卦/后天卦基础数分别递增减96四次，各得到8个条文编号",
      customList: [0, 96, 192, 288, 384, -96, -192, -288],
      withSub: false, // 已经包含了负数，不需要额外的减法
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    LiuYaoGanZhiHeStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    if (config is GenericTiaoWenCalculationConfig) {
      // 使用calculationList进行递加
      return config.calculationList
          .map((offset) => baseNumber + offset)
          .toList();
    }
    // 降级处理：直接返回基础数
    return [baseNumber];
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  // ========== 辅助方法 ==========

  /// 将卦名字符串转换为Enum8Gua枚举
  Enum8Gua _stringToEnum8Gua(String guaName) {
    switch (guaName) {
      case "乾":
        return Enum8Gua.Qian;
      case "坤":
        return Enum8Gua.Kun;
      case "震":
        return Enum8Gua.Zhen;
      case "巽":
        return Enum8Gua.Xun;
      case "坎":
        return Enum8Gua.Kan;
      case "离":
        return Enum8Gua.Li;
      case "艮":
        return Enum8Gua.Gen;
      case "兑":
        return Enum8Gua.Dui;
      default:
        throw ArgumentError('未知的卦名: $guaName');
    }
  }

  /// 步骤1：生成天地卦（复用元堂卦法逻辑）
  ///
  /// 返回: (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
  ///        tianGuaNum, diGuaNum, usedThreeYuanWuGong)
  (String, String, List<int>, List<List<int>>, int, int, int, int, bool)
  _generateTianDiGua(LiuYaoGanZhiHeStrategyParams params) {
    // 提取四柱天干数列表
    final ganNumList = [
      constants.tianGanNumberMapper[params.eightChars.year.gan.name]!,
      constants.tianGanNumberMapper[params.eightChars.month.gan.name]!,
      constants.tianGanNumberMapper[params.eightChars.day.gan.name]!,
      constants.tianGanNumberMapper[params.eightChars.time.gan.name]!,
    ];

    // 提取四柱地支数列表（每个地支两个数）
    final zhiNumList = [
      constants.diZhiNumberMapper[params.eightChars.year.zhi.name]!,
      constants.diZhiNumberMapper[params.eightChars.month.zhi.name]!,
      constants.diZhiNumberMapper[params.eightChars.day.zhi.name]!,
      constants.diZhiNumberMapper[params.eightChars.time.zhi.name]!,
    ];

    // 展开地支数列表用于计算奇偶和
    final zhiNumTotalList = [
      ...constants.diZhiNumberMapper[params.eightChars.year.zhi.name]!,
      ...constants.diZhiNumberMapper[params.eightChars.month.zhi.name]!,
      ...constants.diZhiNumberMapper[params.eightChars.day.zhi.name]!,
      ...constants.diZhiNumberMapper[params.eightChars.time.zhi.name]!,
    ];

    // 计算奇数和、偶数和
    final oddNumTotal =
        (ganNumList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 1).fold<int>(0, (a, b) => a + b));

    final evenNumTotal =
        (ganNumList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b) +
        zhiNumTotalList.where((i) => i % 2 == 0).fold<int>(0, (a, b) => a + b));

    // 计算天数（奇数和 模25，但如果结果为0或能整除则特殊处理）
    final tianGuaNum = _calculateGuaNum(oddNumTotal, 25, 5);

    // 计算地数（偶数和 模30，但如果结果为0或能整除则特殊处理）
    final diGuaNum = _calculateGuaNum(evenNumTotal, 30, 3);

    // 数配卦
    final yearYinYang = params.eightChars.year.gan.isYang ? "阳" : "阴";
    String tianGua;
    String diGua;
    bool usedThreeYuanWuGong = false;

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

    // 天卦配卦（天数为5时查询三元五宫）
    if (tianGuaNum == 5) {
      tianGua =
          threeYuan5GongMapper[params.threeYuan]![params.gender]![yearYinYang]!;
      usedThreeYuanWuGong = true;
    } else {
      if (!constants.yuantangHuaTianNumberGuaMapper.containsKey(tianGuaNum)) {
        throw ArgumentError('无效的天数: $tianGuaNum，映射表中不存在该键');
      }
      tianGua = constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
    }

    // 地卦配卦（地数为5时查询三元五宫）
    if (diGuaNum == 5) {
      diGua =
          threeYuan5GongMapper[params.threeYuan]![params.gender]![yearYinYang]!;
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

  /// 步骤2：生成先天卦（复用元堂卦法逻辑）
  ///
  /// 返回: (yearYinYang, upperGua, lowerGua, xiantianGua,
  ///        xiantianUpperGuaNumber, xiantianLowerGuaNumber)
  (String, String, String, String, int, int) _generateXiantianGua(
    LiuYaoGanZhiHeStrategyParams params,
    String tianGua,
    String diGua,
  ) {
    final yearYinYang = params.eightChars.year.gan.isYang ? "阳" : "阴";
    String upperGua;
    String lowerGua;

    // 根据年份阴阳和性别决定上下卦位置
    if (yearYinYang == "阳") {
      if (params.gender == "男") {
        upperGua = tianGua;
        lowerGua = diGua;
      } else {
        upperGua = diGua;
        lowerGua = tianGua;
      }
    } else {
      if (params.gender == "女") {
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

  /// 生成后天卦（占位实现）
  ///
  /// TODO: 实现完整的元堂卦爻变逻辑
  /// 目前简化处理：后天卦与先天卦相同
  ///
  /// 返回: (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber)
  (String, int, int) _generateHoutianGuaPlaceholder(String xiantianGua) {
    final upperGua = xiantianGua[0];
    final lowerGua = xiantianGua[1];

    final houtianUpperGuaNumber = constants.houTianGuaNumberMapper[upperGua]!;
    final houtianLowerGuaNumber = constants.houTianGuaNumberMapper[lowerGua]!;

    // 简化处理：后天卦与先天卦相同
    return (xiantianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
  }

  /// 计算卦数（处理模运算的特殊情况）
  ///
  /// [total] 总和
  /// [divisor] 除数（25或30）
  /// [defaultValue] 当余数为0时的默认值（5或3）
  /// 返回: 卦数（1-9范围内，其中5需要特殊处理三元五宫）
  ///
  /// 算法逻辑：
  /// 1. 如果 total == divisor，返回 defaultValue
  /// 2. 如果 total > divisor，先模 divisor 得到余数
  /// 3. 最后再模10取个位，确保结果在0-9范围内
  int _calculateGuaNum(int total, int divisor, int defaultValue) {
    if (total == divisor) {
      return defaultValue;
    }

    int remainder = total;
    if (total > divisor) {
      remainder = total % divisor;
    }

    // 最后模10取个位，确保结果在0-9范围内
    // 这样可以将任意余数映射到1-9（0会被特殊处理为defaultValue）
    return remainder % 10;
  }
}
