import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/xian_houtian_qu_shu_strategy.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Debug XianHoutianQuShuStrategy null error', () {
    test('打印中间结果定位null来源', () {
      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 创建FourZhu对象
      // final fourZhu = FourZhu(
      //   yearGanzhi: eightChars.year.name,
      //   monthGanzhi: eightChars.month.name,
      //   dayGanzhi: eightChars.day.name,
      //   timeGanzhi: eightChars.time.name,
      // );

      print('\n========== DEBUG INFO ==========');
      print('EightChars: $eightChars');
      print('yearGan: ${eightChars.year.gan}, yearZhi: ${eightChars.year.zhi}');
      print(
        'monthGan: ${eightChars.month.gan}, monthZhi: ${eightChars.month.zhi}',
      );
      print('dayGan: ${eightChars.day.gan}, dayZhi: ${eightChars.day.zhi}');
      print('timeGan: ${eightChars.time.gan}, timeZhi: ${eightChars.time.zhi}');

      final strategy = XianHoutianQuShuStrategy();
      final params = XianHoutianQuShuStrategyParams(
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
