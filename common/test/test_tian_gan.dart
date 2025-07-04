import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("text", () {
    test("12", () {
      // 胎元月份，与生时月份干支的差值

      var birthMontGanZhi = JiaZi.YI_CHOU.number;
      var connGanZhi = JiaZi.REN_XU.number;
      var monthDifference = birthMontGanZhi - connGanZhi;
      print("----- $monthDifference");
      // 如果差值小于0，说明生时月份在后一个甲子中，相差的月份计算：
      if (monthDifference < 0) {
        monthDifference =
            JiaZi.listAll.last.number - connGanZhi + birthMontGanZhi;
      }

      var now = DateTime.now().subtract(Duration(days: 3));
      var bef = now.subtract(Duration(days: 30 * monthDifference));
      // expect(monthDifference, 4);
      expect(bef.month, 2, reason: "should be 2月 but is ${bef.month}月");
    });
  });
  group("纳卦", () {
    test("天干纳卦", () {
      expect("乾", TianGan.JIA.naJiaGua);
      expect("坤", TianGan.YI.naJiaGua);

      expect("艮", TianGan.BING.naJiaGua);
      expect("兑", TianGan.DING.naJiaGua);

      expect("坎", TianGan.WU.naJiaGua);
      expect("离", TianGan.JI.naJiaGua);

      expect("震", TianGan.GENG.naJiaGua);
      expect("巽", TianGan.XIN.naJiaGua);

      expect("乾", TianGan.REN.naJiaGua);
      expect("坤", TianGan.GUI.naJiaGua);
    });
  });
}
