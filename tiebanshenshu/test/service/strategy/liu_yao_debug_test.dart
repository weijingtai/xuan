import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/liu_yao_gan_zhi_he_strategy.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Debug LiuYaoGanZhiHeStrategy null error', () {
    test('打印中间结果定位null来源', () {
      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print('\n========== DEBUG INFO ==========');
      print('FourZhu: $eightChars');
      print(
        'yearGan: ${eightChars.year.tianGan.name}, yearZhi: ${eightChars.year.zhi.name}',
      );
      print(
        'monthGan: ${eightChars.month.tianGan.name}, monthZhi: ${eightChars.month.zhi.name}',
      );
      print(
        'dayGan: ${eightChars.day.tianGan.name}, dayZhi: ${eightChars.day.zhi.name}',
      );
      print(
        'timeGan: ${eightChars.time.tianGan.name}, timeZhi: ${eightChars.time.zhi.name}',
      );

      final strategy = LiuYaoGanZhiHeStrategy();
      final params = LiuYaoGanZhiHeStrategyParams(
        eightChars: eightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      print('\nCalculating...');
      print('About to call strategy.calculate()...');

      final result = strategy.calculate(params);

      print('\nResult hasError: ${result.hasError}');
      if (result.hasError) {
        print('Error Message: ${result.errorMessage}');
        print('Source Data: ${result.sourceData}');
      } else {
        print('Success!');
        print('BaseNumbers count: ${result.baseNumbers.length}');
      }
      print('========== END DEBUG ==========\n');

      expect(result.hasError, false, reason: 'Should not have error');
    });
  });
}
