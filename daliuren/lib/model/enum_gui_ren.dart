
import 'package:json_annotation/json_annotation.dart';

enum GuiRen{
  // 阳贵例曰：
  // 甲羊戊庚牛，己鼠乙居猴，
  // 丙鸡丁猪走，壬兔癸蛇游，
  // 六辛骑猛虎，阳贵此中求。
  // （六辛顺骑虎，阳贵用斯求。）
  //
  // 阴贵例曰：
  // 甲牛戊庚羊，乙鼠己猴乡，
  // 丙猪丁鸡位，壬蛇癸兔藏，
  // 六辛乘骏马，此是阴贵方。
  // （六辛逢午马，阴贵夜时当。）
  // （六辛逢午马，阴贵用心详。）
  @JsonValue("贵人")
  GUI_REN("贵人","贵"),
    @JsonValue("腾蛇")
  TENG_SHE("腾蛇","蛇"),
    @JsonValue("朱雀")
  ZHU_QUE("朱雀","雀"),
    @JsonValue("六合")
  LIU_HE("六合","合"),
    @JsonValue("勾陈")
  GOU_CHEN("勾陈","勾"),
    @JsonValue("青龙")
  QING_LONG("青龙","龙"),
    @JsonValue("天空")
  TIAN_KONG("天空","空"),
    @JsonValue("白虎")
  BAI_HU("白虎","虎"),
    @JsonValue("太常")
  TAI_CHANG("太常","常"),
    @JsonValue("玄武")
  XUAN_WU("玄武","武"),
    @JsonValue("太阴")
  TAI_YIN("太阴","阴"),
    @JsonValue("天后")
  TIAN_HOU("天后","后");


  final String name;
  final String singleName;
  const GuiRen(this.name,this.singleName);
  static List<GuiRen> get clockwiseList=> [GUI_REN,TENG_SHE,ZHU_QUE,LIU_HE,GOU_CHEN,QING_LONG,TIAN_KONG,BAI_HU,TAI_CHANG,XUAN_WU,TAI_YIN,TIAN_HOU];
  static List<GuiRen> get antiClockwiseList => [GUI_REN, ...[TENG_SHE,ZHU_QUE,LIU_HE,GOU_CHEN,QING_LONG,TIAN_KONG,BAI_HU,TAI_CHANG,XUAN_WU,TAI_YIN,TIAN_HOU].reversed.toList()];
  static GuiRen getBySingleName(String singleName){
    switch(singleName){
       case "贵":
        return GUI_REN;
      case "蛇":
      case '螣':
      case '腾':
        return TENG_SHE;
      case "雀":
      case '朱':
        return ZHU_QUE;
      case "合":
        return LIU_HE;
      case "勾":
      case '陈':
        return GOU_CHEN;
      case "龙":
      case '青':
        return QING_LONG;
      case "空":
        return TIAN_KONG;
      case "虎":
      case '白':
        return BAI_HU;
      case "常":
        return TAI_CHANG;
      case "武":
      case '玄':
        return XUAN_WU;
      case '阴':
        return TIAN_HOU;
      case '后':
        return TIAN_HOU;
      default:
        throw UnsupportedError("贵人，没有这个单字：$singleName");
    }
  }
  String getName(bool isDay, bool isSingle){
    if(isSingle){
      if (this == GuiRen.GUI_REN){
        return isDay ? "乙" : "玉";
      }
      return singleName;
    }else{
      if (this == GuiRen.GUI_REN){
        return isDay ? "天乙" : "玉堂";
      }
      return name;
    }


  }

}