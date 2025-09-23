import 'package:common/models/eight_chars.dart';

import '../application/usecases/base_get_tiao_wen_list_use_case.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../domain/models/tiao_wen_list_state.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/four_zhu_tian_gan_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 四柱天干条文列表UseCase实现
///
/// 负责处理基于四柱天干计算条文列表的业务逻辑
/// 完整流程：Strategy计算基础数字 -> 根据配置扩展条文列表 -> Repository获取条文实体
class FourZhuTianGanTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<FourZhuTianGanUseCaseParams> {
  final FourZhuTianGanStrategy _strategy;
  final TiaoWenRepository _repository;
  final TiaoWenListCalculationConfig defaultCalculationConfig;

  FourZhuTianGanTiaoWenListUseCase(
    this._strategy,
    this._repository,
    this.defaultCalculationConfig,
  );

  @override
  String get name => '四柱天干UseCase';

  @override
  String get description => '基于四柱天干计算条文列表的UseCase';

  @override
  Future<TiaoWenListResult> execute(
    FourZhuTianGanUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算基础数字
      final strategyParams = FourZhuTianGanStrategyParams(
        eightChars: params.eightChars,
      );
      final strategyResult = _strategy.calculate(strategyParams);
      final baseNumber = strategyResult.baseNumber;

      // 3. 根据配置扩展条文列表
      final effectiveConfig = calculationConfig ?? defaultCalculationConfig;
      final calculator = TiaoWenListCalculator(effectiveConfig);
      final calculationResult = calculator.calculate(baseNumber);
      final tiaoWenNumbers = calculationResult.tiaoWenNumbers;

      // 4. 调用Repository获取条文实体
      final tiaoWenEntities = await _repository.getByIdList(
        queryList: tiaoWenNumbers,
      );

      // 5. 转换为UseCase结果
      return TiaoWenListResult.success(
        tiaoWenNumbers: tiaoWenNumbers,
        tiaoWenEntities: tiaoWenEntities,
        calculationMethod: '四柱天干',
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'baseNumber': baseNumber,
          'tiaoWenNumbers': tiaoWenNumbers,
          'calculationConfig': effectiveConfig.desc ?? 'N/A',
          'tiaoWenCount': tiaoWenNumbers.length,
          'tiaoWenEntities': tiaoWenEntities.map((e) => e.toJson()).toList(),
        },
      );
    } catch (e) {
      return TiaoWenListResult.error(
        calculationMethod: '四柱天干',
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(FourZhuTianGanUseCaseParams params) {
    if (params.eightChars == null) {
      throw InputValidationException(
        "四柱太玄",
        message: '八字不能为空',
        parameterName: '四柱太玄',
      );
    }
  }
}

/// 四柱天干UseCase参数
///
/// 使用EightChars对象而不是字符串列表，与Strategy参数保持一致
class FourZhuTianGanUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  const FourZhuTianGanUseCaseParams({required this.eightChars});

  @override
  String toString() {
    return 'FourZhuTianGanUseCaseParams(eightChars: ${eightChars.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FourZhuTianGanUseCaseParams &&
        other.eightChars == eightChars;
  }

  @override
  int get hashCode => eightChars.hashCode;
}
