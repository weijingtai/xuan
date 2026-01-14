import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qimendunjia/enums/enum_fu_fan_yin.dart';
import 'package:qimendunjia/ui_models/ui_pan_meta_model.dart';
import 'package:qimendunjia/utils/nine_yi_utils.dart';
import 'package:qimendunjia/widgets/qi_yi_wang_shuai.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_eight_door.dart';
import '../enums/enum_eight_gods.dart';
import '../enums/enum_nine_stars.dart';
import '../model/ConstantQiMenNineGongDataClass.dart';
import '../model/each_gong.dart';
import '../model/each_gong_wang_shuai.dart';
import '../model/shi_jia_qi_men.dart';
import '../model/ten_gan_ke_ying.dart';
import '../model/ten_gan_ke_ying_ge_ju.dart';
import '../ui_models/ui_ten_gan_key_ying_ge_ju.dart';
import '../utils/constant_ui_resources_of_qi_men.dart';
import '../utils/read_data_utils.dart';
import 'BounceDialog.dart';
import 'QiMenGongContentBackground.dart';

class NewEachGongWidget extends StatefulWidget {
  // ShiJiaQiMen pan;
  HouTianGua gua;
  EachGong gong;
  EachGongWangShuai gongWangShuai;
  UIPanMetaModel pan;
  UITenGanKeYingGeJu tenGanKeYingGeJu;
  ConstantQiMenNineGongDataClass? backgroundGong;
  bool withNormalBorder;
  bool withoutMenHuLuFang; // 是否不显示门户路方
  double gongSize;
  ValueNotifier<bool> showHintNotifier;
  NewEachGongWidget({
    super.key,
    required this.gua,
    required this.pan,
    required this.gong,
    required this.gongWangShuai,
    required this.backgroundGong,
    required this.withNormalBorder,
    required this.gongSize,
    required this.showHintNotifier,
    required this.tenGanKeYingGeJu,
    this.withoutMenHuLuFang = false,
  });

  @override
  State<NewEachGongWidget> createState() => _NewEachGongWidgetState();
}

class _NewEachGongWidgetState extends State<NewEachGongWidget> {
  TextStyle get twelveDiZhiTextStyle =>
      ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle;
  TextStyle get tianGanTextStyle => ConstantUiResourcesOfQiMen.tianGanTextStyle;
  TextStyle get eightDoorTextStyle =>
      ConstantUiResourcesOfQiMen.eightDoorTextStyle;
  TextStyle get nineStarTextStyle =>
      ConstantUiResourcesOfQiMen.nineStarTextStyle;
  TextStyle get eightGodsTextStyle =>
      ConstantUiResourcesOfQiMen.eightGodsTextStyle;
  TextStyle get wangShuaiTextStyle =>
      ConstantUiResourcesOfQiMen.wangShuaiTextStyle;
  TextStyle get nineGongNameTextStyle =>
      ConstantUiResourcesOfQiMen.nineGongNameTextStyle;
  TextStyle get nineGongNumberTextStyle =>
      ConstantUiResourcesOfQiMen.nineGongNumberTextStyle;
  TextStyle get nineStarsNameTextStyle =>
      ConstantUiResourcesOfQiMen.nineStarsNameTextStyle;
  TextStyle get eightSkyDoorTextStyle =>
      ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle;
  TextStyle get eightSeasonTextStyle =>
      ConstantUiResourcesOfQiMen.eightSeasonTextStyle;
  TextStyle get doorGongtextStyle =>
      ConstantUiResourcesOfQiMen.doorGongtextStyle;

  EachGong get gong => widget.gong;
  EachGongWangShuai get gongWangShuai => widget.gongWangShuai;
  UIPanMetaModel get pan => widget.pan;
  TextStyle getTwelveDiZhiTextStyle(String diZhiStr) {
    // Color fontColor = zodiacColors[diZhiStr]!;
    return GoogleFonts.longCang(
        color: ConstResourcesMapper
            .zodiacZhiColors[DiZhi.getFromValue(diZhiStr)]!
            .withOpacity(.2),
        // color: Colors.grey.withOpacity(.2),
        fontSize: 24,
        height: 1,
        fontWeight: FontWeight.w400,
        shadows: [
          Shadow(
              color: Colors.grey.withOpacity(.5),
              blurRadius: 2,
              offset: const Offset(0, 0))
        ]);
    Color fontColor =
        ConstResourcesMapper.zodiacZhiColors[DiZhi.getFromValue(diZhiStr)]!;
    return twelveDiZhiTextStyle
        .copyWith(color: fontColor.withOpacity(.6), shadows: [
      // Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))
    ]);
    return twelveDiZhiTextStyle
        .copyWith(color: Colors.grey.withOpacity(.6), shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
  }

  TextStyle getGongWangShuaiTextStyle(GongWangShuaiType gongStrongWeak) {
    switch (gongStrongWeak) {
      case GongWangShuaiType.CongQiang:
        return nineStarsNameTextStyle.copyWith(color: Colors.black87);
      case GongWangShuaiType.Qiang:
        return nineStarsNameTextStyle.copyWith(color: Colors.black87);
      case GongWangShuaiType.Ruo:
        return nineStarsNameTextStyle.copyWith(
            color: Colors.blueGrey.withOpacity(.8));
      case GongWangShuaiType.CongRuo:
        return nineStarsNameTextStyle.copyWith(
            color: Colors.blueGrey.withOpacity(.8));
    }
  }

  TextStyle getTianGanTextStyle(TianGan tianGan) {
    Color fontColor = ConstResourcesMapper.zodiacGanColors[tianGan]!;
    return eightSeasonTextStyle
        .copyWith(color: fontColor, fontSize: 24, shadows: [
      const Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
    ]);
  }

  var nearBorderSide = const BorderSide(color: Colors.black, width: 1);
  var farBorderSide = const BorderSide(color: Colors.grey, width: 1);
  var normalBorderSide = BorderSide(color: Colors.grey.shade300, width: 1);

  BoxDecoration getDefaultGongDecoration(HouTianGua gong) {
    return BoxDecoration(
      color: Colors.white.withOpacity(.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1．阳遁：以一、八、三、四宫为内盘，以九、二、七、六宫为外盘。
    // 2. 阴遁：以九、二、七、六宫为内盘，以一、八、三、四宫为外盘。
    // 3.内盘在空间上主近，在时间上主快；外盘在空间上主远，在时间上主慢。
    Color backgroundColor;
    if (widget.pan.yinYangDun.isYang) {
      if ([HouTianGua.Kan, HouTianGua.Gen, HouTianGua.Zhen, HouTianGua.Xun]
          .contains(widget.gua)) {
        backgroundColor = Colors.black12;
      } else {
        backgroundColor = Colors.white;
      }
    } else {
      if ([HouTianGua.Kan, HouTianGua.Gen, HouTianGua.Zhen, HouTianGua.Xun]
          .contains(widget.gua)) {
        backgroundColor = Colors.white;
      } else {
        backgroundColor = Colors.black12;
      }
    }
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildEachGongMetaContent(widget.gua),
          // buildEachGongContent(widget.gong,widget.pan)
          ValueListenableBuilder(
              valueListenable: widget.showHintNotifier,
              builder: (ctx, showHint, _) {
                return buildGong(widget.gua, showHint);
              }),
          Positioned(right: 12, top: 12, child: buildTenGanKeYingGeJu()),
          // Positioned(
          //   top: 16,
          //     right: 48,
          //     child: buildThreeQiRuGong())
        ],
      ),
    );
  }

  Widget buildTenGanKeYingGeJu() {
    TenGanKeYingGeJu tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianGeJu;
    if (widget.tenGanKeYingGeJu.isTianGanDunJia) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianDunJiaGeJu!;
    }
    if (widget.tenGanKeYingGeJu.isDiGanDunJia) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.diDunJiaGeJu!;
    }
    if (widget.tenGanKeYingGeJu.tianPanJiGan != null) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianPanJiGanGeJu!;
    }
    if (widget.tenGanKeYingGeJu.diPanJiGan != null) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.diPanJiGanGeJu!;
    }
    if (widget.tenGanKeYingGeJu.isTianJiGanJia) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianJiGanJiaGeJu!;
    }
    if (widget.tenGanKeYingGeJu.isDiJiGanJia) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.diJiGanJiaGeJu!;
    }
    if (widget.tenGanKeYingGeJu.tianDiPanGanGeJu != null) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianDiPanGanGeJu!;
    }
    if (widget.tenGanKeYingGeJu.tianDiJiGanGeJu != null) {
      tenGanKeYingGeJu = widget.tenGanKeYingGeJu.tianDiJiGanGeJu!;
    }
    List<String> nameList = tenGanKeYingGeJu.geJuNames.first.split("");

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  // Colors.blueGrey.shade700,
                  ConstResourcesMapper
                      .jiXiongColorMapper[tenGanKeYingGeJu.jiXiong]!,
                  BlendMode.srcIn),
              child: Image.asset(
                "assets/icons/yin_zhang.png",
                width: 32,
                height: 32,
              )),
        ),
        SizedBox(
          height: 38,
          width: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    nameList[0],
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    nameList[1],
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                width: 2,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    nameList[2],
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    nameList[3],
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildThreeQiRuGong() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 24,
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  ConstResourcesMapper.jiXiongColorMapper[JiXiongEnum.JI]!,
                  BlendMode.srcIn),
              child: Image.asset(
                "assets/icons/long_yin_zhang.png",
                width: 64,
                height: 20,
              )),
        ),
        Text(
          "月入雷门",
          style: GoogleFonts.maShanZheng(
              fontSize: 14, height: 1.0, color: Colors.white),
        )
      ],
    );
  }

  // Widget buildEachGongMetaContent(HouTianGua gongGua, ShiJiaQiMen pan){
  Widget buildEachGongMetaContent(HouTianGua gongGua) {
    // ConstantQiMenNineGongDataClass metaGong = defaultMapper[gongGua]!;
    // EachGongWangShuai gongWangShuai = pan.gongWangShuaiMapper[gongGua]!;
    return Container(
      padding: const EdgeInsets.all(4),
      width: widget.gongSize,
      height: widget.gongSize,
      decoration: widget.withNormalBorder
          ? BoxDecoration(
              color: Colors.white.withOpacity(.1),
              border: Border.fromBorderSide(normalBorderSide),
              borderRadius: const BorderRadius.all(Radius.circular(24)))
          : getDefaultGongDecoration(gongGua),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLeftTopCorner(widget.backgroundGong, gongWangShuai),
                _buildGongTopCenter(widget.backgroundGong, gongWangShuai,
                    pan.timeXunKong, pan.horseLocation),
                _buildRightTopCorner(widget.backgroundGong, gongWangShuai),
              ],
            ),
          ),
          Row(
            children: [
              // 中间字左侧
              Expanded(
                child: Row(
                  children: [
                    _buildLeftSideBox(widget.backgroundGong, gongWangShuai,
                        pan.timeXunKong, pan.horseLocation),
                    const Expanded(
                        child: SizedBox()), // Empty container for spacing
                  ],
                ),
              ),
              Opacity(
                opacity: .5,
                child: Transform.scale(
                    scale: 1,
                    child: widget.backgroundGong == null
                        ? const SizedBox()
                        : QiMenGongContentBackground(
                            qiMen: widget.backgroundGong!,
                            nineStarsNameTextStyle:
                                gongWangShuai.starFuFanYin != FuFanYinEnum.Not
                                    ? nineStarsNameTextStyle.copyWith(
                                        color: Colors.black)
                                    : nineStarsNameTextStyle,
                            nineGongNameTextStyle:
                                nineGongNameTextStyle.copyWith(
                                    color: Colors.grey.withOpacity(.6),
                                    // fontSize: 36,
                                    height: 1,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                  Shadow(
                                      color: Colors.grey.withOpacity(.5),
                                      blurRadius: 2,
                                      offset: const Offset(0, 0))
                                ]),
                            nineGongNumberTextStyle:
                                nineGongNumberTextStyle.copyWith(
                                    color: Colors.grey.withOpacity(.6),
                                    // fontSize: 36,
                                    height: 1,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                  Shadow(
                                      color: Colors.grey.withOpacity(.5),
                                      blurRadius: 2,
                                      offset: const Offset(0, 0))
                                ]),
                            eightGuaMapper: ConstResourcesMapper.eightGuaMapper,
                            eightSeasonTextStyle: eightSeasonTextStyle,
                            eightSkyDoorTextStyle:
                                gongWangShuai.doorFuFanYin != FuFanYinEnum.Not
                                    ? eightSkyDoorTextStyle.copyWith(
                                        color: Colors.black)
                                    : eightSkyDoorTextStyle,
                            zodiacColors: ConstResourcesMapper.zodiacZhiColors,
                            seasons24ColorMapper:
                                ConstResourcesMapper.Seasons24ColorMapper,
                          )),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: SizedBox()), // Empty container for spacing
                    _buildRightSideBox(widget.backgroundGong, gongWangShuai,
                        pan.timeXunKong, pan.horseLocation)
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLeftBottomCorner(widget.backgroundGong, gongWangShuai),
                  _buildGongBottomCenter(widget.backgroundGong, gongWangShuai,
                      pan.timeXunKong, pan.horseLocation),
                  _buildRightBottomCorner(widget.backgroundGong, gongWangShuai)
                ]),
          ),
        ],
      ),
    );
  }

  // Widget buildGong(HouTianGua gua,ShiJiaQiMen pan,bool showHint){
  Widget buildGong(HouTianGua gua, bool showHint) {
    // EachGong gong = pan.gongMapper[gua]!;
    // EachGongWangShuai gongWangShuai = pan.gongWangShuaiMapper[gua]!;

    // List<String> godNameList = gong.god.name.split("");

    return Container(
      width: widget.gongSize,
      height: widget.gongSize,
      decoration: const BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          // border: Border.all(color: Colors.black,width: 1),
          // borderRadius: BorderRadius.all(Radius.circular(24))
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 30,
          ),
          Container(
              height: 256,
              width: 28,
              // color: Colors.red.withOpacity(.1),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QiYiWangShuai(
                    tianGan: gong.tianPanAnGan,
                    monthlyZhangSheng:
                        gongWangShuai.tianPanAnGanMonthZhangSheng,
                    gongZhangSheng: gongWangShuai.tianPanAnGanGongZhangSheng,
                    isGongRuMuOrKu: gongWangShuai.tianPanAnGanIsMuOrKu,
                    showHint: showHint,
                    isDunJia: pan.xunHeaderTianGan == gong.tianPanAnGan,
                    isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                        gong.tianPanAnGan, gong.gongGua),
                    isYinAnGan: true,
                    textStyle: ConstantUiResourcesOfQiMen.tianGanTextStyle
                        .copyWith(color: Colors.blueGrey.shade200),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  QiYiWangShuai(
                    tianGan: gong.renPanAnGan,
                    monthlyZhangSheng: gongWangShuai.renPanAnGanMonthZhangSheng,
                    gongZhangSheng: gongWangShuai.renPanAnGanGongZhangSheng,
                    isGongRuMuOrKu: gongWangShuai.renPanAnGanIsMuOrKu,
                    showHint: showHint,
                    isDunJia: pan.xunHeaderTianGan == gong.renPanAnGan,
                    isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                        gong.renPanAnGan, gong.gongGua),
                    isYinAnGan: true,
                    textStyle: ConstantUiResourcesOfQiMen.tianGanTextStyle
                        .copyWith(color: Colors.blueGrey.shade200),
                  )
                ],
              )),
          Container(
            height: 256,
            width: 22,
            // color: Colors.red.withOpacity(.3),
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned(
                        left: 0,
                        child: buildEightGods(gong.god),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: gong.god.name
                            .split("")
                            .map((e) => Text(
                                  e,
                                  style: ConstantUiResourcesOfQiMen
                                      .eightGodsTextStyle,
                                ))
                            .toList(),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24,
                    child: showHint
                        ? _getWangShuaiHint(gongWangShuai.godGongWangShuai)
                        : const SizedBox(),
                  )
                ]),
          ),
          SizedBox(
              height: 256,
              width: 80,
              // color: Colors.red.withOpacity(.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 80,
                    // color: Colors.blue.withOpacity(.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 24,
                        ),
                        Stack(alignment: Alignment.bottomCenter, children: [
                          Container(
                            height: 46,
                            alignment: Alignment.bottomCenter,
                            child: gong.star == pan.zhiFuStar
                                ? SizedBox(width: 64, child: _buildZhiShiDoor())
                                : const SizedBox(),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 36,
                                    width: 2,
                                    // color: Colors.orange.withOpacity(.1),
                                  ),
                                  SizedBox(
                                    height: 36,
                                    width: 12,
                                    // color: Colors.orange.withOpacity(.3),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: showHint
                                          ? [
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              _getNineXingWangShuai(
                                                  gongWangShuai
                                                      .starMonthWangShuai),
                                              _getNineXingWangShuai(
                                                  gongWangShuai
                                                      .starGongWangShuai),
                                            ]
                                          : [],
                                    ),
                                  ),
                                  Container(
                                    height: 36,
                                    width: 52,
                                    // color: Colors.green.withOpacity(.2),
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      gong.star.name,
                                      style: ConstantUiResourcesOfQiMen
                                          .nineStarTextStyle,
                                    ),
                                  ),
                                  Container(
                                      height: 36,
                                      width: 14,
                                      // color: Colors.orange.withOpacity(.3),
                                      alignment: Alignment.topCenter,
                                      child: Stack(
                                        children: [
                                          gong.isJiTianQin &&
                                                  pan.zhiFuStar ==
                                                      NineStarsEnum.QIN
                                              ? RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Container(
                                                    child: SizedBox(
                                                        width: 48,
                                                        child: ColorFiltered(
                                                            colorFilter:
                                                                const ColorFilter
                                                                    .mode(
                                                                    // Color.fromRGBO(144, 105, 62, 1),
                                                                    Color
                                                                        .fromRGBO(
                                                                            176,
                                                                            31,
                                                                            36,
                                                                            .8),
                                                                    BlendMode
                                                                        .srcIn),
                                                            child: Image.asset(
                                                              "assets/icons/wide-black-ink-line.png",
                                                            ))),
                                                  ))
                                              : const SizedBox(),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: !gong.isJiTianQin
                                                ? []
                                                : NineStarsEnum.QIN.name
                                                    .split("")
                                                    .map((e) => Text(e,
                                                        style: nineStarTextStyle
                                                            .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)))
                                                    .toList(),
                                          )
                                        ],
                                      ))
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              )
                            ],
                          ),
                        ])
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 76,
                    width: 80,
                    // color: Colors.blueGrey.withOpacity(.2),
                  ),
                  SizedBox(
                      height: 70,
                      width: 80,
                      // color: Colors.blue.withOpacity(.2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildDoor(gong, gongWangShuai, showHint),
                          Container(
                            width: 80,
                            height: 24,
                            // color: Colors.orange.withOpacity(.4),
                            alignment: Alignment.topCenter,
                            child: Text(
                              gong.diGod.name,
                              style: ConstantUiResourcesOfQiMen
                                  .eightGodsTextStyle
                                  .copyWith(
                                      color: gong.diGod == EightGodsEnum.ZHI_FU
                                          ? Colors.blueGrey.shade500
                                          : Colors.blueGrey.shade200,
                                      fontSize: 20),
                            ),
                          )
                        ],
                      )),
                ],
              )),
          SizedBox(
              height: 256,
              width: 64,
              // color: Colors.orange.withOpacity(.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 48,
                    width: 54,
                    // color: Colors.blueGrey.withOpacity(.2),
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QiYiWangShuai(
                          tianGan: gong.tianPan,
                          monthlyZhangSheng:
                              gongWangShuai.tianPanMonthZhangSheng,
                          gongZhangSheng: gongWangShuai.tianPanGongZhangSheng,
                          isGongRuMuOrKu: gongWangShuai.tianPanGongIsMuOrKu,
                          showHint: showHint,
                          isDunJia: pan.xunHeaderTianGan == gong.tianPan,
                          isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                              gong.tianPan, gong.gongGua),
                          textStyle: ConstantUiResourcesOfQiMen.tianGanTextStyle
                              .copyWith(
                                  color: ConstResourcesMapper
                                      .zodiacGanColors[gong.tianPan]),
                        ),
                        gong.tianPanJiGan != null
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: QiYiWangShuai(
                                  tianGan: gong.tianPanJiGan!,
                                  textSize: const Size(22, 20),
                                  monthlyZhangSheng: gongWangShuai
                                      .tianPanJiGanMonthZhangSheng!,
                                  gongZhangSheng:
                                      gongWangShuai.tianPanJiGanGongZhangSheng!,
                                  isGongRuMuOrKu:
                                      gongWangShuai.tianPanJiGanGongIsMuOrKu,
                                  showHint: showHint,
                                  isDunJia: pan.xunHeaderTianGan ==
                                      gong.tianPanJiGan!,
                                  isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                                      gong.tianPanJiGan!, gong.gongGua),
                                  textStyle: ConstantUiResourcesOfQiMen
                                      .tianGanTextStyle
                                      .copyWith(
                                          color: ConstResourcesMapper
                                                  .zodiacGanColors[
                                              gong.tianPanJiGan!]),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    // width: 54,
                    width: 64,
                    // color: Colors.blueGrey.withOpacity(.5),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        QiYiWangShuai(
                          tianGan: gong.yinGan,
                          monthlyZhangSheng:
                              gongWangShuai.yinGanMonthZhangSheng,
                          gongZhangSheng: gongWangShuai.yinGanGongZhangSheng,
                          isGongRuMuOrKu: gongWangShuai.yinPanAnGanIsMuOrKu,
                          showHint: showHint,
                          isDunJia: pan.xunHeaderTianGan == gong.yinGan,
                          isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                              gong.yinGan, gong.gongGua),
                          isYinAnGan: true,
                          textStyle: ConstantUiResourcesOfQiMen.tianGanTextStyle
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 54,
                    // color: Colors.blueGrey.withOpacity(.2),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        QiYiWangShuai(
                          tianGan: gong.diPan,
                          monthlyZhangSheng: gongWangShuai.diPanMonthZhangSheng,
                          gongZhangSheng: gongWangShuai.diPanGongZhangSheng,
                          isGongRuMuOrKu: gongWangShuai.diPanGongIsMuOrKu,
                          showHint: showHint,
                          isDunJia: pan.xunHeaderTianGan == gong.diPan,
                          isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                              gong.diPan, gong.gongGua),
                          textStyle: ConstantUiResourcesOfQiMen.tianGanTextStyle
                              .copyWith(
                                  color: ConstResourcesMapper
                                      .zodiacGanColors[gong.diPan]),
                        ),
                        gong.diPanJiGan != null
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: QiYiWangShuai(
                                  tianGan: gong.diPanJiGan!,
                                  textSize: const Size(22, 20),
                                  monthlyZhangSheng:
                                      gongWangShuai.diPanJiGanMonthZhangSheng!,
                                  gongZhangSheng:
                                      gongWangShuai.diPanJiGanGongZhangSheng!,
                                  isGongRuMuOrKu:
                                      gongWangShuai.diPanJiGanGongIsMuOrKu,
                                  showHint: showHint,
                                  isDunJia:
                                      pan.xunHeaderTianGan == gong.diPanJiGan!,
                                  isSixYiJixing: NineYiUtils.isLiuYiJiXing(
                                      gong.diPanJiGan!, gong.gongGua),
                                  textStyle: ConstantUiResourcesOfQiMen
                                      .tianGanTextStyle
                                      .copyWith(
                                          color: ConstResourcesMapper
                                                  .zodiacGanColors[
                                              gong.diPanJiGan!]),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 256, width: 0),
          const SizedBox(
            width: 16,
          )
        ],
      ),
    );
  }

  Widget _buildDoor(
      EachGong gong, EachGongWangShuai gongWangShuai, bool showHint) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        height: 46,
        alignment: Alignment.bottomCenter,
        child: gong.door == pan.zhiShiDoor
            ? SizedBox(width: 64, child: _buildZhiShiDoor())
            : const SizedBox(),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 34,
                width: 2,
                // color: Colors.orange.withOpacity(.1),
              ),
              SizedBox(
                height: 34,
                width: 12,
                // color: Colors.orange.withOpacity(.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: showHint
                      ? [
                          const SizedBox(
                            height: 4,
                          ),
                          _getWangShuaiHint(gongWangShuai.doorMonthWangShuai),
                          _getWangShuaiHint(gongWangShuai.doorGongWangShuai)
                        ]
                      : [],
                ),
              ),
              // buildEightDoor(sideWidth,gong.door,pan.zhiShiDoor,gongWangShuai)
              Stack(
                alignment: Alignment.center,
                children: [
                  gongWangShuai.isDoorRuMu && showHint
                      ? Positioned(
                          top: 12,
                          child: SizedBox(
                            height: 24,
                            width: 52,
                            child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                    Color.fromRGBO(81, 0, 0, .8),
                                    BlendMode.srcIn),
                                child: Image.asset(
                                  "assets/icons/mu.png",
                                  width: 28,
                                  height: 36,
                                )),
                          ),
                        )
                      : const SizedBox(),
                  Container(
                    height: 34,
                    width: 52,
                    // color: Colors.green.withOpacity(.2),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      gong.door.name,
                      style: ConstantUiResourcesOfQiMen.eightDoorTextStyle,
                    ),
                  ),
                ],
              ),
              Container(
                  height: 34,
                  width: 14,
                  // color: Colors.orange.withOpacity(.3),
                  alignment: Alignment.bottomCenter,
                  child: showHint && gongWangShuai.doorGongRelationship != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: gongWangShuai.doorGongRelationship!.name
                              .split("")
                              .map((t) => Text(t,
                                  style: getDoorGongTextStyle(
                                      gongWangShuai.doorGongRelationship!)))
                              .toList(),
                        )
                      : Container())
            ],
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
    ]);
  }

  Widget buildEightDoor(double sideWidth, EightDoorEnum eightDoor,
      EightDoorEnum zhiShiDoor, EachGongWangShuai gongWangShuai) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        zhiShiDoor == eightDoor ? _buildZhiShiDoor() : const SizedBox(),
        gongWangShuai.isDoorRuMu
            ? Positioned(
                top: 12,
                child: SizedBox(
                  height: 24,
                  width: 52,
                  child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(81, 0, 0, .8), BlendMode.srcIn),
                      child: Image.asset(
                        "assets/icons/mu.png",
                        width: 28,
                        height: 36,
                      )),
                ),
              )
            : const SizedBox(),
        Container(
            // width: centerWidth,
            // height: 32,
            height: 48,
            alignment: Alignment.centerRight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: sideWidth,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: SizedBox()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            child: _getWangShuaiHint(
                                gongWangShuai.doorMonthWangShuai),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: _getWangShuaiHint(
                                gongWangShuai.doorGongWangShuai),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Text(eightDoor.name, style: eightDoorTextStyle),
                Container(
                    width: sideWidth,
                    alignment: Alignment.centerLeft,
                    child: doorAndGong(gongWangShuai.doorGongRelationship))
              ],
            )),
      ],
    );
  }

  Widget buildEightGods(EightGodsEnum eightGods) {
    return eightGods == EightGodsEnum.ZHI_FU
        ? _buildZhiFuGods()
        : const SizedBox();
  }

  TextStyle getDoorGongTextStyle(GongAndDoorRelationship gongDoorRelationship) {
    TextStyle _doorGongtextStyle = doorGongtextStyle.copyWith(fontSize: 14);
    switch (gongDoorRelationship) {
      case GongAndDoorRelationship.DA_JI:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color: ConstResourcesMapper.jiXiongColorMapper[JiXiongEnum.DA_JI]);
        break;
      case GongAndDoorRelationship.XIAO_JI:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color:
                ConstResourcesMapper.jiXiongColorMapper[JiXiongEnum.XIAO_JI]);
        break;
      case GongAndDoorRelationship.DA_XIONG:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color:
                ConstResourcesMapper.jiXiongColorMapper[JiXiongEnum.DA_XIONG]);
        break;
      case GongAndDoorRelationship.XIAO_XIONG:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color: ConstResourcesMapper
                .jiXiongColorMapper[JiXiongEnum.XIAO_XIONG]);
        break;
      case GongAndDoorRelationship.RU_MU:
        _doorGongtextStyle = doorGongtextStyle
            .copyWith(color: const Color.fromRGBO(81, 0, 0, 1), shadows: [
          Shadow(
              color: Colors.red.withOpacity(.4),
              offset: const Offset(0, 0),
              blurRadius: 3)
        ]);
        break;
      case GongAndDoorRelationship.BI_HE:
      case GongAndDoorRelationship.SHOU_SHEN:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color: const Color.fromRGBO(193, 18, 28, 1));
        break;
      case GongAndDoorRelationship.MEN_PO:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color: const Color.fromRGBO(36, 54, 125, 1));
        break;
      case GongAndDoorRelationship.SHENG_WANG:
        _doorGongtextStyle =
            doorGongtextStyle.copyWith(color: Colors.purple.shade900);
        break;
      case GongAndDoorRelationship.XIE_QI:
        _doorGongtextStyle = doorGongtextStyle.copyWith(color: Colors.black87);
        break;
      case GongAndDoorRelationship.SHOU_ZHI:
      case GongAndDoorRelationship.SHENG_GONG:
        _doorGongtextStyle = doorGongtextStyle.copyWith(
            color: const Color.fromRGBO(121, 114, 110, 1));
        break;
      default:
        break;
    }
    return doorGongtextStyle;
  }

  Widget doorAndGong(GongAndDoorRelationship? gongDoorRelationship) {
    if (gongDoorRelationship == null) {
      return const SizedBox(height: 32);
    }
    TextStyle doorGongtextStyle = getDoorGongTextStyle(gongDoorRelationship);
    return SizedBox(
      height: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: gongDoorRelationship.name
            .split("")
            .map((e) => Text(e, style: doorGongtextStyle))
            .toList(),
      ),
    );
  }

  Widget _getNineXingWangShuai(NineStarStatusEnum wangShuai) {
    Color color = Colors.black87;
    switch (wangShuai) {
      case NineStarStatusEnum.WANG:
        color = Colors.purple.shade700;
        break;
      case NineStarStatusEnum.XIANG:
        color = Colors.red.shade700;
        break;
      case NineStarStatusEnum.QIU:
        color = Colors.blueGrey.shade300;
        break;
      case NineStarStatusEnum.FEI:
        color = Colors.grey.shade400;
        break;
      default:
        color = Colors.black87.withOpacity(.8);
        break;
    }
    return Text(
      wangShuai.name,
      style: wangShuaiTextStyle.copyWith(color: color),
    );
  }

  Widget _getWangShuaiHint(FiveEnergyStatus wangShuai) {
    Color color = Colors.black87;
    switch (wangShuai) {
      case FiveEnergyStatus.WANG:
        color = Colors.purple.shade700;
        break;
      case FiveEnergyStatus.XIANG:
        color = Colors.red.shade700;
        break;
      case FiveEnergyStatus.QIU:
        color = Colors.blueGrey.shade300;
        break;
      case FiveEnergyStatus.SI:
        color = Colors.grey.shade400;
        break;
      default:
        color = Colors.black87.withOpacity(.8);
        break;
    }
    return Text(
      wangShuai.name,
      style: wangShuaiTextStyle.copyWith(color: color),
    );
  }

  void diPanGanTapped(TianGan gan) {
    InteractiveToast.slide(
      context: context,
      // leading: leadingWidget(),
      title: Text("地盘：${gan.name}"),
      // trailing: trailingWidget(),
      toastStyle: const ToastStyle(titleLeadingGap: 10),
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
      ),
    );
  }

  Widget buildGanWithXunHeaderHint(
      TianGan xunHeaderTianGan, TianGan gan, TextStyle textStyle) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // load asset as background picture
        // 当为六甲旬首时添加下划线
        xunHeaderTianGan == gan
            ? SizedBox(
                width: 24,
                height: 24,
                child: _buildXunShou(),
              )
            : const SizedBox(),
        AutoSizeText(
          gan.name,
          // style: getTianGanTextStyle(gan),
          style: textStyle,
          minFontSize: 18,
          maxFontSize: 28,
        )
        // RichText(
        //     text: TextSpan(
        //       style: getTianGanTextStyle(gan),
        //       text: gan.name,
        //     )
        // )
      ],
    );
  }

  Widget buildJiGanWithXunHeaderHint(
      TianGan xunHeaderTianGan, TianGan? diPanJiGan) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // load asset as background picture
        // 当为六甲旬首时添加下划线
        diPanJiGan != null && xunHeaderTianGan == diPanJiGan
            ? SizedBox(
                width: 22,
                height: 22,
                child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        // pan.isSixJiXing?Colors.red.shade700:Colors.green.shade700,
                        //   Colors.green.shade700.withOpacity(.4),
                        ConstResourcesMapper.zodiacGanColors[TianGan.JIA]!,
                        BlendMode.srcIn),
                    child: Image.asset(
                      "assets/icons/red-ink-circle.png",
                      width: 32,
                      height: 32,
                    )),
              )
            : const SizedBox(),
        RichText(
            text: TextSpan(
          style: getTianGanTextStyle(diPanJiGan!).copyWith(fontSize: 18),
          text: diPanJiGan.name,
        )),
      ],
    );
  }

  Widget _buildLeftTopCorner(
      ConstantQiMenNineGongDataClass? taiYi, EachGongWangShuai gongWangShuai) {
    if (taiYi == null) {
      return Container();
    }
    if (taiYi.name == "乾") {
      return _buildCornerBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          Alignment.topLeft,
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak));
    } else if (taiYi.name == "巽") {
      if (widget.withoutMenHuLuFang) {
        return _buildCornerBox(
            taiYi.tianMenDiHu!, Alignment.topLeft, nineStarsNameTextStyle);
      } else {
        return const Expanded(child: SizedBox());
      }
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightTopCorner(
      ConstantQiMenNineGongDataClass? taiYi, EachGongWangShuai gongWangShuai) {
    if (taiYi == null) {
      return Container();
    }
    if (taiYi.name == "艮") {
      return _buildCornerBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          Alignment.topRight,
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak));
    } else if (taiYi.name == "坤") {
      if (widget.withoutMenHuLuFang) {
        return _buildCornerBox(
            taiYi.tianMenDiHu!, Alignment.topRight, nineStarsNameTextStyle);
      } else {
        return const Expanded(child: SizedBox());
      }
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightBottomCorner(
      ConstantQiMenNineGongDataClass? taiYi, EachGongWangShuai gongWangShuai) {
    if (taiYi == null) {
      return Container();
    }
    if (taiYi.name == "巽") {
      return _buildCornerBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          Alignment.bottomRight,
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak));
    } else if (taiYi.name == "乾") {
      if (widget.withoutMenHuLuFang) {
        return _buildCornerBox(
            taiYi.tianMenDiHu!, Alignment.bottomRight, nineStarsNameTextStyle);
      } else {
        return const Expanded(child: SizedBox());
      }
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildLeftBottomCorner(
      ConstantQiMenNineGongDataClass? taiYi, EachGongWangShuai gongWangShuai) {
    if (taiYi == null) {
      return Container();
    }
    if (taiYi.name == "坤") {
      return _buildCornerBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          Alignment.bottomLeft,
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak));
    } else if (taiYi.name == "艮") {
      if (widget.withoutMenHuLuFang) {
        return _buildCornerBox(
            taiYi.tianMenDiHu!, Alignment.bottomLeft, nineStarsNameTextStyle);
      } else {
        return const Expanded(child: SizedBox());
      }
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildLeftSideBox(
      ConstantQiMenNineGongDataClass? taiYiKan, EachGongWangShuai gongWangShuai,
      [Tuple2<DiZhi, DiZhi>? kongWangTuple, DiZhi? horsePosition]) {
    if (taiYiKan == null) {
      return Container();
    }
    if (taiYiKan.name == "兑") {
      return _buildSideBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak),
          Alignment.centerLeft,
          Colors.transparent);
    } else if (taiYiKan.name == "巽") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "艮") {
      String char = taiYiKan.diZhi.item2!;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!),
          horsePosition == DiZhi.getFromValue(char)!);
    } else if (taiYiKan.name == "震") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerLeft,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildRightSideBox(
      ConstantQiMenNineGongDataClass? taiYiKan, EachGongWangShuai gongWangShuai,
      [Tuple2<DiZhi, DiZhi>? kongWangTuple, DiZhi? horsePosition]) {
    if (taiYiKan == null) {
      return Container();
    }
    if (taiYiKan.name == "震") {
      // String char = taiYiKan.diZhi.item2!;
      return _buildSideBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak),
          Alignment.centerRight,
          Colors.transparent);
    } else if (taiYiKan.name == "坤") {
      String char = taiYiKan.diZhi.item2!;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerRight,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!),
          horsePosition == DiZhi.getFromValue(char)!);
    } else if (taiYiKan.name == "兑") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerRight,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "乾") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiSideBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Alignment.centerRight,
          Colors.transparent,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildGongBottomCenter(
      ConstantQiMenNineGongDataClass? taiYiKan, EachGongWangShuai gongWangShuai,
      [Tuple2<DiZhi, DiZhi>? kongWangTuple, DiZhi? horsePosition]) {
    if (taiYiKan == null) {
      return Container();
    }
    if (taiYiKan.name == "离") {
      return _buildCenterBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak),
          Colors.transparent,
          Alignment.bottomCenter);
    } else if (taiYiKan.name == "坎") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.bottomCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "艮") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.bottomCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "乾") {
      String char = taiYiKan.diZhi.item2!;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.bottomCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!),
          horsePosition == DiZhi.getFromValue(char)!);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildGongTopCenter(
      ConstantQiMenNineGongDataClass? taiYiKan, EachGongWangShuai gongWangShuai,
      [Tuple2<DiZhi, DiZhi>? kongWangTuple, DiZhi? horsePosition]) {
    if (taiYiKan == null) {
      return Container();
    }
    if (taiYiKan.name == "坎") {
      return _buildCenterBox(
          "${gongWangShuai.strongOrWeak.name}${gongWangShuai.gongWangShuaiCounter}",
          getGongWangShuaiTextStyle(gongWangShuai.strongOrWeak),
          Colors.transparent,
          Alignment.topCenter);
    } else if (taiYiKan.name == "坤") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.topCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "离") {
      String char = taiYiKan.diZhi.item1;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.topCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!));
    } else if (taiYiKan.name == "巽") {
      String char = taiYiKan.diZhi.item2!;
      return _buildDiZhiCenterBox(
          char,
          getTwelveDiZhiTextStyle(char),
          Colors.transparent,
          Alignment.topCenter,
          kongWangTuple!.toList().contains(DiZhi.getFromValue(char)!),
          horsePosition == DiZhi.getFromValue(char)!);
    } else {
      return const Expanded(child: SizedBox());
    }
  }

  Widget _buildCenterBox(String text, TextStyle style, Color color,
      [Alignment alignment = Alignment.topCenter]) {
    return Expanded(
      child: Container(
        alignment: alignment,
        decoration: const BoxDecoration(),
        child: AnimatedContainer(
          width: widget.gongSize * .1,
          height: widget.gongSize * .1,
          duration: const Duration(milliseconds: 500),
          alignment: alignment,
          child: AutoSizeText(
            text,
            style: style,
            maxLines: 1,
            minFontSize: 12,
            maxFontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBox(
      String text, Alignment alignment, TextStyle textStyle) {
    return Expanded(
      child: Container(
        alignment: alignment,
        decoration: const BoxDecoration(),
        child: AnimatedContainer(
          width: widget.gongSize * .1,
          height: widget.gongSize * .1,
          duration: const Duration(milliseconds: 500),
          // color: Colors.blueGrey.withOpacity(0.1),
          alignment: alignment,
          child: AutoSizeText(
            text.startsWith("从") ? text.substring(0, 1) : text,
            style: textStyle,
            maxLines: 1,
            minFontSize: 12,
            maxFontSize: 24,
          ),
        ),
      ),
    );
  }

// Helper function to build side boxes
  Widget _buildSideBox(
      String text, TextStyle style, Alignment alignment, Color color) {
    return Expanded(
        child: Container(
      alignment: alignment,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: AnimatedContainer(
        width: widget.gongSize * .25,
        height: widget.gongSize * .1,
        duration: const Duration(milliseconds: 500),
        alignment: alignment,
        child: AutoSizeText(
          text.startsWith("从") ? text.substring(0, 1) : text,
          style: style,
          maxLines: 1,
          minFontSize: 12,
          maxFontSize: 24,
        ),
      ),
    ));
  }

  Widget _buildDiZhiSideBox(
      String text, TextStyle style, Alignment alignment, Color color,
      [bool isKongWang = false, bool withHorseStar = false]) {
    return Expanded(
      child: Container(
        alignment: alignment,
        decoration: const BoxDecoration(),
        child: AnimatedContainer(
          width: widget.gongSize * .1,
          height: widget.gongSize * .1,
          duration: const Duration(milliseconds: 500),
          alignment: alignment,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!isKongWang && !withHorseStar)
                AutoSizeText(
                  text,
                  style: style,
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 24,
                ),
              if (isKongWang) _buildKongWangCircle(style.color!),
              if (withHorseStar)
                SizedBox(
                    width: 24,
                    height: 24,
                    child: _buildHorseStar(style.color!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiZhiCenterBox(String text, TextStyle style, Color color,
      [Alignment alignment = Alignment.topCenter,
      bool isKongWang = false,
      bool withHorseStar = false]) {
    return Expanded(
      child: Container(
        alignment: alignment,
        decoration: const BoxDecoration(),
        child: AnimatedContainer(
          width: widget.gongSize * .1,
          height: widget.gongSize * .1,
          duration: const Duration(milliseconds: 500),
          alignment: alignment,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!isKongWang && !withHorseStar)
                AutoSizeText(
                  text,
                  style: style,
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 24,
                ),
              if (isKongWang) _buildKongWangCircle(style.color!),
              if (withHorseStar) _buildHorseStar(style.color!)
            ],
          ),
        ),
      ),
    );
  }

// Helper function to build the center square
  Widget _buildCenterSquare(String text, Color color) {
    return SizedBox(
      width: 70,
      height: 70,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: Text(
            text,
            style: nineGongNameTextStyle,
          ),
        ),
      ),
    );
  }

// Helper function to build the number box
  Widget _buildNumberBox(String number, Color color) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          // color: Colors.black,
          ),
      child: Text(
        number,
        style: nineGongNumberTextStyle,
      ),
    );
  }

  Widget _buildArrowUp(Color color) {
    return RotatedBox(
      quarterTurns: -2,
      child: Lottie.asset('assets/lotties/arrow_up.json',
          width: 16,
          height: 16,
          delegates: LottieDelegates(values: [
            ValueDelegate.colorFilter(
              ["Arrow-Down Outlines", "**"],
              value: ColorFilter.mode(color, BlendMode.src),
            )
          ])),
    );
  }

  Widget _buildArrowDown(Color color) {
    return Lottie.asset(
        // "https://lottie.host/ef9d69b2-aba7-48e5-8eca-61d627edbb9b/VrHr7psMwk.json",
        // "https://lottie.host/embed/34394435-ad2e-4b20-820d-85d2070a7296/iR0wE4yDAA.json",
        'assets/lotties/arrow_down.json',
        width: 16,
        height: 16,
        delegates: LottieDelegates(values: [
          ValueDelegate.colorFilter(
            ["arrow", "**"],
            value: ColorFilter.mode(color, BlendMode.src),
          )
        ]));
  }

  Widget _buildWangHint(String str, bool isLeft) {
    Widget arrow = Lottie.asset(
        // "https://lottie.host/ef9d69b2-aba7-48e5-8eca-61d627edbb9b/VrHr7psMwk.json",
        // "https://lottie.host/embed/34394435-ad2e-4b20-820d-85d2070a7296/iR0wE4yDAA.json",
        'assets/lotties/arrow_down.json',
        width: 12,
        height: 12,
        delegates: LottieDelegates(values: [
          ValueDelegate.colorFilter(
            ["arrow", "**"],
            value: ColorFilter.mode(
                Colors.blueGrey.withOpacity(.5), BlendMode.src),
          )
        ]));
    Text strText = Text(
      str,
      style: wangShuaiTextStyle.copyWith(color: Colors.purple.withOpacity(.8)),
    );

    return Container(
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        width: 32,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // alignment: Alignment.centerRight,
            children: [
              !isLeft
                  ? strText
                  : _buildThreeArrowHint(true, Colors.purple.withOpacity(.8)),
              !isLeft
                  ? _buildThreeArrowHint(true, Colors.purple.withOpacity(.8))
                  : strText,
            ]));
  }

  Widget _buildXiangHint(String str, bool isLeft) {
    Text strText = Text(
      str,
      style: wangShuaiTextStyle.copyWith(color: Colors.red.withOpacity(.8)),
    );
    return Container(
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        width: 32,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // alignment: Alignment.centerRight,
            children: [
              !isLeft
                  ? strText
                  : _buildTwoArrowHint(true, Colors.red.withOpacity(.8)),
              !isLeft
                  ? _buildTwoArrowHint(true, Colors.red.withOpacity(.8))
                  : strText,
            ]));
  }

  Widget _buildXiu() {
    return Container(
        alignment: Alignment.center,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
              ),
              Text(
                "休",
                style: wangShuaiTextStyle.copyWith(
                    color: Colors.black.withOpacity(.7)),
              ),
            ]));
  }

  Widget _buildQiuHint(String str, bool isLeft) {
    Widget arrow = Lottie.asset(
        // "https://lottie.host/ef9d69b2-aba7-48e5-8eca-61d627edbb9b/VrHr7psMwk.json",
        // "https://lottie.host/embed/34394435-ad2e-4b20-820d-85d2070a7296/iR0wE4yDAA.json",
        'assets/lotties/arrow_down.json',
        width: 12,
        height: 12,
        delegates: LottieDelegates(values: [
          ValueDelegate.colorFilter(
            ["arrow", "**"],
            value: ColorFilter.mode(
                Colors.blueGrey.withOpacity(.5), BlendMode.src),
          )
        ]));
    Text strText = Text(
      str,
      style:
          wangShuaiTextStyle.copyWith(color: Colors.blueGrey.withOpacity(.8)),
    );
    return Container(
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        width: 32,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // alignment: Alignment.centerRight,
            children: [
              !isLeft
                  ? strText
                  : _buildTwoArrowHint(false, Colors.blueGrey.withOpacity(.8)),
              !isLeft
                  ? _buildTwoArrowHint(false, Colors.blueGrey.withOpacity(.8))
                  : strText,
            ]));
  }

  Widget _buildSiHint(String str, bool isLeft) {
    // return _buildThreeArrowHint(false);
    Widget arrow = Lottie.asset(
        // "https://lottie.host/ef9d69b2-aba7-48e5-8eca-61d627edbb9b/VrHr7psMwk.json",
        // "https://lottie.host/embed/34394435-ad2e-4b20-820d-85d2070a7296/iR0wE4yDAA.json",
        'assets/lotties/arrow_down.json',
        width: 12,
        height: 12,
        delegates: LottieDelegates(values: [
          ValueDelegate.colorFilter(
            ["arrow", "**"],
            value: ColorFilter.mode(
                Colors.blueGrey.withOpacity(.5), BlendMode.src),
          )
        ]));
    // Text strText = Text("死",style: TextStyle(fontSize: 14,height: 1.0,fontWeight: FontWeight.w300,color: Colors.grey.withOpacity(.5)),);
    Text strText = Text(
      str,
      style: wangShuaiTextStyle.copyWith(color: Colors.grey.withOpacity(.8)),
    );
    return Container(
        alignment: Alignment.center,
        // color: Colors.red.withOpacity(.1),
        width: 27,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // alignment: Alignment.centerRight,
            children: [
              !isLeft
                  ? strText
                  : _buildThreeArrowHint(false, Colors.grey.withOpacity(.8)),
              !isLeft
                  ? _buildThreeArrowHint(false, Colors.grey.withOpacity(.8))
                  : strText,
            ]));
  }

  Widget _buildZhiFuStar() {
    return SizedBox(
        width: 64,
        child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/wide-black-ink-radian-line2.png",
            )));
  }

  Widget _buildZhiShiDoor() {
    return SizedBox(
        width: 64,
        child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/wide-black-ink-radian-line2.png",
            )));
  }

  Widget _buildZhiFuGods({int quarterTurns = 1}) {
    return RotatedBox(
        quarterTurns: quarterTurns,
        child: Container(
          child: SizedBox(
              width: 48,
              child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                      // Color.fromRGBO(144, 105, 62, 1),
                      Color.fromRGBO(176, 31, 36, .8),
                      BlendMode.srcIn),
                  child: Image.asset(
                    "assets/icons/wide-black-ink-line.png",
                  ))),
        ));
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

  Widget _buildKongWangCircle([Color? color]) {
    return ColorFiltered(
        colorFilter:
            ColorFilter.mode(color ?? Colors.blueGrey, BlendMode.srcIn),
        child: Image.asset("assets/icons/thin-black-ink-circle.png"));
  }

  Widget _buildXunShou() {
    return ColorFiltered(
        colorFilter: ColorFilter.mode(
            ConstResourcesMapper.zodiacGanColors[TianGan.JIA]!,
            BlendMode.srcIn),
        child: Image.asset(
          "assets/icons/red-ink-circle.png",
          width: 32,
          height: 32,
        ));
  }

  Widget _buildTwoArrowHint(bool toTop, Color color) {
    return RotatedBox(
      quarterTurns: toTop ? 2 : 0,
      child: Lottie.asset('assets/lotties/two_down_arrow.json',
          width: 18,
          height: 18,
          delegates: LottieDelegates(values: [
            ValueDelegate.colorFilter(
              ["**"],
              value: ColorFilter.mode(color, BlendMode.src),
            )
          ])),
    );
  }

  Widget _buildThreeArrowHint(bool toTop, Color color) {
    return RotatedBox(
      quarterTurns: toTop ? -1 : 1,
      child: Lottie.asset('assets/lotties/three_down_arrow.json',
          width: 14,
          height: 14,
          delegates: LottieDelegates(values: [
            ValueDelegate.colorFilter(
              ["**"],
              value: ColorFilter.mode(color.withOpacity(.5), BlendMode.src),
            )
          ])),
    );
  }
}
