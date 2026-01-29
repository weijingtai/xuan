/// 基础数模型
///
/// 用于表示算法中的基础数及其相关信息
/// 这是一个纯粹的基础数模型，不包含条文列表相关信息
library;

/// 基础数来源枚举
enum BaseNumberSource {
  /// 年柱计算
  yearZhu,

  /// 月柱计算
  monthZhu,

  /// 日柱计算
  dayZhu,

  /// 时柱计算
  timeZhu,

  /// 综合计算
  combined,

  /// 初始数
  initial,

  /// 次数
  secondary,

  /// 自定义
  custom,

  /// 交互式计算
  interactive,
  // @JsonValue("六亲考刻")
  sixQinCorrectKe,
  // @JsonValue("皇极")
  huangji,
}

/// 基础数模型类
///
/// 包含基础数的核心信息，包括数值、名称、描述和来源
/// 这是一个纯粹的基础数模型，不包含条文列表相关信息
class BaseNumberModel {
  /// 基础数值
  final int baseNumber;

  /// 基础数名称
  final String name;

  /// 基础数描述
  final String description;

  /// 基础数来源
  final BaseNumberSource source;

  const BaseNumberModel({
    required this.baseNumber,
    required this.name,
    required this.description,
    required this.source,
  });

  /// 创建基础数模型的工厂方法
  ///
  /// [baseNumber] 基础数值
  /// [name] 基础数名称
  /// [description] 基础数描述
  /// [source] 基础数来源
  factory BaseNumberModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
  }) {
    return BaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
    );
  }

  /// 获取来源描述
  String get sourceDescription {
    switch (source) {
      case BaseNumberSource.yearZhu:
        return '年柱计算';
      case BaseNumberSource.monthZhu:
        return '月柱计算';
      case BaseNumberSource.dayZhu:
        return '日柱计算';
      case BaseNumberSource.timeZhu:
        return '时柱计算';
      case BaseNumberSource.combined:
        return '综合计算';
      case BaseNumberSource.initial:
        return '初始数';
      case BaseNumberSource.secondary:
        return '次数';
      case BaseNumberSource.custom:
        return '自定义';
      case BaseNumberSource.interactive:
        return '交互式计算';
      case BaseNumberSource.sixQinCorrectKe:
        return "六亲考刻";
      case BaseNumberSource.huangji:
        return '皇极取数';
    }
  }

  /// 复制并更新基础数信息
  BaseNumberModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
  }) {
    return BaseNumberModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
    );
  }

  /// 转换为Map用于调试和序列化
  Map<String, dynamic> toMap() {
    return {
      'baseNumber': baseNumber,
      'name': name,
      'description': description,
      'source': source.name,
      'sourceDescription': sourceDescription,
    };
  }

  @override
  String toString() {
    return 'BaseNumberModel(baseNumber: $baseNumber, name: $name, source: ${source.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseNumberModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.source == source;
  }

  @override
  int get hashCode {
    return baseNumber.hashCode ^ name.hashCode ^ source.hashCode;
  }
}
