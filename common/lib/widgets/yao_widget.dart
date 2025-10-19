import 'package:flutter/material.dart';

import '../enums/enum_yin_yang.dart';

class YaoWidget extends StatelessWidget {
  final YinYang yinYangYao;
  final Size yaoSize;
  Color color;
  bool withShadow;
  YaoWidget(
      {super.key,
      required this.yinYangYao,
      required this.yaoSize,
      this.color = Colors.black87,
      this.withShadow = true});

  @override
  Widget build(BuildContext context) {
    return buildEachYao();
  }

  Widget buildEachYao() {
    if (yinYangYao.isYang) {
      return Container(
        width: yaoSize.width,
        height: yaoSize.height,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(yaoSize.height / 2),
            boxShadow: withShadow
                ? [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 0), // changes position of shadow
                    )
                  ]
                : []),
      );
    } else {
      return SizedBox(
        width: yaoSize.width,
        height: yaoSize.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: yaoSize.width * 0.44,
              height: yaoSize.height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(yaoSize.height / 2),
                boxShadow: withShadow
                    ? [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        )
                      ]
                    : [],
              ),
            ),
            SizedBox(
              width: yaoSize.width * .12,
            ),
            Container(
              width: yaoSize.width * 0.44,
              height: yaoSize.height,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(yaoSize.height / 2),
                  boxShadow: withShadow
                      ? [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          )
                        ]
                      : []),
            ),
          ],
        ),
      );
    }
  }
}
