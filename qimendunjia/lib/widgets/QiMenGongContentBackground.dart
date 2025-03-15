import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/enums.dart';
import 'package:common/widgets/eight_gua_widget.dart';
import 'package:flutter/material.dart';
import 'package:qimendunjia/widgets/season_24_tag.dart';

import '../model/ConstantQiMenNineGongDataClass.dart';

class QiMenGongContentBackground extends StatelessWidget {
  final ConstantQiMenNineGongDataClass qiMen;

  late Map<String, String> eightGuaMapper;
  late Map<DiZhi, Color> zodiacColors;
  late Map<String, Color> seasons24ColorMapper;

  TextStyle nineGongNumberTextStyle;
  TextStyle nineGongNameTextStyle;
  TextStyle nineStarsNameTextStyle;
  TextStyle eightSeasonTextStyle;
  TextStyle eightSkyDoorTextStyle;

  QiMenGongContentBackground({
    super.key,
    required this.qiMen,
    required this.eightGuaMapper,
    required this.zodiacColors,
    required this.seasons24ColorMapper,
    required this.eightSkyDoorTextStyle,
    this.nineStarsNameTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 16,
      height: 1,
    ),
    this.nineGongNameTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 64,
      height: 1,
    ),
    this.nineGongNumberTextStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 16,
      height: 1,
    ),
    this.eightSeasonTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
    ),
  });

  @override
  Widget build(BuildContext context) {
    // return centerContent(qiMen);
    return centerContentOnlyGua(qiMen);
  }

  Widget centerContentOnlyGua(ConstantQiMenNineGongDataClass qiMen) {
    var seasonName = qiMen.jieQiTuple.item1;
    Color color = seasons24ColorMapper[seasonName] ?? Colors.grey;
    double height = 80;
    double width = 80;
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: nineStarsNameTextStyle.color ?? Colors.grey,
                            width: 1),
                      ),
                      // color: Colors.red
                    ),
                    child: AutoSizeText(
                      qiMen.defaultStar.name,
                      maxLines: 1,
                      maxFontSize: 18,
                      minFontSize: 12,
                      style: nineStarsNameTextStyle.copyWith(
                          fontWeight: FontWeight.w600),
                    )
                    // child: Text,
                    ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Flexible(
            flex: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Flexible(
                  flex: 10,
                  child: Container(
                    // padding: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    // color: Colors.red.withOpacity(.1),
                    child: EightGuaWidget(
                      gua: HouTianGua.getGuaByName(qiMen.name),
                      yaoSize: const Size(56, 8),
                      intervalHeight: 2,
                      color: Colors.grey.withOpacity(.5),
                      withShadow: false,
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                AutoSizeText(
                  "「${qiMen.defaultDoor.name}」",
                  maxLines: 1,
                  maxFontSize: 18,
                  minFontSize: 12,
                  style: eightSkyDoorTextStyle,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget centerContent(ConstantQiMenNineGongDataClass qiMen) {
    var seasonName = qiMen.jieQiTuple.item1;
    Color color = seasons24ColorMapper[seasonName] ?? Colors.grey;
    double height = 80;
    double width = 80;
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: nineStarsNameTextStyle.color ?? Colors.grey,
                            width: 1),
                      ),
                      // color: Colors.red
                    ),
                    child: AutoSizeText(
                      qiMen.defaultStar.name,
                      maxLines: 1,
                      maxFontSize: 18,
                      minFontSize: 12,
                      style: nineStarsNameTextStyle.copyWith(
                          fontWeight: FontWeight.w600),
                    )
                    // child: Text,
                    ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Flexible(
            flex: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 5,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                            opacity: .8,
                            child: Transform.scale(
                                scale: .7,
                                child: Season24Tag(
                                  name: qiMen.jieQiTuple.item1,
                                  fontColor: color,
                                  borderColor: color,
                                  backgroundColor: color.withOpacity(.2),
                                  fontStyle: eightSeasonTextStyle,
                                ))),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Container(
                    // padding: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    alignment: Alignment.center,
                    // color: Colors.red.withOpacity(.1),
                    child: AutoSizeText(
                      qiMen.name,
                      maxLines: 1,
                      maxFontSize: 64,
                      minFontSize: 12,
                      style: nineGongNameTextStyle.copyWith(height: 1),
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 2.0, top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(
                          qiMen.number,
                          maxLines: 1,
                          maxFontSize: 18,
                          minFontSize: 12,
                          style: nineGongNumberTextStyle,
                        ),
                        const Expanded(child: SizedBox()),
                        AutoSizeText(
                          eightGuaMapper[qiMen.name]!,
                          maxLines: 1,
                          maxFontSize: 18,
                          minFontSize: 12,
                          style: nineGongNumberTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                AutoSizeText(
                  "「${qiMen.defaultDoor}」",
                  maxLines: 1,
                  maxFontSize: 18,
                  minFontSize: 12,
                  style: eightSkyDoorTextStyle,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
