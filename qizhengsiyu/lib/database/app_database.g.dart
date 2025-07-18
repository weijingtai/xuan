// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StarPositionStatusTableTable extends StarPositionStatusTable
    with
        TableInfo<$StarPositionStatusTableTable,
            StarPositionStatusDatasetModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StarPositionStatusTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<EnumStars, String> star =
      GeneratedColumn<String>('star', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EnumStars>(
              $StarPositionStatusTableTable.$converterstar);
  @override
  late final GeneratedColumnWithTypeConverter<EnumStarGongPositionStatusType,
      String> starPositionStatusType = GeneratedColumn<String>(
          'star_position_status_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<EnumStarGongPositionStatusType>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType);
  @override
  late final GeneratedColumnWithTypeConverter<List<Enum>, String> positionList =
      GeneratedColumn<String>('position_list', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Enum>>(
              $StarPositionStatusTableTable.$converterpositionList);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      descriptionList = GeneratedColumn<String>(
              'description_list', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $StarPositionStatusTableTable.$converterdescriptionListn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> geJuList =
      GeneratedColumn<String>('ge_ju_list', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $StarPositionStatusTableTable.$convertergeJuListn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        className,
        star,
        starPositionStatusType,
        positionList,
        descriptionList,
        geJuList
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'star_position_status_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<StarPositionStatusDatasetModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StarPositionStatusDatasetModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StarPositionStatusDatasetModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name'])!,
      star: $StarPositionStatusTableTable.$converterstar.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}star'])!),
      starPositionStatusType: $StarPositionStatusTableTable
          .$converterstarPositionStatusType
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}star_position_status_type'])!),
      positionList: $StarPositionStatusTableTable.$converterpositionList
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}position_list'])!),
      descriptionList: $StarPositionStatusTableTable.$converterdescriptionListn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}description_list'])),
      geJuList: $StarPositionStatusTableTable.$convertergeJuListn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}ge_ju_list'])),
    );
  }

  @override
  $StarPositionStatusTableTable createAlias(String alias) {
    return $StarPositionStatusTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnumStars, String, String> $converterstar =
      const EnumNameConverter<EnumStars>(EnumStars.values);
  static JsonTypeConverter2<EnumStarGongPositionStatusType, String, String>
      $converterstarPositionStatusType =
      const EnumNameConverter<EnumStarGongPositionStatusType>(
          EnumStarGongPositionStatusType.values);
  static TypeConverter<List<Enum>, String> $converterpositionList =
      const PositionListConverter();
  static TypeConverter<List<String>, String> $converterdescriptionList =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterdescriptionListn =
      NullAwareTypeConverter.wrap($converterdescriptionList);
  static TypeConverter<List<String>, String> $convertergeJuList =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertergeJuListn =
      NullAwareTypeConverter.wrap($convertergeJuList);
}

class StarPositionStatusDatasetModel extends DataClass
    implements Insertable<StarPositionStatusDatasetModel> {
  final int id;
  final String className;
  final EnumStars star;
  final EnumStarGongPositionStatusType starPositionStatusType;
  final List<Enum> positionList;
  final List<String>? descriptionList;
  final List<String>? geJuList;
  const StarPositionStatusDatasetModel(
      {required this.id,
      required this.className,
      required this.star,
      required this.starPositionStatusType,
      required this.positionList,
      this.descriptionList,
      this.geJuList});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_name'] = Variable<String>(className);
    {
      map['star'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstar.toSql(star));
    }
    {
      map['star_position_status_type'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toSql(starPositionStatusType));
    }
    {
      map['position_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterpositionList
          .toSql(positionList));
    }
    if (!nullToAbsent || descriptionList != null) {
      map['description_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterdescriptionListn
          .toSql(descriptionList));
    }
    if (!nullToAbsent || geJuList != null) {
      map['ge_ju_list'] = Variable<String>(
          $StarPositionStatusTableTable.$convertergeJuListn.toSql(geJuList));
    }
    return map;
  }

  StarPositionStatusTableCompanion toCompanion(bool nullToAbsent) {
    return StarPositionStatusTableCompanion(
      id: Value(id),
      className: Value(className),
      star: Value(star),
      starPositionStatusType: Value(starPositionStatusType),
      positionList: Value(positionList),
      descriptionList: descriptionList == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionList),
      geJuList: geJuList == null && nullToAbsent
          ? const Value.absent()
          : Value(geJuList),
    );
  }

  factory StarPositionStatusDatasetModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StarPositionStatusDatasetModel(
      id: serializer.fromJson<int>(json['id']),
      className: serializer.fromJson<String>(json['className']),
      star: $StarPositionStatusTableTable.$converterstar
          .fromJson(serializer.fromJson<String>(json['star'])),
      starPositionStatusType: $StarPositionStatusTableTable
          .$converterstarPositionStatusType
          .fromJson(
              serializer.fromJson<String>(json['starPositionStatusType'])),
      positionList: serializer.fromJson<List<Enum>>(json['positionList']),
      descriptionList:
          serializer.fromJson<List<String>?>(json['descriptionList']),
      geJuList: serializer.fromJson<List<String>?>(json['geJuList']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'className': serializer.toJson<String>(className),
      'star': serializer.toJson<String>(
          $StarPositionStatusTableTable.$converterstar.toJson(star)),
      'starPositionStatusType': serializer.toJson<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toJson(starPositionStatusType)),
      'positionList': serializer.toJson<List<Enum>>(positionList),
      'descriptionList': serializer.toJson<List<String>?>(descriptionList),
      'geJuList': serializer.toJson<List<String>?>(geJuList),
    };
  }

  StarPositionStatusDatasetModel copyWith(
          {int? id,
          String? className,
          EnumStars? star,
          EnumStarGongPositionStatusType? starPositionStatusType,
          List<Enum>? positionList,
          Value<List<String>?> descriptionList = const Value.absent(),
          Value<List<String>?> geJuList = const Value.absent()}) =>
      StarPositionStatusDatasetModel(
        id: id ?? this.id,
        className: className ?? this.className,
        star: star ?? this.star,
        starPositionStatusType:
            starPositionStatusType ?? this.starPositionStatusType,
        positionList: positionList ?? this.positionList,
        descriptionList: descriptionList.present
            ? descriptionList.value
            : this.descriptionList,
        geJuList: geJuList.present ? geJuList.value : this.geJuList,
      );
  StarPositionStatusDatasetModel copyWithCompanion(
      StarPositionStatusTableCompanion data) {
    return StarPositionStatusDatasetModel(
      id: data.id.present ? data.id.value : this.id,
      className: data.className.present ? data.className.value : this.className,
      star: data.star.present ? data.star.value : this.star,
      starPositionStatusType: data.starPositionStatusType.present
          ? data.starPositionStatusType.value
          : this.starPositionStatusType,
      positionList: data.positionList.present
          ? data.positionList.value
          : this.positionList,
      descriptionList: data.descriptionList.present
          ? data.descriptionList.value
          : this.descriptionList,
      geJuList: data.geJuList.present ? data.geJuList.value : this.geJuList,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusDatasetModel(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('starPositionStatusType: $starPositionStatusType, ')
          ..write('positionList: $positionList, ')
          ..write('descriptionList: $descriptionList, ')
          ..write('geJuList: $geJuList')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, className, star, starPositionStatusType,
      positionList, descriptionList, geJuList);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StarPositionStatusDatasetModel &&
          other.id == this.id &&
          other.className == this.className &&
          other.star == this.star &&
          other.starPositionStatusType == this.starPositionStatusType &&
          other.positionList == this.positionList &&
          other.descriptionList == this.descriptionList &&
          other.geJuList == this.geJuList);
}

class StarPositionStatusTableCompanion
    extends UpdateCompanion<StarPositionStatusDatasetModel> {
  final Value<int> id;
  final Value<String> className;
  final Value<EnumStars> star;
  final Value<EnumStarGongPositionStatusType> starPositionStatusType;
  final Value<List<Enum>> positionList;
  final Value<List<String>?> descriptionList;
  final Value<List<String>?> geJuList;
  const StarPositionStatusTableCompanion({
    this.id = const Value.absent(),
    this.className = const Value.absent(),
    this.star = const Value.absent(),
    this.starPositionStatusType = const Value.absent(),
    this.positionList = const Value.absent(),
    this.descriptionList = const Value.absent(),
    this.geJuList = const Value.absent(),
  });
  StarPositionStatusTableCompanion.insert({
    this.id = const Value.absent(),
    required String className,
    required EnumStars star,
    required EnumStarGongPositionStatusType starPositionStatusType,
    required List<Enum> positionList,
    this.descriptionList = const Value.absent(),
    this.geJuList = const Value.absent(),
  })  : className = Value(className),
        star = Value(star),
        starPositionStatusType = Value(starPositionStatusType),
        positionList = Value(positionList);
  static Insertable<StarPositionStatusDatasetModel> custom({
    Expression<int>? id,
    Expression<String>? className,
    Expression<String>? star,
    Expression<String>? starPositionStatusType,
    Expression<String>? positionList,
    Expression<String>? descriptionList,
    Expression<String>? geJuList,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (className != null) 'class_name': className,
      if (star != null) 'star': star,
      if (starPositionStatusType != null)
        'star_position_status_type': starPositionStatusType,
      if (positionList != null) 'position_list': positionList,
      if (descriptionList != null) 'description_list': descriptionList,
      if (geJuList != null) 'ge_ju_list': geJuList,
    });
  }

  StarPositionStatusTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? className,
      Value<EnumStars>? star,
      Value<EnumStarGongPositionStatusType>? starPositionStatusType,
      Value<List<Enum>>? positionList,
      Value<List<String>?>? descriptionList,
      Value<List<String>?>? geJuList}) {
    return StarPositionStatusTableCompanion(
      id: id ?? this.id,
      className: className ?? this.className,
      star: star ?? this.star,
      starPositionStatusType:
          starPositionStatusType ?? this.starPositionStatusType,
      positionList: positionList ?? this.positionList,
      descriptionList: descriptionList ?? this.descriptionList,
      geJuList: geJuList ?? this.geJuList,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (star.present) {
      map['star'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstar.toSql(star.value));
    }
    if (starPositionStatusType.present) {
      map['star_position_status_type'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toSql(starPositionStatusType.value));
    }
    if (positionList.present) {
      map['position_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterpositionList
          .toSql(positionList.value));
    }
    if (descriptionList.present) {
      map['description_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterdescriptionListn
          .toSql(descriptionList.value));
    }
    if (geJuList.present) {
      map['ge_ju_list'] = Variable<String>($StarPositionStatusTableTable
          .$convertergeJuListn
          .toSql(geJuList.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusTableCompanion(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('starPositionStatusType: $starPositionStatusType, ')
          ..write('positionList: $positionList, ')
          ..write('descriptionList: $descriptionList, ')
          ..write('geJuList: $geJuList')
          ..write(')'))
        .toString();
  }
}

class $BasePanelTableTable extends BasePanelTable
    with TableInfo<$BasePanelTableTable, BasePanelModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BasePanelTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _panelDataMeta =
      const VerificationMeta('panelData');
  @override
  late final GeneratedColumn<String> panelData = GeneratedColumn<String>(
      'panel_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seekerUuidMeta =
      const VerificationMeta('seekerUuid');
  @override
  late final GeneratedColumn<String> seekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _panelConfigJsonMeta =
      const VerificationMeta('panelConfigJson');
  @override
  late final GeneratedColumn<String> panelConfigJson = GeneratedColumn<String>(
      'panel_config_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observerPositionJsonMeta =
      const VerificationMeta('observerPositionJson');
  @override
  late final GeneratedColumn<String> observerPositionJson =
      GeneratedColumn<String>('observer_position_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        panelData,
        divinationUuid,
        seekerUuid,
        panelConfigJson,
        observerPositionJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_base_panels';
  @override
  VerificationContext validateIntegrity(Insertable<BasePanelModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('panel_data')) {
      context.handle(_panelDataMeta,
          panelData.isAcceptableOrUnknown(data['panel_data']!, _panelDataMeta));
    } else if (isInserting) {
      context.missing(_panelDataMeta);
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _seekerUuidMeta,
          seekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _seekerUuidMeta));
    }
    if (data.containsKey('panel_config_json')) {
      context.handle(
          _panelConfigJsonMeta,
          panelConfigJson.isAcceptableOrUnknown(
              data['panel_config_json']!, _panelConfigJsonMeta));
    } else if (isInserting) {
      context.missing(_panelConfigJsonMeta);
    }
    if (data.containsKey('observer_position_json')) {
      context.handle(
          _observerPositionJsonMeta,
          observerPositionJson.isAcceptableOrUnknown(
              data['observer_position_json']!, _observerPositionJsonMeta));
    } else if (isInserting) {
      context.missing(_observerPositionJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  BasePanelModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BasePanelModel();
  }

  @override
  $BasePanelTableTable createAlias(String alias) {
    return $BasePanelTableTable(attachedDatabase, alias);
  }
}

class BasePanelTableCompanion extends UpdateCompanion<BasePanelModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> panelData;
  final Value<String?> divinationUuid;
  final Value<String?> seekerUuid;
  final Value<String> panelConfigJson;
  final Value<String> observerPositionJson;
  final Value<int> rowid;
  const BasePanelTableCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.panelData = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.seekerUuid = const Value.absent(),
    this.panelConfigJson = const Value.absent(),
    this.observerPositionJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BasePanelTableCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String panelData,
    this.divinationUuid = const Value.absent(),
    this.seekerUuid = const Value.absent(),
    required String panelConfigJson,
    required String observerPositionJson,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        panelData = Value(panelData),
        panelConfigJson = Value(panelConfigJson),
        observerPositionJson = Value(observerPositionJson);
  static Insertable<BasePanelModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? panelData,
    Expression<String>? divinationUuid,
    Expression<String>? seekerUuid,
    Expression<String>? panelConfigJson,
    Expression<String>? observerPositionJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (panelData != null) 'panel_data': panelData,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (seekerUuid != null) 'seeker_uuid': seekerUuid,
      if (panelConfigJson != null) 'panel_config_json': panelConfigJson,
      if (observerPositionJson != null)
        'observer_position_json': observerPositionJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BasePanelTableCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? panelData,
      Value<String?>? divinationUuid,
      Value<String?>? seekerUuid,
      Value<String>? panelConfigJson,
      Value<String>? observerPositionJson,
      Value<int>? rowid}) {
    return BasePanelTableCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      panelData: panelData ?? this.panelData,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      seekerUuid: seekerUuid ?? this.seekerUuid,
      panelConfigJson: panelConfigJson ?? this.panelConfigJson,
      observerPositionJson: observerPositionJson ?? this.observerPositionJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (panelData.present) {
      map['panel_data'] = Variable<String>(panelData.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (seekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(seekerUuid.value);
    }
    if (panelConfigJson.present) {
      map['panel_config_json'] = Variable<String>(panelConfigJson.value);
    }
    if (observerPositionJson.present) {
      map['observer_position_json'] =
          Variable<String>(observerPositionJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BasePanelTableCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('panelData: $panelData, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('seekerUuid: $seekerUuid, ')
          ..write('panelConfigJson: $panelConfigJson, ')
          ..write('observerPositionJson: $observerPositionJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$App74Database extends GeneratedDatabase {
  _$App74Database(QueryExecutor e) : super(e);
  $App74DatabaseManager get managers => $App74DatabaseManager(this);
  late final $StarPositionStatusTableTable starPositionStatusTable =
      $StarPositionStatusTableTable(this);
  late final $BasePanelTableTable basePanelTable = $BasePanelTableTable(this);
  late final BasePanelDao basePanelDao = BasePanelDao(this as App74Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [starPositionStatusTable, basePanelTable];
}

typedef $$StarPositionStatusTableTableCreateCompanionBuilder
    = StarPositionStatusTableCompanion Function({
  Value<int> id,
  required String className,
  required EnumStars star,
  required EnumStarGongPositionStatusType starPositionStatusType,
  required List<Enum> positionList,
  Value<List<String>?> descriptionList,
  Value<List<String>?> geJuList,
});
typedef $$StarPositionStatusTableTableUpdateCompanionBuilder
    = StarPositionStatusTableCompanion Function({
  Value<int> id,
  Value<String> className,
  Value<EnumStars> star,
  Value<EnumStarGongPositionStatusType> starPositionStatusType,
  Value<List<Enum>> positionList,
  Value<List<String>?> descriptionList,
  Value<List<String>?> geJuList,
});

class $$StarPositionStatusTableTableFilterComposer
    extends Composer<_$App74Database, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EnumStars, EnumStars, String> get star =>
      $composableBuilder(
          column: $table.star,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<EnumStarGongPositionStatusType,
          EnumStarGongPositionStatusType, String>
      get starPositionStatusType => $composableBuilder(
          column: $table.starPositionStatusType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<Enum>, List<Enum>, String>
      get positionList => $composableBuilder(
          column: $table.positionList,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get descriptionList => $composableBuilder(
          column: $table.descriptionList,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get geJuList => $composableBuilder(
          column: $table.geJuList,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$StarPositionStatusTableTableOrderingComposer
    extends Composer<_$App74Database, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get star => $composableBuilder(
      column: $table.star, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get starPositionStatusType => $composableBuilder(
      column: $table.starPositionStatusType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positionList => $composableBuilder(
      column: $table.positionList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionList => $composableBuilder(
      column: $table.descriptionList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geJuList => $composableBuilder(
      column: $table.geJuList, builder: (column) => ColumnOrderings(column));
}

class $$StarPositionStatusTableTableAnnotationComposer
    extends Composer<_$App74Database, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumStars, String> get star =>
      $composableBuilder(column: $table.star, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumStarGongPositionStatusType, String>
      get starPositionStatusType => $composableBuilder(
          column: $table.starPositionStatusType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Enum>, String> get positionList =>
      $composableBuilder(
          column: $table.positionList, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get descriptionList =>
      $composableBuilder(
          column: $table.descriptionList, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get geJuList =>
      $composableBuilder(column: $table.geJuList, builder: (column) => column);
}

class $$StarPositionStatusTableTableTableManager extends RootTableManager<
    _$App74Database,
    $StarPositionStatusTableTable,
    StarPositionStatusDatasetModel,
    $$StarPositionStatusTableTableFilterComposer,
    $$StarPositionStatusTableTableOrderingComposer,
    $$StarPositionStatusTableTableAnnotationComposer,
    $$StarPositionStatusTableTableCreateCompanionBuilder,
    $$StarPositionStatusTableTableUpdateCompanionBuilder,
    (
      StarPositionStatusDatasetModel,
      BaseReferences<_$App74Database, $StarPositionStatusTableTable,
          StarPositionStatusDatasetModel>
    ),
    StarPositionStatusDatasetModel,
    PrefetchHooks Function()> {
  $$StarPositionStatusTableTableTableManager(
      _$App74Database db, $StarPositionStatusTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StarPositionStatusTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$StarPositionStatusTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StarPositionStatusTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<EnumStars> star = const Value.absent(),
            Value<EnumStarGongPositionStatusType> starPositionStatusType =
                const Value.absent(),
            Value<List<Enum>> positionList = const Value.absent(),
            Value<List<String>?> descriptionList = const Value.absent(),
            Value<List<String>?> geJuList = const Value.absent(),
          }) =>
              StarPositionStatusTableCompanion(
            id: id,
            className: className,
            star: star,
            starPositionStatusType: starPositionStatusType,
            positionList: positionList,
            descriptionList: descriptionList,
            geJuList: geJuList,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String className,
            required EnumStars star,
            required EnumStarGongPositionStatusType starPositionStatusType,
            required List<Enum> positionList,
            Value<List<String>?> descriptionList = const Value.absent(),
            Value<List<String>?> geJuList = const Value.absent(),
          }) =>
              StarPositionStatusTableCompanion.insert(
            id: id,
            className: className,
            star: star,
            starPositionStatusType: starPositionStatusType,
            positionList: positionList,
            descriptionList: descriptionList,
            geJuList: geJuList,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StarPositionStatusTableTableProcessedTableManager
    = ProcessedTableManager<
        _$App74Database,
        $StarPositionStatusTableTable,
        StarPositionStatusDatasetModel,
        $$StarPositionStatusTableTableFilterComposer,
        $$StarPositionStatusTableTableOrderingComposer,
        $$StarPositionStatusTableTableAnnotationComposer,
        $$StarPositionStatusTableTableCreateCompanionBuilder,
        $$StarPositionStatusTableTableUpdateCompanionBuilder,
        (
          StarPositionStatusDatasetModel,
          BaseReferences<_$App74Database, $StarPositionStatusTableTable,
              StarPositionStatusDatasetModel>
        ),
        StarPositionStatusDatasetModel,
        PrefetchHooks Function()>;
typedef $$BasePanelTableTableCreateCompanionBuilder = BasePanelTableCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String panelData,
  Value<String?> divinationUuid,
  Value<String?> seekerUuid,
  required String panelConfigJson,
  required String observerPositionJson,
  Value<int> rowid,
});
typedef $$BasePanelTableTableUpdateCompanionBuilder = BasePanelTableCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> panelData,
  Value<String?> divinationUuid,
  Value<String?> seekerUuid,
  Value<String> panelConfigJson,
  Value<String> observerPositionJson,
  Value<int> rowid,
});

class $$BasePanelTableTableFilterComposer
    extends Composer<_$App74Database, $BasePanelTableTable> {
  $$BasePanelTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelData => $composableBuilder(
      column: $table.panelData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelConfigJson => $composableBuilder(
      column: $table.panelConfigJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observerPositionJson => $composableBuilder(
      column: $table.observerPositionJson,
      builder: (column) => ColumnFilters(column));
}

class $$BasePanelTableTableOrderingComposer
    extends Composer<_$App74Database, $BasePanelTableTable> {
  $$BasePanelTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelData => $composableBuilder(
      column: $table.panelData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelConfigJson => $composableBuilder(
      column: $table.panelConfigJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observerPositionJson => $composableBuilder(
      column: $table.observerPositionJson,
      builder: (column) => ColumnOrderings(column));
}

class $$BasePanelTableTableAnnotationComposer
    extends Composer<_$App74Database, $BasePanelTableTable> {
  $$BasePanelTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get panelData =>
      $composableBuilder(column: $table.panelData, builder: (column) => column);

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumn<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => column);

  GeneratedColumn<String> get panelConfigJson => $composableBuilder(
      column: $table.panelConfigJson, builder: (column) => column);

  GeneratedColumn<String> get observerPositionJson => $composableBuilder(
      column: $table.observerPositionJson, builder: (column) => column);
}

class $$BasePanelTableTableTableManager extends RootTableManager<
    _$App74Database,
    $BasePanelTableTable,
    BasePanelModel,
    $$BasePanelTableTableFilterComposer,
    $$BasePanelTableTableOrderingComposer,
    $$BasePanelTableTableAnnotationComposer,
    $$BasePanelTableTableCreateCompanionBuilder,
    $$BasePanelTableTableUpdateCompanionBuilder,
    (
      BasePanelModel,
      BaseReferences<_$App74Database, $BasePanelTableTable, BasePanelModel>
    ),
    BasePanelModel,
    PrefetchHooks Function()> {
  $$BasePanelTableTableTableManager(
      _$App74Database db, $BasePanelTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BasePanelTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BasePanelTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BasePanelTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> panelData = const Value.absent(),
            Value<String?> divinationUuid = const Value.absent(),
            Value<String?> seekerUuid = const Value.absent(),
            Value<String> panelConfigJson = const Value.absent(),
            Value<String> observerPositionJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BasePanelTableCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            panelData: panelData,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
            panelConfigJson: panelConfigJson,
            observerPositionJson: observerPositionJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String panelData,
            Value<String?> divinationUuid = const Value.absent(),
            Value<String?> seekerUuid = const Value.absent(),
            required String panelConfigJson,
            required String observerPositionJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              BasePanelTableCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            panelData: panelData,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
            panelConfigJson: panelConfigJson,
            observerPositionJson: observerPositionJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BasePanelTableTableProcessedTableManager = ProcessedTableManager<
    _$App74Database,
    $BasePanelTableTable,
    BasePanelModel,
    $$BasePanelTableTableFilterComposer,
    $$BasePanelTableTableOrderingComposer,
    $$BasePanelTableTableAnnotationComposer,
    $$BasePanelTableTableCreateCompanionBuilder,
    $$BasePanelTableTableUpdateCompanionBuilder,
    (
      BasePanelModel,
      BaseReferences<_$App74Database, $BasePanelTableTable, BasePanelModel>
    ),
    BasePanelModel,
    PrefetchHooks Function()>;

class $App74DatabaseManager {
  final _$App74Database _db;
  $App74DatabaseManager(this._db);
  $$StarPositionStatusTableTableTableManager get starPositionStatusTable =>
      $$StarPositionStatusTableTableTableManager(
          _db, _db.starPositionStatusTable);
  $$BasePanelTableTableTableManager get basePanelTable =>
      $$BasePanelTableTableTableManager(_db, _db.basePanelTable);
}
