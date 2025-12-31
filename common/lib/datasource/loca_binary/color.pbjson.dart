// This is a generated file - do not edit.
//
// Generated from color.proto.

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

@$core.Deprecated('Use colorEntryDescriptor instead')
const ColorEntry$json = {
  '1': 'ColorEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'argb', '3': 3, '4': 1, '5': 7, '10': 'argb'},
  ],
};

/// Descriptor for `ColorEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List colorEntryDescriptor = $convert.base64Decode(
    'CgpDb2xvckVudHJ5Eg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBGFyZ2'
    'IYAyABKAdSBGFyZ2I=');

@$core.Deprecated('Use colorDatasetDescriptor instead')
const ColorDataset$json = {
  '1': 'ColorDataset',
  '2': [
    {'1': 'dataset_id', '3': 1, '4': 1, '5': 9, '10': 'datasetId'},
    {'1': 'dataset_name', '3': 2, '4': 1, '5': 9, '10': 'datasetName'},
    {'1': 'web_address', '3': 3, '4': 1, '5': 9, '10': 'webAddress'},
    {
      '1': 'entries',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.chinese_color.ColorEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `ColorDataset`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List colorDatasetDescriptor = $convert.base64Decode(
    'CgxDb2xvckRhdGFzZXQSHQoKZGF0YXNldF9pZBgBIAEoCVIJZGF0YXNldElkEiEKDGRhdGFzZX'
    'RfbmFtZRgCIAEoCVILZGF0YXNldE5hbWUSHwoLd2ViX2FkZHJlc3MYAyABKAlSCndlYkFkZHJl'
    'c3MSMwoHZW50cmllcxgEIAMoCzIZLmNoaW5lc2VfY29sb3IuQ29sb3JFbnRyeVIHZW50cmllcw'
    '==');
