import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/service/strategy/ba_gua_jia_ze_strategy.dart';

/// 八卦加则法人工规格测试
///
/// 根据手工计算的标准结果验证算法正确性
void main() {
  group('八卦加则法 - 爻序法人工规格测试', () {
    test('地山谦 应该得到 2472', () {
      // Arrange
      final gua64 = Enum64Gua.di_shan_qian; // 地山谦 (坤上艮下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 2472);
      expect(result.methodName, '爻序法');

      // ignore: avoid_print
      print('地山谦(爻序法): ${result.summary}');
    });

    test('雷天大壮 应该得到 3384', () {
      // Arrange
      final gua64 = Enum64Gua.lei_tian_da_zhuang; // 雷天大壮 (震上乾下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 3384);
      expect(result.methodName, '爻序法');

      // ignore: avoid_print
      print('雷天大壮(爻序法): ${result.summary}');
    });

    test('泽山咸 应该得到 7352', () {
      // Arrange
      final gua64 = Enum64Gua.ze_shan_xian; // 泽山咸 (兑上艮下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 7352);
      expect(result.methodName, '爻序法');

      // ignore: avoid_print
      print('泽山咸(爻序法): ${result.summary}');
    });

    test('山火贲 应该得到 8351', () {
      // Arrange
      final gua64 = Enum64Gua.shan_huo_bi; // 山火贲 (艮上离下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 8351);
      expect(result.methodName, '爻序法');

      // ignore: avoid_print
      print('山火贲(爻序法): ${result.summary}');
    });
  });

  group('八卦加则法 - 纳甲法人工规格测试', () {
    test('地山谦 应该得到 2712', () {
      // Arrange
      final gua64 = Enum64Gua.di_shan_qian; // 地山谦 (坤上艮下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 2712);
      expect(result.methodName, '纳甲法');

      // ignore: avoid_print
      print('地山谦(纳甲法): ${result.summary}');
    });

    test('雷天大壮 应该得到 3624', () {
      // Arrange
      final gua64 = Enum64Gua.lei_tian_da_zhuang; // 雷天大壮 (震上乾下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 3624);
      expect(result.methodName, '纳甲法');

      // ignore: avoid_print
      print('雷天大壮(纳甲法): ${result.summary}');
    });

    test('泽山咸 应该得到 7802', () {
      // Arrange
      final gua64 = Enum64Gua.ze_shan_xian; // 泽山咸 (兑上艮下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 7802);
      expect(result.methodName, '纳甲法');

      // ignore: avoid_print
      print('泽山咸(纳甲法): ${result.summary}');
    });

    test('山火贲 应该得到 8531', () {
      // Arrange
      final gua64 = Enum64Gua.shan_huo_bi; // 山火贲 (艮上离下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      expect(result.tiaoWenNumber, 8531);
      expect(result.methodName, '纳甲法');

      // ignore: avoid_print
      print('山火贲(纳甲法): ${result.summary}');
    });
  });

  group('八卦加则法 - 综合验证', () {
    test('同一卦象的两种方法应该产生不同结果', () {
      final testCases = [
        Enum64Gua.di_shan_qian,
        Enum64Gua.lei_tian_da_zhuang,
        Enum64Gua.ze_shan_xian,
        Enum64Gua.shan_huo_bi,
      ];

      for (final gua in testCases) {
        final yaoSeq = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua);
        final naJia = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua);

        // 两种方法的结果应该不同
        expect(yaoSeq.tiaoWenNumber, isNot(equals(naJia.tiaoWenNumber)),
            reason: '${gua.name}的两种方法应该产生不同结果');

        // 但使用相同的上下卦
        expect(yaoSeq.upperGua, naJia.upperGua);
        expect(yaoSeq.lowerGua, naJia.lowerGua);
      }
    });

    test('验证结果数据完整性', () {
      final gua = Enum64Gua.di_shan_qian;
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua);

      // 验证所有字段都已填充
      expect(result.pureSixYaoGua, isNotNull);
      expect(result.upperGua, isNotNull);
      expect(result.lowerGua, isNotNull);
      expect(result.upperGuaNumber, greaterThan(0));
      expect(result.lowerGuaNumber, greaterThan(0));
      expect(result.yaoSum, greaterThan(0));
      expect(result.formula, isNotEmpty);
      expect(result.tiaoWenNumber, greaterThan(0));
      expect(result.tiaoWenNumber, lessThanOrEqualTo(9999));
      expect(result.methodName, isNotEmpty);
      expect(result.description, isNotEmpty);
    });
  });
}
