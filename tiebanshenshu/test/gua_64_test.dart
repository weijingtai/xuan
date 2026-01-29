import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';

void main() {
  group("卦测试", () {
    test("错卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      expect(gua.cuo, equals(Enum64Gua.di_lei_fu));
    });
    test("互卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      expect(gua.hu, equals(Enum64Gua.qian_wei_tian));
    });

    test("互卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Xun, Enum8Gua.Dui);
      expect(gua.hu, equals(Enum64Gua.shan_lei_yi));
    });

    test("综卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);

      expect(gua.zong, equals(Enum64Gua.ze_tian_guai));
    });
  });
}
