import 'package:common/widgets/yao_widget.dart';
import 'package:flutter/material.dart';

import '../enums/enum_hou_tian_gua.dart';
import '../enums/enum_yin_yang.dart';

class EightGuaWidget extends StatelessWidget {
  HouTianGua gua;
  Size yaoSize;
  int intervalHeight;
  Color color;
  bool withShadow;
  EightGuaWidget(
      {super.key,
      required this.gua,
      required this.yaoSize,
      required this.intervalHeight,
      this.color = Colors.black87,
      this.withShadow = true});

  @override
  Widget build(BuildContext context) {
    return buildEightGua();
  }

  /// binary str  从下向上曜
  Widget buildEightGua() {
    /// 0 为 阴爻， 1 为 阳爻
    List<String> threeYaoList = gua.binaryStr.split("");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        YaoWidget(
          yinYangYao: YinYang.getByBinaryStr(threeYaoList[2]),
          yaoSize: yaoSize,
          color: color,
          withShadow: withShadow,
        ),
        SizedBox(
          height: yaoSize.height * 0.5,
        ),
        YaoWidget(
            yinYangYao: YinYang.getByBinaryStr(threeYaoList[1]),
            yaoSize: yaoSize,
            color: color,
            withShadow: withShadow),
        SizedBox(
          height: yaoSize.height * 0.5,
        ),
        YaoWidget(
            yinYangYao: YinYang.getByBinaryStr(threeYaoList[0]),
            yaoSize: yaoSize,
            color: color,
            withShadow: withShadow),
      ],
    );
  }
}
