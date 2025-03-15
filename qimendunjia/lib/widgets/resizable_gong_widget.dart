import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/each_gong_ge_ju.dart';
import 'package:qimendunjia/model/each_gong_wang_shuai.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';
import 'package:qimendunjia/utils/nine_yi_utils.dart';
import 'package:qimendunjia/widgets/wang_shuai_hint.dart';
import 'package:qimendunjia/widgets/wang_shuai_hint_top_down.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_most_popular_ge_ju.dart';
import '../model/each_gong.dart';
import '../model/qi_yi_ru_gong.dart';
import '../ui_models/ui_each_gong_model.dart';
import '../ui_models/ui_pan_meta_model.dart';
import '../ui_models/ui_ten_gan_key_ying_ge_ju.dart';
import '../utils/constant_ui_resources_of_qi_men.dart';

class ResizableGongWidget extends StatefulWidget {
  double cardSize;
  double miniFontSize = 16;
  bool showHint = true;
  bool withYinGan = true;
  bool withAnGan = true;
  UIEachGongModel uiGongModel;

  ResizableGongWidget({
    super.key,
    required this.uiGongModel,
    required this.cardSize,
    required this.withAnGan,
    required this.withYinGan,
    required this.showHint,
  });

  @override
  State<ResizableGongWidget> createState() => _ResizableGongWidgetState();
}

class _ResizableGongWidgetState extends State<ResizableGongWidget> {
  double get cardSize => widget.cardSize;
  bool get showHint => widget.showHint;
  double get miniFontSize => widget.miniFontSize;

  EachGong get gong => widget.uiGongModel.gong;
  EachGongWangShuai get wangShuai => widget.uiGongModel.gongWangShuai;
  UIPanMetaModel get panMeta => widget.uiGongModel.panMete;
  UITenGanKeYingGeJu get tenGanKeYingGeJu =>
      widget.uiGongModel.tenGanKeYingGeJu;
  EachGongGeJu get gongGeJu => widget.uiGongModel.eachGongGeJu;

  bool get isZhiFuStar => gong.star == widget.uiGongModel.panMete.zhiFuStar;
  bool get isJiStarZhiFu =>
      gong.isJiTianQin &&
      widget.uiGongModel.panMete.zhiFuStar == NineStarsEnum.QIN;
  bool get isZhiShiDoor => gong.door == widget.uiGongModel.panMete.zhiShiDoor;
  @override
  Widget build(BuildContext context) {
    return buildGong();
  }

  // shoule delete
  bool displayTenGanKeYing = true;
  bool displayGeJu = true;
  Duration duration = const Duration(milliseconds: 400);

  Widget buildGong() {
    double paddingSideWidth = cardSize * .08;
    if (paddingSideWidth < 12) {
      paddingSideWidth = 0;
    }
    double centerWidth = cardSize - paddingSideWidth * 2;
    double centerBoxWidth = (cardSize * 0.4) * .7;
    double centerSideWidth = (cardSize * 0.4) * .25 * 1.6;

    double fontSize = (cardSize * 0.4) * .3;
    if (fontSize < 16) {
      fontSize = 16;
    }
    double jiFontSize = fontSize * .8;
    double hintFontSize = jiFontSize * .5;

    // Duration duration = Duration(milliseconds: 400);
    Size leftRightSideSize = Size(paddingSideWidth, cardSize);
    Size topBottomSideSize = Size(centerWidth, paddingSideWidth);

    bool isHor = (centerBoxWidth + centerSideWidth * 2) <= 120;
    return AnimatedContainer(
      duration: Duration.zero,
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftSidePanelContent(leftRightSideSize),
              SizedBox(
                width: centerWidth,
                height: cardSize,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    topSidePanelContent(topBottomSideSize),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: duration,
                              alignment: isHor
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child: yinAnGanColumn(
                                  jiFontSize, hintFontSize, isHor),
                            ),
                            AnimatedContainer(
                              duration: duration,
                              width: fontSize * 3,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: fontSize * 3,
                                    alignment: Alignment.center,
                                    child: _gods(
                                        gong.god, fontSize * 2, hintFontSize),
                                  ),
                                  SizedBox(
                                      width: fontSize * 3,
                                      child: _stars(
                                          gong.star,
                                          fontSize,
                                          jiFontSize,
                                          hintFontSize,
                                          gong.isJiTianQin,
                                          isHor)),
                                  Container(
                                      width: fontSize * 3,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          // _doors("休门",fontSize* 2,fontSize * .5,showHint: showHint),
                                          _doors(gong.door, fontSize,
                                              hintFontSize),
                                          Text(gong.diGod.name,
                                              style: ConstantUiResourcesOfQiMen
                                                  .nineStarTextStyle
                                                  .copyWith(
                                                      fontSize: fontSize * .6,
                                                      color: Colors.grey
                                                          .withOpacity(.8)))
                                        ],
                                      ))
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                tianDiPanGanMarked(
                                    gong.tianPan,
                                    wangShuai.tianPanMonthZhangSheng,
                                    wangShuai.tianPanAnGanGongZhangSheng,
                                    fontSize,
                                    hintFontSize,
                                    jiFontSize,
                                    showHint,
                                    gong.tianPanJiGan,
                                    wangShuai.tianPanJiGanMonthZhangSheng,
                                    wangShuai.tianPanJiGanGongZhangSheng),
                                const SizedBox(
                                  height: 4,
                                ),
                                tianDiPanGanMarked(
                                    gong.diPan,
                                    wangShuai.diPanMonthZhangSheng,
                                    wangShuai.diPanGongZhangSheng,
                                    fontSize,
                                    hintFontSize,
                                    jiFontSize,
                                    showHint,
                                    gong.diPanJiGan,
                                    wangShuai.diPanJiGanMonthZhangSheng,
                                    wangShuai.diPanJiGanMonthZhangSheng,
                                    isTianPan: false),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    bottomSidePanelContent(topBottomSideSize),
                  ],
                ),
              ),
              rightSidePanelContent(leftRightSideSize),
            ],
          ),
          if (displayTenGanKeYing)
            AnimatedPositioned(
              left: paddingSideWidth * .5,
              bottom: paddingSideWidth * .5,
              duration: duration,
              child: _tenGanKeYingGeJu(tenGanKeYingGeJu.tianGeJu),
            ),
          if (displayTenGanKeYing && tenGanKeYingGeJu.tianPanJiGanGeJu != null)
            AnimatedPositioned(
              right: paddingSideWidth * .5,
              bottom: paddingSideWidth * .5,
              duration: duration,
              child: _tenGanKeYingGeJu(tenGanKeYingGeJu.tianPanJiGanGeJu!),
            ),
          if (displayTenGanKeYing && tenGanKeYingGeJu.tianDiJiGanGeJu != null)
            AnimatedPositioned(
              right: paddingSideWidth * .5,
              bottom: paddingSideWidth * .5,
              duration: duration,
              child: _tenGanKeYingGeJu(tenGanKeYingGeJu.tianDiJiGanGeJu!),
            ),
          if (displayGeJu)
            AnimatedPositioned(
                top: paddingSideWidth * .5,
                left: paddingSideWidth * .5,
                duration: const Duration(milliseconds: 200),
                child: buildGongGeJu()),
          if (widget.uiGongModel.qiYiRuGongList != null &&
              widget.uiGongModel.qiYiRuGongList!.isNotEmpty &&
              displayGeJu)
            AnimatedPositioned(
                right: paddingSideWidth * .5,
                top: 0,
                bottom: 0,
                duration: duration,
                child: buildThreeQiRuGong(widget.uiGongModel.qiYiRuGongList!)),
        ],
      ),
    );
  }

  Widget buildThreeQiRuGong(List<QiYiRuGong> qiYiRuGongList) {
    return Row(
        children: qiYiRuGongList
            .map((qi) => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 96,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                ConstResourcesMapper
                                    .jiXiongColorMapper[qi.geJuJiXiong]!,
                                BlendMode.srcIn),
                            child: Image.asset(
                              "assets/icons/long_yin_zhang.png",
                              width: 64,
                              height: 20,
                            )),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: qi.geJuName
                          .split("")
                          .map((c) => Text(c,
                              style: GoogleFonts.maShanZheng(
                                  fontSize: 16,
                                  height: 1.0,
                                  color: Colors.white)))
                          .toList(),
                    )
                  ],
                ))
            .toList());
  }

  Widget buildGongGeJu() {
    List<EnumMostPopularGeJu> mostGeJu = [
      ...gongGeJu.tianDiPanGeJuList,
    ];
    if (gongGeJu.tianPanJiGanWithDiPanList != null &&
        gongGeJu.tianPanJiGanWithDiPanList!.isNotEmpty) {
      mostGeJu.addAll(gongGeJu.tianPanJiGanWithDiPanList!);
    }
    if (gongGeJu.tianPanWithDiPanJiGanList != null &&
        gongGeJu.tianPanWithDiPanJiGanList!.isNotEmpty) {
      mostGeJu.addAll(gongGeJu.tianPanWithDiPanJiGanList!);
    }
    if (gongGeJu.tianDiJiGanList != null &&
        gongGeJu.tianDiJiGanList!.isNotEmpty) {
      mostGeJu.addAll(gongGeJu.tianDiJiGanList!);
    }
    List<Widget> geJuWidgets = mostGeJu
        .map((geJu) => geJu.jiXiong.isJi()
            ? ge_ju_template_small(
                geJu.name,
                geJu.jiXiong,
                const Color.fromRGBO(59, 78, 61, 1),
                const Color.fromRGBO(240, 167, 46, 1))
            : GeJuPanelTemplateXiong1(
                name: geJu.name,
                backgroundColor: const Color.fromRGBO(63, 75, 80, 1),
                foregroundColor: const Color.fromRGBO(185, 128, 124, 1),
                size: const Size(120, 32),
              ))
        .toList();

    List<Widget> nineDun = [
      gongGeJu.tianDiPanNineDun,
      gongGeJu.tianJiDiPanNineDun,
      gongGeJu.tianDiJiPanNineDun,
    ]
        .where((nineDun) => nineDun != null)
        .map((nineDun) => ge_ju_template_small(
            nineDun!.name,
            JiXiongEnum.JI,
            const Color.fromRGBO(32, 50, 54, 1),
            const Color.fromRGBO(209, 181, 146, 1)))
        .toList();

    List<Widget> zhaJiaList = [
      gongGeJu.tianJiDiPanZhaJia,
      gongGeJu.tianDiPanZhaJia
    ]
        .where((nineDun) => nineDun != null)
        .map((nineDun) => ge_ju_template_small(
            nineDun!.name,
            JiXiongEnum.JI,
            const Color.fromRGBO(25, 44, 59, 1),
            const Color.fromRGBO(176, 132, 88, 1)))
        .toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (geJuWidgets.isNotEmpty) geJuWidgets.first,
        if (nineDun.isNotEmpty) nineDun.first,
        if (nineDun.isEmpty && zhaJiaList.isNotEmpty) zhaJiaList.first,
      ],
    );
  }

  Widget _tenGanKeYingGeJu(TenGanKeYingGeJu tenGanKeYingGeJu) {
    List<String> nameChar = tenGanKeYingGeJu.geJuNames.first.split("");
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage("assets/icons/yin_zhang.png"),
              colorFilter: ColorFilter.mode(
                  ConstResourcesMapper
                      .jiXiongColorMapper[tenGanKeYingGeJu.jiXiong]!,
                  BlendMode.srcIn),
              fit: BoxFit.cover)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text("朱",style: TextStyle(fontSize: 52 * .3,color: Colors.white),),
              Text(nameChar[0],
                  style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle
                      .copyWith(fontSize: 52 * .3, color: Colors.white)),
              Text(nameChar[1],
                  style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle
                      .copyWith(fontSize: 52 * .3, color: Colors.white)),
              // Text("雀",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text("投",style: TextStyle(fontSize: 52 * .3,color: Colors.white)),
              // Text("江",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
              Text(nameChar[2],
                  style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle
                      .copyWith(fontSize: 52 * .3, color: Colors.white)),
              Text(nameChar[3],
                  style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle
                      .copyWith(fontSize: 52 * .3, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _gods(EightGodsEnum god, double width, double sideWidth) {
    bool isZhiFu = god == EightGodsEnum.ZHI_FU;
    Duration duration = const Duration(milliseconds: 400);
    double centerBoxWidth = width;
    if (centerBoxWidth < 24) {
      centerBoxWidth = 24;
    }
    double fontSize = width * .5;
    bool isSingleChar = false;
    if (fontSize < miniFontSize) {
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    double centerBoxHeight = width * .5;
    // double sideWidth = fontSize * .5;
    double totalWidth = centerBoxWidth + sideWidth * 2;

    Size hintBoxSize = Size(sideWidth, centerBoxHeight);
    return AnimatedContainer(
      duration: duration,
      height: centerBoxHeight + 4,
      // width: showHint?totalWidth:centerBoxWidth,
      width: totalWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
              height: centerBoxHeight < miniFontSize
                  ? miniFontSize
                  : centerBoxHeight,
              width: totalWidth < miniFontSize ? miniFontSize : totalWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WangShuaiHint(
                    textTuple2: Tuple2(wangShuai.godGongWangShuai.name, ""),
                    size: hintBoxSize,
                    showHint: showHint,
                    duration: duration,
                  ),
                  isSingleChar
                      ? Container(
                          alignment: Alignment.center,
                          height: miniFontSize,
                          width: miniFontSize,
                          child: Text(
                            god.name.split("").last,
                            maxLines: 1,
                            style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                                .copyWith(
                                    color: isZhiFu
                                        ? const Color.fromRGBO(176, 31, 36, 1)
                                        : const Color.fromRGBO(28, 45, 37, 1),
                                    fontSize: miniFontSize),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          height: centerBoxHeight,
                          width: centerBoxWidth,
                          child: Text(
                            god.name,
                            maxLines: 1,
                            style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                                .copyWith(
                              fontSize: fontSize,
                              shadows: [
                                const Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                  AnimatedContainer(
                    duration: duration,
                    width: showHint ? sideWidth : 0,
                  ),
                ],
              )),
          if (isZhiFu && !isSingleChar)
            AnimatedPositioned(
              duration: duration,
              right: showHint ? sideWidth : 0,
              top: 0,
              child: Container(
                width: 12,
                height: miniFontSize * 2,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/icons/chinese-red-ink-seal.png"),
                      colorFilter:
                          ColorFilter.mode(Colors.red, BlendMode.srcIn),
                      fit: BoxFit.cover),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("贵",
                        style: ConstantUiResourcesOfQiMen.eightDoorTextStyle
                            .copyWith(fontSize: 10, color: Colors.yellow)),
                    Text("人",
                        style: ConstantUiResourcesOfQiMen.eightDoorTextStyle
                            .copyWith(fontSize: 10, color: Colors.yellow)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _doors(EightDoorEnum door, double fontSize, double sideWidth) {
    String doorName = door.name;
    // double fontSize = width * .5;
    // double sideWidth = fontSize * .5;
    double totalWidth = (fontSize + sideWidth) * 2;

    double centerBoxWidth = fontSize * 2;
    double centerBoxHeight = fontSize;
    if (centerBoxWidth < 24) {
      centerBoxWidth = 24;
    }
    // double totalWidth = width * 1.5;
    // double fontSize = width * .5;
    bool isSingleChar = false;
    if (fontSize < miniFontSize) {
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    // double sideWidth = fontSize * .5;
    Size hintBoxSize = Size(sideWidth, centerBoxHeight);
    return Container(
      height: isSingleChar ? fontSize : centerBoxHeight,
      width: isSingleChar ? fontSize : totalWidth,
      alignment: Alignment.center,
      // color: Colors.yellow,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isSingleChar && isZhiShiDoor)
            Positioned(
                bottom: -2, child: _buildZhiShiDoor(centerBoxWidth + 24)),
          Positioned(
            top: 0,
            child: SizedBox(
              height: isSingleChar ? fontSize : centerBoxHeight,
              width: isSingleChar ? fontSize : totalWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      // color:Colors.yellow.withOpacity(.1),
                      child: WangShuaiHint(
                    textTuple2: Tuple2(wangShuai.doorMonthWangShuai.name,
                        wangShuai.doorGongWangShuai.name),
                    size: hintBoxSize,
                    showHint: showHint,
                    duration: duration,
                  )),
                  isSingleChar
                      ? Container(
                          alignment: Alignment.center,
                          height: miniFontSize,
                          width: miniFontSize,
                          child: Text(
                            doorName.split("").first,
                            maxLines: 1,
                            style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                                .copyWith(
                                    color: isZhiShiDoor
                                        ? const Color.fromRGBO(176, 31, 36, 1)
                                        : const Color.fromRGBO(28, 45, 37, 1),
                                    fontSize: miniFontSize),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          height: centerBoxHeight,
                          width: centerBoxWidth,
                          child: Text(
                            doorName,
                            maxLines: 1,
                            style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                                .copyWith(
                              fontSize: fontSize,
                              shadows: [
                                const Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: centerBoxHeight,
                    width: showHint ? sideWidth : 0,
                    alignment: Alignment.centerLeft,
                    color: Colors.blue.withOpacity(.1),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            end: const Offset(0, 0),
                            begin: const Offset(-1, 0),
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: showHint && wangShuai.doorGongRelationship != null
                          // ?_buildDescYinZhang(widget.wangShuai.doorGongRelationship!.name,widget.wangShuai.doorGongRelationship!.singleCharName,sideWidth,centerBoxHeight)
                          ? _buildDescYinZhang(wangShuai.doorGongRelationship!,
                              sideWidth, centerBoxHeight)
                          : Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned(
          //   child: Container(
          //   // width:centerBoxWidth,
          //   // height: 12,
          //   child: ColorFiltered(
          //       colorFilter: ColorFilter.mode(
          //           Colors.blueGrey.withOpacity(.1),
          //           BlendMode.srcIn),
          //       child: Image.asset("assets/icons/mu.png")),
          // ),)
        ],
      ),
    );
  }

  // Widget _stars(NineStarsEnum star,double width,double sideWidth,bool isJiTianQin,bool isHor){
  Widget _stars(NineStarsEnum star, double fontSize, double jiFontSize,
      double hintSize, bool isJiTianQin, bool isHor) {
    String starName = star.name;
    double baseWidth = fontSize;
    bool isSingleChar = false;
    if (fontSize < miniFontSize) {
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    if (isSingleChar) {
      return Container(
        height: fontSize + 10,
        width: fontSize,
        alignment: Alignment.center,
        // color: Colors.blueAccent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: SizedBox(
                height: fontSize,
                width: fontSize,
                child: Row(
                  children: [
                    WangShuaiHint(
                      size: Size(hintSize, miniFontSize),
                      showHint: showHint,
                      duration: const Duration(milliseconds: 400),
                      textTuple2: const Tuple2("旺", "衰"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: miniFontSize,
                      width: miniFontSize,
                      child: Text(
                        starName.split("").last,
                        maxLines: 1,
                        style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                            .copyWith(
                                color: isJiStarZhiFu
                                    ? const Color.fromRGBO(176, 31, 36, 1)
                                    : const Color.fromRGBO(28, 45, 37, 1),
                                fontSize: miniFontSize),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isJiTianQin)
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 10,
                        width: 10,
                        child: Text(
                          NineStarsEnum.QIN.name.split("").last,
                          maxLines: 1,
                          style: ConstantUiResourcesOfQiMen.nineStarTextStyle
                              .copyWith(
                                  color: isJiStarZhiFu
                                      ? const Color.fromRGBO(176, 31, 36, 1)
                                      : const Color.fromRGBO(28, 45, 37, 1),
                                  fontSize: 10),
                        ),
                      ),
                      WangShuaiHint(
                        size: Size(hintSize, miniFontSize * 0.75),
                        showHint: showHint,
                        duration: duration,
                        textTuple2: Tuple2(wangShuai.starMonthWangShuai.name,
                            wangShuai.starGongWangShuai.name),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      );
    }

    double minHeight = baseWidth;
    double maxHeight = baseWidth * 2;
    double minWidth = baseWidth;
    double maxWidth = baseWidth * 2;
    double maxBoxWidth = isHor ? maxWidth : minWidth;
    double maxBoxHeight = isHor ? minHeight : maxHeight;
    // double topHeight = minHeight * 0.75;
    // double jiStarWidth = topHeight;
    // double sizeWidth = topHeight;
    double minFontSize = 16;
    // double sideWidth = fontSize * .5;
    // double jiStarFontSize = topHeight * .5;
    TextStyle tianQinFontStyle =
        ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(
      fontSize: jiFontSize,
      shadows: [
        const Shadow(
          offset: Offset(1, 1),
          blurRadius: 3,
          color: Colors.grey,
        ),
      ],
    );
    TextStyle starFontStyle =
        ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(
      fontSize: fontSize,
      shadows: [
        const Shadow(
          offset: Offset(1, 1),
          blurRadius: 3,
          color: Colors.grey,
        ),
      ],
    );

    double boxMaxWidth = (fontSize + hintSize) * 2;
    double boxMaxHeight = fontSize + jiFontSize;
    return AnimatedContainer(
      duration: duration,
      alignment: isHor ? Alignment.center : Alignment.centerLeft,
      width: isHor ? boxMaxWidth : boxMaxHeight,
      height: isHor ? boxMaxHeight : boxMaxWidth,
      // color: Colors.red.withOpacity(.1),
      // color: Colors.indigo.withOpacity(.1),
      // width:  isHor ?maxWidth + sideWidth*2:maxWidth+sizeWidth*2,
      child: Stack(
        children: [
          if (isJiStarZhiFu)
            isHor
                ? Positioned(
                    top: jiFontSize * .5,
                    right: 0,
                    child: _buildZhiFuStar(jiFontSize * 3))
                : Positioned(
                    top: 0,
                    left: minWidth * .7,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: _buildZhiFuStar(jiFontSize * 3),
                    )),
          if (isZhiFuStar)
            isHor
                ? Positioned(
                    bottom: 0,
                    left: fontSize >= 16 ? 0 : 16,
                    child: _buildZhiFuStar(
                        fontSize >= 16 ? maxWidth + hintSize * 2 : 16 + 8))
                : Positioned(
                    top: 0,
                    left: 0,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: _buildZhiFuStar(maxWidth + hintSize * 2),
                    )),
          // 星 旺衰
          AnimatedPositioned(
            duration: duration,
            left: 0,
            top: isHor ? jiFontSize : 0,
            child: WangShuaiHintTopDown(
              top: Container(
                width: fontSize,
                height: hintSize,
                // height: height,
                alignment:
                    isHor ? Alignment.bottomRight : Alignment.bottomCenter,
                // alignment: Alignment.topCenter,
                child: AutoSizeText(
                  wangShuai.starMonthWangShuai.name,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                      height: 1),
                  minFontSize: 8,
                  maxFontSize: 24,
                ),
              ),
              bottom: Container(
                width: fontSize,
                height: hintSize,
                // height: height,
                alignment: isHor ? Alignment.topRight : Alignment.topCenter,
                // alignment: Alignment.topCenter,
                child: AutoSizeText(
                  wangShuai.starGongWangShuai.name,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                      height: 1),
                  minFontSize: 8,
                  maxFontSize: 24,
                ),
              ),
              size: isHor
                  ? Size(hintSize, fontSize)
                  : Size(fontSize, (fontSize + hintSize) * 2),
              showHint: showHint,
              duration: duration,
              alignment: isHor ? Alignment.centerRight : Alignment.center,
            ),
          ),
          if (isJiTianQin)
            // 寄天禽 旺衰
            AnimatedPositioned(
              duration: duration,
              // top: isHor?0:topHeight * .5,
              top: 0,
              left: isHor ? (hintSize + maxBoxWidth) : minWidth * .7,
              child: WangShuaiHintTopDown(
                top: Container(
                  width: fontSize,
                  height: hintSize,
                  alignment:
                      isHor ? Alignment.bottomRight : Alignment.bottomCenter,
                  child: AutoSizeText(
                    wangShuai.starMonthWangShuai.name,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w300,
                        height: 1),
                    minFontSize: 8,
                    maxFontSize: 24,
                  ),
                ),
                bottom: Container(
                  width: fontSize,
                  height: hintSize,
                  // height: height,
                  alignment: isHor ? Alignment.topRight : Alignment.topCenter,
                  // alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    wangShuai.starGongWangShuai.name,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w300,
                        height: 1),
                    minFontSize: 8,
                    maxFontSize: 24,
                  ),
                ),
                size: isHor
                    ? Size(hintSize, jiFontSize)
                    : Size(jiFontSize, (jiFontSize + hintSize) * 2),
                showHint: showHint,
                duration: duration,
                alignment: isHor ? Alignment.centerRight : Alignment.center,
              ),
            ),
          if (isJiTianQin)
            AnimatedPositioned(
              // top: isHor?0:topHeight,
              top: isHor ? 0 : hintSize,
              left: isHor
                  ? boxMaxWidth - hintSize - jiFontSize * 2
                  : fontSize * .7, // `fontSize * .7` UI显示更紧凑，为中间腾出空间
              right: isHor ? 0 : null,
              duration: duration,
              child: AnimatedContainer(
                  duration: duration,
                  width: isHor ? maxBoxWidth + jiFontSize : jiFontSize,
                  height: isHor ? jiFontSize : jiFontSize * 2,
                  // color: Colors.yellow.withOpacity(.4),
                  child: Stack(alignment: Alignment.topLeft, children: [
                    Container(
                      width: jiFontSize,
                      height: jiFontSize,
                      alignment: Alignment.center,
                      child: Text(NineStarsEnum.QIN.name.split("").first,
                          style: tianQinFontStyle),
                    ),
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment:
                            isHor ? Alignment.topRight : Alignment.bottomCenter,
                        // width:maxBoxWidth-sizeWidth,
                        width: isHor ? jiFontSize * 2 : jiFontSize,
                        // height: maxWidth - animationWidth < 24?24:maxWidth-animationWidth+16,
                        height: isHor ? jiFontSize : jiFontSize * 2,
                        // color: Colors.blue.withOpacity(.1),
                        child: Container(
                          // color: Colors.red.withOpacity(.1),
                          height: jiFontSize,
                          width: jiFontSize,
                          alignment: Alignment.center,
                          child: Text(NineStarsEnum.QIN.name.split("").last,
                              style: tianQinFontStyle),
                        )),
                  ])),
            ),
          AnimatedPositioned(
              duration: duration,
              top: isHor ? jiFontSize : hintSize,
              left: isHor ? hintSize : 0,
              child: Row(children: [
                Stack(alignment: Alignment.topLeft, children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          end: const Offset(0, 0),
                          begin: const Offset(-1, 0),
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: fontSize >= minFontSize
                        ? Container(
                            width: fontSize,
                            height: fontSize,
                            // width: baseWidth,
                            // height: baseWidth,
                            // color: Colors.purple.withOpacity(.1),
                            alignment: Alignment.center,
                            child: Text(starName.split("").first,
                                style: starFontStyle),
                          )
                        : Container(),
                  ),
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: isHor
                          ? (fontSize < minFontSize
                              ? Alignment.center
                              : Alignment.topRight)
                          : Alignment.bottomCenter,
                      width:
                          fontSize >= minFontSize ? maxBoxWidth : fontSize * 2,
                      height: maxBoxHeight,
                      child: Container(
                        // color: Colors.red.withOpacity(.1),
                        width: fontSize,
                        height: fontSize,
                        // height: baseWidth,
                        // width: baseWidth,
                        alignment: Alignment.center,
                        child:
                            Text(starName.split("").last, style: starFontStyle),
                      )),
                ]),
                isHor
                    ? SizedBox(
                        width: hintSize,
                        height: maxBoxHeight,
                        // color: Colors.grey.withOpacity(.5),
                      )
                    : const SizedBox()
              ])),
        ],
      ),
    );
  }

  Widget _buildZhiFuStar(double width) {
    return AnimatedContainer(
        width: width,
        height: width * .2,
        alignment: Alignment.center,
        duration: Duration.zero,
        child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/wide-black-ink-line.png",
            )));
  }

  Widget _buildZhiShiDoor(double width) {
    return AnimatedContainer(
        width: width,
        height: width * .2,
        alignment: Alignment.center,
        // duration: Duration.zero,
        duration: const Duration(milliseconds: 200),
        child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/wide-black-ink-radian-line2.png",
            )));
  }

  Widget _buildDescYinZhang(GongAndDoorRelationship gongAndDoorRelationship,
      double width, double height) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            // color: Colors.indigo,
            image: DecorationImage(
                fit: BoxFit.fill,
                //
                colorFilter: ColorFilter.mode(
                    ConstantUiResourcesOfQiMen.gongDoorRelationshipColorMapper[
                        gongAndDoorRelationship]!,
                    BlendMode.srcIn),
                image: const AssetImage("assets/icons/red-ink-background.png")),
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(16),
            //   topRight: Radius.circular(16),
            //   bottomLeft: Radius.circular(8),
            //   bottomRight: Radius.circular(8),
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
              )
            ]),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: height < 20
              ? Container(
                  width: width,
                  height: width,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    gongAndDoorRelationship.singleCharName,
                    maxLines: 1,
                    minFontSize: 8,
                    maxFontSize: 12,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                          )
                        ]),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: width,
                      height: width,
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        gongAndDoorRelationship.name.split("").first,
                        maxLines: 1,
                        minFontSize: 8,
                        maxFontSize: 12,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                              )
                            ]),
                      ),
                    ),
                    Container(
                      width: width,
                      height: width,
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        gongAndDoorRelationship.name.split("").last,
                        maxLines: 1,
                        minFontSize: 8,
                        maxFontSize: 12,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                              )
                            ]),
                      ),
                    )
                  ],
                ),
        ));
  }

  Widget tianDiPanGanMarked(
      TianGan gan,
      TwelveZhangSheng monthly,
      TwelveZhangSheng gongZhangSheng,
      double fontSize,
      double hintFontSize,
      double jiFontSize,
      bool showHint,
      TianGan? jiGan,
      TwelveZhangSheng? jiGanMonthly,
      TwelveZhangSheng? jiGanGong,
      {bool isTianPan = true}) {
    bool? isMuOrKu =
        NineYiUtils.checkMuOrKu(panMeta.monthToken, gan, gong.gongGua);
    bool? isJiGanMuOrKu = jiGan == null
        ? null
        : NineYiUtils.checkMuOrKu(panMeta.monthToken, jiGan, gong.gongGua);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment:
          isTianPan ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              // height:showHint?hintFontSize:0,
              height: hintFontSize,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: showHint
                      ? AutoSizeText(
                          monthly.name,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w300,
                              height: 1),
                          minFontSize: 8,
                          maxFontSize: 24,
                        )
                      : Container()),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                if (panMeta.xunHeaderTianGan == gan)
                  SizedBox(
                    width: fontSize * .8,
                    height: fontSize * .8,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            ConstResourcesMapper.zodiacGanColors[TianGan.JIA]!,
                            BlendMode.srcIn),
                        child: Image.asset("assets/icons/red-ink-circle.png")
                        // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                        // child: Image.asset("assets/icons/jia_dun_jia.png")
                        ),
                  ),
                if (isMuOrKu != null)
                  SizedBox(
                    width: fontSize,
                    height: fontSize,
                    child: RotatedBox(
                      quarterTurns: 0,
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              isMuOrKu
                                  ? Colors.red.shade800
                                  : Colors.blue.shade600,
                              BlendMode.srcIn),
                          // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                          child: Image.asset("assets/icons/mu.png")),
                    ),
                  ),
                // SizedBox(
                //   width:fontSize *.7,
                //   height: fontSize * .7,
                //   child: ColorFiltered(
                //       colorFilter: ColorFilter.mode(
                //           Colors.blueGrey,
                //           BlendMode.srcIn),
                //       // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                //       child: Image.asset("assets/icons/jia_ru_mu.png")
                //   ),
                // ),
                if (NineYiUtils.isLiuYiJiXing(gan, gong.gongGua))
                  SizedBox(
                    width: fontSize,
                    height: fontSize,
                    child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                            Colors.blueGrey, BlendMode.srcIn),
                        child: Image.asset("assets/icons/ji_xing.png")),
                  ),
                Text(gan.name,
                    style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(
                        fontSize: fontSize,
                        color: ConstResourcesMapper.zodiacGanColors[gan],
                        shadows: [
                          Shadow(
                              color: ConstResourcesMapper.zodiacGanColors[gan]!
                                  .withOpacity(.4),
                              offset: const Offset(1, 1),
                              blurRadius: 2),
                          Shadow(
                              color: Colors.white.withOpacity(.2),
                              offset: const Offset(1, -1),
                              blurRadius: 2),
                        ])),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              // height:showHint?hintSize:0,
              height: hintFontSize,
              alignment: Alignment.topCenter,
              // color: Colors.red.withOpacity(.1),
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: showHint
                      ? AutoSizeText(
                          gongZhangSheng.name,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                              height: 1),
                          minFontSize: 8,
                          maxFontSize: 24,
                        )
                      : Container()),
            ),
          ],
        ),
        jiGan != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    // height:showHint?hintFontSize:0,
                    height: hintFontSize,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: const Offset(0, 0),
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: showHint
                            ? AutoSizeText(
                                jiGanMonthly!.name,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w300,
                                    height: 1),
                                minFontSize: 8,
                                maxFontSize: 24,
                              )
                            : Container()),
                  ),
                  Stack(
                    children: [
                      if (panMeta.xunHeaderTianGan == jiGan)
                        SizedBox(
                          width: jiFontSize * .8,
                          height: jiFontSize * .8,
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  ConstResourcesMapper
                                      .zodiacGanColors[TianGan.JIA]!,
                                  BlendMode.srcIn),
                              child:
                                  Image.asset("assets/icons/red-ink-circle.png")
                              // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                              // child: Image.asset("assets/icons/jia_dun_jia.png")
                              ),
                        ),
                      if (isJiGanMuOrKu != null)
                        SizedBox(
                          width: jiFontSize,
                          height: jiFontSize,
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  isJiGanMuOrKu
                                      ? Colors.red.shade800
                                      : Colors.blue.shade600,
                                  BlendMode.srcIn),
                              // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                              child: Image.asset("assets/icons/mu.png")),
                        ),
                      // SizedBox(
                      //   width:fontSize *.7,
                      //   height: fontSize * .7,
                      //   child: ColorFiltered(
                      //       colorFilter: ColorFilter.mode(
                      //           Colors.blueGrey,
                      //           BlendMode.srcIn),
                      //       // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                      //       child: Image.asset("assets/icons/jia_ru_mu.png")
                      //   ),
                      // ),

                      if (NineYiUtils.isLiuYiJiXing(jiGan, gong.gongGua))
                        SizedBox(
                          width: jiFontSize,
                          height: jiFontSize,
                          child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Colors.blueGrey, BlendMode.srcIn),
                              child: Image.asset("assets/icons/ji_xing.png")),
                        ),

                      Text(jiGan.name,
                          style: ConstantUiResourcesOfQiMen.tianGanTextStyle
                              .copyWith(
                                  fontSize: jiFontSize,
                                  color: ConstResourcesMapper
                                      .zodiacGanColors[jiGan])),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    // height:showHint?hintSize:0,
                    // height:hintFontSize,
                    height: hintFontSize,
                    alignment: Alignment.topCenter,
                    // color: Colors.red.withOpacity(.1),
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -1),
                              end: const Offset(0, 0),
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: showHint
                            ? AutoSizeText(
                                jiGanGong!.name,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300,
                                    height: 1),
                                minFontSize: 8,
                                maxFontSize: 24,
                              )
                            : Container()),
                  ),
                ],
              )
            : SizedBox(
                width: fontSize * .6,
              )
      ],
    );
  }

  Widget yinAnGanColumn(double jiFontSize, double hintFontSize, bool isHor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        yinAnGan(
            gong.tianPanAnGan,
            "天暗",
            wangShuai.tianPanAnGanMonthZhangSheng,
            wangShuai.tianPanAnGanGongZhangSheng,
            jiFontSize,
            hintFontSize,
            isHor,
            showHint,
            duration,
            Colors.grey),
        yinAnGan(
            gong.yinGan,
            "隐干",
            wangShuai.yinGanMonthZhangSheng,
            wangShuai.tianPanAnGanGongZhangSheng,
            jiFontSize,
            hintFontSize,
            isHor,
            showHint,
            duration,
            Colors.blueGrey),
        yinAnGan(
            gong.renPanAnGan,
            "人暗",
            wangShuai.renPanAnGanMonthZhangSheng,
            wangShuai.renPanAnGanGongZhangSheng,
            jiFontSize,
            hintFontSize,
            isHor,
            showHint,
            duration,
            Colors.grey),
      ],
    );
  }

  Widget yinAnGan(
    TianGan tian,
    String yinAnGan,
    TwelveZhangSheng monthly,
    TwelveZhangSheng gong,
    double yinAnGanfontSize,
    double yinAnGanHintSize,
    bool isHor,
    bool showHint,
    Duration duration,
    Color fontColor,
  ) {
    double tagTextFontSize = yinAnGanHintSize * .8;
    double yinAnGanHintFontSize = yinAnGanHintSize;
    if (yinAnGanHintFontSize > 12) {
      yinAnGanHintFontSize = 12;
    } else if (yinAnGanHintFontSize < 9) {
      yinAnGanHintFontSize = 9;
    }
    double tianGanSize = yinAnGanfontSize;
    return SizedBox(
      width: tianGanSize,
      height: yinAnGanfontSize + yinAnGanHintFontSize * 2 + 1,
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: showHint
                  ? Text(
                      isHor ? monthly.name.split("").last : monthly.name,
                      // monthly.name,
                      style: TextStyle(
                          color: Colors.black45,
                          fontSize: yinAnGanHintFontSize,
                          fontWeight: FontWeight.w300,
                          height: 1),
                      maxLines: 1,
                    )
                  : SizedBox(
                      height: yinAnGanHintFontSize,
                    )),
          Stack(
            children: [
              Text(tian.name,
                  style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(
                      fontSize: tianGanSize,
                      color: fontColor,
                      shadows: [
                        const Shadow(
                            color: Colors.black12,
                            offset: Offset(1, 1),
                            blurRadius: 2),
                      ])),
              Positioned(
                bottom: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Column(
                      children: [
                        Text(
                          yinAnGan.split("").first,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: tagTextFontSize,
                              fontWeight: FontWeight.w300,
                              height: 1),
                        ),
                        if (tagTextFontSize >= 8)
                          Text(
                            yinAnGan.split("").last,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: tagTextFontSize,
                                fontWeight: FontWeight.w300,
                                height: 1),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: showHint
                  ? Text(
                      isHor ? gong.name.split("").last : gong.name,
                      // gong.name,
                      style: TextStyle(
                          color: Colors.black45,
                          fontSize: yinAnGanHintFontSize,
                          fontWeight: FontWeight.w300,
                          height: 1),
                      maxLines: 1,
                    )
                  : SizedBox(
                      height: yinAnGanHintFontSize,
                    ))
        ],
      ),
    );
  }

  Widget topSidePanelContent(Size size) {
    DiZhi? diZhi;
    if (gong.gongGua == HouTianGua.Xun) {
      diZhi = DiZhi.SI;
    } else if (gong.gongGua == HouTianGua.Li) {
      diZhi = DiZhi.WU;
    } else if (gong.gongGua == HouTianGua.Kun) {
      diZhi = DiZhi.WEI;
    }
    if (panMeta.timeXunKong.toList().contains(diZhi) ||
        panMeta.horseLocation == diZhi) {
      return Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.bottomCenter,
        child: diZhi == null
            ? Container()
            : AnimatedSwitcher(
                duration: duration,
                child: size.height < 10
                    ? Container()
                    : _buildKongWangOrHorseStar(size.height, diZhi),
              ),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      // color: Colors.red.withOpacity(.1),
      alignment: Alignment.bottomCenter,
      child: diZhi == null
          ? Container()
          : AnimatedSwitcher(
              duration: duration,
              child: size.height < 10
                  ? Container()
                  : AutoSizeText(
                      diZhi.name,
                      style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle
                          .copyWith(
                              color: ConstResourcesMapper
                                  .zodiacZhiColors[diZhi]!
                                  .withOpacity(.8)),
                      minFontSize: 10,
                      maxFontSize: 32,
                    ),
            ),
    );
  }

  Widget bottomSidePanelContent(Size size) {
    DiZhi? diZhi;
    if (gong.gongGua == HouTianGua.Kan) {
      diZhi = DiZhi.ZI;
    } else if (gong.gongGua == HouTianGua.Gen) {
      diZhi = DiZhi.CHOU;
    } else if (gong.gongGua == HouTianGua.Qian) {
      diZhi = DiZhi.HAI;
    }
    if (panMeta.timeXunKong.toList().contains(diZhi) ||
        panMeta.horseLocation == diZhi) {
      return Container(
        width: size.width,
        height: size.height,
        // color: Colors.red.withOpacity(.1),
        alignment: Alignment.topCenter,
        child: diZhi == null
            ? Container()
            : AnimatedSwitcher(
                duration: duration,
                child: size.height < 10
                    ? Container()
                    : _buildKongWangOrHorseStar(size.height, diZhi),
              ),
      );
    }

    return Container(
      width: size.width,
      height: size.height,
      // color: Colors.red.withOpacity(.1),
      alignment: Alignment.topCenter,
      child: diZhi == null
          ? Container()
          : AnimatedSwitcher(
              duration: duration,
              child: size.height < 10
                  ? Container()
                  : AutoSizeText(
                      diZhi.name,
                      style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle
                          .copyWith(
                              color: ConstResourcesMapper
                                  .zodiacZhiColors[diZhi]!
                                  .withOpacity(.8)),
                      minFontSize: 10,
                      maxFontSize: 32,
                    ),
            ),
    );
  }

  Widget leftSidePanelContent(Size size) {
    DiZhi? diZhi;
    if (gong.gongGua == HouTianGua.Gen) {
      diZhi = DiZhi.YIN;
    } else if (gong.gongGua == HouTianGua.Zhen) {
      diZhi = DiZhi.MAO;
    } else if (gong.gongGua == HouTianGua.Xun) {
      diZhi = DiZhi.CHEN;
    }
    if (panMeta.timeXunKong.toList().contains(diZhi) ||
        panMeta.horseLocation == diZhi) {
      return Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.centerRight,
        child: diZhi == null
            ? Container()
            : AnimatedSwitcher(
                duration: duration,
                child: size.width < 10
                    ? Container()
                    : _buildKongWangOrHorseStar(size.width, diZhi),
              ),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.centerRight,
      child: diZhi == null
          ? Container()
          : AnimatedSwitcher(
              duration: duration,
              child: size.width < 10
                  ? Container()
                  : AutoSizeText(
                      diZhi.name,
                      style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle
                          .copyWith(
                              color: ConstResourcesMapper
                                  .zodiacZhiColors[diZhi]!
                                  .withOpacity(.8)),
                      minFontSize: 10,
                      maxFontSize: 32,
                    ),
            ),
    );
  }

  Widget rightSidePanelContent(Size size) {
    DiZhi? diZhi;
    if (gong.gongGua == HouTianGua.Qian) {
      diZhi = DiZhi.XU;
    } else if (gong.gongGua == HouTianGua.Dui) {
      diZhi = DiZhi.YOU;
    } else if (gong.gongGua == HouTianGua.Kun) {
      diZhi = DiZhi.SHEN;
    }
    if (panMeta.timeXunKong.toList().contains(diZhi) ||
        panMeta.horseLocation == diZhi) {
      return Container(
        width: size.width,
        height: size.height,
        // color: Colors.red.withOpacity(.1),
        alignment: Alignment.centerLeft,
        child: diZhi == null
            ? Container()
            : AnimatedSwitcher(
                duration: duration,
                child: size.width < 10
                    ? Container()
                    : _buildKongWangOrHorseStar(size.width, diZhi),
              ),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.centerLeft,
      child: diZhi == null
          ? Container()
          : AnimatedSwitcher(
              duration: duration,
              child: size.width < 10
                  ? Container()
                  : AutoSizeText(
                      diZhi.name,
                      style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle
                          .copyWith(
                              color: ConstResourcesMapper
                                  .zodiacZhiColors[diZhi]!
                                  .withOpacity(.8)),
                      minFontSize: 10,
                      maxFontSize: 32,
                    ),
            ),
    );
  }

  Widget ge_ju_template_small(
      String name, JiXiongEnum jiXiong, Color color, Color backColor) {
    // Color backColor = Color.fromRGBO(252, 204, 140, 1);
    // Color color = Color.fromRGBO(77, 79, 100, 1);
    double innerDotSize = 12;
    Container dot1 = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.5),
              offset: const Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]),
    );
    Container dot2 = Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color: backColor,
        // color:Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 = Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    // double width = 120;
    // double height = 36;
    double width = 100;
    double height = 28;

    // double outerWidth = 120;
    // double outerHeight = 52;
    double outerWidth = 120;
    double outerHeight = 32;
    double outerRadius = 10;
    double offset = 2;
    Size size = const Size(36, 18);
    return SizedBox(
      width: outerWidth,
      height: outerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            // width: outerWidth - 18-9-1,
            width: width + innerDotSize,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [dot1, dot1],
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(outerRadius),
                boxShadow: [
                  BoxShadow(
                    // color: Colors.black26,
                    color: color.withOpacity(.5),
                    offset: const Offset(1, 1), //阴影xy轴偏移量
                    blurRadius: 1, //阴影模糊程度
                    spreadRadius: 1, //阴影扩散程度
                  )
                ]),
          ),
          SizedBox(
            // width: outerWidth - 18 - 9 -6,
            width: width + innerDotSize - offset * 2,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [dot2, dot2],
            ),
          ),
          Container(
              width: width - 4,
              height: height - 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerRadius - offset),
                color: backColor,
              )),
          SizedBox(
            // width: outerWidth - 18 - 9 - 8,
            width: width + innerDotSize - offset * 3,
            height: outerHeight,
            // color: Colors.white.withOpacity(.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [dot3, dot3],
            ),
          ),
          Container(
            width: width - 6,
            height: height - 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius - offset),
              color: color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                    alignment: Alignment.center,
                    width: outerWidth * .5,
                    child: AutoSizeText(
                      name.split("").join(""),
                      style: GoogleFonts.maShanZheng(color: backColor),
                      maxLines: 1,
                      minFontSize: 10,
                      maxFontSize: 32,
                    )),
                Container(
                    height: outerHeight * .5,
                    width: 14,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          colorFilter:
                              ColorFilter.mode(backColor, BlendMode.srcIn),
                          image: const AssetImage(
                            "assets/icons/ji_xiong_yin_zhang.png",
                          )),
                    ),
                    child: AutoSizeText(
                      "吉",
                      style: GoogleFonts.longCang(
                          height: 1.0,
                          color: color,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                                color: Colors.white.withOpacity(.4),
                                blurRadius: 4)
                          ]),
                      maxLines: 1,
                      minFontSize: 8,
                      maxFontSize: 16,
                    ))
              ],
            ),
          ),
          FutureBuilder(
            future: precacheImage(
                const AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                        left: -2,
                        top: -2,
                        child: SizedBox(
                          // height: 24,
                          // width: 64,
                          height: 12,
                          width: 32,
                          child: ColorFiltered(
                              colorFilter:
                                  ColorFilter.mode(backColor, BlendMode.srcIn),
                              child: Image.asset(
                                "assets/icons/xiang_yun_line_1.png",
                              )),
                        ))
                    .animate(autoPlay: true)
                    .scale(
                        begin: Offset.zero,
                        end: const Offset(1, 1),
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
          FutureBuilder(
            future: precacheImage(
                const AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                        left: 0,
                        bottom: -2,
                        child: SizedBox.fromSize(
                          size: size,
                          child: ColorFiltered(
                              colorFilter:
                                  ColorFilter.mode(backColor, BlendMode.srcIn),
                              child: Image.asset(
                                "assets/icons/xiang_yun_wen_l.png",
                              )),
                        ))
                    .animate(autoPlay: true)
                    .moveX(
                        begin: outerWidth * .2,
                        end: 0,
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
          FutureBuilder(
            future: precacheImage(
                const AssetImage('assets/icons/xiang_yun_wen_r.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                  right: 2,
                  top: -2,
                  child: Container(
                    child: SizedBox.fromSize(
                        size: size,
                        child: ColorFiltered(
                            colorFilter:
                                ColorFilter.mode(backColor, BlendMode.srcIn),
                            child: Image.asset(
                              "assets/icons/xiang_yun_wen_r.png",
                            ))),
                  ),
                )
                        .animate(
                          autoPlay: true,
                        )
                        .moveX(
                            begin: -(outerWidth * .2),
                            end: 0,
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 800))
                    // .then()
                    // .animate(autoPlay: true,delay: Duration(milliseconds: 1000),onComplete: (an)=>an.repeat(),)
                    // .moveX(begin: 0,end: 24,curve: Curves.ease,duration: Duration(milliseconds: 800))
                    ;
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKongWangOrHorseStar(double size, DiZhi diZhi) {
    return Container(
      width: size,
      height: size,
      decoration: panMeta.timeXunKong.toList().contains(diZhi)
          ? BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                      ConstResourcesMapper.zodiacZhiColors[diZhi]!,
                      BlendMode.srcIn),
                  image: const AssetImage(
                      "assets/icons/thin-black-ink-circle.png")),
            )
          : null,
      child: panMeta.horseLocation != diZhi
          ? const SizedBox()
          : _buildHorseStar(ConstResourcesMapper.zodiacZhiColors[diZhi]!),
    );
  }

  Widget _buildHorseStar([Color color = Colors.black]) {
    return Lottie.asset("assets/lotties/horse_walking.json",
        delegates: LottieDelegates(values: [
          ValueDelegate.colorFilter(
            ["**"],
            value: ColorFilter.mode(color.withOpacity(1), BlendMode.src),
          )
        ]),
        repeat: true);
  }
}
