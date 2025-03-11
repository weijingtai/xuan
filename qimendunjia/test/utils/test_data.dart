// create test function
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qimendunjia/data.dart';

void main() {
  test('测试节气为“大雪”', () {
    // String datetimeStr = "2021/01/01 12:10:00";
    // String datetimeStr = "2021/02/01 12:10:00";
    // String datetimeStr = "2023/09/13 07:31:00";
    String datetimeStr = "2000/01/01 00:00:00";
    DateTime datetime = DateFormat("yyyy/MM/dd HH:mm:ss").parse(datetimeStr);
    QiMenDunJiaPlate plate = QiMenDunJiaPlate(
        plateType: QiMenDunJiaPlateType.turnPlate_divisionAppend,
        plateDateTime: datetime);
    var res = plate.arrange();
    // assert(plate.plate[0][0] == "",plate.plate[0][0].eightDoor);
  });
}
