// This is a generated file - do not edit.
//
// Generated from color.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ColorEntry extends $pb.GeneratedMessage {
  factory ColorEntry({
    $core.int? id,
    $core.String? name,
    $core.int? argb,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (argb != null) result.argb = argb;
    return result;
  }

  ColorEntry._();

  factory ColorEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ColorEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ColorEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chinese_color'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'argb', fieldType: $pb.PbFieldType.OF3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ColorEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ColorEntry copyWith(void Function(ColorEntry) updates) =>
      super.copyWith((message) => updates(message as ColorEntry)) as ColorEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ColorEntry create() => ColorEntry._();
  @$core.override
  ColorEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ColorEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ColorEntry>(create);
  static ColorEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get argb => $_getIZ(2);
  @$pb.TagNumber(3)
  set argb($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArgb() => $_has(2);
  @$pb.TagNumber(3)
  void clearArgb() => $_clearField(3);
}

class ColorDataset extends $pb.GeneratedMessage {
  factory ColorDataset({
    $core.String? datasetId,
    $core.String? datasetName,
    $core.String? webAddress,
    $core.Iterable<ColorEntry>? entries,
  }) {
    final result = create();
    if (datasetId != null) result.datasetId = datasetId;
    if (datasetName != null) result.datasetName = datasetName;
    if (webAddress != null) result.webAddress = webAddress;
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  ColorDataset._();

  factory ColorDataset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ColorDataset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ColorDataset',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chinese_color'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasetId')
    ..aOS(2, _omitFieldNames ? '' : 'datasetName')
    ..aOS(3, _omitFieldNames ? '' : 'webAddress')
    ..pPM<ColorEntry>(4, _omitFieldNames ? '' : 'entries',
        subBuilder: ColorEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ColorDataset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ColorDataset copyWith(void Function(ColorDataset) updates) =>
      super.copyWith((message) => updates(message as ColorDataset))
          as ColorDataset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ColorDataset create() => ColorDataset._();
  @$core.override
  ColorDataset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ColorDataset getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ColorDataset>(create);
  static ColorDataset? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get datasetName => $_getSZ(1);
  @$pb.TagNumber(2)
  set datasetName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDatasetName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDatasetName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get webAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set webAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWebAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearWebAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<ColorEntry> get entries => $_getList(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
