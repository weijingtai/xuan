import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_3.dart';

void main() {
  group('Real Case 3 Tests', () {
    test('四柱天干取数法测试', () {
      final fourZhu = FourZhu(
        yearGanzhi: "癸卯",
        monthGanzhi: "癸巳",
        dayGanzhi: "甲子",
        timeGanzhi: "丁酉",
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      final result = strategy.getTiaoWenNumberList();

      // 验证基本数计算：月(癸0)、日(甲1)、时(丁7)、年(癸0) = 0170
      expect(strategy.baseNumber, equals(170));

      // 验证条文数字列表
      final expected = [170, 266, 362, 458, 554, 650, 746, 842];
      expect(result, equals(expected));
    });

    test('天干数字映射测试', () {
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["甲"], equals(1));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["乙"], equals(6));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["丙"], equals(2));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["丁"], equals(7));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["戊"], equals(3));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["己"], equals(8));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["庚"], equals(4));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["辛"], equals(9));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["壬"], equals(5));
      expect(TiaoWenNumberCalculationStrategy.ganNumberMapper["癸"], equals(0));
    });
  });
}
