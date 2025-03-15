import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TenGanKeYingYinZhang extends StatelessWidget {
  final String geJuName;
  final JiXiongEnum jiXiong;
  late final String yinZhang0;
  late final String yinZhang1;
  late final String yinZhang2;
  late final String yinZhang3;
  TextStyle textStyle;
  Size size;
  TenGanKeYingYinZhang(
      {super.key,
      required this.geJuName,
      required this.jiXiong,
      this.size = const Size(48, 48),
      this.textStyle = const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)}) {
    List<String> juName = geJuName.split("");
    yinZhang0 = juName[0];
    yinZhang1 = juName[1];
    yinZhang2 = juName[2];
    yinZhang3 = juName[3];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  ConstResourcesMapper.jiXiongColorMapper[jiXiong]!,
                  // Colors.blueGrey.shade700,
                  BlendMode.srcIn),
              child: Image.asset("assets/icons/yin_zhang.png")),
        ),
        Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    yinZhang2,
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                  AutoSizeText(
                    yinZhang3,
                    style: textStyle,
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    yinZhang0,
                    style: textStyle,
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                  AutoSizeText(
                    yinZhang1,
                    style: textStyle,
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
