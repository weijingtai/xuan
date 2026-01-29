import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/gua_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/domain/models/gua_yao_gan_zhi_he_base_number_model.dart';

void main() {
  late GuaYaoGanZhiHeStrategy strategy;

  setUp(() {
    strategy = GuaYaoGanZhiHeStrategy();
  });

  group('GUI_WEI case: 3342 3326 3945 2648', () {
    test('Year pillar GUI_WEI should produce 3342', () {
      final testFourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("癸未")!,
        month: JiaZi.getFromGanZhiValue("癸亥")!,
        day: JiaZi.getFromGanZhiValue("壬午")!,
        time: JiaZi.getFromGanZhiValue("戊申")!,
      );

      final params = GuaYaoGanZhiHeStrategyParams(
        eightChars: testFourZhu,
        naJiaMethod: GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
      );

      final result = strategy.calculate(params);

      expect(result.hasError, false);
      expect(result.baseNumbers.length, equals(4));

      final yearModel = result.baseNumbers[0] as GuaYaoGanZhiHeBaseNumberModel;
      final monthModel = result.baseNumbers[1] as GuaYaoGanZhiHeBaseNumberModel;
      final dayModel = result.baseNumbers[2] as GuaYaoGanZhiHeBaseNumberModel;
      final timeModel = result.baseNumbers[3] as GuaYaoGanZhiHeBaseNumberModel;

      print('\n=== Year Pillar DEBUG ===');
      print('GanZhi: ${yearModel.ganzhi.name}');
      print('Gua64: ${yearModel.gua64.name}');
      print(
        'Upper: ${yearModel.upperGua.name}, Lower: ${yearModel.lowerGua.name}',
      );
      print(
        'LowerSum: ${yearModel.lowerGuaSum}, UpperSum: ${yearModel.upperGuaSum}',
      );
      print('Formula: ${yearModel.formula}');
      print('BaseNumber: ${yearModel.baseNumber}');
      print('\nYaoDetails (with position check):');
      int lowerCalc = 0;
      int upperCalc = 0;
      for (int i = 0; i < yearModel.yaoDetails.length; i++) {
        final yao = yearModel.yaoDetails[i];
        final guaType = i < 3 ? 'LOWER' : 'UPPER';
        print('  Position $i [$guaType]: ${yao.toString()}');
        if (!yao.isFiltered) {
          if (i < 3)
            lowerCalc += yao.yaoSum;
          else
            upperCalc += yao.yaoSum;
        }
      }
      print('\nManual calculation:');
      print('  Lower sum (positions 0-2, excluding filtered): $lowerCalc');
      print('  Upper sum (positions 3-5, excluding filtered): $upperCalc');
      print(
        '  Result: $upperCalc * 100 + $lowerCalc = ${upperCalc * 100 + lowerCalc}',
      );

      print('\n=== Month Pillar ===');
      print('GanZhi: ${monthModel.ganzhi.name}');
      print('Gua64: ${monthModel.gua64.name}');
      print(
        'Upper: ${monthModel.upperGua.name}, Lower: ${monthModel.lowerGua.name}',
      );
      print('BaseNumber: ${monthModel.baseNumber}');

      print('\n=== Day Pillar ===');
      print('GanZhi: ${dayModel.ganzhi.name}');
      print('Gua64: ${dayModel.gua64.name}');
      print(
        'Upper: ${dayModel.upperGua.name}, Lower: ${dayModel.lowerGua.name}',
      );
      print('BaseNumber: ${dayModel.baseNumber}');

      print('\n=== Time Pillar ===');
      print('GanZhi: ${timeModel.ganzhi.name}');
      print('Gua64: ${timeModel.gua64.name}');
      print(
        'Upper: ${timeModel.upperGua.name}, Lower: ${timeModel.lowerGua.name}',
      );
      print('BaseNumber: ${timeModel.baseNumber}');

      expect(yearModel.baseNumber, equals(3342), reason: 'Year should be 3342');
      expect(
        monthModel.baseNumber,
        equals(3326),
        reason: 'Month should be 3326',
      );
      expect(dayModel.baseNumber, equals(3945), reason: 'Day should be 3945');
      expect(timeModel.baseNumber, equals(2648), reason: 'Time should be 2648');
    });
  });
}
