import 'package:common/shared/enums/enum_hou_tian_gua.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/pure_six_yao_gua.dart';

void main() {
  group("卦测试", () {
    test("错卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      expect(gua.cuo, equals(Gua64Enum.di_lei_fu));
    });
    test("互卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      expect(gua.hu, equals(Gua64Enum.qian_wei_tian));
    });

    test("互卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Xun, Enum8Gua.Dui);
      expect(gua.hu, equals(Gua64Enum.shan_lei_yi));
    });

    test("综卦", () {
      final gua = PureSixYaoGua.by8Gua(Enum8Gua.Qian, Enum8Gua.Xun);

      expect(gua.zong, equals(Gua64Enum.ze_tian_guai));
    });
  });
}
