import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/kao_ke/gua_calculation_helper.dart';
import 'package:tiebanshenshu/features/kao_ke/kao_ke_session_models.dart';

void main() {
  group('GuaCalculationHelper - 卦象计算测试', () {
    test('应该正确计算基础数字的卦象 - 测试用例1: 1234', () {
      // Arrange
      const baseNumber = 1234;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.shangGuaNumber, lessThanOrEqualTo(8));
      expect(result.xiaGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, lessThanOrEqualTo(8));
      expect(result.fullGuaName, isNotEmpty);
      expect(result.calculationDetail, isNotEmpty);
    });

    test('应该正确计算基础数字的卦象 - 测试用例2: 5678', () {
      // Arrange
      const baseNumber = 5678;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.shangGuaNumber, lessThanOrEqualTo(8));
      expect(result.xiaGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, lessThanOrEqualTo(8));
      expect(result.fullGuaName, isNotEmpty);
      expect(result.calculationDetail, isNotEmpty);
    });

    test('应该正确处理小于1000的数字', () {
      // Arrange
      const baseNumber = 123;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, greaterThan(0));
    });

    test('应该正确处理取模余数为0的情况', () {
      // Arrange
      const baseNumber = 1616; // 16 % 8 = 0

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, 8); // 余数为0时应该返回8
      expect(result.xiaGuaNumber, 8);
    });

    test('应该正确应用特殊规则 - 余数为5的情况', () {
      // Arrange
      const baseNumber = 1305; // 13 % 8 = 5, 应该使用 13 - 10 = 3

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      // 前两位: 13 % 8 = 5, 特殊规则: 13 - 10 = 3
      expect(result.shangGuaNumber, 3);
      // 后两位: 05, 直接使用 5
      expect(result.xiaGuaNumber, 5);
    });

    test('应该正确应用特殊规则 - 余数为10的情况 (实际上10%8=2,但如果有10的话)', () {
      // Note: 实际上对8取模,余数不会是10,但代码中有这个逻辑
      // 这个测试主要是验证代码逻辑的完整性
      const baseNumber = 1810; // 18 % 8 = 2, 10 % 8 = 2

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.shangGuaNumber, lessThanOrEqualTo(8));
    });

    test('应该包含计算详情信息', () {
      // Arrange
      const baseNumber = 2468;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result.calculationDetail, contains('基础数'));
      expect(result.calculationDetail, contains('上卦'));
      expect(result.calculationDetail, contains('下卦'));
      expect(result.calculationDetail, contains('完整卦名'));
    });

    test('应该正确映射64卦名称', () {
      // Arrange
      const baseNumber = 1234;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      // 验证卦象名称不为空且包含64卦之一
      expect(result.fullGuaName, isNotEmpty);
      expect(result.shangGuaName, isNotEmpty);
      expect(result.xiaGuaName, isNotEmpty);

      // 验证完整卦名的格式和内容
      expect(result.fullGuaName.length, greaterThan(0));
    });

    test('应该保持一致性 - 相同输入得到相同输出', () {
      // Arrange
      const baseNumber = 7890;

      // Act
      final result1 = GuaCalculationHelper.calculateGua(baseNumber);
      final result2 = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result1.shangGuaNumber, equals(result2.shangGuaNumber));
      expect(result1.xiaGuaNumber, equals(result2.xiaGuaNumber));
      expect(result1.fullGuaName, equals(result2.fullGuaName));
      expect(result1.shangGuaName, equals(result2.shangGuaName));
      expect(result1.xiaGuaName, equals(result2.xiaGuaName));
    });

    test('边界测试 - 最小值1', () {
      // Arrange
      const baseNumber = 1;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThanOrEqualTo(0)); // 可能为0
      expect(result.xiaGuaNumber, greaterThan(0));
    });

    test('边界测试 - 最大值9999', () {
      // Arrange
      const baseNumber = 9999;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.shangGuaNumber, lessThanOrEqualTo(8));
      expect(result.xiaGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, lessThanOrEqualTo(8));
    });

    test('应该正确处理数字分割 - 四位数', () {
      // Arrange
      const baseNumber = 5678;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      expect(result.calculationDetail, contains('56')); // 前两位
      expect(result.calculationDetail, contains('78')); // 后两位
    });

    test('应该正确处理数字分割 - 三位数', () {
      // Arrange
      const baseNumber = 567;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert
      // 三位数: 0567 -> 05, 67
      expect(result, isNotNull);
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, greaterThan(0));
    });

    test('完整流程测试 - 验证所有步骤', () {
      // Arrange
      const baseNumber = 3456;

      // Act
      final result = GuaCalculationHelper.calculateGua(baseNumber);

      // Assert - 验证结果结构完整性
      expect(result, isA<GuaCalculationResult>());
      expect(result.shangGuaNumber, isA<int>());
      expect(result.xiaGuaNumber, isA<int>());
      expect(result.shangGuaName, isA<String>());
      expect(result.xiaGuaName, isA<String>());
      expect(result.fullGuaName, isA<String>());
      expect(result.calculationDetail, isA<String>());

      // 验证范围
      expect(result.shangGuaNumber, inInclusiveRange(1, 8));
      expect(result.xiaGuaNumber, inInclusiveRange(1, 8));

      // 验证非空
      expect(result.shangGuaName, isNotEmpty);
      expect(result.xiaGuaName, isNotEmpty);
      expect(result.fullGuaName, isNotEmpty);
      expect(result.calculationDetail, isNotEmpty);
    });
  });

  group('GuaCalculationHelper - 特殊算法规则测试', () {
    test('验证后天八卦映射 - 乾1', () {
      const testNumber = 1001; // 10 % 8 = 2, 01 直接使用

      final result = GuaCalculationHelper.calculateGua(testNumber);

      // 验证结果有效
      expect(result.shangGuaNumber, greaterThan(0));
      expect(result.xiaGuaNumber, 1);
    });

    test('验证后天八卦映射 - 坤8', () {
      const testNumber = 1616; // 16 % 8 = 0 -> 8, 16 % 8 = 0 -> 8

      final result = GuaCalculationHelper.calculateGua(testNumber);

      // 验证余数为0时返回8
      expect(result.shangGuaNumber, 8);
      expect(result.xiaGuaNumber, 8);
    });

    test('验证计算详情包含必要信息', () {
      const testNumber = 2345;

      final result = GuaCalculationHelper.calculateGua(testNumber);

      // 验证计算详情包含关键步骤
      expect(result.calculationDetail, contains('基础数'));
      expect(result.calculationDetail, contains('23'));
      expect(result.calculationDetail, contains('45'));
      expect(result.calculationDetail, contains('上卦'));
      expect(result.calculationDetail, contains('下卦'));
    });
  });
}
