class CollectUtils<T> {
  /// 将给定字符串放到给定list的第一个位置
  static List<String> changeStrSeq(String start, List<String> originalSeq,
      {bool isReversed = false}) {
    List<String> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<String> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<String> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  /// 将给定类型T放到给定list的第一个位置
  static List<T> changeSeq<T>(T start, List<T> originalSeq,
      {bool isReversed = false}) {
    if (originalSeq.isEmpty) {
      throw ArgumentError("original sequence is empty");
    }
    if (!originalSeq.contains(start)) {
      throw ArgumentError("start not in original sequence");
    }
    List<T> oldList = List.from(originalSeq);
    if (start == originalSeq.first) {
      if (isReversed) {
        List<T> newDiZhiList = oldList.sublist(1).toList(growable: true);
        return [start, ...newDiZhiList.reversed];
      }
      return oldList;
    }
    if (isReversed) {
      oldList = oldList.reversed.toList();
    }

    var timeZhiIndex = oldList.indexOf(start);
    List<T> newDiZhiList = oldList.sublist(timeZhiIndex).toList(growable: true);
    List<T> appendedList = oldList.sublist(0, timeZhiIndex);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }
}
