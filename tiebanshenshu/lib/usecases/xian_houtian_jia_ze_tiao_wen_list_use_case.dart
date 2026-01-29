import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/eight_chars.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/xian_houtian_gua_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/xian_houtian_jia_ze_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';
import 'base_get_tiao_wen_list_use_case.dart';

/// 先后天八卦加则法条文列表UseCase实现
///
/// 负责处理基于先后天八卦加则法计算条文列表的业务逻辑
/// 先天卦和后天卦各产生5个条文编号（先天卦递增96四次，后天卦递减96四次）
class XianHoutianJiaZeTiaoWenListUseCase
    extends BaseGetTiaoWenListUseCase<XianHoutianJiaZeUseCaseParams> {
  final XianHoutianJiaZeStrategy _strategy;
  final TiaoWenRepository _repository;

  XianHoutianJiaZeTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

  @override
  TiaoWenRepository get repository => _repository;

  @override
  String get name => '先后天八卦加则法UseCase';

  @override
  String get description => '基于先后天八卦加则法计算条文列表的UseCase';

  @override
  Future<MultiBaseNumberResult> execute(
    XianHoutianJiaZeUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = XianHoutianJiaZeStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("先后天八卦加则法计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取XianHoutianGuaBaseNumberModel
      final xianHoutianModel =
          strategyResult.baseNumbers.first as XianHoutianGuaBaseNumberModel;

      // 4. 获取先天卦条文编号（已在Strategy中递增96四次）
      final xiantianBaseNumber = xianHoutianModel.xiantianBaseNumber;
      final xiantianTiaoWenList = xianHoutianModel.xiantianTiaoWenNumbers;

      // 5. 获取后天卦条文编号（已在Strategy中递减96四次）
      final houtianBaseNumber = xianHoutianModel.houtianBaseNumber;
      final houtianTiaoWenList = xianHoutianModel.houtianTiaoWenNumbers;

      // 6. 合并所有条文编号
      final allTiaoWenNumbers = {
        ...xiantianTiaoWenList,
        ...houtianTiaoWenList,
      }.toList(); // 去重

      // 7. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 8. 构建两个BaseNumberTiaoWenListModel（先天和后天分开）
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: xiantianBaseNumber,
          tiaoWenDataList: tiaoWenDataList
              .where((t) => xiantianTiaoWenList.contains(t.id))
              .toList(),
          name: "${xianHoutianModel.name} - 先天卦",
          description:
              "先天卦${xianHoutianModel.xiantianGua}条文（基础数$xiantianBaseNumber + [0, 96, 192, 288, 384]）",
          source: xianHoutianModel.source,
          tiaoWenNumbers: xiantianTiaoWenList,
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: houtianBaseNumber,
          tiaoWenDataList: tiaoWenDataList
              .where((t) => houtianTiaoWenList.contains(t.id))
              .toList(),
          name: "${xianHoutianModel.name} - 后天卦",
          description:
              "后天卦${xianHoutianModel.houtianGua}条文（基础数$houtianBaseNumber + [0, -96, -192, -288, -384]）",
          source: xianHoutianModel.source,
          tiaoWenNumbers: houtianTiaoWenList,
        ),
      ];

      // 9. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '先后天八卦加则法',
        algorithmDescription:
            '先后天八卦加则法（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          // 同步返回八字及转换后的四柱字符串，便于UI层显示
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianTiaoWenCount': xiantianTiaoWenList.length,
          'houtianTiaoWenCount': houtianTiaoWenList.length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
          // 保存XianHoutianGuaBaseNumberModel以便UI层访问完整的中间结果
          'xianHoutianGuaBaseNumberModel': xianHoutianModel,
        },
      );
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      return MultiBaseNumberResult.error(
        algorithmName: '先后天八卦加则法',
        algorithmDescription: '先后天八卦加则法',
        calculationParams: params.toString(),
        errorMessage: e.toString(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  void validateParams(XianHoutianJiaZeUseCaseParams params) {
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

    // 验证节气
    if (params.birthAfterZhi != TwentyFourJieQi.XIA_ZHI &&
        params.birthAfterZhi != TwentyFourJieQi.DONG_ZHI) {
      throw InputValidationException(
        '节气验证',
        parameterName: 'birthAfterZhi',
        parameterValue: params.birthAfterZhi,
        message: '出生节气后必须为"夏至"或"冬至"',
      );
    }
  }
}

/// 先后天八卦加则法UseCase参数
///
/// 包含先后天八卦加则法计算所需的所有参数
class XianHoutianJiaZeUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  const XianHoutianJiaZeUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String toString() {
    return 'XianHoutianJiaZeUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan, birthAfterZhi: $birthAfterZhi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XianHoutianJiaZeUseCaseParams &&
        other.eightChars == eightChars &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.birthAfterZhi == birthAfterZhi;
  }

  @override
  int get hashCode =>
      eightChars.hashCode ^
      gender.hashCode ^
      threeYuan.hashCode ^
      birthAfterZhi.hashCode;
}
