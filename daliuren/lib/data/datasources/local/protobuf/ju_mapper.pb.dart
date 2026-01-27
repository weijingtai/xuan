//
//  Generated code. Do not modify.
//  source: resources/ju_mapper.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// 局映射主数据结构
class JuMapperData extends $pb.GeneratedMessage {
  factory JuMapperData({
    $pb.PbMap<$core.String, DiZhiMapping>? jiaZiMapping,
  }) {
    final $result = create();
    if (jiaZiMapping != null) {
      $result.jiaZiMapping.addAll(jiaZiMapping);
    }
    return $result;
  }
  JuMapperData._() : super();
  factory JuMapperData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JuMapperData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JuMapperData', package: const $pb.PackageName(_omitMessageNames ? '' : 'ju_mapper'), createEmptyInstance: create)
    ..m<$core.String, DiZhiMapping>(1, _omitFieldNames ? '' : 'jiaZiMapping', entryClassName: 'JuMapperData.JiaZiMappingEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: DiZhiMapping.create, valueDefaultOrMaker: DiZhiMapping.getDefault, packageName: const $pb.PackageName('ju_mapper'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JuMapperData clone() => JuMapperData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JuMapperData copyWith(void Function(JuMapperData) updates) => super.copyWith((message) => updates(message as JuMapperData)) as JuMapperData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JuMapperData create() => JuMapperData._();
  JuMapperData createEmptyInstance() => create();
  static $pb.PbList<JuMapperData> createRepeated() => $pb.PbList<JuMapperData>();
  @$core.pragma('dart2js:noInline')
  static JuMapperData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JuMapperData>(create);
  static JuMapperData? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, DiZhiMapping> get jiaZiMapping => $_getMap(0);
}

/// 地支映射结构
class DiZhiMapping extends $pb.GeneratedMessage {
  factory DiZhiMapping({
    $pb.PbMap<$core.String, YinYangNumbers>? diZhiMapping,
  }) {
    final $result = create();
    if (diZhiMapping != null) {
      $result.diZhiMapping.addAll(diZhiMapping);
    }
    return $result;
  }
  DiZhiMapping._() : super();
  factory DiZhiMapping.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiZhiMapping.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiZhiMapping', package: const $pb.PackageName(_omitMessageNames ? '' : 'ju_mapper'), createEmptyInstance: create)
    ..m<$core.String, YinYangNumbers>(1, _omitFieldNames ? '' : 'diZhiMapping', entryClassName: 'DiZhiMapping.DiZhiMappingEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: YinYangNumbers.create, valueDefaultOrMaker: YinYangNumbers.getDefault, packageName: const $pb.PackageName('ju_mapper'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DiZhiMapping clone() => DiZhiMapping()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DiZhiMapping copyWith(void Function(DiZhiMapping) updates) => super.copyWith((message) => updates(message as DiZhiMapping)) as DiZhiMapping;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiZhiMapping create() => DiZhiMapping._();
  DiZhiMapping createEmptyInstance() => create();
  static $pb.PbList<DiZhiMapping> createRepeated() => $pb.PbList<DiZhiMapping>();
  @$core.pragma('dart2js:noInline')
  static DiZhiMapping getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiZhiMapping>(create);
  static DiZhiMapping? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, YinYangNumbers> get diZhiMapping => $_getMap(0);
}

/// 阴阳数字结构
class YinYangNumbers extends $pb.GeneratedMessage {
  factory YinYangNumbers({
    $core.int? yin,
    $core.int? yang,
  }) {
    final $result = create();
    if (yin != null) {
      $result.yin = yin;
    }
    if (yang != null) {
      $result.yang = yang;
    }
    return $result;
  }
  YinYangNumbers._() : super();
  factory YinYangNumbers.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory YinYangNumbers.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'YinYangNumbers', package: const $pb.PackageName(_omitMessageNames ? '' : 'ju_mapper'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'yin', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'yang', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  YinYangNumbers clone() => YinYangNumbers()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  YinYangNumbers copyWith(void Function(YinYangNumbers) updates) => super.copyWith((message) => updates(message as YinYangNumbers)) as YinYangNumbers;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static YinYangNumbers create() => YinYangNumbers._();
  YinYangNumbers createEmptyInstance() => create();
  static $pb.PbList<YinYangNumbers> createRepeated() => $pb.PbList<YinYangNumbers>();
  @$core.pragma('dart2js:noInline')
  static YinYangNumbers getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<YinYangNumbers>(create);
  static YinYangNumbers? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get yin => $_getIZ(0);
  @$pb.TagNumber(1)
  set yin($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasYin() => $_has(0);
  @$pb.TagNumber(1)
  void clearYin() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get yang => $_getIZ(1);
  @$pb.TagNumber(2)
  set yang($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasYang() => $_has(1);
  @$pb.TagNumber(2)
  void clearYang() => $_clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
