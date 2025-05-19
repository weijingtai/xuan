// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionDataModel _$RegionDataModelFromJson(Map<String, dynamic> json) =>
    RegionDataModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      translations: json['translations'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flag: (json['flag'] as num?)?.toInt() ?? 1,
      wikiDataId: json['wikiDataId'] as String?,
    );

Map<String, dynamic> _$RegionDataModelToJson(RegionDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'translations': instance.translations,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'flag': instance.flag,
      'wikiDataId': instance.wikiDataId,
    };

SubregionDataModel _$SubregionDataModelFromJson(Map<String, dynamic> json) =>
    SubregionDataModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      translations: json['translations'] as String?,
      regionId: (json['regionId'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flag: (json['flag'] as num?)?.toInt() ?? 1,
      wikiDataId: json['wikiDataId'] as String?,
    );

Map<String, dynamic> _$SubregionDataModelToJson(SubregionDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'translations': instance.translations,
      'regionId': instance.regionId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'flag': instance.flag,
      'wikiDataId': instance.wikiDataId,
    };

CountryDataModel _$CountryDataModelFromJson(Map<String, dynamic> json) =>
    CountryDataModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      iso3: json['iso3'] as String?,
      numericCode: json['numericCode'] as String?,
      iso2: json['iso2'] as String?,
      phonecode: json['phonecode'] as String?,
      capital: json['capital'] as String?,
      currency: json['currency'] as String?,
      currencyName: json['currencyName'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      tld: json['tld'] as String?,
      native: json['native'] as String?,
      region: json['region'] as String?,
      regionId: (json['regionId'] as num?)?.toInt(),
      subregion: json['subregion'] as String?,
      subregionId: (json['subregionId'] as num?)?.toInt(),
      nationality: json['nationality'] as String?,
      timezones: json['timezones'] as String?,
      translations: json['translations'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      emoji: json['emoji'] as String?,
      emojiU: json['emojiU'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flag: (json['flag'] as num?)?.toInt() ?? 1,
      wikiDataId: json['wikiDataId'] as String?,
    );

Map<String, dynamic> _$CountryDataModelToJson(CountryDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iso3': instance.iso3,
      'numericCode': instance.numericCode,
      'iso2': instance.iso2,
      'phonecode': instance.phonecode,
      'capital': instance.capital,
      'currency': instance.currency,
      'currencyName': instance.currencyName,
      'currencySymbol': instance.currencySymbol,
      'tld': instance.tld,
      'native': instance.native,
      'region': instance.region,
      'regionId': instance.regionId,
      'subregion': instance.subregion,
      'subregionId': instance.subregionId,
      'nationality': instance.nationality,
      'timezones': instance.timezones,
      'translations': instance.translations,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'emoji': instance.emoji,
      'emojiU': instance.emojiU,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'flag': instance.flag,
      'wikiDataId': instance.wikiDataId,
    };

StateDataModel _$StateDataModelFromJson(Map<String, dynamic> json) =>
    StateDataModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      countryId: (json['countryId'] as num).toInt(),
      countryCode: json['countryCode'] as String,
      fipsCode: json['fipsCode'] as String?,
      iso2: json['iso2'] as String?,
      type: json['type'] as String?,
      level: (json['level'] as num?)?.toInt(),
      parentId: (json['parentId'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flag: (json['flag'] as num?)?.toInt() ?? 1,
      wikiDataId: json['wikiDataId'] as String?,
    );

Map<String, dynamic> _$StateDataModelToJson(StateDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countryId': instance.countryId,
      'countryCode': instance.countryCode,
      'fipsCode': instance.fipsCode,
      'iso2': instance.iso2,
      'type': instance.type,
      'level': instance.level,
      'parentId': instance.parentId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'flag': instance.flag,
      'wikiDataId': instance.wikiDataId,
    };

CityDataModel _$CityDataModelFromJson(Map<String, dynamic> json) =>
    CityDataModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      stateId: (json['stateId'] as num).toInt(),
      stateCode: json['stateCode'] as String,
      countryId: (json['countryId'] as num).toInt(),
      countryCode: json['countryCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      flag: (json['flag'] as num?)?.toInt() ?? 1,
      wikiDataId: json['wikiDataId'] as String?,
    );

Map<String, dynamic> _$CityDataModelToJson(CityDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stateId': instance.stateId,
      'stateCode': instance.stateCode,
      'countryId': instance.countryId,
      'countryCode': instance.countryCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'flag': instance.flag,
      'wikiDataId': instance.wikiDataId,
    };
