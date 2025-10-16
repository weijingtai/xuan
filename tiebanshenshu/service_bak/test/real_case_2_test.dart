import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/constant/constants.dart' as Constants;
import 'package:tiebanshenshu/domain/six_yao_gua.dart';
import 'package:tiebanshenshu/service/real_case_2.dart';
import 'package:tiebanshenshu/utils/tiao_wen_calculator.dart';

void main() {
  group('Real Case 2 Tests', () {
    test('定刻取数法测试', () {
      // 预期结果: [6856, 7240, 7432, 7528, 7624, 7720, 7816, 8008, 8392]
      const String inputTimeZhi = "卯";
      final List<int> keList = Constants.eightKeNumberMapper[inputTimeZhi]!;
      final TiaoWenNumberCalculationStrategy strategy =
          TiaoWenNumberCalculationStrategy(birthTimeZhi: inputTimeZhi);

      for (int i = 0; i < 8; i++) {
        final int keNumber = keList[i];
        final bool isAccepted = i == 7; // 选择第8个刻
        final KeInfo keInfo = KeInfo(
          timeZhi: inputTimeZhi,
          keOrderName: Constants.keNameList[i],
          number: keNumber,
          isAccepted: isAccepted,
        );
        strategy.appendKeInfo(keInfo);
        if (isAccepted) {
          break;
        }
      }

      final SixYaoGua sixYaoGua = strategy.baseGuaToSixYaoGua;
      final int baseNumber = sixYaoGua.getTiaowenNumberByJiaze();
      final List<int> tiaowenNumberList =
          TiaowenCalculator.calculateTiaowenNumberList48(
            baseNumber,
            withBaseNumber: true,
          );

      // 验证结果
      expect(
        tiaowenNumberList,
        equals([6856, 7240, 7432, 7528, 7624, 7720, 7816, 8008, 8392]),
      );
    });

    test('KeInfo 类测试', () {
      const KeInfo keInfo = KeInfo(
        timeZhi: "卯",
        keOrderName: "初刻",
        number: 1234,
        isAccepted: true,
      );

      expect(keInfo.timeZhi, equals("卯"));
      expect(keInfo.keOrderName, equals("初刻"));
      expect(keInfo.number, equals(1234));
      expect(keInfo.isAccepted, isTrue);
    });

    test('TiaoWenNumberCalculationStrategy 类测试', () {
      final TiaoWenNumberCalculationStrategy strategy =
          TiaoWenNumberCalculationStrategy(birthTimeZhi: "卯");

      expect(strategy.birthTimeZhi, equals("卯"));
      expect(strategy.baseNumber, equals(-1));
      expect(strategy.baseGua, isNull);
      expect(strategy.keInfoList, isEmpty);

      const KeInfo keInfo = KeInfo(
        timeZhi: "卯",
        keOrderName: "初刻",
        number: 1234,
        isAccepted: true,
      );

      strategy.appendKeInfo(keInfo);

      expect(strategy.keInfoList.length, equals(1));
      expect(strategy.baseNumber, equals(1234));
      expect(strategy.baseGua, isNotNull);
    });
  });
}
