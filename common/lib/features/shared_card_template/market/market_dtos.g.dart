// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketTemplatesPageDto _$MarketTemplatesPageDtoFromJson(
        Map<String, dynamic> json) =>
    MarketTemplatesPageDto(
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              MarketTemplateSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$MarketTemplatesPageDtoToJson(
        MarketTemplatesPageDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
    };

MarketTemplateSummaryDto _$MarketTemplateSummaryDtoFromJson(
        Map<String, dynamic> json) =>
    MarketTemplateSummaryDto(
      templateId: json['templateId'] as String,
      latestVersionId: json['latestVersionId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      downloadCount: (json['downloadCount'] as num).toInt(),
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$MarketTemplateSummaryDtoToJson(
        MarketTemplateSummaryDto instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'latestVersionId': instance.latestVersionId,
      'name': instance.name,
      'description': instance.description,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'tags': instance.tags,
      'downloadCount': instance.downloadCount,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc.toIso8601String(),
    };

MarketTemplateVersionDto _$MarketTemplateVersionDtoFromJson(
        Map<String, dynamic> json) =>
    MarketTemplateVersionDto(
      templateId: json['templateId'] as String,
      versionId: json['versionId'] as String,
      versionName: json['versionName'] as String,
      changelog: json['changelog'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );

Map<String, dynamic> _$MarketTemplateVersionDtoToJson(
        MarketTemplateVersionDto instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'versionId': instance.versionId,
      'versionName': instance.versionName,
      'changelog': instance.changelog,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
    };

MarketTemplateDetailDto _$MarketTemplateDetailDtoFromJson(
        Map<String, dynamic> json) =>
    MarketTemplateDetailDto(
      template: MarketTemplateSummaryDto.fromJson(
          json['template'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>)
          .map((e) =>
              MarketTemplateVersionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarketTemplateDetailDtoToJson(
        MarketTemplateDetailDto instance) =>
    <String, dynamic>{
      'template': instance.template.toJson(),
      'versions': instance.versions.map((e) => e.toJson()).toList(),
    };

MarketTemplatePayloadDto _$MarketTemplatePayloadDtoFromJson(
        Map<String, dynamic> json) =>
    MarketTemplatePayloadDto(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      templateId: json['templateId'] as String,
      versionId: json['versionId'] as String,
      layoutTemplate: LayoutTemplateDto.fromJson(
          json['layoutTemplate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MarketTemplatePayloadDtoToJson(
        MarketTemplatePayloadDto instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'templateId': instance.templateId,
      'versionId': instance.versionId,
      'layoutTemplate': instance.layoutTemplate.toJson(),
    };

PublishMarketTemplateRequestDto _$PublishMarketTemplateRequestDtoFromJson(
        Map<String, dynamic> json) =>
    PublishMarketTemplateRequestDto(
      name: json['name'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      layoutTemplate: LayoutTemplateDto.fromJson(
          json['layoutTemplate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PublishMarketTemplateRequestDtoToJson(
        PublishMarketTemplateRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'tags': instance.tags,
      'schemaVersion': instance.schemaVersion,
      'layoutTemplate': instance.layoutTemplate.toJson(),
    };
