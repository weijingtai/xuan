import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../models/layout_template_dto.dart';

part 'market_dtos.g.dart';

@JsonSerializable()
class MarketTemplatesPageDto extends Equatable {
  const MarketTemplatesPageDto({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<MarketTemplateSummaryDto> items;
  final String? nextCursor;
  final bool hasMore;

  factory MarketTemplatesPageDto.fromJson(Map<String, dynamic> json) =>
      _$MarketTemplatesPageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTemplatesPageDtoToJson(this);

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}

@JsonSerializable()
class MarketTemplateSummaryDto extends Equatable {
  const MarketTemplateSummaryDto({
    required this.templateId,
    required this.latestVersionId,
    required this.name,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.tags,
    required this.downloadCount,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String templateId;
  final String latestVersionId;

  final String name;
  final String description;

  final String authorId;
  final String authorName;

  final List<String> tags;
  final int downloadCount;

  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  factory MarketTemplateSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MarketTemplateSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTemplateSummaryDtoToJson(this);

  @override
  List<Object?> get props => [
        templateId,
        latestVersionId,
        name,
        description,
        authorId,
        authorName,
        tags,
        downloadCount,
        createdAtUtc,
        updatedAtUtc,
      ];
}

@JsonSerializable()
class MarketTemplateVersionDto extends Equatable {
  const MarketTemplateVersionDto({
    required this.templateId,
    required this.versionId,
    required this.versionName,
    required this.changelog,
    required this.createdAtUtc,
  });

  final String templateId;
  final String versionId;
  final String versionName;
  final String changelog;
  final DateTime createdAtUtc;

  factory MarketTemplateVersionDto.fromJson(Map<String, dynamic> json) =>
      _$MarketTemplateVersionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTemplateVersionDtoToJson(this);

  @override
  List<Object?> get props => [
        templateId,
        versionId,
        versionName,
        changelog,
        createdAtUtc,
      ];
}

@JsonSerializable(explicitToJson: true)
class MarketTemplateDetailDto extends Equatable {
  const MarketTemplateDetailDto({
    required this.template,
    required this.versions,
  });

  final MarketTemplateSummaryDto template;
  final List<MarketTemplateVersionDto> versions;

  factory MarketTemplateDetailDto.fromJson(Map<String, dynamic> json) =>
      _$MarketTemplateDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTemplateDetailDtoToJson(this);

  @override
  List<Object?> get props => [template, versions];
}

@JsonSerializable(explicitToJson: true)
class MarketTemplatePayloadDto extends Equatable {
  const MarketTemplatePayloadDto({
    required this.schemaVersion,
    required this.templateId,
    required this.versionId,
    required this.layoutTemplate,
  });

  final int schemaVersion;
  final String templateId;
  final String versionId;

  final LayoutTemplateDto layoutTemplate;

  factory MarketTemplatePayloadDto.fromJson(Map<String, dynamic> json) =>
      _$MarketTemplatePayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTemplatePayloadDtoToJson(this);

  @override
  List<Object?> get props => [
        schemaVersion,
        templateId,
        versionId,
        layoutTemplate,
      ];
}

@JsonSerializable(explicitToJson: true)
class PublishMarketTemplateRequestDto extends Equatable {
  const PublishMarketTemplateRequestDto({
    required this.name,
    required this.description,
    required this.tags,
    required this.schemaVersion,
    required this.layoutTemplate,
  });

  final String name;
  final String description;
  final List<String> tags;

  final int schemaVersion;
  final LayoutTemplateDto layoutTemplate;

  factory PublishMarketTemplateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PublishMarketTemplateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PublishMarketTemplateRequestDtoToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        tags,
        schemaVersion,
        layoutTemplate,
      ];
}
