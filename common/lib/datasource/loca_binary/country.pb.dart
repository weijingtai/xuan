//
//  Generated code. Do not modify.
//  source: country.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Timezone extends $pb.GeneratedMessage {
  factory Timezone({
    $core.String? zoneName,
    $core.int? gmtOffset,
    $core.String? gmtOffsetName,
    $core.String? abbreviation,
    $core.String? tzName,
  }) {
    final $result = create();
    if (zoneName != null) {
      $result.zoneName = zoneName;
    }
    if (gmtOffset != null) {
      $result.gmtOffset = gmtOffset;
    }
    if (gmtOffsetName != null) {
      $result.gmtOffsetName = gmtOffsetName;
    }
    if (abbreviation != null) {
      $result.abbreviation = abbreviation;
    }
    if (tzName != null) {
      $result.tzName = tzName;
    }
    return $result;
  }
  Timezone._() : super();
  factory Timezone.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Timezone.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Timezone',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'country'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zoneName')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'gmtOffset', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'gmtOffsetName')
    ..aOS(4, _omitFieldNames ? '' : 'abbreviation')
    ..aOS(5, _omitFieldNames ? '' : 'tzName')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Timezone clone() => Timezone()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Timezone copyWith(void Function(Timezone) updates) =>
      super.copyWith((message) => updates(message as Timezone)) as Timezone;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Timezone create() => Timezone._();
  Timezone createEmptyInstance() => create();
  static $pb.PbList<Timezone> createRepeated() => $pb.PbList<Timezone>();
  @$core.pragma('dart2js:noInline')
  static Timezone getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Timezone>(create);
  static Timezone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zoneName => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasZoneName() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoneName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get gmtOffset => $_getIZ(1);
  @$pb.TagNumber(2)
  set gmtOffset($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasGmtOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearGmtOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get gmtOffsetName => $_getSZ(2);
  @$pb.TagNumber(3)
  set gmtOffsetName($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasGmtOffsetName() => $_has(2);
  @$pb.TagNumber(3)
  void clearGmtOffsetName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get abbreviation => $_getSZ(3);
  @$pb.TagNumber(4)
  set abbreviation($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasAbbreviation() => $_has(3);
  @$pb.TagNumber(4)
  void clearAbbreviation() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get tzName => $_getSZ(4);
  @$pb.TagNumber(5)
  set tzName($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasTzName() => $_has(4);
  @$pb.TagNumber(5)
  void clearTzName() => $_clearField(5);
}

class City extends $pb.GeneratedMessage {
  factory City({
    $core.int? id,
    $core.String? name,
    $core.double? latitude,
    $core.double? longitude,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    return $result;
  }
  City._() : super();
  factory City.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory City.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'City',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'country'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  City clone() => City()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  City copyWith(void Function(City) updates) =>
      super.copyWith((message) => updates(message as City)) as City;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static City create() => City._();
  City createEmptyInstance() => create();
  static $pb.PbList<City> createRepeated() => $pb.PbList<City>();
  @$core.pragma('dart2js:noInline')
  static City getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<City>(create);
  static City? _defaultInstance;

  /// 根据实际需求补充字段（示例数据中cities数组为空）
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(4)
  $core.double get latitude => $_getN(2);
  @$pb.TagNumber(4)
  set latitude($core.double v) {
    $_setDouble(2, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasLatitude() => $_has(2);
  @$pb.TagNumber(4)
  void clearLatitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get longitude => $_getN(3);
  @$pb.TagNumber(5)
  set longitude($core.double v) {
    $_setDouble(3, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasLongitude() => $_has(3);
  @$pb.TagNumber(5)
  void clearLongitude() => $_clearField(5);
}

class State extends $pb.GeneratedMessage {
  factory State({
    $core.int? id,
    $core.String? name,
    $core.String? stateCode,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? type,
    $core.Iterable<City>? cities,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (stateCode != null) {
      $result.stateCode = stateCode;
    }
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    if (type != null) {
      $result.type = type;
    }
    if (cities != null) {
      $result.cities.addAll(cities);
    }
    return $result;
  }
  State._() : super();
  factory State.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory State.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'State',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'country'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'stateCode')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..aOS(6, _omitFieldNames ? '' : 'type')
    ..pc<City>(7, _omitFieldNames ? '' : 'cities', $pb.PbFieldType.PM,
        subBuilder: City.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  State clone() => State()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  State copyWith(void Function(State) updates) =>
      super.copyWith((message) => updates(message as State)) as State;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static State create() => State._();
  State createEmptyInstance() => create();
  static $pb.PbList<State> createRepeated() => $pb.PbList<State>();
  @$core.pragma('dart2js:noInline')
  static State getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<State>(create);
  static State? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get stateCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set stateCode($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasStateCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearStateCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get latitude => $_getN(3);
  @$pb.TagNumber(4)
  set latitude($core.double v) {
    $_setDouble(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasLatitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get longitude => $_getN(4);
  @$pb.TagNumber(5)
  set longitude($core.double v) {
    $_setDouble(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasLongitude() => $_has(4);
  @$pb.TagNumber(5)
  void clearLongitude() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get type => $_getSZ(5);
  @$pb.TagNumber(6)
  set type($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<City> get cities => $_getList(6);
}

class Country extends $pb.GeneratedMessage {
  factory Country({
    $core.int? id,
    $core.String? name,
    $core.String? iso3,
    $core.String? iso2,
    $core.String? numericCode,
    $core.String? phonecode,
    $core.String? capital,
    $core.String? currency,
    $core.String? currencyName,
    $core.String? currencySymbol,
    $core.String? tld,
    $core.String? native,
    $core.String? region,
    $core.int? regionId,
    $core.String? subregion,
    $core.int? subregionId,
    $core.String? nationality,
    $core.Iterable<Timezone>? timezones,
    $pb.PbMap<$core.String, $core.String>? translations,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? emoji,
    $core.String? emojiU,
    $core.Iterable<State>? states,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (iso3 != null) {
      $result.iso3 = iso3;
    }
    if (iso2 != null) {
      $result.iso2 = iso2;
    }
    if (numericCode != null) {
      $result.numericCode = numericCode;
    }
    if (phonecode != null) {
      $result.phonecode = phonecode;
    }
    if (capital != null) {
      $result.capital = capital;
    }
    if (currency != null) {
      $result.currency = currency;
    }
    if (currencyName != null) {
      $result.currencyName = currencyName;
    }
    if (currencySymbol != null) {
      $result.currencySymbol = currencySymbol;
    }
    if (tld != null) {
      $result.tld = tld;
    }
    if (native != null) {
      $result.native = native;
    }
    if (region != null) {
      $result.region = region;
    }
    if (regionId != null) {
      $result.regionId = regionId;
    }
    if (subregion != null) {
      $result.subregion = subregion;
    }
    if (subregionId != null) {
      $result.subregionId = subregionId;
    }
    if (nationality != null) {
      $result.nationality = nationality;
    }
    if (timezones != null) {
      $result.timezones.addAll(timezones);
    }
    if (translations != null) {
      $result.translations.addAll(translations);
    }
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    if (emoji != null) {
      $result.emoji = emoji;
    }
    if (emojiU != null) {
      $result.emojiU = emojiU;
    }
    if (states != null) {
      $result.states.addAll(states);
    }
    return $result;
  }
  Country._() : super();
  factory Country.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Country.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Country',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'country'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'iso3')
    ..aOS(4, _omitFieldNames ? '' : 'iso2')
    ..aOS(5, _omitFieldNames ? '' : 'numericCode')
    ..aOS(6, _omitFieldNames ? '' : 'phonecode')
    ..aOS(7, _omitFieldNames ? '' : 'capital')
    ..aOS(8, _omitFieldNames ? '' : 'currency')
    ..aOS(9, _omitFieldNames ? '' : 'currencyName')
    ..aOS(10, _omitFieldNames ? '' : 'currencySymbol')
    ..aOS(11, _omitFieldNames ? '' : 'tld')
    ..aOS(12, _omitFieldNames ? '' : 'native')
    ..aOS(13, _omitFieldNames ? '' : 'region')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'regionId', $pb.PbFieldType.O3)
    ..aOS(15, _omitFieldNames ? '' : 'subregion')
    ..a<$core.int>(16, _omitFieldNames ? '' : 'subregionId', $pb.PbFieldType.O3)
    ..aOS(17, _omitFieldNames ? '' : 'nationality')
    ..pc<Timezone>(18, _omitFieldNames ? '' : 'timezones', $pb.PbFieldType.PM,
        subBuilder: Timezone.create)
    ..m<$core.String, $core.String>(19, _omitFieldNames ? '' : 'translations',
        entryClassName: 'Country.TranslationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('country'))
    ..a<$core.double>(20, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(
        21, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..aOS(22, _omitFieldNames ? '' : 'emoji')
    ..aOS(23, _omitFieldNames ? '' : 'emojiU', protoName: 'emojiU')
    ..pc<State>(24, _omitFieldNames ? '' : 'states', $pb.PbFieldType.PM,
        subBuilder: State.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Country clone() => Country()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Country copyWith(void Function(Country) updates) =>
      super.copyWith((message) => updates(message as Country)) as Country;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Country create() => Country._();
  Country createEmptyInstance() => create();
  static $pb.PbList<Country> createRepeated() => $pb.PbList<Country>();
  @$core.pragma('dart2js:noInline')
  static Country getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Country>(create);
  static Country? _defaultInstance;

  /// 核心字段
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get iso3 => $_getSZ(2);
  @$pb.TagNumber(3)
  set iso3($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasIso3() => $_has(2);
  @$pb.TagNumber(3)
  void clearIso3() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get iso2 => $_getSZ(3);
  @$pb.TagNumber(4)
  set iso2($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIso2() => $_has(3);
  @$pb.TagNumber(4)
  void clearIso2() => $_clearField(4);

  /// 编码类信息
  @$pb.TagNumber(5)
  $core.String get numericCode => $_getSZ(4);
  @$pb.TagNumber(5)
  set numericCode($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasNumericCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearNumericCode() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get phonecode => $_getSZ(5);
  @$pb.TagNumber(6)
  set phonecode($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasPhonecode() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhonecode() => $_clearField(6);

  /// 地理信息
  @$pb.TagNumber(7)
  $core.String get capital => $_getSZ(6);
  @$pb.TagNumber(7)
  set capital($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasCapital() => $_has(6);
  @$pb.TagNumber(7)
  void clearCapital() => $_clearField(7);

  /// 货币信息
  @$pb.TagNumber(8)
  $core.String get currency => $_getSZ(7);
  @$pb.TagNumber(8)
  set currency($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasCurrency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrency() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get currencyName => $_getSZ(8);
  @$pb.TagNumber(9)
  set currencyName($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasCurrencyName() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrencyName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get currencySymbol => $_getSZ(9);
  @$pb.TagNumber(10)
  set currencySymbol($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasCurrencySymbol() => $_has(9);
  @$pb.TagNumber(10)
  void clearCurrencySymbol() => $_clearField(10);

  /// 其他标识
  @$pb.TagNumber(11)
  $core.String get tld => $_getSZ(10);
  @$pb.TagNumber(11)
  set tld($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasTld() => $_has(10);
  @$pb.TagNumber(11)
  void clearTld() => $_clearField(11);

  /// 国际化
  @$pb.TagNumber(12)
  $core.String get native => $_getSZ(11);
  @$pb.TagNumber(12)
  set native($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasNative() => $_has(11);
  @$pb.TagNumber(12)
  void clearNative() => $_clearField(12);

  /// 行政区划
  @$pb.TagNumber(13)
  $core.String get region => $_getSZ(12);
  @$pb.TagNumber(13)
  set region($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasRegion() => $_has(12);
  @$pb.TagNumber(13)
  void clearRegion() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get regionId => $_getIZ(13);
  @$pb.TagNumber(14)
  set regionId($core.int v) {
    $_setSignedInt32(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasRegionId() => $_has(13);
  @$pb.TagNumber(14)
  void clearRegionId() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get subregion => $_getSZ(14);
  @$pb.TagNumber(15)
  set subregion($core.String v) {
    $_setString(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasSubregion() => $_has(14);
  @$pb.TagNumber(15)
  void clearSubregion() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get subregionId => $_getIZ(15);
  @$pb.TagNumber(16)
  set subregionId($core.int v) {
    $_setSignedInt32(15, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasSubregionId() => $_has(15);
  @$pb.TagNumber(16)
  void clearSubregionId() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get nationality => $_getSZ(16);
  @$pb.TagNumber(17)
  set nationality($core.String v) {
    $_setString(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasNationality() => $_has(16);
  @$pb.TagNumber(17)
  void clearNationality() => $_clearField(17);

  /// 时区信息
  @$pb.TagNumber(18)
  $pb.PbList<Timezone> get timezones => $_getList(17);

  @$pb.TagNumber(19)
  $pb.PbMap<$core.String, $core.String> get translations => $_getMap(18);

  @$pb.TagNumber(20)
  $core.double get latitude => $_getN(19);
  @$pb.TagNumber(20)
  set latitude($core.double v) {
    $_setDouble(19, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasLatitude() => $_has(19);
  @$pb.TagNumber(20)
  void clearLatitude() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.double get longitude => $_getN(20);
  @$pb.TagNumber(21)
  set longitude($core.double v) {
    $_setDouble(20, v);
  }

  @$pb.TagNumber(21)
  $core.bool hasLongitude() => $_has(20);
  @$pb.TagNumber(21)
  void clearLongitude() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get emoji => $_getSZ(21);
  @$pb.TagNumber(22)
  set emoji($core.String v) {
    $_setString(21, v);
  }

  @$pb.TagNumber(22)
  $core.bool hasEmoji() => $_has(21);
  @$pb.TagNumber(22)
  void clearEmoji() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get emojiU => $_getSZ(22);
  @$pb.TagNumber(23)
  set emojiU($core.String v) {
    $_setString(22, v);
  }

  @$pb.TagNumber(23)
  $core.bool hasEmojiU() => $_has(22);
  @$pb.TagNumber(23)
  void clearEmojiU() => $_clearField(23);

  @$pb.TagNumber(24)
  $pb.PbList<State> get states => $_getList(23);
}

class Countries extends $pb.GeneratedMessage {
  factory Countries({
    $core.Iterable<Country>? countryList,
  }) {
    final $result = create();
    if (countryList != null) {
      $result.countryList.addAll(countryList);
    }
    return $result;
  }
  Countries._() : super();
  factory Countries.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Countries.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Countries',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'country'),
      createEmptyInstance: create)
    ..pc<Country>(1, _omitFieldNames ? '' : 'countryList', $pb.PbFieldType.PM,
        protoName: 'countryList', subBuilder: Country.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Countries clone() => Countries()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Countries copyWith(void Function(Countries) updates) =>
      super.copyWith((message) => updates(message as Countries)) as Countries;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Countries create() => Countries._();
  Countries createEmptyInstance() => create();
  static $pb.PbList<Countries> createRepeated() => $pb.PbList<Countries>();
  @$core.pragma('dart2js:noInline')
  static Countries getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Countries>(create);
  static Countries? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Country> get countryList => $_getList(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
