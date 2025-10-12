import '../domain/four_zhu.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/yuan_tang_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/yuan_tang_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 元堂卦条文列表UseCase实现
///
/// 负责处理基于元堂卦取数法计算条文列表的业务逻辑
/// 元堂卦产生8种条文编号（加则法、纳甲太玄数法、本互法、互取数列表，先天卦和后天卦各一套）
class YuanTangTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<YuanTangUseCaseParams> {
  final YuanTangStrategy _strategy;
  final TiaoWenRepository _repository;

  YuanTangTiaoWenListUseCase(
    this._strategy,
    this._repository,
  );

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig
          as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '元堂卦UseCase';

  @override
  String get description => '基于元堂卦取数法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    YuanTangUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = YuanTangStrategyParams(
        fourZhu: params.fourZhu,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("元堂卦计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取YuanTangBaseNumberModel（只有一个结果）
      final yuanTangModel =
          strategyResult.baseNumbers.first as YuanTangBaseNumberModel;

      // 4. 收集所有8种条文编号
      final tiaoWenNumbers = <int>[
        yuanTangModel.tiaowenNumberJiazeXiantiangua,
        yuanTangModel.tiaowenNumberJiazeHoutiangua,
        yuanTangModel.tiaowenNumberNajiaTaixuanXiantiangua,
        yuanTangModel.tiaowenNumberNajiaTaixuanHoutiangua,
        yuanTangModel.tiaowenNumberXiantianBenhu,
        yuanTangModel.tiaowenNumberHoutianBenhu,
        ...yuanTangModel.tiaowenNumberListXiantianGuahu,
        ...yuanTangModel.tiaowenNumberListHoutianGuahu,
      ].toSet().toList(); // 去重

      // 5. 批量查询条文数据
      final tiaoWenDataList =
          await _repository.getByIdList(queryList: tiaoWenNumbers);

      // 6. 构建BaseNumberTiaoWenListModel
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: yuanTangModel.baseNumber,
          tiaoWenDataList: tiaoWenDataList,
          name: yuanTangModel.name,
          description: yuanTangModel.description,
          source: yuanTangModel.source,
          tiaoWenNumbers: tiaoWenNumbers,
        ),
      ];

      // 7. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: strategyResult.algorithmName,
        algorithmDescription: strategyResult.algorithmDescription,
        calculationParams: strategyResult.calculationParams,
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          ...strategyResult.sourceData,
          'tiaoWenCount': tiaoWenDataList.length,
          'totalBaseNumbers': 1,
          'tiaoWenMethodsCount': 8,
          'uniqueTiaoWenNumbers': tiaoWenNumbers.length,
          // 保存YuanTangBaseNumberModel以便UI层访问完整的中间结果
          'yuanTangBaseNumberModel': yuanTangModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '元堂卦取数法',
        algorithmDescription: '元堂卦取数法',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'fourZhu': params.fourZhu.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(YuanTangUseCaseParams params) {
    // 验证性别
    if (params.gender != "男" && params.gender != "女") {
      throw InputValidationException(
        '性别验证',
        parameterName: 'gender',
        parameterValue: params.gender,
        message: '性别必须为"男"或"女"',
      );
    }

    // 验证三元
    if (params.threeYuan != "上" &&
        params.threeYuan != "中" &&
        params.threeYuan != "下") {
      throw InputValidationException(
        '三元验证',
        parameterName: 'threeYuan',
        parameterValue: params.threeYuan,
        message: '三元必须为"上"、"中"或"下"',
      );
    }

    // 验证节气
    if (params.birthAfterZhi != "夏至" && params.birthAfterZhi != "冬至") {
      throw InputValidationException(
        '节气验证',
        parameterName: 'birthAfterZhi',
        parameterValue: params.birthAfterZhi,
        message: '出生节气后必须为"夏至"或"冬至"',
      );
    }
  }
}

/// 元堂卦UseCase参数
///
/// 包含元堂卦计算所需的所有参数
class YuanTangUseCaseParams {
  /// 四柱信息
  final FourZhu fourZhu;

  /// 性别（"男" / "女"）
  final String gender;

  /// 三元（"上" / "中" / "下"）
  final String threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final String birthAfterZhi;

  const YuanTangUseCaseParams({
    required this.fourZhu,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String toString() {
    return 'YuanTangUseCaseParams(fourZhu: ${fourZhu.toString()}, gender: $gender, threeYuan: $threeYuan, birthAfterZhi: $birthAfterZhi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YuanTangUseCaseParams &&
        other.fourZhu == fourZhu &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.birthAfterZhi == birthAfterZhi;
  }

  @override
  int get hashCode =>
      fourZhu.hashCode ^
      gender.hashCode ^
      threeYuan.hashCode ^
      birthAfterZhi.hashCode;
}
