// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QueriesTable extends Queries with TableInfo<$QueriesTable, Query> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryTypeUuidMeta =
      const VerificationMeta('queryTypeUuid');
  @override
  late final GeneratedColumn<String> queryTypeUuid = GeneratedColumn<String>(
      'query_type_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearGanZhiMeta =
      const VerificationMeta('yearGanZhi');
  @override
  late final GeneratedColumn<String> yearGanZhi = GeneratedColumn<String>(
      'year_gan_zhi', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSeersLocationMeta =
      const VerificationMeta('isSeersLocation');
  @override
  late final GeneratedColumn<bool> isSeersLocation = GeneratedColumn<bool>(
      'is_seers_location', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_seers_location" IN (0, 1))'));
  static const VerificationMeta _queryQuestionMeta =
      const VerificationMeta('queryQuestion');
  @override
  late final GeneratedColumn<String> queryQuestion = GeneratedColumn<String>(
      'query_question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queryDescriptionMeta =
      const VerificationMeta('queryDescription');
  @override
  late final GeneratedColumn<String> queryDescription = GeneratedColumn<String>(
      'query_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seekerUuidMeta =
      const VerificationMeta('seekerUuid');
  @override
  late final GeneratedColumn<String> seekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tinySummaryMeta =
      const VerificationMeta('tinySummary');
  @override
  late final GeneratedColumn<String> tinySummary = GeneratedColumn<String>(
      'tiny_summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directlyPredictMeta =
      const VerificationMeta('directlyPredict');
  @override
  late final GeneratedColumn<String> directlyPredict = GeneratedColumn<String>(
      'directly_predict', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        queryTypeUuid,
        yearGanZhi,
        isSeersLocation,
        queryQuestion,
        queryDescription,
        seekerUuid,
        tinySummary,
        directlyPredict,
        panelUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queries';
  @override
  VerificationContext validateIntegrity(Insertable<Query> instance,
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
    if (data.containsKey('query_type_uuid')) {
      context.handle(
          _queryTypeUuidMeta,
          queryTypeUuid.isAcceptableOrUnknown(
              data['query_type_uuid']!, _queryTypeUuidMeta));
    } else if (isInserting) {
      context.missing(_queryTypeUuidMeta);
    }
    if (data.containsKey('year_gan_zhi')) {
      context.handle(
          _yearGanZhiMeta,
          yearGanZhi.isAcceptableOrUnknown(
              data['year_gan_zhi']!, _yearGanZhiMeta));
    }
    if (data.containsKey('is_seers_location')) {
      context.handle(
          _isSeersLocationMeta,
          isSeersLocation.isAcceptableOrUnknown(
              data['is_seers_location']!, _isSeersLocationMeta));
    } else if (isInserting) {
      context.missing(_isSeersLocationMeta);
    }
    if (data.containsKey('query_question')) {
      context.handle(
          _queryQuestionMeta,
          queryQuestion.isAcceptableOrUnknown(
              data['query_question']!, _queryQuestionMeta));
    } else if (isInserting) {
      context.missing(_queryQuestionMeta);
    }
    if (data.containsKey('query_description')) {
      context.handle(
          _queryDescriptionMeta,
          queryDescription.isAcceptableOrUnknown(
              data['query_description']!, _queryDescriptionMeta));
    } else if (isInserting) {
      context.missing(_queryDescriptionMeta);
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _seekerUuidMeta,
          seekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _seekerUuidMeta));
    }
    if (data.containsKey('tiny_summary')) {
      context.handle(
          _tinySummaryMeta,
          tinySummary.isAcceptableOrUnknown(
              data['tiny_summary']!, _tinySummaryMeta));
    } else if (isInserting) {
      context.missing(_tinySummaryMeta);
    }
    if (data.containsKey('directly_predict')) {
      context.handle(
          _directlyPredictMeta,
          directlyPredict.isAcceptableOrUnknown(
              data['directly_predict']!, _directlyPredictMeta));
    } else if (isInserting) {
      context.missing(_directlyPredictMeta);
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Query map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Query(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      queryTypeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}query_type_uuid'])!,
      yearGanZhi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}year_gan_zhi']),
      isSeersLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_seers_location'])!,
      queryQuestion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_question'])!,
      queryDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}query_description'])!,
      seekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid']),
      tinySummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tiny_summary'])!,
      directlyPredict: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}directly_predict'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid']),
    );
  }

  @override
  $QueriesTable createAlias(String alias) {
    return $QueriesTable(attachedDatabase, alias);
  }
}

class Query extends DataClass implements Insertable<Query> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String queryTypeUuid;
  final String? yearGanZhi;
  final bool isSeersLocation;
  final String queryQuestion;
  final String queryDescription;
  final String? seekerUuid;
  final String tinySummary;
  final String directlyPredict;
  final String? panelUuid;
  const Query(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.queryTypeUuid,
      this.yearGanZhi,
      required this.isSeersLocation,
      required this.queryQuestion,
      required this.queryDescription,
      this.seekerUuid,
      required this.tinySummary,
      required this.directlyPredict,
      this.panelUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['query_type_uuid'] = Variable<String>(queryTypeUuid);
    if (!nullToAbsent || yearGanZhi != null) {
      map['year_gan_zhi'] = Variable<String>(yearGanZhi);
    }
    map['is_seers_location'] = Variable<bool>(isSeersLocation);
    map['query_question'] = Variable<String>(queryQuestion);
    map['query_description'] = Variable<String>(queryDescription);
    if (!nullToAbsent || seekerUuid != null) {
      map['seeker_uuid'] = Variable<String>(seekerUuid);
    }
    map['tiny_summary'] = Variable<String>(tinySummary);
    map['directly_predict'] = Variable<String>(directlyPredict);
    if (!nullToAbsent || panelUuid != null) {
      map['panel_uuid'] = Variable<String>(panelUuid);
    }
    return map;
  }

  QueriesCompanion toCompanion(bool nullToAbsent) {
    return QueriesCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      queryTypeUuid: Value(queryTypeUuid),
      yearGanZhi: yearGanZhi == null && nullToAbsent
          ? const Value.absent()
          : Value(yearGanZhi),
      isSeersLocation: Value(isSeersLocation),
      queryQuestion: Value(queryQuestion),
      queryDescription: Value(queryDescription),
      seekerUuid: seekerUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(seekerUuid),
      tinySummary: Value(tinySummary),
      directlyPredict: Value(directlyPredict),
      panelUuid: panelUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(panelUuid),
    );
  }

  factory Query.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Query(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      queryTypeUuid: serializer.fromJson<String>(json['queryTypeUuid']),
      yearGanZhi: serializer.fromJson<String?>(json['yearGanZhi']),
      isSeersLocation: serializer.fromJson<bool>(json['isSeersLocation']),
      queryQuestion: serializer.fromJson<String>(json['queryQuestion']),
      queryDescription: serializer.fromJson<String>(json['queryDescription']),
      seekerUuid: serializer.fromJson<String?>(json['seekerUuid']),
      tinySummary: serializer.fromJson<String>(json['tinySummary']),
      directlyPredict: serializer.fromJson<String>(json['directlyPredict']),
      panelUuid: serializer.fromJson<String?>(json['panelUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'queryTypeUuid': serializer.toJson<String>(queryTypeUuid),
      'yearGanZhi': serializer.toJson<String?>(yearGanZhi),
      'isSeersLocation': serializer.toJson<bool>(isSeersLocation),
      'queryQuestion': serializer.toJson<String>(queryQuestion),
      'queryDescription': serializer.toJson<String>(queryDescription),
      'seekerUuid': serializer.toJson<String?>(seekerUuid),
      'tinySummary': serializer.toJson<String>(tinySummary),
      'directlyPredict': serializer.toJson<String>(directlyPredict),
      'panelUuid': serializer.toJson<String?>(panelUuid),
    };
  }

  Query copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? queryTypeUuid,
          Value<String?> yearGanZhi = const Value.absent(),
          bool? isSeersLocation,
          String? queryQuestion,
          String? queryDescription,
          Value<String?> seekerUuid = const Value.absent(),
          String? tinySummary,
          String? directlyPredict,
          Value<String?> panelUuid = const Value.absent()}) =>
      Query(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        queryTypeUuid: queryTypeUuid ?? this.queryTypeUuid,
        yearGanZhi: yearGanZhi.present ? yearGanZhi.value : this.yearGanZhi,
        isSeersLocation: isSeersLocation ?? this.isSeersLocation,
        queryQuestion: queryQuestion ?? this.queryQuestion,
        queryDescription: queryDescription ?? this.queryDescription,
        seekerUuid: seekerUuid.present ? seekerUuid.value : this.seekerUuid,
        tinySummary: tinySummary ?? this.tinySummary,
        directlyPredict: directlyPredict ?? this.directlyPredict,
        panelUuid: panelUuid.present ? panelUuid.value : this.panelUuid,
      );
  Query copyWithCompanion(QueriesCompanion data) {
    return Query(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      queryTypeUuid: data.queryTypeUuid.present
          ? data.queryTypeUuid.value
          : this.queryTypeUuid,
      yearGanZhi:
          data.yearGanZhi.present ? data.yearGanZhi.value : this.yearGanZhi,
      isSeersLocation: data.isSeersLocation.present
          ? data.isSeersLocation.value
          : this.isSeersLocation,
      queryQuestion: data.queryQuestion.present
          ? data.queryQuestion.value
          : this.queryQuestion,
      queryDescription: data.queryDescription.present
          ? data.queryDescription.value
          : this.queryDescription,
      seekerUuid:
          data.seekerUuid.present ? data.seekerUuid.value : this.seekerUuid,
      tinySummary:
          data.tinySummary.present ? data.tinySummary.value : this.tinySummary,
      directlyPredict: data.directlyPredict.present
          ? data.directlyPredict.value
          : this.directlyPredict,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Query(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryTypeUuid: $queryTypeUuid, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('isSeersLocation: $isSeersLocation, ')
          ..write('queryQuestion: $queryQuestion, ')
          ..write('queryDescription: $queryDescription, ')
          ..write('seekerUuid: $seekerUuid, ')
          ..write('tinySummary: $tinySummary, ')
          ..write('directlyPredict: $directlyPredict, ')
          ..write('panelUuid: $panelUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      createdAt,
      lastUpdatedAt,
      deletedAt,
      queryTypeUuid,
      yearGanZhi,
      isSeersLocation,
      queryQuestion,
      queryDescription,
      seekerUuid,
      tinySummary,
      directlyPredict,
      panelUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Query &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.queryTypeUuid == this.queryTypeUuid &&
          other.yearGanZhi == this.yearGanZhi &&
          other.isSeersLocation == this.isSeersLocation &&
          other.queryQuestion == this.queryQuestion &&
          other.queryDescription == this.queryDescription &&
          other.seekerUuid == this.seekerUuid &&
          other.tinySummary == this.tinySummary &&
          other.directlyPredict == this.directlyPredict &&
          other.panelUuid == this.panelUuid);
}

class QueriesCompanion extends UpdateCompanion<Query> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> queryTypeUuid;
  final Value<String?> yearGanZhi;
  final Value<bool> isSeersLocation;
  final Value<String> queryQuestion;
  final Value<String> queryDescription;
  final Value<String?> seekerUuid;
  final Value<String> tinySummary;
  final Value<String> directlyPredict;
  final Value<String?> panelUuid;
  final Value<int> rowid;
  const QueriesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.queryTypeUuid = const Value.absent(),
    this.yearGanZhi = const Value.absent(),
    this.isSeersLocation = const Value.absent(),
    this.queryQuestion = const Value.absent(),
    this.queryDescription = const Value.absent(),
    this.seekerUuid = const Value.absent(),
    this.tinySummary = const Value.absent(),
    this.directlyPredict = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueriesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String queryTypeUuid,
    this.yearGanZhi = const Value.absent(),
    required bool isSeersLocation,
    required String queryQuestion,
    required String queryDescription,
    this.seekerUuid = const Value.absent(),
    required String tinySummary,
    required String directlyPredict,
    this.panelUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        queryTypeUuid = Value(queryTypeUuid),
        isSeersLocation = Value(isSeersLocation),
        queryQuestion = Value(queryQuestion),
        queryDescription = Value(queryDescription),
        tinySummary = Value(tinySummary),
        directlyPredict = Value(directlyPredict);
  static Insertable<Query> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? queryTypeUuid,
    Expression<String>? yearGanZhi,
    Expression<bool>? isSeersLocation,
    Expression<String>? queryQuestion,
    Expression<String>? queryDescription,
    Expression<String>? seekerUuid,
    Expression<String>? tinySummary,
    Expression<String>? directlyPredict,
    Expression<String>? panelUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (queryTypeUuid != null) 'query_type_uuid': queryTypeUuid,
      if (yearGanZhi != null) 'year_gan_zhi': yearGanZhi,
      if (isSeersLocation != null) 'is_seers_location': isSeersLocation,
      if (queryQuestion != null) 'query_question': queryQuestion,
      if (queryDescription != null) 'query_description': queryDescription,
      if (seekerUuid != null) 'seeker_uuid': seekerUuid,
      if (tinySummary != null) 'tiny_summary': tinySummary,
      if (directlyPredict != null) 'directly_predict': directlyPredict,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueriesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? queryTypeUuid,
      Value<String?>? yearGanZhi,
      Value<bool>? isSeersLocation,
      Value<String>? queryQuestion,
      Value<String>? queryDescription,
      Value<String?>? seekerUuid,
      Value<String>? tinySummary,
      Value<String>? directlyPredict,
      Value<String?>? panelUuid,
      Value<int>? rowid}) {
    return QueriesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      queryTypeUuid: queryTypeUuid ?? this.queryTypeUuid,
      yearGanZhi: yearGanZhi ?? this.yearGanZhi,
      isSeersLocation: isSeersLocation ?? this.isSeersLocation,
      queryQuestion: queryQuestion ?? this.queryQuestion,
      queryDescription: queryDescription ?? this.queryDescription,
      seekerUuid: seekerUuid ?? this.seekerUuid,
      tinySummary: tinySummary ?? this.tinySummary,
      directlyPredict: directlyPredict ?? this.directlyPredict,
      panelUuid: panelUuid ?? this.panelUuid,
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
    if (queryTypeUuid.present) {
      map['query_type_uuid'] = Variable<String>(queryTypeUuid.value);
    }
    if (yearGanZhi.present) {
      map['year_gan_zhi'] = Variable<String>(yearGanZhi.value);
    }
    if (isSeersLocation.present) {
      map['is_seers_location'] = Variable<bool>(isSeersLocation.value);
    }
    if (queryQuestion.present) {
      map['query_question'] = Variable<String>(queryQuestion.value);
    }
    if (queryDescription.present) {
      map['query_description'] = Variable<String>(queryDescription.value);
    }
    if (seekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(seekerUuid.value);
    }
    if (tinySummary.present) {
      map['tiny_summary'] = Variable<String>(tinySummary.value);
    }
    if (directlyPredict.present) {
      map['directly_predict'] = Variable<String>(directlyPredict.value);
    }
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryTypeUuid: $queryTypeUuid, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('isSeersLocation: $isSeersLocation, ')
          ..write('queryQuestion: $queryQuestion, ')
          ..write('queryDescription: $queryDescription, ')
          ..write('seekerUuid: $seekerUuid, ')
          ..write('tinySummary: $tinySummary, ')
          ..write('directlyPredict: $directlyPredict, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SkillsTable extends Skills with TableInfo<$SkillsTable, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionsMeta =
      const VerificationMeta('descriptions');
  @override
  late final GeneratedColumn<String> descriptions = GeneratedColumn<String>(
      'descriptions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        isAvailable,
        name,
        descriptions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skills';
  @override
  VerificationContext validateIntegrity(Insertable<Skill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('descriptions')) {
      context.handle(
          _descriptionsMeta,
          descriptions.isAcceptableOrUnknown(
              data['descriptions']!, _descriptionsMeta));
    } else if (isInserting) {
      context.missing(_descriptionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      descriptions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descriptions'])!,
    );
  }

  @override
  $SkillsTable createAlias(String alias) {
    return $SkillsTable(attachedDatabase, alias);
  }
}

class Skill extends DataClass implements Insertable<Skill> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final bool isAvailable;
  final String name;
  final String descriptions;
  const Skill(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.isAvailable,
      required this.name,
      required this.descriptions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_available'] = Variable<bool>(isAvailable);
    map['name'] = Variable<String>(name);
    map['descriptions'] = Variable<String>(descriptions);
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isAvailable: Value(isAvailable),
      name: Value(name),
      descriptions: Value(descriptions),
    );
  }

  factory Skill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      name: serializer.fromJson<String>(json['name']),
      descriptions: serializer.fromJson<String>(json['descriptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'name': serializer.toJson<String>(name),
      'descriptions': serializer.toJson<String>(descriptions),
    };
  }

  Skill copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isAvailable,
          String? name,
          String? descriptions}) =>
      Skill(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isAvailable: isAvailable ?? this.isAvailable,
        name: name ?? this.name,
        descriptions: descriptions ?? this.descriptions,
      );
  Skill copyWithCompanion(SkillsCompanion data) {
    return Skill(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
      name: data.name.present ? data.name.value : this.name,
      descriptions: data.descriptions.present
          ? data.descriptions.value
          : this.descriptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('name: $name, ')
          ..write('descriptions: $descriptions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, lastUpdatedAt, deletedAt, isAvailable, name, descriptions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isAvailable == this.isAvailable &&
          other.name == this.name &&
          other.descriptions == this.descriptions);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isAvailable;
  final Value<String> name;
  final Value<String> descriptions;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.name = const Value.absent(),
    this.descriptions = const Value.absent(),
  });
  SkillsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required bool isAvailable,
    required String name,
    required String descriptions,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        isAvailable = Value(isAvailable),
        name = Value(name),
        descriptions = Value(descriptions);
  static Insertable<Skill> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isAvailable,
    Expression<String>? name,
    Expression<String>? descriptions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isAvailable != null) 'is_available': isAvailable,
      if (name != null) 'name': name,
      if (descriptions != null) 'descriptions': descriptions,
    });
  }

  SkillsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isAvailable,
      Value<String>? name,
      Value<String>? descriptions}) {
    return SkillsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      name: name ?? this.name,
      descriptions: descriptions ?? this.descriptions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (descriptions.present) {
      map['descriptions'] = Variable<String>(descriptions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('name: $name, ')
          ..write('descriptions: $descriptions')
          ..write(')'))
        .toString();
  }
}

class $CombinedQueriesTable extends CombinedQueries
    with TableInfo<$CombinedQueriesTable, CombinedQuery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombinedQueriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _queryUuidMeta =
      const VerificationMeta('queryUuid');
  @override
  late final GeneratedColumn<String> queryUuid = GeneratedColumn<String>(
      'query_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _combinedTypeMeta =
      const VerificationMeta('combinedType');
  @override
  late final GeneratedColumn<String> combinedType = GeneratedColumn<String>(
      'combined_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, order, queryUuid, createdAt, deletedAt, combinedType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'combined_queries';
  @override
  VerificationContext validateIntegrity(Insertable<CombinedQuery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('query_uuid')) {
      context.handle(_queryUuidMeta,
          queryUuid.isAcceptableOrUnknown(data['query_uuid']!, _queryUuidMeta));
    } else if (isInserting) {
      context.missing(_queryUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('combined_type')) {
      context.handle(
          _combinedTypeMeta,
          combinedType.isAcceptableOrUnknown(
              data['combined_type']!, _combinedTypeMeta));
    } else if (isInserting) {
      context.missing(_combinedTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CombinedQuery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CombinedQuery(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      queryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      combinedType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}combined_type'])!,
    );
  }

  @override
  $CombinedQueriesTable createAlias(String alias) {
    return $CombinedQueriesTable(attachedDatabase, alias);
  }
}

class CombinedQuery extends DataClass implements Insertable<CombinedQuery> {
  final String uuid;
  final int order;
  final String queryUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String combinedType;
  const CombinedQuery(
      {required this.uuid,
      required this.order,
      required this.queryUuid,
      required this.createdAt,
      this.deletedAt,
      required this.combinedType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['order'] = Variable<int>(order);
    map['query_uuid'] = Variable<String>(queryUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['combined_type'] = Variable<String>(combinedType);
    return map;
  }

  CombinedQueriesCompanion toCompanion(bool nullToAbsent) {
    return CombinedQueriesCompanion(
      uuid: Value(uuid),
      order: Value(order),
      queryUuid: Value(queryUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      combinedType: Value(combinedType),
    );
  }

  factory CombinedQuery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CombinedQuery(
      uuid: serializer.fromJson<String>(json['uuid']),
      order: serializer.fromJson<int>(json['order']),
      queryUuid: serializer.fromJson<String>(json['queryUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      combinedType: serializer.fromJson<String>(json['combinedType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'order': serializer.toJson<int>(order),
      'queryUuid': serializer.toJson<String>(queryUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'combinedType': serializer.toJson<String>(combinedType),
    };
  }

  CombinedQuery copyWith(
          {String? uuid,
          int? order,
          String? queryUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? combinedType}) =>
      CombinedQuery(
        uuid: uuid ?? this.uuid,
        order: order ?? this.order,
        queryUuid: queryUuid ?? this.queryUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        combinedType: combinedType ?? this.combinedType,
      );
  CombinedQuery copyWithCompanion(CombinedQueriesCompanion data) {
    return CombinedQuery(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      order: data.order.present ? data.order.value : this.order,
      queryUuid: data.queryUuid.present ? data.queryUuid.value : this.queryUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      combinedType: data.combinedType.present
          ? data.combinedType.value
          : this.combinedType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CombinedQuery(')
          ..write('uuid: $uuid, ')
          ..write('order: $order, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('combinedType: $combinedType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, order, queryUuid, createdAt, deletedAt, combinedType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombinedQuery &&
          other.uuid == this.uuid &&
          other.order == this.order &&
          other.queryUuid == this.queryUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.combinedType == this.combinedType);
}

class CombinedQueriesCompanion extends UpdateCompanion<CombinedQuery> {
  final Value<String> uuid;
  final Value<int> order;
  final Value<String> queryUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<String> combinedType;
  final Value<int> rowid;
  const CombinedQueriesCompanion({
    this.uuid = const Value.absent(),
    this.order = const Value.absent(),
    this.queryUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.combinedType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CombinedQueriesCompanion.insert({
    required String uuid,
    required int order,
    required String queryUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    required String combinedType,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        order = Value(order),
        queryUuid = Value(queryUuid),
        createdAt = Value(createdAt),
        combinedType = Value(combinedType);
  static Insertable<CombinedQuery> custom({
    Expression<String>? uuid,
    Expression<int>? order,
    Expression<String>? queryUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? combinedType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (order != null) 'order': order,
      if (queryUuid != null) 'query_uuid': queryUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (combinedType != null) 'combined_type': combinedType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CombinedQueriesCompanion copyWith(
      {Value<String>? uuid,
      Value<int>? order,
      Value<String>? queryUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt,
      Value<String>? combinedType,
      Value<int>? rowid}) {
    return CombinedQueriesCompanion(
      uuid: uuid ?? this.uuid,
      order: order ?? this.order,
      queryUuid: queryUuid ?? this.queryUuid,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      combinedType: combinedType ?? this.combinedType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (queryUuid.present) {
      map['query_uuid'] = Variable<String>(queryUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (combinedType.present) {
      map['combined_type'] = Variable<String>(combinedType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombinedQueriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('order: $order, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('combinedType: $combinedType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueryDatetimeTable extends QueryDatetime
    with TableInfo<$QueryDatetimeTable, QueryDatetimeModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueryDatetimeTable(this.attachedDatabase, [this._alias]);
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
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<EnumDatetimeType, String> type =
      GeneratedColumn<String>('datetime_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EnumDatetimeType>($QueryDatetimeTable.$convertertype);
  static const VerificationMeta _isDstMeta = const VerificationMeta('isDst');
  @override
  late final GeneratedColumn<bool> isDst = GeneratedColumn<bool>(
      'is_dst', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dst" IN (0, 1))'));
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'));
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timezoneStrMeta =
      const VerificationMeta('timezoneStr');
  @override
  late final GeneratedColumn<String> timezoneStr = GeneratedColumn<String>(
      'timezone_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Location?, String> location =
      GeneratedColumn<String>('location_json', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Location?>($QueryDatetimeTable.$converterlocationn);
  @override
  late final GeneratedColumnWithTypeConverter<Coordinates?, String>
      coordinates = GeneratedColumn<String>('coordinates', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Coordinates?>(
              $QueryDatetimeTable.$convertercoordinatesn);
  static const VerificationMeta _hourAdjustedMeta =
      const VerificationMeta('hourAdjusted');
  @override
  late final GeneratedColumn<int> hourAdjusted = GeneratedColumn<int>(
      'hour_adjusted', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, String> yearJiaZi =
      GeneratedColumn<String>('year_gan_zhi', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JiaZi>($QueryDatetimeTable.$converteryearJiaZi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, String> monthJiaZi =
      GeneratedColumn<String>('month_gan_zhi', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JiaZi>($QueryDatetimeTable.$convertermonthJiaZi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, String> dayJiaZi =
      GeneratedColumn<String>('day_gan_zhi', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JiaZi>($QueryDatetimeTable.$converterdayJiaZi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, String> timeJiaZi =
      GeneratedColumn<String>('hour_gan_zhi', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JiaZi>($QueryDatetimeTable.$convertertimeJiaZi);
  static const VerificationMeta _lunarMonthMeta =
      const VerificationMeta('lunarMonth');
  @override
  late final GeneratedColumn<String> lunarMonth = GeneratedColumn<String>(
      'lunar_month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lunarDayMeta =
      const VerificationMeta('lunarDay');
  @override
  late final GeneratedColumn<String> lunarDay = GeneratedColumn<String>(
      'lunar_day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<JieQiInfo, String> jieQiInfo =
      GeneratedColumn<String>('jie_qi_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JieQiInfo>($QueryDatetimeTable.$converterjieQiInfo);
  static const VerificationMeta _queryUuidMeta =
      const VerificationMeta('queryUuid');
  @override
  late final GeneratedColumn<String> queryUuid = GeneratedColumn<String>(
      't_query_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        type,
        isDst,
        isManual,
        datetime,
        timezoneStr,
        location,
        coordinates,
        hourAdjusted,
        yearJiaZi,
        monthJiaZi,
        dayJiaZi,
        timeJiaZi,
        lunarMonth,
        lunarDay,
        jieQiInfo,
        queryUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'query_datetime';
  @override
  VerificationContext validateIntegrity(Insertable<QueryDatetimeModel> instance,
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
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dst')) {
      context.handle(
          _isDstMeta, isDst.isAcceptableOrUnknown(data['is_dst']!, _isDstMeta));
    } else if (isInserting) {
      context.missing(_isDstMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    } else if (isInserting) {
      context.missing(_isManualMeta);
    }
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('timezone_str')) {
      context.handle(
          _timezoneStrMeta,
          timezoneStr.isAcceptableOrUnknown(
              data['timezone_str']!, _timezoneStrMeta));
    } else if (isInserting) {
      context.missing(_timezoneStrMeta);
    }
    if (data.containsKey('hour_adjusted')) {
      context.handle(
          _hourAdjustedMeta,
          hourAdjusted.isAcceptableOrUnknown(
              data['hour_adjusted']!, _hourAdjustedMeta));
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
          _lunarMonthMeta,
          lunarMonth.isAcceptableOrUnknown(
              data['lunar_month']!, _lunarMonthMeta));
    } else if (isInserting) {
      context.missing(_lunarMonthMeta);
    }
    if (data.containsKey('lunar_day')) {
      context.handle(_lunarDayMeta,
          lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta));
    } else if (isInserting) {
      context.missing(_lunarDayMeta);
    }
    if (data.containsKey('t_query_uuid')) {
      context.handle(
          _queryUuidMeta,
          queryUuid.isAcceptableOrUnknown(
              data['t_query_uuid']!, _queryUuidMeta));
    } else if (isInserting) {
      context.missing(_queryUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  QueryDatetimeModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueryDatetimeModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      queryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}t_query_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      type: $QueryDatetimeTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}datetime_type'])!),
      hourAdjusted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hour_adjusted']),
      location: $QueryDatetimeTable.$converterlocationn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_json'])),
      coordinates: $QueryDatetimeTable.$convertercoordinatesn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}coordinates'])),
      timezoneStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone_str'])!,
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      yearJiaZi: $QueryDatetimeTable.$converteryearJiaZi.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}year_gan_zhi'])!),
      monthJiaZi: $QueryDatetimeTable.$convertermonthJiaZi.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}month_gan_zhi'])!),
      dayJiaZi: $QueryDatetimeTable.$converterdayJiaZi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_gan_zhi'])!),
      timeJiaZi: $QueryDatetimeTable.$convertertimeJiaZi.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}hour_gan_zhi'])!),
      lunarMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunar_month'])!,
      lunarDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lunar_day'])!,
      jieQiInfo: $QueryDatetimeTable.$converterjieQiInfo.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}jie_qi_json'])!),
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
      isDst: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dst'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $QueryDatetimeTable createAlias(String alias) {
    return $QueryDatetimeTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnumDatetimeType, String, String> $convertertype =
      const EnumNameConverter(EnumDatetimeType.values);
  static TypeConverter<Location, String> $converterlocation =
      const LocationConverter();
  static TypeConverter<Location?, String?> $converterlocationn =
      NullAwareTypeConverter.wrap($converterlocation);
  static TypeConverter<Coordinates, String> $convertercoordinates =
      const CoordinatesConverter();
  static TypeConverter<Coordinates?, String?> $convertercoordinatesn =
      NullAwareTypeConverter.wrap($convertercoordinates);
  static JsonTypeConverter2<JiaZi, String, String> $converteryearJiaZi =
      const EnumNameConverter(JiaZi.values);
  static JsonTypeConverter2<JiaZi, String, String> $convertermonthJiaZi =
      const EnumNameConverter(JiaZi.values);
  static JsonTypeConverter2<JiaZi, String, String> $converterdayJiaZi =
      const EnumNameConverter(JiaZi.values);
  static JsonTypeConverter2<JiaZi, String, String> $convertertimeJiaZi =
      const EnumNameConverter(JiaZi.values);
  static TypeConverter<JieQiInfo, String> $converterjieQiInfo =
      const JieQiInfoConverter();
}

class QueryDatetimeCompanion extends UpdateCompanion<QueryDatetimeModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<EnumDatetimeType> type;
  final Value<bool> isDst;
  final Value<bool> isManual;
  final Value<DateTime> datetime;
  final Value<String> timezoneStr;
  final Value<Location?> location;
  final Value<Coordinates?> coordinates;
  final Value<int?> hourAdjusted;
  final Value<JiaZi> yearJiaZi;
  final Value<JiaZi> monthJiaZi;
  final Value<JiaZi> dayJiaZi;
  final Value<JiaZi> timeJiaZi;
  final Value<String> lunarMonth;
  final Value<String> lunarDay;
  final Value<JieQiInfo> jieQiInfo;
  final Value<String> queryUuid;
  final Value<int> rowid;
  const QueryDatetimeCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.isDst = const Value.absent(),
    this.isManual = const Value.absent(),
    this.datetime = const Value.absent(),
    this.timezoneStr = const Value.absent(),
    this.location = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.hourAdjusted = const Value.absent(),
    this.yearJiaZi = const Value.absent(),
    this.monthJiaZi = const Value.absent(),
    this.dayJiaZi = const Value.absent(),
    this.timeJiaZi = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.jieQiInfo = const Value.absent(),
    this.queryUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueryDatetimeCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required EnumDatetimeType type,
    required bool isDst,
    required bool isManual,
    required DateTime datetime,
    required String timezoneStr,
    this.location = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.hourAdjusted = const Value.absent(),
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi dayJiaZi,
    required JiaZi timeJiaZi,
    required String lunarMonth,
    required String lunarDay,
    required JieQiInfo jieQiInfo,
    required String queryUuid,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        type = Value(type),
        isDst = Value(isDst),
        isManual = Value(isManual),
        datetime = Value(datetime),
        timezoneStr = Value(timezoneStr),
        yearJiaZi = Value(yearJiaZi),
        monthJiaZi = Value(monthJiaZi),
        dayJiaZi = Value(dayJiaZi),
        timeJiaZi = Value(timeJiaZi),
        lunarMonth = Value(lunarMonth),
        lunarDay = Value(lunarDay),
        jieQiInfo = Value(jieQiInfo),
        queryUuid = Value(queryUuid);
  static Insertable<QueryDatetimeModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? type,
    Expression<bool>? isDst,
    Expression<bool>? isManual,
    Expression<DateTime>? datetime,
    Expression<String>? timezoneStr,
    Expression<String>? location,
    Expression<String>? coordinates,
    Expression<int>? hourAdjusted,
    Expression<String>? yearJiaZi,
    Expression<String>? monthJiaZi,
    Expression<String>? dayJiaZi,
    Expression<String>? timeJiaZi,
    Expression<String>? lunarMonth,
    Expression<String>? lunarDay,
    Expression<String>? jieQiInfo,
    Expression<String>? queryUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (type != null) 'datetime_type': type,
      if (isDst != null) 'is_dst': isDst,
      if (isManual != null) 'is_manual': isManual,
      if (datetime != null) 'datetime': datetime,
      if (timezoneStr != null) 'timezone_str': timezoneStr,
      if (location != null) 'location_json': location,
      if (coordinates != null) 'coordinates': coordinates,
      if (hourAdjusted != null) 'hour_adjusted': hourAdjusted,
      if (yearJiaZi != null) 'year_gan_zhi': yearJiaZi,
      if (monthJiaZi != null) 'month_gan_zhi': monthJiaZi,
      if (dayJiaZi != null) 'day_gan_zhi': dayJiaZi,
      if (timeJiaZi != null) 'hour_gan_zhi': timeJiaZi,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (jieQiInfo != null) 'jie_qi_json': jieQiInfo,
      if (queryUuid != null) 't_query_uuid': queryUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueryDatetimeCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<EnumDatetimeType>? type,
      Value<bool>? isDst,
      Value<bool>? isManual,
      Value<DateTime>? datetime,
      Value<String>? timezoneStr,
      Value<Location?>? location,
      Value<Coordinates?>? coordinates,
      Value<int?>? hourAdjusted,
      Value<JiaZi>? yearJiaZi,
      Value<JiaZi>? monthJiaZi,
      Value<JiaZi>? dayJiaZi,
      Value<JiaZi>? timeJiaZi,
      Value<String>? lunarMonth,
      Value<String>? lunarDay,
      Value<JieQiInfo>? jieQiInfo,
      Value<String>? queryUuid,
      Value<int>? rowid}) {
    return QueryDatetimeCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
      isDst: isDst ?? this.isDst,
      isManual: isManual ?? this.isManual,
      datetime: datetime ?? this.datetime,
      timezoneStr: timezoneStr ?? this.timezoneStr,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      hourAdjusted: hourAdjusted ?? this.hourAdjusted,
      yearJiaZi: yearJiaZi ?? this.yearJiaZi,
      monthJiaZi: monthJiaZi ?? this.monthJiaZi,
      dayJiaZi: dayJiaZi ?? this.dayJiaZi,
      timeJiaZi: timeJiaZi ?? this.timeJiaZi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      jieQiInfo: jieQiInfo ?? this.jieQiInfo,
      queryUuid: queryUuid ?? this.queryUuid,
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
    if (type.present) {
      map['datetime_type'] = Variable<String>(
          $QueryDatetimeTable.$convertertype.toSql(type.value));
    }
    if (isDst.present) {
      map['is_dst'] = Variable<bool>(isDst.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (timezoneStr.present) {
      map['timezone_str'] = Variable<String>(timezoneStr.value);
    }
    if (location.present) {
      map['location_json'] = Variable<String>(
          $QueryDatetimeTable.$converterlocationn.toSql(location.value));
    }
    if (coordinates.present) {
      map['coordinates'] = Variable<String>(
          $QueryDatetimeTable.$convertercoordinatesn.toSql(coordinates.value));
    }
    if (hourAdjusted.present) {
      map['hour_adjusted'] = Variable<int>(hourAdjusted.value);
    }
    if (yearJiaZi.present) {
      map['year_gan_zhi'] = Variable<String>(
          $QueryDatetimeTable.$converteryearJiaZi.toSql(yearJiaZi.value));
    }
    if (monthJiaZi.present) {
      map['month_gan_zhi'] = Variable<String>(
          $QueryDatetimeTable.$convertermonthJiaZi.toSql(monthJiaZi.value));
    }
    if (dayJiaZi.present) {
      map['day_gan_zhi'] = Variable<String>(
          $QueryDatetimeTable.$converterdayJiaZi.toSql(dayJiaZi.value));
    }
    if (timeJiaZi.present) {
      map['hour_gan_zhi'] = Variable<String>(
          $QueryDatetimeTable.$convertertimeJiaZi.toSql(timeJiaZi.value));
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<String>(lunarMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<String>(lunarDay.value);
    }
    if (jieQiInfo.present) {
      map['jie_qi_json'] = Variable<String>(
          $QueryDatetimeTable.$converterjieQiInfo.toSql(jieQiInfo.value));
    }
    if (queryUuid.present) {
      map['t_query_uuid'] = Variable<String>(queryUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueryDatetimeCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('type: $type, ')
          ..write('isDst: $isDst, ')
          ..write('isManual: $isManual, ')
          ..write('datetime: $datetime, ')
          ..write('timezoneStr: $timezoneStr, ')
          ..write('location: $location, ')
          ..write('coordinates: $coordinates, ')
          ..write('hourAdjusted: $hourAdjusted, ')
          ..write('yearJiaZi: $yearJiaZi, ')
          ..write('monthJiaZi: $monthJiaZi, ')
          ..write('dayJiaZi: $dayJiaZi, ')
          ..write('timeJiaZi: $timeJiaZi, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('jieQiInfo: $jieQiInfo, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeekersTable extends Seekers with TableInfo<$SeekersTable, Seeker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeekersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _birthDatetimeMeta =
      const VerificationMeta('birthDatetime');
  @override
  late final GeneratedColumn<DateTime> birthDatetime =
      GeneratedColumn<DateTime>('birth_datetime', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _eightCharsMeta =
      const VerificationMeta('eightChars');
  @override
  late final GeneratedColumn<String> eightChars = GeneratedColumn<String>(
      'eight_chars', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthLocationMeta =
      const VerificationMeta('birthLocation');
  @override
  late final GeneratedColumn<String> birthLocation = GeneratedColumn<String>(
      'birth_location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthLngMeta =
      const VerificationMeta('birthLng');
  @override
  late final GeneratedColumn<double> birthLng = GeneratedColumn<double>(
      'birth_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _birthLatMeta =
      const VerificationMeta('birthLat');
  @override
  late final GeneratedColumn<double> birthLat = GeneratedColumn<double>(
      'birth_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentLocationMeta =
      const VerificationMeta('currentLocation');
  @override
  late final GeneratedColumn<String> currentLocation = GeneratedColumn<String>(
      'current_location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentLngMeta =
      const VerificationMeta('currentLng');
  @override
  late final GeneratedColumn<double> currentLng = GeneratedColumn<double>(
      'current_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentLatMeta =
      const VerificationMeta('currentLat');
  @override
  late final GeneratedColumn<double> currentLat = GeneratedColumn<double>(
      'current_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        username,
        nickname,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        birthDatetime,
        eightChars,
        birthLocation,
        birthLng,
        birthLat,
        currentLocation,
        currentLng,
        currentLat
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seekers';
  @override
  VerificationContext validateIntegrity(Insertable<Seeker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
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
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('birth_datetime')) {
      context.handle(
          _birthDatetimeMeta,
          birthDatetime.isAcceptableOrUnknown(
              data['birth_datetime']!, _birthDatetimeMeta));
    } else if (isInserting) {
      context.missing(_birthDatetimeMeta);
    }
    if (data.containsKey('eight_chars')) {
      context.handle(
          _eightCharsMeta,
          eightChars.isAcceptableOrUnknown(
              data['eight_chars']!, _eightCharsMeta));
    } else if (isInserting) {
      context.missing(_eightCharsMeta);
    }
    if (data.containsKey('birth_location')) {
      context.handle(
          _birthLocationMeta,
          birthLocation.isAcceptableOrUnknown(
              data['birth_location']!, _birthLocationMeta));
    } else if (isInserting) {
      context.missing(_birthLocationMeta);
    }
    if (data.containsKey('birth_lng')) {
      context.handle(_birthLngMeta,
          birthLng.isAcceptableOrUnknown(data['birth_lng']!, _birthLngMeta));
    } else if (isInserting) {
      context.missing(_birthLngMeta);
    }
    if (data.containsKey('birth_lat')) {
      context.handle(_birthLatMeta,
          birthLat.isAcceptableOrUnknown(data['birth_lat']!, _birthLatMeta));
    } else if (isInserting) {
      context.missing(_birthLatMeta);
    }
    if (data.containsKey('current_location')) {
      context.handle(
          _currentLocationMeta,
          currentLocation.isAcceptableOrUnknown(
              data['current_location']!, _currentLocationMeta));
    } else if (isInserting) {
      context.missing(_currentLocationMeta);
    }
    if (data.containsKey('current_lng')) {
      context.handle(
          _currentLngMeta,
          currentLng.isAcceptableOrUnknown(
              data['current_lng']!, _currentLngMeta));
    } else if (isInserting) {
      context.missing(_currentLngMeta);
    }
    if (data.containsKey('current_lat')) {
      context.handle(
          _currentLatMeta,
          currentLat.isAcceptableOrUnknown(
              data['current_lat']!, _currentLatMeta));
    } else if (isInserting) {
      context.missing(_currentLatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Seeker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Seeker(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      birthDatetime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}birth_datetime'])!,
      eightChars: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}eight_chars'])!,
      birthLocation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_location'])!,
      birthLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_lng'])!,
      birthLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_lat'])!,
      currentLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_location'])!,
      currentLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_lng'])!,
      currentLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_lat'])!,
    );
  }

  @override
  $SeekersTable createAlias(String alias) {
    return $SeekersTable(attachedDatabase, alias);
  }
}

class Seeker extends DataClass implements Insertable<Seeker> {
  final String uuid;
  final String username;
  final String nickname;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final DateTime birthDatetime;
  final String eightChars;
  final String birthLocation;
  final double birthLng;
  final double birthLat;
  final String currentLocation;
  final double currentLng;
  final double currentLat;
  const Seeker(
      {required this.uuid,
      required this.username,
      required this.nickname,
      required this.createdAt,
      this.lastUpdatedAt,
      this.deletedAt,
      required this.birthDatetime,
      required this.eightChars,
      required this.birthLocation,
      required this.birthLng,
      required this.birthLat,
      required this.currentLocation,
      required this.currentLng,
      required this.currentLat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['username'] = Variable<String>(username);
    map['nickname'] = Variable<String>(nickname);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUpdatedAt != null) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['birth_datetime'] = Variable<DateTime>(birthDatetime);
    map['eight_chars'] = Variable<String>(eightChars);
    map['birth_location'] = Variable<String>(birthLocation);
    map['birth_lng'] = Variable<double>(birthLng);
    map['birth_lat'] = Variable<double>(birthLat);
    map['current_location'] = Variable<String>(currentLocation);
    map['current_lng'] = Variable<double>(currentLng);
    map['current_lat'] = Variable<double>(currentLat);
    return map;
  }

  SeekersCompanion toCompanion(bool nullToAbsent) {
    return SeekersCompanion(
      uuid: Value(uuid),
      username: Value(username),
      nickname: Value(nickname),
      createdAt: Value(createdAt),
      lastUpdatedAt: lastUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      birthDatetime: Value(birthDatetime),
      eightChars: Value(eightChars),
      birthLocation: Value(birthLocation),
      birthLng: Value(birthLng),
      birthLat: Value(birthLat),
      currentLocation: Value(currentLocation),
      currentLng: Value(currentLng),
      currentLat: Value(currentLat),
    );
  }

  factory Seeker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Seeker(
      uuid: serializer.fromJson<String>(json['uuid']),
      username: serializer.fromJson<String>(json['username']),
      nickname: serializer.fromJson<String>(json['nickname']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime?>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      birthDatetime: serializer.fromJson<DateTime>(json['birthDatetime']),
      eightChars: serializer.fromJson<String>(json['eightChars']),
      birthLocation: serializer.fromJson<String>(json['birthLocation']),
      birthLng: serializer.fromJson<double>(json['birthLng']),
      birthLat: serializer.fromJson<double>(json['birthLat']),
      currentLocation: serializer.fromJson<String>(json['currentLocation']),
      currentLng: serializer.fromJson<double>(json['currentLng']),
      currentLat: serializer.fromJson<double>(json['currentLat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'username': serializer.toJson<String>(username),
      'nickname': serializer.toJson<String>(nickname),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime?>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'birthDatetime': serializer.toJson<DateTime>(birthDatetime),
      'eightChars': serializer.toJson<String>(eightChars),
      'birthLocation': serializer.toJson<String>(birthLocation),
      'birthLng': serializer.toJson<double>(birthLng),
      'birthLat': serializer.toJson<double>(birthLat),
      'currentLocation': serializer.toJson<String>(currentLocation),
      'currentLng': serializer.toJson<double>(currentLng),
      'currentLat': serializer.toJson<double>(currentLat),
    };
  }

  Seeker copyWith(
          {String? uuid,
          String? username,
          String? nickname,
          DateTime? createdAt,
          Value<DateTime?> lastUpdatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          DateTime? birthDatetime,
          String? eightChars,
          String? birthLocation,
          double? birthLng,
          double? birthLat,
          String? currentLocation,
          double? currentLng,
          double? currentLat}) =>
      Seeker(
        uuid: uuid ?? this.uuid,
        username: username ?? this.username,
        nickname: nickname ?? this.nickname,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt:
            lastUpdatedAt.present ? lastUpdatedAt.value : this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        birthDatetime: birthDatetime ?? this.birthDatetime,
        eightChars: eightChars ?? this.eightChars,
        birthLocation: birthLocation ?? this.birthLocation,
        birthLng: birthLng ?? this.birthLng,
        birthLat: birthLat ?? this.birthLat,
        currentLocation: currentLocation ?? this.currentLocation,
        currentLng: currentLng ?? this.currentLng,
        currentLat: currentLat ?? this.currentLat,
      );
  Seeker copyWithCompanion(SeekersCompanion data) {
    return Seeker(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      username: data.username.present ? data.username.value : this.username,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      birthDatetime: data.birthDatetime.present
          ? data.birthDatetime.value
          : this.birthDatetime,
      eightChars:
          data.eightChars.present ? data.eightChars.value : this.eightChars,
      birthLocation: data.birthLocation.present
          ? data.birthLocation.value
          : this.birthLocation,
      birthLng: data.birthLng.present ? data.birthLng.value : this.birthLng,
      birthLat: data.birthLat.present ? data.birthLat.value : this.birthLat,
      currentLocation: data.currentLocation.present
          ? data.currentLocation.value
          : this.currentLocation,
      currentLng:
          data.currentLng.present ? data.currentLng.value : this.currentLng,
      currentLat:
          data.currentLat.present ? data.currentLat.value : this.currentLat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Seeker(')
          ..write('uuid: $uuid, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('birthDatetime: $birthDatetime, ')
          ..write('eightChars: $eightChars, ')
          ..write('birthLocation: $birthLocation, ')
          ..write('birthLng: $birthLng, ')
          ..write('birthLat: $birthLat, ')
          ..write('currentLocation: $currentLocation, ')
          ..write('currentLng: $currentLng, ')
          ..write('currentLat: $currentLat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      username,
      nickname,
      createdAt,
      lastUpdatedAt,
      deletedAt,
      birthDatetime,
      eightChars,
      birthLocation,
      birthLng,
      birthLat,
      currentLocation,
      currentLng,
      currentLat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Seeker &&
          other.uuid == this.uuid &&
          other.username == this.username &&
          other.nickname == this.nickname &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.birthDatetime == this.birthDatetime &&
          other.eightChars == this.eightChars &&
          other.birthLocation == this.birthLocation &&
          other.birthLng == this.birthLng &&
          other.birthLat == this.birthLat &&
          other.currentLocation == this.currentLocation &&
          other.currentLng == this.currentLng &&
          other.currentLat == this.currentLat);
}

class SeekersCompanion extends UpdateCompanion<Seeker> {
  final Value<String> uuid;
  final Value<String> username;
  final Value<String> nickname;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> birthDatetime;
  final Value<String> eightChars;
  final Value<String> birthLocation;
  final Value<double> birthLng;
  final Value<double> birthLat;
  final Value<String> currentLocation;
  final Value<double> currentLng;
  final Value<double> currentLat;
  final Value<int> rowid;
  const SeekersCompanion({
    this.uuid = const Value.absent(),
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.birthDatetime = const Value.absent(),
    this.eightChars = const Value.absent(),
    this.birthLocation = const Value.absent(),
    this.birthLng = const Value.absent(),
    this.birthLat = const Value.absent(),
    this.currentLocation = const Value.absent(),
    this.currentLng = const Value.absent(),
    this.currentLat = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeekersCompanion.insert({
    required String uuid,
    required String username,
    required String nickname,
    required DateTime createdAt,
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime birthDatetime,
    required String eightChars,
    required String birthLocation,
    required double birthLng,
    required double birthLat,
    required String currentLocation,
    required double currentLng,
    required double currentLat,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        username = Value(username),
        nickname = Value(nickname),
        createdAt = Value(createdAt),
        birthDatetime = Value(birthDatetime),
        eightChars = Value(eightChars),
        birthLocation = Value(birthLocation),
        birthLng = Value(birthLng),
        birthLat = Value(birthLat),
        currentLocation = Value(currentLocation),
        currentLng = Value(currentLng),
        currentLat = Value(currentLat);
  static Insertable<Seeker> custom({
    Expression<String>? uuid,
    Expression<String>? username,
    Expression<String>? nickname,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? birthDatetime,
    Expression<String>? eightChars,
    Expression<String>? birthLocation,
    Expression<double>? birthLng,
    Expression<double>? birthLat,
    Expression<String>? currentLocation,
    Expression<double>? currentLng,
    Expression<double>? currentLat,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (username != null) 'username': username,
      if (nickname != null) 'nickname': nickname,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (birthDatetime != null) 'birth_datetime': birthDatetime,
      if (eightChars != null) 'eight_chars': eightChars,
      if (birthLocation != null) 'birth_location': birthLocation,
      if (birthLng != null) 'birth_lng': birthLng,
      if (birthLat != null) 'birth_lat': birthLat,
      if (currentLocation != null) 'current_location': currentLocation,
      if (currentLng != null) 'current_lng': currentLng,
      if (currentLat != null) 'current_lat': currentLat,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeekersCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? username,
      Value<String>? nickname,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime>? birthDatetime,
      Value<String>? eightChars,
      Value<String>? birthLocation,
      Value<double>? birthLng,
      Value<double>? birthLat,
      Value<String>? currentLocation,
      Value<double>? currentLng,
      Value<double>? currentLat,
      Value<int>? rowid}) {
    return SeekersCompanion(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      birthDatetime: birthDatetime ?? this.birthDatetime,
      eightChars: eightChars ?? this.eightChars,
      birthLocation: birthLocation ?? this.birthLocation,
      birthLng: birthLng ?? this.birthLng,
      birthLat: birthLat ?? this.birthLat,
      currentLocation: currentLocation ?? this.currentLocation,
      currentLng: currentLng ?? this.currentLng,
      currentLat: currentLat ?? this.currentLat,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
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
    if (birthDatetime.present) {
      map['birth_datetime'] = Variable<DateTime>(birthDatetime.value);
    }
    if (eightChars.present) {
      map['eight_chars'] = Variable<String>(eightChars.value);
    }
    if (birthLocation.present) {
      map['birth_location'] = Variable<String>(birthLocation.value);
    }
    if (birthLng.present) {
      map['birth_lng'] = Variable<double>(birthLng.value);
    }
    if (birthLat.present) {
      map['birth_lat'] = Variable<double>(birthLat.value);
    }
    if (currentLocation.present) {
      map['current_location'] = Variable<String>(currentLocation.value);
    }
    if (currentLng.present) {
      map['current_lng'] = Variable<double>(currentLng.value);
    }
    if (currentLat.present) {
      map['current_lat'] = Variable<double>(currentLat.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeekersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('birthDatetime: $birthDatetime, ')
          ..write('eightChars: $eightChars, ')
          ..write('birthLocation: $birthLocation, ')
          ..write('birthLng: $birthLng, ')
          ..write('birthLat: $birthLat, ')
          ..write('currentLocation: $currentLocation, ')
          ..write('currentLng: $currentLng, ')
          ..write('currentLat: $currentLat, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubQueryTypesTable extends SubQueryTypes
    with TableInfo<$SubQueryTypesTable, SubQueryType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubQueryTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
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
  static const VerificationMeta _hiddenAtMeta =
      const VerificationMeta('hiddenAt');
  @override
  late final GeneratedColumn<DateTime> hiddenAt = GeneratedColumn<DateTime>(
      'hidden_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timesMeta = const VerificationMeta('times');
  @override
  late final GeneratedColumn<int> times = GeneratedColumn<int>(
      'times', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        lastUpdatedAt,
        deletedAt,
        hiddenAt,
        name,
        times,
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_query_types';
  @override
  VerificationContext validateIntegrity(Insertable<SubQueryType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
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
    if (data.containsKey('hidden_at')) {
      context.handle(_hiddenAtMeta,
          hiddenAt.isAcceptableOrUnknown(data['hidden_at']!, _hiddenAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('times')) {
      context.handle(
          _timesMeta, times.isAcceptableOrUnknown(data['times']!, _timesMeta));
    } else if (isInserting) {
      context.missing(_timesMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SubQueryType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubQueryType(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      hiddenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}hidden_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      times: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $SubQueryTypesTable createAlias(String alias) {
    return $SubQueryTypesTable(attachedDatabase, alias);
  }
}

class SubQueryType extends DataClass implements Insertable<SubQueryType> {
  final String uuid;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final DateTime? hiddenAt;
  final String name;
  final int times;
  final bool isCustomized;
  final bool isAvailable;
  const SubQueryType(
      {required this.uuid,
      required this.lastUpdatedAt,
      this.deletedAt,
      this.hiddenAt,
      required this.name,
      required this.times,
      required this.isCustomized,
      required this.isAvailable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hiddenAt != null) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt);
    }
    map['name'] = Variable<String>(name);
    map['times'] = Variable<int>(times);
    map['is_customized'] = Variable<bool>(isCustomized);
    map['is_available'] = Variable<bool>(isAvailable);
    return map;
  }

  SubQueryTypesCompanion toCompanion(bool nullToAbsent) {
    return SubQueryTypesCompanion(
      uuid: Value(uuid),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hiddenAt: hiddenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(hiddenAt),
      name: Value(name),
      times: Value(times),
      isCustomized: Value(isCustomized),
      isAvailable: Value(isAvailable),
    );
  }

  factory SubQueryType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubQueryType(
      uuid: serializer.fromJson<String>(json['uuid']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hiddenAt: serializer.fromJson<DateTime?>(json['hiddenAt']),
      name: serializer.fromJson<String>(json['name']),
      times: serializer.fromJson<int>(json['times']),
      isCustomized: serializer.fromJson<bool>(json['isCustomized']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hiddenAt': serializer.toJson<DateTime?>(hiddenAt),
      'name': serializer.toJson<String>(name),
      'times': serializer.toJson<int>(times),
      'isCustomized': serializer.toJson<bool>(isCustomized),
      'isAvailable': serializer.toJson<bool>(isAvailable),
    };
  }

  SubQueryType copyWith(
          {String? uuid,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<DateTime?> hiddenAt = const Value.absent(),
          String? name,
          int? times,
          bool? isCustomized,
          bool? isAvailable}) =>
      SubQueryType(
        uuid: uuid ?? this.uuid,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        hiddenAt: hiddenAt.present ? hiddenAt.value : this.hiddenAt,
        name: name ?? this.name,
        times: times ?? this.times,
        isCustomized: isCustomized ?? this.isCustomized,
        isAvailable: isAvailable ?? this.isAvailable,
      );
  SubQueryType copyWithCompanion(SubQueryTypesCompanion data) {
    return SubQueryType(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hiddenAt: data.hiddenAt.present ? data.hiddenAt.value : this.hiddenAt,
      name: data.name.present ? data.name.value : this.name,
      times: data.times.present ? data.times.value : this.times,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubQueryType(')
          ..write('uuid: $uuid, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('name: $name, ')
          ..write('times: $times, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, lastUpdatedAt, deletedAt, hiddenAt,
      name, times, isCustomized, isAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubQueryType &&
          other.uuid == this.uuid &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hiddenAt == this.hiddenAt &&
          other.name == this.name &&
          other.times == this.times &&
          other.isCustomized == this.isCustomized &&
          other.isAvailable == this.isAvailable);
}

class SubQueryTypesCompanion extends UpdateCompanion<SubQueryType> {
  final Value<String> uuid;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> hiddenAt;
  final Value<String> name;
  final Value<int> times;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const SubQueryTypesCompanion({
    this.uuid = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.name = const Value.absent(),
    this.times = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubQueryTypesCompanion.insert({
    required String uuid,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    required String name,
    required int times,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        times = Value(times),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<SubQueryType> custom({
    Expression<String>? uuid,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? hiddenAt,
    Expression<String>? name,
    Expression<int>? times,
    Expression<bool>? isCustomized,
    Expression<bool>? isAvailable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hiddenAt != null) 'hidden_at': hiddenAt,
      if (name != null) 'name': name,
      if (times != null) 'times': times,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubQueryTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? hiddenAt,
      Value<String>? name,
      Value<int>? times,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return SubQueryTypesCompanion(
      uuid: uuid ?? this.uuid,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      name: name ?? this.name,
      times: times ?? this.times,
      isCustomized: isCustomized ?? this.isCustomized,
      isAvailable: isAvailable ?? this.isAvailable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hiddenAt.present) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (times.present) {
      map['times'] = Variable<int>(times.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubQueryTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('name: $name, ')
          ..write('times: $times, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueryTypesTable extends QueryTypes
    with TableInfo<$QueryTypesTable, QueryType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueryTypesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timesMeta = const VerificationMeta('times');
  @override
  late final GeneratedColumn<int> times = GeneratedColumn<int>(
      'times', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        name,
        description,
        times,
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'query_types';
  @override
  VerificationContext validateIntegrity(Insertable<QueryType> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('times')) {
      context.handle(
          _timesMeta, times.isAcceptableOrUnknown(data['times']!, _timesMeta));
    } else if (isInserting) {
      context.missing(_timesMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    } else if (isInserting) {
      context.missing(_isAvailableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  QueryType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueryType(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      times: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $QueryTypesTable createAlias(String alias) {
    return $QueryTypesTable(attachedDatabase, alias);
  }
}

class QueryType extends DataClass implements Insertable<QueryType> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String name;
  final String description;
  final int times;
  final bool isCustomized;
  final bool isAvailable;
  const QueryType(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.name,
      required this.description,
      required this.times,
      required this.isCustomized,
      required this.isAvailable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['times'] = Variable<int>(times);
    map['is_customized'] = Variable<bool>(isCustomized);
    map['is_available'] = Variable<bool>(isAvailable);
    return map;
  }

  QueryTypesCompanion toCompanion(bool nullToAbsent) {
    return QueryTypesCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      description: Value(description),
      times: Value(times),
      isCustomized: Value(isCustomized),
      isAvailable: Value(isAvailable),
    );
  }

  factory QueryType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueryType(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      times: serializer.fromJson<int>(json['times']),
      isCustomized: serializer.fromJson<bool>(json['isCustomized']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'times': serializer.toJson<int>(times),
      'isCustomized': serializer.toJson<bool>(isCustomized),
      'isAvailable': serializer.toJson<bool>(isAvailable),
    };
  }

  QueryType copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? name,
          String? description,
          int? times,
          bool? isCustomized,
          bool? isAvailable}) =>
      QueryType(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        name: name ?? this.name,
        description: description ?? this.description,
        times: times ?? this.times,
        isCustomized: isCustomized ?? this.isCustomized,
        isAvailable: isAvailable ?? this.isAvailable,
      );
  QueryType copyWithCompanion(QueryTypesCompanion data) {
    return QueryType(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      times: data.times.present ? data.times.value : this.times,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueryType(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('times: $times, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, createdAt, lastUpdatedAt, deletedAt,
      name, description, times, isCustomized, isAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryType &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.description == this.description &&
          other.times == this.times &&
          other.isCustomized == this.isCustomized &&
          other.isAvailable == this.isAvailable);
}

class QueryTypesCompanion extends UpdateCompanion<QueryType> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> description;
  final Value<int> times;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const QueryTypesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.times = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueryTypesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String description,
    required int times,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        description = Value(description),
        times = Value(times),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<QueryType> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? times,
    Expression<bool>? isCustomized,
    Expression<bool>? isAvailable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (times != null) 'times': times,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueryTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? name,
      Value<String>? description,
      Value<int>? times,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return QueryTypesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      times: times ?? this.times,
      isCustomized: isCustomized ?? this.isCustomized,
      isAvailable: isAvailable ?? this.isAvailable,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (times.present) {
      map['times'] = Variable<int>(times.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueryTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('times: $times, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuerySubQueryTypeMapperTable extends QuerySubQueryTypeMapper
    with TableInfo<$QuerySubQueryTypeMapperTable, QuerySubQueryTypeMapperData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuerySubQueryTypeMapperTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _queryUuidMeta =
      const VerificationMeta('queryUuid');
  @override
  late final GeneratedColumn<String> queryUuid = GeneratedColumn<String>(
      'query_type_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subTypeUuidMeta =
      const VerificationMeta('subTypeUuid');
  @override
  late final GeneratedColumn<String> subTypeUuid = GeneratedColumn<String>(
      'sub_type_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, queryUuid, subTypeUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'query_sub_query_type_mapper';
  @override
  VerificationContext validateIntegrity(
      Insertable<QuerySubQueryTypeMapperData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query_type_uuid')) {
      context.handle(
          _queryUuidMeta,
          queryUuid.isAcceptableOrUnknown(
              data['query_type_uuid']!, _queryUuidMeta));
    } else if (isInserting) {
      context.missing(_queryUuidMeta);
    }
    if (data.containsKey('sub_type_uuid')) {
      context.handle(
          _subTypeUuidMeta,
          subTypeUuid.isAcceptableOrUnknown(
              data['sub_type_uuid']!, _subTypeUuidMeta));
    } else if (isInserting) {
      context.missing(_subTypeUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuerySubQueryTypeMapperData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuerySubQueryTypeMapperData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      queryUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}query_type_uuid'])!,
      subTypeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_type_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $QuerySubQueryTypeMapperTable createAlias(String alias) {
    return $QuerySubQueryTypeMapperTable(attachedDatabase, alias);
  }
}

class QuerySubQueryTypeMapperData extends DataClass
    implements Insertable<QuerySubQueryTypeMapperData> {
  final int id;
  final String queryUuid;
  final String subTypeUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const QuerySubQueryTypeMapperData(
      {required this.id,
      required this.queryUuid,
      required this.subTypeUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query_type_uuid'] = Variable<String>(queryUuid);
    map['sub_type_uuid'] = Variable<String>(subTypeUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  QuerySubQueryTypeMapperCompanion toCompanion(bool nullToAbsent) {
    return QuerySubQueryTypeMapperCompanion(
      id: Value(id),
      queryUuid: Value(queryUuid),
      subTypeUuid: Value(subTypeUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory QuerySubQueryTypeMapperData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuerySubQueryTypeMapperData(
      id: serializer.fromJson<int>(json['id']),
      queryUuid: serializer.fromJson<String>(json['queryUuid']),
      subTypeUuid: serializer.fromJson<String>(json['subTypeUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queryUuid': serializer.toJson<String>(queryUuid),
      'subTypeUuid': serializer.toJson<String>(subTypeUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  QuerySubQueryTypeMapperData copyWith(
          {int? id,
          String? queryUuid,
          String? subTypeUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      QuerySubQueryTypeMapperData(
        id: id ?? this.id,
        queryUuid: queryUuid ?? this.queryUuid,
        subTypeUuid: subTypeUuid ?? this.subTypeUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  QuerySubQueryTypeMapperData copyWithCompanion(
      QuerySubQueryTypeMapperCompanion data) {
    return QuerySubQueryTypeMapperData(
      id: data.id.present ? data.id.value : this.id,
      queryUuid: data.queryUuid.present ? data.queryUuid.value : this.queryUuid,
      subTypeUuid:
          data.subTypeUuid.present ? data.subTypeUuid.value : this.subTypeUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuerySubQueryTypeMapperData(')
          ..write('id: $id, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, queryUuid, subTypeUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuerySubQueryTypeMapperData &&
          other.id == this.id &&
          other.queryUuid == this.queryUuid &&
          other.subTypeUuid == this.subTypeUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class QuerySubQueryTypeMapperCompanion
    extends UpdateCompanion<QuerySubQueryTypeMapperData> {
  final Value<int> id;
  final Value<String> queryUuid;
  final Value<String> subTypeUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const QuerySubQueryTypeMapperCompanion({
    this.id = const Value.absent(),
    this.queryUuid = const Value.absent(),
    this.subTypeUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  QuerySubQueryTypeMapperCompanion.insert({
    this.id = const Value.absent(),
    required String queryUuid,
    required String subTypeUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : queryUuid = Value(queryUuid),
        subTypeUuid = Value(subTypeUuid),
        createdAt = Value(createdAt);
  static Insertable<QuerySubQueryTypeMapperData> custom({
    Expression<int>? id,
    Expression<String>? queryUuid,
    Expression<String>? subTypeUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queryUuid != null) 'query_type_uuid': queryUuid,
      if (subTypeUuid != null) 'sub_type_uuid': subTypeUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  QuerySubQueryTypeMapperCompanion copyWith(
      {Value<int>? id,
      Value<String>? queryUuid,
      Value<String>? subTypeUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return QuerySubQueryTypeMapperCompanion(
      id: id ?? this.id,
      queryUuid: queryUuid ?? this.queryUuid,
      subTypeUuid: subTypeUuid ?? this.subTypeUuid,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queryUuid.present) {
      map['query_type_uuid'] = Variable<String>(queryUuid.value);
    }
    if (subTypeUuid.present) {
      map['sub_type_uuid'] = Variable<String>(subTypeUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuerySubQueryTypeMapperCompanion(')
          ..write('id: $id, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QueriesTable queries = $QueriesTable(this);
  late final $SkillsTable skills = $SkillsTable(this);
  late final $CombinedQueriesTable combinedQueries =
      $CombinedQueriesTable(this);
  late final $QueryDatetimeTable queryDatetime = $QueryDatetimeTable(this);
  late final $SeekersTable seekers = $SeekersTable(this);
  late final $SubQueryTypesTable subQueryTypes = $SubQueryTypesTable(this);
  late final $QueryTypesTable queryTypes = $QueryTypesTable(this);
  late final $QuerySubQueryTypeMapperTable querySubQueryTypeMapper =
      $QuerySubQueryTypeMapperTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        queries,
        skills,
        combinedQueries,
        queryDatetime,
        seekers,
        subQueryTypes,
        queryTypes,
        querySubQueryTypeMapper
      ];
}

typedef $$QueriesTableCreateCompanionBuilder = QueriesCompanion Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String queryTypeUuid,
  Value<String?> yearGanZhi,
  required bool isSeersLocation,
  required String queryQuestion,
  required String queryDescription,
  Value<String?> seekerUuid,
  required String tinySummary,
  required String directlyPredict,
  Value<String?> panelUuid,
  Value<int> rowid,
});
typedef $$QueriesTableUpdateCompanionBuilder = QueriesCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> queryTypeUuid,
  Value<String?> yearGanZhi,
  Value<bool> isSeersLocation,
  Value<String> queryQuestion,
  Value<String> queryDescription,
  Value<String?> seekerUuid,
  Value<String> tinySummary,
  Value<String> directlyPredict,
  Value<String?> panelUuid,
  Value<int> rowid,
});

class $$QueriesTableFilterComposer
    extends Composer<_$AppDatabase, $QueriesTable> {
  $$QueriesTableFilterComposer({
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

  ColumnFilters<String> get queryTypeUuid => $composableBuilder(
      column: $table.queryTypeUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSeersLocation => $composableBuilder(
      column: $table.isSeersLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryQuestion => $composableBuilder(
      column: $table.queryQuestion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryDescription => $composableBuilder(
      column: $table.queryDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tinySummary => $composableBuilder(
      column: $table.tinySummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnFilters(column));
}

class $$QueriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueriesTable> {
  $$QueriesTableOrderingComposer({
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

  ColumnOrderings<String> get queryTypeUuid => $composableBuilder(
      column: $table.queryTypeUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSeersLocation => $composableBuilder(
      column: $table.isSeersLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryQuestion => $composableBuilder(
      column: $table.queryQuestion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryDescription => $composableBuilder(
      column: $table.queryDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tinySummary => $composableBuilder(
      column: $table.tinySummary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelUuid => $composableBuilder(
      column: $table.panelUuid, builder: (column) => ColumnOrderings(column));
}

class $$QueriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueriesTable> {
  $$QueriesTableAnnotationComposer({
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

  GeneratedColumn<String> get queryTypeUuid => $composableBuilder(
      column: $table.queryTypeUuid, builder: (column) => column);

  GeneratedColumn<String> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => column);

  GeneratedColumn<bool> get isSeersLocation => $composableBuilder(
      column: $table.isSeersLocation, builder: (column) => column);

  GeneratedColumn<String> get queryQuestion => $composableBuilder(
      column: $table.queryQuestion, builder: (column) => column);

  GeneratedColumn<String> get queryDescription => $composableBuilder(
      column: $table.queryDescription, builder: (column) => column);

  GeneratedColumn<String> get seekerUuid => $composableBuilder(
      column: $table.seekerUuid, builder: (column) => column);

  GeneratedColumn<String> get tinySummary => $composableBuilder(
      column: $table.tinySummary, builder: (column) => column);

  GeneratedColumn<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict, builder: (column) => column);

  GeneratedColumn<String> get panelUuid =>
      $composableBuilder(column: $table.panelUuid, builder: (column) => column);
}

class $$QueriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueriesTable,
    Query,
    $$QueriesTableFilterComposer,
    $$QueriesTableOrderingComposer,
    $$QueriesTableAnnotationComposer,
    $$QueriesTableCreateCompanionBuilder,
    $$QueriesTableUpdateCompanionBuilder,
    (Query, BaseReferences<_$AppDatabase, $QueriesTable, Query>),
    Query,
    PrefetchHooks Function()> {
  $$QueriesTableTableManager(_$AppDatabase db, $QueriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> queryTypeUuid = const Value.absent(),
            Value<String?> yearGanZhi = const Value.absent(),
            Value<bool> isSeersLocation = const Value.absent(),
            Value<String> queryQuestion = const Value.absent(),
            Value<String> queryDescription = const Value.absent(),
            Value<String?> seekerUuid = const Value.absent(),
            Value<String> tinySummary = const Value.absent(),
            Value<String> directlyPredict = const Value.absent(),
            Value<String?> panelUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueriesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryTypeUuid: queryTypeUuid,
            yearGanZhi: yearGanZhi,
            isSeersLocation: isSeersLocation,
            queryQuestion: queryQuestion,
            queryDescription: queryDescription,
            seekerUuid: seekerUuid,
            tinySummary: tinySummary,
            directlyPredict: directlyPredict,
            panelUuid: panelUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String queryTypeUuid,
            Value<String?> yearGanZhi = const Value.absent(),
            required bool isSeersLocation,
            required String queryQuestion,
            required String queryDescription,
            Value<String?> seekerUuid = const Value.absent(),
            required String tinySummary,
            required String directlyPredict,
            Value<String?> panelUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueriesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryTypeUuid: queryTypeUuid,
            yearGanZhi: yearGanZhi,
            isSeersLocation: isSeersLocation,
            queryQuestion: queryQuestion,
            queryDescription: queryDescription,
            seekerUuid: seekerUuid,
            tinySummary: tinySummary,
            directlyPredict: directlyPredict,
            panelUuid: panelUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueriesTable,
    Query,
    $$QueriesTableFilterComposer,
    $$QueriesTableOrderingComposer,
    $$QueriesTableAnnotationComposer,
    $$QueriesTableCreateCompanionBuilder,
    $$QueriesTableUpdateCompanionBuilder,
    (Query, BaseReferences<_$AppDatabase, $QueriesTable, Query>),
    Query,
    PrefetchHooks Function()>;
typedef $$SkillsTableCreateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required bool isAvailable,
  required String name,
  required String descriptions,
});
typedef $$SkillsTableUpdateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isAvailable,
  Value<String> name,
  Value<String> descriptions,
});

class $$SkillsTableFilterComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptions => $composableBuilder(
      column: $table.descriptions, builder: (column) => ColumnFilters(column));
}

class $$SkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptions => $composableBuilder(
      column: $table.descriptions,
      builder: (column) => ColumnOrderings(column));
}

class $$SkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get descriptions => $composableBuilder(
      column: $table.descriptions, builder: (column) => column);
}

class $$SkillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()> {
  $$SkillsTableTableManager(_$AppDatabase db, $SkillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> descriptions = const Value.absent(),
          }) =>
              SkillsCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            isAvailable: isAvailable,
            name: name,
            descriptions: descriptions,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required bool isAvailable,
            required String name,
            required String descriptions,
          }) =>
              SkillsCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            isAvailable: isAvailable,
            name: name,
            descriptions: descriptions,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()>;
typedef $$CombinedQueriesTableCreateCompanionBuilder = CombinedQueriesCompanion
    Function({
  required String uuid,
  required int order,
  required String queryUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
  required String combinedType,
  Value<int> rowid,
});
typedef $$CombinedQueriesTableUpdateCompanionBuilder = CombinedQueriesCompanion
    Function({
  Value<String> uuid,
  Value<int> order,
  Value<String> queryUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
  Value<String> combinedType,
  Value<int> rowid,
});

class $$CombinedQueriesTableFilterComposer
    extends Composer<_$AppDatabase, $CombinedQueriesTable> {
  $$CombinedQueriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get combinedType => $composableBuilder(
      column: $table.combinedType, builder: (column) => ColumnFilters(column));
}

class $$CombinedQueriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CombinedQueriesTable> {
  $$CombinedQueriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get combinedType => $composableBuilder(
      column: $table.combinedType,
      builder: (column) => ColumnOrderings(column));
}

class $$CombinedQueriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CombinedQueriesTable> {
  $$CombinedQueriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get queryUuid =>
      $composableBuilder(column: $table.queryUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get combinedType => $composableBuilder(
      column: $table.combinedType, builder: (column) => column);
}

class $$CombinedQueriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CombinedQueriesTable,
    CombinedQuery,
    $$CombinedQueriesTableFilterComposer,
    $$CombinedQueriesTableOrderingComposer,
    $$CombinedQueriesTableAnnotationComposer,
    $$CombinedQueriesTableCreateCompanionBuilder,
    $$CombinedQueriesTableUpdateCompanionBuilder,
    (
      CombinedQuery,
      BaseReferences<_$AppDatabase, $CombinedQueriesTable, CombinedQuery>
    ),
    CombinedQuery,
    PrefetchHooks Function()> {
  $$CombinedQueriesTableTableManager(
      _$AppDatabase db, $CombinedQueriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombinedQueriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombinedQueriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombinedQueriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> queryUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> combinedType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedQueriesCompanion(
            uuid: uuid,
            order: order,
            queryUuid: queryUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
            combinedType: combinedType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required int order,
            required String queryUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String combinedType,
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedQueriesCompanion.insert(
            uuid: uuid,
            order: order,
            queryUuid: queryUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
            combinedType: combinedType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CombinedQueriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CombinedQueriesTable,
    CombinedQuery,
    $$CombinedQueriesTableFilterComposer,
    $$CombinedQueriesTableOrderingComposer,
    $$CombinedQueriesTableAnnotationComposer,
    $$CombinedQueriesTableCreateCompanionBuilder,
    $$CombinedQueriesTableUpdateCompanionBuilder,
    (
      CombinedQuery,
      BaseReferences<_$AppDatabase, $CombinedQueriesTable, CombinedQuery>
    ),
    CombinedQuery,
    PrefetchHooks Function()>;
typedef $$QueryDatetimeTableCreateCompanionBuilder = QueryDatetimeCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required EnumDatetimeType type,
  required bool isDst,
  required bool isManual,
  required DateTime datetime,
  required String timezoneStr,
  Value<Location?> location,
  Value<Coordinates?> coordinates,
  Value<int?> hourAdjusted,
  required JiaZi yearJiaZi,
  required JiaZi monthJiaZi,
  required JiaZi dayJiaZi,
  required JiaZi timeJiaZi,
  required String lunarMonth,
  required String lunarDay,
  required JieQiInfo jieQiInfo,
  required String queryUuid,
  Value<int> rowid,
});
typedef $$QueryDatetimeTableUpdateCompanionBuilder = QueryDatetimeCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<EnumDatetimeType> type,
  Value<bool> isDst,
  Value<bool> isManual,
  Value<DateTime> datetime,
  Value<String> timezoneStr,
  Value<Location?> location,
  Value<Coordinates?> coordinates,
  Value<int?> hourAdjusted,
  Value<JiaZi> yearJiaZi,
  Value<JiaZi> monthJiaZi,
  Value<JiaZi> dayJiaZi,
  Value<JiaZi> timeJiaZi,
  Value<String> lunarMonth,
  Value<String> lunarDay,
  Value<JieQiInfo> jieQiInfo,
  Value<String> queryUuid,
  Value<int> rowid,
});

class $$QueryDatetimeTableFilterComposer
    extends Composer<_$AppDatabase, $QueryDatetimeTable> {
  $$QueryDatetimeTableFilterComposer({
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

  ColumnWithTypeConverterFilters<EnumDatetimeType, EnumDatetimeType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isDst => $composableBuilder(
      column: $table.isDst, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezoneStr => $composableBuilder(
      column: $table.timezoneStr, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Location?, Location, String> get location =>
      $composableBuilder(
          column: $table.location,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Coordinates?, Coordinates, String>
      get coordinates => $composableBuilder(
          column: $table.coordinates,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get hourAdjusted => $composableBuilder(
      column: $table.hourAdjusted, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, String> get yearJiaZi =>
      $composableBuilder(
          column: $table.yearJiaZi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, String> get monthJiaZi =>
      $composableBuilder(
          column: $table.monthJiaZi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, String> get dayJiaZi =>
      $composableBuilder(
          column: $table.dayJiaZi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, String> get timeJiaZi =>
      $composableBuilder(
          column: $table.timeJiaZi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JieQiInfo, JieQiInfo, String> get jieQiInfo =>
      $composableBuilder(
          column: $table.jieQiInfo,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnFilters(column));
}

class $$QueryDatetimeTableOrderingComposer
    extends Composer<_$AppDatabase, $QueryDatetimeTable> {
  $$QueryDatetimeTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDst => $composableBuilder(
      column: $table.isDst, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezoneStr => $composableBuilder(
      column: $table.timezoneStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hourAdjusted => $composableBuilder(
      column: $table.hourAdjusted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yearJiaZi => $composableBuilder(
      column: $table.yearJiaZi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthJiaZi => $composableBuilder(
      column: $table.monthJiaZi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayJiaZi => $composableBuilder(
      column: $table.dayJiaZi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeJiaZi => $composableBuilder(
      column: $table.timeJiaZi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jieQiInfo => $composableBuilder(
      column: $table.jieQiInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnOrderings(column));
}

class $$QueryDatetimeTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueryDatetimeTable> {
  $$QueryDatetimeTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<EnumDatetimeType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDst =>
      $composableBuilder(column: $table.isDst, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumn<String> get timezoneStr => $composableBuilder(
      column: $table.timezoneStr, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Location?, String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Coordinates?, String> get coordinates =>
      $composableBuilder(
          column: $table.coordinates, builder: (column) => column);

  GeneratedColumn<int> get hourAdjusted => $composableBuilder(
      column: $table.hourAdjusted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, String> get yearJiaZi =>
      $composableBuilder(column: $table.yearJiaZi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, String> get monthJiaZi =>
      $composableBuilder(
          column: $table.monthJiaZi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, String> get dayJiaZi =>
      $composableBuilder(column: $table.dayJiaZi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, String> get timeJiaZi =>
      $composableBuilder(column: $table.timeJiaZi, builder: (column) => column);

  GeneratedColumn<String> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => column);

  GeneratedColumn<String> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JieQiInfo, String> get jieQiInfo =>
      $composableBuilder(column: $table.jieQiInfo, builder: (column) => column);

  GeneratedColumn<String> get queryUuid =>
      $composableBuilder(column: $table.queryUuid, builder: (column) => column);
}

class $$QueryDatetimeTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueryDatetimeTable,
    QueryDatetimeModel,
    $$QueryDatetimeTableFilterComposer,
    $$QueryDatetimeTableOrderingComposer,
    $$QueryDatetimeTableAnnotationComposer,
    $$QueryDatetimeTableCreateCompanionBuilder,
    $$QueryDatetimeTableUpdateCompanionBuilder,
    (
      QueryDatetimeModel,
      BaseReferences<_$AppDatabase, $QueryDatetimeTable, QueryDatetimeModel>
    ),
    QueryDatetimeModel,
    PrefetchHooks Function()> {
  $$QueryDatetimeTableTableManager(_$AppDatabase db, $QueryDatetimeTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueryDatetimeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueryDatetimeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueryDatetimeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<EnumDatetimeType> type = const Value.absent(),
            Value<bool> isDst = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<DateTime> datetime = const Value.absent(),
            Value<String> timezoneStr = const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<Coordinates?> coordinates = const Value.absent(),
            Value<int?> hourAdjusted = const Value.absent(),
            Value<JiaZi> yearJiaZi = const Value.absent(),
            Value<JiaZi> monthJiaZi = const Value.absent(),
            Value<JiaZi> dayJiaZi = const Value.absent(),
            Value<JiaZi> timeJiaZi = const Value.absent(),
            Value<String> lunarMonth = const Value.absent(),
            Value<String> lunarDay = const Value.absent(),
            Value<JieQiInfo> jieQiInfo = const Value.absent(),
            Value<String> queryUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueryDatetimeCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            type: type,
            isDst: isDst,
            isManual: isManual,
            datetime: datetime,
            timezoneStr: timezoneStr,
            location: location,
            coordinates: coordinates,
            hourAdjusted: hourAdjusted,
            yearJiaZi: yearJiaZi,
            monthJiaZi: monthJiaZi,
            dayJiaZi: dayJiaZi,
            timeJiaZi: timeJiaZi,
            lunarMonth: lunarMonth,
            lunarDay: lunarDay,
            jieQiInfo: jieQiInfo,
            queryUuid: queryUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required EnumDatetimeType type,
            required bool isDst,
            required bool isManual,
            required DateTime datetime,
            required String timezoneStr,
            Value<Location?> location = const Value.absent(),
            Value<Coordinates?> coordinates = const Value.absent(),
            Value<int?> hourAdjusted = const Value.absent(),
            required JiaZi yearJiaZi,
            required JiaZi monthJiaZi,
            required JiaZi dayJiaZi,
            required JiaZi timeJiaZi,
            required String lunarMonth,
            required String lunarDay,
            required JieQiInfo jieQiInfo,
            required String queryUuid,
            Value<int> rowid = const Value.absent(),
          }) =>
              QueryDatetimeCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            type: type,
            isDst: isDst,
            isManual: isManual,
            datetime: datetime,
            timezoneStr: timezoneStr,
            location: location,
            coordinates: coordinates,
            hourAdjusted: hourAdjusted,
            yearJiaZi: yearJiaZi,
            monthJiaZi: monthJiaZi,
            dayJiaZi: dayJiaZi,
            timeJiaZi: timeJiaZi,
            lunarMonth: lunarMonth,
            lunarDay: lunarDay,
            jieQiInfo: jieQiInfo,
            queryUuid: queryUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueryDatetimeTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueryDatetimeTable,
    QueryDatetimeModel,
    $$QueryDatetimeTableFilterComposer,
    $$QueryDatetimeTableOrderingComposer,
    $$QueryDatetimeTableAnnotationComposer,
    $$QueryDatetimeTableCreateCompanionBuilder,
    $$QueryDatetimeTableUpdateCompanionBuilder,
    (
      QueryDatetimeModel,
      BaseReferences<_$AppDatabase, $QueryDatetimeTable, QueryDatetimeModel>
    ),
    QueryDatetimeModel,
    PrefetchHooks Function()>;
typedef $$SeekersTableCreateCompanionBuilder = SeekersCompanion Function({
  required String uuid,
  required String username,
  required String nickname,
  required DateTime createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required DateTime birthDatetime,
  required String eightChars,
  required String birthLocation,
  required double birthLng,
  required double birthLat,
  required String currentLocation,
  required double currentLng,
  required double currentLat,
  Value<int> rowid,
});
typedef $$SeekersTableUpdateCompanionBuilder = SeekersCompanion Function({
  Value<String> uuid,
  Value<String> username,
  Value<String> nickname,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime> birthDatetime,
  Value<String> eightChars,
  Value<String> birthLocation,
  Value<double> birthLng,
  Value<double> birthLat,
  Value<String> currentLocation,
  Value<double> currentLng,
  Value<double> currentLat,
  Value<int> rowid,
});

class $$SeekersTableFilterComposer
    extends Composer<_$AppDatabase, $SeekersTable> {
  $$SeekersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDatetime => $composableBuilder(
      column: $table.birthDatetime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eightChars => $composableBuilder(
      column: $table.eightChars, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthLocation => $composableBuilder(
      column: $table.birthLocation, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthLng => $composableBuilder(
      column: $table.birthLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthLat => $composableBuilder(
      column: $table.birthLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentLocation => $composableBuilder(
      column: $table.currentLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentLng => $composableBuilder(
      column: $table.currentLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentLat => $composableBuilder(
      column: $table.currentLat, builder: (column) => ColumnFilters(column));
}

class $$SeekersTableOrderingComposer
    extends Composer<_$AppDatabase, $SeekersTable> {
  $$SeekersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDatetime => $composableBuilder(
      column: $table.birthDatetime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eightChars => $composableBuilder(
      column: $table.eightChars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthLocation => $composableBuilder(
      column: $table.birthLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthLng => $composableBuilder(
      column: $table.birthLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthLat => $composableBuilder(
      column: $table.birthLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentLocation => $composableBuilder(
      column: $table.currentLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentLng => $composableBuilder(
      column: $table.currentLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentLat => $composableBuilder(
      column: $table.currentLat, builder: (column) => ColumnOrderings(column));
}

class $$SeekersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeekersTable> {
  $$SeekersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDatetime => $composableBuilder(
      column: $table.birthDatetime, builder: (column) => column);

  GeneratedColumn<String> get eightChars => $composableBuilder(
      column: $table.eightChars, builder: (column) => column);

  GeneratedColumn<String> get birthLocation => $composableBuilder(
      column: $table.birthLocation, builder: (column) => column);

  GeneratedColumn<double> get birthLng =>
      $composableBuilder(column: $table.birthLng, builder: (column) => column);

  GeneratedColumn<double> get birthLat =>
      $composableBuilder(column: $table.birthLat, builder: (column) => column);

  GeneratedColumn<String> get currentLocation => $composableBuilder(
      column: $table.currentLocation, builder: (column) => column);

  GeneratedColumn<double> get currentLng => $composableBuilder(
      column: $table.currentLng, builder: (column) => column);

  GeneratedColumn<double> get currentLat => $composableBuilder(
      column: $table.currentLat, builder: (column) => column);
}

class $$SeekersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeekersTable,
    Seeker,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (Seeker, BaseReferences<_$AppDatabase, $SeekersTable, Seeker>),
    Seeker,
    PrefetchHooks Function()> {
  $$SeekersTableTableManager(_$AppDatabase db, $SeekersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeekersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeekersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeekersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime> birthDatetime = const Value.absent(),
            Value<String> eightChars = const Value.absent(),
            Value<String> birthLocation = const Value.absent(),
            Value<double> birthLng = const Value.absent(),
            Value<double> birthLat = const Value.absent(),
            Value<String> currentLocation = const Value.absent(),
            Value<double> currentLng = const Value.absent(),
            Value<double> currentLat = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion(
            uuid: uuid,
            username: username,
            nickname: nickname,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            birthDatetime: birthDatetime,
            eightChars: eightChars,
            birthLocation: birthLocation,
            birthLng: birthLng,
            birthLat: birthLat,
            currentLocation: currentLocation,
            currentLng: currentLng,
            currentLat: currentLat,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String username,
            required String nickname,
            required DateTime createdAt,
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTime birthDatetime,
            required String eightChars,
            required String birthLocation,
            required double birthLng,
            required double birthLat,
            required String currentLocation,
            required double currentLng,
            required double currentLat,
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion.insert(
            uuid: uuid,
            username: username,
            nickname: nickname,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            birthDatetime: birthDatetime,
            eightChars: eightChars,
            birthLocation: birthLocation,
            birthLng: birthLng,
            birthLat: birthLat,
            currentLocation: currentLocation,
            currentLng: currentLng,
            currentLat: currentLat,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SeekersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SeekersTable,
    Seeker,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (Seeker, BaseReferences<_$AppDatabase, $SeekersTable, Seeker>),
    Seeker,
    PrefetchHooks Function()>;
typedef $$SubQueryTypesTableCreateCompanionBuilder = SubQueryTypesCompanion
    Function({
  required String uuid,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  required String name,
  required int times,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$SubQueryTypesTableUpdateCompanionBuilder = SubQueryTypesCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  Value<String> name,
  Value<int> times,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

class $$SubQueryTypesTableFilterComposer
    extends Composer<_$AppDatabase, $SubQueryTypesTable> {
  $$SubQueryTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get hiddenAt => $composableBuilder(
      column: $table.hiddenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get times => $composableBuilder(
      column: $table.times, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));
}

class $$SubQueryTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubQueryTypesTable> {
  $$SubQueryTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get hiddenAt => $composableBuilder(
      column: $table.hiddenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get times => $composableBuilder(
      column: $table.times, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$SubQueryTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubQueryTypesTable> {
  $$SubQueryTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get hiddenAt =>
      $composableBuilder(column: $table.hiddenAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);
}

class $$SubQueryTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubQueryTypesTable,
    SubQueryType,
    $$SubQueryTypesTableFilterComposer,
    $$SubQueryTypesTableOrderingComposer,
    $$SubQueryTypesTableAnnotationComposer,
    $$SubQueryTypesTableCreateCompanionBuilder,
    $$SubQueryTypesTableUpdateCompanionBuilder,
    (
      SubQueryType,
      BaseReferences<_$AppDatabase, $SubQueryTypesTable, SubQueryType>
    ),
    SubQueryType,
    PrefetchHooks Function()> {
  $$SubQueryTypesTableTableManager(_$AppDatabase db, $SubQueryTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubQueryTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubQueryTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubQueryTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> hiddenAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> times = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubQueryTypesCompanion(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
            times: times,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> hiddenAt = const Value.absent(),
            required String name,
            required int times,
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubQueryTypesCompanion.insert(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
            times: times,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubQueryTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubQueryTypesTable,
    SubQueryType,
    $$SubQueryTypesTableFilterComposer,
    $$SubQueryTypesTableOrderingComposer,
    $$SubQueryTypesTableAnnotationComposer,
    $$SubQueryTypesTableCreateCompanionBuilder,
    $$SubQueryTypesTableUpdateCompanionBuilder,
    (
      SubQueryType,
      BaseReferences<_$AppDatabase, $SubQueryTypesTable, SubQueryType>
    ),
    SubQueryType,
    PrefetchHooks Function()>;
typedef $$QueryTypesTableCreateCompanionBuilder = QueryTypesCompanion Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  required String description,
  required int times,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$QueryTypesTableUpdateCompanionBuilder = QueryTypesCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<String> description,
  Value<int> times,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

class $$QueryTypesTableFilterComposer
    extends Composer<_$AppDatabase, $QueryTypesTable> {
  $$QueryTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get times => $composableBuilder(
      column: $table.times, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));
}

class $$QueryTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueryTypesTable> {
  $$QueryTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get times => $composableBuilder(
      column: $table.times, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$QueryTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueryTypesTable> {
  $$QueryTypesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);
}

class $$QueryTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueryTypesTable,
    QueryType,
    $$QueryTypesTableFilterComposer,
    $$QueryTypesTableOrderingComposer,
    $$QueryTypesTableAnnotationComposer,
    $$QueryTypesTableCreateCompanionBuilder,
    $$QueryTypesTableUpdateCompanionBuilder,
    (QueryType, BaseReferences<_$AppDatabase, $QueryTypesTable, QueryType>),
    QueryType,
    PrefetchHooks Function()> {
  $$QueryTypesTableTableManager(_$AppDatabase db, $QueryTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueryTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueryTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueryTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> times = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueryTypesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
            times: times,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String name,
            required String description,
            required int times,
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              QueryTypesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
            times: times,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueryTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueryTypesTable,
    QueryType,
    $$QueryTypesTableFilterComposer,
    $$QueryTypesTableOrderingComposer,
    $$QueryTypesTableAnnotationComposer,
    $$QueryTypesTableCreateCompanionBuilder,
    $$QueryTypesTableUpdateCompanionBuilder,
    (QueryType, BaseReferences<_$AppDatabase, $QueryTypesTable, QueryType>),
    QueryType,
    PrefetchHooks Function()>;
typedef $$QuerySubQueryTypeMapperTableCreateCompanionBuilder
    = QuerySubQueryTypeMapperCompanion Function({
  Value<int> id,
  required String queryUuid,
  required String subTypeUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$QuerySubQueryTypeMapperTableUpdateCompanionBuilder
    = QuerySubQueryTypeMapperCompanion Function({
  Value<int> id,
  Value<String> queryUuid,
  Value<String> subTypeUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

class $$QuerySubQueryTypeMapperTableFilterComposer
    extends Composer<_$AppDatabase, $QuerySubQueryTypeMapperTable> {
  $$QuerySubQueryTypeMapperTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subTypeUuid => $composableBuilder(
      column: $table.subTypeUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$QuerySubQueryTypeMapperTableOrderingComposer
    extends Composer<_$AppDatabase, $QuerySubQueryTypeMapperTable> {
  $$QuerySubQueryTypeMapperTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subTypeUuid => $composableBuilder(
      column: $table.subTypeUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$QuerySubQueryTypeMapperTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuerySubQueryTypeMapperTable> {
  $$QuerySubQueryTypeMapperTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queryUuid =>
      $composableBuilder(column: $table.queryUuid, builder: (column) => column);

  GeneratedColumn<String> get subTypeUuid => $composableBuilder(
      column: $table.subTypeUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$QuerySubQueryTypeMapperTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuerySubQueryTypeMapperTable,
    QuerySubQueryTypeMapperData,
    $$QuerySubQueryTypeMapperTableFilterComposer,
    $$QuerySubQueryTypeMapperTableOrderingComposer,
    $$QuerySubQueryTypeMapperTableAnnotationComposer,
    $$QuerySubQueryTypeMapperTableCreateCompanionBuilder,
    $$QuerySubQueryTypeMapperTableUpdateCompanionBuilder,
    (
      QuerySubQueryTypeMapperData,
      BaseReferences<_$AppDatabase, $QuerySubQueryTypeMapperTable,
          QuerySubQueryTypeMapperData>
    ),
    QuerySubQueryTypeMapperData,
    PrefetchHooks Function()> {
  $$QuerySubQueryTypeMapperTableTableManager(
      _$AppDatabase db, $QuerySubQueryTypeMapperTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuerySubQueryTypeMapperTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$QuerySubQueryTypeMapperTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuerySubQueryTypeMapperTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> queryUuid = const Value.absent(),
            Value<String> subTypeUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              QuerySubQueryTypeMapperCompanion(
            id: id,
            queryUuid: queryUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String queryUuid,
            required String subTypeUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              QuerySubQueryTypeMapperCompanion.insert(
            id: id,
            queryUuid: queryUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuerySubQueryTypeMapperTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $QuerySubQueryTypeMapperTable,
        QuerySubQueryTypeMapperData,
        $$QuerySubQueryTypeMapperTableFilterComposer,
        $$QuerySubQueryTypeMapperTableOrderingComposer,
        $$QuerySubQueryTypeMapperTableAnnotationComposer,
        $$QuerySubQueryTypeMapperTableCreateCompanionBuilder,
        $$QuerySubQueryTypeMapperTableUpdateCompanionBuilder,
        (
          QuerySubQueryTypeMapperData,
          BaseReferences<_$AppDatabase, $QuerySubQueryTypeMapperTable,
              QuerySubQueryTypeMapperData>
        ),
        QuerySubQueryTypeMapperData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QueriesTableTableManager get queries =>
      $$QueriesTableTableManager(_db, _db.queries);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db, _db.skills);
  $$CombinedQueriesTableTableManager get combinedQueries =>
      $$CombinedQueriesTableTableManager(_db, _db.combinedQueries);
  $$QueryDatetimeTableTableManager get queryDatetime =>
      $$QueryDatetimeTableTableManager(_db, _db.queryDatetime);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db, _db.seekers);
  $$SubQueryTypesTableTableManager get subQueryTypes =>
      $$SubQueryTypesTableTableManager(_db, _db.subQueryTypes);
  $$QueryTypesTableTableManager get queryTypes =>
      $$QueryTypesTableTableManager(_db, _db.queryTypes);
  $$QuerySubQueryTypeMapperTableTableManager get querySubQueryTypeMapper =>
      $$QuerySubQueryTypeMapperTableTableManager(
          _db, _db.querySubQueryTypeMapper);
}
