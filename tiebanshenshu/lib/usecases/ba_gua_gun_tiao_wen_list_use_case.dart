import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/ba_gua_gun_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/ba_gua_gun_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 八卦滚法条文列表UseCase实现
///
/// 负责处理基于八卦滚法计算条文列表的业务逻辑
/// 八个卦各产生6个条文编号（基于三基数 a,b,c 的组合），共48个条文
class BaGuaGunTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<BaGuaGunUseCaseParams> {
  final BaGuaGunStrategy _strategy;
  final TiaoWenRepository _repository;

  BaGuaGunTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '八卦滚法UseCase';

  @override
  String get description => '基于八卦滚法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    BaGuaGunUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = BaGuaGunStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("八卦滚法计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取BaGuaGunBaseNumberModel
      final baGuaGunModel =
          strategyResult.baseNumbers.first as BaGuaGunBaseNumberModel;

      // 4. 获取基本数和条文编号列表
      final baseNumber = baGuaGunModel.baseNumber;
      final allTiaoWenNumbers = baGuaGunModel.finalTiaowenList;

      // 5. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 6. 构建BaseNumberTiaoWenListModel
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: baseNumber,
          tiaoWenDataList: tiaoWenDataList,
          name: baGuaGunModel.name,
          description:
              "八卦滚法条文（基本数$baseNumber，八卦共${allTiaoWenNumbers.length}个条文）",
          source: baGuaGunModel.source,
          tiaoWenNumbers: allTiaoWenNumbers,
        ),
      ];

      // 7. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '八卦滚法',
        algorithmDescription:
            '八卦滚法（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          // 同步返回八字及转换后的四柱字符串，便于UI层显示
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'basicGua': baGuaGunModel.basicGua,
          'basicNumber': baGuaGunModel.basicNumber,
          'variationBase': baGuaGunModel.variationBase,
          'firstFourGuaList': baGuaGunModel.firstFourGuaList,
          'lastFourGuaList': baGuaGunModel.lastFourGuaList,
          'eightGuaCount': baGuaGunModel.eightGuaList.length,
          'guaThreeNumbersList': baGuaGunModel.guaThreeNumbersList,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          // 保存BaGuaGunBaseNumberModel以便UI层访问完整的中间结果
          'baGuaGunBaseNumberModel': baGuaGunModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '八卦滚法',
        algorithmDescription: '八卦滚法',
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
  void validateParams(BaGuaGunUseCaseParams params) {
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

/// 八卦滚法UseCase参数
///
/// 包含八卦滚法计算所需的所有参数
class BaGuaGunUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  const BaGuaGunUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
  });

  @override
  String toString() {
    return 'BaGuaGunUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaGuaGunUseCaseParams &&
        other.eightChars == eightChars &&
        other.gender == gender &&
        other.threeYuan == threeYuan;
  }

  @override
  int get hashCode =>
      eightChars.hashCode ^ gender.hashCode ^ threeYuan.hashCode;
}
