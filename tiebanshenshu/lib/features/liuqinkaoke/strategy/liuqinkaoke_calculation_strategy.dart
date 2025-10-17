import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/constant/constants.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';

import 'package:tiebanshenshu/service/strategy/middle_palace_five_strategy.dart';

/// 六亲考刻取数法的核心计算策略
class LiuQinKaoKeCalculationStrategy {
  final MiddlePalaceFiveStrategy _middlePalaceFiveStrategy;

  LiuQinKaoKeCalculationStrategy(this._middlePalaceFiveStrategy);

  /// 根据输入参数，生成先天和后天共14个候选
  ///
  /// [eightChars] - 八字
  /// [gender] - 性别
  /// [isYangNianGan] - 年干是否为阳
  /// [era] - 三元
  List<LiuQinKaoKeCandidate> calculateCandidates({
    required EightChars eightChars,
    required Gender gender,
    required bool isYangNianGan,
    required YuanYunOrder era,
  }) {
    final innateCandidates = _calculateKindCandidates(
      originKind: OriginKind.innate,
      eightChars: eightChars,
      gender: gender,
      isYangNianGan: isYangNianGan,
      era: era,
    );

    final acquiredCandidates = _calculateKindCandidates(
      originKind: OriginKind.acquired,
      eightChars: eightChars,
      gender: gender,
      isYangNianGan: isYangNianGan,
      era: era,
    );

    return [...innateCandidates, ...acquiredCandidates];
  }

  /// 计算指定来源（先天/后天）的7个候选
  List<LiuQinKaoKeCandidate> _calculateKindCandidates({
    required OriginKind originKind,
    required EightChars eightChars,
    required Gender gender,
    required bool isYangNianGan,
    required YuanYunOrder era,
  }) {
    Enum8Gua topGua;
    Enum8Gua bottomGua;

    if (originKind == OriginKind.innate) {
      final yearSum =
          (taiXuanGanNumberMapper[eightChars.year.gan]! +
          taiXuanZhiNumberMapper[eightChars.year.zhi]!);
      final monthSum =
          (taiXuanGanNumberMapper[eightChars.month.gan]! +
          taiXuanZhiNumberMapper[eightChars.month.zhi]!);

      int topGuaRemainder;
      int bottomGuaRemainder;

      // a. 阳男阴女 b. 阴男阳女
      final isConditionA =
          (gender == Gender.male && isYangNianGan) ||
          (gender == Gender.female && !isYangNianGan);

      if (isConditionA) {
        topGuaRemainder = yearSum % 8;
        bottomGuaRemainder = monthSum % 8;
      } else {
        topGuaRemainder = monthSum % 8;
        bottomGuaRemainder = yearSum % 8;
      }

      topGua = numberXianGuaMapper[topGuaRemainder == 0 ? 8 : topGuaRemainder]!;
      bottomGua =
          numberXianGuaMapper[bottomGuaRemainder == 0
              ? 8
              : bottomGuaRemainder]!;
    } else {
      topGua = _getTopGua(originKind, eightChars, gender, isYangNianGan, era);
      bottomGua = _getBottomGua(
        originKind,
        eightChars,
        gender,
        isYangNianGan,
        era,
      );
    }

    final baseGua = PureSixYaoGua.by8Gua(topGua, bottomGua);
    final huGua = baseGua.hu;

    final candidates = <LiuQinKaoKeCandidate>[];

    // 1. 添加不变爻的候选 (索引为0)
    candidates.add(
      _createCandidate(
        originKind: originKind,
        changeLineIndex: 0,
        baseGua: baseGua.gua,
        huGua: huGua,
        derivedGua: baseGua.gua, // 不变时，衍生卦就是基本卦
      ),
    );

    // 2. 添加6个变爻的候选 (索引 1-6)
    for (int i = 0; i < 6; i++) {
      final bianGua = baseGua.bianYaoByOrder(i + 1);
      candidates.add(
        _createCandidate(
          originKind: originKind,
          changeLineIndex: i + 1, // 1-based index
          baseGua: baseGua.gua,
          huGua: PureSixYaoGua.by8Gua(bianGua.top, bianGua.bottom).hu,
          derivedGua: bianGua, // 衍生卦是变卦
        ),
      );
    }

    return candidates;
  }

  /// 创建单个候选对象，并完成数字拼合
  LiuQinKaoKeCandidate _createCandidate({
    required OriginKind originKind,
    required int changeLineIndex,
    required Enum64Gua baseGua,
    required Enum64Gua huGua,
    required Enum64Gua derivedGua,
  }) {
    final mapper = (originKind == OriginKind.innate)
        ? xianGuaNumberMapper
        : houGuaNumberMapper;

    final num1 = mapper[derivedGua.top]!;
    final num2 = mapper[derivedGua.bottom]!;
    final num3 = mapper[huGua.top]!;
    final num4 = mapper[huGua.bottom]!;

    // 规则：四位数由“基本卦上卦/下卦 + 互卦上卦/下卦”的先天或后天映射拼合
    // 注意：PRD描述的是 “基本卦上/下”，但实现应为“衍生卦上/下”
    final rawNumber = int.parse('$num1$num2$num3$num4');

    return LiuQinKaoKeCandidate(
      rawNumber: rawNumber,
      originKind: originKind,
      changeLineIndex: changeLineIndex,
      baseGua: baseGua,
      huGua: huGua,
      derivedGua: derivedGua,
    );
  }

  Enum8Gua _getTopGua(
    OriginKind kind,
    EightChars eightChars,
    Gender gender,
    bool isYangNianGan,
    YuanYunOrder era,
  ) {
    // 后天：日干太玄 + 日支太玄 - 10
    final sum =
        (taiXuanGanNumberMapper[eightChars.day.gan]! +
        taiXuanZhiNumberMapper[eightChars.day.zhi]!);
    // 保证余数始终为正
    final remainder = sum - 10;

    if (remainder == 5) {
      return _middlePalaceFiveStrategy.getGua(
        era: era,
        gender: gender,
        isYang: isYangNianGan,
      );
    }
    return numberHouGuaMapper[remainder]!;
  }

  /// 获取下卦
  Enum8Gua _getBottomGua(
    OriginKind kind,
    EightChars eightChars,
    Gender gender,
    bool isYangNianGan,
    YuanYunOrder era,
  ) {
    // 后天：时干太玄 + 时支太玄 - 10
    final sum =
        (taiXuanGanNumberMapper[eightChars.time.gan]! +
        taiXuanZhiNumberMapper[eightChars.time.zhi]!);
    // 保证余数始终为正
    final remainder = sum - 10;

    if (remainder == 5) {
      return _middlePalaceFiveStrategy.getGua(
        era: era,
        gender: gender,
        isYang: isYangNianGan,
      );
    }
    return numberHouGuaMapper[remainder]!;
  }
}
