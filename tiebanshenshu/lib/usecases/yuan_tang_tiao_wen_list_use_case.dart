import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import '../domain/models/base_number_tiao_wen_list_model.dart';
import '../domain/models/multi_base_number_result.dart';
import '../domain/models/yuan_tang_base_number_model.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../features/yuan_tang_gua/yuan_tang_calculator.dart';
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

  YuanTangTiaoWenListUseCase(this._strategy, this._repository);

  @override
  TiaoWenListCalculationConfig get defaultCalculationConfig =>
      _strategy.defaultTiaoWenCalculationConfig as TiaoWenListCalculationConfig;

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
      // 从 EightChars 转为 EightChars

      // 从八字的月支计算出生月份数字
      final birthMonth = YuanTangStrategyParams.getMonthNumberFromZhi(
        params.eightChars.month.zhi.name,
      );
      final strategyParams = YuanTangStrategyParams(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        birthMonth: birthMonth,
        monthType: params.monthType,
        calanderType: params.calanderType,
      );
      final strategyResult = _strategy.calculate(strategyParams);

      // 检查计算是否成功
      if (strategyResult.hasError) {
        throw Exception("元堂卦计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取YuanTangBaseNumberModel
      final yuanTangModel =
          strategyResult.baseNumbers.first as YuanTangBaseNumberModel;

      // 4. 扩展先天卦条文编号（使用加则法基础数）
      final xiantianBaseNumber = yuanTangModel.tiaowenNumberJiazeXiantiangua;
      final xiantianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        strategyParams,
        _strategy.defaultTiaoWenCalculationConfig,
      );

      // 5. 扩展后天卦条文编号（使用加则法基础数）
      final houtianBaseNumber = yuanTangModel.tiaowenNumberJiazeHoutiangua;
      final houtianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        houtianBaseNumber,
        strategyParams,
        _strategy.defaultTiaoWenCalculationConfig,
      );

      // 6. 合并所有条文编号
      final allTiaoWenNumbers = <int>[
        ...xiantianTiaoWenList,
        ...houtianTiaoWenList,
      ].toSet().toList(); // 去重

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
          name: "${yuanTangModel.name} - 先天卦",
          description:
              "先天卦${yuanTangModel.xiantianGua}条文（基础数$xiantianBaseNumber + [0, 96, 192, 288, 384]）",
          source: yuanTangModel.source,
          tiaoWenNumbers: xiantianTiaoWenList,
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: houtianBaseNumber,
          tiaoWenDataList: tiaoWenDataList
              .where((t) => houtianTiaoWenList.contains(t.id))
              .toList(),
          name: "${yuanTangModel.name} - 后天卦",
          description:
              "后天卦${yuanTangModel.houtianGua}条文（基础数$houtianBaseNumber + [0, 96, 192, 288, 384]）",
          source: yuanTangModel.source,
          tiaoWenNumbers: houtianTiaoWenList,
        ),
      ];

      // 9. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '元堂卦取数法',
        algorithmDescription:
            '元堂卦取数法（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianTiaoWenCount': xiantianTiaoWenList.length,
          'houtianTiaoWenCount': houtianTiaoWenList.length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
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
  void validateParams(YuanTangUseCaseParams params) {
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

/// 元堂卦UseCase参数
///
/// 包含元堂卦计算所需的所有参数
class YuanTangUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  /// 月份类型（阴阳月判断规则）
  final YuanTangMonthType monthType;

  /// 历法类型（阳历/农历）
  final CalanderType calanderType;

  const YuanTangUseCaseParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    this.monthType = YuanTangMonthType.monthYinYan,
    this.calanderType = CalanderType.solar,
  });

  @override
  String toString() {
    return 'YuanTangUseCaseParams(eightChars: ${eightChars.toString()}, gender: $gender, threeYuan: $threeYuan, birthAfterZhi: $birthAfterZhi, monthType: $monthType, calanderType: $calanderType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YuanTangUseCaseParams &&
        other.eightChars == eightChars &&
        other.gender == gender &&
        other.threeYuan == threeYuan &&
        other.birthAfterZhi == birthAfterZhi &&
        other.monthType == monthType &&
        other.calanderType == calanderType;
  }

  @override
  int get hashCode =>
      eightChars.hashCode ^
      gender.hashCode ^
      threeYuan.hashCode ^
      birthAfterZhi.hashCode ^
      monthType.hashCode ^
      calanderType.hashCode;
}
