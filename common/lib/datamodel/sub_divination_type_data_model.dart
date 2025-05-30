import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_divination_type_data_model.g.dart';

@JsonSerializable()
class SubDivinationTypeDataModel extends Equatable {
  final String uuid;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final DateTime? hiddenAt;
  final String name;
  final bool isCustomized;
  final bool isAvailable;

  const SubDivinationTypeDataModel({
    required this.uuid,
    this.lastUpdatedAt,
    this.deletedAt,
    this.hiddenAt,
    required this.name,
    required this.isCustomized,
    required this.isAvailable,
  });

  factory SubDivinationTypeDataModel.fromJson(Map<String, dynamic> json) =>
      _$SubDivinationTypeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubDivinationTypeDataModelToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        lastUpdatedAt,
        deletedAt,
        hiddenAt,
        name,
        isCustomized,
        isAvailable,
      ];
}
