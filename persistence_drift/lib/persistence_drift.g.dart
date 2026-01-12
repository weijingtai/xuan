// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistence_drift.dart';

// ignore_for_file: type=lint
mixin _$OutboxRecordsDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $OutboxRecordsTable get outboxRecords => attachedDatabase.outboxRecords;
}
mixin _$SyncStatesDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $SyncStatesTable get syncStates => attachedDatabase.syncStates;
}

class $OutboxRecordsTable extends OutboxRecords
    with TableInfo<$OutboxRecordsTable, OutboxRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta =
      const VerificationMeta('operationId');
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
      'operation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
      'op_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadSummaryMeta =
      const VerificationMeta('payloadSummary');
  @override
  late final GeneratedColumn<String> payloadSummary = GeneratedColumn<String>(
      'payload_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadHashMeta =
      const VerificationMeta('payloadHash');
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
      'payload_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptMeta =
      const VerificationMeta('attempt');
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
      'attempt', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _lastErrorCodeMeta =
      const VerificationMeta('lastErrorCode');
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
      'last_error_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMessageMeta =
      const VerificationMeta('lastErrorMessage');
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
      'last_error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastAttemptAtUtcMeta =
      const VerificationMeta('lastAttemptAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAtUtc =
      GeneratedColumn<DateTime>('last_attempt_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _succeededAtUtcMeta =
      const VerificationMeta('succeededAtUtc');
  @override
  late final GeneratedColumn<DateTime> succeededAtUtc =
      GeneratedColumn<DateTime>('succeeded_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        operationId,
        scopeUid,
        entityType,
        entityId,
        opType,
        payloadJson,
        payloadSummary,
        payloadHash,
        createdAtUtc,
        attempt,
        status,
        lastErrorCode,
        lastErrorMessage,
        lastAttemptAtUtc,
        succeededAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
          _operationIdMeta,
          operationId.isAcceptableOrUnknown(
              data['operation_id']!, _operationIdMeta));
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(_opTypeMeta,
          opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta));
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('payload_summary')) {
      context.handle(
          _payloadSummaryMeta,
          payloadSummary.isAcceptableOrUnknown(
              data['payload_summary']!, _payloadSummaryMeta));
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
          _payloadHashMeta,
          payloadHash.isAcceptableOrUnknown(
              data['payload_hash']!, _payloadHashMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(_attemptMeta,
          attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
          _lastErrorCodeMeta,
          lastErrorCode.isAcceptableOrUnknown(
              data['last_error_code']!, _lastErrorCodeMeta));
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
          _lastErrorMessageMeta,
          lastErrorMessage.isAcceptableOrUnknown(
              data['last_error_message']!, _lastErrorMessageMeta));
    }
    if (data.containsKey('last_attempt_at_utc')) {
      context.handle(
          _lastAttemptAtUtcMeta,
          lastAttemptAtUtc.isAcceptableOrUnknown(
              data['last_attempt_at_utc']!, _lastAttemptAtUtcMeta));
    }
    if (data.containsKey('succeeded_at_utc')) {
      context.handle(
          _succeededAtUtcMeta,
          succeededAtUtc.isAcceptableOrUnknown(
              data['succeeded_at_utc']!, _succeededAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OutboxRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRecordRow(
      operationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_id'])!,
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      opType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      payloadSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_summary']),
      payloadHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_hash']),
      createdAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}created_at_utc'])!,
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastErrorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error_code']),
      lastErrorMessage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_error_message']),
      lastAttemptAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at_utc']),
      succeededAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}succeeded_at_utc']),
    );
  }

  @override
  $OutboxRecordsTable createAlias(String alias) {
    return $OutboxRecordsTable(attachedDatabase, alias);
  }
}

class OutboxRecordRow extends DataClass implements Insertable<OutboxRecordRow> {
  final String operationId;
  final String scopeUid;
  final String entityType;
  final String entityId;
  final String opType;
  final String payloadJson;
  final String? payloadSummary;
  final String? payloadHash;
  final DateTime createdAtUtc;
  final int attempt;
  final String status;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final DateTime? lastAttemptAtUtc;
  final DateTime? succeededAtUtc;
  const OutboxRecordRow(
      {required this.operationId,
      required this.scopeUid,
      required this.entityType,
      required this.entityId,
      required this.opType,
      required this.payloadJson,
      this.payloadSummary,
      this.payloadHash,
      required this.createdAtUtc,
      required this.attempt,
      required this.status,
      this.lastErrorCode,
      this.lastErrorMessage,
      this.lastAttemptAtUtc,
      this.succeededAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['scope_uid'] = Variable<String>(scopeUid);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || payloadSummary != null) {
      map['payload_summary'] = Variable<String>(payloadSummary);
    }
    if (!nullToAbsent || payloadHash != null) {
      map['payload_hash'] = Variable<String>(payloadHash);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['attempt'] = Variable<int>(attempt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    if (!nullToAbsent || lastAttemptAtUtc != null) {
      map['last_attempt_at_utc'] = Variable<DateTime>(lastAttemptAtUtc);
    }
    if (!nullToAbsent || succeededAtUtc != null) {
      map['succeeded_at_utc'] = Variable<DateTime>(succeededAtUtc);
    }
    return map;
  }

  OutboxRecordsCompanion toCompanion(bool nullToAbsent) {
    return OutboxRecordsCompanion(
      operationId: Value(operationId),
      scopeUid: Value(scopeUid),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      payloadJson: Value(payloadJson),
      payloadSummary: payloadSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadSummary),
      payloadHash: payloadHash == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadHash),
      createdAtUtc: Value(createdAtUtc),
      attempt: Value(attempt),
      status: Value(status),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      lastAttemptAtUtc: lastAttemptAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAtUtc),
      succeededAtUtc: succeededAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(succeededAtUtc),
    );
  }

  factory OutboxRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRecordRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      payloadSummary: serializer.fromJson<String?>(json['payloadSummary']),
      payloadHash: serializer.fromJson<String?>(json['payloadHash']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      attempt: serializer.fromJson<int>(json['attempt']),
      status: serializer.fromJson<String>(json['status']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      lastAttemptAtUtc:
          serializer.fromJson<DateTime?>(json['lastAttemptAtUtc']),
      succeededAtUtc: serializer.fromJson<DateTime?>(json['succeededAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'scopeUid': serializer.toJson<String>(scopeUid),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'payloadSummary': serializer.toJson<String?>(payloadSummary),
      'payloadHash': serializer.toJson<String?>(payloadHash),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'attempt': serializer.toJson<int>(attempt),
      'status': serializer.toJson<String>(status),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'lastAttemptAtUtc': serializer.toJson<DateTime?>(lastAttemptAtUtc),
      'succeededAtUtc': serializer.toJson<DateTime?>(succeededAtUtc),
    };
  }

  OutboxRecordRow copyWith(
          {String? operationId,
          String? scopeUid,
          String? entityType,
          String? entityId,
          String? opType,
          String? payloadJson,
          Value<String?> payloadSummary = const Value.absent(),
          Value<String?> payloadHash = const Value.absent(),
          DateTime? createdAtUtc,
          int? attempt,
          String? status,
          Value<String?> lastErrorCode = const Value.absent(),
          Value<String?> lastErrorMessage = const Value.absent(),
          Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
          Value<DateTime?> succeededAtUtc = const Value.absent()}) =>
      OutboxRecordRow(
        operationId: operationId ?? this.operationId,
        scopeUid: scopeUid ?? this.scopeUid,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        opType: opType ?? this.opType,
        payloadJson: payloadJson ?? this.payloadJson,
        payloadSummary:
            payloadSummary.present ? payloadSummary.value : this.payloadSummary,
        payloadHash: payloadHash.present ? payloadHash.value : this.payloadHash,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
        attempt: attempt ?? this.attempt,
        status: status ?? this.status,
        lastErrorCode:
            lastErrorCode.present ? lastErrorCode.value : this.lastErrorCode,
        lastErrorMessage: lastErrorMessage.present
            ? lastErrorMessage.value
            : this.lastErrorMessage,
        lastAttemptAtUtc: lastAttemptAtUtc.present
            ? lastAttemptAtUtc.value
            : this.lastAttemptAtUtc,
        succeededAtUtc:
            succeededAtUtc.present ? succeededAtUtc.value : this.succeededAtUtc,
      );
  OutboxRecordRow copyWithCompanion(OutboxRecordsCompanion data) {
    return OutboxRecordRow(
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      payloadSummary: data.payloadSummary.present
          ? data.payloadSummary.value
          : this.payloadSummary,
      payloadHash:
          data.payloadHash.present ? data.payloadHash.value : this.payloadHash,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      status: data.status.present ? data.status.value : this.status,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      lastAttemptAtUtc: data.lastAttemptAtUtc.present
          ? data.lastAttemptAtUtc.value
          : this.lastAttemptAtUtc,
      succeededAtUtc: data.succeededAtUtc.present
          ? data.succeededAtUtc.value
          : this.succeededAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecordRow(')
          ..write('operationId: $operationId, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadSummary: $payloadSummary, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('succeededAtUtc: $succeededAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      operationId,
      scopeUid,
      entityType,
      entityId,
      opType,
      payloadJson,
      payloadSummary,
      payloadHash,
      createdAtUtc,
      attempt,
      status,
      lastErrorCode,
      lastErrorMessage,
      lastAttemptAtUtc,
      succeededAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRecordRow &&
          other.operationId == this.operationId &&
          other.scopeUid == this.scopeUid &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.payloadJson == this.payloadJson &&
          other.payloadSummary == this.payloadSummary &&
          other.payloadHash == this.payloadHash &&
          other.createdAtUtc == this.createdAtUtc &&
          other.attempt == this.attempt &&
          other.status == this.status &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.lastAttemptAtUtc == this.lastAttemptAtUtc &&
          other.succeededAtUtc == this.succeededAtUtc);
}

class OutboxRecordsCompanion extends UpdateCompanion<OutboxRecordRow> {
  final Value<String> operationId;
  final Value<String> scopeUid;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<String> payloadJson;
  final Value<String?> payloadSummary;
  final Value<String?> payloadHash;
  final Value<DateTime> createdAtUtc;
  final Value<int> attempt;
  final Value<String> status;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<DateTime?> lastAttemptAtUtc;
  final Value<DateTime?> succeededAtUtc;
  final Value<int> rowid;
  const OutboxRecordsCompanion({
    this.operationId = const Value.absent(),
    this.scopeUid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.payloadSummary = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.succeededAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxRecordsCompanion.insert({
    required String operationId,
    required String scopeUid,
    required String entityType,
    required String entityId,
    required String opType,
    required String payloadJson,
    this.payloadSummary = const Value.absent(),
    this.payloadHash = const Value.absent(),
    required DateTime createdAtUtc,
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtUtc = const Value.absent(),
    this.succeededAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : operationId = Value(operationId),
        scopeUid = Value(scopeUid),
        entityType = Value(entityType),
        entityId = Value(entityId),
        opType = Value(opType),
        payloadJson = Value(payloadJson),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<OutboxRecordRow> custom({
    Expression<String>? operationId,
    Expression<String>? scopeUid,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<String>? payloadJson,
    Expression<String>? payloadSummary,
    Expression<String>? payloadHash,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? attempt,
    Expression<String>? status,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<DateTime>? lastAttemptAtUtc,
    Expression<DateTime>? succeededAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (payloadSummary != null) 'payload_summary': payloadSummary,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (attempt != null) 'attempt': attempt,
      if (status != null) 'status': status,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (lastAttemptAtUtc != null) 'last_attempt_at_utc': lastAttemptAtUtc,
      if (succeededAtUtc != null) 'succeeded_at_utc': succeededAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxRecordsCompanion copyWith(
      {Value<String>? operationId,
      Value<String>? scopeUid,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? opType,
      Value<String>? payloadJson,
      Value<String?>? payloadSummary,
      Value<String?>? payloadHash,
      Value<DateTime>? createdAtUtc,
      Value<int>? attempt,
      Value<String>? status,
      Value<String?>? lastErrorCode,
      Value<String?>? lastErrorMessage,
      Value<DateTime?>? lastAttemptAtUtc,
      Value<DateTime?>? succeededAtUtc,
      Value<int>? rowid}) {
    return OutboxRecordsCompanion(
      operationId: operationId ?? this.operationId,
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      payloadSummary: payloadSummary ?? this.payloadSummary,
      payloadHash: payloadHash ?? this.payloadHash,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      attempt: attempt ?? this.attempt,
      status: status ?? this.status,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      lastAttemptAtUtc: lastAttemptAtUtc ?? this.lastAttemptAtUtc,
      succeededAtUtc: succeededAtUtc ?? this.succeededAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (payloadSummary.present) {
      map['payload_summary'] = Variable<String>(payloadSummary.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (lastAttemptAtUtc.present) {
      map['last_attempt_at_utc'] = Variable<DateTime>(lastAttemptAtUtc.value);
    }
    if (succeededAtUtc.present) {
      map['succeeded_at_utc'] = Variable<DateTime>(succeededAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecordsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadSummary: $payloadSummary, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtUtc: $lastAttemptAtUtc, ')
          ..write('succeededAtUtc: $succeededAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeUidMeta =
      const VerificationMeta('scopeUid');
  @override
  late final GeneratedColumn<String> scopeUid = GeneratedColumn<String>(
      'scope_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorTypeMeta =
      const VerificationMeta('cursorType');
  @override
  late final GeneratedColumn<String> cursorType = GeneratedColumn<String>(
      'cursor_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtUtcMeta =
      const VerificationMeta('serverUpdatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAtUtc =
      GeneratedColumn<DateTime>('server_updated_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tieBreakerMeta =
      const VerificationMeta('tieBreaker');
  @override
  late final GeneratedColumn<String> tieBreaker = GeneratedColumn<String>(
      'tie_breaker', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cursorUpdatedAtUtcMeta =
      const VerificationMeta('cursorUpdatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> cursorUpdatedAtUtc =
      GeneratedColumn<DateTime>('cursor_updated_at_utc', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastPulledAtUtcMeta =
      const VerificationMeta('lastPulledAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastPulledAtUtc =
      GeneratedColumn<DateTime>('last_pulled_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastPushedAtUtcMeta =
      const VerificationMeta('lastPushedAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastPushedAtUtc =
      GeneratedColumn<DateTime>('last_pushed_at_utc', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        scopeUid,
        entityType,
        cursorType,
        revision,
        serverUpdatedAtUtc,
        tieBreaker,
        cursorUpdatedAtUtc,
        lastPulledAtUtc,
        lastPushedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_uid')) {
      context.handle(_scopeUidMeta,
          scopeUid.isAcceptableOrUnknown(data['scope_uid']!, _scopeUidMeta));
    } else if (isInserting) {
      context.missing(_scopeUidMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('cursor_type')) {
      context.handle(
          _cursorTypeMeta,
          cursorType.isAcceptableOrUnknown(
              data['cursor_type']!, _cursorTypeMeta));
    } else if (isInserting) {
      context.missing(_cursorTypeMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('server_updated_at_utc')) {
      context.handle(
          _serverUpdatedAtUtcMeta,
          serverUpdatedAtUtc.isAcceptableOrUnknown(
              data['server_updated_at_utc']!, _serverUpdatedAtUtcMeta));
    }
    if (data.containsKey('tie_breaker')) {
      context.handle(
          _tieBreakerMeta,
          tieBreaker.isAcceptableOrUnknown(
              data['tie_breaker']!, _tieBreakerMeta));
    }
    if (data.containsKey('cursor_updated_at_utc')) {
      context.handle(
          _cursorUpdatedAtUtcMeta,
          cursorUpdatedAtUtc.isAcceptableOrUnknown(
              data['cursor_updated_at_utc']!, _cursorUpdatedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_cursorUpdatedAtUtcMeta);
    }
    if (data.containsKey('last_pulled_at_utc')) {
      context.handle(
          _lastPulledAtUtcMeta,
          lastPulledAtUtc.isAcceptableOrUnknown(
              data['last_pulled_at_utc']!, _lastPulledAtUtcMeta));
    }
    if (data.containsKey('last_pushed_at_utc')) {
      context.handle(
          _lastPushedAtUtcMeta,
          lastPushedAtUtc.isAcceptableOrUnknown(
              data['last_pushed_at_utc']!, _lastPushedAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeUid, entityType};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      scopeUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_uid'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      cursorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor_type'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision']),
      serverUpdatedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}server_updated_at_utc']),
      tieBreaker: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tie_breaker']),
      cursorUpdatedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}cursor_updated_at_utc'])!,
      lastPulledAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pulled_at_utc']),
      lastPushedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pushed_at_utc']),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String scopeUid;
  final String entityType;
  final String cursorType;
  final int? revision;
  final DateTime? serverUpdatedAtUtc;
  final String? tieBreaker;
  final DateTime cursorUpdatedAtUtc;
  final DateTime? lastPulledAtUtc;
  final DateTime? lastPushedAtUtc;
  const SyncStateRow(
      {required this.scopeUid,
      required this.entityType,
      required this.cursorType,
      this.revision,
      this.serverUpdatedAtUtc,
      this.tieBreaker,
      required this.cursorUpdatedAtUtc,
      this.lastPulledAtUtc,
      this.lastPushedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_uid'] = Variable<String>(scopeUid);
    map['entity_type'] = Variable<String>(entityType);
    map['cursor_type'] = Variable<String>(cursorType);
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || serverUpdatedAtUtc != null) {
      map['server_updated_at_utc'] = Variable<DateTime>(serverUpdatedAtUtc);
    }
    if (!nullToAbsent || tieBreaker != null) {
      map['tie_breaker'] = Variable<String>(tieBreaker);
    }
    map['cursor_updated_at_utc'] = Variable<DateTime>(cursorUpdatedAtUtc);
    if (!nullToAbsent || lastPulledAtUtc != null) {
      map['last_pulled_at_utc'] = Variable<DateTime>(lastPulledAtUtc);
    }
    if (!nullToAbsent || lastPushedAtUtc != null) {
      map['last_pushed_at_utc'] = Variable<DateTime>(lastPushedAtUtc);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      scopeUid: Value(scopeUid),
      entityType: Value(entityType),
      cursorType: Value(cursorType),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      serverUpdatedAtUtc: serverUpdatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAtUtc),
      tieBreaker: tieBreaker == null && nullToAbsent
          ? const Value.absent()
          : Value(tieBreaker),
      cursorUpdatedAtUtc: Value(cursorUpdatedAtUtc),
      lastPulledAtUtc: lastPulledAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAtUtc),
      lastPushedAtUtc: lastPushedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAtUtc),
    );
  }

  factory SyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      scopeUid: serializer.fromJson<String>(json['scopeUid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      cursorType: serializer.fromJson<String>(json['cursorType']),
      revision: serializer.fromJson<int?>(json['revision']),
      serverUpdatedAtUtc:
          serializer.fromJson<DateTime?>(json['serverUpdatedAtUtc']),
      tieBreaker: serializer.fromJson<String?>(json['tieBreaker']),
      cursorUpdatedAtUtc:
          serializer.fromJson<DateTime>(json['cursorUpdatedAtUtc']),
      lastPulledAtUtc: serializer.fromJson<DateTime?>(json['lastPulledAtUtc']),
      lastPushedAtUtc: serializer.fromJson<DateTime?>(json['lastPushedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeUid': serializer.toJson<String>(scopeUid),
      'entityType': serializer.toJson<String>(entityType),
      'cursorType': serializer.toJson<String>(cursorType),
      'revision': serializer.toJson<int?>(revision),
      'serverUpdatedAtUtc': serializer.toJson<DateTime?>(serverUpdatedAtUtc),
      'tieBreaker': serializer.toJson<String?>(tieBreaker),
      'cursorUpdatedAtUtc': serializer.toJson<DateTime>(cursorUpdatedAtUtc),
      'lastPulledAtUtc': serializer.toJson<DateTime?>(lastPulledAtUtc),
      'lastPushedAtUtc': serializer.toJson<DateTime?>(lastPushedAtUtc),
    };
  }

  SyncStateRow copyWith(
          {String? scopeUid,
          String? entityType,
          String? cursorType,
          Value<int?> revision = const Value.absent(),
          Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
          Value<String?> tieBreaker = const Value.absent(),
          DateTime? cursorUpdatedAtUtc,
          Value<DateTime?> lastPulledAtUtc = const Value.absent(),
          Value<DateTime?> lastPushedAtUtc = const Value.absent()}) =>
      SyncStateRow(
        scopeUid: scopeUid ?? this.scopeUid,
        entityType: entityType ?? this.entityType,
        cursorType: cursorType ?? this.cursorType,
        revision: revision.present ? revision.value : this.revision,
        serverUpdatedAtUtc: serverUpdatedAtUtc.present
            ? serverUpdatedAtUtc.value
            : this.serverUpdatedAtUtc,
        tieBreaker: tieBreaker.present ? tieBreaker.value : this.tieBreaker,
        cursorUpdatedAtUtc: cursorUpdatedAtUtc ?? this.cursorUpdatedAtUtc,
        lastPulledAtUtc: lastPulledAtUtc.present
            ? lastPulledAtUtc.value
            : this.lastPulledAtUtc,
        lastPushedAtUtc: lastPushedAtUtc.present
            ? lastPushedAtUtc.value
            : this.lastPushedAtUtc,
      );
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      scopeUid: data.scopeUid.present ? data.scopeUid.value : this.scopeUid,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      cursorType:
          data.cursorType.present ? data.cursorType.value : this.cursorType,
      revision: data.revision.present ? data.revision.value : this.revision,
      serverUpdatedAtUtc: data.serverUpdatedAtUtc.present
          ? data.serverUpdatedAtUtc.value
          : this.serverUpdatedAtUtc,
      tieBreaker:
          data.tieBreaker.present ? data.tieBreaker.value : this.tieBreaker,
      cursorUpdatedAtUtc: data.cursorUpdatedAtUtc.present
          ? data.cursorUpdatedAtUtc.value
          : this.cursorUpdatedAtUtc,
      lastPulledAtUtc: data.lastPulledAtUtc.present
          ? data.lastPulledAtUtc.value
          : this.lastPulledAtUtc,
      lastPushedAtUtc: data.lastPushedAtUtc.present
          ? data.lastPushedAtUtc.value
          : this.lastPushedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('cursorType: $cursorType, ')
          ..write('revision: $revision, ')
          ..write('serverUpdatedAtUtc: $serverUpdatedAtUtc, ')
          ..write('tieBreaker: $tieBreaker, ')
          ..write('cursorUpdatedAtUtc: $cursorUpdatedAtUtc, ')
          ..write('lastPulledAtUtc: $lastPulledAtUtc, ')
          ..write('lastPushedAtUtc: $lastPushedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      scopeUid,
      entityType,
      cursorType,
      revision,
      serverUpdatedAtUtc,
      tieBreaker,
      cursorUpdatedAtUtc,
      lastPulledAtUtc,
      lastPushedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.scopeUid == this.scopeUid &&
          other.entityType == this.entityType &&
          other.cursorType == this.cursorType &&
          other.revision == this.revision &&
          other.serverUpdatedAtUtc == this.serverUpdatedAtUtc &&
          other.tieBreaker == this.tieBreaker &&
          other.cursorUpdatedAtUtc == this.cursorUpdatedAtUtc &&
          other.lastPulledAtUtc == this.lastPulledAtUtc &&
          other.lastPushedAtUtc == this.lastPushedAtUtc);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> scopeUid;
  final Value<String> entityType;
  final Value<String> cursorType;
  final Value<int?> revision;
  final Value<DateTime?> serverUpdatedAtUtc;
  final Value<String?> tieBreaker;
  final Value<DateTime> cursorUpdatedAtUtc;
  final Value<DateTime?> lastPulledAtUtc;
  final Value<DateTime?> lastPushedAtUtc;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.scopeUid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.cursorType = const Value.absent(),
    this.revision = const Value.absent(),
    this.serverUpdatedAtUtc = const Value.absent(),
    this.tieBreaker = const Value.absent(),
    this.cursorUpdatedAtUtc = const Value.absent(),
    this.lastPulledAtUtc = const Value.absent(),
    this.lastPushedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String scopeUid,
    required String entityType,
    required String cursorType,
    this.revision = const Value.absent(),
    this.serverUpdatedAtUtc = const Value.absent(),
    this.tieBreaker = const Value.absent(),
    required DateTime cursorUpdatedAtUtc,
    this.lastPulledAtUtc = const Value.absent(),
    this.lastPushedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : scopeUid = Value(scopeUid),
        entityType = Value(entityType),
        cursorType = Value(cursorType),
        cursorUpdatedAtUtc = Value(cursorUpdatedAtUtc);
  static Insertable<SyncStateRow> custom({
    Expression<String>? scopeUid,
    Expression<String>? entityType,
    Expression<String>? cursorType,
    Expression<int>? revision,
    Expression<DateTime>? serverUpdatedAtUtc,
    Expression<String>? tieBreaker,
    Expression<DateTime>? cursorUpdatedAtUtc,
    Expression<DateTime>? lastPulledAtUtc,
    Expression<DateTime>? lastPushedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeUid != null) 'scope_uid': scopeUid,
      if (entityType != null) 'entity_type': entityType,
      if (cursorType != null) 'cursor_type': cursorType,
      if (revision != null) 'revision': revision,
      if (serverUpdatedAtUtc != null)
        'server_updated_at_utc': serverUpdatedAtUtc,
      if (tieBreaker != null) 'tie_breaker': tieBreaker,
      if (cursorUpdatedAtUtc != null)
        'cursor_updated_at_utc': cursorUpdatedAtUtc,
      if (lastPulledAtUtc != null) 'last_pulled_at_utc': lastPulledAtUtc,
      if (lastPushedAtUtc != null) 'last_pushed_at_utc': lastPushedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith(
      {Value<String>? scopeUid,
      Value<String>? entityType,
      Value<String>? cursorType,
      Value<int?>? revision,
      Value<DateTime?>? serverUpdatedAtUtc,
      Value<String?>? tieBreaker,
      Value<DateTime>? cursorUpdatedAtUtc,
      Value<DateTime?>? lastPulledAtUtc,
      Value<DateTime?>? lastPushedAtUtc,
      Value<int>? rowid}) {
    return SyncStatesCompanion(
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      cursorType: cursorType ?? this.cursorType,
      revision: revision ?? this.revision,
      serverUpdatedAtUtc: serverUpdatedAtUtc ?? this.serverUpdatedAtUtc,
      tieBreaker: tieBreaker ?? this.tieBreaker,
      cursorUpdatedAtUtc: cursorUpdatedAtUtc ?? this.cursorUpdatedAtUtc,
      lastPulledAtUtc: lastPulledAtUtc ?? this.lastPulledAtUtc,
      lastPushedAtUtc: lastPushedAtUtc ?? this.lastPushedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeUid.present) {
      map['scope_uid'] = Variable<String>(scopeUid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (cursorType.present) {
      map['cursor_type'] = Variable<String>(cursorType.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (serverUpdatedAtUtc.present) {
      map['server_updated_at_utc'] =
          Variable<DateTime>(serverUpdatedAtUtc.value);
    }
    if (tieBreaker.present) {
      map['tie_breaker'] = Variable<String>(tieBreaker.value);
    }
    if (cursorUpdatedAtUtc.present) {
      map['cursor_updated_at_utc'] =
          Variable<DateTime>(cursorUpdatedAtUtc.value);
    }
    if (lastPulledAtUtc.present) {
      map['last_pulled_at_utc'] = Variable<DateTime>(lastPulledAtUtc.value);
    }
    if (lastPushedAtUtc.present) {
      map['last_pushed_at_utc'] = Variable<DateTime>(lastPushedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('scopeUid: $scopeUid, ')
          ..write('entityType: $entityType, ')
          ..write('cursorType: $cursorType, ')
          ..write('revision: $revision, ')
          ..write('serverUpdatedAtUtc: $serverUpdatedAtUtc, ')
          ..write('tieBreaker: $tieBreaker, ')
          ..write('cursorUpdatedAtUtc: $cursorUpdatedAtUtc, ')
          ..write('lastPulledAtUtc: $lastPulledAtUtc, ')
          ..write('lastPushedAtUtc: $lastPushedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PersistenceDriftDatabase extends GeneratedDatabase {
  _$PersistenceDriftDatabase(QueryExecutor e) : super(e);
  $PersistenceDriftDatabaseManager get managers =>
      $PersistenceDriftDatabaseManager(this);
  late final $OutboxRecordsTable outboxRecords = $OutboxRecordsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final OutboxRecordsDao outboxRecordsDao =
      OutboxRecordsDao(this as PersistenceDriftDatabase);
  late final SyncStatesDao syncStatesDao =
      SyncStatesDao(this as PersistenceDriftDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [outboxRecords, syncStates];
}

typedef $$OutboxRecordsTableCreateCompanionBuilder = OutboxRecordsCompanion
    Function({
  required String operationId,
  required String scopeUid,
  required String entityType,
  required String entityId,
  required String opType,
  required String payloadJson,
  Value<String?> payloadSummary,
  Value<String?> payloadHash,
  required DateTime createdAtUtc,
  Value<int> attempt,
  Value<String> status,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> lastAttemptAtUtc,
  Value<DateTime?> succeededAtUtc,
  Value<int> rowid,
});
typedef $$OutboxRecordsTableUpdateCompanionBuilder = OutboxRecordsCompanion
    Function({
  Value<String> operationId,
  Value<String> scopeUid,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> opType,
  Value<String> payloadJson,
  Value<String?> payloadSummary,
  Value<String?> payloadHash,
  Value<DateTime> createdAtUtc,
  Value<int> attempt,
  Value<String> status,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> lastAttemptAtUtc,
  Value<DateTime?> succeededAtUtc,
  Value<int> rowid,
});

class $$OutboxRecordsTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$OutboxRecordsTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxRecordsTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => column);

  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get payloadSummary => $composableBuilder(
      column: $table.payloadSummary, builder: (column) => column);

  GeneratedColumn<String> get payloadHash => $composableBuilder(
      column: $table.payloadHash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => column);

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAtUtc => $composableBuilder(
      column: $table.lastAttemptAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get succeededAtUtc => $composableBuilder(
      column: $table.succeededAtUtc, builder: (column) => column);
}

class $$OutboxRecordsTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $OutboxRecordsTable,
    OutboxRecordRow,
    $$OutboxRecordsTableFilterComposer,
    $$OutboxRecordsTableOrderingComposer,
    $$OutboxRecordsTableAnnotationComposer,
    $$OutboxRecordsTableCreateCompanionBuilder,
    $$OutboxRecordsTableUpdateCompanionBuilder,
    (
      OutboxRecordRow,
      BaseReferences<_$PersistenceDriftDatabase, $OutboxRecordsTable,
          OutboxRecordRow>
    ),
    OutboxRecordRow,
    PrefetchHooks Function()> {
  $$OutboxRecordsTableTableManager(
      _$PersistenceDriftDatabase db, $OutboxRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> operationId = const Value.absent(),
            Value<String> scopeUid = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> opType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> payloadSummary = const Value.absent(),
            Value<String?> payloadHash = const Value.absent(),
            Value<DateTime> createdAtUtc = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
            Value<DateTime?> succeededAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxRecordsCompanion(
            operationId: operationId,
            scopeUid: scopeUid,
            entityType: entityType,
            entityId: entityId,
            opType: opType,
            payloadJson: payloadJson,
            payloadSummary: payloadSummary,
            payloadHash: payloadHash,
            createdAtUtc: createdAtUtc,
            attempt: attempt,
            status: status,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            lastAttemptAtUtc: lastAttemptAtUtc,
            succeededAtUtc: succeededAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String operationId,
            required String scopeUid,
            required String entityType,
            required String entityId,
            required String opType,
            required String payloadJson,
            Value<String?> payloadSummary = const Value.absent(),
            Value<String?> payloadHash = const Value.absent(),
            required DateTime createdAtUtc,
            Value<int> attempt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<DateTime?> lastAttemptAtUtc = const Value.absent(),
            Value<DateTime?> succeededAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxRecordsCompanion.insert(
            operationId: operationId,
            scopeUid: scopeUid,
            entityType: entityType,
            entityId: entityId,
            opType: opType,
            payloadJson: payloadJson,
            payloadSummary: payloadSummary,
            payloadHash: payloadHash,
            createdAtUtc: createdAtUtc,
            attempt: attempt,
            status: status,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            lastAttemptAtUtc: lastAttemptAtUtc,
            succeededAtUtc: succeededAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxRecordsTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $OutboxRecordsTable,
    OutboxRecordRow,
    $$OutboxRecordsTableFilterComposer,
    $$OutboxRecordsTableOrderingComposer,
    $$OutboxRecordsTableAnnotationComposer,
    $$OutboxRecordsTableCreateCompanionBuilder,
    $$OutboxRecordsTableUpdateCompanionBuilder,
    (
      OutboxRecordRow,
      BaseReferences<_$PersistenceDriftDatabase, $OutboxRecordsTable,
          OutboxRecordRow>
    ),
    OutboxRecordRow,
    PrefetchHooks Function()>;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String scopeUid,
  required String entityType,
  required String cursorType,
  Value<int?> revision,
  Value<DateTime?> serverUpdatedAtUtc,
  Value<String?> tieBreaker,
  required DateTime cursorUpdatedAtUtc,
  Value<DateTime?> lastPulledAtUtc,
  Value<DateTime?> lastPushedAtUtc,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> scopeUid,
  Value<String> entityType,
  Value<String> cursorType,
  Value<int?> revision,
  Value<DateTime?> serverUpdatedAtUtc,
  Value<String?> tieBreaker,
  Value<DateTime> cursorUpdatedAtUtc,
  Value<DateTime?> lastPulledAtUtc,
  Value<DateTime?> lastPushedAtUtc,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeUid => $composableBuilder(
      column: $table.scopeUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$PersistenceDriftDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeUid =>
      $composableBuilder(column: $table.scopeUid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get cursorType => $composableBuilder(
      column: $table.cursorType, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAtUtc => $composableBuilder(
      column: $table.serverUpdatedAtUtc, builder: (column) => column);

  GeneratedColumn<String> get tieBreaker => $composableBuilder(
      column: $table.tieBreaker, builder: (column) => column);

  GeneratedColumn<DateTime> get cursorUpdatedAtUtc => $composableBuilder(
      column: $table.cursorUpdatedAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAtUtc => $composableBuilder(
      column: $table.lastPulledAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPushedAtUtc => $composableBuilder(
      column: $table.lastPushedAtUtc, builder: (column) => column);
}

class $$SyncStatesTableTableManager extends RootTableManager<
    _$PersistenceDriftDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$PersistenceDriftDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()> {
  $$SyncStatesTableTableManager(
      _$PersistenceDriftDatabase db, $SyncStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> scopeUid = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> cursorType = const Value.absent(),
            Value<int?> revision = const Value.absent(),
            Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
            Value<String?> tieBreaker = const Value.absent(),
            Value<DateTime> cursorUpdatedAtUtc = const Value.absent(),
            Value<DateTime?> lastPulledAtUtc = const Value.absent(),
            Value<DateTime?> lastPushedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion(
            scopeUid: scopeUid,
            entityType: entityType,
            cursorType: cursorType,
            revision: revision,
            serverUpdatedAtUtc: serverUpdatedAtUtc,
            tieBreaker: tieBreaker,
            cursorUpdatedAtUtc: cursorUpdatedAtUtc,
            lastPulledAtUtc: lastPulledAtUtc,
            lastPushedAtUtc: lastPushedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String scopeUid,
            required String entityType,
            required String cursorType,
            Value<int?> revision = const Value.absent(),
            Value<DateTime?> serverUpdatedAtUtc = const Value.absent(),
            Value<String?> tieBreaker = const Value.absent(),
            required DateTime cursorUpdatedAtUtc,
            Value<DateTime?> lastPulledAtUtc = const Value.absent(),
            Value<DateTime?> lastPushedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion.insert(
            scopeUid: scopeUid,
            entityType: entityType,
            cursorType: cursorType,
            revision: revision,
            serverUpdatedAtUtc: serverUpdatedAtUtc,
            tieBreaker: tieBreaker,
            cursorUpdatedAtUtc: cursorUpdatedAtUtc,
            lastPulledAtUtc: lastPulledAtUtc,
            lastPushedAtUtc: lastPushedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStatesTableProcessedTableManager = ProcessedTableManager<
    _$PersistenceDriftDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$PersistenceDriftDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()>;

class $PersistenceDriftDatabaseManager {
  final _$PersistenceDriftDatabase _db;
  $PersistenceDriftDatabaseManager(this._db);
  $$OutboxRecordsTableTableManager get outboxRecords =>
      $$OutboxRecordsTableTableManager(_db, _db.outboxRecords);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
