//
//  Generated code. Do not modify.
//  source: jia_wu_geng_niu_yang.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use xuanDaLiuRenDataDescriptor instead')
const XuanDaLiuRenData$json = {
  '1': 'XuanDaLiuRenData',
  '2': [
    {'1': 'day_jia_zi', '3': 1, '4': 1, '5': 9, '10': 'dayJiaZi'},
    {'1': 'shi_chen', '3': 2, '4': 1, '5': 9, '10': 'shiChen'},
    {'1': 'ju_number_name', '3': 3, '4': 1, '5': 9, '10': 'juNumberName'},
    {'1': 'ju_number', '3': 4, '4': 1, '5': 5, '10': 'juNumber'},
    {'1': 'four_class', '3': 5, '4': 1, '5': 11, '6': '.xuan_daliuren.FourClass', '10': 'fourClass'},
    {'1': 'three_chuan', '3': 6, '4': 1, '5': 11, '6': '.xuan_daliuren.ThreeChuan', '10': 'threeChuan'},
    {'1': 'gong_mapper', '3': 7, '4': 3, '5': 11, '6': '.xuan_daliuren.XuanDaLiuRenData.GongMapperEntry', '10': 'gongMapper'},
  ],
  '3': [XuanDaLiuRenData_GongMapperEntry$json],
};

@$core.Deprecated('Use xuanDaLiuRenDataDescriptor instead')
const XuanDaLiuRenData_GongMapperEntry$json = {
  '1': 'GongMapperEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.xuan_daliuren.GongInfo', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `XuanDaLiuRenData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List xuanDaLiuRenDataDescriptor = $convert.base64Decode(
    'ChBYdWFuRGFMaXVSZW5EYXRhEhwKCmRheV9qaWFfemkYASABKAlSCGRheUppYVppEhkKCHNoaV'
    '9jaGVuGAIgASgJUgdzaGlDaGVuEiQKDmp1X251bWJlcl9uYW1lGAMgASgJUgxqdU51bWJlck5h'
    'bWUSGwoJanVfbnVtYmVyGAQgASgFUghqdU51bWJlchI3Cgpmb3VyX2NsYXNzGAUgASgLMhgueH'
    'Vhbl9kYWxpdXJlbi5Gb3VyQ2xhc3NSCWZvdXJDbGFzcxI6Cgt0aHJlZV9jaHVhbhgGIAEoCzIZ'
    'Lnh1YW5fZGFsaXVyZW4uVGhyZWVDaHVhblIKdGhyZWVDaHVhbhJQCgtnb25nX21hcHBlchgHIA'
    'MoCzIvLnh1YW5fZGFsaXVyZW4uWHVhbkRhTGl1UmVuRGF0YS5Hb25nTWFwcGVyRW50cnlSCmdv'
    'bmdNYXBwZXIaVgoPR29uZ01hcHBlckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5Ei0KBXZhbHVlGA'
    'IgASgLMhcueHVhbl9kYWxpdXJlbi5Hb25nSW5mb1IFdmFsdWU6AjgB');

@$core.Deprecated('Use fourClassDescriptor instead')
const FourClass$json = {
  '1': 'FourClass',
  '2': [
    {'1': 'is_full_class', '3': 1, '4': 1, '5': 8, '10': 'isFullClass'},
    {'1': 'is_three_class_only', '3': 2, '4': 1, '5': 8, '10': 'isThreeClassOnly'},
    {'1': 'is_fu_yin', '3': 3, '4': 1, '5': 8, '10': 'isFuYin'},
    {'1': 'is_fan_yin', '3': 4, '4': 1, '5': 8, '10': 'isFanYin'},
    {'1': 'first', '3': 5, '4': 1, '5': 11, '6': '.xuan_daliuren.ClassInfo', '10': 'first'},
    {'1': 'second', '3': 6, '4': 1, '5': 11, '6': '.xuan_daliuren.ClassInfo', '10': 'second'},
    {'1': 'third', '3': 7, '4': 1, '5': 11, '6': '.xuan_daliuren.ClassInfo', '10': 'third'},
    {'1': 'fourth', '3': 8, '4': 1, '5': 11, '6': '.xuan_daliuren.ClassInfo', '10': 'fourth'},
    {'1': 'same_sky_ground_class_list', '3': 9, '4': 3, '5': 5, '10': 'sameSkyGroundClassList'},
  ],
};

/// Descriptor for `FourClass`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fourClassDescriptor = $convert.base64Decode(
    'CglGb3VyQ2xhc3MSIgoNaXNfZnVsbF9jbGFzcxgBIAEoCFILaXNGdWxsQ2xhc3MSLQoTaXNfdG'
    'hyZWVfY2xhc3Nfb25seRgCIAEoCFIQaXNUaHJlZUNsYXNzT25seRIaCglpc19mdV95aW4YAyAB'
    'KAhSB2lzRnVZaW4SHAoKaXNfZmFuX3lpbhgEIAEoCFIIaXNGYW5ZaW4SLgoFZmlyc3QYBSABKA'
    'syGC54dWFuX2RhbGl1cmVuLkNsYXNzSW5mb1IFZmlyc3QSMAoGc2Vjb25kGAYgASgLMhgueHVh'
    'bl9kYWxpdXJlbi5DbGFzc0luZm9SBnNlY29uZBIuCgV0aGlyZBgHIAEoCzIYLnh1YW5fZGFsaX'
    'VyZW4uQ2xhc3NJbmZvUgV0aGlyZBIwCgZmb3VydGgYCCABKAsyGC54dWFuX2RhbGl1cmVuLkNs'
    'YXNzSW5mb1IGZm91cnRoEjoKGnNhbWVfc2t5X2dyb3VuZF9jbGFzc19saXN0GAkgAygFUhZzYW'
    '1lU2t5R3JvdW5kQ2xhc3NMaXN0');

@$core.Deprecated('Use classInfoDescriptor instead')
const ClassInfo$json = {
  '1': 'ClassInfo',
  '2': [
    {'1': 'order', '3': 1, '4': 1, '5': 5, '10': 'order'},
    {'1': 'sky', '3': 2, '4': 1, '5': 9, '10': 'sky'},
    {'1': 'ground', '3': 3, '4': 1, '5': 9, '10': 'ground'},
    {'1': 'is_first_class', '3': 4, '4': 1, '5': 8, '10': 'isFirstClass'},
    {'1': 'gui_ren', '3': 5, '4': 1, '5': 9, '10': 'guiRen'},
    {'1': 'she_hai_times', '3': 6, '4': 1, '5': 5, '9': 0, '10': 'sheHaiTimes', '17': true},
    {'1': 'other_same_sky_ground_index_list', '3': 7, '4': 3, '5': 5, '10': 'otherSameSkyGroundIndexList'},
    {'1': 'zei_ke_type', '3': 8, '4': 1, '5': 9, '9': 1, '10': 'zeiKeType', '17': true},
    {'1': 'is_sky_ke_day_gan', '3': 9, '4': 1, '5': 8, '9': 2, '10': 'isSkyKeDayGan', '17': true},
    {'1': 'is_sky_same_yin_yang_with_day_gan', '3': 10, '4': 1, '5': 8, '10': 'isSkySameYinYangWithDayGan'},
    {'1': 'tian_gan', '3': 11, '4': 1, '5': 9, '9': 3, '10': 'tianGan', '17': true},
  ],
  '8': [
    {'1': '_she_hai_times'},
    {'1': '_zei_ke_type'},
    {'1': '_is_sky_ke_day_gan'},
    {'1': '_tian_gan'},
  ],
};

/// Descriptor for `ClassInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List classInfoDescriptor = $convert.base64Decode(
    'CglDbGFzc0luZm8SFAoFb3JkZXIYASABKAVSBW9yZGVyEhAKA3NreRgCIAEoCVIDc2t5EhYKBm'
    'dyb3VuZBgDIAEoCVIGZ3JvdW5kEiQKDmlzX2ZpcnN0X2NsYXNzGAQgASgIUgxpc0ZpcnN0Q2xh'
    'c3MSFwoHZ3VpX3JlbhgFIAEoCVIGZ3VpUmVuEicKDXNoZV9oYWlfdGltZXMYBiABKAVIAFILc2'
    'hlSGFpVGltZXOIAQESRQogb3RoZXJfc2FtZV9za3lfZ3JvdW5kX2luZGV4X2xpc3QYByADKAVS'
    'G290aGVyU2FtZVNreUdyb3VuZEluZGV4TGlzdBIjCgt6ZWlfa2VfdHlwZRgIIAEoCUgBUgl6ZW'
    'lLZVR5cGWIAQESLQoRaXNfc2t5X2tlX2RheV9nYW4YCSABKAhIAlINaXNTa3lLZURheUdhbogB'
    'ARJFCiFpc19za3lfc2FtZV95aW5feWFuZ193aXRoX2RheV9nYW4YCiABKAhSGmlzU2t5U2FtZV'
    'lpbllhbmdXaXRoRGF5R2FuEh4KCHRpYW5fZ2FuGAsgASgJSANSB3RpYW5HYW6IAQFCEAoOX3No'
    'ZV9oYWlfdGltZXNCDgoMX3plaV9rZV90eXBlQhQKEl9pc19za3lfa2VfZGF5X2dhbkILCglfdG'
    'lhbl9nYW4=');

@$core.Deprecated('Use threeChuanDescriptor instead')
const ThreeChuan$json = {
  '1': 'ThreeChuan',
  '2': [
    {'1': 'nine_zong_men', '3': 1, '4': 1, '5': 9, '10': 'nineZongMen'},
    {'1': 'first', '3': 2, '4': 1, '5': 11, '6': '.xuan_daliuren.ChuanInfo', '10': 'first'},
    {'1': 'second', '3': 3, '4': 1, '5': 11, '6': '.xuan_daliuren.ChuanInfo', '10': 'second'},
    {'1': 'third', '3': 4, '4': 1, '5': 11, '6': '.xuan_daliuren.ChuanInfo', '10': 'third'},
    {'1': 'type', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'type', '17': true},
    {'1': 'zei_ke_type', '3': 6, '4': 1, '5': 9, '9': 1, '10': 'zeiKeType', '17': true},
  ],
  '8': [
    {'1': '_type'},
    {'1': '_zei_ke_type'},
  ],
};

/// Descriptor for `ThreeChuan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List threeChuanDescriptor = $convert.base64Decode(
    'CgpUaHJlZUNodWFuEiIKDW5pbmVfem9uZ19tZW4YASABKAlSC25pbmVab25nTWVuEi4KBWZpcn'
    'N0GAIgASgLMhgueHVhbl9kYWxpdXJlbi5DaHVhbkluZm9SBWZpcnN0EjAKBnNlY29uZBgDIAEo'
    'CzIYLnh1YW5fZGFsaXVyZW4uQ2h1YW5JbmZvUgZzZWNvbmQSLgoFdGhpcmQYBCABKAsyGC54dW'
    'FuX2RhbGl1cmVuLkNodWFuSW5mb1IFdGhpcmQSFwoEdHlwZRgFIAEoCUgAUgR0eXBliAEBEiMK'
    'C3plaV9rZV90eXBlGAYgASgJSAFSCXplaUtlVHlwZYgBAUIHCgVfdHlwZUIOCgxfemVpX2tlX3'
    'R5cGU=');

@$core.Deprecated('Use chuanInfoDescriptor instead')
const ChuanInfo$json = {
  '1': 'ChuanInfo',
  '2': [
    {'1': 'order', '3': 1, '4': 1, '5': 5, '10': 'order'},
    {'1': 'di_zhi', '3': 2, '4': 1, '5': 9, '10': 'diZhi'},
    {'1': 'gui_ren', '3': 3, '4': 1, '5': 9, '10': 'guiRen'},
    {'1': 'liu_qin', '3': 4, '4': 1, '5': 9, '10': 'liuQin'},
  ],
};

/// Descriptor for `ChuanInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chuanInfoDescriptor = $convert.base64Decode(
    'CglDaHVhbkluZm8SFAoFb3JkZXIYASABKAVSBW9yZGVyEhUKBmRpX3poaRgCIAEoCVIFZGlaaG'
    'kSFwoHZ3VpX3JlbhgDIAEoCVIGZ3VpUmVuEhcKB2xpdV9xaW4YBCABKAlSBmxpdVFpbg==');

@$core.Deprecated('Use gongInfoDescriptor instead')
const GongInfo$json = {
  '1': 'GongInfo',
  '2': [
    {'1': 'ground_pan_di_zhi', '3': 1, '4': 1, '5': 9, '10': 'groundPanDiZhi'},
    {'1': 'gui_ren', '3': 2, '4': 1, '5': 9, '10': 'guiRen'},
    {'1': 'sky_pan_di_zhi', '3': 3, '4': 1, '5': 9, '10': 'skyPanDiZhi'},
  ],
};

/// Descriptor for `GongInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gongInfoDescriptor = $convert.base64Decode(
    'CghHb25nSW5mbxIpChFncm91bmRfcGFuX2RpX3poaRgBIAEoCVIOZ3JvdW5kUGFuRGlaaGkSFw'
    'oHZ3VpX3JlbhgCIAEoCVIGZ3VpUmVuEiMKDnNreV9wYW5fZGlfemhpGAMgASgJUgtza3lQYW5E'
    'aVpoaQ==');

@$core.Deprecated('Use xuanDaLiuRenDataListDescriptor instead')
const XuanDaLiuRenDataList$json = {
  '1': 'XuanDaLiuRenDataList',
  '2': [
    {'1': 'isYinYang', '3': 1, '4': 1, '5': 8, '10': 'isYinYang'},
    {'1': 'data_list', '3': 2, '4': 3, '5': 11, '6': '.xuan_daliuren.XuanDaLiuRenData', '10': 'dataList'},
  ],
};

/// Descriptor for `XuanDaLiuRenDataList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List xuanDaLiuRenDataListDescriptor = $convert.base64Decode(
    'ChRYdWFuRGFMaXVSZW5EYXRhTGlzdBIcCglpc1lpbllhbmcYASABKAhSCWlzWWluWWFuZxI8Cg'
    'lkYXRhX2xpc3QYAiADKAsyHy54dWFuX2RhbGl1cmVuLlh1YW5EYUxpdVJlbkRhdGFSCGRhdGFM'
    'aXN0');

@$core.Deprecated('Use xuanDaLiuRenDataListBundleDescriptor instead')
const XuanDaLiuRenDataListBundle$json = {
  '1': 'XuanDaLiuRenDataListBundle',
  '2': [
    {'1': 'yangList', '3': 1, '4': 1, '5': 11, '6': '.xuan_daliuren.XuanDaLiuRenDataList', '10': 'yangList'},
    {'1': 'yinList', '3': 2, '4': 1, '5': 11, '6': '.xuan_daliuren.XuanDaLiuRenDataList', '10': 'yinList'},
  ],
};

/// Descriptor for `XuanDaLiuRenDataListBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List xuanDaLiuRenDataListBundleDescriptor = $convert.base64Decode(
    'ChpYdWFuRGFMaXVSZW5EYXRhTGlzdEJ1bmRsZRI/Cgh5YW5nTGlzdBgBIAEoCzIjLnh1YW5fZG'
    'FsaXVyZW4uWHVhbkRhTGl1UmVuRGF0YUxpc3RSCHlhbmdMaXN0Ej0KB3lpbkxpc3QYAiABKAsy'
    'Iy54dWFuX2RhbGl1cmVuLlh1YW5EYUxpdVJlbkRhdGFMaXN0Ugd5aW5MaXN0');

