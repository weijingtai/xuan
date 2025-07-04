//
//  Generated code. Do not modify.
//  source: resources/jia_wu_geng_niu_yang.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// 主要的玄大六壬数据结构
class XuanDaLiuRenData extends $pb.GeneratedMessage {
  factory XuanDaLiuRenData({
    $core.String? dayJiaZi,
    $core.String? shiChen,
    $core.String? juNumberName,
    FourClass? fourClass,
    ThreeChuan? threeChuan,
    $pb.PbMap<$core.String, GongInfo>? gongMapper,
  }) {
    final $result = create();
    if (dayJiaZi != null) {
      $result.dayJiaZi = dayJiaZi;
    }
    if (shiChen != null) {
      $result.shiChen = shiChen;
    }
    if (juNumberName != null) {
      $result.juNumberName = juNumberName;
    }
    if (fourClass != null) {
      $result.fourClass = fourClass;
    }
    if (threeChuan != null) {
      $result.threeChuan = threeChuan;
    }
    if (gongMapper != null) {
      $result.gongMapper.addAll(gongMapper);
    }
    return $result;
  }
  XuanDaLiuRenData._() : super();
  factory XuanDaLiuRenData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory XuanDaLiuRenData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'XuanDaLiuRenData', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dayJiaZi')
    ..aOS(2, _omitFieldNames ? '' : 'shiChen')
    ..aOS(3, _omitFieldNames ? '' : 'juNumberName')
    ..aOM<FourClass>(4, _omitFieldNames ? '' : 'fourClass', subBuilder: FourClass.create)
    ..aOM<ThreeChuan>(5, _omitFieldNames ? '' : 'threeChuan', subBuilder: ThreeChuan.create)
    ..m<$core.String, GongInfo>(6, _omitFieldNames ? '' : 'gongMapper', entryClassName: 'XuanDaLiuRenData.GongMapperEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: GongInfo.create, valueDefaultOrMaker: GongInfo.getDefault, packageName: const $pb.PackageName('xuan_daliuren'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenData clone() => XuanDaLiuRenData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenData copyWith(void Function(XuanDaLiuRenData) updates) => super.copyWith((message) => updates(message as XuanDaLiuRenData)) as XuanDaLiuRenData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenData create() => XuanDaLiuRenData._();
  XuanDaLiuRenData createEmptyInstance() => create();
  static $pb.PbList<XuanDaLiuRenData> createRepeated() => $pb.PbList<XuanDaLiuRenData>();
  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<XuanDaLiuRenData>(create);
  static XuanDaLiuRenData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dayJiaZi => $_getSZ(0);
  @$pb.TagNumber(1)
  set dayJiaZi($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDayJiaZi() => $_has(0);
  @$pb.TagNumber(1)
  void clearDayJiaZi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shiChen => $_getSZ(1);
  @$pb.TagNumber(2)
  set shiChen($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasShiChen() => $_has(1);
  @$pb.TagNumber(2)
  void clearShiChen() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get juNumberName => $_getSZ(2);
  @$pb.TagNumber(3)
  set juNumberName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasJuNumberName() => $_has(2);
  @$pb.TagNumber(3)
  void clearJuNumberName() => $_clearField(3);

  @$pb.TagNumber(4)
  FourClass get fourClass => $_getN(3);
  @$pb.TagNumber(4)
  set fourClass(FourClass v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFourClass() => $_has(3);
  @$pb.TagNumber(4)
  void clearFourClass() => $_clearField(4);
  @$pb.TagNumber(4)
  FourClass ensureFourClass() => $_ensure(3);

  @$pb.TagNumber(5)
  ThreeChuan get threeChuan => $_getN(4);
  @$pb.TagNumber(5)
  set threeChuan(ThreeChuan v) { $_setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasThreeChuan() => $_has(4);
  @$pb.TagNumber(5)
  void clearThreeChuan() => $_clearField(5);
  @$pb.TagNumber(5)
  ThreeChuan ensureThreeChuan() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, GongInfo> get gongMapper => $_getMap(5);
}

/// 四课结构
class FourClass extends $pb.GeneratedMessage {
  factory FourClass({
    $core.bool? isFullClass,
    $core.bool? isThreeClassOnly,
    $core.bool? isFuYin,
    $core.bool? isFanYin,
    ClassInfo? first,
    ClassInfo? second,
    ClassInfo? third,
    ClassInfo? fourth,
    $core.Iterable<$core.int>? sameSkyGroundClassList,
  }) {
    final $result = create();
    if (isFullClass != null) {
      $result.isFullClass = isFullClass;
    }
    if (isThreeClassOnly != null) {
      $result.isThreeClassOnly = isThreeClassOnly;
    }
    if (isFuYin != null) {
      $result.isFuYin = isFuYin;
    }
    if (isFanYin != null) {
      $result.isFanYin = isFanYin;
    }
    if (first != null) {
      $result.first = first;
    }
    if (second != null) {
      $result.second = second;
    }
    if (third != null) {
      $result.third = third;
    }
    if (fourth != null) {
      $result.fourth = fourth;
    }
    if (sameSkyGroundClassList != null) {
      $result.sameSkyGroundClassList.addAll(sameSkyGroundClassList);
    }
    return $result;
  }
  FourClass._() : super();
  factory FourClass.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FourClass.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FourClass', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isFullClass')
    ..aOB(2, _omitFieldNames ? '' : 'isThreeClassOnly')
    ..aOB(3, _omitFieldNames ? '' : 'isFuYin')
    ..aOB(4, _omitFieldNames ? '' : 'isFanYin')
    ..aOM<ClassInfo>(5, _omitFieldNames ? '' : 'first', subBuilder: ClassInfo.create)
    ..aOM<ClassInfo>(6, _omitFieldNames ? '' : 'second', subBuilder: ClassInfo.create)
    ..aOM<ClassInfo>(7, _omitFieldNames ? '' : 'third', subBuilder: ClassInfo.create)
    ..aOM<ClassInfo>(8, _omitFieldNames ? '' : 'fourth', subBuilder: ClassInfo.create)
    ..p<$core.int>(9, _omitFieldNames ? '' : 'sameSkyGroundClassList', $pb.PbFieldType.K3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FourClass clone() => FourClass()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FourClass copyWith(void Function(FourClass) updates) => super.copyWith((message) => updates(message as FourClass)) as FourClass;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FourClass create() => FourClass._();
  FourClass createEmptyInstance() => create();
  static $pb.PbList<FourClass> createRepeated() => $pb.PbList<FourClass>();
  @$core.pragma('dart2js:noInline')
  static FourClass getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FourClass>(create);
  static FourClass? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isFullClass => $_getBF(0);
  @$pb.TagNumber(1)
  set isFullClass($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsFullClass() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsFullClass() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isThreeClassOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set isThreeClassOnly($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsThreeClassOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsThreeClassOnly() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isFuYin => $_getBF(2);
  @$pb.TagNumber(3)
  set isFuYin($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsFuYin() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsFuYin() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isFanYin => $_getBF(3);
  @$pb.TagNumber(4)
  set isFanYin($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsFanYin() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsFanYin() => $_clearField(4);

  @$pb.TagNumber(5)
  ClassInfo get first => $_getN(4);
  @$pb.TagNumber(5)
  set first(ClassInfo v) { $_setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasFirst() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirst() => $_clearField(5);
  @$pb.TagNumber(5)
  ClassInfo ensureFirst() => $_ensure(4);

  @$pb.TagNumber(6)
  ClassInfo get second => $_getN(5);
  @$pb.TagNumber(6)
  set second(ClassInfo v) { $_setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasSecond() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecond() => $_clearField(6);
  @$pb.TagNumber(6)
  ClassInfo ensureSecond() => $_ensure(5);

  @$pb.TagNumber(7)
  ClassInfo get third => $_getN(6);
  @$pb.TagNumber(7)
  set third(ClassInfo v) { $_setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasThird() => $_has(6);
  @$pb.TagNumber(7)
  void clearThird() => $_clearField(7);
  @$pb.TagNumber(7)
  ClassInfo ensureThird() => $_ensure(6);

  @$pb.TagNumber(8)
  ClassInfo get fourth => $_getN(7);
  @$pb.TagNumber(8)
  set fourth(ClassInfo v) { $_setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFourth() => $_has(7);
  @$pb.TagNumber(8)
  void clearFourth() => $_clearField(8);
  @$pb.TagNumber(8)
  ClassInfo ensureFourth() => $_ensure(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.int> get sameSkyGroundClassList => $_getList(8);
}

/// 课信息
class ClassInfo extends $pb.GeneratedMessage {
  factory ClassInfo({
    $core.int? order,
    $core.String? sky,
    $core.String? ground,
    $core.bool? isFirstClass,
    $core.String? guiRen,
    $core.int? sheHaiTimes,
    $core.Iterable<$core.int>? otherSameSkyGroundIndexList,
    $core.String? zeiKeType,
    $core.bool? isSkyKeDayGan,
    $core.bool? isSkySameYinYangWithDayGan,
    $core.String? tianGan,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    if (sky != null) {
      $result.sky = sky;
    }
    if (ground != null) {
      $result.ground = ground;
    }
    if (isFirstClass != null) {
      $result.isFirstClass = isFirstClass;
    }
    if (guiRen != null) {
      $result.guiRen = guiRen;
    }
    if (sheHaiTimes != null) {
      $result.sheHaiTimes = sheHaiTimes;
    }
    if (otherSameSkyGroundIndexList != null) {
      $result.otherSameSkyGroundIndexList.addAll(otherSameSkyGroundIndexList);
    }
    if (zeiKeType != null) {
      $result.zeiKeType = zeiKeType;
    }
    if (isSkyKeDayGan != null) {
      $result.isSkyKeDayGan = isSkyKeDayGan;
    }
    if (isSkySameYinYangWithDayGan != null) {
      $result.isSkySameYinYangWithDayGan = isSkySameYinYangWithDayGan;
    }
    if (tianGan != null) {
      $result.tianGan = tianGan;
    }
    return $result;
  }
  ClassInfo._() : super();
  factory ClassInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClassInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClassInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'order', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'sky')
    ..aOS(3, _omitFieldNames ? '' : 'ground')
    ..aOB(4, _omitFieldNames ? '' : 'isFirstClass')
    ..aOS(5, _omitFieldNames ? '' : 'guiRen')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'sheHaiTimes', $pb.PbFieldType.O3)
    ..p<$core.int>(7, _omitFieldNames ? '' : 'otherSameSkyGroundIndexList', $pb.PbFieldType.K3)
    ..aOS(8, _omitFieldNames ? '' : 'zeiKeType')
    ..aOB(9, _omitFieldNames ? '' : 'isSkyKeDayGan')
    ..aOB(10, _omitFieldNames ? '' : 'isSkySameYinYangWithDayGan')
    ..aOS(11, _omitFieldNames ? '' : 'tianGan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClassInfo clone() => ClassInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClassInfo copyWith(void Function(ClassInfo) updates) => super.copyWith((message) => updates(message as ClassInfo)) as ClassInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClassInfo create() => ClassInfo._();
  ClassInfo createEmptyInstance() => create();
  static $pb.PbList<ClassInfo> createRepeated() => $pb.PbList<ClassInfo>();
  @$core.pragma('dart2js:noInline')
  static ClassInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClassInfo>(create);
  static ClassInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get order => $_getIZ(0);
  @$pb.TagNumber(1)
  set order($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sky => $_getSZ(1);
  @$pb.TagNumber(2)
  set sky($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSky() => $_has(1);
  @$pb.TagNumber(2)
  void clearSky() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ground => $_getSZ(2);
  @$pb.TagNumber(3)
  set ground($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGround() => $_has(2);
  @$pb.TagNumber(3)
  void clearGround() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isFirstClass => $_getBF(3);
  @$pb.TagNumber(4)
  set isFirstClass($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsFirstClass() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsFirstClass() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get guiRen => $_getSZ(4);
  @$pb.TagNumber(5)
  set guiRen($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGuiRen() => $_has(4);
  @$pb.TagNumber(5)
  void clearGuiRen() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sheHaiTimes => $_getIZ(5);
  @$pb.TagNumber(6)
  set sheHaiTimes($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSheHaiTimes() => $_has(5);
  @$pb.TagNumber(6)
  void clearSheHaiTimes() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.int> get otherSameSkyGroundIndexList => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get zeiKeType => $_getSZ(7);
  @$pb.TagNumber(8)
  set zeiKeType($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasZeiKeType() => $_has(7);
  @$pb.TagNumber(8)
  void clearZeiKeType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isSkyKeDayGan => $_getBF(8);
  @$pb.TagNumber(9)
  set isSkyKeDayGan($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsSkyKeDayGan() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsSkyKeDayGan() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isSkySameYinYangWithDayGan => $_getBF(9);
  @$pb.TagNumber(10)
  set isSkySameYinYangWithDayGan($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsSkySameYinYangWithDayGan() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsSkySameYinYangWithDayGan() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get tianGan => $_getSZ(10);
  @$pb.TagNumber(11)
  set tianGan($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTianGan() => $_has(10);
  @$pb.TagNumber(11)
  void clearTianGan() => $_clearField(11);
}

/// 三传结构
class ThreeChuan extends $pb.GeneratedMessage {
  factory ThreeChuan({
    $core.String? nineZongMen,
    ChuanInfo? first,
    ChuanInfo? second,
    ChuanInfo? third,
    $core.String? type,
    $core.String? zeiKeType,
  }) {
    final $result = create();
    if (nineZongMen != null) {
      $result.nineZongMen = nineZongMen;
    }
    if (first != null) {
      $result.first = first;
    }
    if (second != null) {
      $result.second = second;
    }
    if (third != null) {
      $result.third = third;
    }
    if (type != null) {
      $result.type = type;
    }
    if (zeiKeType != null) {
      $result.zeiKeType = zeiKeType;
    }
    return $result;
  }
  ThreeChuan._() : super();
  factory ThreeChuan.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ThreeChuan.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ThreeChuan', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nineZongMen')
    ..aOM<ChuanInfo>(2, _omitFieldNames ? '' : 'first', subBuilder: ChuanInfo.create)
    ..aOM<ChuanInfo>(3, _omitFieldNames ? '' : 'second', subBuilder: ChuanInfo.create)
    ..aOM<ChuanInfo>(4, _omitFieldNames ? '' : 'third', subBuilder: ChuanInfo.create)
    ..aOS(5, _omitFieldNames ? '' : 'type')
    ..aOS(6, _omitFieldNames ? '' : 'zeiKeType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ThreeChuan clone() => ThreeChuan()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ThreeChuan copyWith(void Function(ThreeChuan) updates) => super.copyWith((message) => updates(message as ThreeChuan)) as ThreeChuan;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThreeChuan create() => ThreeChuan._();
  ThreeChuan createEmptyInstance() => create();
  static $pb.PbList<ThreeChuan> createRepeated() => $pb.PbList<ThreeChuan>();
  @$core.pragma('dart2js:noInline')
  static ThreeChuan getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ThreeChuan>(create);
  static ThreeChuan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nineZongMen => $_getSZ(0);
  @$pb.TagNumber(1)
  set nineZongMen($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNineZongMen() => $_has(0);
  @$pb.TagNumber(1)
  void clearNineZongMen() => $_clearField(1);

  @$pb.TagNumber(2)
  ChuanInfo get first => $_getN(1);
  @$pb.TagNumber(2)
  set first(ChuanInfo v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasFirst() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirst() => $_clearField(2);
  @$pb.TagNumber(2)
  ChuanInfo ensureFirst() => $_ensure(1);

  @$pb.TagNumber(3)
  ChuanInfo get second => $_getN(2);
  @$pb.TagNumber(3)
  set second(ChuanInfo v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSecond() => $_has(2);
  @$pb.TagNumber(3)
  void clearSecond() => $_clearField(3);
  @$pb.TagNumber(3)
  ChuanInfo ensureSecond() => $_ensure(2);

  @$pb.TagNumber(4)
  ChuanInfo get third => $_getN(3);
  @$pb.TagNumber(4)
  set third(ChuanInfo v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasThird() => $_has(3);
  @$pb.TagNumber(4)
  void clearThird() => $_clearField(4);
  @$pb.TagNumber(4)
  ChuanInfo ensureThird() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get type => $_getSZ(4);
  @$pb.TagNumber(5)
  set type($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get zeiKeType => $_getSZ(5);
  @$pb.TagNumber(6)
  set zeiKeType($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasZeiKeType() => $_has(5);
  @$pb.TagNumber(6)
  void clearZeiKeType() => $_clearField(6);
}

/// 传信息
class ChuanInfo extends $pb.GeneratedMessage {
  factory ChuanInfo({
    $core.int? order,
    $core.String? diZhi,
    $core.String? tianGan,
    $core.String? guiRen,
    $core.String? liuQin,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    if (diZhi != null) {
      $result.diZhi = diZhi;
    }
    if (tianGan != null) {
      $result.tianGan = tianGan;
    }
    if (guiRen != null) {
      $result.guiRen = guiRen;
    }
    if (liuQin != null) {
      $result.liuQin = liuQin;
    }
    return $result;
  }
  ChuanInfo._() : super();
  factory ChuanInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChuanInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChuanInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'order', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'diZhi')
    ..aOS(3, _omitFieldNames ? '' : 'tianGan')
    ..aOS(4, _omitFieldNames ? '' : 'guiRen')
    ..aOS(5, _omitFieldNames ? '' : 'liuQin')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChuanInfo clone() => ChuanInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChuanInfo copyWith(void Function(ChuanInfo) updates) => super.copyWith((message) => updates(message as ChuanInfo)) as ChuanInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChuanInfo create() => ChuanInfo._();
  ChuanInfo createEmptyInstance() => create();
  static $pb.PbList<ChuanInfo> createRepeated() => $pb.PbList<ChuanInfo>();
  @$core.pragma('dart2js:noInline')
  static ChuanInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChuanInfo>(create);
  static ChuanInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get order => $_getIZ(0);
  @$pb.TagNumber(1)
  set order($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get diZhi => $_getSZ(1);
  @$pb.TagNumber(2)
  set diZhi($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDiZhi() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiZhi() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tianGan => $_getSZ(2);
  @$pb.TagNumber(3)
  set tianGan($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTianGan() => $_has(2);
  @$pb.TagNumber(3)
  void clearTianGan() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get guiRen => $_getSZ(3);
  @$pb.TagNumber(4)
  set guiRen($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGuiRen() => $_has(3);
  @$pb.TagNumber(4)
  void clearGuiRen() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get liuQin => $_getSZ(4);
  @$pb.TagNumber(5)
  set liuQin($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLiuQin() => $_has(4);
  @$pb.TagNumber(5)
  void clearLiuQin() => $_clearField(5);
}

/// 宫位信息
class GongInfo extends $pb.GeneratedMessage {
  factory GongInfo({
    $core.String? groundPanDiZhi,
    $core.String? guiRen,
    $core.String? skyPanDiZhi,
    $core.String? tianGan,
    $core.String? jiaZi,
  }) {
    final $result = create();
    if (groundPanDiZhi != null) {
      $result.groundPanDiZhi = groundPanDiZhi;
    }
    if (guiRen != null) {
      $result.guiRen = guiRen;
    }
    if (skyPanDiZhi != null) {
      $result.skyPanDiZhi = skyPanDiZhi;
    }
    if (tianGan != null) {
      $result.tianGan = tianGan;
    }
    if (jiaZi != null) {
      $result.jiaZi = jiaZi;
    }
    return $result;
  }
  GongInfo._() : super();
  factory GongInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GongInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GongInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groundPanDiZhi')
    ..aOS(2, _omitFieldNames ? '' : 'guiRen')
    ..aOS(3, _omitFieldNames ? '' : 'skyPanDiZhi')
    ..aOS(4, _omitFieldNames ? '' : 'tianGan')
    ..aOS(5, _omitFieldNames ? '' : 'jiaZi')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GongInfo clone() => GongInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GongInfo copyWith(void Function(GongInfo) updates) => super.copyWith((message) => updates(message as GongInfo)) as GongInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GongInfo create() => GongInfo._();
  GongInfo createEmptyInstance() => create();
  static $pb.PbList<GongInfo> createRepeated() => $pb.PbList<GongInfo>();
  @$core.pragma('dart2js:noInline')
  static GongInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GongInfo>(create);
  static GongInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groundPanDiZhi => $_getSZ(0);
  @$pb.TagNumber(1)
  set groundPanDiZhi($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroundPanDiZhi() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroundPanDiZhi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get guiRen => $_getSZ(1);
  @$pb.TagNumber(2)
  set guiRen($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGuiRen() => $_has(1);
  @$pb.TagNumber(2)
  void clearGuiRen() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get skyPanDiZhi => $_getSZ(2);
  @$pb.TagNumber(3)
  set skyPanDiZhi($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSkyPanDiZhi() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkyPanDiZhi() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get tianGan => $_getSZ(3);
  @$pb.TagNumber(4)
  set tianGan($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTianGan() => $_has(3);
  @$pb.TagNumber(4)
  void clearTianGan() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get jiaZi => $_getSZ(4);
  @$pb.TagNumber(5)
  set jiaZi($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasJiaZi() => $_has(4);
  @$pb.TagNumber(5)
  void clearJiaZi() => $_clearField(5);
}

/// 玄大六壬数据列表
class XuanDaLiuRenDataList extends $pb.GeneratedMessage {
  factory XuanDaLiuRenDataList({
    $core.bool? isYinYang,
    $core.Iterable<XuanDaLiuRenData>? dataList,
  }) {
    final $result = create();
    if (isYinYang != null) {
      $result.isYinYang = isYinYang;
    }
    if (dataList != null) {
      $result.dataList.addAll(dataList);
    }
    return $result;
  }
  XuanDaLiuRenDataList._() : super();
  factory XuanDaLiuRenDataList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory XuanDaLiuRenDataList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'XuanDaLiuRenDataList', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isYinYang', protoName: 'isYinYang')
    ..pc<XuanDaLiuRenData>(2, _omitFieldNames ? '' : 'dataList', $pb.PbFieldType.PM, subBuilder: XuanDaLiuRenData.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenDataList clone() => XuanDaLiuRenDataList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenDataList copyWith(void Function(XuanDaLiuRenDataList) updates) => super.copyWith((message) => updates(message as XuanDaLiuRenDataList)) as XuanDaLiuRenDataList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenDataList create() => XuanDaLiuRenDataList._();
  XuanDaLiuRenDataList createEmptyInstance() => create();
  static $pb.PbList<XuanDaLiuRenDataList> createRepeated() => $pb.PbList<XuanDaLiuRenDataList>();
  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenDataList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<XuanDaLiuRenDataList>(create);
  static XuanDaLiuRenDataList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isYinYang => $_getBF(0);
  @$pb.TagNumber(1)
  set isYinYang($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsYinYang() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsYinYang() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<XuanDaLiuRenData> get dataList => $_getList(1);
}

class XuanDaLiuRenDataListBundle extends $pb.GeneratedMessage {
  factory XuanDaLiuRenDataListBundle({
    XuanDaLiuRenDataList? yangList,
    XuanDaLiuRenDataList? yinList,
  }) {
    final $result = create();
    if (yangList != null) {
      $result.yangList = yangList;
    }
    if (yinList != null) {
      $result.yinList = yinList;
    }
    return $result;
  }
  XuanDaLiuRenDataListBundle._() : super();
  factory XuanDaLiuRenDataListBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory XuanDaLiuRenDataListBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'XuanDaLiuRenDataListBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'xuan_daliuren'), createEmptyInstance: create)
    ..aOM<XuanDaLiuRenDataList>(1, _omitFieldNames ? '' : 'yangList', protoName: 'yangList', subBuilder: XuanDaLiuRenDataList.create)
    ..aOM<XuanDaLiuRenDataList>(2, _omitFieldNames ? '' : 'yinList', protoName: 'yinList', subBuilder: XuanDaLiuRenDataList.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenDataListBundle clone() => XuanDaLiuRenDataListBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  XuanDaLiuRenDataListBundle copyWith(void Function(XuanDaLiuRenDataListBundle) updates) => super.copyWith((message) => updates(message as XuanDaLiuRenDataListBundle)) as XuanDaLiuRenDataListBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenDataListBundle create() => XuanDaLiuRenDataListBundle._();
  XuanDaLiuRenDataListBundle createEmptyInstance() => create();
  static $pb.PbList<XuanDaLiuRenDataListBundle> createRepeated() => $pb.PbList<XuanDaLiuRenDataListBundle>();
  @$core.pragma('dart2js:noInline')
  static XuanDaLiuRenDataListBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<XuanDaLiuRenDataListBundle>(create);
  static XuanDaLiuRenDataListBundle? _defaultInstance;

  @$pb.TagNumber(1)
  XuanDaLiuRenDataList get yangList => $_getN(0);
  @$pb.TagNumber(1)
  set yangList(XuanDaLiuRenDataList v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasYangList() => $_has(0);
  @$pb.TagNumber(1)
  void clearYangList() => $_clearField(1);
  @$pb.TagNumber(1)
  XuanDaLiuRenDataList ensureYangList() => $_ensure(0);

  @$pb.TagNumber(2)
  XuanDaLiuRenDataList get yinList => $_getN(1);
  @$pb.TagNumber(2)
  set yinList(XuanDaLiuRenDataList v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasYinList() => $_has(1);
  @$pb.TagNumber(2)
  void clearYinList() => $_clearField(2);
  @$pb.TagNumber(2)
  XuanDaLiuRenDataList ensureYinList() => $_ensure(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
