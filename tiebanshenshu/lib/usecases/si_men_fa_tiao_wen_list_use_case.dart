import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/si_men_fa_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/si_men_fa_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 四门法V2条文列表UseCase实现
///
/// 负责处理基于四门法V2计算条文列表的业务逻辑
/// 四个卦各产生秘数和先天数，最终生成大量条文编号
class SiMenFaTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<SiMenFaUseCaseParams> {
  final SiMenFaStrategy _strategy;
  final TiaoWenRepository _repository;

  SiMenFaTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '四门法V2UseCase';

  @override
  String get description => '基于四门法V2计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    SiMenFaUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = SiMenFaStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("四门法V2计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取SiMenFaBaseNumberModel
      final siMenFaModel =
          strategyResult.baseNumbers.first as SiMenFaBaseNumberModel;

      // 4. 获取基本数和条文编号列表
      final baseNumber = siMenFaModel.baseNumber;
      final allTiaoWenNumbers = siMenFaModel.finalTiaowenList;

      // 5. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 6. 构建BaseNumberTiaoWenListModel
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: baseNumber,
          tiaoWenDataList: tiaoWenDataList,
          name: siMenFaModel.name,
          description:
              "四门法V2条文（基本数$baseNumber，共${allTiaoWenNumbers.length}个条文）",
          source: siMenFaModel.source,
          tiaoWenNumbers: allTiaoWenNumbers,
        ),
      ];

      // 7. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '四门法V2',
        algorithmDescription:
            '四门法V2（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          // 同步返回八字及转换后的四柱字符串，便于UI层显示
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'basicGua': siMenFaModel.basicGua,
          'basicNumber': siMenFaModel.basicNumber,
          'variationBase': siMenFaModel.variationBase,
          'fourGuaList': siMenFaModel.fourGuaList,
          'secretNumbers': siMenFaModel.secretNumbers,
          'xiantianNumbers': siMenFaModel.xiantianNumbers,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          // 保存SiMenFaBaseNumberModel以便UI层访问完整的中间结��
          'siMenFaBaseNumberModel': siMenFaModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '四门法V2',
        algorithmDescription: '四门法V2',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(SiMenFaUseCaseParams params) {
    // 验证性别
    if (params.gender != Gender.male && params.gender != Gender.female) {
      throw InputValidationException(
        '性别验证',
        parameterName: 'gender',
        parameterValue: params.gender,
        message: '性别必须为"男"或"女"',
      );
    }

    // 验证三元
    if (params.threeYuan != YuanYunOrder.upper &&
        params.threeYuan != YuanYunOrder.middle &&
        params.threeYuan != YuanYunOrder.lower) {
      throw InputValidationException(
        '三元验证',
        parameterName: 'threeYuan',
        parameterValue: params.threeYuan,
        message: '三元必须为"上"、"中"或"下"',
      );
    }
  }
}

/// 四门法V2UseCase参数
///
/// 包含四门法V2计算所需的所有参数
class SiMenFaUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  const SiMenFaUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
  });

  @override
  String toString() {
    return 'SiMenFaUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SiMenFaUseCaseParams &&
        other.eightChars == eightChars &&
        other.gender == gender &&
        other.threeYuan == threeYuan;
  }

  @override
  int get hashCode =>
      eightChars.hashCode ^ gender.hashCode ^ threeYuan.hashCode;
}
