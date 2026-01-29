import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/si_men_fa_strategy.dart';

void main() {
  test('SiMenFa debug - 检查计算错误', () {
    final strategy = SiMenFaStrategy();

    final testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    final testParams = SiMenFaStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
    );

    final result = strategy.calculate(testParams);

    print('hasError: ${result.hasError}');
    print('errorMessage: ${result.errorMessage}');
    print('algorithmName: ${result.algorithmName}');

    if (result.sourceData.containsKey('error')) {
      print('error detail: ${result.sourceData['error']}');
    }
    if (result.sourceData.containsKey('stackTrace')) {
      print('stackTrace: ${result.sourceData['stackTrace']}');
    }
  });
}
