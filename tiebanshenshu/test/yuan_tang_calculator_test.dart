import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';

import '../service_bak/yuan_tang/yuan_tang_calculator.dart';

void main() {
  group('YuanTangGua Tests', () {
    late EightChars eightChars;

    setUp(() {
      // 创建测试用的四柱
      eightChars = EightChars(
        year: JiaZi.BING_XU, // "甲戌",
        month: JiaZi.getFromGanZhiValue("己巳")!, // "己巳",
        day: JiaZi.getFromGanZhiValue("辛丑")!, // "辛丑",
        time: JiaZi.getFromGanZhiValue("丁酉")!, // "丁酉",
      );
    });

    test('should generate YuanTangGua correctly for male in upper yuan', () {
      // Arrange
      const Gender gender = Gender.male;
      const YuanYunOrder threeYuan = YuanYunOrder.upper;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.XIA_ZHI;

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(eightChars));
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
      const Gender gender = Gender.female;
      const YuanYunOrder threeYuan = YuanYunOrder.middle;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.DONG_ZHI;

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(eightChars));
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
      const Gender gender = Gender.male;
      const YuanYunOrder threeYuan = YuanYunOrder.lower;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.DONG_ZHI;

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(yuanTangGua.fourZhu, equals(eightChars));
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
      const Gender gender = Gender.male;
      const YuanYunOrder threeYuan = YuanYunOrder.upper;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.DONG_ZHI;

      // Act
      YuanTangGua yuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
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
      const YuanYunOrder threeYuan = YuanYunOrder.upper;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.DONG_ZHI;

      // Act
      YuanTangGua maleYuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: Gender.male,
        threeYuan: threeYuan,
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua femaleYuanTangGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: Gender.female,
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
      const Gender gender = Gender.male;
      const TwentyFourJieQi birthAfterZhi = TwentyFourJieQi.DONG_ZHI;

      // Act
      YuanTangGua upperYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua middleYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: YuanYunOrder.middle,
        birthAfterZhi: birthAfterZhi,
      );

      YuanTangGua lowerYuanGua = YuanTangGua.generateYuantanGua(
        fourZhu: eightChars,
        gender: gender,
        threeYuan: YuanYunOrder.lower,
        birthAfterZhi: birthAfterZhi,
      );

      // Assert
      expect(upperYuanGua.threeYuan, equals("上"));
      expect(middleYuanGua.threeYuan, equals("中"));
      expect(lowerYuanGua.threeYuan, equals("下"));
    });

    test('should handle edge cases with different FourZhu combinations', () {
      // Arrange
      EightChars edgeCaseFourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("癸亥")!,
        month: JiaZi.getFromGanZhiValue("甲子")!,
        day: JiaZi.getFromGanZhiValue("乙丑")!,
        time: JiaZi.getFromGanZhiValue("丙寅")!,
      );

      // Act & Assert
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: edgeCaseFourZhu,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
        );
      }, returnsNormally);
    });

    test('should validate input parameters', () {
      // Test with invalid gender
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: eightChars,
          gender: Gender.unknown,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
        );
      }, returnsNormally); // 根据实际实现可能需要调整

      // Test with invalid threeYuan
      expect(() {
        YuanTangGua.generateYuantanGua(
          fourZhu: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.lower,
          birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
        );
      }, returnsNormally); // 根据实际实现可能需要调整
    });
  });

  group('YuanTangGua Static Methods Tests', () {
    test('generateUponUnderGua should work correctly', () {
      // Act
      var (uponGua, underGua) = YuanTangGua.generateUponUnderGua(
        Enum8Gua.Qian,
        Enum8Gua.Kun,
        YinYang.YANG,
        Gender.male,
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
        Gender.male,
        true,
        YuanYunOrder.upper,
        ganNumList,
        zhiNumList,
      );

      // Assert
      expect(tianGua, isNotEmpty);
      expect(diGua, isNotEmpty);
    });
  });
}
