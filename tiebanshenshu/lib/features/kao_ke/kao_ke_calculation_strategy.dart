import 'package:common/models/eight_chars.dart';
import 'kao_ke_session_models.dart';
import '../../domain/models/tiao_wen_result.dart';

/// 考刻计算策略接口
///
/// 定义了卦象计算和条文计算的抽象方法
/// 具体实现类将调用 XianHoutianJiaZeStrategy 和 LiuYaoGanZhiHeStrategy
abstract class KaoKeCalculationStrategy {
  /// 计算卦象
  ///
  /// [baseNumber] 四位数的基础数(从选中的条文编号获取)
  ///
  /// 返回卦象计算结果,包含上下卦及完整卦名
  GuaCalculationResult calculateGua(int baseNumber);

  /// 根据指定计算方法计算条文
  ///
  /// [baseNumber] 基础数(条文编号)
  /// [guaResult] 卦象计算结果
  /// [method] 计算方法(八卦加则/爻干支和数法)
  /// [eightChars] 用户八字
  ///
  /// 返回该方法计算出的条文结果列表
  Future<List<TiaoWenResult>> calculateTiaoWenByMethod({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required KaoKeCalculationMethod method,
    required EightChars eightChars,
  });

  /// 批量计算多个方法的条文
  ///
  /// [baseNumber] 基础数
  /// [guaResult] 卦象计算结果
  /// [methods] 要使用的计算方法集合
  /// [eightChars] 用户八字
  ///
  /// 返回按方法分组的条文结果Map
  Future<Map<KaoKeCalculationMethod, List<TiaoWenResult>>>
      calculateAllMethods({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required Set<KaoKeCalculationMethod> methods,
    required EightChars eightChars,
  }) async {
    final results = <KaoKeCalculationMethod, List<TiaoWenResult>>{};

    for (final method in methods) {
      final tiaoWenList = await calculateTiaoWenByMethod(
        baseNumber: baseNumber,
        guaResult: guaResult,
        method: method,
        eightChars: eightChars,
      );
      results[method] = tiaoWenList;
    }

    return results;
  }
}
