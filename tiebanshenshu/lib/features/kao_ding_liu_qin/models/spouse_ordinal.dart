/// 夫妻任次（继任）
///
/// 用于在考订夫妻时选择第几任配偶
enum SpouseOrdinal {
  first, // 第一任
  second, // 第二任
  third, // 第三任
  fourth, // 第四任
}

extension SpouseOrdinalExtension on SpouseOrdinal {
  String get displayName {
    switch (this) {
      case SpouseOrdinal.first:
        return '第一任';
      case SpouseOrdinal.second:
        return '第二任';
      case SpouseOrdinal.third:
        return '第三任';
      case SpouseOrdinal.fourth:
        return '第四任';
    }
  }
}