import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:flutter/material.dart';

class QiYiWangShuai extends StatelessWidget {
  final TianGan tianGan;
  bool withColor;
  bool showHint;
  final TwelveZhangSheng monthlyZhangSheng;
  final TwelveZhangSheng gongZhangSheng;
  TextStyle textStyle;
  TextStyle hintTextStyle;
  bool isSixYiJixing; // 六仪击刑
  bool? isGongRuMuOrKu; // 入墓
  bool isDunJia; // 甲隐遁其下
  bool isYinAnGan; // 是否是“隐暗干”
  Size textSize;

  QiYiWangShuai({
    super.key,
    required this.tianGan,
    required this.monthlyZhangSheng,
    required this.gongZhangSheng,
    this.textSize = const Size(32, 28),
    this.hintTextStyle = const TextStyle(
        height: 1.0,
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: Colors.black45),
    this.textStyle = const TextStyle(
        height: 1.0, fontSize: 24, fontWeight: FontWeight.normal),
    this.showHint = false,
    this.withColor = false,
    this.isSixYiJixing = false,
    required this.isGongRuMuOrKu,
    this.isDunJia = false,
    this.isYinAnGan = false,
  });

  @override
  Widget build(BuildContext context) {
    int showGlass = 0;
    if (isDunJia) {
      showGlass += 1;
    }
    if (isGongRuMuOrKu != null) {
      showGlass += 1;
    }
    if (isSixYiJixing) {
      showGlass += 1;
    }
    showGlass = 0;
    return Container(
        width: textSize.width,
        height: textSize.height + 20,
        alignment: Alignment.center,
        child: Stack(alignment: Alignment.center, children: [
          if (isDunJia && showHint)
            buildDunJia(isYinAnGan
                ? textStyle.color!.withOpacity(.4)
                : ConstResourcesMapper.zodiacGanColors[TianGan.JIA]!),
          if (isSixYiJixing && showHint)
            buildJiXing(isYinAnGan
                ? textStyle.color!.withOpacity(.4)
                : const Color.fromRGBO(0, 33, 81, .8)),
          if (isGongRuMuOrKu != null && showHint)
            Positioned(
                top: textSize.height * .5 - 2,
                child: buildRuMu(isYinAnGan
                    ? textStyle.color!.withOpacity(.4)
                    : (isGongRuMuOrKu!
                        ? const Color.fromRGBO(81, 0, 0, .8)
                        : const Color.fromRGBO(0, 81, 62, .8)))),

          // true
          // false
          showGlass >= 2 && showHint
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: Container(
                      width: textSize.width,
                      height: textSize.height,
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(128, 0, 0, .1), // Adjust opacity as needed
                        color: isYinAnGan
                            ? Colors.red.withOpacity(.1)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            textSize.width * .5), // Optional rounded corners
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          virt()
        ]));
  }

  Widget virt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: textSize.width,
          // width: 32,
          height: 10,
          alignment: Alignment.center,
          // color: Colors.blue.withOpacity(.1),
          child: showHint
              ? Text(monthlyZhangSheng.name, style: hintTextStyle)
              : const SizedBox(),
        ),
        Container(
            // width: 32,
            // height: 28,
            width: textSize.width,
            height: textSize.height,
            alignment: Alignment.center,
            // color: Colors.red.withOpacity(.2),
            child: AutoSizeText(
              tianGan.name,
              style: textStyle.copyWith(shadows: [
                Shadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 3,
                  offset: const Offset(0, 0),
                )
              ]),
              maxLines: 1,
              minFontSize: 18,
              maxFontSize: 28,
            )),
        Container(
          // width: 32,
          width: textSize.width,
          height: 10,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.center,
          child: showHint
              ? Text(gongZhangSheng.name, style: hintTextStyle)
              : const SizedBox(),
        )
      ],
    );
  }

  Widget hori() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 28,
          alignment: Alignment.topCenter,
          child: showHint
              ? Column(
                  children: monthlyZhangSheng.name
                      .split("")
                      .map((t) => Text(t, style: hintTextStyle))
                      .toList(),
                )
              : const SizedBox(),
        ),
        Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            // color: Colors.red.withOpacity(.6),
            child: AutoSizeText(
              tianGan.name,
              style: textStyle.copyWith(shadows: [
                Shadow(
                  color: Colors.grey.withOpacity(.2),
                  blurRadius: 3,
                  offset: const Offset(0, 0),
                )
              ]),
              maxLines: 1,
              minFontSize: 18,
              maxFontSize: 28,
            )),
        Container(
          width: 10,
          height: 28,
          // color: Colors.red.withOpacity(.1),
          alignment: Alignment.bottomCenter,
          child: showHint
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: gongZhangSheng.name
                      .split("")
                      .map((t) => Text(t, style: hintTextStyle))
                      .toList(),
                )
              : const SizedBox(),
        )
      ],
    );
  }

  Widget buildJiXing(Color color) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              color,
              // Colors.blue.shade900,
              //   Colors.black,
              // Color.fromRGBO(59,46,126,1), // 藏蓝
              //   Color.fromRGBO(46,78,126,.8), // 藏青
              BlendMode.srcIn),
          child: Image.asset(
            "assets/icons/ji_xing.png",
            width: 28,
            height: 28,
          )),
    );
  }

  Widget buildDunJia(Color color) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          child: Image.asset(
            "assets/icons/red-ink-circle.png",
            width: 28,
            height: 28,
          )),
    );
  }

  Widget buildRuMu(Color color) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              color,
              // Colors.blue.shade900,
              //   Colors.black,
              // Color.fromRGBO(59,46,126,1), // 藏蓝
              //   Color.fromRGBO(46,78,126,.8), // 藏青
              BlendMode.srcIn),
          child: Image.asset(
            "assets/icons/mu.png",
            width: 28,
            height: 36,
          )),
    );
  }
}
