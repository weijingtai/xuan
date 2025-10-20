import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';

class FourZhuEightChar extends StatelessWidget {
  final JiaZi year;
  final JiaZi month;
  final JiaZi day;
  final JiaZi chen;
  Map<TianGan, Color>? zodiacGanColors;
  Map<DiZhi, Color>? zodiacZhiColors;
  Widget? kongWangWidget;
  bool isColorful;
  FourZhuEightChar({
    super.key,
    required this.year,
    required this.month,
    required this.day,
    required this.chen,
    this.zodiacGanColors,
    this.zodiacZhiColors,
    this.kongWangWidget,
    this.isColorful = false,
  });

  TextStyle normalTextStyle =
      GoogleFonts.zhiMangXing(color: Colors.black45, fontSize: 16, height: 1.0);
  TextStyle twelveDiZhiTextStyle = GoogleFonts.longCang(
      color: Colors.black,
      fontSize: 48,
      height: 1,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
            color: Colors.grey.withValues(alpha: .5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);
  TextStyle tianGanTextStyle = GoogleFonts.zhiMangXing(
      color: const Color.fromRGBO(28, 45, 37, 1),
      fontWeight: FontWeight.w200,
      fontSize: 26,
      height: 1,
      shadows: [
        Shadow(
            color: Colors.grey.withValues(alpha: .5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return four_zhu_eight_char(year: year, month: month, day: day, chen: chen);
  }

  Widget four_zhu_eight_char(
      {required JiaZi year,
      required JiaZi month,
      required JiaZi day,
      required JiaZi chen}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "",
              style: TextStyle(fontSize: 16, height: 1.0),
            ),
            const SizedBox(
              height: 6,
            ),
            SizedBox(
              height: 14,
              // child:Text("旬首",style: TextStyle(fontSize: 10,height: 1.0,fontWeight: FontWeight.w300),),
              child: Text("旬首", style: normalTextStyle.copyWith(fontSize: 14)),
            ),
            Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: Text("天干",
                  style: tianGanTextStyle.copyWith(
                      fontSize: 18, color: Colors.black87)),
            ),
            SizedBox(
              child: Text("纳音", style: normalTextStyle.copyWith(fontSize: 14)),
            ),
            Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              // child: Text("地支",style: TextStyle(fontSize: 14,height: 1.0),),
              child: Text("地支",
                  style: twelveDiZhiTextStyle.copyWith(
                      fontSize: 18, color: Colors.black87)),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 14,
              child: RichText(
                text: TextSpan(
                  text: "",
                  style: normalTextStyle.copyWith(fontSize: 14),
                  children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: kongWangWidget ?? const SizedBox()),
                    const TextSpan(text: "空亡")
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          width: 4,
        ),
        Container(
            // color: Colors.blue.withValues(alpha: .1),
            child:
                each_zhu("年", year.getXunHeader(), year, year.getKongWang())),
        const SizedBox(width: 4),
        Container(
            // color: Colors.orange.withValues(alpha: .1),
            child: each_zhu(
                "月", month.getXunHeader(), month, month.getKongWang())),
        const SizedBox(
          width: 4,
        ),
        Container(
            // color: Colors.red.withValues(alpha: .1),
            child: each_zhu("日", day.getXunHeader(), day, day.getKongWang())),
        const SizedBox(
          width: 4,
        ),
        Container(
            // color: Colors.green.withValues(alpha: .1),
            child:
                each_zhu("时", chen.getXunHeader(), chen, chen.getKongWang())),
        const SizedBox(
          width: 4,
        ),
        Container(
          // color: Colors.green.withValues(alpha: .1),
            child:
            each_zhu("时", chen.getXunHeader(), chen, chen.getKongWang())),

      ],
    );
  }

  Size size = const Size(42, 32);
  Widget each_zhu(
      String name, JiaZi xunHead, JiaZi jiaZi, Tuple2<DiZhi, DiZhi> kongWang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: twelveDiZhiTextStyle.copyWith(
              fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(xunHead.ganZhiStr, style: normalTextStyle),
        Container(
          height: size.height,
          width: size.width,
          alignment: Alignment.center,
          child: Text(jiaZi.tianGan.value,
              style: getTianGanTextStyle(jiaZi.tianGan)),
        ),
        Container(
          width: size.width,
          alignment: Alignment.center,
          child: Text(jiaZi.naYin.name,
              style: normalTextStyle.copyWith(fontSize: 14)),
        ),
        Container(
            height: size.height,
            width: size.width,
            alignment: Alignment.center,
            child:
                Text(jiaZi.diZhi.value, style: getDiZhiTextStyle(jiaZi.diZhi))),
        const SizedBox(
          height: 4,
        ),
        Text(
          "${kongWang.item1.value}${kongWang.item2.value}",
          style: normalTextStyle,
        )
      ],
    );
  }

  TextStyle getTianGanTextStyle(TianGan tianGan) {
    if (isColorful) {
      return tianGanTextStyle.copyWith(
          fontSize: 28,
          color: zodiacGanColors?[tianGan] ?? Colors.black87,
          fontWeight: FontWeight.w100);
    } else {
      return tianGanTextStyle.copyWith(
          fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w100);
    }
  }

  TextStyle getDiZhiTextStyle(DiZhi diZhi) {
    if (isColorful) {
      return twelveDiZhiTextStyle.copyWith(
          fontSize: 28,
          color: zodiacZhiColors?[diZhi] ?? Colors.black87,
          fontWeight: FontWeight.w500);
    } else {
      return twelveDiZhiTextStyle.copyWith(
          fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w500);
    }
  }
}
