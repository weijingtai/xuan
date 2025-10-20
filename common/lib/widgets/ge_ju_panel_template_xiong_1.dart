import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeJuPanelTemplateXiong1 extends StatelessWidget {
  final String name;
  final Color foregroundColor;
  final Color backgroundColor;
  final Size size;
  const GeJuPanelTemplateXiong1(
      {super.key,
      required this.name,
      required this.size,
      required this.foregroundColor,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return shape(name, backgroundColor, foregroundColor);
  }

  Widget shape(String name, Color color, Color backColor) {
    double width = size.width;
    double height = size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        // SizedBox(width: 200, height: 60),
        Container(
          width: width,
          height: height - 20,
          decoration: BoxDecoration(color: color, boxShadow: [
            BoxShadow(
              // color: Colors.black26,
              color: color.withValues(alpha: .5),
              offset: const Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]),
        ),
        Container(
          width: width - 10,
          height: height - 10,
          decoration: BoxDecoration(color: color, boxShadow: [
            BoxShadow(
              // color: Colors.black26,
              color: color.withValues(alpha: .5),
              offset: const Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]),
        ),
        Container(
          width: width - 20,
          height: height,
          decoration: BoxDecoration(color: color, boxShadow: [
            BoxShadow(
              // color: Colors.black26,
              color: color.withValues(alpha: .5),
              offset: const Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]),
        ),
        Container(
          width: width - 4,
          height: height - 20 - 4,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),
        Container(
          width: width - 10 - 4,
          height: height - 10 - 4,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),
        Container(
          width: width - 20 - 4,
          height: height - 4,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),

        Container(
          width: width - 8,
          height: height - 20 - 6,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
        Container(
          width: width - 10 - 8,
          height: height - 10 - 6,
          decoration: BoxDecoration(
            color: color,
          ),
        ),

        Container(
          width: width - 20 - 8,
          height: height - 6,
          decoration: BoxDecoration(
            color: color,
          ),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: size.height,
                width: size.width * .1,
                child: ColorFiltered(
                    colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                    child: Image.asset(
                      "assets/icons/deng_long.png",
                    )),
              ),
              Container(
                  alignment: Alignment.center,
                  width: size.width * .5,
                  child: AutoSizeText(
                    name.split("").join(""),
                    style:
                        GoogleFonts.maShanZheng(color: backColor, fontSize: 24),
                    maxLines: 1,
                    minFontSize: 10,
                    maxFontSize: 32,
                  )),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                      image: const AssetImage("assets/icons/ru_mu.png")),
                ),
                width: width * .1,
                alignment: Alignment.center,
                child: AutoSizeText(
                  "凶",
                  style: GoogleFonts.maShanZheng(
                      height: 1.0,
                      color: color,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                            color: Colors.white.withValues(alpha: .4), blurRadius: 4)
                      ]),
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 16,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
