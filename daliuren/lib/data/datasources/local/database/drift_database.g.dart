// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $JuMappingsTable extends JuMappings
    with TableInfo<$JuMappingsTable, JuMappingEntryDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JuMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayJiaZiNameMeta =
      const VerificationMeta('dayJiaZiName');
  @override
  late final GeneratedColumn<String> dayJiaZiName = GeneratedColumn<String>(
      'day_jia_zi_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeDiZhiNameMeta =
      const VerificationMeta('timeDiZhiName');
  @override
  late final GeneratedColumn<String> timeDiZhiName = GeneratedColumn<String>(
      'time_di_zhi_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yinYangValueMeta =
      const VerificationMeta('yinYangValue');
  @override
  late final GeneratedColumn<String> yinYangValue = GeneratedColumn<String>(
      'yin_yang_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _juNumberMeta =
      const VerificationMeta('juNumber');
  @override
  late final GeneratedColumn<int> juNumber = GeneratedColumn<int>(
      'ju_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [dayJiaZiName, timeDiZhiName, yinYangValue, juNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ju_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<JuMappingEntryDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_jia_zi_name')) {
      context.handle(
          _dayJiaZiNameMeta,
          dayJiaZiName.isAcceptableOrUnknown(
              data['day_jia_zi_name']!, _dayJiaZiNameMeta));
    } else if (isInserting) {
      context.missing(_dayJiaZiNameMeta);
    }
    if (data.containsKey('time_di_zhi_name')) {
      context.handle(
          _timeDiZhiNameMeta,
          timeDiZhiName.isAcceptableOrUnknown(
              data['time_di_zhi_name']!, _timeDiZhiNameMeta));
    } else if (isInserting) {
      context.missing(_timeDiZhiNameMeta);
    }
    if (data.containsKey('yin_yang_value')) {
      context.handle(
          _yinYangValueMeta,
          yinYangValue.isAcceptableOrUnknown(
              data['yin_yang_value']!, _yinYangValueMeta));
    } else if (isInserting) {
      context.missing(_yinYangValueMeta);
    }
    if (data.containsKey('ju_number')) {
      context.handle(_juNumberMeta,
          juNumber.isAcceptableOrUnknown(data['ju_number']!, _juNumberMeta));
    } else if (isInserting) {
      context.missing(_juNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {dayJiaZiName, timeDiZhiName, yinYangValue};
  @override
  JuMappingEntryDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JuMappingEntryDb(
      dayJiaZiName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}day_jia_zi_name'])!,
      timeDiZhiName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}time_di_zhi_name'])!,
      yinYangValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}yin_yang_value'])!,
      juNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ju_number'])!,
    );
  }

  @override
  $JuMappingsTable createAlias(String alias) {
    return $JuMappingsTable(attachedDatabase, alias);
  }
}

class JuMappingEntryDb extends DataClass
    implements Insertable<JuMappingEntryDb> {
  final String dayJiaZiName;
  final String timeDiZhiName;
  final String yinYangValue;
  final int juNumber;
  const JuMappingEntryDb(
      {required this.dayJiaZiName,
      required this.timeDiZhiName,
      required this.yinYangValue,
      required this.juNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_jia_zi_name'] = Variable<String>(dayJiaZiName);
    map['time_di_zhi_name'] = Variable<String>(timeDiZhiName);
    map['yin_yang_value'] = Variable<String>(yinYangValue);
    map['ju_number'] = Variable<int>(juNumber);
    return map;
  }

  JuMappingsCompanion toCompanion(bool nullToAbsent) {
    return JuMappingsCompanion(
      dayJiaZiName: Value(dayJiaZiName),
      timeDiZhiName: Value(timeDiZhiName),
      yinYangValue: Value(yinYangValue),
      juNumber: Value(juNumber),
    );
  }

  factory JuMappingEntryDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JuMappingEntryDb(
      dayJiaZiName: serializer.fromJson<String>(json['dayJiaZiName']),
      timeDiZhiName: serializer.fromJson<String>(json['timeDiZhiName']),
      yinYangValue: serializer.fromJson<String>(json['yinYangValue']),
      juNumber: serializer.fromJson<int>(json['juNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayJiaZiName': serializer.toJson<String>(dayJiaZiName),
      'timeDiZhiName': serializer.toJson<String>(timeDiZhiName),
      'yinYangValue': serializer.toJson<String>(yinYangValue),
      'juNumber': serializer.toJson<int>(juNumber),
    };
  }

  JuMappingEntryDb copyWith(
          {String? dayJiaZiName,
          String? timeDiZhiName,
          String? yinYangValue,
          int? juNumber}) =>
      JuMappingEntryDb(
        dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
        timeDiZhiName: timeDiZhiName ?? this.timeDiZhiName,
        yinYangValue: yinYangValue ?? this.yinYangValue,
        juNumber: juNumber ?? this.juNumber,
      );
  JuMappingEntryDb copyWithCompanion(JuMappingsCompanion data) {
    return JuMappingEntryDb(
      dayJiaZiName: data.dayJiaZiName.present
          ? data.dayJiaZiName.value
          : this.dayJiaZiName,
      timeDiZhiName: data.timeDiZhiName.present
          ? data.timeDiZhiName.value
          : this.timeDiZhiName,
      yinYangValue: data.yinYangValue.present
          ? data.yinYangValue.value
          : this.yinYangValue,
      juNumber: data.juNumber.present ? data.juNumber.value : this.juNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JuMappingEntryDb(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('timeDiZhiName: $timeDiZhiName, ')
          ..write('yinYangValue: $yinYangValue, ')
          ..write('juNumber: $juNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dayJiaZiName, timeDiZhiName, yinYangValue, juNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JuMappingEntryDb &&
          other.dayJiaZiName == this.dayJiaZiName &&
          other.timeDiZhiName == this.timeDiZhiName &&
          other.yinYangValue == this.yinYangValue &&
          other.juNumber == this.juNumber);
}

class JuMappingsCompanion extends UpdateCompanion<JuMappingEntryDb> {
  final Value<String> dayJiaZiName;
  final Value<String> timeDiZhiName;
  final Value<String> yinYangValue;
  final Value<int> juNumber;
  final Value<int> rowid;
  const JuMappingsCompanion({
    this.dayJiaZiName = const Value.absent(),
    this.timeDiZhiName = const Value.absent(),
    this.yinYangValue = const Value.absent(),
    this.juNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JuMappingsCompanion.insert({
    required String dayJiaZiName,
    required String timeDiZhiName,
    required String yinYangValue,
    required int juNumber,
    this.rowid = const Value.absent(),
  })  : dayJiaZiName = Value(dayJiaZiName),
        timeDiZhiName = Value(timeDiZhiName),
        yinYangValue = Value(yinYangValue),
        juNumber = Value(juNumber);
  static Insertable<JuMappingEntryDb> custom({
    Expression<String>? dayJiaZiName,
    Expression<String>? timeDiZhiName,
    Expression<String>? yinYangValue,
    Expression<int>? juNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayJiaZiName != null) 'day_jia_zi_name': dayJiaZiName,
      if (timeDiZhiName != null) 'time_di_zhi_name': timeDiZhiName,
      if (yinYangValue != null) 'yin_yang_value': yinYangValue,
      if (juNumber != null) 'ju_number': juNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JuMappingsCompanion copyWith(
      {Value<String>? dayJiaZiName,
      Value<String>? timeDiZhiName,
      Value<String>? yinYangValue,
      Value<int>? juNumber,
      Value<int>? rowid}) {
    return JuMappingsCompanion(
      dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
      timeDiZhiName: timeDiZhiName ?? this.timeDiZhiName,
      yinYangValue: yinYangValue ?? this.yinYangValue,
      juNumber: juNumber ?? this.juNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayJiaZiName.present) {
      map['day_jia_zi_name'] = Variable<String>(dayJiaZiName.value);
    }
    if (timeDiZhiName.present) {
      map['time_di_zhi_name'] = Variable<String>(timeDiZhiName.value);
    }
    if (yinYangValue.present) {
      map['yin_yang_value'] = Variable<String>(yinYangValue.value);
    }
    if (juNumber.present) {
      map['ju_number'] = Variable<int>(juNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JuMappingsCompanion(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('timeDiZhiName: $timeDiZhiName, ')
          ..write('yinYangValue: $yinYangValue, ')
          ..write('juNumber: $juNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $YuDingEntriesTable extends YuDingEntries
    with TableInfo<$YuDingEntriesTable, YuDingEntryDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YuDingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayJiaZiNameMeta =
      const VerificationMeta('dayJiaZiName');
  @override
  late final GeneratedColumn<String> dayJiaZiName = GeneratedColumn<String>(
      'day_jia_zi_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _juNameMeta = const VerificationMeta('juName');
  @override
  late final GeneratedColumn<String> juName = GeneratedColumn<String>(
      'ju_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _juNumberMeta =
      const VerificationMeta('juNumber');
  @override
  late final GeneratedColumn<int> juNumber = GeneratedColumn<int>(
      'ju_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      detailsJson = GeneratedColumn<String>('details_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Map<String, String>>(
              $YuDingEntriesTable.$converterdetailsJson);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      booksJson = GeneratedColumn<String>('books_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Map<String, String>>(
              $YuDingEntriesTable.$converterbooksJson);
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>, String> bodyJson =
      GeneratedColumn<String>('body_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Set<String>>($YuDingEntriesTable.$converterbodyJson);
  static const VerificationMeta _meaningMeta =
      const VerificationMeta('meaning');
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
      'meaning', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explainMeta =
      const VerificationMeta('explain');
  @override
  late final GeneratedColumn<String> explain = GeneratedColumn<String>(
      'explain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _predicationMeta =
      const VerificationMeta('predication');
  @override
  late final GeneratedColumn<String> predication = GeneratedColumn<String>(
      'predication', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        dayJiaZiName,
        juName,
        juNumber,
        detailsJson,
        booksJson,
        bodyJson,
        meaning,
        explain,
        predication
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yu_ding_entries';
  @override
  VerificationContext validateIntegrity(Insertable<YuDingEntryDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_jia_zi_name')) {
      context.handle(
          _dayJiaZiNameMeta,
          dayJiaZiName.isAcceptableOrUnknown(
              data['day_jia_zi_name']!, _dayJiaZiNameMeta));
    } else if (isInserting) {
      context.missing(_dayJiaZiNameMeta);
    }
    if (data.containsKey('ju_name')) {
      context.handle(_juNameMeta,
          juName.isAcceptableOrUnknown(data['ju_name']!, _juNameMeta));
    } else if (isInserting) {
      context.missing(_juNameMeta);
    }
    if (data.containsKey('ju_number')) {
      context.handle(_juNumberMeta,
          juNumber.isAcceptableOrUnknown(data['ju_number']!, _juNumberMeta));
    } else if (isInserting) {
      context.missing(_juNumberMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(_meaningMeta,
          meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta));
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('explain')) {
      context.handle(_explainMeta,
          explain.isAcceptableOrUnknown(data['explain']!, _explainMeta));
    } else if (isInserting) {
      context.missing(_explainMeta);
    }
    if (data.containsKey('predication')) {
      context.handle(
          _predicationMeta,
          predication.isAcceptableOrUnknown(
              data['predication']!, _predicationMeta));
    } else if (isInserting) {
      context.missing(_predicationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayJiaZiName, juName};
  @override
  YuDingEntryDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YuDingEntryDb(
      dayJiaZiName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}day_jia_zi_name'])!,
      juName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ju_name'])!,
      juNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ju_number'])!,
      detailsJson: $YuDingEntriesTable.$converterdetailsJson.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}details_json'])!),
      booksJson: $YuDingEntriesTable.$converterbooksJson.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}books_json'])!),
      bodyJson: $YuDingEntriesTable.$converterbodyJson.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_json'])!),
      meaning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meaning'])!,
      explain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explain'])!,
      predication: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}predication'])!,
    );
  }

  @override
  $YuDingEntriesTable createAlias(String alias) {
    return $YuDingEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String> $converterdetailsJson =
      const MapStringStringConverter();
  static TypeConverter<Map<String, String>, String> $converterbooksJson =
      const MapStringStringConverter();
  static TypeConverter<Set<String>, String> $converterbodyJson =
      const SetStringConverter();
}

class YuDingEntryDb extends DataClass implements Insertable<YuDingEntryDb> {
  final String dayJiaZiName;
  final String juName;
  final int juNumber;
  final Map<String, String> detailsJson;
  final Map<String, String> booksJson;
  final Set<String> bodyJson;
  final String meaning;
  final String explain;
  final String predication;
  const YuDingEntryDb(
      {required this.dayJiaZiName,
      required this.juName,
      required this.juNumber,
      required this.detailsJson,
      required this.booksJson,
      required this.bodyJson,
      required this.meaning,
      required this.explain,
      required this.predication});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_jia_zi_name'] = Variable<String>(dayJiaZiName);
    map['ju_name'] = Variable<String>(juName);
    map['ju_number'] = Variable<int>(juNumber);
    {
      map['details_json'] = Variable<String>(
          $YuDingEntriesTable.$converterdetailsJson.toSql(detailsJson));
    }
    {
      map['books_json'] = Variable<String>(
          $YuDingEntriesTable.$converterbooksJson.toSql(booksJson));
    }
    {
      map['body_json'] = Variable<String>(
          $YuDingEntriesTable.$converterbodyJson.toSql(bodyJson));
    }
    map['meaning'] = Variable<String>(meaning);
    map['explain'] = Variable<String>(explain);
    map['predication'] = Variable<String>(predication);
    return map;
  }

  YuDingEntriesCompanion toCompanion(bool nullToAbsent) {
    return YuDingEntriesCompanion(
      dayJiaZiName: Value(dayJiaZiName),
      juName: Value(juName),
      juNumber: Value(juNumber),
      detailsJson: Value(detailsJson),
      booksJson: Value(booksJson),
      bodyJson: Value(bodyJson),
      meaning: Value(meaning),
      explain: Value(explain),
      predication: Value(predication),
    );
  }

  factory YuDingEntryDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YuDingEntryDb(
      dayJiaZiName: serializer.fromJson<String>(json['dayJiaZiName']),
      juName: serializer.fromJson<String>(json['juName']),
      juNumber: serializer.fromJson<int>(json['juNumber']),
      detailsJson:
          serializer.fromJson<Map<String, String>>(json['detailsJson']),
      booksJson: serializer.fromJson<Map<String, String>>(json['booksJson']),
      bodyJson: serializer.fromJson<Set<String>>(json['bodyJson']),
      meaning: serializer.fromJson<String>(json['meaning']),
      explain: serializer.fromJson<String>(json['explain']),
      predication: serializer.fromJson<String>(json['predication']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayJiaZiName': serializer.toJson<String>(dayJiaZiName),
      'juName': serializer.toJson<String>(juName),
      'juNumber': serializer.toJson<int>(juNumber),
      'detailsJson': serializer.toJson<Map<String, String>>(detailsJson),
      'booksJson': serializer.toJson<Map<String, String>>(booksJson),
      'bodyJson': serializer.toJson<Set<String>>(bodyJson),
      'meaning': serializer.toJson<String>(meaning),
      'explain': serializer.toJson<String>(explain),
      'predication': serializer.toJson<String>(predication),
    };
  }

  YuDingEntryDb copyWith(
          {String? dayJiaZiName,
          String? juName,
          int? juNumber,
          Map<String, String>? detailsJson,
          Map<String, String>? booksJson,
          Set<String>? bodyJson,
          String? meaning,
          String? explain,
          String? predication}) =>
      YuDingEntryDb(
        dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
        juName: juName ?? this.juName,
        juNumber: juNumber ?? this.juNumber,
        detailsJson: detailsJson ?? this.detailsJson,
        booksJson: booksJson ?? this.booksJson,
        bodyJson: bodyJson ?? this.bodyJson,
        meaning: meaning ?? this.meaning,
        explain: explain ?? this.explain,
        predication: predication ?? this.predication,
      );
  YuDingEntryDb copyWithCompanion(YuDingEntriesCompanion data) {
    return YuDingEntryDb(
      dayJiaZiName: data.dayJiaZiName.present
          ? data.dayJiaZiName.value
          : this.dayJiaZiName,
      juName: data.juName.present ? data.juName.value : this.juName,
      juNumber: data.juNumber.present ? data.juNumber.value : this.juNumber,
      detailsJson:
          data.detailsJson.present ? data.detailsJson.value : this.detailsJson,
      booksJson: data.booksJson.present ? data.booksJson.value : this.booksJson,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      explain: data.explain.present ? data.explain.value : this.explain,
      predication:
          data.predication.present ? data.predication.value : this.predication,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YuDingEntryDb(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('juName: $juName, ')
          ..write('juNumber: $juNumber, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('booksJson: $booksJson, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('meaning: $meaning, ')
          ..write('explain: $explain, ')
          ..write('predication: $predication')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayJiaZiName, juName, juNumber, detailsJson,
      booksJson, bodyJson, meaning, explain, predication);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YuDingEntryDb &&
          other.dayJiaZiName == this.dayJiaZiName &&
          other.juName == this.juName &&
          other.juNumber == this.juNumber &&
          other.detailsJson == this.detailsJson &&
          other.booksJson == this.booksJson &&
          other.bodyJson == this.bodyJson &&
          other.meaning == this.meaning &&
          other.explain == this.explain &&
          other.predication == this.predication);
}

class YuDingEntriesCompanion extends UpdateCompanion<YuDingEntryDb> {
  final Value<String> dayJiaZiName;
  final Value<String> juName;
  final Value<int> juNumber;
  final Value<Map<String, String>> detailsJson;
  final Value<Map<String, String>> booksJson;
  final Value<Set<String>> bodyJson;
  final Value<String> meaning;
  final Value<String> explain;
  final Value<String> predication;
  final Value<int> rowid;
  const YuDingEntriesCompanion({
    this.dayJiaZiName = const Value.absent(),
    this.juName = const Value.absent(),
    this.juNumber = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.booksJson = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.meaning = const Value.absent(),
    this.explain = const Value.absent(),
    this.predication = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YuDingEntriesCompanion.insert({
    required String dayJiaZiName,
    required String juName,
    required int juNumber,
    required Map<String, String> detailsJson,
    required Map<String, String> booksJson,
    required Set<String> bodyJson,
    required String meaning,
    required String explain,
    required String predication,
    this.rowid = const Value.absent(),
  })  : dayJiaZiName = Value(dayJiaZiName),
        juName = Value(juName),
        juNumber = Value(juNumber),
        detailsJson = Value(detailsJson),
        booksJson = Value(booksJson),
        bodyJson = Value(bodyJson),
        meaning = Value(meaning),
        explain = Value(explain),
        predication = Value(predication);
  static Insertable<YuDingEntryDb> custom({
    Expression<String>? dayJiaZiName,
    Expression<String>? juName,
    Expression<int>? juNumber,
    Expression<String>? detailsJson,
    Expression<String>? booksJson,
    Expression<String>? bodyJson,
    Expression<String>? meaning,
    Expression<String>? explain,
    Expression<String>? predication,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayJiaZiName != null) 'day_jia_zi_name': dayJiaZiName,
      if (juName != null) 'ju_name': juName,
      if (juNumber != null) 'ju_number': juNumber,
      if (detailsJson != null) 'details_json': detailsJson,
      if (booksJson != null) 'books_json': booksJson,
      if (bodyJson != null) 'body_json': bodyJson,
      if (meaning != null) 'meaning': meaning,
      if (explain != null) 'explain': explain,
      if (predication != null) 'predication': predication,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YuDingEntriesCompanion copyWith(
      {Value<String>? dayJiaZiName,
      Value<String>? juName,
      Value<int>? juNumber,
      Value<Map<String, String>>? detailsJson,
      Value<Map<String, String>>? booksJson,
      Value<Set<String>>? bodyJson,
      Value<String>? meaning,
      Value<String>? explain,
      Value<String>? predication,
      Value<int>? rowid}) {
    return YuDingEntriesCompanion(
      dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
      juName: juName ?? this.juName,
      juNumber: juNumber ?? this.juNumber,
      detailsJson: detailsJson ?? this.detailsJson,
      booksJson: booksJson ?? this.booksJson,
      bodyJson: bodyJson ?? this.bodyJson,
      meaning: meaning ?? this.meaning,
      explain: explain ?? this.explain,
      predication: predication ?? this.predication,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayJiaZiName.present) {
      map['day_jia_zi_name'] = Variable<String>(dayJiaZiName.value);
    }
    if (juName.present) {
      map['ju_name'] = Variable<String>(juName.value);
    }
    if (juNumber.present) {
      map['ju_number'] = Variable<int>(juNumber.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(
          $YuDingEntriesTable.$converterdetailsJson.toSql(detailsJson.value));
    }
    if (booksJson.present) {
      map['books_json'] = Variable<String>(
          $YuDingEntriesTable.$converterbooksJson.toSql(booksJson.value));
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(
          $YuDingEntriesTable.$converterbodyJson.toSql(bodyJson.value));
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (explain.present) {
      map['explain'] = Variable<String>(explain.value);
    }
    if (predication.present) {
      map['predication'] = Variable<String>(predication.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YuDingEntriesCompanion(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('juName: $juName, ')
          ..write('juNumber: $juNumber, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('booksJson: $booksJson, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('meaning: $meaning, ')
          ..write('explain: $explain, ')
          ..write('predication: $predication, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresetPansTable extends PresetPans
    with TableInfo<$PresetPansTable, PresetPanEntryDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetPansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayJiaZiNameMeta =
      const VerificationMeta('dayJiaZiName');
  @override
  late final GeneratedColumn<String> dayJiaZiName = GeneratedColumn<String>(
      'day_jia_zi_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shiChenNameMeta =
      const VerificationMeta('shiChenName');
  @override
  late final GeneratedColumn<String> shiChenName = GeneratedColumn<String>(
      'shi_chen_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yinYangDunMeta =
      const VerificationMeta('yinYangDun');
  @override
  late final GeneratedColumn<String> yinYangDun = GeneratedColumn<String>(
      'yin_yang_dun', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _juNumberNameMeta =
      const VerificationMeta('juNumberName');
  @override
  late final GeneratedColumn<String> juNumberName = GeneratedColumn<String>(
      'ju_number_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<FourClassDataModel?, String>
      fourClassJson = GeneratedColumn<String>(
              'four_class_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<FourClassDataModel?>(
              $PresetPansTable.$converterfourClassJson);
  @override
  late final GeneratedColumnWithTypeConverter<ThreeChuanDataModel?, String>
      threeChuanJson = GeneratedColumn<String>(
              'three_chuan_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ThreeChuanDataModel?>(
              $PresetPansTable.$converterthreeChuanJson);
  static const VerificationMeta _nineZongMenNameMeta =
      const VerificationMeta('nineZongMenName');
  @override
  late final GeneratedColumn<String> nineZongMenName = GeneratedColumn<String>(
      'nine_zong_men_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        dayJiaZiName,
        shiChenName,
        yinYangDun,
        juNumberName,
        fourClassJson,
        threeChuanJson,
        nineZongMenName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preset_pans';
  @override
  VerificationContext validateIntegrity(Insertable<PresetPanEntryDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_jia_zi_name')) {
      context.handle(
          _dayJiaZiNameMeta,
          dayJiaZiName.isAcceptableOrUnknown(
              data['day_jia_zi_name']!, _dayJiaZiNameMeta));
    } else if (isInserting) {
      context.missing(_dayJiaZiNameMeta);
    }
    if (data.containsKey('shi_chen_name')) {
      context.handle(
          _shiChenNameMeta,
          shiChenName.isAcceptableOrUnknown(
              data['shi_chen_name']!, _shiChenNameMeta));
    } else if (isInserting) {
      context.missing(_shiChenNameMeta);
    }
    if (data.containsKey('yin_yang_dun')) {
      context.handle(
          _yinYangDunMeta,
          yinYangDun.isAcceptableOrUnknown(
              data['yin_yang_dun']!, _yinYangDunMeta));
    } else if (isInserting) {
      context.missing(_yinYangDunMeta);
    }
    if (data.containsKey('ju_number_name')) {
      context.handle(
          _juNumberNameMeta,
          juNumberName.isAcceptableOrUnknown(
              data['ju_number_name']!, _juNumberNameMeta));
    } else if (isInserting) {
      context.missing(_juNumberNameMeta);
    }
    if (data.containsKey('nine_zong_men_name')) {
      context.handle(
          _nineZongMenNameMeta,
          nineZongMenName.isAcceptableOrUnknown(
              data['nine_zong_men_name']!, _nineZongMenNameMeta));
    } else if (isInserting) {
      context.missing(_nineZongMenNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {dayJiaZiName, shiChenName, yinYangDun};
  @override
  PresetPanEntryDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresetPanEntryDb(
      dayJiaZiName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}day_jia_zi_name'])!,
      shiChenName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shi_chen_name'])!,
      yinYangDun: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}yin_yang_dun'])!,
      juNumberName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ju_number_name'])!,
      fourClassJson: $PresetPansTable.$converterfourClassJson.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}four_class_json'])!),
      threeChuanJson: $PresetPansTable.$converterthreeChuanJson.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}three_chuan_json'])!),
      nineZongMenName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nine_zong_men_name'])!,
    );
  }

  @override
  $PresetPansTable createAlias(String alias) {
    return $PresetPansTable(attachedDatabase, alias);
  }

  static TypeConverter<FourClassDataModel?, String> $converterfourClassJson =
      const FourClassConverter();
  static TypeConverter<ThreeChuanDataModel?, String> $converterthreeChuanJson =
      const ThreeChuanConverter();
}

class PresetPanEntryDb extends DataClass
    implements Insertable<PresetPanEntryDb> {
  final String dayJiaZiName;
  final String shiChenName;
  final String yinYangDun;
  final String juNumberName;
  final FourClassDataModel? fourClassJson;
  final ThreeChuanDataModel? threeChuanJson;
  final String nineZongMenName;
  const PresetPanEntryDb(
      {required this.dayJiaZiName,
      required this.shiChenName,
      required this.yinYangDun,
      required this.juNumberName,
      this.fourClassJson,
      this.threeChuanJson,
      required this.nineZongMenName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_jia_zi_name'] = Variable<String>(dayJiaZiName);
    map['shi_chen_name'] = Variable<String>(shiChenName);
    map['yin_yang_dun'] = Variable<String>(yinYangDun);
    map['ju_number_name'] = Variable<String>(juNumberName);
    if (!nullToAbsent || fourClassJson != null) {
      map['four_class_json'] = Variable<String>(
          $PresetPansTable.$converterfourClassJson.toSql(fourClassJson));
    }
    if (!nullToAbsent || threeChuanJson != null) {
      map['three_chuan_json'] = Variable<String>(
          $PresetPansTable.$converterthreeChuanJson.toSql(threeChuanJson));
    }
    map['nine_zong_men_name'] = Variable<String>(nineZongMenName);
    return map;
  }

  PresetPansCompanion toCompanion(bool nullToAbsent) {
    return PresetPansCompanion(
      dayJiaZiName: Value(dayJiaZiName),
      shiChenName: Value(shiChenName),
      yinYangDun: Value(yinYangDun),
      juNumberName: Value(juNumberName),
      fourClassJson: fourClassJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fourClassJson),
      threeChuanJson: threeChuanJson == null && nullToAbsent
          ? const Value.absent()
          : Value(threeChuanJson),
      nineZongMenName: Value(nineZongMenName),
    );
  }

  factory PresetPanEntryDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresetPanEntryDb(
      dayJiaZiName: serializer.fromJson<String>(json['dayJiaZiName']),
      shiChenName: serializer.fromJson<String>(json['shiChenName']),
      yinYangDun: serializer.fromJson<String>(json['yinYangDun']),
      juNumberName: serializer.fromJson<String>(json['juNumberName']),
      fourClassJson:
          serializer.fromJson<FourClassDataModel?>(json['fourClassJson']),
      threeChuanJson:
          serializer.fromJson<ThreeChuanDataModel?>(json['threeChuanJson']),
      nineZongMenName: serializer.fromJson<String>(json['nineZongMenName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayJiaZiName': serializer.toJson<String>(dayJiaZiName),
      'shiChenName': serializer.toJson<String>(shiChenName),
      'yinYangDun': serializer.toJson<String>(yinYangDun),
      'juNumberName': serializer.toJson<String>(juNumberName),
      'fourClassJson': serializer.toJson<FourClassDataModel?>(fourClassJson),
      'threeChuanJson': serializer.toJson<ThreeChuanDataModel?>(threeChuanJson),
      'nineZongMenName': serializer.toJson<String>(nineZongMenName),
    };
  }

  PresetPanEntryDb copyWith(
          {String? dayJiaZiName,
          String? shiChenName,
          String? yinYangDun,
          String? juNumberName,
          Value<FourClassDataModel?> fourClassJson = const Value.absent(),
          Value<ThreeChuanDataModel?> threeChuanJson = const Value.absent(),
          String? nineZongMenName}) =>
      PresetPanEntryDb(
        dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
        shiChenName: shiChenName ?? this.shiChenName,
        yinYangDun: yinYangDun ?? this.yinYangDun,
        juNumberName: juNumberName ?? this.juNumberName,
        fourClassJson:
            fourClassJson.present ? fourClassJson.value : this.fourClassJson,
        threeChuanJson:
            threeChuanJson.present ? threeChuanJson.value : this.threeChuanJson,
        nineZongMenName: nineZongMenName ?? this.nineZongMenName,
      );
  PresetPanEntryDb copyWithCompanion(PresetPansCompanion data) {
    return PresetPanEntryDb(
      dayJiaZiName: data.dayJiaZiName.present
          ? data.dayJiaZiName.value
          : this.dayJiaZiName,
      shiChenName:
          data.shiChenName.present ? data.shiChenName.value : this.shiChenName,
      yinYangDun:
          data.yinYangDun.present ? data.yinYangDun.value : this.yinYangDun,
      juNumberName: data.juNumberName.present
          ? data.juNumberName.value
          : this.juNumberName,
      fourClassJson: data.fourClassJson.present
          ? data.fourClassJson.value
          : this.fourClassJson,
      threeChuanJson: data.threeChuanJson.present
          ? data.threeChuanJson.value
          : this.threeChuanJson,
      nineZongMenName: data.nineZongMenName.present
          ? data.nineZongMenName.value
          : this.nineZongMenName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresetPanEntryDb(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('shiChenName: $shiChenName, ')
          ..write('yinYangDun: $yinYangDun, ')
          ..write('juNumberName: $juNumberName, ')
          ..write('fourClassJson: $fourClassJson, ')
          ..write('threeChuanJson: $threeChuanJson, ')
          ..write('nineZongMenName: $nineZongMenName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayJiaZiName, shiChenName, yinYangDun,
      juNumberName, fourClassJson, threeChuanJson, nineZongMenName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresetPanEntryDb &&
          other.dayJiaZiName == this.dayJiaZiName &&
          other.shiChenName == this.shiChenName &&
          other.yinYangDun == this.yinYangDun &&
          other.juNumberName == this.juNumberName &&
          other.fourClassJson == this.fourClassJson &&
          other.threeChuanJson == this.threeChuanJson &&
          other.nineZongMenName == this.nineZongMenName);
}

class PresetPansCompanion extends UpdateCompanion<PresetPanEntryDb> {
  final Value<String> dayJiaZiName;
  final Value<String> shiChenName;
  final Value<String> yinYangDun;
  final Value<String> juNumberName;
  final Value<FourClassDataModel?> fourClassJson;
  final Value<ThreeChuanDataModel?> threeChuanJson;
  final Value<String> nineZongMenName;
  final Value<int> rowid;
  const PresetPansCompanion({
    this.dayJiaZiName = const Value.absent(),
    this.shiChenName = const Value.absent(),
    this.yinYangDun = const Value.absent(),
    this.juNumberName = const Value.absent(),
    this.fourClassJson = const Value.absent(),
    this.threeChuanJson = const Value.absent(),
    this.nineZongMenName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresetPansCompanion.insert({
    required String dayJiaZiName,
    required String shiChenName,
    required String yinYangDun,
    required String juNumberName,
    required FourClassDataModel? fourClassJson,
    required ThreeChuanDataModel? threeChuanJson,
    required String nineZongMenName,
    this.rowid = const Value.absent(),
  })  : dayJiaZiName = Value(dayJiaZiName),
        shiChenName = Value(shiChenName),
        yinYangDun = Value(yinYangDun),
        juNumberName = Value(juNumberName),
        fourClassJson = Value(fourClassJson),
        threeChuanJson = Value(threeChuanJson),
        nineZongMenName = Value(nineZongMenName);
  static Insertable<PresetPanEntryDb> custom({
    Expression<String>? dayJiaZiName,
    Expression<String>? shiChenName,
    Expression<String>? yinYangDun,
    Expression<String>? juNumberName,
    Expression<String>? fourClassJson,
    Expression<String>? threeChuanJson,
    Expression<String>? nineZongMenName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayJiaZiName != null) 'day_jia_zi_name': dayJiaZiName,
      if (shiChenName != null) 'shi_chen_name': shiChenName,
      if (yinYangDun != null) 'yin_yang_dun': yinYangDun,
      if (juNumberName != null) 'ju_number_name': juNumberName,
      if (fourClassJson != null) 'four_class_json': fourClassJson,
      if (threeChuanJson != null) 'three_chuan_json': threeChuanJson,
      if (nineZongMenName != null) 'nine_zong_men_name': nineZongMenName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresetPansCompanion copyWith(
      {Value<String>? dayJiaZiName,
      Value<String>? shiChenName,
      Value<String>? yinYangDun,
      Value<String>? juNumberName,
      Value<FourClassDataModel?>? fourClassJson,
      Value<ThreeChuanDataModel?>? threeChuanJson,
      Value<String>? nineZongMenName,
      Value<int>? rowid}) {
    return PresetPansCompanion(
      dayJiaZiName: dayJiaZiName ?? this.dayJiaZiName,
      shiChenName: shiChenName ?? this.shiChenName,
      yinYangDun: yinYangDun ?? this.yinYangDun,
      juNumberName: juNumberName ?? this.juNumberName,
      fourClassJson: fourClassJson ?? this.fourClassJson,
      threeChuanJson: threeChuanJson ?? this.threeChuanJson,
      nineZongMenName: nineZongMenName ?? this.nineZongMenName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayJiaZiName.present) {
      map['day_jia_zi_name'] = Variable<String>(dayJiaZiName.value);
    }
    if (shiChenName.present) {
      map['shi_chen_name'] = Variable<String>(shiChenName.value);
    }
    if (yinYangDun.present) {
      map['yin_yang_dun'] = Variable<String>(yinYangDun.value);
    }
    if (juNumberName.present) {
      map['ju_number_name'] = Variable<String>(juNumberName.value);
    }
    if (fourClassJson.present) {
      map['four_class_json'] = Variable<String>(
          $PresetPansTable.$converterfourClassJson.toSql(fourClassJson.value));
    }
    if (threeChuanJson.present) {
      map['three_chuan_json'] = Variable<String>($PresetPansTable
          .$converterthreeChuanJson
          .toSql(threeChuanJson.value));
    }
    if (nineZongMenName.present) {
      map['nine_zong_men_name'] = Variable<String>(nineZongMenName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetPansCompanion(')
          ..write('dayJiaZiName: $dayJiaZiName, ')
          ..write('shiChenName: $shiChenName, ')
          ..write('yinYangDun: $yinYangDun, ')
          ..write('juNumberName: $juNumberName, ')
          ..write('fourClassJson: $fourClassJson, ')
          ..write('threeChuanJson: $threeChuanJson, ')
          ..write('nineZongMenName: $nineZongMenName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbInitializationFlagsTable extends DbInitializationFlags
    with TableInfo<$DbInitializationFlagsTable, DbInitializationFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbInitializationFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flagKeyMeta =
      const VerificationMeta('flagKey');
  @override
  late final GeneratedColumn<String> flagKey = GeneratedColumn<String>(
      'flag_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => 'isAssetDataLoaded_v1');
  static const VerificationMeta _isSetMeta = const VerificationMeta('isSet');
  @override
  late final GeneratedColumn<bool> isSet = GeneratedColumn<bool>(
      'is_set', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_set" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [flagKey, isSet];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_initialization_flags';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbInitializationFlag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flag_key')) {
      context.handle(_flagKeyMeta,
          flagKey.isAcceptableOrUnknown(data['flag_key']!, _flagKeyMeta));
    }
    if (data.containsKey('is_set')) {
      context.handle(
          _isSetMeta, isSet.isAcceptableOrUnknown(data['is_set']!, _isSetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flagKey};
  @override
  DbInitializationFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbInitializationFlag(
      flagKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flag_key'])!,
      isSet: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_set'])!,
    );
  }

  @override
  $DbInitializationFlagsTable createAlias(String alias) {
    return $DbInitializationFlagsTable(attachedDatabase, alias);
  }
}

class DbInitializationFlag extends DataClass
    implements Insertable<DbInitializationFlag> {
  /// The key for the flag, e.g., "isAssetDataLoaded_v1". Using version in key allows for future data reseeding.
  final String flagKey;

  /// Boolean value of the flag.
  final bool isSet;
  const DbInitializationFlag({required this.flagKey, required this.isSet});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flag_key'] = Variable<String>(flagKey);
    map['is_set'] = Variable<bool>(isSet);
    return map;
  }

  DbInitializationFlagsCompanion toCompanion(bool nullToAbsent) {
    return DbInitializationFlagsCompanion(
      flagKey: Value(flagKey),
      isSet: Value(isSet),
    );
  }

  factory DbInitializationFlag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbInitializationFlag(
      flagKey: serializer.fromJson<String>(json['flagKey']),
      isSet: serializer.fromJson<bool>(json['isSet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flagKey': serializer.toJson<String>(flagKey),
      'isSet': serializer.toJson<bool>(isSet),
    };
  }

  DbInitializationFlag copyWith({String? flagKey, bool? isSet}) =>
      DbInitializationFlag(
        flagKey: flagKey ?? this.flagKey,
        isSet: isSet ?? this.isSet,
      );
  DbInitializationFlag copyWithCompanion(DbInitializationFlagsCompanion data) {
    return DbInitializationFlag(
      flagKey: data.flagKey.present ? data.flagKey.value : this.flagKey,
      isSet: data.isSet.present ? data.isSet.value : this.isSet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbInitializationFlag(')
          ..write('flagKey: $flagKey, ')
          ..write('isSet: $isSet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(flagKey, isSet);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbInitializationFlag &&
          other.flagKey == this.flagKey &&
          other.isSet == this.isSet);
}

class DbInitializationFlagsCompanion
    extends UpdateCompanion<DbInitializationFlag> {
  final Value<String> flagKey;
  final Value<bool> isSet;
  final Value<int> rowid;
  const DbInitializationFlagsCompanion({
    this.flagKey = const Value.absent(),
    this.isSet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbInitializationFlagsCompanion.insert({
    this.flagKey = const Value.absent(),
    this.isSet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<DbInitializationFlag> custom({
    Expression<String>? flagKey,
    Expression<bool>? isSet,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flagKey != null) 'flag_key': flagKey,
      if (isSet != null) 'is_set': isSet,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbInitializationFlagsCompanion copyWith(
      {Value<String>? flagKey, Value<bool>? isSet, Value<int>? rowid}) {
    return DbInitializationFlagsCompanion(
      flagKey: flagKey ?? this.flagKey,
      isSet: isSet ?? this.isSet,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flagKey.present) {
      map['flag_key'] = Variable<String>(flagKey.value);
    }
    if (isSet.present) {
      map['is_set'] = Variable<bool>(isSet.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbInitializationFlagsCompanion(')
          ..write('flagKey: $flagKey, ')
          ..write('isSet: $isSet, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DaLiuRenAppDatabase extends GeneratedDatabase {
  _$DaLiuRenAppDatabase(QueryExecutor e) : super(e);
  $DaLiuRenAppDatabaseManager get managers => $DaLiuRenAppDatabaseManager(this);
  late final $JuMappingsTable juMappings = $JuMappingsTable(this);
  late final $YuDingEntriesTable yuDingEntries = $YuDingEntriesTable(this);
  late final $PresetPansTable presetPans = $PresetPansTable(this);
  late final $DbInitializationFlagsTable dbInitializationFlags =
      $DbInitializationFlagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [juMappings, yuDingEntries, presetPans, dbInitializationFlags];
}

typedef $$JuMappingsTableCreateCompanionBuilder = JuMappingsCompanion Function({
  required String dayJiaZiName,
  required String timeDiZhiName,
  required String yinYangValue,
  required int juNumber,
  Value<int> rowid,
});
typedef $$JuMappingsTableUpdateCompanionBuilder = JuMappingsCompanion Function({
  Value<String> dayJiaZiName,
  Value<String> timeDiZhiName,
  Value<String> yinYangValue,
  Value<int> juNumber,
  Value<int> rowid,
});

class $$JuMappingsTableFilterComposer
    extends Composer<_$DaLiuRenAppDatabase, $JuMappingsTable> {
  $$JuMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeDiZhiName => $composableBuilder(
      column: $table.timeDiZhiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yinYangValue => $composableBuilder(
      column: $table.yinYangValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get juNumber => $composableBuilder(
      column: $table.juNumber, builder: (column) => ColumnFilters(column));
}

class $$JuMappingsTableOrderingComposer
    extends Composer<_$DaLiuRenAppDatabase, $JuMappingsTable> {
  $$JuMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeDiZhiName => $composableBuilder(
      column: $table.timeDiZhiName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yinYangValue => $composableBuilder(
      column: $table.yinYangValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get juNumber => $composableBuilder(
      column: $table.juNumber, builder: (column) => ColumnOrderings(column));
}

class $$JuMappingsTableAnnotationComposer
    extends Composer<_$DaLiuRenAppDatabase, $JuMappingsTable> {
  $$JuMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => column);

  GeneratedColumn<String> get timeDiZhiName => $composableBuilder(
      column: $table.timeDiZhiName, builder: (column) => column);

  GeneratedColumn<String> get yinYangValue => $composableBuilder(
      column: $table.yinYangValue, builder: (column) => column);

  GeneratedColumn<int> get juNumber =>
      $composableBuilder(column: $table.juNumber, builder: (column) => column);
}

class $$JuMappingsTableTableManager extends RootTableManager<
    _$DaLiuRenAppDatabase,
    $JuMappingsTable,
    JuMappingEntryDb,
    $$JuMappingsTableFilterComposer,
    $$JuMappingsTableOrderingComposer,
    $$JuMappingsTableAnnotationComposer,
    $$JuMappingsTableCreateCompanionBuilder,
    $$JuMappingsTableUpdateCompanionBuilder,
    (
      JuMappingEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $JuMappingsTable, JuMappingEntryDb>
    ),
    JuMappingEntryDb,
    PrefetchHooks Function()> {
  $$JuMappingsTableTableManager(
      _$DaLiuRenAppDatabase db, $JuMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JuMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JuMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JuMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dayJiaZiName = const Value.absent(),
            Value<String> timeDiZhiName = const Value.absent(),
            Value<String> yinYangValue = const Value.absent(),
            Value<int> juNumber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JuMappingsCompanion(
            dayJiaZiName: dayJiaZiName,
            timeDiZhiName: timeDiZhiName,
            yinYangValue: yinYangValue,
            juNumber: juNumber,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dayJiaZiName,
            required String timeDiZhiName,
            required String yinYangValue,
            required int juNumber,
            Value<int> rowid = const Value.absent(),
          }) =>
              JuMappingsCompanion.insert(
            dayJiaZiName: dayJiaZiName,
            timeDiZhiName: timeDiZhiName,
            yinYangValue: yinYangValue,
            juNumber: juNumber,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JuMappingsTableProcessedTableManager = ProcessedTableManager<
    _$DaLiuRenAppDatabase,
    $JuMappingsTable,
    JuMappingEntryDb,
    $$JuMappingsTableFilterComposer,
    $$JuMappingsTableOrderingComposer,
    $$JuMappingsTableAnnotationComposer,
    $$JuMappingsTableCreateCompanionBuilder,
    $$JuMappingsTableUpdateCompanionBuilder,
    (
      JuMappingEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $JuMappingsTable, JuMappingEntryDb>
    ),
    JuMappingEntryDb,
    PrefetchHooks Function()>;
typedef $$YuDingEntriesTableCreateCompanionBuilder = YuDingEntriesCompanion
    Function({
  required String dayJiaZiName,
  required String juName,
  required int juNumber,
  required Map<String, String> detailsJson,
  required Map<String, String> booksJson,
  required Set<String> bodyJson,
  required String meaning,
  required String explain,
  required String predication,
  Value<int> rowid,
});
typedef $$YuDingEntriesTableUpdateCompanionBuilder = YuDingEntriesCompanion
    Function({
  Value<String> dayJiaZiName,
  Value<String> juName,
  Value<int> juNumber,
  Value<Map<String, String>> detailsJson,
  Value<Map<String, String>> booksJson,
  Value<Set<String>> bodyJson,
  Value<String> meaning,
  Value<String> explain,
  Value<String> predication,
  Value<int> rowid,
});

class $$YuDingEntriesTableFilterComposer
    extends Composer<_$DaLiuRenAppDatabase, $YuDingEntriesTable> {
  $$YuDingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get juName => $composableBuilder(
      column: $table.juName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get juNumber => $composableBuilder(
      column: $table.juNumber, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get detailsJson => $composableBuilder(
          column: $table.detailsJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get booksJson => $composableBuilder(
          column: $table.booksJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Set<String>, Set<String>, String>
      get bodyJson => $composableBuilder(
          column: $table.bodyJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explain => $composableBuilder(
      column: $table.explain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get predication => $composableBuilder(
      column: $table.predication, builder: (column) => ColumnFilters(column));
}

class $$YuDingEntriesTableOrderingComposer
    extends Composer<_$DaLiuRenAppDatabase, $YuDingEntriesTable> {
  $$YuDingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get juName => $composableBuilder(
      column: $table.juName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get juNumber => $composableBuilder(
      column: $table.juNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get booksJson => $composableBuilder(
      column: $table.booksJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyJson => $composableBuilder(
      column: $table.bodyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explain => $composableBuilder(
      column: $table.explain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get predication => $composableBuilder(
      column: $table.predication, builder: (column) => ColumnOrderings(column));
}

class $$YuDingEntriesTableAnnotationComposer
    extends Composer<_$DaLiuRenAppDatabase, $YuDingEntriesTable> {
  $$YuDingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => column);

  GeneratedColumn<String> get juName =>
      $composableBuilder(column: $table.juName, builder: (column) => column);

  GeneratedColumn<int> get juNumber =>
      $composableBuilder(column: $table.juNumber, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get detailsJson => $composableBuilder(
          column: $table.detailsJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get booksJson =>
      $composableBuilder(column: $table.booksJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<String>, String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get explain =>
      $composableBuilder(column: $table.explain, builder: (column) => column);

  GeneratedColumn<String> get predication => $composableBuilder(
      column: $table.predication, builder: (column) => column);
}

class $$YuDingEntriesTableTableManager extends RootTableManager<
    _$DaLiuRenAppDatabase,
    $YuDingEntriesTable,
    YuDingEntryDb,
    $$YuDingEntriesTableFilterComposer,
    $$YuDingEntriesTableOrderingComposer,
    $$YuDingEntriesTableAnnotationComposer,
    $$YuDingEntriesTableCreateCompanionBuilder,
    $$YuDingEntriesTableUpdateCompanionBuilder,
    (
      YuDingEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $YuDingEntriesTable, YuDingEntryDb>
    ),
    YuDingEntryDb,
    PrefetchHooks Function()> {
  $$YuDingEntriesTableTableManager(
      _$DaLiuRenAppDatabase db, $YuDingEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YuDingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YuDingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YuDingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dayJiaZiName = const Value.absent(),
            Value<String> juName = const Value.absent(),
            Value<int> juNumber = const Value.absent(),
            Value<Map<String, String>> detailsJson = const Value.absent(),
            Value<Map<String, String>> booksJson = const Value.absent(),
            Value<Set<String>> bodyJson = const Value.absent(),
            Value<String> meaning = const Value.absent(),
            Value<String> explain = const Value.absent(),
            Value<String> predication = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              YuDingEntriesCompanion(
            dayJiaZiName: dayJiaZiName,
            juName: juName,
            juNumber: juNumber,
            detailsJson: detailsJson,
            booksJson: booksJson,
            bodyJson: bodyJson,
            meaning: meaning,
            explain: explain,
            predication: predication,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dayJiaZiName,
            required String juName,
            required int juNumber,
            required Map<String, String> detailsJson,
            required Map<String, String> booksJson,
            required Set<String> bodyJson,
            required String meaning,
            required String explain,
            required String predication,
            Value<int> rowid = const Value.absent(),
          }) =>
              YuDingEntriesCompanion.insert(
            dayJiaZiName: dayJiaZiName,
            juName: juName,
            juNumber: juNumber,
            detailsJson: detailsJson,
            booksJson: booksJson,
            bodyJson: bodyJson,
            meaning: meaning,
            explain: explain,
            predication: predication,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$YuDingEntriesTableProcessedTableManager = ProcessedTableManager<
    _$DaLiuRenAppDatabase,
    $YuDingEntriesTable,
    YuDingEntryDb,
    $$YuDingEntriesTableFilterComposer,
    $$YuDingEntriesTableOrderingComposer,
    $$YuDingEntriesTableAnnotationComposer,
    $$YuDingEntriesTableCreateCompanionBuilder,
    $$YuDingEntriesTableUpdateCompanionBuilder,
    (
      YuDingEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $YuDingEntriesTable, YuDingEntryDb>
    ),
    YuDingEntryDb,
    PrefetchHooks Function()>;
typedef $$PresetPansTableCreateCompanionBuilder = PresetPansCompanion Function({
  required String dayJiaZiName,
  required String shiChenName,
  required String yinYangDun,
  required String juNumberName,
  required FourClassDataModel? fourClassJson,
  required ThreeChuanDataModel? threeChuanJson,
  required String nineZongMenName,
  Value<int> rowid,
});
typedef $$PresetPansTableUpdateCompanionBuilder = PresetPansCompanion Function({
  Value<String> dayJiaZiName,
  Value<String> shiChenName,
  Value<String> yinYangDun,
  Value<String> juNumberName,
  Value<FourClassDataModel?> fourClassJson,
  Value<ThreeChuanDataModel?> threeChuanJson,
  Value<String> nineZongMenName,
  Value<int> rowid,
});

class $$PresetPansTableFilterComposer
    extends Composer<_$DaLiuRenAppDatabase, $PresetPansTable> {
  $$PresetPansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiChenName => $composableBuilder(
      column: $table.shiChenName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yinYangDun => $composableBuilder(
      column: $table.yinYangDun, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get juNumberName => $composableBuilder(
      column: $table.juNumberName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<FourClassDataModel?, FourClassDataModel,
          String>
      get fourClassJson => $composableBuilder(
          column: $table.fourClassJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ThreeChuanDataModel?, ThreeChuanDataModel,
          String>
      get threeChuanJson => $composableBuilder(
          column: $table.threeChuanJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get nineZongMenName => $composableBuilder(
      column: $table.nineZongMenName,
      builder: (column) => ColumnFilters(column));
}

class $$PresetPansTableOrderingComposer
    extends Composer<_$DaLiuRenAppDatabase, $PresetPansTable> {
  $$PresetPansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiChenName => $composableBuilder(
      column: $table.shiChenName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yinYangDun => $composableBuilder(
      column: $table.yinYangDun, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get juNumberName => $composableBuilder(
      column: $table.juNumberName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fourClassJson => $composableBuilder(
      column: $table.fourClassJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get threeChuanJson => $composableBuilder(
      column: $table.threeChuanJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nineZongMenName => $composableBuilder(
      column: $table.nineZongMenName,
      builder: (column) => ColumnOrderings(column));
}

class $$PresetPansTableAnnotationComposer
    extends Composer<_$DaLiuRenAppDatabase, $PresetPansTable> {
  $$PresetPansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayJiaZiName => $composableBuilder(
      column: $table.dayJiaZiName, builder: (column) => column);

  GeneratedColumn<String> get shiChenName => $composableBuilder(
      column: $table.shiChenName, builder: (column) => column);

  GeneratedColumn<String> get yinYangDun => $composableBuilder(
      column: $table.yinYangDun, builder: (column) => column);

  GeneratedColumn<String> get juNumberName => $composableBuilder(
      column: $table.juNumberName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FourClassDataModel?, String>
      get fourClassJson => $composableBuilder(
          column: $table.fourClassJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThreeChuanDataModel?, String>
      get threeChuanJson => $composableBuilder(
          column: $table.threeChuanJson, builder: (column) => column);

  GeneratedColumn<String> get nineZongMenName => $composableBuilder(
      column: $table.nineZongMenName, builder: (column) => column);
}

class $$PresetPansTableTableManager extends RootTableManager<
    _$DaLiuRenAppDatabase,
    $PresetPansTable,
    PresetPanEntryDb,
    $$PresetPansTableFilterComposer,
    $$PresetPansTableOrderingComposer,
    $$PresetPansTableAnnotationComposer,
    $$PresetPansTableCreateCompanionBuilder,
    $$PresetPansTableUpdateCompanionBuilder,
    (
      PresetPanEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $PresetPansTable, PresetPanEntryDb>
    ),
    PresetPanEntryDb,
    PrefetchHooks Function()> {
  $$PresetPansTableTableManager(
      _$DaLiuRenAppDatabase db, $PresetPansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetPansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetPansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetPansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dayJiaZiName = const Value.absent(),
            Value<String> shiChenName = const Value.absent(),
            Value<String> yinYangDun = const Value.absent(),
            Value<String> juNumberName = const Value.absent(),
            Value<FourClassDataModel?> fourClassJson = const Value.absent(),
            Value<ThreeChuanDataModel?> threeChuanJson = const Value.absent(),
            Value<String> nineZongMenName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PresetPansCompanion(
            dayJiaZiName: dayJiaZiName,
            shiChenName: shiChenName,
            yinYangDun: yinYangDun,
            juNumberName: juNumberName,
            fourClassJson: fourClassJson,
            threeChuanJson: threeChuanJson,
            nineZongMenName: nineZongMenName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dayJiaZiName,
            required String shiChenName,
            required String yinYangDun,
            required String juNumberName,
            required FourClassDataModel? fourClassJson,
            required ThreeChuanDataModel? threeChuanJson,
            required String nineZongMenName,
            Value<int> rowid = const Value.absent(),
          }) =>
              PresetPansCompanion.insert(
            dayJiaZiName: dayJiaZiName,
            shiChenName: shiChenName,
            yinYangDun: yinYangDun,
            juNumberName: juNumberName,
            fourClassJson: fourClassJson,
            threeChuanJson: threeChuanJson,
            nineZongMenName: nineZongMenName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PresetPansTableProcessedTableManager = ProcessedTableManager<
    _$DaLiuRenAppDatabase,
    $PresetPansTable,
    PresetPanEntryDb,
    $$PresetPansTableFilterComposer,
    $$PresetPansTableOrderingComposer,
    $$PresetPansTableAnnotationComposer,
    $$PresetPansTableCreateCompanionBuilder,
    $$PresetPansTableUpdateCompanionBuilder,
    (
      PresetPanEntryDb,
      BaseReferences<_$DaLiuRenAppDatabase, $PresetPansTable, PresetPanEntryDb>
    ),
    PresetPanEntryDb,
    PrefetchHooks Function()>;
typedef $$DbInitializationFlagsTableCreateCompanionBuilder
    = DbInitializationFlagsCompanion Function({
  Value<String> flagKey,
  Value<bool> isSet,
  Value<int> rowid,
});
typedef $$DbInitializationFlagsTableUpdateCompanionBuilder
    = DbInitializationFlagsCompanion Function({
  Value<String> flagKey,
  Value<bool> isSet,
  Value<int> rowid,
});

class $$DbInitializationFlagsTableFilterComposer
    extends Composer<_$DaLiuRenAppDatabase, $DbInitializationFlagsTable> {
  $$DbInitializationFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get flagKey => $composableBuilder(
      column: $table.flagKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSet => $composableBuilder(
      column: $table.isSet, builder: (column) => ColumnFilters(column));
}

class $$DbInitializationFlagsTableOrderingComposer
    extends Composer<_$DaLiuRenAppDatabase, $DbInitializationFlagsTable> {
  $$DbInitializationFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get flagKey => $composableBuilder(
      column: $table.flagKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSet => $composableBuilder(
      column: $table.isSet, builder: (column) => ColumnOrderings(column));
}

class $$DbInitializationFlagsTableAnnotationComposer
    extends Composer<_$DaLiuRenAppDatabase, $DbInitializationFlagsTable> {
  $$DbInitializationFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get flagKey =>
      $composableBuilder(column: $table.flagKey, builder: (column) => column);

  GeneratedColumn<bool> get isSet =>
      $composableBuilder(column: $table.isSet, builder: (column) => column);
}

class $$DbInitializationFlagsTableTableManager extends RootTableManager<
    _$DaLiuRenAppDatabase,
    $DbInitializationFlagsTable,
    DbInitializationFlag,
    $$DbInitializationFlagsTableFilterComposer,
    $$DbInitializationFlagsTableOrderingComposer,
    $$DbInitializationFlagsTableAnnotationComposer,
    $$DbInitializationFlagsTableCreateCompanionBuilder,
    $$DbInitializationFlagsTableUpdateCompanionBuilder,
    (
      DbInitializationFlag,
      BaseReferences<_$DaLiuRenAppDatabase, $DbInitializationFlagsTable,
          DbInitializationFlag>
    ),
    DbInitializationFlag,
    PrefetchHooks Function()> {
  $$DbInitializationFlagsTableTableManager(
      _$DaLiuRenAppDatabase db, $DbInitializationFlagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbInitializationFlagsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DbInitializationFlagsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbInitializationFlagsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> flagKey = const Value.absent(),
            Value<bool> isSet = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DbInitializationFlagsCompanion(
            flagKey: flagKey,
            isSet: isSet,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> flagKey = const Value.absent(),
            Value<bool> isSet = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DbInitializationFlagsCompanion.insert(
            flagKey: flagKey,
            isSet: isSet,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DbInitializationFlagsTableProcessedTableManager
    = ProcessedTableManager<
        _$DaLiuRenAppDatabase,
        $DbInitializationFlagsTable,
        DbInitializationFlag,
        $$DbInitializationFlagsTableFilterComposer,
        $$DbInitializationFlagsTableOrderingComposer,
        $$DbInitializationFlagsTableAnnotationComposer,
        $$DbInitializationFlagsTableCreateCompanionBuilder,
        $$DbInitializationFlagsTableUpdateCompanionBuilder,
        (
          DbInitializationFlag,
          BaseReferences<_$DaLiuRenAppDatabase, $DbInitializationFlagsTable,
              DbInitializationFlag>
        ),
        DbInitializationFlag,
        PrefetchHooks Function()>;

class $DaLiuRenAppDatabaseManager {
  final _$DaLiuRenAppDatabase _db;
  $DaLiuRenAppDatabaseManager(this._db);
  $$JuMappingsTableTableManager get juMappings =>
      $$JuMappingsTableTableManager(_db, _db.juMappings);
  $$YuDingEntriesTableTableManager get yuDingEntries =>
      $$YuDingEntriesTableTableManager(_db, _db.yuDingEntries);
  $$PresetPansTableTableManager get presetPans =>
      $$PresetPansTableTableManager(_db, _db.presetPans);
  $$DbInitializationFlagsTableTableManager get dbInitializationFlags =>
      $$DbInitializationFlagsTableTableManager(_db, _db.dbInitializationFlags);
}
