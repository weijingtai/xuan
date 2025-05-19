// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      preciseCoordinates: json['preciseCoordinates'] == null
          ? null
          : Coordinates.fromJson(
              json['preciseCoordinates'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      isReverseSpeculation: json['isReverseSpeculation'] as bool? ?? false,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'preciseCoordinates': instance.preciseCoordinates,
      'address': instance.address,
      'isReverseSpeculation': instance.isReverseSpeculation,
    };

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      countryName: json['countryName'] as String,
      countryId: (json['countryId'] as num).toInt(),
      regionId: (json['regionId'] as num).toInt(),
      province: GeoLocation.fromJson(json['province'] as Map<String, dynamic>),
      timezone: json['timezone'] as String,
      city: json['city'] == null
          ? null
          : GeoLocation.fromJson(json['city'] as Map<String, dynamic>),
      area: json['area'] == null
          ? null
          : GeoLocation.fromJson(json['area'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'countryName': instance.countryName,
      'countryId': instance.countryId,
      'regionId': instance.regionId,
      'province': instance.province,
      'city': instance.city,
      'area': instance.area,
      'timezone': instance.timezone,
    };
