import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_1.dart' hide test;

void main() {
  group('TiaoWenNumberCalculationStrategy Tests', () {
    late FourZhu testFourZhu;
    late SixQinCorrectKeStrategy tiaoWenCalculator;
    late List<List<int>> bianYaoIndexListSet;

    setUp(() {
      // 创建测试用的四柱数据
      testFourZhu = FourZhu(
        yearGanzhi: "癸巳",
        monthGanzhi: "甲子",
        dayGanzhi: "丁酉",
        timeGanzhi: "癸卯",
      );

      tiaoWenCalculator = SixQinCorrectKeStrategy(
        fourZhu: testFourZhu,
        gender: "男",
      );

      bianYaoIndexListSet = [
        [],
        [0],
        [1],
        [2],
        [3],
        [4],
        [5],
      ];
    });

    test('should initialize TiaoWenNumberCalculationStrategy correctly', () {
      // Assert
      expect(tiaoWenCalculator.fourZhu, equals(testFourZhu));
      expect(tiaoWenCalculator.gender, equals("男"));
      expect(tiaoWenCalculator.strategyName, equals("六亲考刻法"));
      expect(tiaoWenCalculator.xianTianBaseGua, isNotEmpty);
      expect(tiaoWenCalculator.houTianBaseGua, isNotEmpty);
      expect(tiaoWenCalculator.xianTianBaseNumber, equals(-1));
      expect(tiaoWenCalculator.houTianBaseNumber, equals(-1));
    });

    test('should calculate XianTian base gua correctly', () {
      // Act
      String xianTianGua = SixQinCorrectKeStrategy.calculateXianTianBaseGua(
        testFourZhu,
        "男",
      );

      // Assert
      expect(xianTianGua, isNotEmpty);
      expect(xianTianGua.length, equals(2));
    });

    test('should calculate HouTian base gua correctly', () {
      // Act
      String houTianGua = SixQinCorrectKeStrategy.calculateHouTianBaseGua(
        testFourZhu,
      );

      // Assert
      expect(houTianGua, isNotEmpty);
      expect(houTianGua.length, equals(2));
    });

    test('should get XianTian base number by yaobian list', () {
      // Arrange
      List<int> emptyBianYaoList = [];
      List<int> singleBianYaoList = [2];

      // Act
      CorrectionSixQinKe emptyResult = tiaoWenCalculator
          .getXiantianBasenumberByYaobianlist(emptyBianYaoList);
      CorrectionSixQinKe singleResult = tiaoWenCalculator
          .getXiantianBasenumberByYaobianlist(singleBianYaoList);

      // Assert
      expect(emptyResult.baseGua, equals(tiaoWenCalculator.xianTianBaseGua));
      expect(emptyResult.bianYaoIndexList, equals(emptyBianYaoList));
      expect(emptyResult.baseNumber, isA<int>());
      expect(emptyResult.baseNumber, greaterThan(0));
      expect(emptyResult.isAccepted, isFalse);

      expect(singleResult.baseGua, equals(tiaoWenCalculator.xianTianBaseGua));
      expect(singleResult.bianYaoIndexList, equals(singleBianYaoList));
      expect(singleResult.baseNumber, isA<int>());
      expect(singleResult.baseNumber, greaterThan(0));
      expect(singleResult.isAccepted, isFalse);
    });

    test('should get HouTian base number by yaobian list', () {
      // Arrange
      List<int> emptyBianYaoList = [];
      List<int> singleBianYaoList = [1];

      // Act
      CorrectionSixQinKe emptyResult = tiaoWenCalculator
          .getHoutianBasenumberByYaobianlist(emptyBianYaoList);
      CorrectionSixQinKe singleResult = tiaoWenCalculator
          .getHoutianBasenumberByYaobianlist(singleBianYaoList);

      // Assert
      expect(emptyResult.baseGua, equals(tiaoWenCalculator.houTianBaseGua));
      expect(emptyResult.bianYaoIndexList, equals(emptyBianYaoList));
      expect(emptyResult.baseNumber, isA<int>());
      expect(emptyResult.baseNumber, greaterThan(0));
      expect(emptyResult.isAccepted, isFalse);

      expect(singleResult.baseGua, equals(tiaoWenCalculator.houTianBaseGua));
      expect(singleResult.bianYaoIndexList, equals(singleBianYaoList));
      expect(singleResult.baseNumber, isA<int>());
      expect(singleResult.baseNumber, greaterThan(0));
      expect(singleResult.isAccepted, isFalse);
    });

    test(
      'should calculate number lists correctly after setting base numbers',
      () {
        // Arrange - 模拟原测试中的逻辑
        // 第三爻变爻时为先天基数
        // print(tiaoWenCalculator.xianTianBaseGua);
        for (int i = 0; i < bianYaoIndexListSet.length; i++) {
          CorrectionSixQinKe res = tiaoWenCalculator
              .getXiantianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
          tiaoWenCalculator.xianTianGuaStageList.add(res);

          if (i == 3) {
            tiaoWenCalculator.xianTianBaseNumber = res.baseNumber;
            break;
          }
        }

        // 第一爻变爻时为后天基数
        for (int i = 0; i < bianYaoIndexListSet.length; i++) {
          CorrectionSixQinKe res = tiaoWenCalculator
              .getHoutianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
          tiaoWenCalculator.houTianGuaStageList.add(res);

          if (i == 1) {
            tiaoWenCalculator.houTianBaseNumber = res.baseNumber;
            break;
          }
        }

        // Act
        List<int> xianTianList = tiaoWenCalculator.xianTianNumberList;
        List<int> houTianList = tiaoWenCalculator.houTianNumberList;

        // Assert
        expect(xianTianList, hasLength(8));
        expect(houTianList, hasLength(8));
        expect(tiaoWenCalculator.xianTianBaseNumber, greaterThan(0));
        expect(tiaoWenCalculator.houTianBaseNumber, greaterThan(0));
      },
    );

    test('should match expected results from original test', () {
      // Arrange - 执行原测试逻辑
      for (int i = 0; i < bianYaoIndexListSet.length; i++) {
        CorrectionSixQinKe res = tiaoWenCalculator
            .getXiantianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
        tiaoWenCalculator.xianTianGuaStageList.add(res);
        // print(res);

        if (i == 3) {
          tiaoWenCalculator.xianTianBaseNumber = res.baseNumber;
          break;
        }
      }
      // print(tiaoWenCalculator.xianTianBaseNumber);

      for (int i = 0; i < bianYaoIndexListSet.length; i++) {
        CorrectionSixQinKe res = tiaoWenCalculator
            .getHoutianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
        tiaoWenCalculator.houTianGuaStageList.add(res);

        if (i == 1) {
          tiaoWenCalculator.houTianBaseNumber = res.baseNumber;
          break;
        }
      }

      // Expected results from original test
      List<int> expectedXianTianList = [
        2349,
        2445,
        2637,
        3021,
        2157,
        2061,
        1869,
        1485,
      ];
      List<int> expectedHouTianList = [
        2819,
        2915,
        3107,
        3491,
        2627,
        2531,
        2339,
        1955,
      ];

      // Act
      List<int> actualXianTianList = tiaoWenCalculator.xianTianNumberList;
      List<int> actualHouTianList = tiaoWenCalculator.houTianNumberList;

      expect(tiaoWenCalculator.xianTianBaseGua, "兑乾");
      expect(tiaoWenCalculator.houTianBaseGua, "坤坎");
      expect(tiaoWenCalculator.xianTianBaseNumber, 2253);
      expect(tiaoWenCalculator.houTianBaseNumber, 2723);

      // Assert
      expect(actualXianTianList, equals(expectedXianTianList));
      expect(actualHouTianList, equals(expectedHouTianList));
    });

    test('should handle different genders correctly', () {
      // Arrange
      SixQinCorrectKeStrategy femaleCalculator = SixQinCorrectKeStrategy(
        fourZhu: testFourZhu,
        gender: "女",
      );

      // Act & Assert
      expect(femaleCalculator.gender, equals("女"));
      expect(femaleCalculator.xianTianBaseGua, isNotEmpty);
      expect(femaleCalculator.houTianBaseGua, isNotEmpty);

      // 不同性别可能产生不同的先天卦
      // 这取决于具体的算法实现
    });

    test('should handle edge cases with different FourZhu', () {
      // Arrange
      FourZhu edgeCaseFourZhu = FourZhu(
        yearGanzhi: "甲子",
        monthGanzhi: "乙丑",
        dayGanzhi: "丙寅",
        timeGanzhi: "丁卯",
      );

      // Act & Assert
      expect(() {
        SixQinCorrectKeStrategy(fourZhu: edgeCaseFourZhu, gender: "男");
      }, returnsNormally);
    });
  });

  group('CorrectionSixQinKe Tests', () {
    test('should create CorrectionSixQinKe correctly', () {
      // Arrange & Act
      CorrectionSixQinKe correction = CorrectionSixQinKe(
        baseGua: "乾坤",
        rootGua: "坤乾",
        baseGuaHu: "艮兑",
        bianYaoIndexList: [0, 2],
        baseNumber: 1234,
        isAccepted: true,
      );

      // Assert
      expect(correction.baseGua, equals("乾坤"));
      expect(correction.rootGua, equals("坤乾"));
      expect(correction.baseGuaHu, equals("艮兑"));
      expect(correction.bianYaoIndexList, equals([0, 2]));
      expect(correction.baseNumber, equals(1234));
      expect(correction.isAccepted, isTrue);
    });

    test('should have correct toString representation', () {
      // Arrange
      CorrectionSixQinKe correction = CorrectionSixQinKe(
        baseGua: "乾坤",
        rootGua: "坤乾",
        baseGuaHu: "艮兑",
        bianYaoIndexList: [0, 2],
        baseNumber: 1234,
        isAccepted: false,
      );

      // Act
      String result = correction.toString();

      // Assert
      expect(result, contains("CorrectionSixQinKe"));
      expect(result, contains("乾坤"));
      expect(result, contains("坤乾"));
      expect(result, contains("艮兑"));
      expect(result, contains("1234"));
      expect(result, contains("false"));
    });
  });
}
