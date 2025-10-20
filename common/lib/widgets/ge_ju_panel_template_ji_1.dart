import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeJuPanelTemplateJi1 extends StatelessWidget {
  final String name;
  final Color foregroundColor;
  final Color backgroundColor;
  const GeJuPanelTemplateJi1(
      {super.key,
      required this.name,
      required this.foregroundColor,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ge_ju_template(name, backgroundColor, foregroundColor);
  }

  Widget ge_ju_template(String name, Color color, Color backColor) {
    Container dot1 = Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .5),
              offset: const Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]),
    );
    Container dot2 = Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    double width = 180;
    double height = 42;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            // color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: 4,
          child: dot1,
        ),
        Positioned(
          right: 4,
          child: dot1,
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .5),
                  offset: const Offset(1, 1), //阴影xy轴偏移量
                  blurRadius: 1, //阴影模糊程度
                  spreadRadius: 1, //阴影扩散程度
                )
              ]),
        ),
        Positioned(
          left: 6,
          child: dot2,
        ),
        Positioned(
          right: 6,
          child: dot2,
        ),
        Container(
          width: width - 4,
          height: height - 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11), color: backColor
              // border: Border.all(color: Colors.white, width: 1),
              ),
        ),
        Positioned(
          left: 7,
          child: dot3,
        ),
        Positioned(
          right: 7,
          child: dot3,
        ),
        Container(
          width: width - 6,
          height: height - 6,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: color
              // border: Border.all(color: Colors.white, width: 1),
              ),
        ),
        SizedBox(
          width: 180,
          // child: Text("玉 女 守 门",style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 17,
              ),
              Text(
                name.split("").join(" "),
                style: GoogleFonts.maShanZheng(color: backColor, fontSize: 24),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 32,
                    width: 17,
                    child: ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(backColor, BlendMode.srcIn),
                        child: Image.asset(
                          "assets/icons/ji_xiong_yin_zhang.png",
                        )),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        // color: Colors.blue,
                        alignment: Alignment.center,
                        child: Text(
                          "大",
                          style: GoogleFonts.longCang(
                              height: 1.0,
                              color: color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                    color: Colors.grey.withValues(alpha: .4),
                                    blurRadius: 4)
                              ]),
                        ),
                      ),
                      Container(
                        width: 14,
                        alignment: Alignment.center,
                        child: Text("吉",
                            style: GoogleFonts.longCang(
                                height: 1.0,
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                      color: Colors.white.withValues(alpha: .4),
                                      blurRadius: 4)
                                ])),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
            left: 4,
            top: 4,
            child: SizedBox(
              height: 24,
              width: 48,
              child: ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset(
                    "assets/icons/xiang_yun_line_1.png",
                  )),
            )),
        Positioned(
            left: 0,
            bottom: 4,
            child: SizedBox(
              height: 24,
              width: 48,
              child: ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset(
                    "assets/icons/xiang_yun_wen_l.png",
                  )),
            )),
        Positioned(
          right: 0,
          top: -4,
          child: SizedBox(
              height: 24,
              width: 48,
              child: ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset(
                    "assets/icons/xiang_yun_wen_r.png",
                  ))),
        ),
      ],
    );
  }
}
