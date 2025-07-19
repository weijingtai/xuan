import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:common/enums.dart';

part 'divination_request_info_datamodel.g.dart';

@JsonSerializable()
class DivinationRequestInfoDataModel extends Equatable {
  /// 当前数据类型为 占测请求 信息，
  /// 如： 占测类型，占测者年命，占测者UUID（如果存在用户时），
  /// 简单的吉凶等，以及一句话直断，占测问题，详细描述，
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

  const DivinationRequestInfoDataModel({
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

  factory DivinationRequestInfoDataModel.fromJson(Map<String, dynamic> json) =>
      _$DivinationRequestInfoDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DivinationRequestInfoDataModelToJson(this);

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
