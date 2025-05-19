// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_info_database.dart';

// ignore_for_file: type=lint
class $RegionsTable extends Regions
    with TableInfo<$RegionsTable, RegionDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _translationsMeta =
      const VerificationMeta('translations');
  @override
  late final GeneratedColumn<String> translations = GeneratedColumn<String>(
      'translations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
      'flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _wikiDataIdMeta =
      const VerificationMeta('wikiDataId');
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
      'wiki_data_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, translations, createdAt, updatedAt, flag, wikiDataId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regions';
  @override
  VerificationContext validateIntegrity(Insertable<RegionDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('translations')) {
      context.handle(
          _translationsMeta,
          translations.isAcceptableOrUnknown(
              data['translations']!, _translationsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
          _wikiDataIdMeta,
          wikiDataId.isAcceptableOrUnknown(
              data['wiki_data_id']!, _wikiDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegionDataModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegionDataModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      translations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translations']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flag'])!,
      wikiDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wiki_data_id']),
    );
  }

  @override
  $RegionsTable createAlias(String alias) {
    return $RegionsTable(attachedDatabase, alias);
  }
}

class RegionDataModel extends DataClass implements Insertable<RegionDataModel> {
  final int id;
  final String name;
  final String? translations;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;
  const RegionDataModel(
      {required this.id,
      required this.name,
      this.translations,
      this.createdAt,
      required this.updatedAt,
      required this.flag,
      this.wikiDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || translations != null) {
      map['translations'] = Variable<String>(translations);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  RegionsCompanion toCompanion(bool nullToAbsent) {
    return RegionsCompanion(
      id: Value(id),
      name: Value(name),
      translations: translations == null && nullToAbsent
          ? const Value.absent()
          : Value(translations),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      flag: Value(flag),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory RegionDataModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegionDataModel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      translations: serializer.fromJson<String?>(json['translations']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      flag: serializer.fromJson<int>(json['flag']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'translations': serializer.toJson<String?>(translations),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'flag': serializer.toJson<int>(flag),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  RegionDataModel copyWith(
          {int? id,
          String? name,
          Value<String?> translations = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          int? flag,
          Value<String?> wikiDataId = const Value.absent()}) =>
      RegionDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        translations:
            translations.present ? translations.value : this.translations,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        flag: flag ?? this.flag,
        wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
      );
  RegionDataModel copyWithCompanion(RegionsCompanion data) {
    return RegionDataModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      translations: data.translations.present
          ? data.translations.value
          : this.translations,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      flag: data.flag.present ? data.flag.value : this.flag,
      wikiDataId:
          data.wikiDataId.present ? data.wikiDataId.value : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegionDataModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translations: $translations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, translations, createdAt, updatedAt, flag, wikiDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegionDataModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.translations == this.translations &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.flag == this.flag &&
          other.wikiDataId == this.wikiDataId);
}

class RegionsCompanion extends UpdateCompanion<RegionDataModel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> translations;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> flag;
  final Value<String?> wikiDataId;
  const RegionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.translations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  RegionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.translations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RegionDataModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? translations,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? flag,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (translations != null) 'translations': translations,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (flag != null) 'flag': flag,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  RegionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? translations,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? flag,
      Value<String?>? wikiDataId}) {
    return RegionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      translations: translations ?? this.translations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flag: flag ?? this.flag,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (translations.present) {
      map['translations'] = Variable<String>(translations.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translations: $translations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

class $SubregionsTable extends Subregions
    with TableInfo<$SubregionsTable, SubregionDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubregionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _translationsMeta =
      const VerificationMeta('translations');
  @override
  late final GeneratedColumn<String> translations = GeneratedColumn<String>(
      'translations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionIdMeta =
      const VerificationMeta('regionId');
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
      'region_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES regions (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
      'flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _wikiDataIdMeta =
      const VerificationMeta('wikiDataId');
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
      'wiki_data_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        translations,
        regionId,
        createdAt,
        updatedAt,
        flag,
        wikiDataId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subregions';
  @override
  VerificationContext validateIntegrity(Insertable<SubregionDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('translations')) {
      context.handle(
          _translationsMeta,
          translations.isAcceptableOrUnknown(
              data['translations']!, _translationsMeta));
    }
    if (data.containsKey('region_id')) {
      context.handle(_regionIdMeta,
          regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta));
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
          _wikiDataIdMeta,
          wikiDataId.isAcceptableOrUnknown(
              data['wiki_data_id']!, _wikiDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubregionDataModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubregionDataModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      translations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translations']),
      regionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}region_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flag'])!,
      wikiDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wiki_data_id']),
    );
  }

  @override
  $SubregionsTable createAlias(String alias) {
    return $SubregionsTable(attachedDatabase, alias);
  }
}

class SubregionDataModel extends DataClass
    implements Insertable<SubregionDataModel> {
  final int id;
  final String name;
  final String? translations;
  final int regionId;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;
  const SubregionDataModel(
      {required this.id,
      required this.name,
      this.translations,
      required this.regionId,
      this.createdAt,
      required this.updatedAt,
      required this.flag,
      this.wikiDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || translations != null) {
      map['translations'] = Variable<String>(translations);
    }
    map['region_id'] = Variable<int>(regionId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  SubregionsCompanion toCompanion(bool nullToAbsent) {
    return SubregionsCompanion(
      id: Value(id),
      name: Value(name),
      translations: translations == null && nullToAbsent
          ? const Value.absent()
          : Value(translations),
      regionId: Value(regionId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      flag: Value(flag),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory SubregionDataModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubregionDataModel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      translations: serializer.fromJson<String?>(json['translations']),
      regionId: serializer.fromJson<int>(json['regionId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      flag: serializer.fromJson<int>(json['flag']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'translations': serializer.toJson<String?>(translations),
      'regionId': serializer.toJson<int>(regionId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'flag': serializer.toJson<int>(flag),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  SubregionDataModel copyWith(
          {int? id,
          String? name,
          Value<String?> translations = const Value.absent(),
          int? regionId,
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          int? flag,
          Value<String?> wikiDataId = const Value.absent()}) =>
      SubregionDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        translations:
            translations.present ? translations.value : this.translations,
        regionId: regionId ?? this.regionId,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        flag: flag ?? this.flag,
        wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
      );
  SubregionDataModel copyWithCompanion(SubregionsCompanion data) {
    return SubregionDataModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      translations: data.translations.present
          ? data.translations.value
          : this.translations,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      flag: data.flag.present ? data.flag.value : this.flag,
      wikiDataId:
          data.wikiDataId.present ? data.wikiDataId.value : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubregionDataModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translations: $translations, ')
          ..write('regionId: $regionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, translations, regionId, createdAt, updatedAt, flag, wikiDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubregionDataModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.translations == this.translations &&
          other.regionId == this.regionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.flag == this.flag &&
          other.wikiDataId == this.wikiDataId);
}

class SubregionsCompanion extends UpdateCompanion<SubregionDataModel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> translations;
  final Value<int> regionId;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> flag;
  final Value<String?> wikiDataId;
  const SubregionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.translations = const Value.absent(),
    this.regionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  SubregionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.translations = const Value.absent(),
    required int regionId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  })  : name = Value(name),
        regionId = Value(regionId);
  static Insertable<SubregionDataModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? translations,
    Expression<int>? regionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? flag,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (translations != null) 'translations': translations,
      if (regionId != null) 'region_id': regionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (flag != null) 'flag': flag,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  SubregionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? translations,
      Value<int>? regionId,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? flag,
      Value<String?>? wikiDataId}) {
    return SubregionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      translations: translations ?? this.translations,
      regionId: regionId ?? this.regionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flag: flag ?? this.flag,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (translations.present) {
      map['translations'] = Variable<String>(translations.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubregionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('translations: $translations, ')
          ..write('regionId: $regionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

class $CountriesTable extends Countries
    with TableInfo<$CountriesTable, CountryDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iso3Meta = const VerificationMeta('iso3');
  @override
  late final GeneratedColumn<String> iso3 = GeneratedColumn<String>(
      'iso3', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _numericCodeMeta =
      const VerificationMeta('numericCode');
  @override
  late final GeneratedColumn<String> numericCode = GeneratedColumn<String>(
      'numeric_code', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _iso2Meta = const VerificationMeta('iso2');
  @override
  late final GeneratedColumn<String> iso2 = GeneratedColumn<String>(
      'iso2', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _phonecodeMeta =
      const VerificationMeta('phonecode');
  @override
  late final GeneratedColumn<String> phonecode = GeneratedColumn<String>(
      'phonecode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capitalMeta =
      const VerificationMeta('capital');
  @override
  late final GeneratedColumn<String> capital = GeneratedColumn<String>(
      'capital', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyNameMeta =
      const VerificationMeta('currencyName');
  @override
  late final GeneratedColumn<String> currencyName = GeneratedColumn<String>(
      'currency_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tldMeta = const VerificationMeta('tld');
  @override
  late final GeneratedColumn<String> tld = GeneratedColumn<String>(
      'tld', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nativeMeta = const VerificationMeta('native');
  @override
  late final GeneratedColumn<String> native = GeneratedColumn<String>(
      'native', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionIdMeta =
      const VerificationMeta('regionId');
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
      'region_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES regions (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _subregionMeta =
      const VerificationMeta('subregion');
  @override
  late final GeneratedColumn<String> subregion = GeneratedColumn<String>(
      'subregion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subregionIdMeta =
      const VerificationMeta('subregionId');
  @override
  late final GeneratedColumn<int> subregionId = GeneratedColumn<int>(
      'subregion_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subregions (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _nationalityMeta =
      const VerificationMeta('nationality');
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
      'nationality', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timezonesMeta =
      const VerificationMeta('timezones');
  @override
  late final GeneratedColumn<String> timezones = GeneratedColumn<String>(
      'timezones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _translationsMeta =
      const VerificationMeta('translations');
  @override
  late final GeneratedColumn<String> translations = GeneratedColumn<String>(
      'translations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _emojiUMeta = const VerificationMeta('emojiU');
  @override
  late final GeneratedColumn<String> emojiU = GeneratedColumn<String>(
      'emoji_u', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
      'flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _wikiDataIdMeta =
      const VerificationMeta('wikiDataId');
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
      'wiki_data_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iso3,
        numericCode,
        iso2,
        phonecode,
        capital,
        currency,
        currencyName,
        currencySymbol,
        tld,
        native,
        region,
        regionId,
        subregion,
        subregionId,
        nationality,
        timezones,
        translations,
        latitude,
        longitude,
        emoji,
        emojiU,
        createdAt,
        updatedAt,
        flag,
        wikiDataId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countries';
  @override
  VerificationContext validateIntegrity(Insertable<CountryDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('iso3')) {
      context.handle(
          _iso3Meta, iso3.isAcceptableOrUnknown(data['iso3']!, _iso3Meta));
    }
    if (data.containsKey('numeric_code')) {
      context.handle(
          _numericCodeMeta,
          numericCode.isAcceptableOrUnknown(
              data['numeric_code']!, _numericCodeMeta));
    }
    if (data.containsKey('iso2')) {
      context.handle(
          _iso2Meta, iso2.isAcceptableOrUnknown(data['iso2']!, _iso2Meta));
    }
    if (data.containsKey('phonecode')) {
      context.handle(_phonecodeMeta,
          phonecode.isAcceptableOrUnknown(data['phonecode']!, _phonecodeMeta));
    }
    if (data.containsKey('capital')) {
      context.handle(_capitalMeta,
          capital.isAcceptableOrUnknown(data['capital']!, _capitalMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('currency_name')) {
      context.handle(
          _currencyNameMeta,
          currencyName.isAcceptableOrUnknown(
              data['currency_name']!, _currencyNameMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('tld')) {
      context.handle(
          _tldMeta, tld.isAcceptableOrUnknown(data['tld']!, _tldMeta));
    }
    if (data.containsKey('native')) {
      context.handle(_nativeMeta,
          native.isAcceptableOrUnknown(data['native']!, _nativeMeta));
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    }
    if (data.containsKey('region_id')) {
      context.handle(_regionIdMeta,
          regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta));
    }
    if (data.containsKey('subregion')) {
      context.handle(_subregionMeta,
          subregion.isAcceptableOrUnknown(data['subregion']!, _subregionMeta));
    }
    if (data.containsKey('subregion_id')) {
      context.handle(
          _subregionIdMeta,
          subregionId.isAcceptableOrUnknown(
              data['subregion_id']!, _subregionIdMeta));
    }
    if (data.containsKey('nationality')) {
      context.handle(
          _nationalityMeta,
          nationality.isAcceptableOrUnknown(
              data['nationality']!, _nationalityMeta));
    }
    if (data.containsKey('timezones')) {
      context.handle(_timezonesMeta,
          timezones.isAcceptableOrUnknown(data['timezones']!, _timezonesMeta));
    }
    if (data.containsKey('translations')) {
      context.handle(
          _translationsMeta,
          translations.isAcceptableOrUnknown(
              data['translations']!, _translationsMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('emoji_u')) {
      context.handle(_emojiUMeta,
          emojiU.isAcceptableOrUnknown(data['emoji_u']!, _emojiUMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
          _wikiDataIdMeta,
          wikiDataId.isAcceptableOrUnknown(
              data['wiki_data_id']!, _wikiDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CountryDataModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryDataModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iso3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iso3']),
      numericCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numeric_code']),
      iso2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iso2']),
      phonecode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phonecode']),
      capital: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capital']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      currencyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_name']),
      currencySymbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_symbol']),
      tld: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tld']),
      native: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}native']),
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region']),
      regionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}region_id']),
      subregion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subregion']),
      subregionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subregion_id']),
      nationality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nationality']),
      timezones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezones']),
      translations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translations']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      emojiU: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji_u']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flag'])!,
      wikiDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wiki_data_id']),
    );
  }

  @override
  $CountriesTable createAlias(String alias) {
    return $CountriesTable(attachedDatabase, alias);
  }
}

class CountryDataModel extends DataClass
    implements Insertable<CountryDataModel> {
  final int id;
  final String name;
  final String? iso3;
  final String? numericCode;
  final String? iso2;
  final String? phonecode;
  final String? capital;
  final String? currency;
  final String? currencyName;
  final String? currencySymbol;
  final String? tld;
  final String? native;
  final String? region;
  final int? regionId;
  final String? subregion;
  final int? subregionId;
  final String? nationality;
  final String? timezones;
  final String? translations;
  final double? latitude;
  final double? longitude;
  final String? emoji;
  final String? emojiU;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;
  const CountryDataModel(
      {required this.id,
      required this.name,
      this.iso3,
      this.numericCode,
      this.iso2,
      this.phonecode,
      this.capital,
      this.currency,
      this.currencyName,
      this.currencySymbol,
      this.tld,
      this.native,
      this.region,
      this.regionId,
      this.subregion,
      this.subregionId,
      this.nationality,
      this.timezones,
      this.translations,
      this.latitude,
      this.longitude,
      this.emoji,
      this.emojiU,
      this.createdAt,
      required this.updatedAt,
      required this.flag,
      this.wikiDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iso3 != null) {
      map['iso3'] = Variable<String>(iso3);
    }
    if (!nullToAbsent || numericCode != null) {
      map['numeric_code'] = Variable<String>(numericCode);
    }
    if (!nullToAbsent || iso2 != null) {
      map['iso2'] = Variable<String>(iso2);
    }
    if (!nullToAbsent || phonecode != null) {
      map['phonecode'] = Variable<String>(phonecode);
    }
    if (!nullToAbsent || capital != null) {
      map['capital'] = Variable<String>(capital);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || currencyName != null) {
      map['currency_name'] = Variable<String>(currencyName);
    }
    if (!nullToAbsent || currencySymbol != null) {
      map['currency_symbol'] = Variable<String>(currencySymbol);
    }
    if (!nullToAbsent || tld != null) {
      map['tld'] = Variable<String>(tld);
    }
    if (!nullToAbsent || native != null) {
      map['native'] = Variable<String>(native);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<int>(regionId);
    }
    if (!nullToAbsent || subregion != null) {
      map['subregion'] = Variable<String>(subregion);
    }
    if (!nullToAbsent || subregionId != null) {
      map['subregion_id'] = Variable<int>(subregionId);
    }
    if (!nullToAbsent || nationality != null) {
      map['nationality'] = Variable<String>(nationality);
    }
    if (!nullToAbsent || timezones != null) {
      map['timezones'] = Variable<String>(timezones);
    }
    if (!nullToAbsent || translations != null) {
      map['translations'] = Variable<String>(translations);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    if (!nullToAbsent || emojiU != null) {
      map['emoji_u'] = Variable<String>(emojiU);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  CountriesCompanion toCompanion(bool nullToAbsent) {
    return CountriesCompanion(
      id: Value(id),
      name: Value(name),
      iso3: iso3 == null && nullToAbsent ? const Value.absent() : Value(iso3),
      numericCode: numericCode == null && nullToAbsent
          ? const Value.absent()
          : Value(numericCode),
      iso2: iso2 == null && nullToAbsent ? const Value.absent() : Value(iso2),
      phonecode: phonecode == null && nullToAbsent
          ? const Value.absent()
          : Value(phonecode),
      capital: capital == null && nullToAbsent
          ? const Value.absent()
          : Value(capital),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      currencyName: currencyName == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyName),
      currencySymbol: currencySymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(currencySymbol),
      tld: tld == null && nullToAbsent ? const Value.absent() : Value(tld),
      native:
          native == null && nullToAbsent ? const Value.absent() : Value(native),
      region:
          region == null && nullToAbsent ? const Value.absent() : Value(region),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      subregion: subregion == null && nullToAbsent
          ? const Value.absent()
          : Value(subregion),
      subregionId: subregionId == null && nullToAbsent
          ? const Value.absent()
          : Value(subregionId),
      nationality: nationality == null && nullToAbsent
          ? const Value.absent()
          : Value(nationality),
      timezones: timezones == null && nullToAbsent
          ? const Value.absent()
          : Value(timezones),
      translations: translations == null && nullToAbsent
          ? const Value.absent()
          : Value(translations),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      emoji:
          emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      emojiU:
          emojiU == null && nullToAbsent ? const Value.absent() : Value(emojiU),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      flag: Value(flag),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory CountryDataModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryDataModel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iso3: serializer.fromJson<String?>(json['iso3']),
      numericCode: serializer.fromJson<String?>(json['numericCode']),
      iso2: serializer.fromJson<String?>(json['iso2']),
      phonecode: serializer.fromJson<String?>(json['phonecode']),
      capital: serializer.fromJson<String?>(json['capital']),
      currency: serializer.fromJson<String?>(json['currency']),
      currencyName: serializer.fromJson<String?>(json['currencyName']),
      currencySymbol: serializer.fromJson<String?>(json['currencySymbol']),
      tld: serializer.fromJson<String?>(json['tld']),
      native: serializer.fromJson<String?>(json['native']),
      region: serializer.fromJson<String?>(json['region']),
      regionId: serializer.fromJson<int?>(json['regionId']),
      subregion: serializer.fromJson<String?>(json['subregion']),
      subregionId: serializer.fromJson<int?>(json['subregionId']),
      nationality: serializer.fromJson<String?>(json['nationality']),
      timezones: serializer.fromJson<String?>(json['timezones']),
      translations: serializer.fromJson<String?>(json['translations']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      emojiU: serializer.fromJson<String?>(json['emojiU']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      flag: serializer.fromJson<int>(json['flag']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iso3': serializer.toJson<String?>(iso3),
      'numericCode': serializer.toJson<String?>(numericCode),
      'iso2': serializer.toJson<String?>(iso2),
      'phonecode': serializer.toJson<String?>(phonecode),
      'capital': serializer.toJson<String?>(capital),
      'currency': serializer.toJson<String?>(currency),
      'currencyName': serializer.toJson<String?>(currencyName),
      'currencySymbol': serializer.toJson<String?>(currencySymbol),
      'tld': serializer.toJson<String?>(tld),
      'native': serializer.toJson<String?>(native),
      'region': serializer.toJson<String?>(region),
      'regionId': serializer.toJson<int?>(regionId),
      'subregion': serializer.toJson<String?>(subregion),
      'subregionId': serializer.toJson<int?>(subregionId),
      'nationality': serializer.toJson<String?>(nationality),
      'timezones': serializer.toJson<String?>(timezones),
      'translations': serializer.toJson<String?>(translations),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'emoji': serializer.toJson<String?>(emoji),
      'emojiU': serializer.toJson<String?>(emojiU),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'flag': serializer.toJson<int>(flag),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  CountryDataModel copyWith(
          {int? id,
          String? name,
          Value<String?> iso3 = const Value.absent(),
          Value<String?> numericCode = const Value.absent(),
          Value<String?> iso2 = const Value.absent(),
          Value<String?> phonecode = const Value.absent(),
          Value<String?> capital = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> currencyName = const Value.absent(),
          Value<String?> currencySymbol = const Value.absent(),
          Value<String?> tld = const Value.absent(),
          Value<String?> native = const Value.absent(),
          Value<String?> region = const Value.absent(),
          Value<int?> regionId = const Value.absent(),
          Value<String?> subregion = const Value.absent(),
          Value<int?> subregionId = const Value.absent(),
          Value<String?> nationality = const Value.absent(),
          Value<String?> timezones = const Value.absent(),
          Value<String?> translations = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> emoji = const Value.absent(),
          Value<String?> emojiU = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          int? flag,
          Value<String?> wikiDataId = const Value.absent()}) =>
      CountryDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iso3: iso3.present ? iso3.value : this.iso3,
        numericCode: numericCode.present ? numericCode.value : this.numericCode,
        iso2: iso2.present ? iso2.value : this.iso2,
        phonecode: phonecode.present ? phonecode.value : this.phonecode,
        capital: capital.present ? capital.value : this.capital,
        currency: currency.present ? currency.value : this.currency,
        currencyName:
            currencyName.present ? currencyName.value : this.currencyName,
        currencySymbol:
            currencySymbol.present ? currencySymbol.value : this.currencySymbol,
        tld: tld.present ? tld.value : this.tld,
        native: native.present ? native.value : this.native,
        region: region.present ? region.value : this.region,
        regionId: regionId.present ? regionId.value : this.regionId,
        subregion: subregion.present ? subregion.value : this.subregion,
        subregionId: subregionId.present ? subregionId.value : this.subregionId,
        nationality: nationality.present ? nationality.value : this.nationality,
        timezones: timezones.present ? timezones.value : this.timezones,
        translations:
            translations.present ? translations.value : this.translations,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        emoji: emoji.present ? emoji.value : this.emoji,
        emojiU: emojiU.present ? emojiU.value : this.emojiU,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        flag: flag ?? this.flag,
        wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
      );
  CountryDataModel copyWithCompanion(CountriesCompanion data) {
    return CountryDataModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iso3: data.iso3.present ? data.iso3.value : this.iso3,
      numericCode:
          data.numericCode.present ? data.numericCode.value : this.numericCode,
      iso2: data.iso2.present ? data.iso2.value : this.iso2,
      phonecode: data.phonecode.present ? data.phonecode.value : this.phonecode,
      capital: data.capital.present ? data.capital.value : this.capital,
      currency: data.currency.present ? data.currency.value : this.currency,
      currencyName: data.currencyName.present
          ? data.currencyName.value
          : this.currencyName,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      tld: data.tld.present ? data.tld.value : this.tld,
      native: data.native.present ? data.native.value : this.native,
      region: data.region.present ? data.region.value : this.region,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      subregion: data.subregion.present ? data.subregion.value : this.subregion,
      subregionId:
          data.subregionId.present ? data.subregionId.value : this.subregionId,
      nationality:
          data.nationality.present ? data.nationality.value : this.nationality,
      timezones: data.timezones.present ? data.timezones.value : this.timezones,
      translations: data.translations.present
          ? data.translations.value
          : this.translations,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      emojiU: data.emojiU.present ? data.emojiU.value : this.emojiU,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      flag: data.flag.present ? data.flag.value : this.flag,
      wikiDataId:
          data.wikiDataId.present ? data.wikiDataId.value : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryDataModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iso3: $iso3, ')
          ..write('numericCode: $numericCode, ')
          ..write('iso2: $iso2, ')
          ..write('phonecode: $phonecode, ')
          ..write('capital: $capital, ')
          ..write('currency: $currency, ')
          ..write('currencyName: $currencyName, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('tld: $tld, ')
          ..write('native: $native, ')
          ..write('region: $region, ')
          ..write('regionId: $regionId, ')
          ..write('subregion: $subregion, ')
          ..write('subregionId: $subregionId, ')
          ..write('nationality: $nationality, ')
          ..write('timezones: $timezones, ')
          ..write('translations: $translations, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('emoji: $emoji, ')
          ..write('emojiU: $emojiU, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        iso3,
        numericCode,
        iso2,
        phonecode,
        capital,
        currency,
        currencyName,
        currencySymbol,
        tld,
        native,
        region,
        regionId,
        subregion,
        subregionId,
        nationality,
        timezones,
        translations,
        latitude,
        longitude,
        emoji,
        emojiU,
        createdAt,
        updatedAt,
        flag,
        wikiDataId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryDataModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.iso3 == this.iso3 &&
          other.numericCode == this.numericCode &&
          other.iso2 == this.iso2 &&
          other.phonecode == this.phonecode &&
          other.capital == this.capital &&
          other.currency == this.currency &&
          other.currencyName == this.currencyName &&
          other.currencySymbol == this.currencySymbol &&
          other.tld == this.tld &&
          other.native == this.native &&
          other.region == this.region &&
          other.regionId == this.regionId &&
          other.subregion == this.subregion &&
          other.subregionId == this.subregionId &&
          other.nationality == this.nationality &&
          other.timezones == this.timezones &&
          other.translations == this.translations &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.emoji == this.emoji &&
          other.emojiU == this.emojiU &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.flag == this.flag &&
          other.wikiDataId == this.wikiDataId);
}

class CountriesCompanion extends UpdateCompanion<CountryDataModel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iso3;
  final Value<String?> numericCode;
  final Value<String?> iso2;
  final Value<String?> phonecode;
  final Value<String?> capital;
  final Value<String?> currency;
  final Value<String?> currencyName;
  final Value<String?> currencySymbol;
  final Value<String?> tld;
  final Value<String?> native;
  final Value<String?> region;
  final Value<int?> regionId;
  final Value<String?> subregion;
  final Value<int?> subregionId;
  final Value<String?> nationality;
  final Value<String?> timezones;
  final Value<String?> translations;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> emoji;
  final Value<String?> emojiU;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> flag;
  final Value<String?> wikiDataId;
  const CountriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iso3 = const Value.absent(),
    this.numericCode = const Value.absent(),
    this.iso2 = const Value.absent(),
    this.phonecode = const Value.absent(),
    this.capital = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyName = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.tld = const Value.absent(),
    this.native = const Value.absent(),
    this.region = const Value.absent(),
    this.regionId = const Value.absent(),
    this.subregion = const Value.absent(),
    this.subregionId = const Value.absent(),
    this.nationality = const Value.absent(),
    this.timezones = const Value.absent(),
    this.translations = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.emoji = const Value.absent(),
    this.emojiU = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  CountriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iso3 = const Value.absent(),
    this.numericCode = const Value.absent(),
    this.iso2 = const Value.absent(),
    this.phonecode = const Value.absent(),
    this.capital = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyName = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.tld = const Value.absent(),
    this.native = const Value.absent(),
    this.region = const Value.absent(),
    this.regionId = const Value.absent(),
    this.subregion = const Value.absent(),
    this.subregionId = const Value.absent(),
    this.nationality = const Value.absent(),
    this.timezones = const Value.absent(),
    this.translations = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.emoji = const Value.absent(),
    this.emojiU = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CountryDataModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iso3,
    Expression<String>? numericCode,
    Expression<String>? iso2,
    Expression<String>? phonecode,
    Expression<String>? capital,
    Expression<String>? currency,
    Expression<String>? currencyName,
    Expression<String>? currencySymbol,
    Expression<String>? tld,
    Expression<String>? native,
    Expression<String>? region,
    Expression<int>? regionId,
    Expression<String>? subregion,
    Expression<int>? subregionId,
    Expression<String>? nationality,
    Expression<String>? timezones,
    Expression<String>? translations,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? emoji,
    Expression<String>? emojiU,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? flag,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iso3 != null) 'iso3': iso3,
      if (numericCode != null) 'numeric_code': numericCode,
      if (iso2 != null) 'iso2': iso2,
      if (phonecode != null) 'phonecode': phonecode,
      if (capital != null) 'capital': capital,
      if (currency != null) 'currency': currency,
      if (currencyName != null) 'currency_name': currencyName,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (tld != null) 'tld': tld,
      if (native != null) 'native': native,
      if (region != null) 'region': region,
      if (regionId != null) 'region_id': regionId,
      if (subregion != null) 'subregion': subregion,
      if (subregionId != null) 'subregion_id': subregionId,
      if (nationality != null) 'nationality': nationality,
      if (timezones != null) 'timezones': timezones,
      if (translations != null) 'translations': translations,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (emoji != null) 'emoji': emoji,
      if (emojiU != null) 'emoji_u': emojiU,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (flag != null) 'flag': flag,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  CountriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? iso3,
      Value<String?>? numericCode,
      Value<String?>? iso2,
      Value<String?>? phonecode,
      Value<String?>? capital,
      Value<String?>? currency,
      Value<String?>? currencyName,
      Value<String?>? currencySymbol,
      Value<String?>? tld,
      Value<String?>? native,
      Value<String?>? region,
      Value<int?>? regionId,
      Value<String?>? subregion,
      Value<int?>? subregionId,
      Value<String?>? nationality,
      Value<String?>? timezones,
      Value<String?>? translations,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? emoji,
      Value<String?>? emojiU,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? flag,
      Value<String?>? wikiDataId}) {
    return CountriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iso3: iso3 ?? this.iso3,
      numericCode: numericCode ?? this.numericCode,
      iso2: iso2 ?? this.iso2,
      phonecode: phonecode ?? this.phonecode,
      capital: capital ?? this.capital,
      currency: currency ?? this.currency,
      currencyName: currencyName ?? this.currencyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      tld: tld ?? this.tld,
      native: native ?? this.native,
      region: region ?? this.region,
      regionId: regionId ?? this.regionId,
      subregion: subregion ?? this.subregion,
      subregionId: subregionId ?? this.subregionId,
      nationality: nationality ?? this.nationality,
      timezones: timezones ?? this.timezones,
      translations: translations ?? this.translations,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      emoji: emoji ?? this.emoji,
      emojiU: emojiU ?? this.emojiU,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flag: flag ?? this.flag,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iso3.present) {
      map['iso3'] = Variable<String>(iso3.value);
    }
    if (numericCode.present) {
      map['numeric_code'] = Variable<String>(numericCode.value);
    }
    if (iso2.present) {
      map['iso2'] = Variable<String>(iso2.value);
    }
    if (phonecode.present) {
      map['phonecode'] = Variable<String>(phonecode.value);
    }
    if (capital.present) {
      map['capital'] = Variable<String>(capital.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currencyName.present) {
      map['currency_name'] = Variable<String>(currencyName.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (tld.present) {
      map['tld'] = Variable<String>(tld.value);
    }
    if (native.present) {
      map['native'] = Variable<String>(native.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (subregion.present) {
      map['subregion'] = Variable<String>(subregion.value);
    }
    if (subregionId.present) {
      map['subregion_id'] = Variable<int>(subregionId.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (timezones.present) {
      map['timezones'] = Variable<String>(timezones.value);
    }
    if (translations.present) {
      map['translations'] = Variable<String>(translations.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (emojiU.present) {
      map['emoji_u'] = Variable<String>(emojiU.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iso3: $iso3, ')
          ..write('numericCode: $numericCode, ')
          ..write('iso2: $iso2, ')
          ..write('phonecode: $phonecode, ')
          ..write('capital: $capital, ')
          ..write('currency: $currency, ')
          ..write('currencyName: $currencyName, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('tld: $tld, ')
          ..write('native: $native, ')
          ..write('region: $region, ')
          ..write('regionId: $regionId, ')
          ..write('subregion: $subregion, ')
          ..write('subregionId: $subregionId, ')
          ..write('nationality: $nationality, ')
          ..write('timezones: $timezones, ')
          ..write('translations: $translations, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('emoji: $emoji, ')
          ..write('emojiU: $emojiU, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

class $StatesTable extends States with TableInfo<$StatesTable, StateDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _countryIdMeta =
      const VerificationMeta('countryId');
  @override
  late final GeneratedColumn<int> countryId = GeneratedColumn<int>(
      'country_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES countries (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fipsCodeMeta =
      const VerificationMeta('fipsCode');
  @override
  late final GeneratedColumn<String> fipsCode = GeneratedColumn<String>(
      'fips_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iso2Meta = const VerificationMeta('iso2');
  @override
  late final GeneratedColumn<String> iso2 = GeneratedColumn<String>(
      'iso2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
      'flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _wikiDataIdMeta =
      const VerificationMeta('wikiDataId');
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
      'wiki_data_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        countryId,
        countryCode,
        fipsCode,
        iso2,
        type,
        level,
        parentId,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        flag,
        wikiDataId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'states';
  @override
  VerificationContext validateIntegrity(Insertable<StateDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(_countryIdMeta,
          countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta));
    } else if (isInserting) {
      context.missing(_countryIdMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('fips_code')) {
      context.handle(_fipsCodeMeta,
          fipsCode.isAcceptableOrUnknown(data['fips_code']!, _fipsCodeMeta));
    }
    if (data.containsKey('iso2')) {
      context.handle(
          _iso2Meta, iso2.isAcceptableOrUnknown(data['iso2']!, _iso2Meta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
          _wikiDataIdMeta,
          wikiDataId.isAcceptableOrUnknown(
              data['wiki_data_id']!, _wikiDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StateDataModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StateDataModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      countryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}country_id'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      fipsCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fips_code']),
      iso2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iso2']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flag'])!,
      wikiDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wiki_data_id']),
    );
  }

  @override
  $StatesTable createAlias(String alias) {
    return $StatesTable(attachedDatabase, alias);
  }
}

class StateDataModel extends DataClass implements Insertable<StateDataModel> {
  final int id;
  final String name;
  final int countryId;
  final String countryCode;
  final String? fipsCode;
  final String? iso2;
  final String? type;
  final int? level;
  final int? parentId;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;
  const StateDataModel(
      {required this.id,
      required this.name,
      required this.countryId,
      required this.countryCode,
      this.fipsCode,
      this.iso2,
      this.type,
      this.level,
      this.parentId,
      this.latitude,
      this.longitude,
      this.createdAt,
      required this.updatedAt,
      required this.flag,
      this.wikiDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['country_id'] = Variable<int>(countryId);
    map['country_code'] = Variable<String>(countryCode);
    if (!nullToAbsent || fipsCode != null) {
      map['fips_code'] = Variable<String>(fipsCode);
    }
    if (!nullToAbsent || iso2 != null) {
      map['iso2'] = Variable<String>(iso2);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  StatesCompanion toCompanion(bool nullToAbsent) {
    return StatesCompanion(
      id: Value(id),
      name: Value(name),
      countryId: Value(countryId),
      countryCode: Value(countryCode),
      fipsCode: fipsCode == null && nullToAbsent
          ? const Value.absent()
          : Value(fipsCode),
      iso2: iso2 == null && nullToAbsent ? const Value.absent() : Value(iso2),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      level:
          level == null && nullToAbsent ? const Value.absent() : Value(level),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      flag: Value(flag),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory StateDataModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StateDataModel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      countryId: serializer.fromJson<int>(json['countryId']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      fipsCode: serializer.fromJson<String?>(json['fipsCode']),
      iso2: serializer.fromJson<String?>(json['iso2']),
      type: serializer.fromJson<String?>(json['type']),
      level: serializer.fromJson<int?>(json['level']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      flag: serializer.fromJson<int>(json['flag']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'countryId': serializer.toJson<int>(countryId),
      'countryCode': serializer.toJson<String>(countryCode),
      'fipsCode': serializer.toJson<String?>(fipsCode),
      'iso2': serializer.toJson<String?>(iso2),
      'type': serializer.toJson<String?>(type),
      'level': serializer.toJson<int?>(level),
      'parentId': serializer.toJson<int?>(parentId),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'flag': serializer.toJson<int>(flag),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  StateDataModel copyWith(
          {int? id,
          String? name,
          int? countryId,
          String? countryCode,
          Value<String?> fipsCode = const Value.absent(),
          Value<String?> iso2 = const Value.absent(),
          Value<String?> type = const Value.absent(),
          Value<int?> level = const Value.absent(),
          Value<int?> parentId = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          int? flag,
          Value<String?> wikiDataId = const Value.absent()}) =>
      StateDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        countryId: countryId ?? this.countryId,
        countryCode: countryCode ?? this.countryCode,
        fipsCode: fipsCode.present ? fipsCode.value : this.fipsCode,
        iso2: iso2.present ? iso2.value : this.iso2,
        type: type.present ? type.value : this.type,
        level: level.present ? level.value : this.level,
        parentId: parentId.present ? parentId.value : this.parentId,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        flag: flag ?? this.flag,
        wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
      );
  StateDataModel copyWithCompanion(StatesCompanion data) {
    return StateDataModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      fipsCode: data.fipsCode.present ? data.fipsCode.value : this.fipsCode,
      iso2: data.iso2.present ? data.iso2.value : this.iso2,
      type: data.type.present ? data.type.value : this.type,
      level: data.level.present ? data.level.value : this.level,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      flag: data.flag.present ? data.flag.value : this.flag,
      wikiDataId:
          data.wikiDataId.present ? data.wikiDataId.value : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StateDataModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('countryId: $countryId, ')
          ..write('countryCode: $countryCode, ')
          ..write('fipsCode: $fipsCode, ')
          ..write('iso2: $iso2, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      countryId,
      countryCode,
      fipsCode,
      iso2,
      type,
      level,
      parentId,
      latitude,
      longitude,
      createdAt,
      updatedAt,
      flag,
      wikiDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StateDataModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.countryId == this.countryId &&
          other.countryCode == this.countryCode &&
          other.fipsCode == this.fipsCode &&
          other.iso2 == this.iso2 &&
          other.type == this.type &&
          other.level == this.level &&
          other.parentId == this.parentId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.flag == this.flag &&
          other.wikiDataId == this.wikiDataId);
}

class StatesCompanion extends UpdateCompanion<StateDataModel> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> countryId;
  final Value<String> countryCode;
  final Value<String?> fipsCode;
  final Value<String?> iso2;
  final Value<String?> type;
  final Value<int?> level;
  final Value<int?> parentId;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> flag;
  final Value<String?> wikiDataId;
  const StatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.countryId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.fipsCode = const Value.absent(),
    this.iso2 = const Value.absent(),
    this.type = const Value.absent(),
    this.level = const Value.absent(),
    this.parentId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  StatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int countryId,
    required String countryCode,
    this.fipsCode = const Value.absent(),
    this.iso2 = const Value.absent(),
    this.type = const Value.absent(),
    this.level = const Value.absent(),
    this.parentId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  })  : name = Value(name),
        countryId = Value(countryId),
        countryCode = Value(countryCode);
  static Insertable<StateDataModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? countryId,
    Expression<String>? countryCode,
    Expression<String>? fipsCode,
    Expression<String>? iso2,
    Expression<String>? type,
    Expression<int>? level,
    Expression<int>? parentId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? flag,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (countryId != null) 'country_id': countryId,
      if (countryCode != null) 'country_code': countryCode,
      if (fipsCode != null) 'fips_code': fipsCode,
      if (iso2 != null) 'iso2': iso2,
      if (type != null) 'type': type,
      if (level != null) 'level': level,
      if (parentId != null) 'parent_id': parentId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (flag != null) 'flag': flag,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  StatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? countryId,
      Value<String>? countryCode,
      Value<String?>? fipsCode,
      Value<String?>? iso2,
      Value<String?>? type,
      Value<int?>? level,
      Value<int?>? parentId,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? flag,
      Value<String?>? wikiDataId}) {
    return StatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      countryId: countryId ?? this.countryId,
      countryCode: countryCode ?? this.countryCode,
      fipsCode: fipsCode ?? this.fipsCode,
      iso2: iso2 ?? this.iso2,
      type: type ?? this.type,
      level: level ?? this.level,
      parentId: parentId ?? this.parentId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flag: flag ?? this.flag,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<int>(countryId.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (fipsCode.present) {
      map['fips_code'] = Variable<String>(fipsCode.value);
    }
    if (iso2.present) {
      map['iso2'] = Variable<String>(iso2.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('countryId: $countryId, ')
          ..write('countryCode: $countryCode, ')
          ..write('fipsCode: $fipsCode, ')
          ..write('iso2: $iso2, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

class $CitiesTable extends Cities with TableInfo<$CitiesTable, CityDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _stateIdMeta =
      const VerificationMeta('stateId');
  @override
  late final GeneratedColumn<int> stateId = GeneratedColumn<int>(
      'state_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES states (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _stateCodeMeta =
      const VerificationMeta('stateCode');
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
      'state_code', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _countryIdMeta =
      const VerificationMeta('countryId');
  @override
  late final GeneratedColumn<int> countryId = GeneratedColumn<int>(
      'country_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES countries (id) ON UPDATE NO ACTION ON DELETE NO ACTION'));
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime(2014, 1, 1, 12, 1, 1)));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
      'flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _wikiDataIdMeta =
      const VerificationMeta('wikiDataId');
  @override
  late final GeneratedColumn<String> wikiDataId = GeneratedColumn<String>(
      'wiki_data_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        stateId,
        stateCode,
        countryId,
        countryCode,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        flag,
        wikiDataId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cities';
  @override
  VerificationContext validateIntegrity(Insertable<CityDataModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state_id')) {
      context.handle(_stateIdMeta,
          stateId.isAcceptableOrUnknown(data['state_id']!, _stateIdMeta));
    } else if (isInserting) {
      context.missing(_stateIdMeta);
    }
    if (data.containsKey('state_code')) {
      context.handle(_stateCodeMeta,
          stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta));
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(_countryIdMeta,
          countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta));
    } else if (isInserting) {
      context.missing(_countryIdMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('flag')) {
      context.handle(
          _flagMeta, flag.isAcceptableOrUnknown(data['flag']!, _flagMeta));
    }
    if (data.containsKey('wiki_data_id')) {
      context.handle(
          _wikiDataIdMeta,
          wikiDataId.isAcceptableOrUnknown(
              data['wiki_data_id']!, _wikiDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CityDataModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CityDataModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      stateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state_id'])!,
      stateCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_code'])!,
      countryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}country_id'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      flag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flag'])!,
      wikiDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wiki_data_id']),
    );
  }

  @override
  $CitiesTable createAlias(String alias) {
    return $CitiesTable(attachedDatabase, alias);
  }
}

class CityDataModel extends DataClass implements Insertable<CityDataModel> {
  final int id;
  final String name;
  final int stateId;
  final String stateCode;
  final int countryId;
  final String countryCode;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int flag;
  final String? wikiDataId;
  const CityDataModel(
      {required this.id,
      required this.name,
      required this.stateId,
      required this.stateCode,
      required this.countryId,
      required this.countryCode,
      required this.latitude,
      required this.longitude,
      required this.createdAt,
      required this.updatedAt,
      required this.flag,
      this.wikiDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['state_id'] = Variable<int>(stateId);
    map['state_code'] = Variable<String>(stateCode);
    map['country_id'] = Variable<int>(countryId);
    map['country_code'] = Variable<String>(countryCode);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || wikiDataId != null) {
      map['wiki_data_id'] = Variable<String>(wikiDataId);
    }
    return map;
  }

  CitiesCompanion toCompanion(bool nullToAbsent) {
    return CitiesCompanion(
      id: Value(id),
      name: Value(name),
      stateId: Value(stateId),
      stateCode: Value(stateCode),
      countryId: Value(countryId),
      countryCode: Value(countryCode),
      latitude: Value(latitude),
      longitude: Value(longitude),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      flag: Value(flag),
      wikiDataId: wikiDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikiDataId),
    );
  }

  factory CityDataModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CityDataModel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stateId: serializer.fromJson<int>(json['stateId']),
      stateCode: serializer.fromJson<String>(json['stateCode']),
      countryId: serializer.fromJson<int>(json['countryId']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      flag: serializer.fromJson<int>(json['flag']),
      wikiDataId: serializer.fromJson<String?>(json['wikiDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stateId': serializer.toJson<int>(stateId),
      'stateCode': serializer.toJson<String>(stateCode),
      'countryId': serializer.toJson<int>(countryId),
      'countryCode': serializer.toJson<String>(countryCode),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'flag': serializer.toJson<int>(flag),
      'wikiDataId': serializer.toJson<String?>(wikiDataId),
    };
  }

  CityDataModel copyWith(
          {int? id,
          String? name,
          int? stateId,
          String? stateCode,
          int? countryId,
          String? countryCode,
          double? latitude,
          double? longitude,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? flag,
          Value<String?> wikiDataId = const Value.absent()}) =>
      CityDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        stateId: stateId ?? this.stateId,
        stateCode: stateCode ?? this.stateCode,
        countryId: countryId ?? this.countryId,
        countryCode: countryCode ?? this.countryCode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        flag: flag ?? this.flag,
        wikiDataId: wikiDataId.present ? wikiDataId.value : this.wikiDataId,
      );
  CityDataModel copyWithCompanion(CitiesCompanion data) {
    return CityDataModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stateId: data.stateId.present ? data.stateId.value : this.stateId,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      flag: data.flag.present ? data.flag.value : this.flag,
      wikiDataId:
          data.wikiDataId.present ? data.wikiDataId.value : this.wikiDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CityDataModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stateId: $stateId, ')
          ..write('stateCode: $stateCode, ')
          ..write('countryId: $countryId, ')
          ..write('countryCode: $countryCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stateId, stateCode, countryId,
      countryCode, latitude, longitude, createdAt, updatedAt, flag, wikiDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CityDataModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.stateId == this.stateId &&
          other.stateCode == this.stateCode &&
          other.countryId == this.countryId &&
          other.countryCode == this.countryCode &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.flag == this.flag &&
          other.wikiDataId == this.wikiDataId);
}

class CitiesCompanion extends UpdateCompanion<CityDataModel> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> stateId;
  final Value<String> stateCode;
  final Value<int> countryId;
  final Value<String> countryCode;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> flag;
  final Value<String?> wikiDataId;
  const CitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stateId = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.countryId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  });
  CitiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int stateId,
    required String stateCode,
    required int countryId,
    required String countryCode,
    required double latitude,
    required double longitude,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.flag = const Value.absent(),
    this.wikiDataId = const Value.absent(),
  })  : name = Value(name),
        stateId = Value(stateId),
        stateCode = Value(stateCode),
        countryId = Value(countryId),
        countryCode = Value(countryCode),
        latitude = Value(latitude),
        longitude = Value(longitude);
  static Insertable<CityDataModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? stateId,
    Expression<String>? stateCode,
    Expression<int>? countryId,
    Expression<String>? countryCode,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? flag,
    Expression<String>? wikiDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stateId != null) 'state_id': stateId,
      if (stateCode != null) 'state_code': stateCode,
      if (countryId != null) 'country_id': countryId,
      if (countryCode != null) 'country_code': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (flag != null) 'flag': flag,
      if (wikiDataId != null) 'wiki_data_id': wikiDataId,
    });
  }

  CitiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? stateId,
      Value<String>? stateCode,
      Value<int>? countryId,
      Value<String>? countryCode,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? flag,
      Value<String?>? wikiDataId}) {
    return CitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stateId: stateId ?? this.stateId,
      stateCode: stateCode ?? this.stateCode,
      countryId: countryId ?? this.countryId,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flag: flag ?? this.flag,
      wikiDataId: wikiDataId ?? this.wikiDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stateId.present) {
      map['state_id'] = Variable<int>(stateId.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<int>(countryId.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (wikiDataId.present) {
      map['wiki_data_id'] = Variable<String>(wikiDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stateId: $stateId, ')
          ..write('stateCode: $stateCode, ')
          ..write('countryId: $countryId, ')
          ..write('countryCode: $countryCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('flag: $flag, ')
          ..write('wikiDataId: $wikiDataId')
          ..write(')'))
        .toString();
  }
}

abstract class _$WorldInfoDatabase extends GeneratedDatabase {
  _$WorldInfoDatabase(QueryExecutor e) : super(e);
  $WorldInfoDatabaseManager get managers => $WorldInfoDatabaseManager(this);
  late final $RegionsTable regions = $RegionsTable(this);
  late final $SubregionsTable subregions = $SubregionsTable(this);
  late final $CountriesTable countries = $CountriesTable(this);
  late final $StatesTable states = $StatesTable(this);
  late final $CitiesTable cities = $CitiesTable(this);
  late final CityDao cityDao = CityDao(this as WorldInfoDatabase);
  late final CountryDao countryDao = CountryDao(this as WorldInfoDatabase);
  late final RegionDao regionDao = RegionDao(this as WorldInfoDatabase);
  late final StateDao stateDao = StateDao(this as WorldInfoDatabase);
  late final SubregionDao subregionDao =
      SubregionDao(this as WorldInfoDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [regions, subregions, countries, states, cities];
}

typedef $$RegionsTableCreateCompanionBuilder = RegionsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> translations,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});
typedef $$RegionsTableUpdateCompanionBuilder = RegionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> translations,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});

final class $$RegionsTableReferences extends BaseReferences<_$WorldInfoDatabase,
    $RegionsTable, RegionDataModel> {
  $$RegionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubregionsTable, List<SubregionDataModel>>
      _subregionsRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.subregions,
              aliasName:
                  $_aliasNameGenerator(db.regions.id, db.subregions.regionId));

  $$SubregionsTableProcessedTableManager get subregionsRefs {
    final manager = $$SubregionsTableTableManager($_db, $_db.subregions)
        .filter((f) => f.regionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subregionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CountriesTable, List<CountryDataModel>>
      _countriesRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.countries,
              aliasName:
                  $_aliasNameGenerator(db.regions.id, db.countries.regionId));

  $$CountriesTableProcessedTableManager get countriesRefs {
    final manager = $$CountriesTableTableManager($_db, $_db.countries)
        .filter((f) => f.regionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_countriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RegionsTableFilterComposer
    extends Composer<_$WorldInfoDatabase, $RegionsTable> {
  $$RegionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnFilters(column));

  Expression<bool> subregionsRefs(
      Expression<bool> Function($$SubregionsTableFilterComposer f) f) {
    final $$SubregionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subregions,
        getReferencedColumn: (t) => t.regionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubregionsTableFilterComposer(
              $db: $db,
              $table: $db.subregions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> countriesRefs(
      Expression<bool> Function($$CountriesTableFilterComposer f) f) {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.regionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableFilterComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RegionsTableOrderingComposer
    extends Composer<_$WorldInfoDatabase, $RegionsTable> {
  $$RegionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translations => $composableBuilder(
      column: $table.translations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnOrderings(column));
}

class $$RegionsTableAnnotationComposer
    extends Composer<_$WorldInfoDatabase, $RegionsTable> {
  $$RegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => column);

  Expression<T> subregionsRefs<T extends Object>(
      Expression<T> Function($$SubregionsTableAnnotationComposer a) f) {
    final $$SubregionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subregions,
        getReferencedColumn: (t) => t.regionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubregionsTableAnnotationComposer(
              $db: $db,
              $table: $db.subregions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> countriesRefs<T extends Object>(
      Expression<T> Function($$CountriesTableAnnotationComposer a) f) {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.regionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableAnnotationComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RegionsTableTableManager extends RootTableManager<
    _$WorldInfoDatabase,
    $RegionsTable,
    RegionDataModel,
    $$RegionsTableFilterComposer,
    $$RegionsTableOrderingComposer,
    $$RegionsTableAnnotationComposer,
    $$RegionsTableCreateCompanionBuilder,
    $$RegionsTableUpdateCompanionBuilder,
    (RegionDataModel, $$RegionsTableReferences),
    RegionDataModel,
    PrefetchHooks Function({bool subregionsRefs, bool countriesRefs})> {
  $$RegionsTableTableManager(_$WorldInfoDatabase db, $RegionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> translations = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              RegionsCompanion(
            id: id,
            name: name,
            translations: translations,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> translations = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              RegionsCompanion.insert(
            id: id,
            name: name,
            translations: translations,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RegionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {subregionsRefs = false, countriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subregionsRefs) db.subregions,
                if (countriesRefs) db.countries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subregionsRefs)
                    await $_getPrefetchedData<RegionDataModel, $RegionsTable,
                            SubregionDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$RegionsTableReferences._subregionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RegionsTableReferences(db, table, p0)
                                .subregionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.regionId == item.id),
                        typedResults: items),
                  if (countriesRefs)
                    await $_getPrefetchedData<RegionDataModel, $RegionsTable,
                            CountryDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$RegionsTableReferences._countriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RegionsTableReferences(db, table, p0)
                                .countriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.regionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RegionsTableProcessedTableManager = ProcessedTableManager<
    _$WorldInfoDatabase,
    $RegionsTable,
    RegionDataModel,
    $$RegionsTableFilterComposer,
    $$RegionsTableOrderingComposer,
    $$RegionsTableAnnotationComposer,
    $$RegionsTableCreateCompanionBuilder,
    $$RegionsTableUpdateCompanionBuilder,
    (RegionDataModel, $$RegionsTableReferences),
    RegionDataModel,
    PrefetchHooks Function({bool subregionsRefs, bool countriesRefs})>;
typedef $$SubregionsTableCreateCompanionBuilder = SubregionsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> translations,
  required int regionId,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});
typedef $$SubregionsTableUpdateCompanionBuilder = SubregionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> translations,
  Value<int> regionId,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});

final class $$SubregionsTableReferences extends BaseReferences<
    _$WorldInfoDatabase, $SubregionsTable, SubregionDataModel> {
  $$SubregionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RegionsTable _regionIdTable(_$WorldInfoDatabase db) => db.regions
      .createAlias($_aliasNameGenerator(db.subregions.regionId, db.regions.id));

  $$RegionsTableProcessedTableManager get regionId {
    final $_column = $_itemColumn<int>('region_id')!;

    final manager = $$RegionsTableTableManager($_db, $_db.regions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_regionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CountriesTable, List<CountryDataModel>>
      _countriesRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.countries,
              aliasName: $_aliasNameGenerator(
                  db.subregions.id, db.countries.subregionId));

  $$CountriesTableProcessedTableManager get countriesRefs {
    final manager = $$CountriesTableTableManager($_db, $_db.countries)
        .filter((f) => f.subregionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_countriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubregionsTableFilterComposer
    extends Composer<_$WorldInfoDatabase, $SubregionsTable> {
  $$SubregionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnFilters(column));

  $$RegionsTableFilterComposer get regionId {
    final $$RegionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableFilterComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> countriesRefs(
      Expression<bool> Function($$CountriesTableFilterComposer f) f) {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.subregionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableFilterComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubregionsTableOrderingComposer
    extends Composer<_$WorldInfoDatabase, $SubregionsTable> {
  $$SubregionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translations => $composableBuilder(
      column: $table.translations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnOrderings(column));

  $$RegionsTableOrderingComposer get regionId {
    final $$RegionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableOrderingComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubregionsTableAnnotationComposer
    extends Composer<_$WorldInfoDatabase, $SubregionsTable> {
  $$SubregionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => column);

  $$RegionsTableAnnotationComposer get regionId {
    final $$RegionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableAnnotationComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> countriesRefs<T extends Object>(
      Expression<T> Function($$CountriesTableAnnotationComposer a) f) {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.subregionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableAnnotationComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubregionsTableTableManager extends RootTableManager<
    _$WorldInfoDatabase,
    $SubregionsTable,
    SubregionDataModel,
    $$SubregionsTableFilterComposer,
    $$SubregionsTableOrderingComposer,
    $$SubregionsTableAnnotationComposer,
    $$SubregionsTableCreateCompanionBuilder,
    $$SubregionsTableUpdateCompanionBuilder,
    (SubregionDataModel, $$SubregionsTableReferences),
    SubregionDataModel,
    PrefetchHooks Function({bool regionId, bool countriesRefs})> {
  $$SubregionsTableTableManager(_$WorldInfoDatabase db, $SubregionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubregionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubregionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubregionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> translations = const Value.absent(),
            Value<int> regionId = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              SubregionsCompanion(
            id: id,
            name: name,
            translations: translations,
            regionId: regionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> translations = const Value.absent(),
            required int regionId,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              SubregionsCompanion.insert(
            id: id,
            name: name,
            translations: translations,
            regionId: regionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubregionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({regionId = false, countriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (countriesRefs) db.countries],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (regionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.regionId,
                    referencedTable:
                        $$SubregionsTableReferences._regionIdTable(db),
                    referencedColumn:
                        $$SubregionsTableReferences._regionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (countriesRefs)
                    await $_getPrefetchedData<SubregionDataModel,
                            $SubregionsTable, CountryDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$SubregionsTableReferences._countriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubregionsTableReferences(db, table, p0)
                                .countriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subregionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubregionsTableProcessedTableManager = ProcessedTableManager<
    _$WorldInfoDatabase,
    $SubregionsTable,
    SubregionDataModel,
    $$SubregionsTableFilterComposer,
    $$SubregionsTableOrderingComposer,
    $$SubregionsTableAnnotationComposer,
    $$SubregionsTableCreateCompanionBuilder,
    $$SubregionsTableUpdateCompanionBuilder,
    (SubregionDataModel, $$SubregionsTableReferences),
    SubregionDataModel,
    PrefetchHooks Function({bool regionId, bool countriesRefs})>;
typedef $$CountriesTableCreateCompanionBuilder = CountriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> iso3,
  Value<String?> numericCode,
  Value<String?> iso2,
  Value<String?> phonecode,
  Value<String?> capital,
  Value<String?> currency,
  Value<String?> currencyName,
  Value<String?> currencySymbol,
  Value<String?> tld,
  Value<String?> native,
  Value<String?> region,
  Value<int?> regionId,
  Value<String?> subregion,
  Value<int?> subregionId,
  Value<String?> nationality,
  Value<String?> timezones,
  Value<String?> translations,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> emoji,
  Value<String?> emojiU,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});
typedef $$CountriesTableUpdateCompanionBuilder = CountriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> iso3,
  Value<String?> numericCode,
  Value<String?> iso2,
  Value<String?> phonecode,
  Value<String?> capital,
  Value<String?> currency,
  Value<String?> currencyName,
  Value<String?> currencySymbol,
  Value<String?> tld,
  Value<String?> native,
  Value<String?> region,
  Value<int?> regionId,
  Value<String?> subregion,
  Value<int?> subregionId,
  Value<String?> nationality,
  Value<String?> timezones,
  Value<String?> translations,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> emoji,
  Value<String?> emojiU,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});

final class $$CountriesTableReferences extends BaseReferences<
    _$WorldInfoDatabase, $CountriesTable, CountryDataModel> {
  $$CountriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RegionsTable _regionIdTable(_$WorldInfoDatabase db) => db.regions
      .createAlias($_aliasNameGenerator(db.countries.regionId, db.regions.id));

  $$RegionsTableProcessedTableManager? get regionId {
    final $_column = $_itemColumn<int>('region_id');
    if ($_column == null) return null;
    final manager = $$RegionsTableTableManager($_db, $_db.regions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_regionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubregionsTable _subregionIdTable(_$WorldInfoDatabase db) =>
      db.subregions.createAlias(
          $_aliasNameGenerator(db.countries.subregionId, db.subregions.id));

  $$SubregionsTableProcessedTableManager? get subregionId {
    final $_column = $_itemColumn<int>('subregion_id');
    if ($_column == null) return null;
    final manager = $$SubregionsTableTableManager($_db, $_db.subregions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subregionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$StatesTable, List<StateDataModel>>
      _statesRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.states,
              aliasName:
                  $_aliasNameGenerator(db.countries.id, db.states.countryId));

  $$StatesTableProcessedTableManager get statesRefs {
    final manager = $$StatesTableTableManager($_db, $_db.states)
        .filter((f) => f.countryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_statesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CitiesTable, List<CityDataModel>>
      _citiesRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.cities,
              aliasName:
                  $_aliasNameGenerator(db.countries.id, db.cities.countryId));

  $$CitiesTableProcessedTableManager get citiesRefs {
    final manager = $$CitiesTableTableManager($_db, $_db.cities)
        .filter((f) => f.countryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_citiesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CountriesTableFilterComposer
    extends Composer<_$WorldInfoDatabase, $CountriesTable> {
  $$CountriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iso3 => $composableBuilder(
      column: $table.iso3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numericCode => $composableBuilder(
      column: $table.numericCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iso2 => $composableBuilder(
      column: $table.iso2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phonecode => $composableBuilder(
      column: $table.phonecode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capital => $composableBuilder(
      column: $table.capital, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyName => $composableBuilder(
      column: $table.currencyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tld => $composableBuilder(
      column: $table.tld, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get native => $composableBuilder(
      column: $table.native, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subregion => $composableBuilder(
      column: $table.subregion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezones => $composableBuilder(
      column: $table.timezones, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emojiU => $composableBuilder(
      column: $table.emojiU, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnFilters(column));

  $$RegionsTableFilterComposer get regionId {
    final $$RegionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableFilterComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubregionsTableFilterComposer get subregionId {
    final $$SubregionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subregionId,
        referencedTable: $db.subregions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubregionsTableFilterComposer(
              $db: $db,
              $table: $db.subregions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> statesRefs(
      Expression<bool> Function($$StatesTableFilterComposer f) f) {
    final $$StatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.states,
        getReferencedColumn: (t) => t.countryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatesTableFilterComposer(
              $db: $db,
              $table: $db.states,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> citiesRefs(
      Expression<bool> Function($$CitiesTableFilterComposer f) f) {
    final $$CitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cities,
        getReferencedColumn: (t) => t.countryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CitiesTableFilterComposer(
              $db: $db,
              $table: $db.cities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CountriesTableOrderingComposer
    extends Composer<_$WorldInfoDatabase, $CountriesTable> {
  $$CountriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iso3 => $composableBuilder(
      column: $table.iso3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numericCode => $composableBuilder(
      column: $table.numericCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iso2 => $composableBuilder(
      column: $table.iso2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phonecode => $composableBuilder(
      column: $table.phonecode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capital => $composableBuilder(
      column: $table.capital, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyName => $composableBuilder(
      column: $table.currencyName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tld => $composableBuilder(
      column: $table.tld, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get native => $composableBuilder(
      column: $table.native, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subregion => $composableBuilder(
      column: $table.subregion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezones => $composableBuilder(
      column: $table.timezones, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translations => $composableBuilder(
      column: $table.translations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emojiU => $composableBuilder(
      column: $table.emojiU, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnOrderings(column));

  $$RegionsTableOrderingComposer get regionId {
    final $$RegionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableOrderingComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubregionsTableOrderingComposer get subregionId {
    final $$SubregionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subregionId,
        referencedTable: $db.subregions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubregionsTableOrderingComposer(
              $db: $db,
              $table: $db.subregions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CountriesTableAnnotationComposer
    extends Composer<_$WorldInfoDatabase, $CountriesTable> {
  $$CountriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iso3 =>
      $composableBuilder(column: $table.iso3, builder: (column) => column);

  GeneratedColumn<String> get numericCode => $composableBuilder(
      column: $table.numericCode, builder: (column) => column);

  GeneratedColumn<String> get iso2 =>
      $composableBuilder(column: $table.iso2, builder: (column) => column);

  GeneratedColumn<String> get phonecode =>
      $composableBuilder(column: $table.phonecode, builder: (column) => column);

  GeneratedColumn<String> get capital =>
      $composableBuilder(column: $table.capital, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get currencyName => $composableBuilder(
      column: $table.currencyName, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get tld =>
      $composableBuilder(column: $table.tld, builder: (column) => column);

  GeneratedColumn<String> get native =>
      $composableBuilder(column: $table.native, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get subregion =>
      $composableBuilder(column: $table.subregion, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => column);

  GeneratedColumn<String> get timezones =>
      $composableBuilder(column: $table.timezones, builder: (column) => column);

  GeneratedColumn<String> get translations => $composableBuilder(
      column: $table.translations, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get emojiU =>
      $composableBuilder(column: $table.emojiU, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => column);

  $$RegionsTableAnnotationComposer get regionId {
    final $$RegionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.regionId,
        referencedTable: $db.regions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RegionsTableAnnotationComposer(
              $db: $db,
              $table: $db.regions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubregionsTableAnnotationComposer get subregionId {
    final $$SubregionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subregionId,
        referencedTable: $db.subregions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubregionsTableAnnotationComposer(
              $db: $db,
              $table: $db.subregions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> statesRefs<T extends Object>(
      Expression<T> Function($$StatesTableAnnotationComposer a) f) {
    final $$StatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.states,
        getReferencedColumn: (t) => t.countryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatesTableAnnotationComposer(
              $db: $db,
              $table: $db.states,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> citiesRefs<T extends Object>(
      Expression<T> Function($$CitiesTableAnnotationComposer a) f) {
    final $$CitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cities,
        getReferencedColumn: (t) => t.countryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.cities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CountriesTableTableManager extends RootTableManager<
    _$WorldInfoDatabase,
    $CountriesTable,
    CountryDataModel,
    $$CountriesTableFilterComposer,
    $$CountriesTableOrderingComposer,
    $$CountriesTableAnnotationComposer,
    $$CountriesTableCreateCompanionBuilder,
    $$CountriesTableUpdateCompanionBuilder,
    (CountryDataModel, $$CountriesTableReferences),
    CountryDataModel,
    PrefetchHooks Function(
        {bool regionId, bool subregionId, bool statesRefs, bool citiesRefs})> {
  $$CountriesTableTableManager(_$WorldInfoDatabase db, $CountriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> iso3 = const Value.absent(),
            Value<String?> numericCode = const Value.absent(),
            Value<String?> iso2 = const Value.absent(),
            Value<String?> phonecode = const Value.absent(),
            Value<String?> capital = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> currencyName = const Value.absent(),
            Value<String?> currencySymbol = const Value.absent(),
            Value<String?> tld = const Value.absent(),
            Value<String?> native = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<int?> regionId = const Value.absent(),
            Value<String?> subregion = const Value.absent(),
            Value<int?> subregionId = const Value.absent(),
            Value<String?> nationality = const Value.absent(),
            Value<String?> timezones = const Value.absent(),
            Value<String?> translations = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> emoji = const Value.absent(),
            Value<String?> emojiU = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              CountriesCompanion(
            id: id,
            name: name,
            iso3: iso3,
            numericCode: numericCode,
            iso2: iso2,
            phonecode: phonecode,
            capital: capital,
            currency: currency,
            currencyName: currencyName,
            currencySymbol: currencySymbol,
            tld: tld,
            native: native,
            region: region,
            regionId: regionId,
            subregion: subregion,
            subregionId: subregionId,
            nationality: nationality,
            timezones: timezones,
            translations: translations,
            latitude: latitude,
            longitude: longitude,
            emoji: emoji,
            emojiU: emojiU,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> iso3 = const Value.absent(),
            Value<String?> numericCode = const Value.absent(),
            Value<String?> iso2 = const Value.absent(),
            Value<String?> phonecode = const Value.absent(),
            Value<String?> capital = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> currencyName = const Value.absent(),
            Value<String?> currencySymbol = const Value.absent(),
            Value<String?> tld = const Value.absent(),
            Value<String?> native = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<int?> regionId = const Value.absent(),
            Value<String?> subregion = const Value.absent(),
            Value<int?> subregionId = const Value.absent(),
            Value<String?> nationality = const Value.absent(),
            Value<String?> timezones = const Value.absent(),
            Value<String?> translations = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> emoji = const Value.absent(),
            Value<String?> emojiU = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              CountriesCompanion.insert(
            id: id,
            name: name,
            iso3: iso3,
            numericCode: numericCode,
            iso2: iso2,
            phonecode: phonecode,
            capital: capital,
            currency: currency,
            currencyName: currencyName,
            currencySymbol: currencySymbol,
            tld: tld,
            native: native,
            region: region,
            regionId: regionId,
            subregion: subregion,
            subregionId: subregionId,
            nationality: nationality,
            timezones: timezones,
            translations: translations,
            latitude: latitude,
            longitude: longitude,
            emoji: emoji,
            emojiU: emojiU,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CountriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {regionId = false,
              subregionId = false,
              statesRefs = false,
              citiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (statesRefs) db.states,
                if (citiesRefs) db.cities
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (regionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.regionId,
                    referencedTable:
                        $$CountriesTableReferences._regionIdTable(db),
                    referencedColumn:
                        $$CountriesTableReferences._regionIdTable(db).id,
                  ) as T;
                }
                if (subregionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subregionId,
                    referencedTable:
                        $$CountriesTableReferences._subregionIdTable(db),
                    referencedColumn:
                        $$CountriesTableReferences._subregionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (statesRefs)
                    await $_getPrefetchedData<CountryDataModel, $CountriesTable,
                            StateDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$CountriesTableReferences._statesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CountriesTableReferences(db, table, p0)
                                .statesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.countryId == item.id),
                        typedResults: items),
                  if (citiesRefs)
                    await $_getPrefetchedData<CountryDataModel, $CountriesTable,
                            CityDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$CountriesTableReferences._citiesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CountriesTableReferences(db, table, p0)
                                .citiesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.countryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CountriesTableProcessedTableManager = ProcessedTableManager<
    _$WorldInfoDatabase,
    $CountriesTable,
    CountryDataModel,
    $$CountriesTableFilterComposer,
    $$CountriesTableOrderingComposer,
    $$CountriesTableAnnotationComposer,
    $$CountriesTableCreateCompanionBuilder,
    $$CountriesTableUpdateCompanionBuilder,
    (CountryDataModel, $$CountriesTableReferences),
    CountryDataModel,
    PrefetchHooks Function(
        {bool regionId, bool subregionId, bool statesRefs, bool citiesRefs})>;
typedef $$StatesTableCreateCompanionBuilder = StatesCompanion Function({
  Value<int> id,
  required String name,
  required int countryId,
  required String countryCode,
  Value<String?> fipsCode,
  Value<String?> iso2,
  Value<String?> type,
  Value<int?> level,
  Value<int?> parentId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});
typedef $$StatesTableUpdateCompanionBuilder = StatesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> countryId,
  Value<String> countryCode,
  Value<String?> fipsCode,
  Value<String?> iso2,
  Value<String?> type,
  Value<int?> level,
  Value<int?> parentId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});

final class $$StatesTableReferences
    extends BaseReferences<_$WorldInfoDatabase, $StatesTable, StateDataModel> {
  $$StatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CountriesTable _countryIdTable(_$WorldInfoDatabase db) => db.countries
      .createAlias($_aliasNameGenerator(db.states.countryId, db.countries.id));

  $$CountriesTableProcessedTableManager get countryId {
    final $_column = $_itemColumn<int>('country_id')!;

    final manager = $$CountriesTableTableManager($_db, $_db.countries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_countryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CitiesTable, List<CityDataModel>>
      _citiesRefsTable(_$WorldInfoDatabase db) =>
          MultiTypedResultKey.fromTable(db.cities,
              aliasName: $_aliasNameGenerator(db.states.id, db.cities.stateId));

  $$CitiesTableProcessedTableManager get citiesRefs {
    final manager = $$CitiesTableTableManager($_db, $_db.cities)
        .filter((f) => f.stateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_citiesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StatesTableFilterComposer
    extends Composer<_$WorldInfoDatabase, $StatesTable> {
  $$StatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fipsCode => $composableBuilder(
      column: $table.fipsCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iso2 => $composableBuilder(
      column: $table.iso2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnFilters(column));

  $$CountriesTableFilterComposer get countryId {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableFilterComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> citiesRefs(
      Expression<bool> Function($$CitiesTableFilterComposer f) f) {
    final $$CitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cities,
        getReferencedColumn: (t) => t.stateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CitiesTableFilterComposer(
              $db: $db,
              $table: $db.cities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StatesTableOrderingComposer
    extends Composer<_$WorldInfoDatabase, $StatesTable> {
  $$StatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fipsCode => $composableBuilder(
      column: $table.fipsCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iso2 => $composableBuilder(
      column: $table.iso2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnOrderings(column));

  $$CountriesTableOrderingComposer get countryId {
    final $$CountriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableOrderingComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StatesTableAnnotationComposer
    extends Composer<_$WorldInfoDatabase, $StatesTable> {
  $$StatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => column);

  GeneratedColumn<String> get fipsCode =>
      $composableBuilder(column: $table.fipsCode, builder: (column) => column);

  GeneratedColumn<String> get iso2 =>
      $composableBuilder(column: $table.iso2, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => column);

  $$CountriesTableAnnotationComposer get countryId {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableAnnotationComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> citiesRefs<T extends Object>(
      Expression<T> Function($$CitiesTableAnnotationComposer a) f) {
    final $$CitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cities,
        getReferencedColumn: (t) => t.stateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.cities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StatesTableTableManager extends RootTableManager<
    _$WorldInfoDatabase,
    $StatesTable,
    StateDataModel,
    $$StatesTableFilterComposer,
    $$StatesTableOrderingComposer,
    $$StatesTableAnnotationComposer,
    $$StatesTableCreateCompanionBuilder,
    $$StatesTableUpdateCompanionBuilder,
    (StateDataModel, $$StatesTableReferences),
    StateDataModel,
    PrefetchHooks Function({bool countryId, bool citiesRefs})> {
  $$StatesTableTableManager(_$WorldInfoDatabase db, $StatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> countryId = const Value.absent(),
            Value<String> countryCode = const Value.absent(),
            Value<String?> fipsCode = const Value.absent(),
            Value<String?> iso2 = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<int?> level = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              StatesCompanion(
            id: id,
            name: name,
            countryId: countryId,
            countryCode: countryCode,
            fipsCode: fipsCode,
            iso2: iso2,
            type: type,
            level: level,
            parentId: parentId,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int countryId,
            required String countryCode,
            Value<String?> fipsCode = const Value.absent(),
            Value<String?> iso2 = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<int?> level = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              StatesCompanion.insert(
            id: id,
            name: name,
            countryId: countryId,
            countryCode: countryCode,
            fipsCode: fipsCode,
            iso2: iso2,
            type: type,
            level: level,
            parentId: parentId,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$StatesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({countryId = false, citiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (citiesRefs) db.cities],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (countryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.countryId,
                    referencedTable:
                        $$StatesTableReferences._countryIdTable(db),
                    referencedColumn:
                        $$StatesTableReferences._countryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (citiesRefs)
                    await $_getPrefetchedData<StateDataModel, $StatesTable,
                            CityDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$StatesTableReferences._citiesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StatesTableReferences(db, table, p0).citiesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.stateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StatesTableProcessedTableManager = ProcessedTableManager<
    _$WorldInfoDatabase,
    $StatesTable,
    StateDataModel,
    $$StatesTableFilterComposer,
    $$StatesTableOrderingComposer,
    $$StatesTableAnnotationComposer,
    $$StatesTableCreateCompanionBuilder,
    $$StatesTableUpdateCompanionBuilder,
    (StateDataModel, $$StatesTableReferences),
    StateDataModel,
    PrefetchHooks Function({bool countryId, bool citiesRefs})>;
typedef $$CitiesTableCreateCompanionBuilder = CitiesCompanion Function({
  Value<int> id,
  required String name,
  required int stateId,
  required String stateCode,
  required int countryId,
  required String countryCode,
  required double latitude,
  required double longitude,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});
typedef $$CitiesTableUpdateCompanionBuilder = CitiesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> stateId,
  Value<String> stateCode,
  Value<int> countryId,
  Value<String> countryCode,
  Value<double> latitude,
  Value<double> longitude,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> flag,
  Value<String?> wikiDataId,
});

final class $$CitiesTableReferences
    extends BaseReferences<_$WorldInfoDatabase, $CitiesTable, CityDataModel> {
  $$CitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StatesTable _stateIdTable(_$WorldInfoDatabase db) => db.states
      .createAlias($_aliasNameGenerator(db.cities.stateId, db.states.id));

  $$StatesTableProcessedTableManager get stateId {
    final $_column = $_itemColumn<int>('state_id')!;

    final manager = $$StatesTableTableManager($_db, $_db.states)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CountriesTable _countryIdTable(_$WorldInfoDatabase db) => db.countries
      .createAlias($_aliasNameGenerator(db.cities.countryId, db.countries.id));

  $$CountriesTableProcessedTableManager get countryId {
    final $_column = $_itemColumn<int>('country_id')!;

    final manager = $$CountriesTableTableManager($_db, $_db.countries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_countryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CitiesTableFilterComposer
    extends Composer<_$WorldInfoDatabase, $CitiesTable> {
  $$CitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnFilters(column));

  $$StatesTableFilterComposer get stateId {
    final $$StatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stateId,
        referencedTable: $db.states,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatesTableFilterComposer(
              $db: $db,
              $table: $db.states,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountriesTableFilterComposer get countryId {
    final $$CountriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableFilterComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CitiesTableOrderingComposer
    extends Composer<_$WorldInfoDatabase, $CitiesTable> {
  $$CitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flag => $composableBuilder(
      column: $table.flag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => ColumnOrderings(column));

  $$StatesTableOrderingComposer get stateId {
    final $$StatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stateId,
        referencedTable: $db.states,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatesTableOrderingComposer(
              $db: $db,
              $table: $db.states,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountriesTableOrderingComposer get countryId {
    final $$CountriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableOrderingComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CitiesTableAnnotationComposer
    extends Composer<_$WorldInfoDatabase, $CitiesTable> {
  $$CitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<String> get wikiDataId => $composableBuilder(
      column: $table.wikiDataId, builder: (column) => column);

  $$StatesTableAnnotationComposer get stateId {
    final $$StatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stateId,
        referencedTable: $db.states,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatesTableAnnotationComposer(
              $db: $db,
              $table: $db.states,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CountriesTableAnnotationComposer get countryId {
    final $$CountriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.countryId,
        referencedTable: $db.countries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountriesTableAnnotationComposer(
              $db: $db,
              $table: $db.countries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CitiesTableTableManager extends RootTableManager<
    _$WorldInfoDatabase,
    $CitiesTable,
    CityDataModel,
    $$CitiesTableFilterComposer,
    $$CitiesTableOrderingComposer,
    $$CitiesTableAnnotationComposer,
    $$CitiesTableCreateCompanionBuilder,
    $$CitiesTableUpdateCompanionBuilder,
    (CityDataModel, $$CitiesTableReferences),
    CityDataModel,
    PrefetchHooks Function({bool stateId, bool countryId})> {
  $$CitiesTableTableManager(_$WorldInfoDatabase db, $CitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> stateId = const Value.absent(),
            Value<String> stateCode = const Value.absent(),
            Value<int> countryId = const Value.absent(),
            Value<String> countryCode = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              CitiesCompanion(
            id: id,
            name: name,
            stateId: stateId,
            stateCode: stateCode,
            countryId: countryId,
            countryCode: countryCode,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int stateId,
            required String stateCode,
            required int countryId,
            required String countryCode,
            required double latitude,
            required double longitude,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> flag = const Value.absent(),
            Value<String?> wikiDataId = const Value.absent(),
          }) =>
              CitiesCompanion.insert(
            id: id,
            name: name,
            stateId: stateId,
            stateCode: stateCode,
            countryId: countryId,
            countryCode: countryCode,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            flag: flag,
            wikiDataId: wikiDataId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CitiesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({stateId = false, countryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (stateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.stateId,
                    referencedTable: $$CitiesTableReferences._stateIdTable(db),
                    referencedColumn:
                        $$CitiesTableReferences._stateIdTable(db).id,
                  ) as T;
                }
                if (countryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.countryId,
                    referencedTable:
                        $$CitiesTableReferences._countryIdTable(db),
                    referencedColumn:
                        $$CitiesTableReferences._countryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CitiesTableProcessedTableManager = ProcessedTableManager<
    _$WorldInfoDatabase,
    $CitiesTable,
    CityDataModel,
    $$CitiesTableFilterComposer,
    $$CitiesTableOrderingComposer,
    $$CitiesTableAnnotationComposer,
    $$CitiesTableCreateCompanionBuilder,
    $$CitiesTableUpdateCompanionBuilder,
    (CityDataModel, $$CitiesTableReferences),
    CityDataModel,
    PrefetchHooks Function({bool stateId, bool countryId})>;

class $WorldInfoDatabaseManager {
  final _$WorldInfoDatabase _db;
  $WorldInfoDatabaseManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db, _db.regions);
  $$SubregionsTableTableManager get subregions =>
      $$SubregionsTableTableManager(_db, _db.subregions);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db, _db.countries);
  $$StatesTableTableManager get states =>
      $$StatesTableTableManager(_db, _db.states);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db, _db.cities);
}
