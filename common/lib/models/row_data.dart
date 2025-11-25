import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/layout_template_enums.dart';

part 'row_data.g.dart';

/// RowData - 行数据模型
/// 用于表示可拖拽添加到卡片的行类型
@JsonSerializable()
class RowData extends Equatable {
  final String rowId; // 唯一 ID，例如 "heavenly_stem", "ten_god"
  final RowType rowType;
  final String label; // 显示标签，例如 "天干", "十神"

  const RowData({
    required this.rowId,
    required this.rowType,
    required this.label,
  });

  factory RowData.fromJson(Map<String, dynamic> json) =>
      _$RowDataFromJson(json);

  Map<String, dynamic> toJson() => _$RowDataToJson(this);

  @override
  List<Object?> get props => [rowId, rowType, label];
}
