// 定义地区相关表
// 地区模型类
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'world_info.g.dart';

@JsonSerializable()
class RegionDataModel extends Equatable {
  final int id;
  final String name;
  final String? translations;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;

  RegionDataModel({
    required this.id,
    required this.name,
    this.translations,
    this.createdAt,
    required this.updatedAt,
    this.flag = 1,
    this.wikiDataId,
  });

  @override
  List<Object?> get props => [id, name];

  factory RegionDataModel.fromJson(Map<String, dynamic> json) =>
      _$RegionDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegionDataModelToJson(this);
}

// 子地区模型类
@JsonSerializable()
class SubregionDataModel extends Equatable {
  final int id;
  final String name;
  final String? translations;
  final int regionId;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;

  SubregionDataModel({
    required this.id,
    required this.name,
    this.translations,
    required this.regionId,
    this.createdAt,
    required this.updatedAt,
    this.flag = 1,
    this.wikiDataId,
  });

  @override
  List<Object?> get props => [id, regionId, name];
  factory SubregionDataModel.fromJson(Map<String, dynamic> json) =>
      _$SubregionDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubregionDataModelToJson(this);
}

// 国家模型类
@JsonSerializable()
class CountryDataModel extends Equatable {
  final int id;
  final String name;
  final String? iso3;
  final String? numericCode;
  final String? iso2;
  final String? phonecode;
  final String? capital;
  final String? currency;
  final String? currencyName;
  final String? currencySymbol;
  final String? tld;
  final String? native;
  final String? region;
  final int? regionId;
  final String? subregion;
  final int? subregionId;
  final String? nationality;
  final String? timezones;
  final String? translations;
  final double? latitude;
  final double? longitude;
  final String? emoji;
  final String? emojiU;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;

  CountryDataModel({
    required this.id,
    required this.name,
    this.iso3,
    this.numericCode,
    this.iso2,
    this.phonecode,
    this.capital,
    this.currency,
    this.currencyName,
    this.currencySymbol,
    this.tld,
    this.native,
    this.region,
    this.regionId,
    this.subregion,
    this.subregionId,
    this.nationality,
    this.timezones,
    this.translations,
    this.latitude,
    this.longitude,
    this.emoji,
    this.emojiU,
    this.createdAt,
    required this.updatedAt,
    this.flag = 1,
    this.wikiDataId,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [id, regionId, subregionId, name];
  factory CountryDataModel.fromJson(Map<String, dynamic> json) =>
      _$CountryDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$CountryDataModelToJson(this);
}

// 州/省模型类
@JsonSerializable()
class StateDataModel extends Equatable {
  final int id;
  final String name;
  final int countryId;
  final String countryCode;
  final String? fipsCode;
  final String? iso2;
  final String? type;
  final int? level;
  final int? parentId;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;

  StateDataModel({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryCode,
    this.fipsCode,
    this.iso2,
    this.type,
    this.level,
    this.parentId,
    this.latitude,
    this.longitude,
    this.createdAt,
    required this.updatedAt,
    this.flag = 1,
    this.wikiDataId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id, countryId, countryCode, name];

  factory StateDataModel.fromJson(Map<String, dynamic> json) =>
      _$StateDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$StateDataModelToJson(this);
}

// 城市模型类
@JsonSerializable()
class CityDataModel extends Equatable {
  final int id;
  final String name;
  final int stateId;
  final String stateCode;
  final int countryId;
  final String countryCode;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;

  CityDataModel({
    required this.id,
    required this.name,
    required this.stateId,
    required this.stateCode,
    required this.countryId,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.flag = 1,
    this.wikiDataId,
  });

  @override
  // TODO: implement props
  List<Object?> get props =>
      [id, name, stateCode, stateId, countryId, countryCode];

  factory CityDataModel.fromJson(Map<String, dynamic> json) =>
      _$CityDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$CityDataModelToJson(this);
}
