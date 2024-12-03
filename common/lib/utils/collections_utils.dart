

class CollectUtils{
  static List<String> changeStrSeq(String start,List<String> originalSeq,{bool isReversed =false}){
    List<String> oldList = List.from(originalSeq);
    if (isReversed){
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<String> newDiZhiList = oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<String> appendedList = oldList.sublist(0,timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

}