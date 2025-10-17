import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/service/strategy/middle_palace_five_strategy.dart';
import 'package:timezone/data/latest.dart';

void main() {
  initializeTimeZones();
  group('LiuQinKaoKeCalculationStrategy', () {
    late LiuQinKaoKeCalculationStrategy strategy;

    setUp(() {
      strategy = LiuQinKaoKeCalculationStrategy(
        DefaultMiddlePalaceFiveStrategy(),
      );
    });

    test(
      'calculateCandidates should generate 14 candidates (7 innate, 7 acquired)',
      () {
        // Arrange
        final devData = DevConstant.dev_usa;
        final fourZhu = devData.standeredChineseInfo.eightChars;
        const gender = Gender.male;
        // 年干为乙，属阴
        const isYangNianGan = false;

        // Act
        final candidates = strategy.calculateCandidates(
          eightChars: fourZhu,
          gender: gender,
          isYangNianGan: isYangNianGan,
          era: YuanYunOrder.upper,
        );

        // Assert
        expect(candidates.length, 14);

        final innateCandidates = candidates
            .where((c) => c.originKind == OriginKind.innate)
            .toList();
        final acquiredCandidates = candidates
            .where((c) => c.originKind == OriginKind.acquired)
            .toList();

        expect(innateCandidates.length, 7);
        expect(acquiredCandidates.length, 7);

        // Check that changeLineIndex is correct (0 for base, 1-6 for changes)
        final innateIndexes = innateCandidates
            .map((c) => c.changeLineIndex)
            .toSet();
        final acquiredIndexes = acquiredCandidates
            .map((c) => c.changeLineIndex)
            .toSet();

        expect(innateIndexes, {0, 1, 2, 3, 4, 5, 6});
        expect(acquiredIndexes, {0, 1, 2, 3, 4, 5, 6});
      },
    );

    // 在这里可以添加更多测试用例，例如验证一个具体数字的计算是否正确
    test('should produce correct numbers for the given Yin Male test case', () {
      // Arrange
      final eightChars = EightChars(
        year: JiaZi.GUI_SI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.DING_YOU,
        time: JiaZi.GUI_MAO,
      );
      const gender = Gender.male;
      const isYangNianGan = false; // 癸为阴

      // Act
      final candidates = strategy.calculateCandidates(
        eightChars: eightChars,
        gender: gender,
        isYangNianGan: isYangNianGan,
        era: YuanYunOrder.lower,
      );

      // Assert Innate (先天)
      final innateBase = candidates.firstWhere(
        (c) => c.originKind == OriginKind.innate && c.changeLineIndex == 0,
      );
      final innateChange3 = candidates.firstWhere(
        (c) => c.originKind == OriginKind.innate && c.changeLineIndex == 3,
      );

      expect(innateBase.baseGua, Enum64Gua.ze_tian_guai, reason: "先天基本卦应为泽天夬");
      expect(
        PureSixYaoGua.by8Gua(
          innateBase.baseGua.top,
          innateBase.baseGua.bottom,
        ).hu,
        Enum64Gua.qian_wei_tian,
        reason: "互卦 乾为天",
      );
      expect(innateBase.huGua, Enum64Gua.qian_wei_tian, reason: "先天互卦应为乾为天");
      expect(innateBase.rawNumber, 2111, reason: "先天基础数应为2111");
      expect(
        PureSixYaoGua.by8Gua(
          innateBase.baseGua.top,
          innateBase.baseGua.bottom,
        ).bianYaoByOrder(3),
        Enum64Gua.dui_wei_ze,
        reason: "应该为 兑为泽",
      );
      expect(innateChange3.derivedGua, Enum64Gua.dui_wei_ze, reason: "应该变 兑为泽");
      expect(
        innateChange3.huGua,
        Enum64Gua.feng_huo_jia_ren,
        reason: "应该为 风火家人",
      );
      expect(innateChange3.rawNumber, 2253, reason: "先天三爻变后数应为2253");

      // Assert Acquired (后天)
      final acquiredBase = candidates.firstWhere(
        (c) => c.originKind == OriginKind.acquired && c.changeLineIndex == 0,
      );
      final acquiredChange1 = candidates.firstWhere(
        (c) => c.originKind == OriginKind.acquired && c.changeLineIndex == 1,
      );

      expect(acquiredBase.baseGua, Enum64Gua.di_shui_shi, reason: "后天基本卦应为地水师");
      expect(acquiredBase.huGua, Enum64Gua.di_lei_fu, reason: "后天互卦应为地雷复");
      expect(acquiredBase.rawNumber, 2123, reason: "后天基础数应为2123");
      expect(acquiredChange1.rawNumber, 2723, reason: "后天初爻变后数应为2723");
    });
  });
}
