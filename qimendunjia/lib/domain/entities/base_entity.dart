/// 基础实体接口
abstract class Entity {
  String get id;
}

/// 实体相等性比较基类
///
/// 使用 Equatable 模式，通过 props 进行值相等性比较
abstract class Equatable {
  /// 用于相等性比较的属性列表
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Equatable && _listEquals(props, other.props);
  }

  @override
  int get hashCode => Object.hashAll(props);

  bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return '$runtimeType(${props.join(', ')})';
  }
}
