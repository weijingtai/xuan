import 'package:common/models/eight_chars.dart';
import '../../domain/models/tiao_wen_result.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/ba_gua_jia_ze_strategy.dart';
import '../../service/strategy/gua_yao_gan_zhi_he_strategy.dart';
import '../../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';
import 'gua_calculation_helper.dart';
import 'kao_ke_session_models.dart';
import 'kao_ke_calculation_strategy.dart';

/// 考刻计算策略实现类
///
/// 负责卦象计算和条文计算的具体实现
/// 使用简化的条文扩展规则
class KaoKeCalculationStrategyImpl implements KaoKeCalculationStrategy {
  final TiaoWenRepository _tiaoWenRepository;

  KaoKeCalculationStrategyImpl({
    required TiaoWenRepository tiaoWenRepository,
  })  : _tiaoWenRepository = tiaoWenRepository;

  @override
  GuaCalculationResult calculateGua(int baseNumber) {
    return GuaCalculationHelper.calculateGua(baseNumber);
  }

  @override
  Future<List<TiaoWenResult>> calculateTiaoWenByMethod({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required KaoKeCalculationMethod method,
    required EightChars eightChars,
  }) async {
    switch (method) {
      case KaoKeCalculationMethod.baGuaJiaZe:
        return await _calculateByJiaZe(
          baseNumber: baseNumber,
          guaResult: guaResult,
          eightChars: eightChars,
        );

      case KaoKeCalculationMethod.liuYaoGanZhiHe:
        return await _calculateByGanZhiHe(
          baseNumber: baseNumber,
          guaResult: guaResult,
          eightChars: eightChars,
        );
    }
  }

  @override
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

  /// 使用八卦加则法计算条文
  ///
  /// 从卦象提取64卦，使用 BaGuaJiaZeStrategy 的两种方法计算条文
  Future<List<TiaoWenResult>> _calculateByJiaZe({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required EightChars eightChars,
  }) async {
    // 从上下卦数字获取 Enum64Gua
    final gua64 = GuaCalculationHelper.getEnum64Gua(
      guaResult.shangGuaNumber,
      guaResult.xiaGuaNumber,
    );

    if (gua64 == null) {
      // 如果无法转换为64卦，返回空列表
      return [];
    }

    // 使用爻序法计算
    final yaoSeqResult =
        BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

    // 使用纳甲法计算
    final naJiaResult =
        BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

    // 批量查询条文内容
    final tiaoWenNumbers = [
      yaoSeqResult.tiaoWenNumber,
      naJiaResult.tiaoWenNumber,
    ];

    final tiaoWenContentMap =
        await _tiaoWenRepository.getTiaoWenContentByNumbers(tiaoWenNumbers);

    // 构建结果列表
    final results = <TiaoWenResult>[];

    // 添加爻序法结果
    final yaoSeqContent = tiaoWenContentMap[yaoSeqResult.tiaoWenNumber];
    if (yaoSeqContent != null) {
      results.add(
        TiaoWenResult(
          groupId: 'kao_ke_jia_ze_yao_seq',
          formulaName: '八卦加则法-爻序法',
          baseNumber: baseNumber,
          tiaoWenNumber: yaoSeqResult.tiaoWenNumber,
          tiaoWenContent: yaoSeqContent,
          calculationDetail:
              '${yaoSeqResult.description}\n公式: ${yaoSeqResult.formula}\n卦象: ${guaResult.fullGuaName}',
        ),
      );
    }

    // 添加纳甲法结果
    final naJiaContent = tiaoWenContentMap[naJiaResult.tiaoWenNumber];
    if (naJiaContent != null) {
      results.add(
        TiaoWenResult(
          groupId: 'kao_ke_jia_ze_na_jia',
          formulaName: '八卦加则法-纳甲法',
          baseNumber: baseNumber,
          tiaoWenNumber: naJiaResult.tiaoWenNumber,
          tiaoWenContent: naJiaContent,
          calculationDetail:
              '${naJiaResult.description}\n公式: ${naJiaResult.formula}\n卦象: ${guaResult.fullGuaName}',
        ),
      );
    }

    return results;
  }

  /// 使用卦爻干支和数法计算条文
  ///
  /// 使用 GuaYaoGanZhiHeStrategy 的静态方法从64卦计算两种纳甲方案的条文
  Future<List<TiaoWenResult>> _calculateByGanZhiHe({
    required int baseNumber,
    required GuaCalculationResult guaResult,
    required EightChars eightChars,
  }) async {
    // 从上下卦数字获取 Enum64Gua
    final gua64 = GuaCalculationHelper.getEnum64Gua(
      guaResult.shangGuaNumber,
      guaResult.xiaGuaNumber,
    );

    if (gua64 == null) {
      // 如果无法转换为64卦，返回空列表
      return [];
    }

    // 判断年干阴阳（用于年干阴阳纳甲法）
    final isYangYear = eightChars.year.gan.isYang;

    // 使用年干阴阳纳甲法计算
    final yearGanResult = GuaYaoGanZhiHeStrategy.calculateFromGua64(
      gua64,
      GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
      isYangYear,
    );

    // 使用传统内外卦纳甲法计算
    final innerOuterResult = GuaYaoGanZhiHeStrategy.calculateFromGua64(
      gua64,
      GuaYaoGanZhiHeNaJiaMethod.innerOuterGua,
      null, // 内外卦法不需要年干阴阳
    );

    // 批量查询条文内容
    final tiaoWenNumbers = [
      yearGanResult.tiaoWenNumber,
      innerOuterResult.tiaoWenNumber,
    ];

    final tiaoWenContentMap =
        await _tiaoWenRepository.getTiaoWenContentByNumbers(tiaoWenNumbers);

    // 构建结果列表
    final results = <TiaoWenResult>[];

    // 添加年干阴阳纳甲法结果
    final yearGanContent = tiaoWenContentMap[yearGanResult.tiaoWenNumber];
    if (yearGanContent != null) {
      results.add(
        TiaoWenResult(
          groupId: 'kao_ke_gua_yao_gan_zhi_he_year_gan',
          formulaName: '卦爻干支和数法-年干阴阳纳甲',
          baseNumber: baseNumber,
          tiaoWenNumber: yearGanResult.tiaoWenNumber,
          tiaoWenContent: yearGanContent,
          calculationDetail:
              '${yearGanResult.description}\n公式: ${yearGanResult.formula}\n卦象: ${guaResult.fullGuaName}\n年干: ${eightChars.year.gan.name}(${isYangYear ? "阳" : "阴"}年)',
        ),
      );
    }

    // 添加传统内外卦纳甲法结果
    final innerOuterContent = tiaoWenContentMap[innerOuterResult.tiaoWenNumber];
    if (innerOuterContent != null) {
      results.add(
        TiaoWenResult(
          groupId: 'kao_ke_gua_yao_gan_zhi_he_inner_outer',
          formulaName: '卦爻干支和数法-传统内外卦纳甲',
          baseNumber: baseNumber,
          tiaoWenNumber: innerOuterResult.tiaoWenNumber,
          tiaoWenContent: innerOuterContent,
          calculationDetail:
              '${innerOuterResult.description}\n公式: ${innerOuterResult.formula}\n卦象: ${guaResult.fullGuaName}',
        ),
      );
    }

    return results;
  }
}
