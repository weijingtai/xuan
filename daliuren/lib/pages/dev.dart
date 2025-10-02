import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:daliuren/model/each_class.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/first_class.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DevMyWidget extends StatefulWidget {
  const DevMyWidget({super.key});

  @override
  State<DevMyWidget> createState() => _DevMyWidgetState();
}

class _DevMyWidgetState extends State<DevMyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: build_four_ke(generateFourClass()),
    ));
  }

  FourClass generateFourClass() {
    final fourClass = FourClass(
      first: FirstClass(
          sky: DiZhi.CHOU,
          ground: DiZhi.SHEN,
          guiRen: GuiRen.TIAN_KONG,
          tianGan: TianGan.GENG),
      second: EachClass(
          order: 1, sky: DiZhi.WU, ground: DiZhi.CHEN, guiRen: GuiRen.TIAN_HOU),
      third: EachClass(
          order: 2, sky: DiZhi.SI, ground: DiZhi.ZI, guiRen: GuiRen.TAI_YIN),
      fourth: EachClass(
          order: 3, sky: DiZhi.XU, ground: DiZhi.SI, guiRen: GuiRen.LIU_HE),
      isFanYin: false,
      isFuYin: false,
      isFullClass: true,
      isThreeClassOnly: false,
    );
    return fourClass;
  }

  Size gongSize = const Size(400 * .25, 400 * .25);
  TextStyle guiRenNameTextStyle = GoogleFonts.maShanZheng(
      fontSize: 24,
      color: const Color.fromRGBO(68, 68, 60, 1), // 墨染
      // color: Color.fromRGBO(255, 229, 248, 1), // 墨染
      height: 1.0,
      shadows: [
        Shadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);

  Widget build_four_ke(FourClass fourClass) {
    double diZhiFontSize = gongSize.width * .24;
    double otherFontSize = gongSize.width * .24;
    TextStyle tianGanStyle = ConstUIResourcesMapper.tianGanTextStyle
        .copyWith(fontSize: diZhiFontSize, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    TextStyle diZhiStyle = ConstUIResourcesMapper.twelveDiZhiTextStyle
        .copyWith(fontSize: diZhiFontSize, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    TextStyle guiRenName =
        guiRenNameTextStyle.copyWith(fontSize: gongSize.width * .14, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    SizedBox intervalSize = const SizedBox(width: 6);
    double height = gongSize.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "四",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.fourth.guiRen.name, style: guiRenName),
            Text(fourClass.fourth.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.fourth.sky))),
            Text(fourClass.fourth.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.fourth.ground)))
          ],
        ),
        intervalSize,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "三",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.third.guiRen.name, style: guiRenName),
            Text(fourClass.third.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.third.sky))),
            Text(fourClass.third.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.third.ground)))
          ],
        ),
        intervalSize,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "二",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.second.guiRen.name, style: guiRenName),
            Text(fourClass.second.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.second.sky))),
            Text(fourClass.second.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.second.ground)))
          ],
        ),
        intervalSize,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "一",
                    style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
                  ),
                  Text(fourClass.first.guiRen.name, style: guiRenName),
                  Center(
                    child: Text(fourClass.first.sky.value,
                        style: diZhiStyle.copyWith(
                            color: getZhiColor(fourClass.first.sky))),
                  ),
                  Center(
                    child: Text(fourClass.first.tianGan.value,
                        style: tianGanStyle.copyWith(
                            color: getGanColor(fourClass.first.tianGan))),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(fourClass.first.ground.value,
                    style: diZhiStyle.copyWith(
                        color: getZhiColor(fourClass.first.ground),
                        fontSize: gongSize.width * .16)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Color getZhiColor(DiZhi zhi) {
    return ConstResourcesMapper.zodiacZhiColors[zhi]!.withOpacity(.8);
  }

  Color getGanColor(TianGan gan) {
    return ConstResourcesMapper.zodiacGanColors[gan]!.withOpacity(.6);
  }
}
