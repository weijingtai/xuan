import 'package:common/models/eight_chars.dart';

import 'base_get_tiao_wen_list_use_case.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 太玄四柱条文列表UseCase实现
///
/// 负责处理基于太玄四柱计算条文列表的业务逻辑
/// 完整流程：Strategy计算基础数字 -> 根据配置扩展条文列表 -> Repository获取条文实体
class TaiXuanFourZhuTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<TaiXuanFourZhuUseCaseParams> {
  final TaiXuanFourZhuStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  TaiXuanFourZhuTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '太玄四柱UseCase';

  @override
  String get description => '基于太玄四柱计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    TaiXuanFourZhuUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      TiaoWenListCalculationConfig config =
          calculationConfig ?? defaultCalculationConfig;
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础数模型
      final strategyParams = TaiXuanFourZhuStrategyParams(
        eightChars: params.eightChars,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("太玄四柱计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 使用基类模板方法处理条文列表
      final updatedBaseNumbers = await processWithBatchQuery(
        strategyResult.baseNumbers,
        config,
      );

      // 4. 创建并返回MultiBaseNumberResult
      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: strategyResult.algorithmDescription,
        calculationParams: strategyResult.calculationParams,
        sourceData: {
          ...strategyResult.sourceData,
          'calculationConfig': config.desc ?? 'N/A',
          'tiaoWenCount': updatedBaseNumbers.fold<int>(
            0,
            (sum, model) => sum + model.tiaoWenCount,
          ),
        },
        baseNumberTiaoWenList: updatedBaseNumbers,
      );
    } catch (e) {
      return MultiBaseNumberResult.error(
        algorithmName: '太玄四柱',
        algorithmDescription: '太玄四柱取数法',
        calculationParams: params.eightChars.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(TaiXuanFourZhuUseCaseParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        "八字不能为空",
        message: '八字不能为空',
        parameterName: '四柱太玄',
      );
    }
  }
}

/// 太玄四柱UseCase参数
///
/// 使用EightChars对象而不是字符串列表，与Strategy参数保持一致
class TaiXuanFourZhuUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const TaiXuanFourZhuUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'TaiXuanFourZhuUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaiXuanFourZhuUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
