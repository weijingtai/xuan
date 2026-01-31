// This is a generated file - do not edit.
//
// Generated from country.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use timezoneDescriptor instead')
const Timezone$json = {
  '1': 'Timezone',
  '2': [
    {'1': 'zone_name', '3': 1, '4': 1, '5': 9, '10': 'zoneName'},
    {'1': 'gmt_offset', '3': 2, '4': 1, '5': 5, '10': 'gmtOffset'},
    {'1': 'gmt_offset_name', '3': 3, '4': 1, '5': 9, '10': 'gmtOffsetName'},
    {'1': 'abbreviation', '3': 4, '4': 1, '5': 9, '10': 'abbreviation'},
    {'1': 'tz_name', '3': 5, '4': 1, '5': 9, '10': 'tzName'},
  ],
};

/// Descriptor for `Timezone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timezoneDescriptor = $convert.base64Decode(
    'CghUaW1lem9uZRIbCgl6b25lX25hbWUYASABKAlSCHpvbmVOYW1lEh0KCmdtdF9vZmZzZXQYAi'
    'ABKAVSCWdtdE9mZnNldBImCg9nbXRfb2Zmc2V0X25hbWUYAyABKAlSDWdtdE9mZnNldE5hbWUS'
    'IgoMYWJicmV2aWF0aW9uGAQgASgJUgxhYmJyZXZpYXRpb24SFwoHdHpfbmFtZRgFIAEoCVIGdH'
    'pOYW1l');

@$core.Deprecated('Use cityDescriptor instead')
const City$json = {
  '1': 'City',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'latitude', '3': 4, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 5, '4': 1, '5': 1, '10': 'longitude'},
  ],
};

/// Descriptor for `City`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityDescriptor = $convert.base64Decode(
    'CgRDaXR5Eg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhoKCGxhdGl0dWRlGA'
    'QgASgBUghsYXRpdHVkZRIcCglsb25naXR1ZGUYBSABKAFSCWxvbmdpdHVkZQ==');

@$core.Deprecated('Use stateDescriptor instead')
const State$json = {
  '1': 'State',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'state_code',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'stateCode',
      '17': true
    },
    {'1': 'latitude', '3': 4, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 5, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'type', '3': 6, '4': 1, '5': 9, '10': 'type'},
    {
      '1': 'cities',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.country.City',
      '10': 'cities'
    },
  ],
  '8': [
    {'1': '_state_code'},
  ],
};

/// Descriptor for `State`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stateDescriptor = $convert.base64Decode(
    'CgVTdGF0ZRIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIiCgpzdGF0ZV9jb2'
    'RlGAMgASgJSABSCXN0YXRlQ29kZYgBARIaCghsYXRpdHVkZRgEIAEoAVIIbGF0aXR1ZGUSHAoJ'
    'bG9uZ2l0dWRlGAUgASgBUglsb25naXR1ZGUSEgoEdHlwZRgGIAEoCVIEdHlwZRIlCgZjaXRpZX'
    'MYByADKAsyDS5jb3VudHJ5LkNpdHlSBmNpdGllc0INCgtfc3RhdGVfY29kZQ==');

@$core.Deprecated('Use countryDescriptor instead')
const Country$json = {
  '1': 'Country',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'iso3', '3': 3, '4': 1, '5': 9, '10': 'iso3'},
    {'1': 'iso2', '3': 4, '4': 1, '5': 9, '10': 'iso2'},
    {'1': 'numeric_code', '3': 5, '4': 1, '5': 9, '10': 'numericCode'},
    {'1': 'phonecode', '3': 6, '4': 1, '5': 9, '10': 'phonecode'},
    {'1': 'capital', '3': 7, '4': 1, '5': 9, '10': 'capital'},
    {'1': 'latitude', '3': 20, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 21, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'region', '3': 13, '4': 1, '5': 9, '10': 'region'},
    {'1': 'region_id', '3': 14, '4': 1, '5': 5, '10': 'regionId'},
    {'1': 'subregion', '3': 15, '4': 1, '5': 9, '10': 'subregion'},
    {'1': 'subregion_id', '3': 16, '4': 1, '5': 5, '10': 'subregionId'},
    {
      '1': 'states',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.country.State',
      '10': 'states'
    },
    {'1': 'currency', '3': 8, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'currency_name', '3': 9, '4': 1, '5': 9, '10': 'currencyName'},
    {'1': 'currency_symbol', '3': 10, '4': 1, '5': 9, '10': 'currencySymbol'},
    {'1': 'native', '3': 12, '4': 1, '5': 9, '10': 'native'},
    {'1': 'nationality', '3': 17, '4': 1, '5': 9, '10': 'nationality'},
    {
      '1': 'translations',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.country.Country.TranslationsEntry',
      '10': 'translations'
    },
    {'1': 'tld', '3': 11, '4': 1, '5': 9, '10': 'tld'},
    {'1': 'emoji', '3': 22, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'emojiU', '3': 23, '4': 1, '5': 9, '10': 'emojiU'},
    {
      '1': 'timezones',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.country.Timezone',
      '10': 'timezones'
    },
  ],
  '3': [Country_TranslationsEntry$json],
};

@$core.Deprecated('Use countryDescriptor instead')
const Country_TranslationsEntry$json = {
  '1': 'TranslationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Country`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List countryDescriptor = $convert.base64Decode(
    'CgdDb3VudHJ5Eg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBGlzbzMYAy'
    'ABKAlSBGlzbzMSEgoEaXNvMhgEIAEoCVIEaXNvMhIhCgxudW1lcmljX2NvZGUYBSABKAlSC251'
    'bWVyaWNDb2RlEhwKCXBob25lY29kZRgGIAEoCVIJcGhvbmVjb2RlEhgKB2NhcGl0YWwYByABKA'
    'lSB2NhcGl0YWwSGgoIbGF0aXR1ZGUYFCABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdHVkZRgVIAEo'
    'AVIJbG9uZ2l0dWRlEhYKBnJlZ2lvbhgNIAEoCVIGcmVnaW9uEhsKCXJlZ2lvbl9pZBgOIAEoBV'
    'IIcmVnaW9uSWQSHAoJc3VicmVnaW9uGA8gASgJUglzdWJyZWdpb24SIQoMc3VicmVnaW9uX2lk'
    'GBAgASgFUgtzdWJyZWdpb25JZBImCgZzdGF0ZXMYGCADKAsyDi5jb3VudHJ5LlN0YXRlUgZzdG'
    'F0ZXMSGgoIY3VycmVuY3kYCCABKAlSCGN1cnJlbmN5EiMKDWN1cnJlbmN5X25hbWUYCSABKAlS'
    'DGN1cnJlbmN5TmFtZRInCg9jdXJyZW5jeV9zeW1ib2wYCiABKAlSDmN1cnJlbmN5U3ltYm9sEh'
    'YKBm5hdGl2ZRgMIAEoCVIGbmF0aXZlEiAKC25hdGlvbmFsaXR5GBEgASgJUgtuYXRpb25hbGl0'
    'eRJGCgx0cmFuc2xhdGlvbnMYEyADKAsyIi5jb3VudHJ5LkNvdW50cnkuVHJhbnNsYXRpb25zRW'
    '50cnlSDHRyYW5zbGF0aW9ucxIQCgN0bGQYCyABKAlSA3RsZBIUCgVlbW9qaRgWIAEoCVIFZW1v'
    'amkSFgoGZW1vamlVGBcgASgJUgZlbW9qaVUSLwoJdGltZXpvbmVzGBIgAygLMhEuY291bnRyeS'
    '5UaW1lem9uZVIJdGltZXpvbmVzGj8KEVRyYW5zbGF0aW9uc0VudHJ5EhAKA2tleRgBIAEoCVID'
    'a2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use countriesDescriptor instead')
const Countries$json = {
  '1': 'Countries',
  '2': [
    {
      '1': 'countryList',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.country.Country',
      '10': 'countryList'
    },
  ],
};

/// Descriptor for `Countries`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List countriesDescriptor = $convert.base64Decode(
    'CglDb3VudHJpZXMSMgoLY291bnRyeUxpc3QYASADKAsyEC5jb3VudHJ5LkNvdW50cnlSC2NvdW'
    '50cnlMaXN0');
