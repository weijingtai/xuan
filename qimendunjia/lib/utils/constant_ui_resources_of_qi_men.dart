import 'package:common/const_resources_mapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';

class ConstantUiResourcesOfQiMen{

  static final TextStyle eightGodsTextStyle = GoogleFonts.zhiMangXing(
      fontSize: 26,
      // color: Color.fromRGBO(28, 45, 37, 1),
      color: Color.fromRGBO(68, 68, 60, 1), // 墨染
      // color: Color.fromRGBO(255, 229, 248, 1), // 墨染
      height: 1.0,
      shadows: [
        Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))
      ]
  );
  static final TextStyle twelveDiZhiTextStyle = GoogleFonts.longCang(
      color: Colors.grey,
      fontSize: 24,
      height: 1,
      // fontWeight: FontWeight.w500,
      shadows: [
        Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
      ]
  );
  static final TextStyle tianGanTextStyle =  GoogleFonts.maShanZheng(
      color: Colors.black87,
      fontSize: 28,
      height: 1.0,
      shadows: [
        Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
      ]
  );

  static final TextStyle eightDoorTextStyle = GoogleFonts.maShanZheng(
      fontSize: 24,
      color: Color.fromRGBO(25, 44, 59, 1),
      fontWeight: FontWeight.w400,
      height: 1,
      shadows: [
        Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))
      ]
  );
  static final TextStyle nineStarTextStyle = GoogleFonts.zhiMangXing(
      color: Color.fromRGBO(28, 45, 37, 1),
      fontSize: 28,
      height: 1,
      shadows: [
        Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))
      ]
  );
  static final TextStyle menHuLuFangStyle =  GoogleFonts.zhiMangXing(
    // color: Color.fromRGBO(28, 45, 37, 1),
      color: Colors.black87,
      fontSize: 16,
      height: 1,
      fontWeight: FontWeight.w300,
      shadows: [
        Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))
      ]
  );
  static final TextStyle panInfoTextStyle = GoogleFonts.maShanZheng(
      fontSize: 24,
      height: 1,
      fontWeight: FontWeight.w600,
      color: Colors.blueGrey.shade800
  );

  static final TextStyle wangShuaiTextStyle = TextStyle(fontSize: 10,height: 1.0,fontWeight: FontWeight.w400);
  static final TextStyle nineGongNameTextStyle = TextStyle(
    // color: Colors.grey.withOpacity(.3),
    color: Colors.grey,
    fontSize: 70,
    height: 1,
  );
  static final TextStyle nineGongNumberTextStyle = GoogleFonts.notoSerif(
    color: Colors.grey,
    fontSize: 20,
    height: 1,
  );
  static final TextStyle nineStarsNameTextStyle = GoogleFonts.zhiMangXing(
    color: Colors.grey,
    fontSize: 20,
    height: 1,
  );
  static final TextStyle eightSkyDoorTextStyle = GoogleFonts.maShanZheng(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
      height: 1
  );
  static final TextStyle eightSeasonTextStyle = GoogleFonts.maShanZheng(
    color: Colors.grey,
    fontSize: 16,
    height: 1,
  );
  static final TextStyle doorGongtextStyle = TextStyle(fontSize: 10,color: Colors.black,height: 1,fontWeight: FontWeight.w600);



  static final Map<String,Color> themeColor1={
    "backgroundColor": Color.fromRGBO(45, 52, 76, 1),
    "foregroundColor": Color.fromRGBO(196, 183, 160, 1),
    "specialColor": Color.fromRGBO(194, 52, 40, 1)
  };
  static final Map<String,Color> themeColor2={
    "backgroundColor": Color.fromRGBO(115, 28, 35, 1),
    "foregroundColor": Color.fromRGBO(230, 181, 123, 1),
  };

  static final Map<EightDoorEnum,Color> eightDoorColorMapper = {
    EightDoorEnum.XIU:Color.fromRGBO(61, 89, 171, 1),
    EightDoorEnum.SI:Color.fromRGBO(210, 180, 140, 1),
    EightDoorEnum.SHANG:Color.fromRGBO(120, 146, 98, 1),
    EightDoorEnum.DU:Color.fromRGBO(120, 146, 98, 1),
    EightDoorEnum.CENTER: Color.fromRGBO(244, 164, 96, 1),
    EightDoorEnum.KAI:Color.fromRGBO(228,158,0, 1),
    EightDoorEnum.JING_W:Color.fromRGBO(205, 92, 92, 1),
    EightDoorEnum.SHENG: Color.fromRGBO(210, 180, 140, 1),
    EightDoorEnum.JING_S:Color.fromRGBO(228,158,0, 1),
  };
  static final Map<NineStarsEnum,Color> nineStarsColorMapper = {
    NineStarsEnum.PENG: Color.fromRGBO(39,117,182, 1),
    NineStarsEnum.RUI: Color.fromRGBO(168,132,98, 1),
    NineStarsEnum.CHONG: Color.fromRGBO(90,164,174, 1),
    NineStarsEnum.FU: Color.fromRGBO(90,164,174, 1),
    NineStarsEnum.QIN: Color.fromRGBO(168,132,98, 1),
    NineStarsEnum.XIN: Color.fromRGBO(240,167,46, 1),
    NineStarsEnum.ZHU: Color.fromRGBO(240,167,46, 1),
    NineStarsEnum.REN: Color.fromRGBO(168,132,98, 1),
    NineStarsEnum.YING: Color.fromRGBO(233,84, 100, 1),
  };
  static final Map<GongAndDoorRelationship,Color> gongDoorRelationshipColorMapper = {
    GongAndDoorRelationship.DA_JI:Color.fromRGBO(39,98,53, 1),
    GongAndDoorRelationship.XIAO_JI:Color.fromRGBO(40,140,62, 1),
    GongAndDoorRelationship.DA_XIONG:Color.fromRGBO(120, 0, 36, 1),
    GongAndDoorRelationship.XIAO_XIONG:Color.fromRGBO(71, 0, 36, 1),
    GongAndDoorRelationship.RU_MU:Color.fromRGBO(81, 0, 0, 1),
    GongAndDoorRelationship.BI_HE:Color.fromRGBO(193,18,28,1),
    GongAndDoorRelationship.SHOU_SHEN:Color.fromRGBO(193,18,28,1),
    GongAndDoorRelationship.MEN_PO:Color.fromRGBO(36, 54, 125, 1),
    GongAndDoorRelationship.SHENG_WANG:Colors.purple.shade900,
    GongAndDoorRelationship.XIE_QI:Colors.black87,
    GongAndDoorRelationship.SHOU_ZHI:Color.fromRGBO(121, 114, 110, 1),
    GongAndDoorRelationship.SHENG_GONG:Color.fromRGBO(121, 114, 110, 1),
    GongAndDoorRelationship.FU_YIN:Colors.orange.shade900,
    GongAndDoorRelationship.FAN_YIN:Colors.blueAccent.shade400,
  };
}