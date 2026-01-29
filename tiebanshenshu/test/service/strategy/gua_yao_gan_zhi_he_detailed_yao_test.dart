import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';
import 'package:tiebanshenshu/service/strategy/gua_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/domain/models/gua_yao_gan_zhi_he_base_number_model.dart';

/// Detailed Yao-by-Yao Tests for GuaYaoGanZhiHe
///
/// Verifies each yao's NaJia Gan-Zhi assignment for all four pillars
/// Test case: GUI_WEI GUI_HAI REN_WU WU_SHEN
void main() {
  late GuaYaoGanZhiHeStrategy strategy;

  setUp(() {
    strategy = GuaYaoGanZhiHeStrategy();
  });

  group('Detailed Yao Tests - GUI_WEI GUI_HAI REN_WU WU_SHEN', () {
    late EightChars testFourZhu;
    late GuaYaoGanZhiHeStrategyParams params;
    late BaseNumberModelResult result;

    setUp(() {
      testFourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("癸未")!,
        month: JiaZi.getFromGanZhiValue("癸亥")!,
        day: JiaZi.getFromGanZhiValue("壬午")!,
        time: JiaZi.getFromGanZhiValue("戊申")!,
      );

      params = GuaYaoGanZhiHeStrategyParams(
        eightChars: testFourZhu,
        naJiaMethod: GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
      );

      result = strategy.calculate(params);
    });

    test('Year Pillar - Di Shan Qian (地山谦) - Yao Details', () {
      final yearModel = result.baseNumbers[0] as GuaYaoGanZhiHeBaseNumberModel;

      expect(yearModel.ganzhi.name, equals('癸未'));
      expect(yearModel.gua64.name, equals('谦'));
      expect(yearModel.upperGua, equals(Enum8Gua.Kun));
      expect(yearModel.lowerGua, equals(Enum8Gua.Gen));

      // Yaos from bottom to top (positions 0-5)
      // Expected (top->bottom): 癸酉 癸亥 癸丑 丙申 丙午 丙辰
      // So (bottom->top): 丙辰 丙午 丙申 癸丑 癸亥 癸酉
      final yaos = yearModel.yaoDetails;

      expect(
        yaos[0].naTianGan,
        equals(TianGan.BING),
        reason: 'Yao 0 should be BING',
      );
      expect(
        yaos[0].naDiZhi,
        equals(DiZhi.CHEN),
        reason: 'Yao 0 should be CHEN',
      );

      expect(
        yaos[1].naTianGan,
        equals(TianGan.BING),
        reason: 'Yao 1 should be BING',
      );
      expect(yaos[1].naDiZhi, equals(DiZhi.WU), reason: 'Yao 1 should be WU');

      expect(
        yaos[2].naTianGan,
        equals(TianGan.BING),
        reason: 'Yao 2 should be BING',
      );
      expect(
        yaos[2].naDiZhi,
        equals(DiZhi.SHEN),
        reason: 'Yao 2 should be SHEN',
      );

      expect(
        yaos[3].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 3 should be GUI',
      );
      expect(
        yaos[3].naDiZhi,
        equals(DiZhi.CHOU),
        reason: 'Yao 3 should be CHOU',
      );

      expect(
        yaos[4].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 4 should be GUI',
      );
      expect(yaos[4].naDiZhi, equals(DiZhi.HAI), reason: 'Yao 4 should be HAI');

      expect(
        yaos[5].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 5 should be GUI',
      );
      expect(yaos[5].naDiZhi, equals(DiZhi.YOU), reason: 'Yao 5 should be YOU');

      expect(yearModel.baseNumber, equals(3342));
    });

    test('Month Pillar - Di Shui Shi (地水师) - Yao Details', () {
      final monthModel = result.baseNumbers[1] as GuaYaoGanZhiHeBaseNumberModel;

      expect(monthModel.ganzhi.name, equals('癸亥'));
      expect(monthModel.gua64.name, equals('师'));
      expect(monthModel.upperGua, equals(Enum8Gua.Kun));
      expect(monthModel.lowerGua, equals(Enum8Gua.Kan));

      // Expected (top->bottom): 癸酉 癸亥 癸丑 戊午 戊辰 戊寅
      // So (bottom->top): 戊寅 戊辰 戊午 癸丑 癸亥 癸酉
      final yaos = monthModel.yaoDetails;

      expect(
        yaos[0].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 0 should be WU',
      );
      expect(yaos[0].naDiZhi, equals(DiZhi.YIN), reason: 'Yao 0 should be YIN');

      expect(
        yaos[1].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 1 should be WU',
      );
      expect(
        yaos[1].naDiZhi,
        equals(DiZhi.CHEN),
        reason: 'Yao 1 should be CHEN',
      );

      expect(
        yaos[2].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 2 should be WU',
      );
      expect(yaos[2].naDiZhi, equals(DiZhi.WU), reason: 'Yao 2 should be WU');

      expect(
        yaos[3].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 3 should be GUI',
      );
      expect(
        yaos[3].naDiZhi,
        equals(DiZhi.CHOU),
        reason: 'Yao 3 should be CHOU',
      );

      expect(
        yaos[4].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 4 should be GUI',
      );
      expect(yaos[4].naDiZhi, equals(DiZhi.HAI), reason: 'Yao 4 should be HAI');

      expect(
        yaos[5].naTianGan,
        equals(TianGan.GUI),
        reason: 'Yao 5 should be GUI',
      );
      expect(yaos[5].naDiZhi, equals(DiZhi.YOU), reason: 'Yao 5 should be YOU');

      expect(monthModel.baseNumber, equals(3326));
    });

    test('Day Pillar - Tian Huo Tong Ren (天火同人) - Yao Details', () {
      final dayModel = result.baseNumbers[2] as GuaYaoGanZhiHeBaseNumberModel;

      expect(dayModel.ganzhi.name, equals('壬午'));
      expect(dayModel.gua64.name, equals('同人'));
      expect(dayModel.upperGua, equals(Enum8Gua.Qian));
      expect(dayModel.lowerGua, equals(Enum8Gua.Li));

      // Expected (top->bottom): 壬戌 壬申 壬午 己亥 己丑 己卯
      // So (bottom->top): 己卯 己丑 己亥 壬午 壬申 壬戌
      final yaos = dayModel.yaoDetails;

      expect(
        yaos[0].naTianGan,
        equals(TianGan.JI),
        reason: 'Yao 0 should be JI',
      );
      expect(yaos[0].naDiZhi, equals(DiZhi.MAO), reason: 'Yao 0 should be MAO');

      expect(
        yaos[1].naTianGan,
        equals(TianGan.JI),
        reason: 'Yao 1 should be JI',
      );
      expect(
        yaos[1].naDiZhi,
        equals(DiZhi.CHOU),
        reason: 'Yao 1 should be CHOU',
      );

      expect(
        yaos[2].naTianGan,
        equals(TianGan.JI),
        reason: 'Yao 2 should be JI',
      );
      expect(yaos[2].naDiZhi, equals(DiZhi.HAI), reason: 'Yao 2 should be HAI');

      expect(
        yaos[3].naTianGan,
        equals(TianGan.REN),
        reason: 'Yao 3 should be REN',
      );
      expect(yaos[3].naDiZhi, equals(DiZhi.WU), reason: 'Yao 3 should be WU');

      expect(
        yaos[4].naTianGan,
        equals(TianGan.REN),
        reason: 'Yao 4 should be REN',
      );
      expect(
        yaos[4].naDiZhi,
        equals(DiZhi.SHEN),
        reason: 'Yao 4 should be SHEN',
      );

      expect(
        yaos[5].naTianGan,
        equals(TianGan.REN),
        reason: 'Yao 5 should be REN',
      );
      expect(yaos[5].naDiZhi, equals(DiZhi.XU), reason: 'Yao 5 should be XU');

      expect(dayModel.baseNumber, equals(3945));
    });

    test('Time Pillar - Shui Tian Xu (水天需) - Yao Details', () {
      final timeModel = result.baseNumbers[3] as GuaYaoGanZhiHeBaseNumberModel;

      expect(timeModel.ganzhi.name, equals('戊申'));
      expect(timeModel.gua64.name, equals('需'));
      expect(timeModel.upperGua, equals(Enum8Gua.Kan));
      expect(timeModel.lowerGua, equals(Enum8Gua.Qian));

      // Expected (top->bottom): 戊子 戊戌 戊申 甲辰 甲寅 甲子
      // So (bottom->top): 甲子 甲寅 甲辰 戊申 戊戌 戊子
      final yaos = timeModel.yaoDetails;

      expect(
        yaos[0].naTianGan,
        equals(TianGan.JIA),
        reason: 'Yao 0 should be JIA',
      );
      expect(yaos[0].naDiZhi, equals(DiZhi.ZI), reason: 'Yao 0 should be ZI');

      expect(
        yaos[1].naTianGan,
        equals(TianGan.JIA),
        reason: 'Yao 1 should be JIA',
      );
      expect(yaos[1].naDiZhi, equals(DiZhi.YIN), reason: 'Yao 1 should be YIN');

      expect(
        yaos[2].naTianGan,
        equals(TianGan.JIA),
        reason: 'Yao 2 should be JIA',
      );
      expect(
        yaos[2].naDiZhi,
        equals(DiZhi.CHEN),
        reason: 'Yao 2 should be CHEN',
      );

      expect(
        yaos[3].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 3 should be WU',
      );
      expect(
        yaos[3].naDiZhi,
        equals(DiZhi.SHEN),
        reason: 'Yao 3 should be SHEN',
      );

      expect(
        yaos[4].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 4 should be WU',
      );
      expect(yaos[4].naDiZhi, equals(DiZhi.XU), reason: 'Yao 4 should be XU');

      expect(
        yaos[5].naTianGan,
        equals(TianGan.WU),
        reason: 'Yao 5 should be WU',
      );
      expect(yaos[5].naDiZhi, equals(DiZhi.ZI), reason: 'Yao 5 should be ZI');

      expect(timeModel.baseNumber, equals(2648));
    });

    test('All four pillars should produce expected base numbers', () {
      final yearModel = result.baseNumbers[0] as GuaYaoGanZhiHeBaseNumberModel;
      final monthModel = result.baseNumbers[1] as GuaYaoGanZhiHeBaseNumberModel;
      final dayModel = result.baseNumbers[2] as GuaYaoGanZhiHeBaseNumberModel;
      final timeModel = result.baseNumbers[3] as GuaYaoGanZhiHeBaseNumberModel;

      expect(
        yearModel.baseNumber,
        equals(3342),
        reason: 'Year pillar should be 3342',
      );
      expect(
        monthModel.baseNumber,
        equals(3326),
        reason: 'Month pillar should be 3326',
      );
      expect(
        dayModel.baseNumber,
        equals(3945),
        reason: 'Day pillar should be 3945',
      );
      expect(
        timeModel.baseNumber,
        equals(2648),
        reason: 'Time pillar should be 2648',
      );
    });
  });
}
