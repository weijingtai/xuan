/// 皇极取数法候选项
///
/// 封装皇极取数法交互式计算中的候选数值信息
library;

import 'package:json_annotation/json_annotation.dart';

import '../models/tiao_wen_candidate.dart';

part 'huang_ji_candidate.g.dart';

/// 皇极取数法候选项
///
/// 继承自TiaoWenCandidate，添加皇极取数法特有的属性
@JsonSerializable()
class HuangJiCandidate extends TiaoWenCandidate {
  /// 是否为初始次条文数
  final bool isInitialSecondary;

  /// 调整方向（正数表示递增，负数表示递减）
  final int adjustmentDirection;

  /// 调整次数
  final int adjustmentCount;

  /// 数值
  final int number;

  /// 相对于基础数的偏移量
  final int offset;

  /// 调整步数
  final int stepCount;

  /// 是否为基础候选项
  final bool isBase;

  /// 构造函数
  ///
  /// [id] 候选项唯一标识
  /// [displayName] 候选项显示名称
  /// [description] 候选项描述
  /// [type] 候选项类型
  /// [value] 候选项值
  /// [number] 候选数值
  /// [offset] 相对于基础数的偏移量
  /// [stepCount] 调整步数
  /// [isBase] 是否为基础候选项
  /// [isInitialSecondary] 是否为初始次条文数
  /// [adjustmentDirection] 调整方向
  /// [adjustmentCount] 调整次数
  /// [isDefault] 是否为默认选项
  /// [isEnabled] 是否可用
  /// [metadata] 额外的元数据
  HuangJiCandidate({
    required super.id,
    required super.displayName,
    required super.description,
    required super.type,
    required super.value,
    required this.number,
    required this.offset,
    required this.stepCount,
    required this.isBase,
    required this.isInitialSecondary,
    required this.adjustmentDirection,
    required this.adjustmentCount,
    super.isDefault,
    super.isEnabled,
    super.metadata,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    number,
    offset,
    stepCount,
    isBase,
    isInitialSecondary,
    adjustmentDirection,
    adjustmentCount,
  ];

  @override
  String toString() {
    return 'HuangJiCandidate('
        'id: $id, '
        'number: $number, '
        'offset: $offset, '
        'stepCount: $stepCount, '
        'isBase: $isBase, '
        'isInitialSecondary: $isInitialSecondary, '
        'adjustmentDirection: $adjustmentDirection, '
        'adjustmentCount: $adjustmentCount)';
  }

  // /// 转换为JSON
  // @override
  // Map<String, dynamic> toJson() {
  //   final json = super.toJson();
  //   json.addAll({
  //     'number': number,
  //     'offset': offset,
  //     'stepCount': stepCount,
  //     'isBase': isBase,
  //     'isInitialSecondary': isInitialSecondary,
  //     'adjustmentDirection': adjustmentDirection,
  //     'adjustmentCount': adjustmentCount,
  //   });
  //   return json;
  // }

  /// 从JSON创建实例
  // factory HuangJiCandidate.fromJson(Map<String, dynamic> json) {
  //   return HuangJiCandidate(
  //     id: json['id'] as String,
  //     displayName: json['displayName'] as String,
  //     description: json['description'] as String,
  //     type: TiaoWenCandidateType.values.firstWhere(
  //       (e) => e.toString() == json['type'],
  //       orElse: () => TiaoWenCandidateType.baseNumber,
  //     ),
  //     value: json['value'],
  //     number: json['number'] as int,
  //     offset: json['offset'] as int,
  //     stepCount: json['stepCount'] as int,
  //     isBase: json['isBase'] as bool,
  //     isInitialSecondary: json['isInitialSecondary'] as bool,
  //     adjustmentDirection: json['adjustmentDirection'] as int,
  //     adjustmentCount: json['adjustmentCount'] as int,
  //     isDefault: json['isDefault'] as bool? ?? false,
  //     isEnabled: json['isEnabled'] as bool? ?? true,
  //     metadata: json['metadata'] as Map<String, dynamic>?,
  //   );
  // }

  /// 创建初始次条文数候选项
  factory HuangJiCandidate.createInitialSecondary({required int number}) {
    return HuangJiCandidate(
      id: 'initial_secondary_$number',
      displayName: '初始次条文数',
      description: '初始次条文数：$number',
      type: TiaoWenCandidateType.baseNumber,
      value: number,
      number: number,
      offset: 0,
      stepCount: 0,
      isBase: true,
      isInitialSecondary: true,
      adjustmentDirection: 0,
      adjustmentCount: 0,
      isDefault: true,
    );
  }

  /// 创建调整后的候选项
  factory HuangJiCandidate.createAdjusted({
    required int baseNumber,
    required int adjustmentDirection,
    required int adjustmentCount,
  }) {
    final adjustedNumber =
        baseNumber + (adjustmentDirection * 30 * adjustmentCount);
    final directionText = adjustmentDirection > 0 ? '递增' : '递减';
    final displayName = '${directionText}${adjustmentCount}次';
    final description =
        '调整后数值：$adjustedNumber（${directionText}${adjustmentCount}次）';

    return HuangJiCandidate(
      id: 'adjusted_${adjustedNumber}_${adjustmentDirection}_$adjustmentCount',
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.baseNumber,
      value: adjustedNumber,
      number: adjustedNumber,
      offset: adjustmentDirection * 30 * adjustmentCount,
      stepCount: adjustmentCount,
      isBase: false,
      isInitialSecondary: false,
      adjustmentDirection: adjustmentDirection,
      adjustmentCount: adjustmentCount,
    );
  }

  /// 获取候选项描述
  String get description {
    if (isInitialSecondary) {
      return '初始次条文数：$number';
    }

    final directionText = adjustmentDirection > 0 ? '递增' : '递减';
    final adjustmentText = adjustmentCount > 0
        ? '（${directionText}${adjustmentCount}次）'
        : '';
    return '调整后数值：$number $adjustmentText';
  }

  /// 获取调整说明
  String get adjustmentDescription {
    if (isInitialSecondary) {
      return '原始计算结果';
    }

    if (adjustmentCount == 0) {
      return '无调整';
    }

    final directionText = adjustmentDirection > 0 ? '+' : '-';
    final totalAdjustment = adjustmentDirection * 30 * adjustmentCount;
    return '$directionText${totalAdjustment.abs()}（${directionText}30×$adjustmentCount）';
  }

  /// 从JSON创建实例
  factory HuangJiCandidate.fromJson(Map<String, dynamic> json) =>
      _$HuangJiCandidateFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$HuangJiCandidateToJson(this);
}
