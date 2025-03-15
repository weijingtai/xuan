import 'dart:convert';

import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/enum_nine_zong_men.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'each_class.dart';
import 'first_class.dart';

part 'four_class.g.dart';

@JsonSerializable()
class FourClass {
  // late final List<EachClass> _classList;
  late final bool isFullClass; // 是否为4课齐全
  late final bool isThreeClassOnly; // 是否为3课
  late final bool isFuYin; // 是否为伏吟
  late final bool isFanYin; // 是否为反吟

  late final FirstClass first;
  late final EachClass second;
  late final EachClass third;
  late final EachClass fourth;
  // 当四课不备时，相同的两颗是谁
  List<EachClass>? sameSkyGroundClassList;

  FourClass(
      {required this.first,
      required this.second,
      required this.third,
      required this.fourth,
      required this.isFuYin,
      required this.isFanYin,
      required this.isThreeClassOnly,
      required this.isFullClass,
      this.sameSkyGroundClassList});
  List<EachClass> get listAllClass => [first, second, third, fourth];

  FourClass.fastGenerate(
      {required JiaZi dayGanZhi,
      required Map<DiZhi, DaLiuRenGong> eachGongMapper}) {
    // print(eachGongMapper.values.map((d)=>d.groundPanDiZhi.value));
    var dayGan = dayGanZhi.tianGan;
    var dayZhi = dayGanZhi.diZhi;
    // 获取天干寄宫
    var jiZhi = tenGanJiGongMapper[dayGan]!;
    var firstGong = eachGongMapper[jiZhi]!;
    first = FirstClass(
        sky: firstGong.skyPanDiZhi,
        ground: jiZhi,
        guiRen: firstGong.guiRen,
        tianGan: dayGan);

    var secondGround = firstGong.skyPanDiZhi;
    var secondSky = eachGongMapper[secondGround]!;
    var secondGong = eachGongMapper[secondGround]!;
    second = createEachClass(
        dayGan, 1, secondGong.skyPanDiZhi, secondGround, secondGong.guiRen);

    var thirdGround = dayZhi;
    var thridGong = eachGongMapper[thirdGround]!;
    third = createEachClass(
        dayGan, 2, thridGong.skyPanDiZhi, thirdGround, thridGong.guiRen);

    var fourthGround = thridGong.skyPanDiZhi;
    var fourthGong = eachGongMapper[fourthGround]!;
    fourth = createEachClass(
        dayGan, 3, fourthGong.skyPanDiZhi, fourthGround, fourthGong.guiRen);

    List<EachClass> classList = [first, second, third, fourth];
    // 检查是否为伏吟
    isFuYin = _checkIsFuYin(classList);
    isFanYin = _checkIsFanYin(classList);

    if (isFuYin || isFanYin) {
      isThreeClassOnly = false;
      isFullClass = false;
    } else if (!isFuYin && !isFanYin) {
      // 只在不是伏吟是查看是否为四课补全
      isFullClass = checkIsFullClass(classList);
      if (!isFullClass) {
        isThreeClassOnly = _setupBieZe(classList);
      } else {
        isThreeClassOnly = false;
      }
    } else {
      isThreeClassOnly = false;
      isFullClass = false;
    }
  }

  FourClass.generate(
      {required TianGan firstGround,
      required DiZhi firstSky,
      required DiZhi secondSky,
      required DiZhi secondGround,
      required DiZhi thirdSky,
      required DiZhi thirdGround,
      required DiZhi fourthSky,
      required DiZhi fourthGround,
      required JiaZi dayGanZhi,
      required Map<DiZhi, DaLiuRenGong> eachGongMapper}) {
    // print all sky and ground
    var dayGan = dayGanZhi.tianGan;
    var dayZhi = dayGanZhi.diZhi;
    // 获取天干寄宫
    var jiZhi = tenGanJiGongMapper[dayGan]!;
    // var firstGround = dayGan;
    // var firstSky = eachGongMapper[jiZhi]!.skyPanDiZhi;
    // print("------- ${firstSky.value}");
    // print("------- ${firstGround.value}");
    var firstGods = eachGongMapper.values
        .firstWhere((g) => g.skyPanDiZhi == firstSky)
        .guiRen;
    first = FirstClass(
        sky: firstSky, ground: jiZhi, guiRen: firstGods, tianGan: firstGround);

    // var secondGround =firstSky;
    // var secondSky = eachGongMapper[secondGround]!.skyPanDiZhi;
    var secondGods = eachGongMapper.values
        .firstWhere((g) => g.skyPanDiZhi == secondSky)
        .guiRen;
    second = createEachClass(dayGan, 1, secondSky, secondGround, secondGods);

    // var thirdGround =dayZhi;
    // var thirdSky = eachGongMapper[thirdGround]!.skyPanDiZhi;
    var thirdGods = eachGongMapper.values
        .firstWhere((g) => g.skyPanDiZhi == thirdSky)
        .guiRen;
    third = createEachClass(dayGan, 2, thirdSky, thirdGround, thirdGods);

    // var fourthGround = thirdSky;
    // var fourthSky = eachGongMapper[fourthGround]!.skyPanDiZhi;
    var fourthGods = eachGongMapper.values
        .firstWhere((g) => g.skyPanDiZhi == fourthSky)
        .guiRen;
    fourth = createEachClass(dayGan, 3, fourthSky, fourthGround, fourthGods);

    List<EachClass> classList = [first, second, third, fourth];
    // 检查是否为伏吟
    isFuYin = _checkIsFuYin(classList);
    isFanYin = _checkIsFanYin(classList);
    if (isFuYin || isFanYin) {
      isThreeClassOnly = false;
    } else if (!isFuYin && !isFanYin) {
      // 只在不是伏吟是查看是否为四课补全
      isFullClass = checkIsFullClass(classList);
      if (!isFullClass) {
        isThreeClassOnly = _setupBieZe(classList);
      } else {
        isThreeClassOnly = false;
      }
    } else {
      isThreeClassOnly = false;
    }
  }

  // 检查是否为反吟
  static bool _checkIsFuYin(List<EachClass> classList) {
    // 1. 检查第二课 与 第三课 是否 sky == ground
    return classList[1].sky == classList[1].ground &&
        classList[2].sky == classList[2].ground;
  }

  // 检查是否为伏吟
  static bool _checkIsFanYin(List<EachClass> classList) {
    // 1. 检查第二课 与 第三课 是否 为六冲
    return DiZhiChong.getOtherDiZhi(classList[1].sky) == classList[1].ground &&
        DiZhiChong.getOtherDiZhi(classList[2].sky) == classList[2].ground;
  }

  /// @return 为‘true’时标识为 别责，只备三课，
  static bool _setupBieZe(List<EachClass> classList) {
    // 跳过 first class, first class 的 ground 永远为天干，不会与其他相同
    Map<String, List<int>> singleSet = Map<String, List<int>>.fromEntries(
        classList.map((e) => MapEntry("${e.sky.value}${e.ground.value}", [])));

    for (var each in classList) {
      String tmpKey = "${each.sky.value}${each.ground.value}";
      singleSet[tmpKey]!.add(each.order);
    }
    // print(classList.map((e)=>"${e.ground.value}${e.sky.value}${e.otherSameSkyGroundIndexList}"));
    // print(jsonEncode(_singleSet));
    // 找到那个List中index最多，并根据其中的index找到对应的 EachClass 并设置
    if (singleSet.keys.length == 1) {
      for (var each in classList) {
        each.otherSameSkyGroundIndexList =
            singleSet.values.first.where((i) => i != each.order).toList();
      }
      return false;
    } else if (singleSet.keys.length == 2) {
      // 找到 value.length 为 2 的key

      var tmpKey =
          singleSet.keys.firstWhere((key) => singleSet[key]!.length == 2);
      // 从 _classList 中找到所有相同"sky""ground"的eachClass
      for (var each in classList) {
        if (tmpKey == "${each.sky.value}${each.ground.value}") {
          each.otherSameSkyGroundIndexList =
              singleSet[tmpKey]!.where((i) => i != each.order).toList();
        }
      }
      return true;
    } else if (singleSet.keys.length == 3) {
      // 找到 value.length 为 2 的key
      var tmpKey =
          singleSet.keys.firstWhere((key) => singleSet[key]!.length == 2);
      // 从 _classList 中找到所有相同"sky""ground"的eachClass
      for (var each in classList) {
        if (tmpKey == "${each.sky.value}${each.ground.value}") {
          each.otherSameSkyGroundIndexList =
              singleSet[tmpKey]!.where((i) => i != each.order).toList();
        }
      }
      // print(classList.map((e)=>"${e.ground.value}${e.sky.value}${e.otherSameSkyGroundIndexList}"));
      return true;
    } else {
      throw Exception("四课去重出现问题，没找但相同的的课");
    }
  }

  static bool checkIsFullClass(List<EachClass> classList) {
    return classList
            .map((each) {
              if (each.isFirstClass) {
                FirstClass first = each as FirstClass;
                // return "${first.sky.value}${first.tianGan.value}";
                return "${first.sky.value}${first.ground.value}";
              } else {
                return "${each.sky.value}${each.ground.value}";
              }
            })
            .toSet()
            .length ==
        4;
  }

  static EachClass createEachClass(
      TianGan dayGan, int order, DiZhi sky, DiZhi ground, GuiRen guiRen) {
    var skyKeDayGan =
        FiveXingRelationship.checkRelationship(dayGan.fiveXing, sky.fiveXing) ==
            FiveXingRelationship.KE;
    var dayGanKeSky =
        FiveXingRelationship.checkRelationship(sky.fiveXing, dayGan.fiveXing) ==
            FiveXingRelationship.KE;
    bool? isSkyKeDayGan;
    if (skyKeDayGan) {
      isSkyKeDayGan = true;
    } else if (dayGanKeSky) {
      isSkyKeDayGan = false;
    }
    // print("${dayGan.value} ${sky.value}${ground.value} ${dayGan.yinYang == sky.yinYang}");
    return EachClass(
      order: order,
      sky: sky,
      ground: ground,
      guiRen: guiRen,
      isSkyKeDayGan: isSkyKeDayGan,
      isSkySameYinYangWithDayGan: dayGan.yinYang == sky.yinYang,
    );
  }

  String toDebugString() {
    return "四\t三\t二\t一\r\n"
        "${fourth.sky.value}\t${third.sky.value}\t${second.sky.value}\t${first.sky.value}\r\n"
        "${fourth.ground.value}\t${third.ground.value}\t${second.ground.value}\t${first.tianGan.value}(${first.ground.value})";
  }

  EachClass getAsIndex(int index) {
    // get xxxGround and xxxSky as index of list
    // when item1 is true, item3 will be TianGan Data type, item2 always be DiZhi
    // index will start from 0 to 3
    // var res = _classList.firstWhere((e)=>e.order == index);
    // print(_classList.map((e)=>"${e.order}${e.sky.value}${e.ground.value}"));
    // print(res.order);
    // print("${res.sky.value}${res.ground.value}");
    // return _classList.firstWhere((e)=>e.order == index);
    // return _classList[index];
    switch (index) {
      case 0:
        return first;
      // return Tuple3<int,DiZhi,TianGan>(0,firstSky,firstGround);
      case 1:
        // return Tuple3<int,DiZhi,DiZhi>(1,secondSky,secondGround);
        return second;
      case 2:
        // return Tuple3<int,DiZhi,DiZhi>(2,thirdSky,thirdGround);
        return third;
      case 3:
        // return Tuple3<int,DiZhi,DiZhi>(3,fourthSky,fourthGround);
        return fourth;
      default:
        throw IndexError.withLength(index, 4);
    }
  }

  factory FourClass.fromJson(Map<String, dynamic> json) =>
      _$FourClassFromJson(json);
  Map<String, dynamic> toJson() => _$FourClassToJson(this);
}
