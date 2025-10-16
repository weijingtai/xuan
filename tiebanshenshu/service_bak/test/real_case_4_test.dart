import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/real_case_4.dart';

void main() {
  group('Real Case 4 Tests', () {
    test('日柱变卦取数法测试', () {
      final strategy = TiaoWenNumberCalculationStrategy("丁酉");

      // 验证基本卦计算
      // 丁 -> 兑, 酉 -> 乾, 所以基本卦为 "乾兑"
      expect(strategy.baseGua, equals("乾兑"));

      // 验证基本数计算
      // 第一卦：乾(后天6)兑(后天3) -> 63
      // 第二卦（互卦）：需要根据互卦算法计算先天数
      expect(strategy.baseNumber, equals(6753));

      // 验证条文数字列表
      final result = strategy.getTiaoWenNumberList();
      final expected = [6369, 6465, 6561, 6657, 6753, 6849, 6945, 7041, 7137];
      expect(result, equals(expected));
    });

    test('不同日柱测试', () {
      // 测试其他日柱
      final strategy1 = TiaoWenNumberCalculationStrategy("甲子");
      expect(strategy1.dayGanzhi, equals("甲子"));

      final strategy2 = TiaoWenNumberCalculationStrategy("乙丑");
      expect(strategy2.dayGanzhi, equals("乙丑"));
    });
  });
}
