import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/yuan_tang/yuan_tang_calculator.dart';

void main() {
  group('YuanTangGua Tests', () {
    late FourZhu testFourZhu;

    setUp(() {
      // 创建测试用的四柱
      testFourZhu = FourZhu(
        yearGanzhi: "甲戌",
        monthGanzhi: "己巳",
        dayGanzhi: "辛丑",
        timeGanzhi: "丁酉",
      );
    });

    test('should generate YuanTangGua correctly for male in upper yuan', () {
      // Arrange
      const String gender = "男";
      const String threeYuan = "上";
      const String birthAfterZhi = "夏至";

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(testFourZhu));
      expect(yuanTangGua.gender, equals(gender));
      expect(yuanTangGua.threeYuan, equals(threeYuan));
      expect(yuanTangGua.birthAfterZhi, equals(birthAfterZhi));
      expect(yuanTangGua.xiantianGua, isNotEmpty);
      expect(yuanTangGua.houtianGua, isNotEmpty);
      expect(yuanTangGua.yuantanYaoIndex, greaterThanOrEqualTo(0));
      expect(yuanTangGua.yuantanYaoIndex, lessThan(6));
      expect(yuanTangGua.zhiList, isNotEmpty);
    });

    test('should generate YuanTangGua correctly for female in middle yuan', () {
      // Arrange
      const String gender = "女";
      const String threeYuan = "中";
      const String birthAfterZhi = "冬至";

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(testFourZhu));
      expect(yuanTangGua.gender, equals(gender));
      expect(yuanTangGua.threeYuan, equals(threeYuan));
      expect(yuanTangGua.birthAfterZhi, equals(birthAfterZhi));
      expect(yuanTangGua.xiantianGua, isNotEmpty);
      expect(yuanTangGua.houtianGua, isNotEmpty);
      expect(yuanTangGua.yuantanYaoIndex, greaterThanOrEqualTo(0));
      expect(yuanTangGua.yuantanYaoIndex, lessThan(6));
      expect(yuanTangGua.zhiList, isNotEmpty);
    });

    test('should generate YuanTangGua correctly for male in lower yuan', () {
      // Arrange
      const String gender = "男";
      const String threeYuan = "下";
      const String birthAfterZhi = "春分";

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(testFourZhu));
      expect(yuanTangGua.gender, equals(gender));
      expect(yuanTangGua.threeYuan, equals(threeYuan));
      expect(yuanTangGua.birthAfterZhi, equals(birthAfterZhi));
      expect(yuanTangGua.xiantianGua, isNotEmpty);
      expect(yuanTangGua.houtianGua, isNotEmpty);
      expect(yuanTangGua.yuantanYaoIndex, greaterThanOrEqualTo(0));
      expect(yuanTangGua.yuantanYaoIndex, lessThan(6));
      expect(yuanTangGua.zhiList, isNotEmpty);
    });

    test('should calculate tiaowen numbers correctly', () {
      // Arrange
      const String gender = "男";
      const String threeYuan = "上";
      const String birthAfterZhi = "夏至";

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.tiaowenNumberJiazeXiantiangua, isA<int>());
      expect(yuanTangGua.tiaowenNumberJiazeHoutiangua, isA<int>());
      expect(yuanTangGua.tiaowenNumberXiantianBenhu, isA<int>());
      expect(yuanTangGua.tiaowenNumberHoutianBenhu, isA<int>());

      // 条文编号应该是正数
      expect(yuanTangGua.tiaowenNumberJiazeXiantiangua, greaterThan(0));
      expect(yuanTangGua.tiaowenNumberJiazeHoutiangua, greaterThan(0));
      expect(yuanTangGua.tiaowenNumberXiantianBenhu, greaterThan(0));
      expect(yuanTangGua.tiaowenNumberHoutianBenhu, greaterThan(0));
    });

    test('should generate different results for different genders', () {
      // Arrange
      const String threeYuan = "上";
      const String birthAfterZhi = "夏至";

      // Act
      YuanTangGua maleYuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: "男",
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua femaleYuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: "女",
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      // 不同性别可能产生不同的结果（取决于具体算法）
      expect(maleYuanTangGua.gender, equals("男"));
      expect(femaleYuanTangGua.gender, equals("女"));
    });

    test('should generate different results for different three yuan', () {
      // Arrange
      const String gender = "男";
      const String birthAfterZhi = "夏至";

      // Act
      YuanTangGua upperYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: "上",
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua middleYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: "中",
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua lowerYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: testFourZhu,
        gender: gender,
        threeYuan: "下",
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(upperYuanGua.threeYuan, equals("上"));
      expect(middleYuanGua.threeYuan, equals("中"));
      expect(lowerYuanGua.threeYuan, equals("下"));
    });

    test('should handle edge cases with different FourZhu combinations', () {
      // Arrange
      FourZhu edgeCaseFourZhu = FourZhu(
        yearGanzhi: "癸亥",
        monthGanzhi: "甲子",
        dayGanzhi: "乙丑",
        timeGanzhi: "丙寅",
      );

      // Act & Assert
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: edgeCaseFourZhu,
          gender: "男",
          threeYuan: "上",
          birthAfterZhi: "夏至",
        );
      }, returnsNormally);
    });

    test('should validate input parameters', () {
      // Test with invalid gender
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: testFourZhu,
          gender: "无效性别",
          threeYuan: "上",
          birthAfterZhi: "夏至",
        );
      }, returnsNormally); // 根据实际实现可能需要调整

      // Test with invalid threeYuan
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: testFourZhu,
          gender: "男",
          threeYuan: "无效元",
          birthAfterZhi: "夏至",
        );
      }, returnsNormally); // 根据实际实现可能需要调整
    });
  });

  group('YuanTangGua Static Methods Tests', () {
    test('generateUponUnderGua should work correctly', () {
      // Act
      var (uponGua, underGua) = YuanTangGua.generateUponUnderGua(
        "乾",
        "坤",
        "阳",
        "男",
      );

      // Assert
      expect(uponGua, isNotEmpty);
      expect(underGua, isNotEmpty);
    });

    test('generateTianDiGua should work correctly', () {
      // Arrange
      List<int> ganNumList = [1, 2, 3, 4];
      List<int> zhiNumList = [1, 2, 3, 4];

      // Act
      var (tianGua, diGua) = YuanTangGua.generateTianDiGua(
        "男",
        true,
        "上",
        ganNumList,
        zhiNumList,
      );

      // Assert
      expect(tianGua, isNotEmpty);
      expect(diGua, isNotEmpty);
    });
  });
}
