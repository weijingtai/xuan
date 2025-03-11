import 'package:common/enums.dart';

import '../enums/enum_eight_door.dart';
import '../enums/enum_eight_gods.dart';
import '../enums/enum_nine_stars.dart';

class ChangeSequenceUtils {
  static List<NineStarsEnum> changeNineStarsSeq(
      NineStarsEnum start, List<NineStarsEnum> originalSeq,
      {bool isReversed = false}) {
    List<NineStarsEnum> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<NineStarsEnum> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<NineStarsEnum> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  static List<int> changeNumberSeq(int start, List<int> originalSeq,
      {bool isReversed = false}) {
    List<int> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<int> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<int> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  static List<TianGan> changeThreeQiXiYiSeq(
      TianGan start, List<TianGan> originalSeq,
      {bool isReversed = false}) {
    List<TianGan> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<TianGan> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<TianGan> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  static List<EightDoorEnum> changeDoorSeq(
      EightDoorEnum start, List<EightDoorEnum> originalSeq,
      {bool isReversed = false}) {
    List<EightDoorEnum> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<EightDoorEnum> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<EightDoorEnum> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  static List<EightGodsEnum> changeGodsSeq(
      EightGodsEnum start, List<EightGodsEnum> originalSeq,
      {bool isReversed = false}) {
    List<EightGodsEnum> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<EightGodsEnum> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<EightGodsEnum> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }
}
