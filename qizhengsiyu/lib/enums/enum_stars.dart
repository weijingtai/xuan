
import 'package:common/model/enum_five_xing.dart';

import 'enum_qi_zheng.dart';

enum EnumStars{
  Sun("太阳","日",FiveXing.HUO,true), // 太阳
  Moon("太阴","月",FiveXing.SHUI,false), // 太阴
  Water("辰星","水",FiveXing.SHUI,true), // 水
  Fire("荧惑","火",FiveXing.HUO,false), // 火
  Soil("镇星","土",FiveXing.TU,true), // 土
  Golden("太白","金",FiveXing.JIN,false), // 金
  Wood("岁星","木",FiveXing.MU,true),  // 木
  Qi("紫炁","炁",FiveXing.MU,true),
  Luo("罗睺","罗",FiveXing.HUO,false),
  Ji("计都","计",FiveXing.TU,true),
  Bei("月孛","孛",FiveXing.SHUI,false);
  final String starName;
  final String singleName;
  final FiveXing fiveXing;
  final bool isDayOrNight; // true is day; false is night
  const EnumStars(this.starName,this.singleName, this.fiveXing,this.isDayOrNight);



  bool get isFiveStar => [Water,Fire,Soil,Golden,Wood].contains(this);
  bool get isYuNu => [Qi,Luo,Ji,Bei].contains(this);
  List<FiveStarWalkingType> get fullForwardList {
    switch (this) {
      case Fire:
      case Wood:
      case Water:
        return FiveStarWalkingType.fullForwardList([]);
      case Soil:
      // 土星没有疾行与迟行
        return FiveStarWalkingType.fullForwardList(
            [FiveStarWalkingType.Fast, FiveStarWalkingType.Slow]);
      case Golden:
      // 金星没有疾行
        return FiveStarWalkingType.fullForwardList([FiveStarWalkingType.Fast]);
      default:
      // 日月，永远为常
        return [FiveStarWalkingType.Normal];
    }
  }
  EnumStars? get yu{
    switch (this){
      case Fire: return Luo;
      case Water: return Bei;
      case Wood: return Qi;
      case Soil: return Ji;
      default: return null;
    }
  }
  EnumStars? get zheng{
    switch (this){
      case Luo: return Fire;
      case Bei: return Water;
      case Qi: return Wood;
      case Ji: return Soil;
      default: return null;
    }
  }
  static EnumStars? getByName(String name){
    if (name == "太阳"){
      return Sun;
    }else if (["月亮","太阴"].contains(name)){
      return Moon;
    }else if (name == "水星"){
      return Water;
    }else if (name == "火星"){
      return Fire;
    }else if (name == "土星"){
      return Soil;
    }else if (name == "金星"){
      return Golden;
    }else if (name == "木星"){
      return Wood;
    }else if (["紫炁","紫气"].contains(name)){
      return Qi;
    }else if (["罗睺","天首"].contains(name)){
      return Luo;
    }else if (["计都","天尾"].contains(name)){
      return Ji;
    }else if (["月孛","攙抢"].contains(name)){
      return Bei;
    }else {
      return null;
    }
  }
  static EnumStars? getBySingleName(String singleName){
    if (["阳","日"].contains(singleName)){
      return Sun;
    }else if (["月","阴"].contains(singleName)){
      return Moon;
    }else if (singleName == "水"){
      return Water;
    }else if (singleName == "火"){
      return Fire;
    }else if (singleName == "土"){
      return Soil;
    }else if (singleName == "金"){
      return Golden;
    }else if (singleName == "木"){
      return Wood;
    } else if (["炁","气"].contains(singleName)){
      return Qi;
    }else if ("罗"==singleName){
      return Luo;
    }else if ("计"==singleName){
      return Ji;
    }else if ("孛"==singleName){
      return Bei;
    }else {
      return null;
    }
  }
}

