/// 皇极取数法计算策略
///
/// 职责：
/// - 基于八字（四柱）实现皇极取数法的完整计算流程
/// - 提供计算结果（初刻数、次条文数、基础数、最终条文数列表）与步骤详情
/// - 提供条文计算配置以适配不同计算方案
/// - 生成候选基础数并验证有效性，用于交互选择
///
/// 流程概览：
/// 1) `calculate` 入口：参数校验 → 初刻数 → 次条文数 → 最终条文数列表 → 步骤详情
/// 2) 初刻数：基于元会数与年干太玄千位，超出阈值按规则扣减
/// 3) 次条文数：基于运世数与年干太玄千位，超出阈值按规则扣减
/// 4) 最终条文数：围绕基础数与运世数，按年/月/日/时干支位数组合计算
///
/// 注意：
/// - 标准策略不直接获取条文文本，仅返回数字列表；上层可结合仓库展示
/// - `defaultTiaoWenCalculationConfig` 与 `supportedTiaoWenCalculationConfigs` 提供配置选择
library;

import 'package:common/models/eight_chars.dart';
import 'package:flutter/foundation.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/four_zhu.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import 'base_calculation_strategy.dart';

/// 皇极取数法计算策略
///
/// 实现皇极取数法的完整计算逻辑，包括：
/// 1. 初刻数计算（规则1-4）
/// 2. 次条文数计算（规则5前半部分）
/// 3. 最终条文数计算（规则6-17）
class HuangJiCalculationStrategy
    extends
        BaseCalculationStrategy<
          HuangJiCalculationParams,
          HuangJiCalculationResult
        > {
  @override
  String get name => '皇极取数法';

  @override
  String get description => '基于四柱的皇极取数法，支持元会运世取数计算';

  @override
  StrategyCategory get category => StrategyCategory.standard;

  @override
  /// 入口方法：执行完整皇极取数流程
  /// 入参：`params` 包含八字等必要数据
  /// 返回：`HuangJiCalculationResult`（含初刻数、次条文数、基础数、最终条文数列表与步骤详情）
  /// 错误：抛出 `HuangJiCalculationException` 或其子类；包含四柱信息与原始异常
  HuangJiCalculationResult calculate(HuangJiCalculationParams params) {
    try {
      if (kDebugMode) {
        print('🚀 HuangJiCalculationStrategy: 开始计算');
        print('📊 输入八字: ${params.eightChars.toString()}');
      }

      // 验证参数
      validateParams(params);

      if (kDebugMode) {
        print('✅ HuangJiCalculationStrategy: 参数验证完成');
      }

      final fourZhu = params.eightChars;

      if (kDebugMode) {
        print('🔧 HuangJiCalculationStrategy: 开始计算初刻数');
      }

      // 步骤1-4：计算初刻数
      final initialNumber = _calculateInitialNumber(fourZhu);

      if (kDebugMode) {
        print('✅ HuangJiCalculationStrategy: 初刻数计算完成: $initialNumber');
        print('🔧 HuangJiCalculationStrategy: 开始计算次条文数');
      }

      // 步骤5：计算次条文数
      final secondaryNumber = _calculateSecondaryNumber(fourZhu, initialNumber);

      if (kDebugMode) {
        print('✅ HuangJiCalculationStrategy: 次条文数计算完成: $secondaryNumber');
      }

      // 这里暂时使用次条文数作为基础数，实际应用中需要用户确认
      final baseNumber = secondaryNumber;

      if (kDebugMode) {
        print('🔧 HuangJiCalculationStrategy: 开始计算最终条文数列表');
      }

      // 步骤6-17：计算最终条文数列表
      final finalNumbers = _calculateFinalNumbers(fourZhu, baseNumber);

      if (kDebugMode) {
        print('✅ HuangJiCalculationStrategy: 最终条文数计算完成: $finalNumbers');
        print('🔧 HuangJiCalculationStrategy: 构建计算步骤详情');
      }

      // 构建计算步骤详情
      final calculationSteps = _buildCalculationSteps(
        fourZhu,
        initialNumber,
        secondaryNumber,
        baseNumber,
        finalNumbers,
      );

      if (kDebugMode) {
        print('✅ HuangJiCalculationStrategy: 计算步骤构建完成');
        print('🎉 HuangJiCalculationStrategy: 计算成功完成');
      }

      return HuangJiCalculationResult.success(
        initialNumber: initialNumber,
        secondaryNumber: secondaryNumber,
        baseNumber: baseNumber,
        finalNumbers: finalNumbers,
        tiaoWenDataList: null, // 标准策略不获取条文数据
        calculationSteps: calculationSteps,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiCalculationStrategy: 计算失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }

      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      throw HuangJiCalculationException(
        message: '皇极取数法计算失败: ${e.toString()}',
        fourZhuInfo: params.eightChars.toString(),
        originalException: e,
      );
    }
  }

  @override
  /// 参数校验：确保必需的八字信息存在
  /// 入参：`params` 计算参数
  /// 错误：缺少八字时抛出 `InputValidationException`
  void validateParams(HuangJiCalculationParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        '四柱参数',
        parameterName: '四柱',
        message: '四柱信息不能为空',
      );
    }
  }

  /// 计算初刻数（规则1-4）
  ///
  /// 1. 排四柱，四柱天干与地支配太玄数
  /// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
  /// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
  /// 4. 元会基础数 + 年干太玄数 = 条文数（如果条文数大于13000 则将条文数减去12000）
  int _calculateInitialNumber(EightChars eightChars) {
    try {
      // 计算元会数
      final yuanHuiNumber = _calculateYuanHuiNumber(eightChars);

      // 计算初刻数
      int initialNumber =
          yuanHuiNumber +
          Constants.taiXuanGanNumberMapper[eightChars.year.gan]! * 1000;

      // 如果大于13000则减去12000
      if (initialNumber > 13000) {
        initialNumber -= 12000;
      }

      return initialNumber;
    } catch (e) {
      throw InitialNumberCalculationException(
        yearTaiXuan:
            Constants.taiXuanGanNumberMapper[eightChars.year.gan]! +
            Constants.taiXuanZhiNumberMapper[eightChars.year.zhi]!,
        monthTaiXuan:
            Constants.taiXuanGanNumberMapper[eightChars.month.gan]! +
            Constants.taiXuanZhiNumberMapper[eightChars.month.zhi]!,
        dayTaiXuan:
            Constants.taiXuanGanNumberMapper[eightChars.day.gan]! +
            Constants.taiXuanZhiNumberMapper[eightChars.day.zhi]!,
        hourTaiXuan:
            Constants.taiXuanGanNumberMapper[eightChars.time.gan]! +
            Constants.taiXuanZhiNumberMapper[eightChars.time.zhi]!,
        fourZhuInfo: eightChars.toString(),
        message: '初刻数计算失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// 计算元会数
  ///
  /// 年+月 互合成数顺左旋取数
  int _calculateYuanHuiNumber(EightChars fourZhu) {
    final yuanNumber =
        Constants.taiXuanGanNumberMapper[fourZhu.year.gan]! +
        Constants.taiXuanZhiNumberMapper[fourZhu.year.zhi]!;
    final monthNumber =
        Constants.taiXuanGanNumberMapper[fourZhu.month.gan]! +
        Constants.taiXuanZhiNumberMapper[fourZhu.month.zhi]!;

    // 确保都是两位数
    int tmpYuanNumber = yuanNumber;
    if (tmpYuanNumber < 10) {
      tmpYuanNumber = tmpYuanNumber * 10;
    }
    int tmpMonthNumber = monthNumber;
    if (tmpMonthNumber < 10) {
      tmpMonthNumber = tmpMonthNumber * 10;
    }

    // 左旋合成
    int yuanHuiNumber = int.parse('$tmpYuanNumber$tmpMonthNumber');
    if (yuanHuiNumber > 13000) {
      yuanHuiNumber = yuanHuiNumber - 12000;
    }
    return yuanHuiNumber;
  }

  /// 计算次条文数（规则5前半部分）
  ///
  /// 基于运世基础数计算次条文数
  int _calculateSecondaryNumber(EightChars fourZhu, int initialNumber) {
    try {
      // 计算运世数
      final yunShiNumber = _calculateYunShiNumber(fourZhu);

      // 计算次条文数
      int secondaryNumber =
          yunShiNumber +
          Constants.taiXuanGanNumberMapper[fourZhu.year.gan]! * 1000;
      if (secondaryNumber > 13000) {
        secondaryNumber -= 12000;
      }

      return secondaryNumber;
    } catch (e) {
      throw SecondaryNumberCalculationException(
        initialNumber: initialNumber,
        calculationRule: '运世基础数计算',
        fourZhuInfo: fourZhu.toString(),
        message: '次条文数计算失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// 计算运世数
  ///
  /// 日+时 互合成数逆右旋取数
  int _calculateYunShiNumber(EightChars fourZhu) {
    final dayNumber =
        Constants.taiXuanGanNumberMapper[fourZhu.dayTianGan]! +
        Constants.taiXuanZhiNumberMapper[fourZhu.dayDiZhi]!;

    final timeNumber =
        Constants.taiXuanGanNumberMapper[fourZhu.time.gan]! +
        Constants.taiXuanZhiNumberMapper[fourZhu.time.zhi]!;

    // 确保日数是两位数
    int tmpDayNumber = dayNumber;
    if (dayNumber < 10) {
      tmpDayNumber = tmpDayNumber * 10;
    }

    // 右旋
    final tmpDayStr = tmpDayNumber.toString();
    tmpDayNumber = int.parse(
      '${tmpDayStr[tmpDayStr.length - 1]}${tmpDayStr.substring(0, tmpDayStr.length - 1)}',
    );

    // 确保时数是两位数
    int tmpTimeNumber = timeNumber;
    if (timeNumber < 10) {
      tmpTimeNumber = tmpTimeNumber * 10;
    }
    final tmpTimeStr = tmpTimeNumber.toString();
    tmpTimeNumber = int.parse(
      '${tmpTimeStr[tmpTimeStr.length - 1]}${tmpTimeStr.substring(0, tmpTimeStr.length - 1)}',
    );

    return int.parse('$tmpDayNumber$tmpTimeNumber');
  }

  /// 计算最终条文数列表（规则6-17）
  ///
  /// 基于确定的基础数计算12种不同的条文数
  List<int> _calculateFinalNumbers(EightChars fourZhu, int baseNumber) {
    try {
      final yunShiNumber = _calculateYunShiNumber(fourZhu);

      final yearGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.year.gan]!;
      final yearZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.year.zhi]!;

      final monthGanNumber =
          Constants.taiXuanGanNumberMapper[fourZhu.month.gan]!;
      final monthZhiNumber =
          Constants.taiXuanZhiNumberMapper[fourZhu.month.zhi]!;

      final dayGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.day.gan]!;
      final dayZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.day.zhi]!;

      final timeGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.time.gan]!;
      final timeZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.time.zhi]!;

      return [
        // 基础数 + 月干(百位数) = 条文数
        baseNumber + monthGanNumber * 100,

        // 基础数 + 月支(百位数) = 条文数
        baseNumber + monthZhiNumber * 100,

        // 基础数 + 月干支互数(干为十位+支为个位) = 条文数
        baseNumber + monthGanNumber * 10 + monthZhiNumber,

        // 基础数 + 时干(个位数) = 条文数
        baseNumber + timeGanNumber,

        // 基础数 + 时支(个位数) = 条文数
        baseNumber + timeZhiNumber,

        // 基础数 + 日干支互合数(干为十位+支为个位) + 时干个位数 = 条文数
        baseNumber + dayGanNumber * 10 + dayZhiNumber + timeGanNumber,

        // 基础数 + 日干支互合数(干为十位+支为个位) + 时支个位数 = 条文数
        baseNumber + dayGanNumber * 10 + dayZhiNumber + timeZhiNumber,

        // 基础数 + 年支(千位数) = 条文数
        baseNumber + yearZhiNumber * 1000,

        // 运世基础数 + 日干支互合数 = 条文数
        yunShiNumber + dayGanNumber * 10 + dayZhiNumber,

        // 运世基础数 + 时干个位数 = 条文数
        yunShiNumber + timeGanNumber,

        // 运世基础数 + 时支个位数 = 条文数
        yunShiNumber + timeZhiNumber,

        // 运世基础数 + 日干支互合数 + 时干个位数 = 条文数
        yunShiNumber + dayGanNumber * 10 + dayZhiNumber + timeGanNumber,

        // 运世基础数 + 日干支互合数 + 时支个位数 = 条文数
        yunShiNumber + dayGanNumber * 10 + dayZhiNumber + timeZhiNumber,
      ];
    } catch (e) {
      throw FinalNumbersCalculationException(
        baseNumber: baseNumber,
        fourZhuInfo: fourZhu.toString(),
        message: '最终条文数计算失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// 构建计算步骤详情
  /// 行为：汇总计算过程的关键中间值与规则描述，便于 UI 展示与排障
  /// 返回：包含太玄数、元会/运世、各阶段结果与规则说明的字典
  Map<String, dynamic> _buildCalculationSteps(
    EightChars fourZhu,
    int initialNumber,
    int secondaryNumber,
    int baseNumber,
    List<int> finalNumbers,
  ) {
    final yearGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.year.gan]!;
    final yearZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.year.zhi]!;

    final monthGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.month.gan]!;
    final monthZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.month.zhi]!;

    final dayGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.day.gan]!;
    final dayZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.day.zhi]!;

    final timeGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.time.gan]!;
    final timeZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.time.zhi]!;

    final yearNumber = yearGanNumber + yearZhiNumber;
    final monthNumber = monthGanNumber + monthZhiNumber;
    final dayNumber = dayGanNumber + dayZhiNumber;
    final timeNumber = timeGanNumber + timeZhiNumber;
    final yuanHuiNumber = _calculateYuanHuiNumber(fourZhu);
    final yunShiNumber = _calculateYunShiNumber(fourZhu);

    return {
      'fourZhu': fourZhu.toString(),
      'taixuanNumbers': {
        'year': {'gan': yearGanNumber, 'zhi': yearZhiNumber, 'sum': yearNumber},
        'month': {
          'gan': monthGanNumber,
          'zhi': monthZhiNumber,
          'sum': monthNumber,
        },
        'day': {'gan': dayGanNumber, 'zhi': dayZhiNumber, 'sum': dayNumber},
        'time': {'gan': timeGanNumber, 'zhi': timeZhiNumber, 'sum': timeNumber},
      },
      'yuanHuiNumber': yuanHuiNumber,
      'yunShiNumber': yunShiNumber,
      'initialNumber': initialNumber,
      'secondaryNumber': secondaryNumber,
      'baseNumber': baseNumber,
      'finalNumbers': finalNumbers,
      'calculationRules': [
        '基础数 + 月干(百位数)',
        '基础数 + 月支(百位数)',
        '基础数 + 月干支互数',
        '基础数 + 时干(个位数)',
        '基础数 + 时支(个位数)',
        '基础数 + 日干支互合数 + 时干个位数',
        '基础数 + 日干支互合数 + 时支个位数',
        '基础数 + 年支(千位数)',
        '运世基础数 + 日干支互合数',
        '运世基础数 + 时干个位数',
        '运世基础数 + 时支个位数',
        '运世基础数 + 日干支互合数 + 时干个位数',
        '运世基础数 + 日干支互合数 + 时支个位数',
      ],
    };
  }

  /// 生成候选基础数列表
  ///
  /// 用于交互式选择，按照"30"递增或递减
  /// 行为：以 `originalNumber` 为中心，生成向下与向上各 `count` 个，以 `step` 为步长的候选列表
  /// 返回：候选基础数列表，首元素为原始数
  List<int> generateCandidateNumbers(
    int originalNumber, {
    int count = 10,
    int step = 30,
  }) {
    final candidates = <int>[];

    // 添加原始数字
    candidates.add(originalNumber);

    // 添加递减的候选数
    for (int i = 1; i <= count; i++) {
      candidates.add(originalNumber - i * step);
    }

    // 添加递增的候选数
    for (int i = 1; i <= count; i++) {
      candidates.add(originalNumber + i * step);
    }

    return candidates;
  }

  /// 计算另外两种方案中新增的最终条文数列表
  ///
  /// 该函数包含了《皇极取数法二》和《皇极取数法三》中独有的条文计算规则。
  /// 这些规则的核心是引入了新的衍生“基础数”。
  Map<String, int> _calculateAdditionalFinalNumbers(
    EightChars fourZhu,
    int baseNumber, // 这个是“基础数一”，即校准后的元会数
  ) {
    // 首先，获取所有需要的原始太玄数，与原函数保持一致
    final yearGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.year.gan]!;
    final monthGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.month.gan]!;
    final dayGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.day.gan]!;
    final dayZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.day.zhi]!;
    final timeGanNumber = Constants.taiXuanGanNumberMapper[fourZhu.time.gan]!;
    final timeZhiNumber = Constants.taiXuanZhiNumberMapper[fourZhu.time.zhi]!;

    // 重新计算运世数，因为它是多个计算的基础
    final yunShiNumber = _calculateYunShiNumber(fourZhu);

    // 用于存储新增条文数的Map，使用描述性键名以区分
    final additionalNumbers = <String, int>{};

    // --- 方案二：“对称修正双核”方案新增的计算 ---
    // 该方案的核心是定义了一个新的“基础数二”，即修正后的运世数

    // 1. 定义《皇极取数法二》的“基础数二”
    // 公式: 运世基础数 + 年干太玄数
    final baseNumber2Method2 = yunShiNumber + yearGanNumber;

    // 2. 基于“基础数一”的新增条文
    // 公式: 基础数一 + 日干(十位数) = 条文数
    additionalNumbers['方案二_基础数一_加_日干十位'] = baseNumber + dayGanNumber * 10;

    // 3. 基于“基础数二”的系列条文
    // 公式: 基础数二 + 月干(百位数) = 条文数
    additionalNumbers['方案二_基础数二_加_月干百位'] =
        baseNumber2Method2 + monthGanNumber * 100;

    // 公式: 基础数二 + 日干(十位数) = 条文数
    additionalNumbers['方案二_基础数二_加_日干十位'] =
        baseNumber2Method2 + dayGanNumber * 10;

    // 公式: 基础数二 + 时干个位数 = 条文数
    additionalNumbers['方案二_基础数二_加_时干个位'] = baseNumber2Method2 + timeGanNumber;

    // --- 方案三：“递进衍生”方案新增的计算 ---
    // 该方案的核心是定义了多个衍生的基础数 (基础数二, 基础数三, 基础数四)

    // 1. 定义《皇极取数法三》的“基础数二”
    // 公式: 基础数一 + 日干支合数（日干十位、日支个位）
    final dayPillarNumber = dayGanNumber * 10 + dayZhiNumber; // 日干支合数
    final baseNumber2Method3 = baseNumber + dayPillarNumber;

    // 2. 基于“基础数二”的系列条文
    // 公式: 基础数二 + 时干个位 = 条文数
    additionalNumbers['方案三_基础数二_加_时干个位'] = baseNumber2Method3 + timeGanNumber;

    // 公式: 基础数二 + 时支个位 = 条文数
    additionalNumbers['方案三_基础数二_加_时支个位'] = baseNumber2Method3 + timeZhiNumber;

    // 3. 定义《皇极取数法三》的“基础数三”
    // 公式: 运世基本数 + 年干太玄千位
    // 注意: 这里“年干太玄千位”通常理解为 年干数 * 1000
    final baseNumber3Method3 = yunShiNumber + yearGanNumber * 1000;

    // 4. 定义《皇极取数法三》的“基础数四”
    // 公式: 基础数三 + 日干支合数
    final baseNumber4Method3 = baseNumber3Method3 + dayPillarNumber;

    // 5. 基于“基础数四”的系列条文
    // 公式: 基础数四 + 时干(个位数) = 条文数
    additionalNumbers['方案三_基础数四_加_时干个位'] = baseNumber4Method3 + timeGanNumber;

    // 公式: 基础数四 + 时支(个位数) = 条文数
    additionalNumbers['方案三_基础数四_加_时支个位'] = baseNumber4Method3 + timeZhiNumber;

    return additionalNumbers;
  }

  /// 验证候选数是否有效
  /// 行为：检查候选基础数范围是否在 (0, 13000] 之间
  /// 返回：布尔值
  bool isValidCandidateNumber(int candidateNumber) {
    // 基本验证：数字应该在合理范围内
    return candidateNumber > 0 && candidateNumber <= 13000;
  }

  /// 获取默认的条文计算配置
  @override
  /// 默认条文计算配置：皇极取数法配置
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return HuangJiTiaoWenCalculationConfig();
  }

  /// 计算条文列表（使用指定配置）
  @override
  /// 使用指定的条文计算配置计算条文列表
  /// 入参：基础数、计算参数、配置实例（需实现 `calculateTiaoWenList`）
  /// 返回：条文数列表 `List<int>`
  /// 错误：抛出 `HuangJiCalculationException`，包含步骤说明与四柱信息
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    HuangJiCalculationParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 构建计算上下文
    final context = <String, dynamic>{
      'eightChars': params.eightChars,
      'baseNumber': baseNumber,
    };

    try {
      return config.calculateTiaoWenList(baseNumber, context);
    } catch (e) {
      throw HuangJiCalculationException(
        message: '皇极取数法计算失败: $e',
        code: '10',
        originalException: e,
        calculationStep: '条文列表计算',
        fourZhuInfo: params.eightChars.toString(),
      );
    }
  }

  /// 获取支持的条文计算配置选项
  @override
  /// 返回支持的条文计算配置集合：默认配置 + 简化通用配置
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      HuangJiTiaoWenCalculationConfig(),
      // 皇极取数法也可以支持简化的通用配置作为备选
      GenericTiaoWenCalculationConfig.customList(
        name: "皇极简化配置",
        description: "简化的皇极取数：基础数±100",
        customList: [0, 100],
        withSub: true,
      ),
    ];
  }

  @override
  /// 条文计算描述：取默认配置的说明文本
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  @override
  // TODO: implement detailSteps
  /// 详细步骤描述：暂未实现，返回占位内容
  List<String> get detailSteps => ["未实现"];

  @override
  // TODO: implement school
  /// 所属流派/方案：当前为“皇极取数法一”
  String get school => "皇极取数法一";
}
