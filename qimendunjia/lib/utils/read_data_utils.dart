import 'dart:convert';
import 'dart:io';

import 'package:common/model/enum_hou_tian_gua.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:common/model/enum_yin_yang.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';

import '../model/eight_door_ke_ying.dart';
import '../model/ten_gan_ke_ying_ge_ju.dart';

class ReadDataUtils{

  static final TEN_GAN_KE_YING_PATH = 'assets/qi_men_dun_jia/ten_gan_ke_ying_v1.json';
  static final TEN_GAN_KE_YING_GE_JU_PATH = 'assets/qi_men_dun_jia/ten_gan_ke_ying_final.json';
  static final DOOR_GAN_KE_YING_PATH = 'assets/qi_men_dun_jia/door_gan_ke_ying.json';
  static final QI_YI_RU_GONG_PATH = 'assets/qi_men_dun_jia/gong_qi.json';
  static final QI_YI_RU_GONG_DISEAS_PATH = 'assets/qi_men_dun_jia/gong_gan.json';
  static final STAR_DOOR_KE_YING_PATH = 'assets/qi_men_dun_jia/star_door_ke_ying.json';
  static final EIGHT_DOOR_KE_YING_PATH = 'assets/qi_men_dun_jia/eight_door_ke_ying.json';
  static Future<Map<TianGan, Map<TianGan, TenGanKeYing>>> readTenGanKeYing() async {
    try{
      // AssetBundle assetBundle = DefaultAssetBundle.of(context);
      // String jsonString = await assetBundle.loadString(TEN_GAN_KE_YING_PATH);
      String jsonString = await rootBundle.loadString(TEN_GAN_KE_YING_PATH);
      Map<String, dynamic> jsonMapper = jsonDecode(jsonString);
      Map<TianGan, Map<TianGan, TenGanKeYing>> result = {};
      for (var key in jsonMapper.keys) {
        Map<TianGan, TenGanKeYing> res = {};
        Map<String, dynamic> value = jsonMapper[key]!;
        if (key == "甲") {
          for (var k in value.keys) {
            res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
          }
          result[TianGan.JIA] = res;
        } else {
          for (var k in value.keys) {
            if (k == "甲") {
              res[TianGan.JIA] = TenGanKeYing.fromJson(value[k]);
            } else {
              res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
            }
          }
          result[TianGan.getFromValue(key)!] = res;
        }
      }
      // Map<TianGan,Map<TianGan,Map<String,List<String>>>> mapper = {};
      // for (var key in result.keys) {
      //   if (mapper.containsKey(key)){
      //     mapper[key] = {};
      //   }
      //   for (var k in result[key]!.keys){
      //     if (mapper[key]!.containsKey(k)){
      //       mapper[key]![k] = {
      //         "juName": [result[key]![k]!.juName],
      //       };
      //     }
      //   }
      // }
      // print(json.encode(mapper));
      return result;
    }catch(e){
      throw e;
    }
    // 从 asset 中读取数据
    // final content = await rootBundle.loadString(TEN_GAN_KE_TING_PATH);
    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();

    // 保留jsonMapper key 为String, value TenGanKeYing

  }

  static Future<Map<TianGan, Map<TianGan, TenGanKeYingGeJu>>> readTenGanKeYingGeJu() async {
    final content = await rootBundle.loadString(TEN_GAN_KE_YING_GE_JU_PATH);
    Map<String, dynamic> jsonMapper2 = jsonDecode(content);
    Map<TianGan,Map<TianGan,TenGanKeYingGeJu>> finalResult = {};
    for(var key in jsonMapper2.keys) {
      TianGan tian = TianGan.getFromValue(key)!;
      if (!finalResult.containsKey(tian)){
        finalResult[tian] = {};
      }
      for (var k in jsonMapper2[key]!.keys) {
        TianGan di = TianGan.getFromValue(k)!;
        finalResult[tian]![di] = TenGanKeYingGeJu.fromJson(jsonMapper2[key][k]);
      }
    }
    return finalResult;
  }
  static Future<Map<TianGan, Map<TianGan, TenGanKeYing>>> readTenGanKeYingJiXiong(BuildContext context) async {
    try{
      AssetBundle assetBundle = DefaultAssetBundle.of(context);
      String jsonString = await assetBundle.loadString(TEN_GAN_KE_YING_PATH);
      Map<String, dynamic> jsonMapper = jsonDecode(jsonString);
      Map<TianGan, Map<TianGan, TenGanKeYing>> result = {};
      for (var key in jsonMapper.keys) {
        Map<TianGan, TenGanKeYing> res = {};
        Map<String, dynamic> value = jsonMapper[key]!;
        if (key == "甲") {
          for (var k in value.keys) {
            res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
          }
          result[TianGan.JIA] = res;
        } else {
          for (var k in value.keys) {
            if (k == "甲") {
              res[TianGan.JIA] = TenGanKeYing.fromJson(value[k]);
            } else {
              res[TianGan.getFromValue(k)!] = TenGanKeYing.fromJson(value[k]);
            }
          }
          result[TianGan.getFromValue(key)!] = res;
        }
      }
      return result;
    }catch(e){
      throw e;
    }
    // 从 asset 中读取数据
    // final content = await rootBundle.loadString(TEN_GAN_KE_TING_PATH);
    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();

    // 保留jsonMapper key 为String, value TenGanKeYing

  }

  static Future<Map<EightDoorEnum, Map<TianGan, String>>> readDoorGanKeYing() async {

    final content = await rootBundle.loadString(DOOR_GAN_KE_YING_PATH);
    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();
    Map<String, dynamic> jsonMapper = jsonDecode(content);

    // 保留jsonMapper key 为String, value TenGanKeYing
    Map<EightDoorEnum, Map<TianGan, String>> result = {};
    for (var key in jsonMapper.keys) {
      Map<TianGan, String> res = {};
      Map<String, dynamic> value = jsonMapper[key]!;
      for (var k in value.keys) {
        res[TianGan.getFromValue(k)!] = value[k];
      }
      result[EightDoorEnum.fromSingleCharName(key)!] = res;
    }
    return result;

  }

  static Future<Map<HouTianGua, Map<TianGan, QiYiRuGong>>> readQiYiRuGong() async {

    final content = await rootBundle.loadString(QI_YI_RU_GONG_PATH);

    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();
    Map<String, dynamic> jsonMapper = jsonDecode(content);

    // 保留jsonMapper key 为String, value TenGanKeYing
    Map<HouTianGua, Map<TianGan, QiYiRuGong>> result = {};
    for (var key in jsonMapper.keys) {
      Map<TianGan, QiYiRuGong> res = {};
      Map<String, dynamic> value = jsonMapper[key]!;
      HouTianGua gongName = HouTianGua.getGuaByName(key)!;
      for (var k in value.keys) {
        Map<String,dynamic> _tmp = Map.from(value[k]);
        TianGan _currentGan = TianGan.getFromValue(k)!;
        _tmp["qiYi"] = _currentGan.name;
        _tmp["gong"] = gongName.name;
        try{

          res[_currentGan] = QiYiRuGong.fromJson(_tmp);
        }catch(e){
          print(e);

        }
      }
      result[gongName] = res;
    }
    return result;
  }
  static Future<Map<HouTianGua, Map<TianGan, String>>> readQiYiRuGongDisease() async {

    final content = await rootBundle.loadString(QI_YI_RU_GONG_DISEAS_PATH);

    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();
    Map<String, dynamic> jsonMapper = jsonDecode(content);

    // 保留jsonMapper key 为String, value TenGanKeYing
    Map<HouTianGua, Map<TianGan, String>> result = {};
    for (var key in jsonMapper.keys) {
      if (key == "中"){
        continue;
      }
      Map<TianGan, String> res = {};
      Map<String, dynamic> value = jsonMapper[key]!;
      for (var k in value.keys) {
        res[TianGan.getFromValue(k)!] = value[k];
      }
      result[HouTianGua.getGuaByName(key)!] = res;
    }

    return result;
  }

  static Future<Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>>> readDoorStarKeYing() async {

    final content = await rootBundle.loadString(STAR_DOOR_KE_YING_PATH);

    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();
    Map<String, dynamic> jsonMapper = jsonDecode(content);

    // 保留jsonMapper key 为String, value TenGanKeYing
    Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>> result = {};
    Map<NineStarsEnum, DoorStarKeYing> res = {};
    List<DoorStarKeYing> resultList = [];
    for (var key in jsonMapper.keys) {
      Map<String, dynamic> value = jsonMapper[key]!;
      for (var k in value.keys) {
        Map<String,dynamic> vMapper = value[k];
        vMapper["door"] = k;
        vMapper["star"] = key;
        resultList.add(DoorStarKeYing.fromJson(vMapper));
      }
    }
    // convert from DoorStarKeYing list to Mapper
    resultList.forEach((e){
      if (!result.keys.contains(e.door)){
        result[e.door] = {};
      }
      result[e.door]![e.star] = e;
    });

    return result;
  }


  static Future<Map<EightDoorEnum, Map<EightDoorEnum, Map<YinYang,EightDoorKeYing>>>> readEightDoorKeYing() async {

    final content = await rootBundle.loadString(EIGHT_DOOR_KE_YING_PATH);

    // final file = File('a/data/ten_gan_ke_ying_final_v1.json');
    // final content = file.readAsStringSync();
    try{
      Map<String, dynamic> jsonMapper = jsonDecode(content);

      // 保留jsonMapper key 为String, value TenGanKeYing
      Map<EightDoorEnum, EightDoorKeYing> res = {};
      List<EightDoorKeYing> resultList = [];

      print(jsonMapper.keys);
      for (var key in jsonMapper.keys) {
        Map<String, dynamic> value = jsonMapper[key]!;
        for (var k1 in value.keys) {
          Map<String,dynamic> vMapper = value[k1];
          for (var k2 in vMapper.keys){
            String content = vMapper[k2];

            resultList.add(EightDoorKeYing.fromJson({
              "fixDoor": k2,
              "door" : key,
              "dongJingYing" : k1 == "静应"?"阴":"阳",
              "description":content,
            }));
          }

        }
      }
      // print(resultList.first.toString());
      // convert from DoorStarKeYing list to Mapper
      Map<EightDoorEnum, Map<EightDoorEnum, Map<YinYang,EightDoorKeYing>>> result = {};
      resultList.forEach((e){
        if (!result.keys.contains(e.door)){
          result[e.door] = {};
        }
        if (!result[e.door]!.keys.contains(e.fixDoor)){
          result[e.door]![e.fixDoor] = {};
        }
        result[e.door]![e.fixDoor]![e.dongJingYing] = e;

      });
      return result;
    }catch(e){
      throw e;
    }

  }


}