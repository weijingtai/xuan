/// 元堂派生策略的统一基类
///
/// 所有基于元堂卦的策略（先后天卦加则法、先后天卦取数、六爻干支和数法）
/// 都继承此基类，共享 YuanTangInfo 的获取和缓存逻辑
library;

import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';

import '../../../constant/constants.dart' as constants;
import '../../../domain/models/base_number_model_result.dart';
import '../standard_calculation_strategy.dart';
import 'yuan_tang_derived_params.dart';

/// 元堂派生策略的统一基类
///
/// 职责：
/// 1. 统一管理 YuanTangInfo 的获取（懒加载或复用）
/// 2. 提供模板方法，子类只需实现特定算法逻辑
/// 3. 消除子类中的重复代码
///
/// 泛型参数：
/// - P: 参数类型，必须继承自 YuanTangDerivedParams
/// - R: 结果类型，必须继承自 BaseNumberModelResult
abstract class YuanTangBasedStrategy<P extends YuanTangDerivedParams,
    R extends BaseNumberModelResult> extends StandardCalculationStrategy<P, R> {
  /// 获取 YuanTangInfo（懒加载或复用）
  ///
  /// 此方法封装了复杂的获取逻辑，子类无需关心
  /// - 如果 params.yuanTangInfo 已存在，直接返回
  /// - 否则，调用 YuanTangCalculator 计算并缓存
  YuanTangInfo getYuanTangInfo(P params) {
    return params.getOrComputeYuanTangInfo();
  }

  /// 模板方法：计算流程
  ///
  /// 默认实现：
  /// 1. 获取 YuanTangInfo
  /// 2. 调用子类的 calculateWithYuanTangInfo 进行特定算法计算
  /// 3. 处理错误情况
  ///
  /// 子类可以覆盖此方法以自定义流程，但通常只需实现 calculateWithYuanTangInfo
  @override
  R calculate(P params) {
    try {
      // 步骤1：获取 YuanTangInfo（可能是从头计算，也可能是复用）
      final yuanTangInfo = getYuanTangInfo(params);

      // 步骤2：调用子类的特定算法计算
      return calculateWithYuanTangInfo(params, yuanTangInfo);
    } catch (e, stackTrace) {
      // 步骤3：错误处理
      return handleError(params, e, stackTrace);
    }
  }

  /// 抽象方法：使用 YuanTangInfo 进行特定算法计算
  ///
  /// 子类必须实现此方法，定义自己的算法逻辑
  ///
  /// 参数：
  /// - params: 策略参数
  /// - yuanTangInfo: 已计算好的元堂卦信息（包含先天卦、后天卦等）
  ///
  /// 返回: 计算结果
  R calculateWithYuanTangInfo(P params, YuanTangInfo yuanTangInfo);

  /// 抽象方法：错误处理
  ///
  /// 子类必须实现此方法，定义错误时的返回结果
  ///
  /// 参数：
  /// - params: 策略参数
  /// - error: 错误对象
  /// - stackTrace: 堆栈跟踪
  ///
  /// 返回: 错误结果
  R handleError(P params, Object error, StackTrace stackTrace);

  /// 便捷方法：提取先天卦
  ///
  /// 从 YuanTangInfo 中提取先天卦象
  Enum64Gua getXiantianGua(YuanTangInfo yuanTangInfo) {
    return yuanTangInfo.xianTanGua.gua;
  }

  /// 便捷方法：提取后天卦
  ///
  /// 从 YuanTangInfo 中提取后天卦象
  Enum64Gua getHoutianGua(YuanTangInfo yuanTangInfo) {
    return yuanTangInfo.houTianGua.gua;
  }

  /// 便捷方法：提取元堂爻索引
  ///
  /// 从 YuanTangInfo 中提取元堂爻位置（0-5）
  int getYuanTangYaoIndex(YuanTangInfo yuanTangInfo) {
    return yuanTangInfo.xianTanGua.yuanTangYao.indexAtYaoList;
  }

  /// 便捷方法：提取上下卦的后天数
  ///
  /// 返回：(上卦后天数, 下卦后天数)
  (int, int) getHoutianNumbers(YuanTangInfo yuanTangInfo) {
    final upperNum = constants.houGuaNumberMapper[yuanTangInfo.xianTanGua.gua.top]!;
    final lowerNum = constants.houGuaNumberMapper[yuanTangInfo.xianTanGua.gua.bottom]!;
    return (upperNum, lowerNum);
  }

  /// 便捷方法：判断是否使用了预计算的 YuanTangInfo
  ///
  /// 用于日志记录或性能监控
  bool isUsingPrecomputedYuanTangInfo(P params) {
    return params.isUsingPrecomputedYuanTangInfo;
  }

  /// 获取计算模式描述（用于日志）
  String getCalculationModeDescription(P params) {
    return params.isUsingPrecomputedYuanTangInfo
        ? "复用模式（使用预计算的元堂卦信息）"
        : "从头计算模式（重新计算元堂卦信息）";
  }
}
