//
//  Generated code. Do not modify.
//  source: resources/ju_mapper.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use juMapperDataDescriptor instead')
const JuMapperData$json = {
  '1': 'JuMapperData',
  '2': [
    {'1': 'jia_zi_mapping', '3': 1, '4': 3, '5': 11, '6': '.ju_mapper.JuMapperData.JiaZiMappingEntry', '10': 'jiaZiMapping'},
  ],
  '3': [JuMapperData_JiaZiMappingEntry$json],
};

@$core.Deprecated('Use juMapperDataDescriptor instead')
const JuMapperData_JiaZiMappingEntry$json = {
  '1': 'JiaZiMappingEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.ju_mapper.DiZhiMapping', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `JuMapperData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List juMapperDataDescriptor = $convert.base64Decode(
    'CgxKdU1hcHBlckRhdGESTwoOamlhX3ppX21hcHBpbmcYASADKAsyKS5qdV9tYXBwZXIuSnVNYX'
    'BwZXJEYXRhLkppYVppTWFwcGluZ0VudHJ5UgxqaWFaaU1hcHBpbmcaWAoRSmlhWmlNYXBwaW5n'
    'RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSLQoFdmFsdWUYAiABKAsyFy5qdV9tYXBwZXIuRGlaaG'
    'lNYXBwaW5nUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use diZhiMappingDescriptor instead')
const DiZhiMapping$json = {
  '1': 'DiZhiMapping',
  '2': [
    {'1': 'di_zhi_mapping', '3': 1, '4': 3, '5': 11, '6': '.ju_mapper.DiZhiMapping.DiZhiMappingEntry', '10': 'diZhiMapping'},
  ],
  '3': [DiZhiMapping_DiZhiMappingEntry$json],
};

@$core.Deprecated('Use diZhiMappingDescriptor instead')
const DiZhiMapping_DiZhiMappingEntry$json = {
  '1': 'DiZhiMappingEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.ju_mapper.YinYangNumbers', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `DiZhiMapping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diZhiMappingDescriptor = $convert.base64Decode(
    'CgxEaVpoaU1hcHBpbmcSTwoOZGlfemhpX21hcHBpbmcYASADKAsyKS5qdV9tYXBwZXIuRGlaaG'
    'lNYXBwaW5nLkRpWmhpTWFwcGluZ0VudHJ5UgxkaVpoaU1hcHBpbmcaWgoRRGlaaGlNYXBwaW5n'
    'RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSLwoFdmFsdWUYAiABKAsyGS5qdV9tYXBwZXIuWWluWW'
    'FuZ051bWJlcnNSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use yinYangNumbersDescriptor instead')
const YinYangNumbers$json = {
  '1': 'YinYangNumbers',
  '2': [
    {'1': 'yin', '3': 1, '4': 1, '5': 5, '10': 'yin'},
    {'1': 'yang', '3': 2, '4': 1, '5': 5, '10': 'yang'},
  ],
};

/// Descriptor for `YinYangNumbers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List yinYangNumbersDescriptor = $convert.base64Decode(
    'Cg5ZaW5ZYW5nTnVtYmVycxIQCgN5aW4YASABKAVSA3lpbhISCgR5YW5nGAIgASgFUgR5YW5n');

