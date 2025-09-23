/// 获取条文列表UseCase基类
///
/// 定义获取条文列表的通用业务逻辑接口
library;

import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 获取条文列表UseCase的基础抽象类
///
/// 定义了获取条文列表的通用接口，所有具体的条文列表UseCase都应该实现此接口
abstract class BaseGetTiaoWenListUseCase<TParams> {
  /// UseCase名称
  String get name;

  /// UseCase描述
  String get description;

  /// 执行UseCase
  ///
  /// [params] 计算参数
  /// [calculationConfig] 可选的计算配置，如果为null则使用默认配置
  /// 返回条文列表结果
  ///
  /// 抛出异常：
  /// - [InputValidationException] 输入参数验证失败
  /// - [StrategyCalculationException] Strategy计算失败
  /// - [TiaoWenListCalculationException] 条文列表计算失败
  /// - [TiaoWenDataException] 条文数据获取失败
  /// - [UseCaseExecutionException] UseCase执行失败
  Future<TiaoWenListResult> execute(
    TParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  });

  /// 验证参数
  ///
  /// [params] 待验证的参数
  /// 抛出 [InputValidationException] 如果参数无效
  void validateParams(TParams params) {
    if (params == null) {
      throw InputValidationException(
        "参数不能为空",
        message: '参数不能为空',
        parameterName: 'params',
      );
    }
  }
}
