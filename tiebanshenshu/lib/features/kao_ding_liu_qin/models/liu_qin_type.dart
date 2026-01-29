/// 六亲类型枚举
///
/// 定义考订六亲功能支持的六亲关系类型
enum LiuQinType {
  /// 父亲
  father,

  /// 母亲
  mother,

  /// 妻子
  wife,

  /// 丈夫
  husband,

  /// 兄弟姐妹
  sibling,

  /// 儿子
  son,

  /// 女儿
  daughter,
}

/// 六亲类型扩展
extension LiuQinTypeExtension on LiuQinType {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case LiuQinType.father:
        return '父亲';
      case LiuQinType.mother:
        return '母亲';
      case LiuQinType.wife:
        return '妻子';
      case LiuQinType.husband:
        return '丈夫';
      case LiuQinType.sibling:
        return '兄弟姐妹';
      case LiuQinType.son:
        return '儿子';
      case LiuQinType.daughter:
        return '女儿';
    }
  }

  /// 获取简称
  String get shortName {
    switch (this) {
      case LiuQinType.father:
        return '父';
      case LiuQinType.mother:
        return '母';
      case LiuQinType.wife:
        return '妻';
      case LiuQinType.husband:
        return '夫';
      case LiuQinType.sibling:
        return '兄弟';
      case LiuQinType.son:
        return '子';
      case LiuQinType.daughter:
        return '女';
    }
  }

  /// 对应的柱
  String get correspondingPillar {
    switch (this) {
      case LiuQinType.father:
      case LiuQinType.mother:
        return '年柱';
      case LiuQinType.wife:
      case LiuQinType.husband:
        return '日柱';
      case LiuQinType.sibling:
        return '月柱';
      case LiuQinType.son:
      case LiuQinType.daughter:
        return '时柱';
    }
  }

  /// 是否是考父母
  bool get isParent => this == LiuQinType.father || this == LiuQinType.mother;

  /// 是否是考夫妻
  bool get isSpouse => this == LiuQinType.wife || this == LiuQinType.husband;

  /// 是否是考兄弟
  bool get isSibling => this == LiuQinType.sibling;

  /// 是否是考子女
  bool get isChild => this == LiuQinType.son || this == LiuQinType.daughter;
}
