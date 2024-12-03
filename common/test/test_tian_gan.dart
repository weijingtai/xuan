import 'package:common/model/enum_tian_gan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("纳卦", ()
  {
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