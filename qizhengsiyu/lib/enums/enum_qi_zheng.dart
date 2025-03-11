import 'package:common/utils/collections_utils.dart';
import 'package:json_annotation/json_annotation.dart';

enum FiveStarWalkingType {
  // 逆、留、迟、常、速 （星体完整的运动规律顺序）
  // 逆、留、迟、常、速、常、迟、留、逆
  // 迟留速逆顺

  @JsonValue("速")
  Fast("速"),
  @JsonValue("常")
  Normal("常"),
  @JsonValue("迟")
  Slow("迟"),
  @JsonValue("留")
  Stay("留"),
  @JsonValue("逆")
  Retrograde("逆");

  final String name;
  const FiveStarWalkingType(this.name);

  static List<FiveStarWalkingType> fullForwardList(
      List<FiveStarWalkingType> without) {
    List<FiveStarWalkingType> result = [
      Retrograde,
      Stay,
      Slow,
      Normal,
      Fast,
      Normal,
      Slow,
      Stay
    ];
    if (without.isNotEmpty) {
      // result.removeWhere((r)=>without.contains(r));
      if (without.length == 1) {
        // 金星没有速行，所以只有一个“常行”
        return [Retrograde, Stay, Slow, Normal, Slow, Stay];
      } else {
        // 土星，没有速，及 迟
        [Retrograde, Stay, Normal, Stay];
      }
    }
    return result;
  }

  static List<FiveStarWalkingType> changeFirst(
      FiveStarWalkingType first, List<FiveStarWalkingType> list) {
    return CollectUtils.changeSeq(first, list);
    if (list.first == first) {
      return list;
    } else {
      int currentAtIndex = list.indexOf(first);
      // return [...list.sublist(currentAtIndex-1),...list.sublist(0,currentAtIndex)];
      // 逆、留、迟、常、速、常、迟、留
      // 常、速、常、迟、留、逆、留、迟、
      return [
        ...list.sublist(currentAtIndex),
        ...list.sublist(0, currentAtIndex)
      ];
    }
  }

  static List<FiveStarWalkingType> reverseToPreviousListAndChangeFirst(
      FiveStarWalkingType first, List<FiveStarWalkingType> list) {
    return CollectUtils.changeSeq(first, list, isReversed: true);
    // List<FiveStarWalkingType> result = list;
    // if (list.first != first) {
    //   int currentAtIndex = list.indexOf(first);
    //   // return [...list.sublist(currentAtIndex-1),...list.sublist(0,currentAtIndex)];
    //   // 逆、留、迟、常、速、常、迟、留
    //   // 常、速、常、迟、留、逆、留、迟、
    //   result = [
    //     ...list.sublist(currentAtIndex),
    //     ...list.sublist(0, currentAtIndex)
    //   ];
    // }
    // return [result.first, ...result.sublist(1).reversed];
  }
}
