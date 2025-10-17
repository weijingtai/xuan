import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/ba_gua_gun_strategy.dart';

void main() {
  test('BaGuaGun debug - 检查计算错误', () {
    final strategy = BaGuaGunStrategy();

    final testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    final testParams = BaGuaGunStrategyParams(
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

    if (!result.hasError) {
      print('\n计算成功！');
      print('八卦数量: ${result.sourceData['eightGuaCount']}');
      print('条文数量: ${result.sourceData['totalTiaoWenNumbers']}');
    }
  });
}
