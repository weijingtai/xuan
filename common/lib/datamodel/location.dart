import 'package:common/datamodel/geo_location.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  Coordinates? preciseCoordinates;
  Address? address;
  Coordinates? get coordinates => preciseCoordinates ?? address!.coordinates;
  // address 是否通过 preciseCoordinates 方向查询到的
  bool isReverseSpeculation;
  Location(
      {this.preciseCoordinates,
      this.address,
      this.isReverseSpeculation = false});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  copyWith({
    Coordinates? preciseCoordinates,
    Address? address,
    bool? isReverseSpeculation,
  }) {
    return Location(
      preciseCoordinates: preciseCoordinates ?? this.preciseCoordinates,
      address: address ?? this.address,
      isReverseSpeculation: isReverseSpeculation ?? this.isReverseSpeculation,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [address, preciseCoordinates];
}

@JsonSerializable()
class Coordinates extends Equatable {
  double latitude;
  double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [latitude.toString(), longitude.toString()];
}

@JsonSerializable()
class Address extends Equatable {
  String countryName;
  int countryId;
  int regionId;

  GeoLocation province;
  GeoLocation? city;
  GeoLocation? area;
  // String country;
  // String province;
  // String city;
  GeoLocation get lowestGeoLocation => area ?? city ?? province;
  Coordinates get coordinates {
    return lowestGeoLocation.coordinates;
  }

  String timezone;

  Address(
      {required this.countryName,
      required this.countryId,
      required this.regionId,
      required this.province,
      required this.timezone,
      this.city,
      this.area});

  Address removeArea() {
    return Address(
      countryName: this.countryName,
      countryId: this.countryId,
      regionId: this.regionId,
      province: this.province,
      city: this.city,
      area: null,
      timezone: timezone ?? this.timezone,
    );
  }

  Address removeCity() {
    return Address(
      countryName: this.countryName,
      countryId: this.countryId,
      regionId: this.regionId,
      province: this.province,
      city: null,
      area: null,
      timezone: timezone ?? this.timezone,
    );
  }

  // 写一个copyWith方法，用于修改某些属性
  Address copyWith({
    String? contryName,
    int? countryId,
    int? regionId,
    GeoLocation? province,
    GeoLocation? city,
    GeoLocation? area,
    String? timezone,
  }) {
    return Address(
      countryName: contryName ?? this.countryName,
      countryId: countryId ?? this.countryId,
      regionId: regionId ?? this.regionId,
      province: province ?? this.province,
      city: city ?? this.city,
      area: area ?? this.area,
      timezone: timezone ?? this.timezone,
    );
  }

  static Address get defualtAddress {
    return Address(
      countryName: '中国',
      countryId: 45,
      regionId: 9,
      province: GeoLocation(
          name: '北京市',
          latitude: 39.9042,
          longitude: 116.4074,
          level: GeoLevel.province,
          code: '110000',
          parentCode: "0"),
      city: GeoLocation(
        name: '北京市',
        latitude: 39.9042,
        longitude: 116.4074,
        code: '110100',
        parentCode: "110000",
        level: GeoLevel.city,
      ),
      timezone: 'Asia/Shanghai',
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props =>
      [countryName, countryId, regionId, province, city, area, timezone];
}
