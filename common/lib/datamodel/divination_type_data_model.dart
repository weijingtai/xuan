import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'divination_type_data_model.g.dart';

@JsonSerializable()
class DivinationTypeDataModel extends Equatable {
  final String uuid;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final String name;
  final String description;
  final bool isCustomized;
  final bool isAvailable;

  const DivinationTypeDataModel({
    required this.uuid,
    required this.createdAt,
    this.lastUpdatedAt,
    this.deletedAt,
    required this.name,
    required this.description,
    required this.isCustomized,
    required this.isAvailable,
  });

  factory DivinationTypeDataModel.fromJson(Map<String, dynamic> json) =>
      _$DivinationTypeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DivinationTypeDataModelToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        name,
        description,
        isCustomized,
        isAvailable,
      ];
}
