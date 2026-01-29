import 'package:common/enums.dart';

import 'base_get_tiao_wen_list_use_case.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/day_gan_zhi_gua_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import './base_get_tiao_wen_list_use_case.dart';

/// 日干支卦条文列表UseCase实现
///
/// 负责处理基于日干支卦计算条文列表的业务逻辑
/// 包含参数验证、Strategy调用、条文列表计算和Repository查询
class DayGanZhiGuaTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<DayGanZhiGuaUseCaseParams> {
  final DayGanZhiGuaStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  DayGanZhiGuaTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '日干支卦UseCase';

  @override
  String get description => '基于日干支卦计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    DayGanZhiGuaUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      TiaoWenListCalculationConfig effectiveConfig =
          calculationConfig ?? defaultCalculationConfig;
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础条文
      final strategyParams = DayGanZhiGuaStrategyParams(
        dayGanZhi: params.dayGanZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("日柱变卦计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 使用基类模板方法处理条文列表
      final updatedBaseNumbers = await super.processWithBatchQuery(
        strategyResult.baseNumbers,
        effectiveConfig,
      );

      // 4. 提取所有条文实体
      final allTiaoWenEntities = updatedBaseNumbers
          .expand((model) => model.tiaoWenDataList)
          .toList();

      // 5. 创建并返回MultiBaseNumberResult
      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: strategyResult.algorithmDescription,
        calculationParams: strategyResult.calculationParams,
        sourceData: {
          ...strategyResult.sourceData,
          'calculationConfig': effectiveConfig.desc ?? 'Unknown',
          'tiaoWenCount': updatedBaseNumbers.fold<int>(
            0,
            (sum, model) => sum + model.tiaoWenCount,
          ),
        },
        baseNumberTiaoWenList: updatedBaseNumbers,
        tiaoWenEntities: allTiaoWenEntities,
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '日干支卦',
        algorithmDescription: '日柱变卦取数法',
        calculationParams: params.dayGanZhi.name,
        errorMessage: e.toString(),
        sourceData: {'dayGanZhi': params.dayGanZhi.name, 'error': e.toString()},
      );
    }
  }

  @override
  void validateParams(DayGanZhiGuaUseCaseParams params) {
    if (params.dayGanZhi == null) {
      throw InputValidationException(
        "日干支参数",
        parameterName: '日干支参数',
        message: '日干支参数',
      );
    }
  }
}

/// 日干支卦UseCase参数
///
/// 使用JiaZi对象而不是字符串，与Strategy参数保持一致
class DayGanZhiGuaUseCaseParams {
  /// 日干支
  final JiaZi dayGanZhi;

  const DayGanZhiGuaUseCaseParams({required this.dayGanZhi});

  @override
  String toString() {
    return 'DayGanZhiGuaUseCaseParams(dayGanZhi: ${dayGanZhi.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayGanZhiGuaUseCaseParams && other.dayGanZhi == dayGanZhi;
  }

  @override
  int get hashCode => dayGanZhi.hashCode;
}
