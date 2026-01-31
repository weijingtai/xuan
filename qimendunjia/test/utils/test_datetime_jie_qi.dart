

// create test function
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tyme/tyme.dart';
import 'package:qimendunjia/utils/datetime_jie_qi.dart';

void main() {
  test('测试节气为“大雪”', () {
    String datetimeStr = "2022/12/14 16:30:00";
    DateTime datetime = DateFormat("yyyy/MM/dd HH:mm:ss").parse(datetimeStr);
    String res = datetime.getSolarTerm();
    assert(res == "大雪",res);
  });
  test('测试节气为“芒种”', () {
    String datetimeStr = "2010/06/12 16:30:00";
    DateTime datetime = DateFormat("yyyy/MM/dd HH:mm:ss").parse(datetimeStr);
    String res = datetime.getSolarTerm();
    assert(res == "芒种",res);
  });
  test('测试节气为"处暑"', () {
    String datetimeStr = "2023/08/31";
    DateTime datetime = DateFormat("yyyy/MM/dd").parse(datetimeStr);
    // Using tyme to get the current solar term
    SolarDay solarDay = SolarDay.fromYmd(datetime.year, datetime.month, datetime.day);
    String res = solarDay.getTerm().getName();
    // String res = datetime.getSolarTerm();
    assert(res == "处暑","result is '$res' "); //
  });

  test('测试节气为“处暑”，使用自己的函数', () {
    String datetimeStr = "2023/08/31 16:30";
    DateTime datetime = DateFormat("yyyy/MM/dd HH:mm").parse(datetimeStr);
    // String datetimeStr = "2023/08/31";
    // DateTime datetime = DateFormat("yyyy/MM/dd").parse(datetimeStr);
    String res = datetime.getSolarTerm();
    assert(res == "处暑","result is '$res' "); //
  });
}
