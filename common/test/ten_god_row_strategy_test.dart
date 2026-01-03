import 'package:common/enums.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/pillar_content.dart';
import 'package:common/models/row_strategy.dart';
import 'package:common/utils/constant_values_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TenGodRowStrategy', () {
    test('uses gender label for day pillar', () {
      final strategy = TenGodRowStrategy();

      final year = PillarContent(
        id: 'pillar-year',
        pillarType: PillarType.year,
        label: '年',
        jiaZi: JiaZi.JIA_ZI,
        version: '1',
        sourceKind: PillarSourceKind.userInput,
      );
      final day = PillarContent(
        id: 'pillar-day',
        pillarType: PillarType.day,
        label: '日',
        jiaZi: JiaZi.BING_YIN,
        version: '1',
        sourceKind: PillarSourceKind.userInput,
      );

      final maleInput = RowComputationInput(
        pillars: [year, day],
        dayJiaZi: day.jiaZi,
        gender: Gender.male,
      );
      final male = strategy.compute(maleInput).perPillarValues;
      expect(male[day.id], equals(FourZhuText.qianZao));
      expect(
        male[year.id],
        equals(year.jiaZi.tianGan.getTenGods(day.jiaZi.tianGan).name),
      );

      final femaleInput = RowComputationInput(
        pillars: [year, day],
        dayJiaZi: day.jiaZi,
        gender: Gender.female,
      );
      final female = strategy.compute(femaleInput).perPillarValues;
      expect(female[day.id], equals(FourZhuText.kunZao));

      final unknownInput = RowComputationInput(
        pillars: [year, day],
        dayJiaZi: day.jiaZi,
        gender: Gender.unknown,
      );
      final unknown = strategy.compute(unknownInput).perPillarValues;
      expect(unknown[day.id], equals(FourZhuText.riYuan));
    });

    test('computeSingleValue falls back to day text when jiaZi matches day',
        () {
      final strategy = TenGodRowStrategy();
      expect(
        strategy.computeSingleValue(
            JiaZi.BING_YIN, JiaZi.BING_YIN, Gender.male),
        equals(JiaZi.BING_YIN.tianGan.getTenGods(JiaZi.BING_YIN.tianGan).name),
      );
    });
  });
}
