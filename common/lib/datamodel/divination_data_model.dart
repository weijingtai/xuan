import 'package:common/datamodel/divination_type_data_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/enums/enum_gender.dart' hide Gender;

import '../database/app_database.dart';

part 'divination_data_model.g.dart';

@JsonSerializable()
class DivinationDataModel extends Equatable {
  final String uuid;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final String divinationTypeUuid;
  final String? fateYear;
  final String? question;
  final String? detail;
  final String? ownerSeekerUuid;
  final Gender? gender;
  final String? seekerName;
  final String? tinyPredict;
  final String? directlyPredict;

  const DivinationDataModel({
    required this.uuid,
    required this.createdAt,
    this.lastUpdatedAt,
    this.deletedAt,
    required this.divinationTypeUuid,
    this.fateYear,
    this.question,
    this.detail,
    this.ownerSeekerUuid,
    this.gender,
    this.seekerName,
    this.tinyPredict,
    this.directlyPredict,
  });

  factory DivinationDataModel.fromJson(Map<String, dynamic> json) =>
      _$DivinationDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DivinationDataModelToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationTypeUuid,
        fateYear,
        question,
        detail,
        ownerSeekerUuid,
        gender,
        seekerName,
        tinyPredict,
        directlyPredict,
      ];
}
