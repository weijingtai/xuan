// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  static const String $name = 't_skills';
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

class $SkillClassesTable extends SkillClasses
    with TableInfo<$SkillClassesTable, SkillClass> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillClassesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_skills (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specificationMeta =
      const VerificationMeta('specification');
  @override
  late final GeneratedColumn<String> specification = GeneratedColumn<String>(
      'specification', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _featureMeta =
      const VerificationMeta('feature');
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
      'feature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        skillId,
        name,
        specification,
        feature,
        isCustomized
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_skill_classes';
  @override
  VerificationContext validateIntegrity(Insertable<SkillClass> instance,
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
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specification')) {
      context.handle(
          _specificationMeta,
          specification.isAcceptableOrUnknown(
              data['specification']!, _specificationMeta));
    } else if (isInserting) {
      context.missing(_specificationMeta);
    }
    if (data.containsKey('feature')) {
      context.handle(_featureMeta,
          feature.isAcceptableOrUnknown(data['feature']!, _featureMeta));
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    } else if (isInserting) {
      context.missing(_isCustomizedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SkillClass map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillClass(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      specification: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specification'])!,
      feature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature'])!,
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
    );
  }

  @override
  $SkillClassesTable createAlias(String alias) {
    return $SkillClassesTable(attachedDatabase, alias);
  }
}

class SkillClass extends DataClass implements Insertable<SkillClass> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final int skillId;
  final String name;
  final String specification;
  final String feature;
  final bool isCustomized;
  const SkillClass(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.skillId,
      required this.name,
      required this.specification,
      required this.feature,
      required this.isCustomized});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['skill_id'] = Variable<int>(skillId);
    map['name'] = Variable<String>(name);
    map['specification'] = Variable<String>(specification);
    map['feature'] = Variable<String>(feature);
    map['is_customized'] = Variable<bool>(isCustomized);
    return map;
  }

  SkillClassesCompanion toCompanion(bool nullToAbsent) {
    return SkillClassesCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      skillId: Value(skillId),
      name: Value(name),
      specification: Value(specification),
      feature: Value(feature),
      isCustomized: Value(isCustomized),
    );
  }

  factory SkillClass.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillClass(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      skillId: serializer.fromJson<int>(json['skillId']),
      name: serializer.fromJson<String>(json['name']),
      specification: serializer.fromJson<String>(json['specification']),
      feature: serializer.fromJson<String>(json['feature']),
      isCustomized: serializer.fromJson<bool>(json['isCustomized']),
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
      'skillId': serializer.toJson<int>(skillId),
      'name': serializer.toJson<String>(name),
      'specification': serializer.toJson<String>(specification),
      'feature': serializer.toJson<String>(feature),
      'isCustomized': serializer.toJson<bool>(isCustomized),
    };
  }

  SkillClass copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? skillId,
          String? name,
          String? specification,
          String? feature,
          bool? isCustomized}) =>
      SkillClass(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        skillId: skillId ?? this.skillId,
        name: name ?? this.name,
        specification: specification ?? this.specification,
        feature: feature ?? this.feature,
        isCustomized: isCustomized ?? this.isCustomized,
      );
  SkillClass copyWithCompanion(SkillClassesCompanion data) {
    return SkillClass(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      name: data.name.present ? data.name.value : this.name,
      specification: data.specification.present
          ? data.specification.value
          : this.specification,
      feature: data.feature.present ? data.feature.value : this.feature,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillClass(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('specification: $specification, ')
          ..write('feature: $feature, ')
          ..write('isCustomized: $isCustomized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, createdAt, lastUpdatedAt, deletedAt,
      skillId, name, specification, feature, isCustomized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillClass &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.skillId == this.skillId &&
          other.name == this.name &&
          other.specification == this.specification &&
          other.feature == this.feature &&
          other.isCustomized == this.isCustomized);
}

class SkillClassesCompanion extends UpdateCompanion<SkillClass> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> skillId;
  final Value<String> name;
  final Value<String> specification;
  final Value<String> feature;
  final Value<bool> isCustomized;
  final Value<int> rowid;
  const SkillClassesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.skillId = const Value.absent(),
    this.name = const Value.absent(),
    this.specification = const Value.absent(),
    this.feature = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkillClassesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required int skillId,
    required String name,
    required String specification,
    required String feature,
    required bool isCustomized,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        skillId = Value(skillId),
        name = Value(name),
        specification = Value(specification),
        feature = Value(feature),
        isCustomized = Value(isCustomized);
  static Insertable<SkillClass> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? skillId,
    Expression<String>? name,
    Expression<String>? specification,
    Expression<String>? feature,
    Expression<bool>? isCustomized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (skillId != null) 'skill_id': skillId,
      if (name != null) 'name': name,
      if (specification != null) 'specification': specification,
      if (feature != null) 'feature': feature,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkillClassesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? skillId,
      Value<String>? name,
      Value<String>? specification,
      Value<String>? feature,
      Value<bool>? isCustomized,
      Value<int>? rowid}) {
    return SkillClassesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      skillId: skillId ?? this.skillId,
      name: name ?? this.name,
      specification: specification ?? this.specification,
      feature: feature ?? this.feature,
      isCustomized: isCustomized ?? this.isCustomized,
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
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specification.present) {
      map['specification'] = Variable<String>(specification.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillClassesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('specification: $specification, ')
          ..write('feature: $feature, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LayoutTemplatesTable extends LayoutTemplates
    with TableInfo<$LayoutTemplatesTable, LayoutTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId =
      GeneratedColumn<String>('collection_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _templateJsonMeta =
      const VerificationMeta('templateJson');
  @override
  late final GeneratedColumn<String> templateJson = GeneratedColumn<String>(
      'template_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        collectionId,
        name,
        description,
        templateJson,
        version,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_layout_templates';
  @override
  VerificationContext validateIntegrity(Insertable<LayoutTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
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
    }
    if (data.containsKey('template_json')) {
      context.handle(
          _templateJsonMeta,
          templateJson.isAcceptableOrUnknown(
              data['template_json']!, _templateJsonMeta));
    } else if (isInserting) {
      context.missing(_templateJsonMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LayoutTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayoutTemplateRow(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      templateJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_json'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $LayoutTemplatesTable createAlias(String alias) {
    return $LayoutTemplatesTable(attachedDatabase, alias);
  }
}

class LayoutTemplateRow extends DataClass
    implements Insertable<LayoutTemplateRow> {
  final String uuid;
  final String collectionId;
  final String name;
  final String? description;
  final String templateJson;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LayoutTemplateRow(
      {required this.uuid,
      required this.collectionId,
      required this.name,
      this.description,
      required this.templateJson,
      required this.version,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['collection_id'] = Variable<String>(collectionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['template_json'] = Variable<String>(templateJson);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LayoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return LayoutTemplatesCompanion(
      uuid: Value(uuid),
      collectionId: Value(collectionId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      templateJson: Value(templateJson),
      version: Value(version),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LayoutTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayoutTemplateRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      templateJson: serializer.fromJson<String>(json['templateJson']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'collectionId': serializer.toJson<String>(collectionId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'templateJson': serializer.toJson<String>(templateJson),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LayoutTemplateRow copyWith(
          {String? uuid,
          String? collectionId,
          String? name,
          Value<String?> description = const Value.absent(),
          String? templateJson,
          int? version,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      LayoutTemplateRow(
        uuid: uuid ?? this.uuid,
        collectionId: collectionId ?? this.collectionId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        templateJson: templateJson ?? this.templateJson,
        version: version ?? this.version,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  LayoutTemplateRow copyWithCompanion(LayoutTemplatesCompanion data) {
    return LayoutTemplateRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      templateJson: data.templateJson.present
          ? data.templateJson.value
          : this.templateJson,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayoutTemplateRow(')
          ..write('uuid: $uuid, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('templateJson: $templateJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, collectionId, name, description,
      templateJson, version, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutTemplateRow &&
          other.uuid == this.uuid &&
          other.collectionId == this.collectionId &&
          other.name == this.name &&
          other.description == this.description &&
          other.templateJson == this.templateJson &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LayoutTemplatesCompanion extends UpdateCompanion<LayoutTemplateRow> {
  final Value<String> uuid;
  final Value<String> collectionId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> templateJson;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LayoutTemplatesCompanion({
    this.uuid = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.templateJson = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LayoutTemplatesCompanion.insert({
    required String uuid,
    required String collectionId,
    required String name,
    this.description = const Value.absent(),
    required String templateJson,
    required int version,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        collectionId = Value(collectionId),
        name = Value(name),
        templateJson = Value(templateJson),
        version = Value(version),
        updatedAt = Value(updatedAt);
  static Insertable<LayoutTemplateRow> custom({
    Expression<String>? uuid,
    Expression<String>? collectionId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? templateJson,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (collectionId != null) 'collection_id': collectionId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (templateJson != null) 'template_json': templateJson,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LayoutTemplatesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? collectionId,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? templateJson,
      Value<int>? version,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return LayoutTemplatesCompanion(
      uuid: uuid ?? this.uuid,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      templateJson: templateJson ?? this.templateJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (templateJson.present) {
      map['template_json'] = Variable<String>(templateJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayoutTemplatesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('templateJson: $templateJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateMetasTable extends CardTemplateMetas
    with TableInfo<$CardTemplateMetasTable, CardTemplateMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifiedAtMeta =
      const VerificationMeta('modifiedAt');
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
      'modified_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _authorUuidMeta =
      const VerificationMeta('authorUuid');
  @override
  late final GeneratedColumn<String> authorUuid = GeneratedColumn<String>(
      'author_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createFromCardUuidMeta =
      const VerificationMeta('createFromCardUuid');
  @override
  late final GeneratedColumn<String> createFromCardUuid =
      GeneratedColumn<String>('create_from_card_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomizedMeta =
      const VerificationMeta('isCustomized');
  @override
  late final GeneratedColumn<bool> isCustomized = GeneratedColumn<bool>(
      'is_customized', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_customized" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        templateUuid,
        createdAt,
        modifiedAt,
        deletedAt,
        authorUuid,
        createFromCardUuid,
        isCustomized
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_meta';
  @override
  VerificationContext validateIntegrity(Insertable<CardTemplateMeta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
          _modifiedAtMeta,
          modifiedAt.isAcceptableOrUnknown(
              data['modified_at']!, _modifiedAtMeta));
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('author_uuid')) {
      context.handle(
          _authorUuidMeta,
          authorUuid.isAcceptableOrUnknown(
              data['author_uuid']!, _authorUuidMeta));
    }
    if (data.containsKey('create_from_card_uuid')) {
      context.handle(
          _createFromCardUuidMeta,
          createFromCardUuid.isAcceptableOrUnknown(
              data['create_from_card_uuid']!, _createFromCardUuidMeta));
    }
    if (data.containsKey('is_customized')) {
      context.handle(
          _isCustomizedMeta,
          isCustomized.isAcceptableOrUnknown(
              data['is_customized']!, _isCustomizedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateUuid};
  @override
  CardTemplateMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateMeta(
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      modifiedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      authorUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_uuid']),
      createFromCardUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}create_from_card_uuid']),
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized']),
    );
  }

  @override
  $CardTemplateMetasTable createAlias(String alias) {
    return $CardTemplateMetasTable(attachedDatabase, alias);
  }
}

class CardTemplateMeta extends DataClass
    implements Insertable<CardTemplateMeta> {
  final String templateUuid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final String? authorUuid;
  final String? createFromCardUuid;
  final bool? isCustomized;
  const CardTemplateMeta(
      {required this.templateUuid,
      required this.createdAt,
      required this.modifiedAt,
      this.deletedAt,
      this.authorUuid,
      this.createFromCardUuid,
      this.isCustomized});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_uuid'] = Variable<String>(templateUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || authorUuid != null) {
      map['author_uuid'] = Variable<String>(authorUuid);
    }
    if (!nullToAbsent || createFromCardUuid != null) {
      map['create_from_card_uuid'] = Variable<String>(createFromCardUuid);
    }
    if (!nullToAbsent || isCustomized != null) {
      map['is_customized'] = Variable<bool>(isCustomized);
    }
    return map;
  }

  CardTemplateMetasCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateMetasCompanion(
      templateUuid: Value(templateUuid),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      authorUuid: authorUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(authorUuid),
      createFromCardUuid: createFromCardUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(createFromCardUuid),
      isCustomized: isCustomized == null && nullToAbsent
          ? const Value.absent()
          : Value(isCustomized),
    );
  }

  factory CardTemplateMeta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateMeta(
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      authorUuid: serializer.fromJson<String?>(json['authorUuid']),
      createFromCardUuid:
          serializer.fromJson<String?>(json['createFromCardUuid']),
      isCustomized: serializer.fromJson<bool?>(json['isCustomized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateUuid': serializer.toJson<String>(templateUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'authorUuid': serializer.toJson<String?>(authorUuid),
      'createFromCardUuid': serializer.toJson<String?>(createFromCardUuid),
      'isCustomized': serializer.toJson<bool?>(isCustomized),
    };
  }

  CardTemplateMeta copyWith(
          {String? templateUuid,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> authorUuid = const Value.absent(),
          Value<String?> createFromCardUuid = const Value.absent(),
          Value<bool?> isCustomized = const Value.absent()}) =>
      CardTemplateMeta(
        templateUuid: templateUuid ?? this.templateUuid,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        authorUuid: authorUuid.present ? authorUuid.value : this.authorUuid,
        createFromCardUuid: createFromCardUuid.present
            ? createFromCardUuid.value
            : this.createFromCardUuid,
        isCustomized:
            isCustomized.present ? isCustomized.value : this.isCustomized,
      );
  CardTemplateMeta copyWithCompanion(CardTemplateMetasCompanion data) {
    return CardTemplateMeta(
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      authorUuid:
          data.authorUuid.present ? data.authorUuid.value : this.authorUuid,
      createFromCardUuid: data.createFromCardUuid.present
          ? data.createFromCardUuid.value
          : this.createFromCardUuid,
      isCustomized: data.isCustomized.present
          ? data.isCustomized.value
          : this.isCustomized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateMeta(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorUuid: $authorUuid, ')
          ..write('createFromCardUuid: $createFromCardUuid, ')
          ..write('isCustomized: $isCustomized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(templateUuid, createdAt, modifiedAt,
      deletedAt, authorUuid, createFromCardUuid, isCustomized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateMeta &&
          other.templateUuid == this.templateUuid &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deletedAt == this.deletedAt &&
          other.authorUuid == this.authorUuid &&
          other.createFromCardUuid == this.createFromCardUuid &&
          other.isCustomized == this.isCustomized);
}

class CardTemplateMetasCompanion extends UpdateCompanion<CardTemplateMeta> {
  final Value<String> templateUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> authorUuid;
  final Value<String?> createFromCardUuid;
  final Value<bool?> isCustomized;
  final Value<int> rowid;
  const CardTemplateMetasCompanion({
    this.templateUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.authorUuid = const Value.absent(),
    this.createFromCardUuid = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTemplateMetasCompanion.insert({
    required String templateUuid,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.deletedAt = const Value.absent(),
    this.authorUuid = const Value.absent(),
    this.createFromCardUuid = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : templateUuid = Value(templateUuid),
        createdAt = Value(createdAt),
        modifiedAt = Value(modifiedAt);
  static Insertable<CardTemplateMeta> custom({
    Expression<String>? templateUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? authorUuid,
    Expression<String>? createFromCardUuid,
    Expression<bool>? isCustomized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (authorUuid != null) 'author_uuid': authorUuid,
      if (createFromCardUuid != null)
        'create_from_card_uuid': createFromCardUuid,
      if (isCustomized != null) 'is_customized': isCustomized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTemplateMetasCompanion copyWith(
      {Value<String>? templateUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? authorUuid,
      Value<String?>? createFromCardUuid,
      Value<bool?>? isCustomized,
      Value<int>? rowid}) {
    return CardTemplateMetasCompanion(
      templateUuid: templateUuid ?? this.templateUuid,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      authorUuid: authorUuid ?? this.authorUuid,
      createFromCardUuid: createFromCardUuid ?? this.createFromCardUuid,
      isCustomized: isCustomized ?? this.isCustomized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (authorUuid.present) {
      map['author_uuid'] = Variable<String>(authorUuid.value);
    }
    if (createFromCardUuid.present) {
      map['create_from_card_uuid'] = Variable<String>(createFromCardUuid.value);
    }
    if (isCustomized.present) {
      map['is_customized'] = Variable<bool>(isCustomized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateMetasCompanion(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorUuid: $authorUuid, ')
          ..write('createFromCardUuid: $createFromCardUuid, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateSettingsTable extends CardTemplateSettings
    with TableInfo<$CardTemplateSettingsTable, CardTemplateSettingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifiedAtMeta =
      const VerificationMeta('modifiedAt');
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
      'modified_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _settingJsonMeta =
      const VerificationMeta('settingJson');
  @override
  late final GeneratedColumn<String> settingJson = GeneratedColumn<String>(
      'setting_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [templateUuid, createdAt, modifiedAt, deletedAt, settingJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_setting';
  @override
  VerificationContext validateIntegrity(
      Insertable<CardTemplateSettingRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
          _modifiedAtMeta,
          modifiedAt.isAcceptableOrUnknown(
              data['modified_at']!, _modifiedAtMeta));
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('setting_json')) {
      context.handle(
          _settingJsonMeta,
          settingJson.isAcceptableOrUnknown(
              data['setting_json']!, _settingJsonMeta));
    } else if (isInserting) {
      context.missing(_settingJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateUuid};
  @override
  CardTemplateSettingRecord map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateSettingRecord(
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      modifiedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      settingJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_json'])!,
    );
  }

  @override
  $CardTemplateSettingsTable createAlias(String alias) {
    return $CardTemplateSettingsTable(attachedDatabase, alias);
  }
}

class CardTemplateSettingRecord extends DataClass
    implements Insertable<CardTemplateSettingRecord> {
  final String templateUuid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final String settingJson;
  const CardTemplateSettingRecord(
      {required this.templateUuid,
      required this.createdAt,
      required this.modifiedAt,
      this.deletedAt,
      required this.settingJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_uuid'] = Variable<String>(templateUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['setting_json'] = Variable<String>(settingJson);
    return map;
  }

  CardTemplateSettingsCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateSettingsCompanion(
      templateUuid: Value(templateUuid),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      settingJson: Value(settingJson),
    );
  }

  factory CardTemplateSettingRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateSettingRecord(
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      settingJson: serializer.fromJson<String>(json['settingJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateUuid': serializer.toJson<String>(templateUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'settingJson': serializer.toJson<String>(settingJson),
    };
  }

  CardTemplateSettingRecord copyWith(
          {String? templateUuid,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? settingJson}) =>
      CardTemplateSettingRecord(
        templateUuid: templateUuid ?? this.templateUuid,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        settingJson: settingJson ?? this.settingJson,
      );
  CardTemplateSettingRecord copyWithCompanion(
      CardTemplateSettingsCompanion data) {
    return CardTemplateSettingRecord(
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      settingJson:
          data.settingJson.present ? data.settingJson.value : this.settingJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSettingRecord(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('settingJson: $settingJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(templateUuid, createdAt, modifiedAt, deletedAt, settingJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateSettingRecord &&
          other.templateUuid == this.templateUuid &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deletedAt == this.deletedAt &&
          other.settingJson == this.settingJson);
}

class CardTemplateSettingsCompanion
    extends UpdateCompanion<CardTemplateSettingRecord> {
  final Value<String> templateUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> settingJson;
  final Value<int> rowid;
  const CardTemplateSettingsCompanion({
    this.templateUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.settingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTemplateSettingsCompanion.insert({
    required String templateUuid,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.deletedAt = const Value.absent(),
    required String settingJson,
    this.rowid = const Value.absent(),
  })  : templateUuid = Value(templateUuid),
        createdAt = Value(createdAt),
        modifiedAt = Value(modifiedAt),
        settingJson = Value(settingJson);
  static Insertable<CardTemplateSettingRecord> custom({
    Expression<String>? templateUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? settingJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (settingJson != null) 'setting_json': settingJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTemplateSettingsCompanion copyWith(
      {Value<String>? templateUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? settingJson,
      Value<int>? rowid}) {
    return CardTemplateSettingsCompanion(
      templateUuid: templateUuid ?? this.templateUuid,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      settingJson: settingJson ?? this.settingJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (settingJson.present) {
      map['setting_json'] = Variable<String>(settingJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSettingsCompanion(')
          ..write('templateUuid: $templateUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('settingJson: $settingJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTemplateSkillUsagesTable extends CardTemplateSkillUsages
    with TableInfo<$CardTemplateSkillUsagesTable, CardTemplateSkillUsage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTemplateSkillUsagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryUuidMeta =
      const VerificationMeta('queryUuid');
  @override
  late final GeneratedColumn<String> queryUuid = GeneratedColumn<String>(
      'query_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateUuidMeta =
      const VerificationMeta('templateUuid');
  @override
  late final GeneratedColumn<String> templateUuid = GeneratedColumn<String>(
      'template_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<String> usedAt = GeneratedColumn<String>(
      'used_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        queryUuid,
        templateUuid,
        skillId,
        usedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_card_template_skill_usage';
  @override
  VerificationContext validateIntegrity(
      Insertable<CardTemplateSkillUsage> instance,
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
    if (data.containsKey('query_uuid')) {
      context.handle(_queryUuidMeta,
          queryUuid.isAcceptableOrUnknown(data['query_uuid']!, _queryUuidMeta));
    } else if (isInserting) {
      context.missing(_queryUuidMeta);
    }
    if (data.containsKey('template_uuid')) {
      context.handle(
          _templateUuidMeta,
          templateUuid.isAcceptableOrUnknown(
              data['template_uuid']!, _templateUuidMeta));
    } else if (isInserting) {
      context.missing(_templateUuidMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(_usedAtMeta,
          usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta));
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTemplateSkillUsage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTemplateSkillUsage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      queryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_uuid'])!,
      templateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_uuid'])!,
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      usedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}used_at'])!,
    );
  }

  @override
  $CardTemplateSkillUsagesTable createAlias(String alias) {
    return $CardTemplateSkillUsagesTable(attachedDatabase, alias);
  }
}

class CardTemplateSkillUsage extends DataClass
    implements Insertable<CardTemplateSkillUsage> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String queryUuid;
  final String templateUuid;
  final int skillId;
  final String usedAt;
  const CardTemplateSkillUsage(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.queryUuid,
      required this.templateUuid,
      required this.skillId,
      required this.usedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['query_uuid'] = Variable<String>(queryUuid);
    map['template_uuid'] = Variable<String>(templateUuid);
    map['skill_id'] = Variable<int>(skillId);
    map['used_at'] = Variable<String>(usedAt);
    return map;
  }

  CardTemplateSkillUsagesCompanion toCompanion(bool nullToAbsent) {
    return CardTemplateSkillUsagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      queryUuid: Value(queryUuid),
      templateUuid: Value(templateUuid),
      skillId: Value(skillId),
      usedAt: Value(usedAt),
    );
  }

  factory CardTemplateSkillUsage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTemplateSkillUsage(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      queryUuid: serializer.fromJson<String>(json['queryUuid']),
      templateUuid: serializer.fromJson<String>(json['templateUuid']),
      skillId: serializer.fromJson<int>(json['skillId']),
      usedAt: serializer.fromJson<String>(json['usedAt']),
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
      'queryUuid': serializer.toJson<String>(queryUuid),
      'templateUuid': serializer.toJson<String>(templateUuid),
      'skillId': serializer.toJson<int>(skillId),
      'usedAt': serializer.toJson<String>(usedAt),
    };
  }

  CardTemplateSkillUsage copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? queryUuid,
          String? templateUuid,
          int? skillId,
          String? usedAt}) =>
      CardTemplateSkillUsage(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        queryUuid: queryUuid ?? this.queryUuid,
        templateUuid: templateUuid ?? this.templateUuid,
        skillId: skillId ?? this.skillId,
        usedAt: usedAt ?? this.usedAt,
      );
  CardTemplateSkillUsage copyWithCompanion(
      CardTemplateSkillUsagesCompanion data) {
    return CardTemplateSkillUsage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      queryUuid: data.queryUuid.present ? data.queryUuid.value : this.queryUuid,
      templateUuid: data.templateUuid.present
          ? data.templateUuid.value
          : this.templateUuid,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSkillUsage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('templateUuid: $templateUuid, ')
          ..write('skillId: $skillId, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, lastUpdatedAt, deletedAt,
      queryUuid, templateUuid, skillId, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTemplateSkillUsage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.queryUuid == this.queryUuid &&
          other.templateUuid == this.templateUuid &&
          other.skillId == this.skillId &&
          other.usedAt == this.usedAt);
}

class CardTemplateSkillUsagesCompanion
    extends UpdateCompanion<CardTemplateSkillUsage> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> queryUuid;
  final Value<String> templateUuid;
  final Value<int> skillId;
  final Value<String> usedAt;
  const CardTemplateSkillUsagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.queryUuid = const Value.absent(),
    this.templateUuid = const Value.absent(),
    this.skillId = const Value.absent(),
    this.usedAt = const Value.absent(),
  });
  CardTemplateSkillUsagesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String queryUuid,
    required String templateUuid,
    required int skillId,
    required String usedAt,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        queryUuid = Value(queryUuid),
        templateUuid = Value(templateUuid),
        skillId = Value(skillId),
        usedAt = Value(usedAt);
  static Insertable<CardTemplateSkillUsage> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? queryUuid,
    Expression<String>? templateUuid,
    Expression<int>? skillId,
    Expression<String>? usedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (queryUuid != null) 'query_uuid': queryUuid,
      if (templateUuid != null) 'template_uuid': templateUuid,
      if (skillId != null) 'skill_id': skillId,
      if (usedAt != null) 'used_at': usedAt,
    });
  }

  CardTemplateSkillUsagesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? queryUuid,
      Value<String>? templateUuid,
      Value<int>? skillId,
      Value<String>? usedAt}) {
    return CardTemplateSkillUsagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      queryUuid: queryUuid ?? this.queryUuid,
      templateUuid: templateUuid ?? this.templateUuid,
      skillId: skillId ?? this.skillId,
      usedAt: usedAt ?? this.usedAt,
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
    if (queryUuid.present) {
      map['query_uuid'] = Variable<String>(queryUuid.value);
    }
    if (templateUuid.present) {
      map['template_uuid'] = Variable<String>(templateUuid.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<String>(usedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTemplateSkillUsagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queryUuid: $queryUuid, ')
          ..write('templateUuid: $templateUuid, ')
          ..write('skillId: $skillId, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }
}

class $MarketTemplateInstallsTable extends MarketTemplateInstalls
    with TableInfo<$MarketTemplateInstallsTable, MarketTemplateInstall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketTemplateInstallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTemplateUuidMeta =
      const VerificationMeta('localTemplateUuid');
  @override
  late final GeneratedColumn<String> localTemplateUuid =
      GeneratedColumn<String>('local_template_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marketTemplateIdMeta =
      const VerificationMeta('marketTemplateId');
  @override
  late final GeneratedColumn<String> marketTemplateId = GeneratedColumn<String>(
      'market_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marketVersionIdMeta =
      const VerificationMeta('marketVersionId');
  @override
  late final GeneratedColumn<String> marketVersionId = GeneratedColumn<String>(
      'market_version_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _installedAtMeta =
      const VerificationMeta('installedAt');
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
      'installed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pinnedAtMeta =
      const VerificationMeta('pinnedAt');
  @override
  late final GeneratedColumn<DateTime> pinnedAt = GeneratedColumn<DateTime>(
      'pinned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastCheckedAtMeta =
      const VerificationMeta('lastCheckedAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>('last_checked_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localTemplateUuid,
        marketTemplateId,
        marketVersionId,
        installedAt,
        pinnedAt,
        lastCheckedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_market_template_installs';
  @override
  VerificationContext validateIntegrity(
      Insertable<MarketTemplateInstall> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_template_uuid')) {
      context.handle(
          _localTemplateUuidMeta,
          localTemplateUuid.isAcceptableOrUnknown(
              data['local_template_uuid']!, _localTemplateUuidMeta));
    } else if (isInserting) {
      context.missing(_localTemplateUuidMeta);
    }
    if (data.containsKey('market_template_id')) {
      context.handle(
          _marketTemplateIdMeta,
          marketTemplateId.isAcceptableOrUnknown(
              data['market_template_id']!, _marketTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_marketTemplateIdMeta);
    }
    if (data.containsKey('market_version_id')) {
      context.handle(
          _marketVersionIdMeta,
          marketVersionId.isAcceptableOrUnknown(
              data['market_version_id']!, _marketVersionIdMeta));
    } else if (isInserting) {
      context.missing(_marketVersionIdMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
          _installedAtMeta,
          installedAt.isAcceptableOrUnknown(
              data['installed_at']!, _installedAtMeta));
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('pinned_at')) {
      context.handle(_pinnedAtMeta,
          pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta));
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
          _lastCheckedAtMeta,
          lastCheckedAt.isAcceptableOrUnknown(
              data['last_checked_at']!, _lastCheckedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTemplateUuid};
  @override
  MarketTemplateInstall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketTemplateInstall(
      localTemplateUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_template_uuid'])!,
      marketTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}market_template_id'])!,
      marketVersionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}market_version_id'])!,
      installedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}installed_at'])!,
      pinnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}pinned_at']),
      lastCheckedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_checked_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $MarketTemplateInstallsTable createAlias(String alias) {
    return $MarketTemplateInstallsTable(attachedDatabase, alias);
  }
}

class MarketTemplateInstall extends DataClass
    implements Insertable<MarketTemplateInstall> {
  final String localTemplateUuid;
  final String marketTemplateId;
  final String marketVersionId;
  final DateTime installedAt;
  final DateTime? pinnedAt;
  final DateTime? lastCheckedAt;
  final DateTime? deletedAt;
  const MarketTemplateInstall(
      {required this.localTemplateUuid,
      required this.marketTemplateId,
      required this.marketVersionId,
      required this.installedAt,
      this.pinnedAt,
      this.lastCheckedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_template_uuid'] = Variable<String>(localTemplateUuid);
    map['market_template_id'] = Variable<String>(marketTemplateId);
    map['market_version_id'] = Variable<String>(marketVersionId);
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || pinnedAt != null) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MarketTemplateInstallsCompanion toCompanion(bool nullToAbsent) {
    return MarketTemplateInstallsCompanion(
      localTemplateUuid: Value(localTemplateUuid),
      marketTemplateId: Value(marketTemplateId),
      marketVersionId: Value(marketVersionId),
      installedAt: Value(installedAt),
      pinnedAt: pinnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MarketTemplateInstall.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketTemplateInstall(
      localTemplateUuid: serializer.fromJson<String>(json['localTemplateUuid']),
      marketTemplateId: serializer.fromJson<String>(json['marketTemplateId']),
      marketVersionId: serializer.fromJson<String>(json['marketVersionId']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      pinnedAt: serializer.fromJson<DateTime?>(json['pinnedAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTemplateUuid': serializer.toJson<String>(localTemplateUuid),
      'marketTemplateId': serializer.toJson<String>(marketTemplateId),
      'marketVersionId': serializer.toJson<String>(marketVersionId),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'pinnedAt': serializer.toJson<DateTime?>(pinnedAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MarketTemplateInstall copyWith(
          {String? localTemplateUuid,
          String? marketTemplateId,
          String? marketVersionId,
          DateTime? installedAt,
          Value<DateTime?> pinnedAt = const Value.absent(),
          Value<DateTime?> lastCheckedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      MarketTemplateInstall(
        localTemplateUuid: localTemplateUuid ?? this.localTemplateUuid,
        marketTemplateId: marketTemplateId ?? this.marketTemplateId,
        marketVersionId: marketVersionId ?? this.marketVersionId,
        installedAt: installedAt ?? this.installedAt,
        pinnedAt: pinnedAt.present ? pinnedAt.value : this.pinnedAt,
        lastCheckedAt:
            lastCheckedAt.present ? lastCheckedAt.value : this.lastCheckedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  MarketTemplateInstall copyWithCompanion(
      MarketTemplateInstallsCompanion data) {
    return MarketTemplateInstall(
      localTemplateUuid: data.localTemplateUuid.present
          ? data.localTemplateUuid.value
          : this.localTemplateUuid,
      marketTemplateId: data.marketTemplateId.present
          ? data.marketTemplateId.value
          : this.marketTemplateId,
      marketVersionId: data.marketVersionId.present
          ? data.marketVersionId.value
          : this.marketVersionId,
      installedAt:
          data.installedAt.present ? data.installedAt.value : this.installedAt,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketTemplateInstall(')
          ..write('localTemplateUuid: $localTemplateUuid, ')
          ..write('marketTemplateId: $marketTemplateId, ')
          ..write('marketVersionId: $marketVersionId, ')
          ..write('installedAt: $installedAt, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localTemplateUuid, marketTemplateId,
      marketVersionId, installedAt, pinnedAt, lastCheckedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketTemplateInstall &&
          other.localTemplateUuid == this.localTemplateUuid &&
          other.marketTemplateId == this.marketTemplateId &&
          other.marketVersionId == this.marketVersionId &&
          other.installedAt == this.installedAt &&
          other.pinnedAt == this.pinnedAt &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.deletedAt == this.deletedAt);
}

class MarketTemplateInstallsCompanion
    extends UpdateCompanion<MarketTemplateInstall> {
  final Value<String> localTemplateUuid;
  final Value<String> marketTemplateId;
  final Value<String> marketVersionId;
  final Value<DateTime> installedAt;
  final Value<DateTime?> pinnedAt;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MarketTemplateInstallsCompanion({
    this.localTemplateUuid = const Value.absent(),
    this.marketTemplateId = const Value.absent(),
    this.marketVersionId = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketTemplateInstallsCompanion.insert({
    required String localTemplateUuid,
    required String marketTemplateId,
    required String marketVersionId,
    required DateTime installedAt,
    this.pinnedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : localTemplateUuid = Value(localTemplateUuid),
        marketTemplateId = Value(marketTemplateId),
        marketVersionId = Value(marketVersionId),
        installedAt = Value(installedAt);
  static Insertable<MarketTemplateInstall> custom({
    Expression<String>? localTemplateUuid,
    Expression<String>? marketTemplateId,
    Expression<String>? marketVersionId,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? pinnedAt,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTemplateUuid != null) 'local_template_uuid': localTemplateUuid,
      if (marketTemplateId != null) 'market_template_id': marketTemplateId,
      if (marketVersionId != null) 'market_version_id': marketVersionId,
      if (installedAt != null) 'installed_at': installedAt,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketTemplateInstallsCompanion copyWith(
      {Value<String>? localTemplateUuid,
      Value<String>? marketTemplateId,
      Value<String>? marketVersionId,
      Value<DateTime>? installedAt,
      Value<DateTime?>? pinnedAt,
      Value<DateTime?>? lastCheckedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return MarketTemplateInstallsCompanion(
      localTemplateUuid: localTemplateUuid ?? this.localTemplateUuid,
      marketTemplateId: marketTemplateId ?? this.marketTemplateId,
      marketVersionId: marketVersionId ?? this.marketVersionId,
      installedAt: installedAt ?? this.installedAt,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTemplateUuid.present) {
      map['local_template_uuid'] = Variable<String>(localTemplateUuid.value);
    }
    if (marketTemplateId.present) {
      map['market_template_id'] = Variable<String>(marketTemplateId.value);
    }
    if (marketVersionId.present) {
      map['market_version_id'] = Variable<String>(marketVersionId.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketTemplateInstallsCompanion(')
          ..write('localTemplateUuid: $localTemplateUuid, ')
          ..write('marketTemplateId: $marketTemplateId, ')
          ..write('marketVersionId: $marketVersionId, ')
          ..write('installedAt: $installedAt, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationTypesTable extends DivinationTypes
    with TableInfo<$DivinationTypesTable, DivinationTypeDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationTypesTable(this.attachedDatabase, [this._alias]);
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
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationTypeDataModel> instance,
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
  DivinationTypeDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationTypeDataModel(
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
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $DivinationTypesTable createAlias(String alias) {
    return $DivinationTypesTable(attachedDatabase, alias);
  }
}

class DivinationTypesCompanion
    extends UpdateCompanion<DivinationTypeDataModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> description;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const DivinationTypesCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationTypesCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String description,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        description = Value(description),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<DivinationTypeDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? description,
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
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? name,
      Value<String>? description,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return DivinationTypesCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      description: description ?? this.description,
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
    return (StringBuffer('DivinationTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeekersTable extends Seekers with TableInfo<$SeekersTable, SeekerModel> {
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
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Gender, String> gender =
      GeneratedColumn<String>('gender', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Gender>($SeekersTable.$convertergender);
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
  late final GeneratedColumnWithTypeConverter<DateTimeType, int> timingType =
      GeneratedColumn<int>('timing_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTimeType>($SeekersTable.$convertertimingType);
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> yearGanZhi =
      GeneratedColumn<int>('year_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$converteryearGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> monthGanZhi =
      GeneratedColumn<int>('month_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$convertermonthGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> dayGanZhi =
      GeneratedColumn<int>('day_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$converterdayGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> timeGanZhi =
      GeneratedColumn<int>('time_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($SeekersTable.$convertertimeGanZhi);
  static const VerificationMeta _lunarMonthMeta =
      const VerificationMeta('lunarMonth');
  @override
  late final GeneratedColumn<int> lunarMonth = GeneratedColumn<int>(
      'lunar_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isLeapMonthMeta =
      const VerificationMeta('isLeapMonth');
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
      'is_leap_month', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_leap_month" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lunarDayMeta =
      const VerificationMeta('lunarDay');
  @override
  late final GeneratedColumn<int> lunarDay = GeneratedColumn<int>(
      'lunar_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timingInfoUuidMeta =
      const VerificationMeta('timingInfoUuid');
  @override
  late final GeneratedColumn<String> timingInfoUuid = GeneratedColumn<String>(
      'timing_info_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?,
      String> timingInfoListJson = GeneratedColumn<String>(
          'info_list_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false)
      .withConverter<List<DivinationDatetimeModel>?>(
          $SeekersTable.$convertertimingInfoListJsonn);
  @override
  late final GeneratedColumnWithTypeConverter<Location?, String> location =
      GeneratedColumn<String>('location_json', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Location?>($SeekersTable.$converterlocation);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        username,
        nickname,
        gender,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        timingType,
        datetime,
        yearGanZhi,
        monthGanZhi,
        dayGanZhi,
        timeGanZhi,
        lunarMonth,
        isLeapMonth,
        lunarDay,
        divinationUuid,
        timingInfoUuid,
        timingInfoListJson,
        location
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_seekers';
  @override
  VerificationContext validateIntegrity(Insertable<SeekerModel> instance,
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
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
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
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
          _lunarMonthMeta,
          lunarMonth.isAcceptableOrUnknown(
              data['lunar_month']!, _lunarMonthMeta));
    } else if (isInserting) {
      context.missing(_lunarMonthMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
          _isLeapMonthMeta,
          isLeapMonth.isAcceptableOrUnknown(
              data['is_leap_month']!, _isLeapMonthMeta));
    }
    if (data.containsKey('lunar_day')) {
      context.handle(_lunarDayMeta,
          lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta));
    } else if (isInserting) {
      context.missing(_lunarDayMeta);
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('timing_info_uuid')) {
      context.handle(
          _timingInfoUuidMeta,
          timingInfoUuid.isAcceptableOrUnknown(
              data['timing_info_uuid']!, _timingInfoUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SeekerModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeekerModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      location: $SeekersTable.$converterlocation.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_json'])),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      timingType: $SeekersTable.$convertertimingType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timing_type'])!),
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      yearGanZhi: $SeekersTable.$converteryearGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year_gan_zhi'])!),
      monthGanZhi: $SeekersTable.$convertermonthGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month_gan_zhi'])!),
      dayGanZhi: $SeekersTable.$converterdayGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_gan_zhi'])!),
      timeGanZhi: $SeekersTable.$convertertimeGanZhi.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_gan_zhi'])!),
      lunarMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_month'])!,
      isLeapMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_leap_month'])!,
      lunarDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_day'])!,
      timingInfoUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}timing_info_uuid']),
      timingInfoListJson: $SeekersTable.$convertertimingInfoListJsonn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}info_list_json'])),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      gender: $SeekersTable.$convertergender.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!),
    );
  }

  @override
  $SeekersTable createAlias(String alias) {
    return $SeekersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, String, String> $convertergender =
      const EnumNameConverter<Gender>(Gender.values);
  static JsonTypeConverter2<DateTimeType, int, int> $convertertimingType =
      const EnumIndexConverter<DateTimeType>(DateTimeType.values);
  static JsonTypeConverter2<JiaZi, int, int> $converteryearGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertermonthGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $converterdayGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertertimeGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static TypeConverter<List<DivinationDatetimeModel>, String>
      $convertertimingInfoListJson = const DivinationDatetimeModelConverter();
  static TypeConverter<List<DivinationDatetimeModel>?, String?>
      $convertertimingInfoListJsonn =
      NullAwareTypeConverter.wrap($convertertimingInfoListJson);
  static TypeConverter<Location?, String?> $converterlocation =
      const NullableLocationConverter();
}

class SeekersCompanion extends UpdateCompanion<SeekerModel> {
  final Value<String> uuid;
  final Value<String?> username;
  final Value<String?> nickname;
  final Value<Gender> gender;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTimeType> timingType;
  final Value<DateTime> datetime;
  final Value<JiaZi> yearGanZhi;
  final Value<JiaZi> monthGanZhi;
  final Value<JiaZi> dayGanZhi;
  final Value<JiaZi> timeGanZhi;
  final Value<int> lunarMonth;
  final Value<bool> isLeapMonth;
  final Value<int> lunarDay;
  final Value<String> divinationUuid;
  final Value<String?> timingInfoUuid;
  final Value<List<DivinationDatetimeModel>?> timingInfoListJson;
  final Value<Location?> location;
  final Value<int> rowid;
  const SeekersCompanion({
    this.uuid = const Value.absent(),
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.timingType = const Value.absent(),
    this.datetime = const Value.absent(),
    this.yearGanZhi = const Value.absent(),
    this.monthGanZhi = const Value.absent(),
    this.dayGanZhi = const Value.absent(),
    this.timeGanZhi = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.timingInfoUuid = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeekersCompanion.insert({
    required String uuid,
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    required Gender gender,
    required DateTime createdAt,
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTimeType timingType,
    required DateTime datetime,
    required JiaZi yearGanZhi,
    required JiaZi monthGanZhi,
    required JiaZi dayGanZhi,
    required JiaZi timeGanZhi,
    required int lunarMonth,
    this.isLeapMonth = const Value.absent(),
    required int lunarDay,
    required String divinationUuid,
    this.timingInfoUuid = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        gender = Value(gender),
        createdAt = Value(createdAt),
        timingType = Value(timingType),
        datetime = Value(datetime),
        yearGanZhi = Value(yearGanZhi),
        monthGanZhi = Value(monthGanZhi),
        dayGanZhi = Value(dayGanZhi),
        timeGanZhi = Value(timeGanZhi),
        lunarMonth = Value(lunarMonth),
        lunarDay = Value(lunarDay),
        divinationUuid = Value(divinationUuid);
  static Insertable<SeekerModel> custom({
    Expression<String>? uuid,
    Expression<String>? username,
    Expression<String>? nickname,
    Expression<String>? gender,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? timingType,
    Expression<DateTime>? datetime,
    Expression<int>? yearGanZhi,
    Expression<int>? monthGanZhi,
    Expression<int>? dayGanZhi,
    Expression<int>? timeGanZhi,
    Expression<int>? lunarMonth,
    Expression<bool>? isLeapMonth,
    Expression<int>? lunarDay,
    Expression<String>? divinationUuid,
    Expression<String>? timingInfoUuid,
    Expression<String>? timingInfoListJson,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (username != null) 'username': username,
      if (nickname != null) 'nickname': nickname,
      if (gender != null) 'gender': gender,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (timingType != null) 'timing_type': timingType,
      if (datetime != null) 'datetime': datetime,
      if (yearGanZhi != null) 'year_gan_zhi': yearGanZhi,
      if (monthGanZhi != null) 'month_gan_zhi': monthGanZhi,
      if (dayGanZhi != null) 'day_gan_zhi': dayGanZhi,
      if (timeGanZhi != null) 'time_gan_zhi': timeGanZhi,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (timingInfoUuid != null) 'timing_info_uuid': timingInfoUuid,
      if (timingInfoListJson != null) 'info_list_json': timingInfoListJson,
      if (location != null) 'location_json': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeekersCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? username,
      Value<String?>? nickname,
      Value<Gender>? gender,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTimeType>? timingType,
      Value<DateTime>? datetime,
      Value<JiaZi>? yearGanZhi,
      Value<JiaZi>? monthGanZhi,
      Value<JiaZi>? dayGanZhi,
      Value<JiaZi>? timeGanZhi,
      Value<int>? lunarMonth,
      Value<bool>? isLeapMonth,
      Value<int>? lunarDay,
      Value<String>? divinationUuid,
      Value<String?>? timingInfoUuid,
      Value<List<DivinationDatetimeModel>?>? timingInfoListJson,
      Value<Location?>? location,
      Value<int>? rowid}) {
    return SeekersCompanion(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      timingType: timingType ?? this.timingType,
      datetime: datetime ?? this.datetime,
      yearGanZhi: yearGanZhi ?? this.yearGanZhi,
      monthGanZhi: monthGanZhi ?? this.monthGanZhi,
      dayGanZhi: dayGanZhi ?? this.dayGanZhi,
      timeGanZhi: timeGanZhi ?? this.timeGanZhi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      timingInfoUuid: timingInfoUuid ?? this.timingInfoUuid,
      timingInfoListJson: timingInfoListJson ?? this.timingInfoListJson,
      location: location ?? this.location,
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
    if (gender.present) {
      map['gender'] =
          Variable<String>($SeekersTable.$convertergender.toSql(gender.value));
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
    if (timingType.present) {
      map['timing_type'] = Variable<int>(
          $SeekersTable.$convertertimingType.toSql(timingType.value));
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (yearGanZhi.present) {
      map['year_gan_zhi'] = Variable<int>(
          $SeekersTable.$converteryearGanZhi.toSql(yearGanZhi.value));
    }
    if (monthGanZhi.present) {
      map['month_gan_zhi'] = Variable<int>(
          $SeekersTable.$convertermonthGanZhi.toSql(monthGanZhi.value));
    }
    if (dayGanZhi.present) {
      map['day_gan_zhi'] = Variable<int>(
          $SeekersTable.$converterdayGanZhi.toSql(dayGanZhi.value));
    }
    if (timeGanZhi.present) {
      map['time_gan_zhi'] = Variable<int>(
          $SeekersTable.$convertertimeGanZhi.toSql(timeGanZhi.value));
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<int>(lunarMonth.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<int>(lunarDay.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (timingInfoUuid.present) {
      map['timing_info_uuid'] = Variable<String>(timingInfoUuid.value);
    }
    if (timingInfoListJson.present) {
      map['info_list_json'] = Variable<String>($SeekersTable
          .$convertertimingInfoListJsonn
          .toSql(timingInfoListJson.value));
    }
    if (location.present) {
      map['location_json'] = Variable<String>(
          $SeekersTable.$converterlocation.toSql(location.value));
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
          ..write('gender: $gender, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('timingType: $timingType, ')
          ..write('datetime: $datetime, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('monthGanZhi: $monthGanZhi, ')
          ..write('dayGanZhi: $dayGanZhi, ')
          ..write('timeGanZhi: $timeGanZhi, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('timingInfoUuid: $timingInfoUuid, ')
          ..write('timingInfoListJson: $timingInfoListJson, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DivinationsTable extends Divinations
    with TableInfo<$DivinationsTable, DivinationRequestInfoDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _divinationTypeUuidMeta =
      const VerificationMeta('divinationTypeUuid');
  @override
  late final GeneratedColumn<String> divinationTypeUuid =
      GeneratedColumn<String>('divination_type_uuid', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES t_divination_types (uuid)'));
  static const VerificationMeta _fateYearMeta =
      const VerificationMeta('fateYear');
  @override
  late final GeneratedColumn<String> fateYear = GeneratedColumn<String>(
      'fate_year', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerSeekerUuidMeta =
      const VerificationMeta('ownerSeekerUuid');
  @override
  late final GeneratedColumn<String> ownerSeekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_seekers (uuid)'));
  @override
  late final GeneratedColumnWithTypeConverter<Gender?, String> gender =
      GeneratedColumn<String>('gender', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Gender?>($DivinationsTable.$convertergendern);
  static const VerificationMeta _seekerNameMeta =
      const VerificationMeta('seekerName');
  @override
  late final GeneratedColumn<String> seekerName = GeneratedColumn<String>(
      'seeker_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tinyPredictMeta =
      const VerificationMeta('tinyPredict');
  @override
  late final GeneratedColumn<String> tinyPredict = GeneratedColumn<String>(
      'tiny_predict', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _directlyPredictMeta =
      const VerificationMeta('directlyPredict');
  @override
  late final GeneratedColumn<String> directlyPredict = GeneratedColumn<String>(
      'directly_predict', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationTypeUuid,
        fateYear,
        question,
        detail,
        ownerSeekerUuid,
        gender,
        seekerName,
        tinyPredict,
        directlyPredict
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divinations';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationRequestInfoDataModel> instance,
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
    if (data.containsKey('divination_type_uuid')) {
      context.handle(
          _divinationTypeUuidMeta,
          divinationTypeUuid.isAcceptableOrUnknown(
              data['divination_type_uuid']!, _divinationTypeUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationTypeUuidMeta);
    }
    if (data.containsKey('fate_year')) {
      context.handle(_fateYearMeta,
          fateYear.isAcceptableOrUnknown(data['fate_year']!, _fateYearMeta));
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _ownerSeekerUuidMeta,
          ownerSeekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _ownerSeekerUuidMeta));
    }
    if (data.containsKey('seeker_name')) {
      context.handle(
          _seekerNameMeta,
          seekerName.isAcceptableOrUnknown(
              data['seeker_name']!, _seekerNameMeta));
    }
    if (data.containsKey('tiny_predict')) {
      context.handle(
          _tinyPredictMeta,
          tinyPredict.isAcceptableOrUnknown(
              data['tiny_predict']!, _tinyPredictMeta));
    }
    if (data.containsKey('directly_predict')) {
      context.handle(
          _directlyPredictMeta,
          directlyPredict.isAcceptableOrUnknown(
              data['directly_predict']!, _directlyPredictMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  DivinationRequestInfoDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationRequestInfoDataModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationTypeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_type_uuid'])!,
      fateYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fate_year']),
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question']),
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
      ownerSeekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid']),
      gender: $DivinationsTable.$convertergendern.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])),
      seekerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_name']),
      tinyPredict: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tiny_predict']),
      directlyPredict: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}directly_predict']),
    );
  }

  @override
  $DivinationsTable createAlias(String alias) {
    return $DivinationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, String, String> $convertergender =
      const EnumNameConverter<Gender>(Gender.values);
  static JsonTypeConverter2<Gender?, String?, String?> $convertergendern =
      JsonTypeConverter2.asNullable($convertergender);
}

class DivinationsCompanion
    extends UpdateCompanion<DivinationRequestInfoDataModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationTypeUuid;
  final Value<String?> fateYear;
  final Value<String?> question;
  final Value<String?> detail;
  final Value<String?> ownerSeekerUuid;
  final Value<Gender?> gender;
  final Value<String?> seekerName;
  final Value<String?> tinyPredict;
  final Value<String?> directlyPredict;
  final Value<int> rowid;
  const DivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationTypeUuid = const Value.absent(),
    this.fateYear = const Value.absent(),
    this.question = const Value.absent(),
    this.detail = const Value.absent(),
    this.ownerSeekerUuid = const Value.absent(),
    this.gender = const Value.absent(),
    this.seekerName = const Value.absent(),
    this.tinyPredict = const Value.absent(),
    this.directlyPredict = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DivinationsCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String divinationTypeUuid,
    this.fateYear = const Value.absent(),
    this.question = const Value.absent(),
    this.detail = const Value.absent(),
    this.ownerSeekerUuid = const Value.absent(),
    this.gender = const Value.absent(),
    this.seekerName = const Value.absent(),
    this.tinyPredict = const Value.absent(),
    this.directlyPredict = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        divinationTypeUuid = Value(divinationTypeUuid);
  static Insertable<DivinationRequestInfoDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationTypeUuid,
    Expression<String>? fateYear,
    Expression<String>? question,
    Expression<String>? detail,
    Expression<String>? ownerSeekerUuid,
    Expression<String>? gender,
    Expression<String>? seekerName,
    Expression<String>? tinyPredict,
    Expression<String>? directlyPredict,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationTypeUuid != null)
        'divination_type_uuid': divinationTypeUuid,
      if (fateYear != null) 'fate_year': fateYear,
      if (question != null) 'question': question,
      if (detail != null) 'detail': detail,
      if (ownerSeekerUuid != null) 'seeker_uuid': ownerSeekerUuid,
      if (gender != null) 'gender': gender,
      if (seekerName != null) 'seeker_name': seekerName,
      if (tinyPredict != null) 'tiny_predict': tinyPredict,
      if (directlyPredict != null) 'directly_predict': directlyPredict,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationTypeUuid,
      Value<String?>? fateYear,
      Value<String?>? question,
      Value<String?>? detail,
      Value<String?>? ownerSeekerUuid,
      Value<Gender?>? gender,
      Value<String?>? seekerName,
      Value<String?>? tinyPredict,
      Value<String?>? directlyPredict,
      Value<int>? rowid}) {
    return DivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationTypeUuid: divinationTypeUuid ?? this.divinationTypeUuid,
      fateYear: fateYear ?? this.fateYear,
      question: question ?? this.question,
      detail: detail ?? this.detail,
      ownerSeekerUuid: ownerSeekerUuid ?? this.ownerSeekerUuid,
      gender: gender ?? this.gender,
      seekerName: seekerName ?? this.seekerName,
      tinyPredict: tinyPredict ?? this.tinyPredict,
      directlyPredict: directlyPredict ?? this.directlyPredict,
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
    if (divinationTypeUuid.present) {
      map['divination_type_uuid'] = Variable<String>(divinationTypeUuid.value);
    }
    if (fateYear.present) {
      map['fate_year'] = Variable<String>(fateYear.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (ownerSeekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(ownerSeekerUuid.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(
          $DivinationsTable.$convertergendern.toSql(gender.value));
    }
    if (seekerName.present) {
      map['seeker_name'] = Variable<String>(seekerName.value);
    }
    if (tinyPredict.present) {
      map['tiny_predict'] = Variable<String>(tinyPredict.value);
    }
    if (directlyPredict.present) {
      map['directly_predict'] = Variable<String>(directlyPredict.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationTypeUuid: $divinationTypeUuid, ')
          ..write('fateYear: $fateYear, ')
          ..write('question: $question, ')
          ..write('detail: $detail, ')
          ..write('ownerSeekerUuid: $ownerSeekerUuid, ')
          ..write('gender: $gender, ')
          ..write('seekerName: $seekerName, ')
          ..write('tinyPredict: $tinyPredict, ')
          ..write('directlyPredict: $directlyPredict, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CombinedDivinationsTable extends CombinedDivinations
    with TableInfo<$CombinedDivinationsTable, CombinedDivination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombinedDivinationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divinations (uuid)'));
  @override
  List<GeneratedColumn> get $columns =>
      [uuid, createdAt, lastUpdatedAt, deletedAt, order, divinationUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_combined_divinations';
  @override
  VerificationContext validateIntegrity(Insertable<CombinedDivination> instance,
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
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  CombinedDivination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CombinedDivination(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
    );
  }

  @override
  $CombinedDivinationsTable createAlias(String alias) {
    return $CombinedDivinationsTable(attachedDatabase, alias);
  }
}

class CombinedDivination extends DataClass
    implements Insertable<CombinedDivination> {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final int order;
  final String divinationUuid;
  const CombinedDivination(
      {required this.uuid,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.order,
      required this.divinationUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order'] = Variable<int>(order);
    map['divination_uuid'] = Variable<String>(divinationUuid);
    return map;
  }

  CombinedDivinationsCompanion toCompanion(bool nullToAbsent) {
    return CombinedDivinationsCompanion(
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      order: Value(order),
      divinationUuid: Value(divinationUuid),
    );
  }

  factory CombinedDivination.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CombinedDivination(
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      order: serializer.fromJson<int>(json['order']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
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
      'order': serializer.toJson<int>(order),
      'divinationUuid': serializer.toJson<String>(divinationUuid),
    };
  }

  CombinedDivination copyWith(
          {String? uuid,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? order,
          String? divinationUuid}) =>
      CombinedDivination(
        uuid: uuid ?? this.uuid,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        order: order ?? this.order,
        divinationUuid: divinationUuid ?? this.divinationUuid,
      );
  CombinedDivination copyWithCompanion(CombinedDivinationsCompanion data) {
    return CombinedDivination(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      order: data.order.present ? data.order.value : this.order,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CombinedDivination(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('order: $order, ')
          ..write('divinationUuid: $divinationUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, createdAt, lastUpdatedAt, deletedAt, order, divinationUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombinedDivination &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.order == this.order &&
          other.divinationUuid == this.divinationUuid);
}

class CombinedDivinationsCompanion extends UpdateCompanion<CombinedDivination> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> order;
  final Value<String> divinationUuid;
  final Value<int> rowid;
  const CombinedDivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CombinedDivinationsCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required int order,
    required String divinationUuid,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        order = Value(order),
        divinationUuid = Value(divinationUuid);
  static Insertable<CombinedDivination> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? order,
    Expression<String>? divinationUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (order != null) 'order': order,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CombinedDivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? order,
      Value<String>? divinationUuid,
      Value<int>? rowid}) {
    return CombinedDivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      order: order ?? this.order,
      divinationUuid: divinationUuid ?? this.divinationUuid,
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
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombinedDivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('order: $order, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PanelsTable extends Panels with TableInfo<$PanelsTable, Panel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<EnumPanelType, int> panelType =
      GeneratedColumn<int>('panel_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<EnumPanelType>($PanelsTable.$converterpanelType);
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_skills (id)'));
  static const VerificationMeta _divinateTypeMeta =
      const VerificationMeta('divinateType');
  @override
  late final GeneratedColumn<String> divinateType = GeneratedColumn<String>(
      'divinate_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _divinateUuidMeta =
      const VerificationMeta('divinateUuid');
  @override
  late final GeneratedColumn<String> divinateUuid = GeneratedColumn<String>(
      'divinate_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        lastUpdatedAt,
        deletedAt,
        uuid,
        panelType,
        skillId,
        divinateType,
        divinateUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_panels';
  @override
  VerificationContext validateIntegrity(Insertable<Panel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('divinate_type')) {
      context.handle(
          _divinateTypeMeta,
          divinateType.isAcceptableOrUnknown(
              data['divinate_type']!, _divinateTypeMeta));
    } else if (isInserting) {
      context.missing(_divinateTypeMeta);
    }
    if (data.containsKey('divinate_uuid')) {
      context.handle(
          _divinateUuidMeta,
          divinateUuid.isAcceptableOrUnknown(
              data['divinate_uuid']!, _divinateUuidMeta));
    } else if (isInserting) {
      context.missing(_divinateUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Panel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Panel(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      panelType: $PanelsTable.$converterpanelType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}panel_type'])!),
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      divinateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}divinate_type'])!,
      divinateUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}divinate_uuid'])!,
    );
  }

  @override
  $PanelsTable createAlias(String alias) {
    return $PanelsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnumPanelType, int, int> $converterpanelType =
      const EnumIndexConverter<EnumPanelType>(EnumPanelType.values);
}

class Panel extends DataClass implements Insertable<Panel> {
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String uuid;
  final EnumPanelType panelType;
  final int skillId;
  final String divinateType;
  final String divinateUuid;
  const Panel(
      {required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.uuid,
      required this.panelType,
      required this.skillId,
      required this.divinateType,
      required this.divinateUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['uuid'] = Variable<String>(uuid);
    {
      map['panel_type'] =
          Variable<int>($PanelsTable.$converterpanelType.toSql(panelType));
    }
    map['skill_id'] = Variable<int>(skillId);
    map['divinate_type'] = Variable<String>(divinateType);
    map['divinate_uuid'] = Variable<String>(divinateUuid);
    return map;
  }

  PanelsCompanion toCompanion(bool nullToAbsent) {
    return PanelsCompanion(
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      uuid: Value(uuid),
      panelType: Value(panelType),
      skillId: Value(skillId),
      divinateType: Value(divinateType),
      divinateUuid: Value(divinateUuid),
    );
  }

  factory Panel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Panel(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      uuid: serializer.fromJson<String>(json['uuid']),
      panelType: $PanelsTable.$converterpanelType
          .fromJson(serializer.fromJson<int>(json['panelType'])),
      skillId: serializer.fromJson<int>(json['skillId']),
      divinateType: serializer.fromJson<String>(json['divinateType']),
      divinateUuid: serializer.fromJson<String>(json['divinateUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'uuid': serializer.toJson<String>(uuid),
      'panelType': serializer
          .toJson<int>($PanelsTable.$converterpanelType.toJson(panelType)),
      'skillId': serializer.toJson<int>(skillId),
      'divinateType': serializer.toJson<String>(divinateType),
      'divinateUuid': serializer.toJson<String>(divinateUuid),
    };
  }

  Panel copyWith(
          {DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? uuid,
          EnumPanelType? panelType,
          int? skillId,
          String? divinateType,
          String? divinateUuid}) =>
      Panel(
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        uuid: uuid ?? this.uuid,
        panelType: panelType ?? this.panelType,
        skillId: skillId ?? this.skillId,
        divinateType: divinateType ?? this.divinateType,
        divinateUuid: divinateUuid ?? this.divinateUuid,
      );
  Panel copyWithCompanion(PanelsCompanion data) {
    return Panel(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      panelType: data.panelType.present ? data.panelType.value : this.panelType,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      divinateType: data.divinateType.present
          ? data.divinateType.value
          : this.divinateType,
      divinateUuid: data.divinateUuid.present
          ? data.divinateUuid.value
          : this.divinateUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Panel(')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('uuid: $uuid, ')
          ..write('panelType: $panelType, ')
          ..write('skillId: $skillId, ')
          ..write('divinateType: $divinateType, ')
          ..write('divinateUuid: $divinateUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, lastUpdatedAt, deletedAt, uuid,
      panelType, skillId, divinateType, divinateUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Panel &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.uuid == this.uuid &&
          other.panelType == this.panelType &&
          other.skillId == this.skillId &&
          other.divinateType == this.divinateType &&
          other.divinateUuid == this.divinateUuid);
}

class PanelsCompanion extends UpdateCompanion<Panel> {
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> uuid;
  final Value<EnumPanelType> panelType;
  final Value<int> skillId;
  final Value<String> divinateType;
  final Value<String> divinateUuid;
  final Value<int> rowid;
  const PanelsCompanion({
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.uuid = const Value.absent(),
    this.panelType = const Value.absent(),
    this.skillId = const Value.absent(),
    this.divinateType = const Value.absent(),
    this.divinateUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PanelsCompanion.insert({
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String uuid,
    required EnumPanelType panelType,
    required int skillId,
    required String divinateType,
    required String divinateUuid,
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        uuid = Value(uuid),
        panelType = Value(panelType),
        skillId = Value(skillId),
        divinateType = Value(divinateType),
        divinateUuid = Value(divinateUuid);
  static Insertable<Panel> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? uuid,
    Expression<int>? panelType,
    Expression<int>? skillId,
    Expression<String>? divinateType,
    Expression<String>? divinateUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (uuid != null) 'uuid': uuid,
      if (panelType != null) 'panel_type': panelType,
      if (skillId != null) 'skill_id': skillId,
      if (divinateType != null) 'divinate_type': divinateType,
      if (divinateUuid != null) 'divinate_uuid': divinateUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PanelsCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? uuid,
      Value<EnumPanelType>? panelType,
      Value<int>? skillId,
      Value<String>? divinateType,
      Value<String>? divinateUuid,
      Value<int>? rowid}) {
    return PanelsCompanion(
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      uuid: uuid ?? this.uuid,
      panelType: panelType ?? this.panelType,
      skillId: skillId ?? this.skillId,
      divinateType: divinateType ?? this.divinateType,
      divinateUuid: divinateUuid ?? this.divinateUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (panelType.present) {
      map['panel_type'] = Variable<int>(
          $PanelsTable.$converterpanelType.toSql(panelType.value));
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (divinateType.present) {
      map['divinate_type'] = Variable<String>(divinateType.value);
    }
    if (divinateUuid.present) {
      map['divinate_uuid'] = Variable<String>(divinateUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PanelsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('uuid: $uuid, ')
          ..write('panelType: $panelType, ')
          ..write('skillId: $skillId, ')
          ..write('divinateType: $divinateType, ')
          ..write('divinateUuid: $divinateUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubDivinationTypesTable extends SubDivinationTypes
    with TableInfo<$SubDivinationTypesTable, SubDivinationTypeDataModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubDivinationTypesTable(this.attachedDatabase, [this._alias]);
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
        isCustomized,
        isAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_sub_divination_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<SubDivinationTypeDataModel> instance,
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
  SubDivinationTypeDataModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubDivinationTypeDataModel(
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
      isCustomized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customized'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
    );
  }

  @override
  $SubDivinationTypesTable createAlias(String alias) {
    return $SubDivinationTypesTable(attachedDatabase, alias);
  }
}

class SubDivinationTypesCompanion
    extends UpdateCompanion<SubDivinationTypeDataModel> {
  final Value<String> uuid;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> hiddenAt;
  final Value<String> name;
  final Value<bool> isCustomized;
  final Value<bool> isAvailable;
  final Value<int> rowid;
  const SubDivinationTypesCompanion({
    this.uuid = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustomized = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubDivinationTypesCompanion.insert({
    required String uuid,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    required String name,
    required bool isCustomized,
    required bool isAvailable,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        lastUpdatedAt = Value(lastUpdatedAt),
        name = Value(name),
        isCustomized = Value(isCustomized),
        isAvailable = Value(isAvailable);
  static Insertable<SubDivinationTypeDataModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? hiddenAt,
    Expression<String>? name,
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
      if (isCustomized != null) 'is_customized': isCustomized,
      if (isAvailable != null) 'is_available': isAvailable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubDivinationTypesCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? hiddenAt,
      Value<String>? name,
      Value<bool>? isCustomized,
      Value<bool>? isAvailable,
      Value<int>? rowid}) {
    return SubDivinationTypesCompanion(
      uuid: uuid ?? this.uuid,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      name: name ?? this.name,
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
    return (StringBuffer('SubDivinationTypesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('name: $name, ')
          ..write('isCustomized: $isCustomized, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeekerDivinationMappersTable extends SeekerDivinationMappers
    with TableInfo<$SeekerDivinationMappersTable, SeekerDivinationMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeekerDivinationMappersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divinations (uuid)'));
  static const VerificationMeta _seekerUuidMeta =
      const VerificationMeta('seekerUuid');
  @override
  late final GeneratedColumn<String> seekerUuid = GeneratedColumn<String>(
      'seeker_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_seekers (uuid)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, lastUpdatedAt, deletedAt, divinationUuid, seekerUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_seeker_divination_mapper';
  @override
  VerificationContext validateIntegrity(
      Insertable<SeekerDivinationMapper> instance,
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
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('seeker_uuid')) {
      context.handle(
          _seekerUuidMeta,
          seekerUuid.isAcceptableOrUnknown(
              data['seeker_uuid']!, _seekerUuidMeta));
    } else if (isInserting) {
      context.missing(_seekerUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeekerDivinationMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeekerDivinationMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      seekerUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seeker_uuid'])!,
    );
  }

  @override
  $SeekerDivinationMappersTable createAlias(String alias) {
    return $SeekerDivinationMappersTable(attachedDatabase, alias);
  }
}

class SeekerDivinationMapper extends DataClass
    implements Insertable<SeekerDivinationMapper> {
  final int id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String divinationUuid;
  final String seekerUuid;
  const SeekerDivinationMapper(
      {required this.id,
      required this.createdAt,
      required this.lastUpdatedAt,
      this.deletedAt,
      required this.divinationUuid,
      required this.seekerUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['divination_uuid'] = Variable<String>(divinationUuid);
    map['seeker_uuid'] = Variable<String>(seekerUuid);
    return map;
  }

  SeekerDivinationMappersCompanion toCompanion(bool nullToAbsent) {
    return SeekerDivinationMappersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      lastUpdatedAt: Value(lastUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      divinationUuid: Value(divinationUuid),
      seekerUuid: Value(seekerUuid),
    );
  }

  factory SeekerDivinationMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeekerDivinationMapper(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
      seekerUuid: serializer.fromJson<String>(json['seekerUuid']),
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
      'divinationUuid': serializer.toJson<String>(divinationUuid),
      'seekerUuid': serializer.toJson<String>(seekerUuid),
    };
  }

  SeekerDivinationMapper copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? lastUpdatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? divinationUuid,
          String? seekerUuid}) =>
      SeekerDivinationMapper(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        divinationUuid: divinationUuid ?? this.divinationUuid,
        seekerUuid: seekerUuid ?? this.seekerUuid,
      );
  SeekerDivinationMapper copyWithCompanion(
      SeekerDivinationMappersCompanion data) {
    return SeekerDivinationMapper(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
      seekerUuid:
          data.seekerUuid.present ? data.seekerUuid.value : this.seekerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeekerDivinationMapper(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('seekerUuid: $seekerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, lastUpdatedAt, deletedAt, divinationUuid, seekerUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeekerDivinationMapper &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.lastUpdatedAt == this.lastUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.divinationUuid == this.divinationUuid &&
          other.seekerUuid == this.seekerUuid);
}

class SeekerDivinationMappersCompanion
    extends UpdateCompanion<SeekerDivinationMapper> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationUuid;
  final Value<String> seekerUuid;
  const SeekerDivinationMappersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.seekerUuid = const Value.absent(),
  });
  SeekerDivinationMappersCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String divinationUuid,
    required String seekerUuid,
  })  : createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        divinationUuid = Value(divinationUuid),
        seekerUuid = Value(seekerUuid);
  static Insertable<SeekerDivinationMapper> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationUuid,
    Expression<String>? seekerUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (seekerUuid != null) 'seeker_uuid': seekerUuid,
    });
  }

  SeekerDivinationMappersCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationUuid,
      Value<String>? seekerUuid}) {
    return SeekerDivinationMappersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      seekerUuid: seekerUuid ?? this.seekerUuid,
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
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (seekerUuid.present) {
      map['seeker_uuid'] = Variable<String>(seekerUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeekerDivinationMappersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('seekerUuid: $seekerUuid')
          ..write(')'))
        .toString();
  }
}

class $DivinationPanelMappersTable extends DivinationPanelMappers
    with TableInfo<$DivinationPanelMappersTable, DivinationPanelMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationPanelMappersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divinations (uuid)'));
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_panels (uuid)'));
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
      [id, divinationUuid, panelUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_panel_mappers';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationPanelMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    } else if (isInserting) {
      context.missing(_panelUuidMeta);
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
  DivinationPanelMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationPanelMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DivinationPanelMappersTable createAlias(String alias) {
    return $DivinationPanelMappersTable(attachedDatabase, alias);
  }
}

class DivinationPanelMapper extends DataClass
    implements Insertable<DivinationPanelMapper> {
  final int id;
  final String divinationUuid;
  final String panelUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const DivinationPanelMapper(
      {required this.id,
      required this.divinationUuid,
      required this.panelUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['divination_uuid'] = Variable<String>(divinationUuid);
    map['panel_uuid'] = Variable<String>(panelUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DivinationPanelMappersCompanion toCompanion(bool nullToAbsent) {
    return DivinationPanelMappersCompanion(
      id: Value(id),
      divinationUuid: Value(divinationUuid),
      panelUuid: Value(panelUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DivinationPanelMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationPanelMapper(
      id: serializer.fromJson<int>(json['id']),
      divinationUuid: serializer.fromJson<String>(json['divinationUuid']),
      panelUuid: serializer.fromJson<String>(json['panelUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'divinationUuid': serializer.toJson<String>(divinationUuid),
      'panelUuid': serializer.toJson<String>(panelUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DivinationPanelMapper copyWith(
          {int? id,
          String? divinationUuid,
          String? panelUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      DivinationPanelMapper(
        id: id ?? this.id,
        divinationUuid: divinationUuid ?? this.divinationUuid,
        panelUuid: panelUuid ?? this.panelUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DivinationPanelMapper copyWithCompanion(
      DivinationPanelMappersCompanion data) {
    return DivinationPanelMapper(
      id: data.id.present ? data.id.value : this.id,
      divinationUuid: data.divinationUuid.present
          ? data.divinationUuid.value
          : this.divinationUuid,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationPanelMapper(')
          ..write('id: $id, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, divinationUuid, panelUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationPanelMapper &&
          other.id == this.id &&
          other.divinationUuid == this.divinationUuid &&
          other.panelUuid == this.panelUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class DivinationPanelMappersCompanion
    extends UpdateCompanion<DivinationPanelMapper> {
  final Value<int> id;
  final Value<String> divinationUuid;
  final Value<String> panelUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const DivinationPanelMappersCompanion({
    this.id = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DivinationPanelMappersCompanion.insert({
    this.id = const Value.absent(),
    required String divinationUuid,
    required String panelUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : divinationUuid = Value(divinationUuid),
        panelUuid = Value(panelUuid),
        createdAt = Value(createdAt);
  static Insertable<DivinationPanelMapper> custom({
    Expression<int>? id,
    Expression<String>? divinationUuid,
    Expression<String>? panelUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DivinationPanelMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? divinationUuid,
      Value<String>? panelUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return DivinationPanelMappersCompanion(
      id: id ?? this.id,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      panelUuid: panelUuid ?? this.panelUuid,
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
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
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
    return (StringBuffer('DivinationPanelMappersCompanion(')
          ..write('id: $id, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PanelSkillClassMappersTable extends PanelSkillClassMappers
    with TableInfo<$PanelSkillClassMappersTable, PanelSkillClassMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelSkillClassMappersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _panelUuidMeta =
      const VerificationMeta('panelUuid');
  @override
  late final GeneratedColumn<String> panelUuid = GeneratedColumn<String>(
      'panel_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES t_panels (uuid)'));
  static const VerificationMeta _skillClassUuidMeta =
      const VerificationMeta('skillClassUuid');
  @override
  late final GeneratedColumn<String> skillClassUuid = GeneratedColumn<String>(
      'skill_class_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_skill_classes (uuid)'));
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
      [id, panelUuid, skillClassUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_panel_skill_class_mapper';
  @override
  VerificationContext validateIntegrity(
      Insertable<PanelSkillClassMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('panel_uuid')) {
      context.handle(_panelUuidMeta,
          panelUuid.isAcceptableOrUnknown(data['panel_uuid']!, _panelUuidMeta));
    } else if (isInserting) {
      context.missing(_panelUuidMeta);
    }
    if (data.containsKey('skill_class_uuid')) {
      context.handle(
          _skillClassUuidMeta,
          skillClassUuid.isAcceptableOrUnknown(
              data['skill_class_uuid']!, _skillClassUuidMeta));
    } else if (isInserting) {
      context.missing(_skillClassUuidMeta);
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
  PanelSkillClassMapper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PanelSkillClassMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      panelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}panel_uuid'])!,
      skillClassUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}skill_class_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PanelSkillClassMappersTable createAlias(String alias) {
    return $PanelSkillClassMappersTable(attachedDatabase, alias);
  }
}

class PanelSkillClassMapper extends DataClass
    implements Insertable<PanelSkillClassMapper> {
  final int id;
  final String panelUuid;
  final String skillClassUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const PanelSkillClassMapper(
      {required this.id,
      required this.panelUuid,
      required this.skillClassUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['panel_uuid'] = Variable<String>(panelUuid);
    map['skill_class_uuid'] = Variable<String>(skillClassUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PanelSkillClassMappersCompanion toCompanion(bool nullToAbsent) {
    return PanelSkillClassMappersCompanion(
      id: Value(id),
      panelUuid: Value(panelUuid),
      skillClassUuid: Value(skillClassUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PanelSkillClassMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PanelSkillClassMapper(
      id: serializer.fromJson<int>(json['id']),
      panelUuid: serializer.fromJson<String>(json['panelUuid']),
      skillClassUuid: serializer.fromJson<String>(json['skillClassUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'panelUuid': serializer.toJson<String>(panelUuid),
      'skillClassUuid': serializer.toJson<String>(skillClassUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PanelSkillClassMapper copyWith(
          {int? id,
          String? panelUuid,
          String? skillClassUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      PanelSkillClassMapper(
        id: id ?? this.id,
        panelUuid: panelUuid ?? this.panelUuid,
        skillClassUuid: skillClassUuid ?? this.skillClassUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PanelSkillClassMapper copyWithCompanion(
      PanelSkillClassMappersCompanion data) {
    return PanelSkillClassMapper(
      id: data.id.present ? data.id.value : this.id,
      panelUuid: data.panelUuid.present ? data.panelUuid.value : this.panelUuid,
      skillClassUuid: data.skillClassUuid.present
          ? data.skillClassUuid.value
          : this.skillClassUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PanelSkillClassMapper(')
          ..write('id: $id, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('skillClassUuid: $skillClassUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, panelUuid, skillClassUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PanelSkillClassMapper &&
          other.id == this.id &&
          other.panelUuid == this.panelUuid &&
          other.skillClassUuid == this.skillClassUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class PanelSkillClassMappersCompanion
    extends UpdateCompanion<PanelSkillClassMapper> {
  final Value<int> id;
  final Value<String> panelUuid;
  final Value<String> skillClassUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const PanelSkillClassMappersCompanion({
    this.id = const Value.absent(),
    this.panelUuid = const Value.absent(),
    this.skillClassUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PanelSkillClassMappersCompanion.insert({
    this.id = const Value.absent(),
    required String panelUuid,
    required String skillClassUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : panelUuid = Value(panelUuid),
        skillClassUuid = Value(skillClassUuid),
        createdAt = Value(createdAt);
  static Insertable<PanelSkillClassMapper> custom({
    Expression<int>? id,
    Expression<String>? panelUuid,
    Expression<String>? skillClassUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (panelUuid != null) 'panel_uuid': panelUuid,
      if (skillClassUuid != null) 'skill_class_uuid': skillClassUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PanelSkillClassMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? panelUuid,
      Value<String>? skillClassUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return PanelSkillClassMappersCompanion(
      id: id ?? this.id,
      panelUuid: panelUuid ?? this.panelUuid,
      skillClassUuid: skillClassUuid ?? this.skillClassUuid,
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
    if (panelUuid.present) {
      map['panel_uuid'] = Variable<String>(panelUuid.value);
    }
    if (skillClassUuid.present) {
      map['skill_class_uuid'] = Variable<String>(skillClassUuid.value);
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
    return (StringBuffer('PanelSkillClassMappersCompanion(')
          ..write('id: $id, ')
          ..write('panelUuid: $panelUuid, ')
          ..write('skillClassUuid: $skillClassUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DivinationSubDivinationTypeMappersTable
    extends DivinationSubDivinationTypeMappers
    with
        TableInfo<$DivinationSubDivinationTypeMappersTable,
            DivinationSubDivinationTypeMapper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DivinationSubDivinationTypeMappersTable(this.attachedDatabase,
      [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeUuidMeta =
      const VerificationMeta('typeUuid');
  @override
  late final GeneratedColumn<String> typeUuid = GeneratedColumn<String>(
      'divination_type_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_divination_types (uuid)'));
  static const VerificationMeta _subTypeUuidMeta =
      const VerificationMeta('subTypeUuid');
  @override
  late final GeneratedColumn<String> subTypeUuid = GeneratedColumn<String>(
      'sub_divination_type_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_sub_divination_types (uuid)'));
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
      [id, typeUuid, subTypeUuid, createdAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_divination_sub_divination_type_mappers';
  @override
  VerificationContext validateIntegrity(
      Insertable<DivinationSubDivinationTypeMapper> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('divination_type_uuid')) {
      context.handle(
          _typeUuidMeta,
          typeUuid.isAcceptableOrUnknown(
              data['divination_type_uuid']!, _typeUuidMeta));
    } else if (isInserting) {
      context.missing(_typeUuidMeta);
    }
    if (data.containsKey('sub_divination_type_uuid')) {
      context.handle(
          _subTypeUuidMeta,
          subTypeUuid.isAcceptableOrUnknown(
              data['sub_divination_type_uuid']!, _subTypeUuidMeta));
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
  DivinationSubDivinationTypeMapper map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DivinationSubDivinationTypeMapper(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      typeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_type_uuid'])!,
      subTypeUuid: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}sub_divination_type_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DivinationSubDivinationTypeMappersTable createAlias(String alias) {
    return $DivinationSubDivinationTypeMappersTable(attachedDatabase, alias);
  }
}

class DivinationSubDivinationTypeMapper extends DataClass
    implements Insertable<DivinationSubDivinationTypeMapper> {
  final int id;
  final String typeUuid;
  final String subTypeUuid;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const DivinationSubDivinationTypeMapper(
      {required this.id,
      required this.typeUuid,
      required this.subTypeUuid,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['divination_type_uuid'] = Variable<String>(typeUuid);
    map['sub_divination_type_uuid'] = Variable<String>(subTypeUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DivinationSubDivinationTypeMappersCompanion toCompanion(bool nullToAbsent) {
    return DivinationSubDivinationTypeMappersCompanion(
      id: Value(id),
      typeUuid: Value(typeUuid),
      subTypeUuid: Value(subTypeUuid),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DivinationSubDivinationTypeMapper.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DivinationSubDivinationTypeMapper(
      id: serializer.fromJson<int>(json['id']),
      typeUuid: serializer.fromJson<String>(json['typeUuid']),
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
      'typeUuid': serializer.toJson<String>(typeUuid),
      'subTypeUuid': serializer.toJson<String>(subTypeUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DivinationSubDivinationTypeMapper copyWith(
          {int? id,
          String? typeUuid,
          String? subTypeUuid,
          DateTime? createdAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      DivinationSubDivinationTypeMapper(
        id: id ?? this.id,
        typeUuid: typeUuid ?? this.typeUuid,
        subTypeUuid: subTypeUuid ?? this.subTypeUuid,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DivinationSubDivinationTypeMapper copyWithCompanion(
      DivinationSubDivinationTypeMappersCompanion data) {
    return DivinationSubDivinationTypeMapper(
      id: data.id.present ? data.id.value : this.id,
      typeUuid: data.typeUuid.present ? data.typeUuid.value : this.typeUuid,
      subTypeUuid:
          data.subTypeUuid.present ? data.subTypeUuid.value : this.subTypeUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DivinationSubDivinationTypeMapper(')
          ..write('id: $id, ')
          ..write('typeUuid: $typeUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, typeUuid, subTypeUuid, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DivinationSubDivinationTypeMapper &&
          other.id == this.id &&
          other.typeUuid == this.typeUuid &&
          other.subTypeUuid == this.subTypeUuid &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class DivinationSubDivinationTypeMappersCompanion
    extends UpdateCompanion<DivinationSubDivinationTypeMapper> {
  final Value<int> id;
  final Value<String> typeUuid;
  final Value<String> subTypeUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const DivinationSubDivinationTypeMappersCompanion({
    this.id = const Value.absent(),
    this.typeUuid = const Value.absent(),
    this.subTypeUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DivinationSubDivinationTypeMappersCompanion.insert({
    this.id = const Value.absent(),
    required String typeUuid,
    required String subTypeUuid,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
  })  : typeUuid = Value(typeUuid),
        subTypeUuid = Value(subTypeUuid),
        createdAt = Value(createdAt);
  static Insertable<DivinationSubDivinationTypeMapper> custom({
    Expression<int>? id,
    Expression<String>? typeUuid,
    Expression<String>? subTypeUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeUuid != null) 'divination_type_uuid': typeUuid,
      if (subTypeUuid != null) 'sub_divination_type_uuid': subTypeUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DivinationSubDivinationTypeMappersCompanion copyWith(
      {Value<int>? id,
      Value<String>? typeUuid,
      Value<String>? subTypeUuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? deletedAt}) {
    return DivinationSubDivinationTypeMappersCompanion(
      id: id ?? this.id,
      typeUuid: typeUuid ?? this.typeUuid,
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
    if (typeUuid.present) {
      map['divination_type_uuid'] = Variable<String>(typeUuid.value);
    }
    if (subTypeUuid.present) {
      map['sub_divination_type_uuid'] = Variable<String>(subTypeUuid.value);
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
    return (StringBuffer('DivinationSubDivinationTypeMappersCompanion(')
          ..write('id: $id, ')
          ..write('typeUuid: $typeUuid, ')
          ..write('subTypeUuid: $subTypeUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TimingDivinationsTable extends TimingDivinations
    with TableInfo<$TimingDivinationsTable, TimingDivinationModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimingDivinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _divinationUuidMeta =
      const VerificationMeta('divinationUuid');
  @override
  late final GeneratedColumn<String> divinationUuid = GeneratedColumn<String>(
      'divination_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTimeType, int> timingType =
      GeneratedColumn<int>('timing_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTimeType>(
              $TimingDivinationsTable.$convertertimingType);
  static const VerificationMeta _datetimeMeta =
      const VerificationMeta('datetime');
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
      'datetime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> yearGanZhi =
      GeneratedColumn<int>('year_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$converteryearGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> monthGanZhi =
      GeneratedColumn<int>('month_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$convertermonthGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> dayGanZhi =
      GeneratedColumn<int>('day_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$converterdayGanZhi);
  @override
  late final GeneratedColumnWithTypeConverter<JiaZi, int> timeGanZhi =
      GeneratedColumn<int>('time_gan_zhi', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<JiaZi>($TimingDivinationsTable.$convertertimeGanZhi);
  static const VerificationMeta _lunarMonthMeta =
      const VerificationMeta('lunarMonth');
  @override
  late final GeneratedColumn<int> lunarMonth = GeneratedColumn<int>(
      'lunar_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isLeapMonthMeta =
      const VerificationMeta('isLeapMonth');
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
      'is_leap_month', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_leap_month" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lunarDayMeta =
      const VerificationMeta('lunarDay');
  @override
  late final GeneratedColumn<int> lunarDay = GeneratedColumn<int>(
      'lunar_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timingInfoUuidMeta =
      const VerificationMeta('timingInfoUuid');
  @override
  late final GeneratedColumn<String> timingInfoUuid = GeneratedColumn<String>(
      'timing_info_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Location?, String> location =
      GeneratedColumn<String>('location_json', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Location?>($TimingDivinationsTable.$converterlocation);
  @override
  late final GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?,
      String> timingInfoListJson = GeneratedColumn<String>(
          'info_list_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false)
      .withConverter<List<DivinationDatetimeModel>?>(
          $TimingDivinationsTable.$convertertimingInfoListJsonn);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationUuid,
        timingType,
        datetime,
        isManual,
        yearGanZhi,
        monthGanZhi,
        dayGanZhi,
        timeGanZhi,
        lunarMonth,
        isLeapMonth,
        lunarDay,
        timingInfoUuid,
        location,
        timingInfoListJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_timing_divinations';
  @override
  VerificationContext validateIntegrity(
      Insertable<TimingDivinationModel> instance,
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
    if (data.containsKey('divination_uuid')) {
      context.handle(
          _divinationUuidMeta,
          divinationUuid.isAcceptableOrUnknown(
              data['divination_uuid']!, _divinationUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationUuidMeta);
    }
    if (data.containsKey('datetime')) {
      context.handle(_datetimeMeta,
          datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta));
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
          _lunarMonthMeta,
          lunarMonth.isAcceptableOrUnknown(
              data['lunar_month']!, _lunarMonthMeta));
    } else if (isInserting) {
      context.missing(_lunarMonthMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
          _isLeapMonthMeta,
          isLeapMonth.isAcceptableOrUnknown(
              data['is_leap_month']!, _isLeapMonthMeta));
    }
    if (data.containsKey('lunar_day')) {
      context.handle(_lunarDayMeta,
          lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta));
    } else if (isInserting) {
      context.missing(_lunarDayMeta);
    }
    if (data.containsKey('timing_info_uuid')) {
      context.handle(
          _timingInfoUuidMeta,
          timingInfoUuid.isAcceptableOrUnknown(
              data['timing_info_uuid']!, _timingInfoUuidMeta));
    } else if (isInserting) {
      context.missing(_timingInfoUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TimingDivinationModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimingDivinationModel(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}divination_uuid'])!,
      timingType: $TimingDivinationsTable.$convertertimingType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}timing_type'])!),
      datetime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}datetime'])!,
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
      yearGanZhi: $TimingDivinationsTable.$converteryearGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}year_gan_zhi'])!),
      monthGanZhi: $TimingDivinationsTable.$convertermonthGanZhi.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}month_gan_zhi'])!),
      dayGanZhi: $TimingDivinationsTable.$converterdayGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}day_gan_zhi'])!),
      timeGanZhi: $TimingDivinationsTable.$convertertimeGanZhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}time_gan_zhi'])!),
      lunarMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_month'])!,
      isLeapMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_leap_month'])!,
      lunarDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lunar_day'])!,
      timingInfoUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}timing_info_uuid'])!,
      location: $TimingDivinationsTable.$converterlocation.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}location_json'])),
      timingInfoListJson: $TimingDivinationsTable.$convertertimingInfoListJsonn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}info_list_json'])),
    );
  }

  @override
  $TimingDivinationsTable createAlias(String alias) {
    return $TimingDivinationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DateTimeType, int, int> $convertertimingType =
      const EnumIndexConverter<DateTimeType>(DateTimeType.values);
  static JsonTypeConverter2<JiaZi, int, int> $converteryearGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertermonthGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $converterdayGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static JsonTypeConverter2<JiaZi, int, int> $convertertimeGanZhi =
      const EnumIndexConverter<JiaZi>(JiaZi.values);
  static TypeConverter<Location?, String?> $converterlocation =
      const NullableLocationConverter();
  static TypeConverter<List<DivinationDatetimeModel>, String>
      $convertertimingInfoListJson = const DivinationDatetimeModelConverter();
  static TypeConverter<List<DivinationDatetimeModel>?, String?>
      $convertertimingInfoListJsonn =
      NullAwareTypeConverter.wrap($convertertimingInfoListJson);
}

class TimingDivinationsCompanion
    extends UpdateCompanion<TimingDivinationModel> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationUuid;
  final Value<DateTimeType> timingType;
  final Value<DateTime> datetime;
  final Value<bool> isManual;
  final Value<JiaZi> yearGanZhi;
  final Value<JiaZi> monthGanZhi;
  final Value<JiaZi> dayGanZhi;
  final Value<JiaZi> timeGanZhi;
  final Value<int> lunarMonth;
  final Value<bool> isLeapMonth;
  final Value<int> lunarDay;
  final Value<String> timingInfoUuid;
  final Value<Location?> location;
  final Value<List<DivinationDatetimeModel>?> timingInfoListJson;
  final Value<int> rowid;
  const TimingDivinationsCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationUuid = const Value.absent(),
    this.timingType = const Value.absent(),
    this.datetime = const Value.absent(),
    this.isManual = const Value.absent(),
    this.yearGanZhi = const Value.absent(),
    this.monthGanZhi = const Value.absent(),
    this.dayGanZhi = const Value.absent(),
    this.timeGanZhi = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.timingInfoUuid = const Value.absent(),
    this.location = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimingDivinationsCompanion.insert({
    required String uuid,
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String divinationUuid,
    required DateTimeType timingType,
    required DateTime datetime,
    this.isManual = const Value.absent(),
    required JiaZi yearGanZhi,
    required JiaZi monthGanZhi,
    required JiaZi dayGanZhi,
    required JiaZi timeGanZhi,
    required int lunarMonth,
    this.isLeapMonth = const Value.absent(),
    required int lunarDay,
    required String timingInfoUuid,
    this.location = const Value.absent(),
    this.timingInfoListJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        divinationUuid = Value(divinationUuid),
        timingType = Value(timingType),
        datetime = Value(datetime),
        yearGanZhi = Value(yearGanZhi),
        monthGanZhi = Value(monthGanZhi),
        dayGanZhi = Value(dayGanZhi),
        timeGanZhi = Value(timeGanZhi),
        lunarMonth = Value(lunarMonth),
        lunarDay = Value(lunarDay),
        timingInfoUuid = Value(timingInfoUuid);
  static Insertable<TimingDivinationModel> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationUuid,
    Expression<int>? timingType,
    Expression<DateTime>? datetime,
    Expression<bool>? isManual,
    Expression<int>? yearGanZhi,
    Expression<int>? monthGanZhi,
    Expression<int>? dayGanZhi,
    Expression<int>? timeGanZhi,
    Expression<int>? lunarMonth,
    Expression<bool>? isLeapMonth,
    Expression<int>? lunarDay,
    Expression<String>? timingInfoUuid,
    Expression<String>? location,
    Expression<String>? timingInfoListJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationUuid != null) 'divination_uuid': divinationUuid,
      if (timingType != null) 'timing_type': timingType,
      if (datetime != null) 'datetime': datetime,
      if (isManual != null) 'is_manual': isManual,
      if (yearGanZhi != null) 'year_gan_zhi': yearGanZhi,
      if (monthGanZhi != null) 'month_gan_zhi': monthGanZhi,
      if (dayGanZhi != null) 'day_gan_zhi': dayGanZhi,
      if (timeGanZhi != null) 'time_gan_zhi': timeGanZhi,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (timingInfoUuid != null) 'timing_info_uuid': timingInfoUuid,
      if (location != null) 'location_json': location,
      if (timingInfoListJson != null) 'info_list_json': timingInfoListJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimingDivinationsCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationUuid,
      Value<DateTimeType>? timingType,
      Value<DateTime>? datetime,
      Value<bool>? isManual,
      Value<JiaZi>? yearGanZhi,
      Value<JiaZi>? monthGanZhi,
      Value<JiaZi>? dayGanZhi,
      Value<JiaZi>? timeGanZhi,
      Value<int>? lunarMonth,
      Value<bool>? isLeapMonth,
      Value<int>? lunarDay,
      Value<String>? timingInfoUuid,
      Value<Location?>? location,
      Value<List<DivinationDatetimeModel>?>? timingInfoListJson,
      Value<int>? rowid}) {
    return TimingDivinationsCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationUuid: divinationUuid ?? this.divinationUuid,
      timingType: timingType ?? this.timingType,
      datetime: datetime ?? this.datetime,
      isManual: isManual ?? this.isManual,
      yearGanZhi: yearGanZhi ?? this.yearGanZhi,
      monthGanZhi: monthGanZhi ?? this.monthGanZhi,
      dayGanZhi: dayGanZhi ?? this.dayGanZhi,
      timeGanZhi: timeGanZhi ?? this.timeGanZhi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      timingInfoUuid: timingInfoUuid ?? this.timingInfoUuid,
      location: location ?? this.location,
      timingInfoListJson: timingInfoListJson ?? this.timingInfoListJson,
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
    if (divinationUuid.present) {
      map['divination_uuid'] = Variable<String>(divinationUuid.value);
    }
    if (timingType.present) {
      map['timing_type'] = Variable<int>(
          $TimingDivinationsTable.$convertertimingType.toSql(timingType.value));
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (yearGanZhi.present) {
      map['year_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$converteryearGanZhi.toSql(yearGanZhi.value));
    }
    if (monthGanZhi.present) {
      map['month_gan_zhi'] = Variable<int>($TimingDivinationsTable
          .$convertermonthGanZhi
          .toSql(monthGanZhi.value));
    }
    if (dayGanZhi.present) {
      map['day_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$converterdayGanZhi.toSql(dayGanZhi.value));
    }
    if (timeGanZhi.present) {
      map['time_gan_zhi'] = Variable<int>(
          $TimingDivinationsTable.$convertertimeGanZhi.toSql(timeGanZhi.value));
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<int>(lunarMonth.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<int>(lunarDay.value);
    }
    if (timingInfoUuid.present) {
      map['timing_info_uuid'] = Variable<String>(timingInfoUuid.value);
    }
    if (location.present) {
      map['location_json'] = Variable<String>(
          $TimingDivinationsTable.$converterlocation.toSql(location.value));
    }
    if (timingInfoListJson.present) {
      map['info_list_json'] = Variable<String>($TimingDivinationsTable
          .$convertertimingInfoListJsonn
          .toSql(timingInfoListJson.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimingDivinationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationUuid: $divinationUuid, ')
          ..write('timingType: $timingType, ')
          ..write('datetime: $datetime, ')
          ..write('isManual: $isManual, ')
          ..write('yearGanZhi: $yearGanZhi, ')
          ..write('monthGanZhi: $monthGanZhi, ')
          ..write('dayGanZhi: $dayGanZhi, ')
          ..write('timeGanZhi: $timeGanZhi, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('timingInfoUuid: $timingInfoUuid, ')
          ..write('location: $location, ')
          ..write('timingInfoListJson: $timingInfoListJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SkillsTable skills = $SkillsTable(this);
  late final $SkillClassesTable skillClasses = $SkillClassesTable(this);
  late final $LayoutTemplatesTable layoutTemplates =
      $LayoutTemplatesTable(this);
  late final $CardTemplateMetasTable cardTemplateMetas =
      $CardTemplateMetasTable(this);
  late final $CardTemplateSettingsTable cardTemplateSettings =
      $CardTemplateSettingsTable(this);
  late final $CardTemplateSkillUsagesTable cardTemplateSkillUsages =
      $CardTemplateSkillUsagesTable(this);
  late final $MarketTemplateInstallsTable marketTemplateInstalls =
      $MarketTemplateInstallsTable(this);
  late final $DivinationTypesTable divinationTypes =
      $DivinationTypesTable(this);
  late final $SeekersTable seekers = $SeekersTable(this);
  late final $DivinationsTable divinations = $DivinationsTable(this);
  late final $CombinedDivinationsTable combinedDivinations =
      $CombinedDivinationsTable(this);
  late final $PanelsTable panels = $PanelsTable(this);
  late final $SubDivinationTypesTable subDivinationTypes =
      $SubDivinationTypesTable(this);
  late final $SeekerDivinationMappersTable seekerDivinationMappers =
      $SeekerDivinationMappersTable(this);
  late final $DivinationPanelMappersTable divinationPanelMappers =
      $DivinationPanelMappersTable(this);
  late final $PanelSkillClassMappersTable panelSkillClassMappers =
      $PanelSkillClassMappersTable(this);
  late final $DivinationSubDivinationTypeMappersTable
      divinationSubDivinationTypeMappers =
      $DivinationSubDivinationTypeMappersTable(this);
  late final $TimingDivinationsTable timingDivinations =
      $TimingDivinationsTable(this);
  late final CombinedDivinationsDao combinedDivinationsDao =
      CombinedDivinationsDao(this as AppDatabase);
  late final DivinationsDao divinationsDao =
      DivinationsDao(this as AppDatabase);
  late final TimingDivinationsDao timingDivinationsDao =
      TimingDivinationsDao(this as AppDatabase);
  late final PanelsDao panelsDao = PanelsDao(this as AppDatabase);
  late final SkillsDao skillsDao = SkillsDao(this as AppDatabase);
  late final SkillClassesDao skillClassesDao =
      SkillClassesDao(this as AppDatabase);
  late final LayoutTemplatesDao layoutTemplatesDao =
      LayoutTemplatesDao(this as AppDatabase);
  late final CardTemplateMetaDao cardTemplateMetaDao =
      CardTemplateMetaDao(this as AppDatabase);
  late final CardTemplateSettingDao cardTemplateSettingDao =
      CardTemplateSettingDao(this as AppDatabase);
  late final CardTemplateSkillUsageDao cardTemplateSkillUsageDao =
      CardTemplateSkillUsageDao(this as AppDatabase);
  late final MarketTemplateInstallsDao marketTemplateInstallsDao =
      MarketTemplateInstallsDao(this as AppDatabase);
  late final DivinationTypesDao divinationTypesDao =
      DivinationTypesDao(this as AppDatabase);
  late final SeekersDao seekersDao = SeekersDao(this as AppDatabase);
  late final SeekerDivinationMappersDao seekerDivinationMappersDao =
      SeekerDivinationMappersDao(this as AppDatabase);
  late final DivinationPanelMappersDao divinationPanelMappersDao =
      DivinationPanelMappersDao(this as AppDatabase);
  late final PanelSkillClassMappersDao panelSkillClassMappersDao =
      PanelSkillClassMappersDao(this as AppDatabase);
  late final DivinationSubDivinationTypeMappersDao
      divinationSubDivinationTypeMappersDao =
      DivinationSubDivinationTypeMappersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        skills,
        skillClasses,
        layoutTemplates,
        cardTemplateMetas,
        cardTemplateSettings,
        cardTemplateSkillUsages,
        marketTemplateInstalls,
        divinationTypes,
        seekers,
        divinations,
        combinedDivinations,
        panels,
        subDivinationTypes,
        seekerDivinationMappers,
        divinationPanelMappers,
        panelSkillClassMappers,
        divinationSubDivinationTypeMappers,
        timingDivinations
      ];
}

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

final class $$SkillsTableReferences
    extends BaseReferences<_$AppDatabase, $SkillsTable, Skill> {
  $$SkillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SkillClassesTable, List<SkillClass>>
      _skillClassesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.skillClasses,
              aliasName:
                  $_aliasNameGenerator(db.skills.id, db.skillClasses.skillId));

  $$SkillClassesTableProcessedTableManager get skillClassesRefs {
    final manager = $$SkillClassesTableTableManager($_db, $_db.skillClasses)
        .filter((f) => f.skillId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_skillClassesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PanelsTable, List<Panel>> _panelsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.panels,
          aliasName: $_aliasNameGenerator(db.skills.id, db.panels.skillId));

  $$PanelsTableProcessedTableManager get panelsRefs {
    final manager = $$PanelsTableTableManager($_db, $_db.panels)
        .filter((f) => f.skillId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_panelsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  Expression<bool> skillClassesRefs(
      Expression<bool> Function($$SkillClassesTableFilterComposer f) f) {
    final $$SkillClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.skillClasses,
        getReferencedColumn: (t) => t.skillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillClassesTableFilterComposer(
              $db: $db,
              $table: $db.skillClasses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> panelsRefs(
      Expression<bool> Function($$PanelsTableFilterComposer f) f) {
    final $$PanelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.skillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableFilterComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  Expression<T> skillClassesRefs<T extends Object>(
      Expression<T> Function($$SkillClassesTableAnnotationComposer a) f) {
    final $$SkillClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.skillClasses,
        getReferencedColumn: (t) => t.skillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.skillClasses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> panelsRefs<T extends Object>(
      Expression<T> Function($$PanelsTableAnnotationComposer a) f) {
    final $$PanelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.skillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableAnnotationComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
    (Skill, $$SkillsTableReferences),
    Skill,
    PrefetchHooks Function({bool skillClassesRefs, bool panelsRefs})> {
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
              .map((e) =>
                  (e.readTable(table), $$SkillsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {skillClassesRefs = false, panelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (skillClassesRefs) db.skillClasses,
                if (panelsRefs) db.panels
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (skillClassesRefs)
                    await $_getPrefetchedData<Skill, $SkillsTable, SkillClass>(
                        currentTable: table,
                        referencedTable:
                            $$SkillsTableReferences._skillClassesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SkillsTableReferences(db, table, p0)
                                .skillClassesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.skillId == item.id),
                        typedResults: items),
                  if (panelsRefs)
                    await $_getPrefetchedData<Skill, $SkillsTable, Panel>(
                        currentTable: table,
                        referencedTable:
                            $$SkillsTableReferences._panelsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SkillsTableReferences(db, table, p0).panelsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.skillId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
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
    (Skill, $$SkillsTableReferences),
    Skill,
    PrefetchHooks Function({bool skillClassesRefs, bool panelsRefs})>;
typedef $$SkillClassesTableCreateCompanionBuilder = SkillClassesCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required int skillId,
  required String name,
  required String specification,
  required String feature,
  required bool isCustomized,
  Value<int> rowid,
});
typedef $$SkillClassesTableUpdateCompanionBuilder = SkillClassesCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<int> skillId,
  Value<String> name,
  Value<String> specification,
  Value<String> feature,
  Value<bool> isCustomized,
  Value<int> rowid,
});

final class $$SkillClassesTableReferences
    extends BaseReferences<_$AppDatabase, $SkillClassesTable, SkillClass> {
  $$SkillClassesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SkillsTable _skillIdTable(_$AppDatabase db) => db.skills
      .createAlias($_aliasNameGenerator(db.skillClasses.skillId, db.skills.id));

  $$SkillsTableProcessedTableManager get skillId {
    final $_column = $_itemColumn<int>('skill_id')!;

    final manager = $$SkillsTableTableManager($_db, $_db.skills)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skillIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PanelSkillClassMappersTable,
      List<PanelSkillClassMapper>> _panelSkillClassMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.panelSkillClassMappers,
          aliasName: $_aliasNameGenerator(
              db.skillClasses.uuid, db.panelSkillClassMappers.skillClassUuid));

  $$PanelSkillClassMappersTableProcessedTableManager
      get panelSkillClassMappersRefs {
    final manager = $$PanelSkillClassMappersTableTableManager(
            $_db, $_db.panelSkillClassMappers)
        .filter((f) =>
            f.skillClassUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_panelSkillClassMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SkillClassesTableFilterComposer
    extends Composer<_$AppDatabase, $SkillClassesTable> {
  $$SkillClassesTableFilterComposer({
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

  ColumnFilters<String> get specification => $composableBuilder(
      column: $table.specification, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  $$SkillsTableFilterComposer get skillId {
    final $$SkillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableFilterComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> panelSkillClassMappersRefs(
      Expression<bool> Function($$PanelSkillClassMappersTableFilterComposer f)
          f) {
    final $$PanelSkillClassMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.panelSkillClassMappers,
            getReferencedColumn: (t) => t.skillClassUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PanelSkillClassMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.panelSkillClassMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SkillClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $SkillClassesTable> {
  $$SkillClassesTableOrderingComposer({
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

  ColumnOrderings<String> get specification => $composableBuilder(
      column: $table.specification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  $$SkillsTableOrderingComposer get skillId {
    final $$SkillsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableOrderingComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SkillClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkillClassesTable> {
  $$SkillClassesTableAnnotationComposer({
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

  GeneratedColumn<String> get specification => $composableBuilder(
      column: $table.specification, builder: (column) => column);

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  $$SkillsTableAnnotationComposer get skillId {
    final $$SkillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableAnnotationComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> panelSkillClassMappersRefs<T extends Object>(
      Expression<T> Function($$PanelSkillClassMappersTableAnnotationComposer a)
          f) {
    final $$PanelSkillClassMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.panelSkillClassMappers,
            getReferencedColumn: (t) => t.skillClassUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PanelSkillClassMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.panelSkillClassMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SkillClassesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillClassesTable,
    SkillClass,
    $$SkillClassesTableFilterComposer,
    $$SkillClassesTableOrderingComposer,
    $$SkillClassesTableAnnotationComposer,
    $$SkillClassesTableCreateCompanionBuilder,
    $$SkillClassesTableUpdateCompanionBuilder,
    (SkillClass, $$SkillClassesTableReferences),
    SkillClass,
    PrefetchHooks Function({bool skillId, bool panelSkillClassMappersRefs})> {
  $$SkillClassesTableTableManager(_$AppDatabase db, $SkillClassesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> specification = const Value.absent(),
            Value<String> feature = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SkillClassesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            skillId: skillId,
            name: name,
            specification: specification,
            feature: feature,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required int skillId,
            required String name,
            required String specification,
            required String feature,
            required bool isCustomized,
            Value<int> rowid = const Value.absent(),
          }) =>
              SkillClassesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            skillId: skillId,
            name: name,
            specification: specification,
            feature: feature,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SkillClassesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {skillId = false, panelSkillClassMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (panelSkillClassMappersRefs) db.panelSkillClassMappers
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
                if (skillId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.skillId,
                    referencedTable:
                        $$SkillClassesTableReferences._skillIdTable(db),
                    referencedColumn:
                        $$SkillClassesTableReferences._skillIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (panelSkillClassMappersRefs)
                    await $_getPrefetchedData<SkillClass, $SkillClassesTable,
                            PanelSkillClassMapper>(
                        currentTable: table,
                        referencedTable: $$SkillClassesTableReferences
                            ._panelSkillClassMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SkillClassesTableReferences(db, table, p0)
                                .panelSkillClassMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.skillClassUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SkillClassesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkillClassesTable,
    SkillClass,
    $$SkillClassesTableFilterComposer,
    $$SkillClassesTableOrderingComposer,
    $$SkillClassesTableAnnotationComposer,
    $$SkillClassesTableCreateCompanionBuilder,
    $$SkillClassesTableUpdateCompanionBuilder,
    (SkillClass, $$SkillClassesTableReferences),
    SkillClass,
    PrefetchHooks Function({bool skillId, bool panelSkillClassMappersRefs})>;
typedef $$LayoutTemplatesTableCreateCompanionBuilder = LayoutTemplatesCompanion
    Function({
  required String uuid,
  required String collectionId,
  required String name,
  Value<String?> description,
  required String templateJson,
  required int version,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$LayoutTemplatesTableUpdateCompanionBuilder = LayoutTemplatesCompanion
    Function({
  Value<String> uuid,
  Value<String> collectionId,
  Value<String> name,
  Value<String?> description,
  Value<String> templateJson,
  Value<int> version,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$LayoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateJson => $composableBuilder(
      column: $table.templateJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LayoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateJson => $composableBuilder(
      column: $table.templateJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LayoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayoutTemplatesTable> {
  $$LayoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get templateJson => $composableBuilder(
      column: $table.templateJson, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LayoutTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LayoutTemplatesTable,
    LayoutTemplateRow,
    $$LayoutTemplatesTableFilterComposer,
    $$LayoutTemplatesTableOrderingComposer,
    $$LayoutTemplatesTableAnnotationComposer,
    $$LayoutTemplatesTableCreateCompanionBuilder,
    $$LayoutTemplatesTableUpdateCompanionBuilder,
    (
      LayoutTemplateRow,
      BaseReferences<_$AppDatabase, $LayoutTemplatesTable, LayoutTemplateRow>
    ),
    LayoutTemplateRow,
    PrefetchHooks Function()> {
  $$LayoutTemplatesTableTableManager(
      _$AppDatabase db, $LayoutTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> collectionId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> templateJson = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayoutTemplatesCompanion(
            uuid: uuid,
            collectionId: collectionId,
            name: name,
            description: description,
            templateJson: templateJson,
            version: version,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String collectionId,
            required String name,
            Value<String?> description = const Value.absent(),
            required String templateJson,
            required int version,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayoutTemplatesCompanion.insert(
            uuid: uuid,
            collectionId: collectionId,
            name: name,
            description: description,
            templateJson: templateJson,
            version: version,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LayoutTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LayoutTemplatesTable,
    LayoutTemplateRow,
    $$LayoutTemplatesTableFilterComposer,
    $$LayoutTemplatesTableOrderingComposer,
    $$LayoutTemplatesTableAnnotationComposer,
    $$LayoutTemplatesTableCreateCompanionBuilder,
    $$LayoutTemplatesTableUpdateCompanionBuilder,
    (
      LayoutTemplateRow,
      BaseReferences<_$AppDatabase, $LayoutTemplatesTable, LayoutTemplateRow>
    ),
    LayoutTemplateRow,
    PrefetchHooks Function()>;
typedef $$CardTemplateMetasTableCreateCompanionBuilder
    = CardTemplateMetasCompanion Function({
  required String templateUuid,
  required DateTime createdAt,
  required DateTime modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String?> authorUuid,
  Value<String?> createFromCardUuid,
  Value<bool?> isCustomized,
  Value<int> rowid,
});
typedef $$CardTemplateMetasTableUpdateCompanionBuilder
    = CardTemplateMetasCompanion Function({
  Value<String> templateUuid,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String?> authorUuid,
  Value<String?> createFromCardUuid,
  Value<bool?> isCustomized,
  Value<int> rowid,
});

class $$CardTemplateMetasTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateMetasTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateMetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateMetasTable> {
  $$CardTemplateMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get authorUuid => $composableBuilder(
      column: $table.authorUuid, builder: (column) => column);

  GeneratedColumn<String> get createFromCardUuid => $composableBuilder(
      column: $table.createFromCardUuid, builder: (column) => column);

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);
}

class $$CardTemplateMetasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateMetasTable,
    CardTemplateMeta,
    $$CardTemplateMetasTableFilterComposer,
    $$CardTemplateMetasTableOrderingComposer,
    $$CardTemplateMetasTableAnnotationComposer,
    $$CardTemplateMetasTableCreateCompanionBuilder,
    $$CardTemplateMetasTableUpdateCompanionBuilder,
    (
      CardTemplateMeta,
      BaseReferences<_$AppDatabase, $CardTemplateMetasTable, CardTemplateMeta>
    ),
    CardTemplateMeta,
    PrefetchHooks Function()> {
  $$CardTemplateMetasTableTableManager(
      _$AppDatabase db, $CardTemplateMetasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateMetasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> templateUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> authorUuid = const Value.absent(),
            Value<String?> createFromCardUuid = const Value.absent(),
            Value<bool?> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateMetasCompanion(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            authorUuid: authorUuid,
            createFromCardUuid: createFromCardUuid,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String templateUuid,
            required DateTime createdAt,
            required DateTime modifiedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> authorUuid = const Value.absent(),
            Value<String?> createFromCardUuid = const Value.absent(),
            Value<bool?> isCustomized = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateMetasCompanion.insert(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            authorUuid: authorUuid,
            createFromCardUuid: createFromCardUuid,
            isCustomized: isCustomized,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateMetasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardTemplateMetasTable,
    CardTemplateMeta,
    $$CardTemplateMetasTableFilterComposer,
    $$CardTemplateMetasTableOrderingComposer,
    $$CardTemplateMetasTableAnnotationComposer,
    $$CardTemplateMetasTableCreateCompanionBuilder,
    $$CardTemplateMetasTableUpdateCompanionBuilder,
    (
      CardTemplateMeta,
      BaseReferences<_$AppDatabase, $CardTemplateMetasTable, CardTemplateMeta>
    ),
    CardTemplateMeta,
    PrefetchHooks Function()>;
typedef $$CardTemplateSettingsTableCreateCompanionBuilder
    = CardTemplateSettingsCompanion Function({
  required String templateUuid,
  required DateTime createdAt,
  required DateTime modifiedAt,
  Value<DateTime?> deletedAt,
  required String settingJson,
  Value<int> rowid,
});
typedef $$CardTemplateSettingsTableUpdateCompanionBuilder
    = CardTemplateSettingsCompanion Function({
  Value<String> templateUuid,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
  Value<String> settingJson,
  Value<int> rowid,
});

class $$CardTemplateSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateSettingsTable> {
  $$CardTemplateSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get settingJson => $composableBuilder(
      column: $table.settingJson, builder: (column) => column);
}

class $$CardTemplateSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateSettingsTable,
    CardTemplateSettingRecord,
    $$CardTemplateSettingsTableFilterComposer,
    $$CardTemplateSettingsTableOrderingComposer,
    $$CardTemplateSettingsTableAnnotationComposer,
    $$CardTemplateSettingsTableCreateCompanionBuilder,
    $$CardTemplateSettingsTableUpdateCompanionBuilder,
    (
      CardTemplateSettingRecord,
      BaseReferences<_$AppDatabase, $CardTemplateSettingsTable,
          CardTemplateSettingRecord>
    ),
    CardTemplateSettingRecord,
    PrefetchHooks Function()> {
  $$CardTemplateSettingsTableTableManager(
      _$AppDatabase db, $CardTemplateSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateSettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> templateUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> settingJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateSettingsCompanion(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            settingJson: settingJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String templateUuid,
            required DateTime createdAt,
            required DateTime modifiedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String settingJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardTemplateSettingsCompanion.insert(
            templateUuid: templateUuid,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
            settingJson: settingJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateSettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CardTemplateSettingsTable,
        CardTemplateSettingRecord,
        $$CardTemplateSettingsTableFilterComposer,
        $$CardTemplateSettingsTableOrderingComposer,
        $$CardTemplateSettingsTableAnnotationComposer,
        $$CardTemplateSettingsTableCreateCompanionBuilder,
        $$CardTemplateSettingsTableUpdateCompanionBuilder,
        (
          CardTemplateSettingRecord,
          BaseReferences<_$AppDatabase, $CardTemplateSettingsTable,
              CardTemplateSettingRecord>
        ),
        CardTemplateSettingRecord,
        PrefetchHooks Function()>;
typedef $$CardTemplateSkillUsagesTableCreateCompanionBuilder
    = CardTemplateSkillUsagesCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String queryUuid,
  required String templateUuid,
  required int skillId,
  required String usedAt,
});
typedef $$CardTemplateSkillUsagesTableUpdateCompanionBuilder
    = CardTemplateSkillUsagesCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> queryUuid,
  Value<String> templateUuid,
  Value<int> skillId,
  Value<String> usedAt,
});

class $$CardTemplateSkillUsagesTableFilterComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableFilterComposer({
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

  ColumnFilters<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnFilters(column));
}

class $$CardTemplateSkillUsagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableOrderingComposer({
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

  ColumnOrderings<String> get queryUuid => $composableBuilder(
      column: $table.queryUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnOrderings(column));
}

class $$CardTemplateSkillUsagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTemplateSkillUsagesTable> {
  $$CardTemplateSkillUsagesTableAnnotationComposer({
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

  GeneratedColumn<String> get queryUuid =>
      $composableBuilder(column: $table.queryUuid, builder: (column) => column);

  GeneratedColumn<String> get templateUuid => $composableBuilder(
      column: $table.templateUuid, builder: (column) => column);

  GeneratedColumn<int> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<String> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$CardTemplateSkillUsagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardTemplateSkillUsagesTable,
    CardTemplateSkillUsage,
    $$CardTemplateSkillUsagesTableFilterComposer,
    $$CardTemplateSkillUsagesTableOrderingComposer,
    $$CardTemplateSkillUsagesTableAnnotationComposer,
    $$CardTemplateSkillUsagesTableCreateCompanionBuilder,
    $$CardTemplateSkillUsagesTableUpdateCompanionBuilder,
    (
      CardTemplateSkillUsage,
      BaseReferences<_$AppDatabase, $CardTemplateSkillUsagesTable,
          CardTemplateSkillUsage>
    ),
    CardTemplateSkillUsage,
    PrefetchHooks Function()> {
  $$CardTemplateSkillUsagesTableTableManager(
      _$AppDatabase db, $CardTemplateSkillUsagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTemplateSkillUsagesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTemplateSkillUsagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTemplateSkillUsagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> queryUuid = const Value.absent(),
            Value<String> templateUuid = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> usedAt = const Value.absent(),
          }) =>
              CardTemplateSkillUsagesCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryUuid: queryUuid,
            templateUuid: templateUuid,
            skillId: skillId,
            usedAt: usedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String queryUuid,
            required String templateUuid,
            required int skillId,
            required String usedAt,
          }) =>
              CardTemplateSkillUsagesCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            queryUuid: queryUuid,
            templateUuid: templateUuid,
            skillId: skillId,
            usedAt: usedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardTemplateSkillUsagesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CardTemplateSkillUsagesTable,
        CardTemplateSkillUsage,
        $$CardTemplateSkillUsagesTableFilterComposer,
        $$CardTemplateSkillUsagesTableOrderingComposer,
        $$CardTemplateSkillUsagesTableAnnotationComposer,
        $$CardTemplateSkillUsagesTableCreateCompanionBuilder,
        $$CardTemplateSkillUsagesTableUpdateCompanionBuilder,
        (
          CardTemplateSkillUsage,
          BaseReferences<_$AppDatabase, $CardTemplateSkillUsagesTable,
              CardTemplateSkillUsage>
        ),
        CardTemplateSkillUsage,
        PrefetchHooks Function()>;
typedef $$MarketTemplateInstallsTableCreateCompanionBuilder
    = MarketTemplateInstallsCompanion Function({
  required String localTemplateUuid,
  required String marketTemplateId,
  required String marketVersionId,
  required DateTime installedAt,
  Value<DateTime?> pinnedAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$MarketTemplateInstallsTableUpdateCompanionBuilder
    = MarketTemplateInstallsCompanion Function({
  Value<String> localTemplateUuid,
  Value<String> marketTemplateId,
  Value<String> marketVersionId,
  Value<DateTime> installedAt,
  Value<DateTime?> pinnedAt,
  Value<DateTime?> lastCheckedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$MarketTemplateInstallsTableFilterComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pinnedAt => $composableBuilder(
      column: $table.pinnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$MarketTemplateInstallsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pinnedAt => $composableBuilder(
      column: $table.pinnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$MarketTemplateInstallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketTemplateInstallsTable> {
  $$MarketTemplateInstallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localTemplateUuid => $composableBuilder(
      column: $table.localTemplateUuid, builder: (column) => column);

  GeneratedColumn<String> get marketTemplateId => $composableBuilder(
      column: $table.marketTemplateId, builder: (column) => column);

  GeneratedColumn<String> get marketVersionId => $composableBuilder(
      column: $table.marketVersionId, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
      column: $table.installedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$MarketTemplateInstallsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MarketTemplateInstallsTable,
    MarketTemplateInstall,
    $$MarketTemplateInstallsTableFilterComposer,
    $$MarketTemplateInstallsTableOrderingComposer,
    $$MarketTemplateInstallsTableAnnotationComposer,
    $$MarketTemplateInstallsTableCreateCompanionBuilder,
    $$MarketTemplateInstallsTableUpdateCompanionBuilder,
    (
      MarketTemplateInstall,
      BaseReferences<_$AppDatabase, $MarketTemplateInstallsTable,
          MarketTemplateInstall>
    ),
    MarketTemplateInstall,
    PrefetchHooks Function()> {
  $$MarketTemplateInstallsTableTableManager(
      _$AppDatabase db, $MarketTemplateInstallsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketTemplateInstallsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketTemplateInstallsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketTemplateInstallsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localTemplateUuid = const Value.absent(),
            Value<String> marketTemplateId = const Value.absent(),
            Value<String> marketVersionId = const Value.absent(),
            Value<DateTime> installedAt = const Value.absent(),
            Value<DateTime?> pinnedAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MarketTemplateInstallsCompanion(
            localTemplateUuid: localTemplateUuid,
            marketTemplateId: marketTemplateId,
            marketVersionId: marketVersionId,
            installedAt: installedAt,
            pinnedAt: pinnedAt,
            lastCheckedAt: lastCheckedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localTemplateUuid,
            required String marketTemplateId,
            required String marketVersionId,
            required DateTime installedAt,
            Value<DateTime?> pinnedAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MarketTemplateInstallsCompanion.insert(
            localTemplateUuid: localTemplateUuid,
            marketTemplateId: marketTemplateId,
            marketVersionId: marketVersionId,
            installedAt: installedAt,
            pinnedAt: pinnedAt,
            lastCheckedAt: lastCheckedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MarketTemplateInstallsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MarketTemplateInstallsTable,
        MarketTemplateInstall,
        $$MarketTemplateInstallsTableFilterComposer,
        $$MarketTemplateInstallsTableOrderingComposer,
        $$MarketTemplateInstallsTableAnnotationComposer,
        $$MarketTemplateInstallsTableCreateCompanionBuilder,
        $$MarketTemplateInstallsTableUpdateCompanionBuilder,
        (
          MarketTemplateInstall,
          BaseReferences<_$AppDatabase, $MarketTemplateInstallsTable,
              MarketTemplateInstall>
        ),
        MarketTemplateInstall,
        PrefetchHooks Function()>;
typedef $$DivinationTypesTableCreateCompanionBuilder = DivinationTypesCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String name,
  required String description,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$DivinationTypesTableUpdateCompanionBuilder = DivinationTypesCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> name,
  Value<String> description,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

final class $$DivinationTypesTableReferences extends BaseReferences<
    _$AppDatabase, $DivinationTypesTable, DivinationTypeDataModel> {
  $$DivinationTypesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationsTable,
      List<DivinationRequestInfoDataModel>> _divinationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.divinations,
          aliasName: $_aliasNameGenerator(
              db.divinationTypes.uuid, db.divinations.divinationTypeUuid));

  $$DivinationsTableProcessedTableManager get divinationsRefs {
    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) =>
            f.divinationTypeUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_divinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DivinationSubDivinationTypeMappersTable,
          List<DivinationSubDivinationTypeMapper>>
      _divinationSubDivinationTypeMappersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.divinationSubDivinationTypeMappers,
              aliasName: $_aliasNameGenerator(db.divinationTypes.uuid,
                  db.divinationSubDivinationTypeMappers.typeUuid));

  $$DivinationSubDivinationTypeMappersTableProcessedTableManager
      get divinationSubDivinationTypeMappersRefs {
    final manager = $$DivinationSubDivinationTypeMappersTableTableManager(
            $_db, $_db.divinationSubDivinationTypeMappers)
        .filter(
            (f) => f.typeUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult
        .readTableOrNull(_divinationSubDivinationTypeMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DivinationTypesTableFilterComposer
    extends Composer<_$AppDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableFilterComposer({
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

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  Expression<bool> divinationsRefs(
      Expression<bool> Function($$DivinationsTableFilterComposer f) f) {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.divinationTypeUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> divinationSubDivinationTypeMappersRefs(
      Expression<bool> Function(
              $$DivinationSubDivinationTypeMappersTableFilterComposer f)
          f) {
    final $$DivinationSubDivinationTypeMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.typeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableOrderingComposer({
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

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$DivinationTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DivinationTypesTable> {
  $$DivinationTypesTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  Expression<T> divinationsRefs<T extends Object>(
      Expression<T> Function($$DivinationsTableAnnotationComposer a) f) {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.divinationTypeUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> divinationSubDivinationTypeMappersRefs<T extends Object>(
      Expression<T> Function(
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer a)
          f) {
    final $$DivinationSubDivinationTypeMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.typeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DivinationTypesTable,
    DivinationTypeDataModel,
    $$DivinationTypesTableFilterComposer,
    $$DivinationTypesTableOrderingComposer,
    $$DivinationTypesTableAnnotationComposer,
    $$DivinationTypesTableCreateCompanionBuilder,
    $$DivinationTypesTableUpdateCompanionBuilder,
    (DivinationTypeDataModel, $$DivinationTypesTableReferences),
    DivinationTypeDataModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool divinationSubDivinationTypeMappersRefs})> {
  $$DivinationTypesTableTableManager(
      _$AppDatabase db, $DivinationTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTypesCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
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
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationTypesCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            name: name,
            description: description,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationsRefs = false,
              divinationSubDivinationTypeMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationsRefs) db.divinations,
                if (divinationSubDivinationTypeMappersRefs)
                  db.divinationSubDivinationTypeMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationsRefs)
                    await $_getPrefetchedData<
                            DivinationTypeDataModel,
                            $DivinationTypesTable,
                            DivinationRequestInfoDataModel>(
                        currentTable: table,
                        referencedTable: $$DivinationTypesTableReferences
                            ._divinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationTypesTableReferences(db, table, p0)
                                .divinationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.divinationTypeUuid == item.uuid),
                        typedResults: items),
                  if (divinationSubDivinationTypeMappersRefs)
                    await $_getPrefetchedData<
                            DivinationTypeDataModel,
                            $DivinationTypesTable,
                            DivinationSubDivinationTypeMapper>(
                        currentTable: table,
                        referencedTable: $$DivinationTypesTableReferences
                            ._divinationSubDivinationTypeMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationTypesTableReferences(db, table, p0)
                                .divinationSubDivinationTypeMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.typeUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DivinationTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DivinationTypesTable,
    DivinationTypeDataModel,
    $$DivinationTypesTableFilterComposer,
    $$DivinationTypesTableOrderingComposer,
    $$DivinationTypesTableAnnotationComposer,
    $$DivinationTypesTableCreateCompanionBuilder,
    $$DivinationTypesTableUpdateCompanionBuilder,
    (DivinationTypeDataModel, $$DivinationTypesTableReferences),
    DivinationTypeDataModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool divinationSubDivinationTypeMappersRefs})>;
typedef $$SeekersTableCreateCompanionBuilder = SeekersCompanion Function({
  required String uuid,
  Value<String?> username,
  Value<String?> nickname,
  required Gender gender,
  required DateTime createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required DateTimeType timingType,
  required DateTime datetime,
  required JiaZi yearGanZhi,
  required JiaZi monthGanZhi,
  required JiaZi dayGanZhi,
  required JiaZi timeGanZhi,
  required int lunarMonth,
  Value<bool> isLeapMonth,
  required int lunarDay,
  required String divinationUuid,
  Value<String?> timingInfoUuid,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<Location?> location,
  Value<int> rowid,
});
typedef $$SeekersTableUpdateCompanionBuilder = SeekersCompanion Function({
  Value<String> uuid,
  Value<String?> username,
  Value<String?> nickname,
  Value<Gender> gender,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTimeType> timingType,
  Value<DateTime> datetime,
  Value<JiaZi> yearGanZhi,
  Value<JiaZi> monthGanZhi,
  Value<JiaZi> dayGanZhi,
  Value<JiaZi> timeGanZhi,
  Value<int> lunarMonth,
  Value<bool> isLeapMonth,
  Value<int> lunarDay,
  Value<String> divinationUuid,
  Value<String?> timingInfoUuid,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<Location?> location,
  Value<int> rowid,
});

final class $$SeekersTableReferences
    extends BaseReferences<_$AppDatabase, $SeekersTable, SeekerModel> {
  $$SeekersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationsTable,
      List<DivinationRequestInfoDataModel>> _divinationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.divinations,
          aliasName: $_aliasNameGenerator(
              db.seekers.uuid, db.divinations.ownerSeekerUuid));

  $$DivinationsTableProcessedTableManager get divinationsRefs {
    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) =>
            f.ownerSeekerUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_divinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SeekerDivinationMappersTable,
      List<SeekerDivinationMapper>> _seekerDivinationMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.seekerDivinationMappers,
          aliasName: $_aliasNameGenerator(
              db.seekers.uuid, db.seekerDivinationMappers.seekerUuid));

  $$SeekerDivinationMappersTableProcessedTableManager
      get seekerDivinationMappersRefs {
    final manager = $$SeekerDivinationMappersTableTableManager(
            $_db, $_db.seekerDivinationMappers)
        .filter(
            (f) => f.seekerUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_seekerDivinationMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnWithTypeConverterFilters<Gender, Gender, String> get gender =>
      $composableBuilder(
          column: $table.gender,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTimeType, DateTimeType, int>
      get timingType => $composableBuilder(
          column: $table.timingType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get dayGanZhi =>
      $composableBuilder(
          column: $table.dayGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<DivinationDatetimeModel>?,
          List<DivinationDatetimeModel>, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Location?, Location, String> get location =>
      $composableBuilder(
          column: $table.location,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> divinationsRefs(
      Expression<bool> Function($$DivinationsTableFilterComposer f) f) {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.ownerSeekerUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> seekerDivinationMappersRefs(
      Expression<bool> Function($$SeekerDivinationMappersTableFilterComposer f)
          f) {
    final $$SeekerDivinationMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.seekerUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
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

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timingType => $composableBuilder(
      column: $table.timingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthGanZhi => $composableBuilder(
      column: $table.monthGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayGanZhi => $composableBuilder(
      column: $table.dayGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeGanZhi => $composableBuilder(
      column: $table.timeGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoListJson => $composableBuilder(
      column: $table.timingInfoListJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumnWithTypeConverter<Gender, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTimeType, int> get timingType =>
      $composableBuilder(
          column: $table.timingType, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get dayGanZhi =>
      $composableBuilder(column: $table.dayGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi, builder: (column) => column);

  GeneratedColumn<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => column);

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => column);

  GeneratedColumn<int> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumn<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Location?, String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  Expression<T> divinationsRefs<T extends Object>(
      Expression<T> Function($$DivinationsTableAnnotationComposer a) f) {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.ownerSeekerUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> seekerDivinationMappersRefs<T extends Object>(
      Expression<T> Function($$SeekerDivinationMappersTableAnnotationComposer a)
          f) {
    final $$SeekerDivinationMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.seekerUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SeekersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeekersTable,
    SeekerModel,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (SeekerModel, $$SeekersTableReferences),
    SeekerModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool seekerDivinationMappersRefs})> {
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
            Value<String?> username = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            Value<Gender> gender = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTimeType> timingType = const Value.absent(),
            Value<DateTime> datetime = const Value.absent(),
            Value<JiaZi> yearGanZhi = const Value.absent(),
            Value<JiaZi> monthGanZhi = const Value.absent(),
            Value<JiaZi> dayGanZhi = const Value.absent(),
            Value<JiaZi> timeGanZhi = const Value.absent(),
            Value<int> lunarMonth = const Value.absent(),
            Value<bool> isLeapMonth = const Value.absent(),
            Value<int> lunarDay = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String?> timingInfoUuid = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion(
            uuid: uuid,
            username: username,
            nickname: nickname,
            gender: gender,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            timingType: timingType,
            datetime: datetime,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            divinationUuid: divinationUuid,
            timingInfoUuid: timingInfoUuid,
            timingInfoListJson: timingInfoListJson,
            location: location,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> username = const Value.absent(),
            Value<String?> nickname = const Value.absent(),
            required Gender gender,
            required DateTime createdAt,
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTimeType timingType,
            required DateTime datetime,
            required JiaZi yearGanZhi,
            required JiaZi monthGanZhi,
            required JiaZi dayGanZhi,
            required JiaZi timeGanZhi,
            required int lunarMonth,
            Value<bool> isLeapMonth = const Value.absent(),
            required int lunarDay,
            required String divinationUuid,
            Value<String?> timingInfoUuid = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SeekersCompanion.insert(
            uuid: uuid,
            username: username,
            nickname: nickname,
            gender: gender,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            timingType: timingType,
            datetime: datetime,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            divinationUuid: divinationUuid,
            timingInfoUuid: timingInfoUuid,
            timingInfoListJson: timingInfoListJson,
            location: location,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SeekersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {divinationsRefs = false, seekerDivinationMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationsRefs) db.divinations,
                if (seekerDivinationMappersRefs) db.seekerDivinationMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationsRefs)
                    await $_getPrefetchedData<SeekerModel, $SeekersTable,
                            DivinationRequestInfoDataModel>(
                        currentTable: table,
                        referencedTable:
                            $$SeekersTableReferences._divinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeekersTableReferences(db, table, p0)
                                .divinationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ownerSeekerUuid == item.uuid),
                        typedResults: items),
                  if (seekerDivinationMappersRefs)
                    await $_getPrefetchedData<SeekerModel, $SeekersTable,
                            SeekerDivinationMapper>(
                        currentTable: table,
                        referencedTable: $$SeekersTableReferences
                            ._seekerDivinationMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeekersTableReferences(db, table, p0)
                                .seekerDivinationMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.seekerUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SeekersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SeekersTable,
    SeekerModel,
    $$SeekersTableFilterComposer,
    $$SeekersTableOrderingComposer,
    $$SeekersTableAnnotationComposer,
    $$SeekersTableCreateCompanionBuilder,
    $$SeekersTableUpdateCompanionBuilder,
    (SeekerModel, $$SeekersTableReferences),
    SeekerModel,
    PrefetchHooks Function(
        {bool divinationsRefs, bool seekerDivinationMappersRefs})>;
typedef $$DivinationsTableCreateCompanionBuilder = DivinationsCompanion
    Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationTypeUuid,
  Value<String?> fateYear,
  Value<String?> question,
  Value<String?> detail,
  Value<String?> ownerSeekerUuid,
  Value<Gender?> gender,
  Value<String?> seekerName,
  Value<String?> tinyPredict,
  Value<String?> directlyPredict,
  Value<int> rowid,
});
typedef $$DivinationsTableUpdateCompanionBuilder = DivinationsCompanion
    Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationTypeUuid,
  Value<String?> fateYear,
  Value<String?> question,
  Value<String?> detail,
  Value<String?> ownerSeekerUuid,
  Value<Gender?> gender,
  Value<String?> seekerName,
  Value<String?> tinyPredict,
  Value<String?> directlyPredict,
  Value<int> rowid,
});

final class $$DivinationsTableReferences extends BaseReferences<_$AppDatabase,
    $DivinationsTable, DivinationRequestInfoDataModel> {
  $$DivinationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DivinationTypesTable _divinationTypeUuidTable(_$AppDatabase db) =>
      db.divinationTypes.createAlias($_aliasNameGenerator(
          db.divinations.divinationTypeUuid, db.divinationTypes.uuid));

  $$DivinationTypesTableProcessedTableManager get divinationTypeUuid {
    final $_column = $_itemColumn<String>('divination_type_uuid')!;

    final manager =
        $$DivinationTypesTableTableManager($_db, $_db.divinationTypes)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationTypeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SeekersTable _ownerSeekerUuidTable(_$AppDatabase db) =>
      db.seekers.createAlias($_aliasNameGenerator(
          db.divinations.ownerSeekerUuid, db.seekers.uuid));

  $$SeekersTableProcessedTableManager? get ownerSeekerUuid {
    final $_column = $_itemColumn<String>('seeker_uuid');
    if ($_column == null) return null;
    final manager = $$SeekersTableTableManager($_db, $_db.seekers)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerSeekerUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CombinedDivinationsTable,
      List<CombinedDivination>> _combinedDivinationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.combinedDivinations,
          aliasName: $_aliasNameGenerator(
              db.divinations.uuid, db.combinedDivinations.divinationUuid));

  $$CombinedDivinationsTableProcessedTableManager get combinedDivinationsRefs {
    final manager =
        $$CombinedDivinationsTableTableManager($_db, $_db.combinedDivinations)
            .filter((f) =>
                f.divinationUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_combinedDivinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SeekerDivinationMappersTable,
      List<SeekerDivinationMapper>> _seekerDivinationMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.seekerDivinationMappers,
          aliasName: $_aliasNameGenerator(
              db.divinations.uuid, db.seekerDivinationMappers.divinationUuid));

  $$SeekerDivinationMappersTableProcessedTableManager
      get seekerDivinationMappersRefs {
    final manager = $$SeekerDivinationMappersTableTableManager(
            $_db, $_db.seekerDivinationMappers)
        .filter((f) =>
            f.divinationUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_seekerDivinationMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DivinationPanelMappersTable,
      List<DivinationPanelMapper>> _divinationPanelMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.divinationPanelMappers,
          aliasName: $_aliasNameGenerator(
              db.divinations.uuid, db.divinationPanelMappers.divinationUuid));

  $$DivinationPanelMappersTableProcessedTableManager
      get divinationPanelMappersRefs {
    final manager = $$DivinationPanelMappersTableTableManager(
            $_db, $_db.divinationPanelMappers)
        .filter((f) =>
            f.divinationUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_divinationPanelMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DivinationsTableFilterComposer
    extends Composer<_$AppDatabase, $DivinationsTable> {
  $$DivinationsTableFilterComposer({
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

  ColumnFilters<String> get fateYear => $composableBuilder(
      column: $table.fateYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Gender?, Gender, String> get gender =>
      $composableBuilder(
          column: $table.gender,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnFilters(column));

  $$DivinationTypesTableFilterComposer get divinationTypeUuid {
    final $$DivinationTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationTypeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableFilterComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableFilterComposer get ownerSeekerUuid {
    final $$SeekersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableFilterComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> combinedDivinationsRefs(
      Expression<bool> Function($$CombinedDivinationsTableFilterComposer f) f) {
    final $$CombinedDivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.combinedDivinations,
        getReferencedColumn: (t) => t.divinationUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CombinedDivinationsTableFilterComposer(
              $db: $db,
              $table: $db.combinedDivinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> seekerDivinationMappersRefs(
      Expression<bool> Function($$SeekerDivinationMappersTableFilterComposer f)
          f) {
    final $$SeekerDivinationMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> divinationPanelMappersRefs(
      Expression<bool> Function($$DivinationPanelMappersTableFilterComposer f)
          f) {
    final $$DivinationPanelMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationPanelMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationPanelMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationPanelMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DivinationsTable> {
  $$DivinationsTableOrderingComposer({
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

  ColumnOrderings<String> get fateYear => $composableBuilder(
      column: $table.fateYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict,
      builder: (column) => ColumnOrderings(column));

  $$DivinationTypesTableOrderingComposer get divinationTypeUuid {
    final $$DivinationTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationTypeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableOrderingComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableOrderingComposer get ownerSeekerUuid {
    final $$SeekersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableOrderingComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DivinationsTable> {
  $$DivinationsTableAnnotationComposer({
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

  GeneratedColumn<String> get fateYear =>
      $composableBuilder(column: $table.fateYear, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Gender?, String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get seekerName => $composableBuilder(
      column: $table.seekerName, builder: (column) => column);

  GeneratedColumn<String> get tinyPredict => $composableBuilder(
      column: $table.tinyPredict, builder: (column) => column);

  GeneratedColumn<String> get directlyPredict => $composableBuilder(
      column: $table.directlyPredict, builder: (column) => column);

  $$DivinationTypesTableAnnotationComposer get divinationTypeUuid {
    final $$DivinationTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationTypeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableAnnotationComposer get ownerSeekerUuid {
    final $$SeekersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerSeekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableAnnotationComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> combinedDivinationsRefs<T extends Object>(
      Expression<T> Function($$CombinedDivinationsTableAnnotationComposer a)
          f) {
    final $$CombinedDivinationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.combinedDivinations,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CombinedDivinationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.combinedDivinations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> seekerDivinationMappersRefs<T extends Object>(
      Expression<T> Function($$SeekerDivinationMappersTableAnnotationComposer a)
          f) {
    final $$SeekerDivinationMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.seekerDivinationMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.seekerDivinationMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> divinationPanelMappersRefs<T extends Object>(
      Expression<T> Function($$DivinationPanelMappersTableAnnotationComposer a)
          f) {
    final $$DivinationPanelMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationPanelMappers,
            getReferencedColumn: (t) => t.divinationUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationPanelMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationPanelMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DivinationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DivinationsTable,
    DivinationRequestInfoDataModel,
    $$DivinationsTableFilterComposer,
    $$DivinationsTableOrderingComposer,
    $$DivinationsTableAnnotationComposer,
    $$DivinationsTableCreateCompanionBuilder,
    $$DivinationsTableUpdateCompanionBuilder,
    (DivinationRequestInfoDataModel, $$DivinationsTableReferences),
    DivinationRequestInfoDataModel,
    PrefetchHooks Function(
        {bool divinationTypeUuid,
        bool ownerSeekerUuid,
        bool combinedDivinationsRefs,
        bool seekerDivinationMappersRefs,
        bool divinationPanelMappersRefs})> {
  $$DivinationsTableTableManager(_$AppDatabase db, $DivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationTypeUuid = const Value.absent(),
            Value<String?> fateYear = const Value.absent(),
            Value<String?> question = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String?> ownerSeekerUuid = const Value.absent(),
            Value<Gender?> gender = const Value.absent(),
            Value<String?> seekerName = const Value.absent(),
            Value<String?> tinyPredict = const Value.absent(),
            Value<String?> directlyPredict = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationTypeUuid: divinationTypeUuid,
            fateYear: fateYear,
            question: question,
            detail: detail,
            ownerSeekerUuid: ownerSeekerUuid,
            gender: gender,
            seekerName: seekerName,
            tinyPredict: tinyPredict,
            directlyPredict: directlyPredict,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationTypeUuid,
            Value<String?> fateYear = const Value.absent(),
            Value<String?> question = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<String?> ownerSeekerUuid = const Value.absent(),
            Value<Gender?> gender = const Value.absent(),
            Value<String?> seekerName = const Value.absent(),
            Value<String?> tinyPredict = const Value.absent(),
            Value<String?> directlyPredict = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationTypeUuid: divinationTypeUuid,
            fateYear: fateYear,
            question: question,
            detail: detail,
            ownerSeekerUuid: ownerSeekerUuid,
            gender: gender,
            seekerName: seekerName,
            tinyPredict: tinyPredict,
            directlyPredict: directlyPredict,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationTypeUuid = false,
              ownerSeekerUuid = false,
              combinedDivinationsRefs = false,
              seekerDivinationMappersRefs = false,
              divinationPanelMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (combinedDivinationsRefs) db.combinedDivinations,
                if (seekerDivinationMappersRefs) db.seekerDivinationMappers,
                if (divinationPanelMappersRefs) db.divinationPanelMappers
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
                if (divinationTypeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationTypeUuid,
                    referencedTable: $$DivinationsTableReferences
                        ._divinationTypeUuidTable(db),
                    referencedColumn: $$DivinationsTableReferences
                        ._divinationTypeUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (ownerSeekerUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerSeekerUuid,
                    referencedTable:
                        $$DivinationsTableReferences._ownerSeekerUuidTable(db),
                    referencedColumn: $$DivinationsTableReferences
                        ._ownerSeekerUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (combinedDivinationsRefs)
                    await $_getPrefetchedData<DivinationRequestInfoDataModel,
                            $DivinationsTable, CombinedDivination>(
                        currentTable: table,
                        referencedTable: $$DivinationsTableReferences
                            ._combinedDivinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationsTableReferences(db, table, p0)
                                .combinedDivinationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.divinationUuid == item.uuid),
                        typedResults: items),
                  if (seekerDivinationMappersRefs)
                    await $_getPrefetchedData<DivinationRequestInfoDataModel,
                            $DivinationsTable, SeekerDivinationMapper>(
                        currentTable: table,
                        referencedTable: $$DivinationsTableReferences
                            ._seekerDivinationMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationsTableReferences(db, table, p0)
                                .seekerDivinationMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.divinationUuid == item.uuid),
                        typedResults: items),
                  if (divinationPanelMappersRefs)
                    await $_getPrefetchedData<DivinationRequestInfoDataModel,
                            $DivinationsTable, DivinationPanelMapper>(
                        currentTable: table,
                        referencedTable: $$DivinationsTableReferences
                            ._divinationPanelMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DivinationsTableReferences(db, table, p0)
                                .divinationPanelMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.divinationUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DivinationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DivinationsTable,
    DivinationRequestInfoDataModel,
    $$DivinationsTableFilterComposer,
    $$DivinationsTableOrderingComposer,
    $$DivinationsTableAnnotationComposer,
    $$DivinationsTableCreateCompanionBuilder,
    $$DivinationsTableUpdateCompanionBuilder,
    (DivinationRequestInfoDataModel, $$DivinationsTableReferences),
    DivinationRequestInfoDataModel,
    PrefetchHooks Function(
        {bool divinationTypeUuid,
        bool ownerSeekerUuid,
        bool combinedDivinationsRefs,
        bool seekerDivinationMappersRefs,
        bool divinationPanelMappersRefs})>;
typedef $$CombinedDivinationsTableCreateCompanionBuilder
    = CombinedDivinationsCompanion Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required int order,
  required String divinationUuid,
  Value<int> rowid,
});
typedef $$CombinedDivinationsTableUpdateCompanionBuilder
    = CombinedDivinationsCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<int> order,
  Value<String> divinationUuid,
  Value<int> rowid,
});

final class $$CombinedDivinationsTableReferences extends BaseReferences<
    _$AppDatabase, $CombinedDivinationsTable, CombinedDivination> {
  $$CombinedDivinationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationsTable _divinationUuidTable(_$AppDatabase db) =>
      db.divinations.createAlias($_aliasNameGenerator(
          db.combinedDivinations.divinationUuid, db.divinations.uuid));

  $$DivinationsTableProcessedTableManager get divinationUuid {
    final $_column = $_itemColumn<String>('divination_uuid')!;

    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CombinedDivinationsTableFilterComposer
    extends Composer<_$AppDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableFilterComposer({
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

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  $$DivinationsTableFilterComposer get divinationUuid {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableOrderingComposer({
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

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  $$DivinationsTableOrderingComposer get divinationUuid {
    final $$DivinationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableOrderingComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CombinedDivinationsTable> {
  $$CombinedDivinationsTableAnnotationComposer({
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

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$DivinationsTableAnnotationComposer get divinationUuid {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CombinedDivinationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CombinedDivinationsTable,
    CombinedDivination,
    $$CombinedDivinationsTableFilterComposer,
    $$CombinedDivinationsTableOrderingComposer,
    $$CombinedDivinationsTableAnnotationComposer,
    $$CombinedDivinationsTableCreateCompanionBuilder,
    $$CombinedDivinationsTableUpdateCompanionBuilder,
    (CombinedDivination, $$CombinedDivinationsTableReferences),
    CombinedDivination,
    PrefetchHooks Function({bool divinationUuid})> {
  $$CombinedDivinationsTableTableManager(
      _$AppDatabase db, $CombinedDivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombinedDivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombinedDivinationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombinedDivinationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedDivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            order: order,
            divinationUuid: divinationUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required int order,
            required String divinationUuid,
            Value<int> rowid = const Value.absent(),
          }) =>
              CombinedDivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            order: order,
            divinationUuid: divinationUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CombinedDivinationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({divinationUuid = false}) {
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
                if (divinationUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationUuid,
                    referencedTable: $$CombinedDivinationsTableReferences
                        ._divinationUuidTable(db),
                    referencedColumn: $$CombinedDivinationsTableReferences
                        ._divinationUuidTable(db)
                        .uuid,
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

typedef $$CombinedDivinationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CombinedDivinationsTable,
    CombinedDivination,
    $$CombinedDivinationsTableFilterComposer,
    $$CombinedDivinationsTableOrderingComposer,
    $$CombinedDivinationsTableAnnotationComposer,
    $$CombinedDivinationsTableCreateCompanionBuilder,
    $$CombinedDivinationsTableUpdateCompanionBuilder,
    (CombinedDivination, $$CombinedDivinationsTableReferences),
    CombinedDivination,
    PrefetchHooks Function({bool divinationUuid})>;
typedef $$PanelsTableCreateCompanionBuilder = PanelsCompanion Function({
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String uuid,
  required EnumPanelType panelType,
  required int skillId,
  required String divinateType,
  required String divinateUuid,
  Value<int> rowid,
});
typedef $$PanelsTableUpdateCompanionBuilder = PanelsCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> uuid,
  Value<EnumPanelType> panelType,
  Value<int> skillId,
  Value<String> divinateType,
  Value<String> divinateUuid,
  Value<int> rowid,
});

final class $$PanelsTableReferences
    extends BaseReferences<_$AppDatabase, $PanelsTable, Panel> {
  $$PanelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SkillsTable _skillIdTable(_$AppDatabase db) => db.skills
      .createAlias($_aliasNameGenerator(db.panels.skillId, db.skills.id));

  $$SkillsTableProcessedTableManager get skillId {
    final $_column = $_itemColumn<int>('skill_id')!;

    final manager = $$SkillsTableTableManager($_db, $_db.skills)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skillIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DivinationPanelMappersTable,
      List<DivinationPanelMapper>> _divinationPanelMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.divinationPanelMappers,
          aliasName: $_aliasNameGenerator(
              db.panels.uuid, db.divinationPanelMappers.panelUuid));

  $$DivinationPanelMappersTableProcessedTableManager
      get divinationPanelMappersRefs {
    final manager = $$DivinationPanelMappersTableTableManager(
            $_db, $_db.divinationPanelMappers)
        .filter(
            (f) => f.panelUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_divinationPanelMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PanelSkillClassMappersTable,
      List<PanelSkillClassMapper>> _panelSkillClassMappersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.panelSkillClassMappers,
          aliasName: $_aliasNameGenerator(
              db.panels.uuid, db.panelSkillClassMappers.panelUuid));

  $$PanelSkillClassMappersTableProcessedTableManager
      get panelSkillClassMappersRefs {
    final manager = $$PanelSkillClassMappersTableTableManager(
            $_db, $_db.panelSkillClassMappers)
        .filter(
            (f) => f.panelUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_panelSkillClassMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PanelsTableFilterComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EnumPanelType, EnumPanelType, int>
      get panelType => $composableBuilder(
          column: $table.panelType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get divinateType => $composableBuilder(
      column: $table.divinateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid, builder: (column) => ColumnFilters(column));

  $$SkillsTableFilterComposer get skillId {
    final $$SkillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableFilterComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> divinationPanelMappersRefs(
      Expression<bool> Function($$DivinationPanelMappersTableFilterComposer f)
          f) {
    final $$DivinationPanelMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationPanelMappers,
            getReferencedColumn: (t) => t.panelUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationPanelMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationPanelMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> panelSkillClassMappersRefs(
      Expression<bool> Function($$PanelSkillClassMappersTableFilterComposer f)
          f) {
    final $$PanelSkillClassMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.panelSkillClassMappers,
            getReferencedColumn: (t) => t.panelUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PanelSkillClassMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.panelSkillClassMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PanelsTableOrderingComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get panelType => $composableBuilder(
      column: $table.panelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinateType => $composableBuilder(
      column: $table.divinateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid,
      builder: (column) => ColumnOrderings(column));

  $$SkillsTableOrderingComposer get skillId {
    final $$SkillsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableOrderingComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PanelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumPanelType, int> get panelType =>
      $composableBuilder(column: $table.panelType, builder: (column) => column);

  GeneratedColumn<String> get divinateType => $composableBuilder(
      column: $table.divinateType, builder: (column) => column);

  GeneratedColumn<String> get divinateUuid => $composableBuilder(
      column: $table.divinateUuid, builder: (column) => column);

  $$SkillsTableAnnotationComposer get skillId {
    final $$SkillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillId,
        referencedTable: $db.skills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillsTableAnnotationComposer(
              $db: $db,
              $table: $db.skills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> divinationPanelMappersRefs<T extends Object>(
      Expression<T> Function($$DivinationPanelMappersTableAnnotationComposer a)
          f) {
    final $$DivinationPanelMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationPanelMappers,
            getReferencedColumn: (t) => t.panelUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationPanelMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationPanelMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> panelSkillClassMappersRefs<T extends Object>(
      Expression<T> Function($$PanelSkillClassMappersTableAnnotationComposer a)
          f) {
    final $$PanelSkillClassMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.panelSkillClassMappers,
            getReferencedColumn: (t) => t.panelUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PanelSkillClassMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.panelSkillClassMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PanelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PanelsTable,
    Panel,
    $$PanelsTableFilterComposer,
    $$PanelsTableOrderingComposer,
    $$PanelsTableAnnotationComposer,
    $$PanelsTableCreateCompanionBuilder,
    $$PanelsTableUpdateCompanionBuilder,
    (Panel, $$PanelsTableReferences),
    Panel,
    PrefetchHooks Function(
        {bool skillId,
        bool divinationPanelMappersRefs,
        bool panelSkillClassMappersRefs})> {
  $$PanelsTableTableManager(_$AppDatabase db, $PanelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<EnumPanelType> panelType = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<String> divinateType = const Value.absent(),
            Value<String> divinateUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelsCompanion(
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            uuid: uuid,
            panelType: panelType,
            skillId: skillId,
            divinateType: divinateType,
            divinateUuid: divinateUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String uuid,
            required EnumPanelType panelType,
            required int skillId,
            required String divinateType,
            required String divinateUuid,
            Value<int> rowid = const Value.absent(),
          }) =>
              PanelsCompanion.insert(
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            uuid: uuid,
            panelType: panelType,
            skillId: skillId,
            divinateType: divinateType,
            divinateUuid: divinateUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PanelsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {skillId = false,
              divinationPanelMappersRefs = false,
              panelSkillClassMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationPanelMappersRefs) db.divinationPanelMappers,
                if (panelSkillClassMappersRefs) db.panelSkillClassMappers
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
                if (skillId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.skillId,
                    referencedTable: $$PanelsTableReferences._skillIdTable(db),
                    referencedColumn:
                        $$PanelsTableReferences._skillIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationPanelMappersRefs)
                    await $_getPrefetchedData<Panel, $PanelsTable,
                            DivinationPanelMapper>(
                        currentTable: table,
                        referencedTable: $$PanelsTableReferences
                            ._divinationPanelMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PanelsTableReferences(db, table, p0)
                                .divinationPanelMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.panelUuid == item.uuid),
                        typedResults: items),
                  if (panelSkillClassMappersRefs)
                    await $_getPrefetchedData<Panel, $PanelsTable,
                            PanelSkillClassMapper>(
                        currentTable: table,
                        referencedTable: $$PanelsTableReferences
                            ._panelSkillClassMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PanelsTableReferences(db, table, p0)
                                .panelSkillClassMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.panelUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PanelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PanelsTable,
    Panel,
    $$PanelsTableFilterComposer,
    $$PanelsTableOrderingComposer,
    $$PanelsTableAnnotationComposer,
    $$PanelsTableCreateCompanionBuilder,
    $$PanelsTableUpdateCompanionBuilder,
    (Panel, $$PanelsTableReferences),
    Panel,
    PrefetchHooks Function(
        {bool skillId,
        bool divinationPanelMappersRefs,
        bool panelSkillClassMappersRefs})>;
typedef $$SubDivinationTypesTableCreateCompanionBuilder
    = SubDivinationTypesCompanion Function({
  required String uuid,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  required String name,
  required bool isCustomized,
  required bool isAvailable,
  Value<int> rowid,
});
typedef $$SubDivinationTypesTableUpdateCompanionBuilder
    = SubDivinationTypesCompanion Function({
  Value<String> uuid,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> hiddenAt,
  Value<String> name,
  Value<bool> isCustomized,
  Value<bool> isAvailable,
  Value<int> rowid,
});

final class $$SubDivinationTypesTableReferences extends BaseReferences<
    _$AppDatabase, $SubDivinationTypesTable, SubDivinationTypeDataModel> {
  $$SubDivinationTypesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DivinationSubDivinationTypeMappersTable,
          List<DivinationSubDivinationTypeMapper>>
      _divinationSubDivinationTypeMappersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.divinationSubDivinationTypeMappers,
              aliasName: $_aliasNameGenerator(db.subDivinationTypes.uuid,
                  db.divinationSubDivinationTypeMappers.subTypeUuid));

  $$DivinationSubDivinationTypeMappersTableProcessedTableManager
      get divinationSubDivinationTypeMappersRefs {
    final manager = $$DivinationSubDivinationTypeMappersTableTableManager(
            $_db, $_db.divinationSubDivinationTypeMappers)
        .filter(
            (f) => f.subTypeUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult
        .readTableOrNull(_divinationSubDivinationTypeMappersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubDivinationTypesTableFilterComposer
    extends Composer<_$AppDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableFilterComposer({
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

  ColumnFilters<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  Expression<bool> divinationSubDivinationTypeMappersRefs(
      Expression<bool> Function(
              $$DivinationSubDivinationTypeMappersTableFilterComposer f)
          f) {
    final $$DivinationSubDivinationTypeMappersTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.subTypeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubDivinationTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableOrderingComposer({
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

  ColumnOrderings<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));
}

class $$SubDivinationTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubDivinationTypesTable> {
  $$SubDivinationTypesTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCustomized => $composableBuilder(
      column: $table.isCustomized, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  Expression<T> divinationSubDivinationTypeMappersRefs<T extends Object>(
      Expression<T> Function(
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer a)
          f) {
    final $$DivinationSubDivinationTypeMappersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.divinationSubDivinationTypeMappers,
            getReferencedColumn: (t) => t.subTypeUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.divinationSubDivinationTypeMappers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubDivinationTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubDivinationTypesTable,
    SubDivinationTypeDataModel,
    $$SubDivinationTypesTableFilterComposer,
    $$SubDivinationTypesTableOrderingComposer,
    $$SubDivinationTypesTableAnnotationComposer,
    $$SubDivinationTypesTableCreateCompanionBuilder,
    $$SubDivinationTypesTableUpdateCompanionBuilder,
    (SubDivinationTypeDataModel, $$SubDivinationTypesTableReferences),
    SubDivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})> {
  $$SubDivinationTypesTableTableManager(
      _$AppDatabase db, $SubDivinationTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubDivinationTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubDivinationTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubDivinationTypesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> hiddenAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isCustomized = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubDivinationTypesCompanion(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
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
            required bool isCustomized,
            required bool isAvailable,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubDivinationTypesCompanion.insert(
            uuid: uuid,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            hiddenAt: hiddenAt,
            name: name,
            isCustomized: isCustomized,
            isAvailable: isAvailable,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubDivinationTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationSubDivinationTypeMappersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (divinationSubDivinationTypeMappersRefs)
                  db.divinationSubDivinationTypeMappers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (divinationSubDivinationTypeMappersRefs)
                    await $_getPrefetchedData<
                            SubDivinationTypeDataModel,
                            $SubDivinationTypesTable,
                            DivinationSubDivinationTypeMapper>(
                        currentTable: table,
                        referencedTable: $$SubDivinationTypesTableReferences
                            ._divinationSubDivinationTypeMappersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubDivinationTypesTableReferences(db, table, p0)
                                .divinationSubDivinationTypeMappersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subTypeUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubDivinationTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubDivinationTypesTable,
    SubDivinationTypeDataModel,
    $$SubDivinationTypesTableFilterComposer,
    $$SubDivinationTypesTableOrderingComposer,
    $$SubDivinationTypesTableAnnotationComposer,
    $$SubDivinationTypesTableCreateCompanionBuilder,
    $$SubDivinationTypesTableUpdateCompanionBuilder,
    (SubDivinationTypeDataModel, $$SubDivinationTypesTableReferences),
    SubDivinationTypeDataModel,
    PrefetchHooks Function({bool divinationSubDivinationTypeMappersRefs})>;
typedef $$SeekerDivinationMappersTableCreateCompanionBuilder
    = SeekerDivinationMappersCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationUuid,
  required String seekerUuid,
});
typedef $$SeekerDivinationMappersTableUpdateCompanionBuilder
    = SeekerDivinationMappersCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationUuid,
  Value<String> seekerUuid,
});

final class $$SeekerDivinationMappersTableReferences extends BaseReferences<
    _$AppDatabase, $SeekerDivinationMappersTable, SeekerDivinationMapper> {
  $$SeekerDivinationMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationsTable _divinationUuidTable(_$AppDatabase db) =>
      db.divinations.createAlias($_aliasNameGenerator(
          db.seekerDivinationMappers.divinationUuid, db.divinations.uuid));

  $$DivinationsTableProcessedTableManager get divinationUuid {
    final $_column = $_itemColumn<String>('divination_uuid')!;

    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SeekersTable _seekerUuidTable(_$AppDatabase db) =>
      db.seekers.createAlias($_aliasNameGenerator(
          db.seekerDivinationMappers.seekerUuid, db.seekers.uuid));

  $$SeekersTableProcessedTableManager get seekerUuid {
    final $_column = $_itemColumn<String>('seeker_uuid')!;

    final manager = $$SeekersTableTableManager($_db, $_db.seekers)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seekerUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SeekerDivinationMappersTableFilterComposer
    extends Composer<_$AppDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableFilterComposer({
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

  $$DivinationsTableFilterComposer get divinationUuid {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableFilterComposer get seekerUuid {
    final $$SeekersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableFilterComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableOrderingComposer
    extends Composer<_$AppDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableOrderingComposer({
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

  $$DivinationsTableOrderingComposer get divinationUuid {
    final $$DivinationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableOrderingComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableOrderingComposer get seekerUuid {
    final $$SeekersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableOrderingComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeekerDivinationMappersTable> {
  $$SeekerDivinationMappersTableAnnotationComposer({
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

  $$DivinationsTableAnnotationComposer get divinationUuid {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SeekersTableAnnotationComposer get seekerUuid {
    final $$SeekersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seekerUuid,
        referencedTable: $db.seekers,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeekersTableAnnotationComposer(
              $db: $db,
              $table: $db.seekers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeekerDivinationMappersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeekerDivinationMappersTable,
    SeekerDivinationMapper,
    $$SeekerDivinationMappersTableFilterComposer,
    $$SeekerDivinationMappersTableOrderingComposer,
    $$SeekerDivinationMappersTableAnnotationComposer,
    $$SeekerDivinationMappersTableCreateCompanionBuilder,
    $$SeekerDivinationMappersTableUpdateCompanionBuilder,
    (SeekerDivinationMapper, $$SeekerDivinationMappersTableReferences),
    SeekerDivinationMapper,
    PrefetchHooks Function({bool divinationUuid, bool seekerUuid})> {
  $$SeekerDivinationMappersTableTableManager(
      _$AppDatabase db, $SeekerDivinationMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeekerDivinationMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SeekerDivinationMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeekerDivinationMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String> seekerUuid = const Value.absent(),
          }) =>
              SeekerDivinationMappersCompanion(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationUuid,
            required String seekerUuid,
          }) =>
              SeekerDivinationMappersCompanion.insert(
            id: id,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            seekerUuid: seekerUuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SeekerDivinationMappersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {divinationUuid = false, seekerUuid = false}) {
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
                if (divinationUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationUuid,
                    referencedTable: $$SeekerDivinationMappersTableReferences
                        ._divinationUuidTable(db),
                    referencedColumn: $$SeekerDivinationMappersTableReferences
                        ._divinationUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (seekerUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seekerUuid,
                    referencedTable: $$SeekerDivinationMappersTableReferences
                        ._seekerUuidTable(db),
                    referencedColumn: $$SeekerDivinationMappersTableReferences
                        ._seekerUuidTable(db)
                        .uuid,
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

typedef $$SeekerDivinationMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SeekerDivinationMappersTable,
        SeekerDivinationMapper,
        $$SeekerDivinationMappersTableFilterComposer,
        $$SeekerDivinationMappersTableOrderingComposer,
        $$SeekerDivinationMappersTableAnnotationComposer,
        $$SeekerDivinationMappersTableCreateCompanionBuilder,
        $$SeekerDivinationMappersTableUpdateCompanionBuilder,
        (SeekerDivinationMapper, $$SeekerDivinationMappersTableReferences),
        SeekerDivinationMapper,
        PrefetchHooks Function({bool divinationUuid, bool seekerUuid})>;
typedef $$DivinationPanelMappersTableCreateCompanionBuilder
    = DivinationPanelMappersCompanion Function({
  Value<int> id,
  required String divinationUuid,
  required String panelUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$DivinationPanelMappersTableUpdateCompanionBuilder
    = DivinationPanelMappersCompanion Function({
  Value<int> id,
  Value<String> divinationUuid,
  Value<String> panelUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

final class $$DivinationPanelMappersTableReferences extends BaseReferences<
    _$AppDatabase, $DivinationPanelMappersTable, DivinationPanelMapper> {
  $$DivinationPanelMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationsTable _divinationUuidTable(_$AppDatabase db) =>
      db.divinations.createAlias($_aliasNameGenerator(
          db.divinationPanelMappers.divinationUuid, db.divinations.uuid));

  $$DivinationsTableProcessedTableManager get divinationUuid {
    final $_column = $_itemColumn<String>('divination_uuid')!;

    final manager = $$DivinationsTableTableManager($_db, $_db.divinations)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_divinationUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PanelsTable _panelUuidTable(_$AppDatabase db) =>
      db.panels.createAlias($_aliasNameGenerator(
          db.divinationPanelMappers.panelUuid, db.panels.uuid));

  $$PanelsTableProcessedTableManager get panelUuid {
    final $_column = $_itemColumn<String>('panel_uuid')!;

    final manager = $$PanelsTableTableManager($_db, $_db.panels)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_panelUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DivinationPanelMappersTableFilterComposer
    extends Composer<_$AppDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableFilterComposer({
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$DivinationsTableFilterComposer get divinationUuid {
    final $$DivinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableFilterComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PanelsTableFilterComposer get panelUuid {
    final $$PanelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableFilterComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationPanelMappersTableOrderingComposer
    extends Composer<_$AppDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$DivinationsTableOrderingComposer get divinationUuid {
    final $$DivinationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableOrderingComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PanelsTableOrderingComposer get panelUuid {
    final $$PanelsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableOrderingComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationPanelMappersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DivinationPanelMappersTable> {
  $$DivinationPanelMappersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DivinationsTableAnnotationComposer get divinationUuid {
    final $$DivinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.divinationUuid,
        referencedTable: $db.divinations,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.divinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PanelsTableAnnotationComposer get panelUuid {
    final $$PanelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableAnnotationComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationPanelMappersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DivinationPanelMappersTable,
    DivinationPanelMapper,
    $$DivinationPanelMappersTableFilterComposer,
    $$DivinationPanelMappersTableOrderingComposer,
    $$DivinationPanelMappersTableAnnotationComposer,
    $$DivinationPanelMappersTableCreateCompanionBuilder,
    $$DivinationPanelMappersTableUpdateCompanionBuilder,
    (DivinationPanelMapper, $$DivinationPanelMappersTableReferences),
    DivinationPanelMapper,
    PrefetchHooks Function({bool divinationUuid, bool panelUuid})> {
  $$DivinationPanelMappersTableTableManager(
      _$AppDatabase db, $DivinationPanelMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationPanelMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationPanelMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationPanelMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<String> panelUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationPanelMappersCompanion(
            id: id,
            divinationUuid: divinationUuid,
            panelUuid: panelUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String divinationUuid,
            required String panelUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationPanelMappersCompanion.insert(
            id: id,
            divinationUuid: divinationUuid,
            panelUuid: panelUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationPanelMappersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({divinationUuid = false, panelUuid = false}) {
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
                if (divinationUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.divinationUuid,
                    referencedTable: $$DivinationPanelMappersTableReferences
                        ._divinationUuidTable(db),
                    referencedColumn: $$DivinationPanelMappersTableReferences
                        ._divinationUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (panelUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.panelUuid,
                    referencedTable: $$DivinationPanelMappersTableReferences
                        ._panelUuidTable(db),
                    referencedColumn: $$DivinationPanelMappersTableReferences
                        ._panelUuidTable(db)
                        .uuid,
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

typedef $$DivinationPanelMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DivinationPanelMappersTable,
        DivinationPanelMapper,
        $$DivinationPanelMappersTableFilterComposer,
        $$DivinationPanelMappersTableOrderingComposer,
        $$DivinationPanelMappersTableAnnotationComposer,
        $$DivinationPanelMappersTableCreateCompanionBuilder,
        $$DivinationPanelMappersTableUpdateCompanionBuilder,
        (DivinationPanelMapper, $$DivinationPanelMappersTableReferences),
        DivinationPanelMapper,
        PrefetchHooks Function({bool divinationUuid, bool panelUuid})>;
typedef $$PanelSkillClassMappersTableCreateCompanionBuilder
    = PanelSkillClassMappersCompanion Function({
  Value<int> id,
  required String panelUuid,
  required String skillClassUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$PanelSkillClassMappersTableUpdateCompanionBuilder
    = PanelSkillClassMappersCompanion Function({
  Value<int> id,
  Value<String> panelUuid,
  Value<String> skillClassUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

final class $$PanelSkillClassMappersTableReferences extends BaseReferences<
    _$AppDatabase, $PanelSkillClassMappersTable, PanelSkillClassMapper> {
  $$PanelSkillClassMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PanelsTable _panelUuidTable(_$AppDatabase db) =>
      db.panels.createAlias($_aliasNameGenerator(
          db.panelSkillClassMappers.panelUuid, db.panels.uuid));

  $$PanelsTableProcessedTableManager get panelUuid {
    final $_column = $_itemColumn<String>('panel_uuid')!;

    final manager = $$PanelsTableTableManager($_db, $_db.panels)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_panelUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SkillClassesTable _skillClassUuidTable(_$AppDatabase db) =>
      db.skillClasses.createAlias($_aliasNameGenerator(
          db.panelSkillClassMappers.skillClassUuid, db.skillClasses.uuid));

  $$SkillClassesTableProcessedTableManager get skillClassUuid {
    final $_column = $_itemColumn<String>('skill_class_uuid')!;

    final manager = $$SkillClassesTableTableManager($_db, $_db.skillClasses)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skillClassUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PanelSkillClassMappersTableFilterComposer
    extends Composer<_$AppDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableFilterComposer({
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$PanelsTableFilterComposer get panelUuid {
    final $$PanelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableFilterComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SkillClassesTableFilterComposer get skillClassUuid {
    final $$SkillClassesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillClassUuid,
        referencedTable: $db.skillClasses,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillClassesTableFilterComposer(
              $db: $db,
              $table: $db.skillClasses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PanelSkillClassMappersTableOrderingComposer
    extends Composer<_$AppDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$PanelsTableOrderingComposer get panelUuid {
    final $$PanelsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableOrderingComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SkillClassesTableOrderingComposer get skillClassUuid {
    final $$SkillClassesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillClassUuid,
        referencedTable: $db.skillClasses,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillClassesTableOrderingComposer(
              $db: $db,
              $table: $db.skillClasses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PanelSkillClassMappersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PanelSkillClassMappersTable> {
  $$PanelSkillClassMappersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PanelsTableAnnotationComposer get panelUuid {
    final $$PanelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.panelUuid,
        referencedTable: $db.panels,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PanelsTableAnnotationComposer(
              $db: $db,
              $table: $db.panels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SkillClassesTableAnnotationComposer get skillClassUuid {
    final $$SkillClassesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.skillClassUuid,
        referencedTable: $db.skillClasses,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkillClassesTableAnnotationComposer(
              $db: $db,
              $table: $db.skillClasses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PanelSkillClassMappersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PanelSkillClassMappersTable,
    PanelSkillClassMapper,
    $$PanelSkillClassMappersTableFilterComposer,
    $$PanelSkillClassMappersTableOrderingComposer,
    $$PanelSkillClassMappersTableAnnotationComposer,
    $$PanelSkillClassMappersTableCreateCompanionBuilder,
    $$PanelSkillClassMappersTableUpdateCompanionBuilder,
    (PanelSkillClassMapper, $$PanelSkillClassMappersTableReferences),
    PanelSkillClassMapper,
    PrefetchHooks Function({bool panelUuid, bool skillClassUuid})> {
  $$PanelSkillClassMappersTableTableManager(
      _$AppDatabase db, $PanelSkillClassMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelSkillClassMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelSkillClassMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelSkillClassMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> panelUuid = const Value.absent(),
            Value<String> skillClassUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PanelSkillClassMappersCompanion(
            id: id,
            panelUuid: panelUuid,
            skillClassUuid: skillClassUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String panelUuid,
            required String skillClassUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PanelSkillClassMappersCompanion.insert(
            id: id,
            panelUuid: panelUuid,
            skillClassUuid: skillClassUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PanelSkillClassMappersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({panelUuid = false, skillClassUuid = false}) {
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
                if (panelUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.panelUuid,
                    referencedTable: $$PanelSkillClassMappersTableReferences
                        ._panelUuidTable(db),
                    referencedColumn: $$PanelSkillClassMappersTableReferences
                        ._panelUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (skillClassUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.skillClassUuid,
                    referencedTable: $$PanelSkillClassMappersTableReferences
                        ._skillClassUuidTable(db),
                    referencedColumn: $$PanelSkillClassMappersTableReferences
                        ._skillClassUuidTable(db)
                        .uuid,
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

typedef $$PanelSkillClassMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PanelSkillClassMappersTable,
        PanelSkillClassMapper,
        $$PanelSkillClassMappersTableFilterComposer,
        $$PanelSkillClassMappersTableOrderingComposer,
        $$PanelSkillClassMappersTableAnnotationComposer,
        $$PanelSkillClassMappersTableCreateCompanionBuilder,
        $$PanelSkillClassMappersTableUpdateCompanionBuilder,
        (PanelSkillClassMapper, $$PanelSkillClassMappersTableReferences),
        PanelSkillClassMapper,
        PrefetchHooks Function({bool panelUuid, bool skillClassUuid})>;
typedef $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder
    = DivinationSubDivinationTypeMappersCompanion Function({
  Value<int> id,
  required String typeUuid,
  required String subTypeUuid,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
});
typedef $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder
    = DivinationSubDivinationTypeMappersCompanion Function({
  Value<int> id,
  Value<String> typeUuid,
  Value<String> subTypeUuid,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
});

final class $$DivinationSubDivinationTypeMappersTableReferences
    extends BaseReferences<
        _$AppDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper> {
  $$DivinationSubDivinationTypeMappersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DivinationTypesTable _typeUuidTable(_$AppDatabase db) =>
      db.divinationTypes.createAlias($_aliasNameGenerator(
          db.divinationSubDivinationTypeMappers.typeUuid,
          db.divinationTypes.uuid));

  $$DivinationTypesTableProcessedTableManager get typeUuid {
    final $_column = $_itemColumn<String>('divination_type_uuid')!;

    final manager =
        $$DivinationTypesTableTableManager($_db, $_db.divinationTypes)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubDivinationTypesTable _subTypeUuidTable(_$AppDatabase db) =>
      db.subDivinationTypes.createAlias($_aliasNameGenerator(
          db.divinationSubDivinationTypeMappers.subTypeUuid,
          db.subDivinationTypes.uuid));

  $$SubDivinationTypesTableProcessedTableManager get subTypeUuid {
    final $_column = $_itemColumn<String>('sub_divination_type_uuid')!;

    final manager =
        $$SubDivinationTypesTableTableManager($_db, $_db.subDivinationTypes)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subTypeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DivinationSubDivinationTypeMappersTableFilterComposer
    extends Composer<_$AppDatabase, $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableFilterComposer({
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$DivinationTypesTableFilterComposer get typeUuid {
    final $$DivinationTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableFilterComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableFilterComposer get subTypeUuid {
    final $$SubDivinationTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subTypeUuid,
        referencedTable: $db.subDivinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubDivinationTypesTableFilterComposer(
              $db: $db,
              $table: $db.subDivinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableOrderingComposer
    extends Composer<_$AppDatabase, $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$DivinationTypesTableOrderingComposer get typeUuid {
    final $$DivinationTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableOrderingComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableOrderingComposer get subTypeUuid {
    final $$SubDivinationTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subTypeUuid,
        referencedTable: $db.subDivinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubDivinationTypesTableOrderingComposer(
              $db: $db,
              $table: $db.subDivinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DivinationSubDivinationTypeMappersTable> {
  $$DivinationSubDivinationTypeMappersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DivinationTypesTableAnnotationComposer get typeUuid {
    final $$DivinationTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.typeUuid,
        referencedTable: $db.divinationTypes,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DivinationTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.divinationTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubDivinationTypesTableAnnotationComposer get subTypeUuid {
    final $$SubDivinationTypesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.subTypeUuid,
            referencedTable: $db.subDivinationTypes,
            getReferencedColumn: (t) => t.uuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubDivinationTypesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subDivinationTypes,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DivinationSubDivinationTypeMappersTableTableManager
    extends RootTableManager<
        _$AppDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper,
        $$DivinationSubDivinationTypeMappersTableFilterComposer,
        $$DivinationSubDivinationTypeMappersTableOrderingComposer,
        $$DivinationSubDivinationTypeMappersTableAnnotationComposer,
        $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder,
        $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder,
        (
          DivinationSubDivinationTypeMapper,
          $$DivinationSubDivinationTypeMappersTableReferences
        ),
        DivinationSubDivinationTypeMapper,
        PrefetchHooks Function({bool typeUuid, bool subTypeUuid})> {
  $$DivinationSubDivinationTypeMappersTableTableManager(
      _$AppDatabase db, $DivinationSubDivinationTypeMappersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DivinationSubDivinationTypeMappersTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DivinationSubDivinationTypeMappersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DivinationSubDivinationTypeMappersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> typeUuid = const Value.absent(),
            Value<String> subTypeUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationSubDivinationTypeMappersCompanion(
            id: id,
            typeUuid: typeUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String typeUuid,
            required String subTypeUuid,
            required DateTime createdAt,
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DivinationSubDivinationTypeMappersCompanion.insert(
            id: id,
            typeUuid: typeUuid,
            subTypeUuid: subTypeUuid,
            createdAt: createdAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DivinationSubDivinationTypeMappersTableReferences(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({typeUuid = false, subTypeUuid = false}) {
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
                if (typeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.typeUuid,
                    referencedTable:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._typeUuidTable(db),
                    referencedColumn:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._typeUuidTable(db)
                            .uuid,
                  ) as T;
                }
                if (subTypeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subTypeUuid,
                    referencedTable:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._subTypeUuidTable(db),
                    referencedColumn:
                        $$DivinationSubDivinationTypeMappersTableReferences
                            ._subTypeUuidTable(db)
                            .uuid,
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

typedef $$DivinationSubDivinationTypeMappersTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DivinationSubDivinationTypeMappersTable,
        DivinationSubDivinationTypeMapper,
        $$DivinationSubDivinationTypeMappersTableFilterComposer,
        $$DivinationSubDivinationTypeMappersTableOrderingComposer,
        $$DivinationSubDivinationTypeMappersTableAnnotationComposer,
        $$DivinationSubDivinationTypeMappersTableCreateCompanionBuilder,
        $$DivinationSubDivinationTypeMappersTableUpdateCompanionBuilder,
        (
          DivinationSubDivinationTypeMapper,
          $$DivinationSubDivinationTypeMappersTableReferences
        ),
        DivinationSubDivinationTypeMapper,
        PrefetchHooks Function({bool typeUuid, bool subTypeUuid})>;
typedef $$TimingDivinationsTableCreateCompanionBuilder
    = TimingDivinationsCompanion Function({
  required String uuid,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationUuid,
  required DateTimeType timingType,
  required DateTime datetime,
  Value<bool> isManual,
  required JiaZi yearGanZhi,
  required JiaZi monthGanZhi,
  required JiaZi dayGanZhi,
  required JiaZi timeGanZhi,
  required int lunarMonth,
  Value<bool> isLeapMonth,
  required int lunarDay,
  required String timingInfoUuid,
  Value<Location?> location,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<int> rowid,
});
typedef $$TimingDivinationsTableUpdateCompanionBuilder
    = TimingDivinationsCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationUuid,
  Value<DateTimeType> timingType,
  Value<DateTime> datetime,
  Value<bool> isManual,
  Value<JiaZi> yearGanZhi,
  Value<JiaZi> monthGanZhi,
  Value<JiaZi> dayGanZhi,
  Value<JiaZi> timeGanZhi,
  Value<int> lunarMonth,
  Value<bool> isLeapMonth,
  Value<int> lunarDay,
  Value<String> timingInfoUuid,
  Value<Location?> location,
  Value<List<DivinationDatetimeModel>?> timingInfoListJson,
  Value<int> rowid,
});

class $$TimingDivinationsTableFilterComposer
    extends Composer<_$AppDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableFilterComposer({
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

  ColumnFilters<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTimeType, DateTimeType, int>
      get timingType => $composableBuilder(
          column: $table.timingType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get dayGanZhi =>
      $composableBuilder(
          column: $table.dayGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<JiaZi, JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Location?, Location, String> get location =>
      $composableBuilder(
          column: $table.location,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<DivinationDatetimeModel>?,
          List<DivinationDatetimeModel>, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$TimingDivinationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableOrderingComposer({
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

  ColumnOrderings<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timingType => $composableBuilder(
      column: $table.timingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
      column: $table.datetime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get yearGanZhi => $composableBuilder(
      column: $table.yearGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthGanZhi => $composableBuilder(
      column: $table.monthGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayGanZhi => $composableBuilder(
      column: $table.dayGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeGanZhi => $composableBuilder(
      column: $table.timeGanZhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lunarDay => $composableBuilder(
      column: $table.lunarDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timingInfoListJson => $composableBuilder(
      column: $table.timingInfoListJson,
      builder: (column) => ColumnOrderings(column));
}

class $$TimingDivinationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimingDivinationsTable> {
  $$TimingDivinationsTableAnnotationComposer({
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

  GeneratedColumn<String> get divinationUuid => $composableBuilder(
      column: $table.divinationUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTimeType, int> get timingType =>
      $composableBuilder(
          column: $table.timingType, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get yearGanZhi =>
      $composableBuilder(
          column: $table.yearGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get monthGanZhi =>
      $composableBuilder(
          column: $table.monthGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get dayGanZhi =>
      $composableBuilder(column: $table.dayGanZhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JiaZi, int> get timeGanZhi =>
      $composableBuilder(
          column: $table.timeGanZhi, builder: (column) => column);

  GeneratedColumn<int> get lunarMonth => $composableBuilder(
      column: $table.lunarMonth, builder: (column) => column);

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
      column: $table.isLeapMonth, builder: (column) => column);

  GeneratedColumn<int> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumn<String> get timingInfoUuid => $composableBuilder(
      column: $table.timingInfoUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Location?, String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<DivinationDatetimeModel>?, String>
      get timingInfoListJson => $composableBuilder(
          column: $table.timingInfoListJson, builder: (column) => column);
}

class $$TimingDivinationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimingDivinationsTable,
    TimingDivinationModel,
    $$TimingDivinationsTableFilterComposer,
    $$TimingDivinationsTableOrderingComposer,
    $$TimingDivinationsTableAnnotationComposer,
    $$TimingDivinationsTableCreateCompanionBuilder,
    $$TimingDivinationsTableUpdateCompanionBuilder,
    (
      TimingDivinationModel,
      BaseReferences<_$AppDatabase, $TimingDivinationsTable,
          TimingDivinationModel>
    ),
    TimingDivinationModel,
    PrefetchHooks Function()> {
  $$TimingDivinationsTableTableManager(
      _$AppDatabase db, $TimingDivinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimingDivinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimingDivinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimingDivinationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationUuid = const Value.absent(),
            Value<DateTimeType> timingType = const Value.absent(),
            Value<DateTime> datetime = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<JiaZi> yearGanZhi = const Value.absent(),
            Value<JiaZi> monthGanZhi = const Value.absent(),
            Value<JiaZi> dayGanZhi = const Value.absent(),
            Value<JiaZi> timeGanZhi = const Value.absent(),
            Value<int> lunarMonth = const Value.absent(),
            Value<bool> isLeapMonth = const Value.absent(),
            Value<int> lunarDay = const Value.absent(),
            Value<String> timingInfoUuid = const Value.absent(),
            Value<Location?> location = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimingDivinationsCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            timingType: timingType,
            datetime: datetime,
            isManual: isManual,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            timingInfoUuid: timingInfoUuid,
            location: location,
            timingInfoListJson: timingInfoListJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationUuid,
            required DateTimeType timingType,
            required DateTime datetime,
            Value<bool> isManual = const Value.absent(),
            required JiaZi yearGanZhi,
            required JiaZi monthGanZhi,
            required JiaZi dayGanZhi,
            required JiaZi timeGanZhi,
            required int lunarMonth,
            Value<bool> isLeapMonth = const Value.absent(),
            required int lunarDay,
            required String timingInfoUuid,
            Value<Location?> location = const Value.absent(),
            Value<List<DivinationDatetimeModel>?> timingInfoListJson =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimingDivinationsCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationUuid: divinationUuid,
            timingType: timingType,
            datetime: datetime,
            isManual: isManual,
            yearGanZhi: yearGanZhi,
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi,
            timeGanZhi: timeGanZhi,
            lunarMonth: lunarMonth,
            isLeapMonth: isLeapMonth,
            lunarDay: lunarDay,
            timingInfoUuid: timingInfoUuid,
            location: location,
            timingInfoListJson: timingInfoListJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TimingDivinationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimingDivinationsTable,
    TimingDivinationModel,
    $$TimingDivinationsTableFilterComposer,
    $$TimingDivinationsTableOrderingComposer,
    $$TimingDivinationsTableAnnotationComposer,
    $$TimingDivinationsTableCreateCompanionBuilder,
    $$TimingDivinationsTableUpdateCompanionBuilder,
    (
      TimingDivinationModel,
      BaseReferences<_$AppDatabase, $TimingDivinationsTable,
          TimingDivinationModel>
    ),
    TimingDivinationModel,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db, _db.skills);
  $$SkillClassesTableTableManager get skillClasses =>
      $$SkillClassesTableTableManager(_db, _db.skillClasses);
  $$LayoutTemplatesTableTableManager get layoutTemplates =>
      $$LayoutTemplatesTableTableManager(_db, _db.layoutTemplates);
  $$CardTemplateMetasTableTableManager get cardTemplateMetas =>
      $$CardTemplateMetasTableTableManager(_db, _db.cardTemplateMetas);
  $$CardTemplateSettingsTableTableManager get cardTemplateSettings =>
      $$CardTemplateSettingsTableTableManager(_db, _db.cardTemplateSettings);
  $$CardTemplateSkillUsagesTableTableManager get cardTemplateSkillUsages =>
      $$CardTemplateSkillUsagesTableTableManager(
          _db, _db.cardTemplateSkillUsages);
  $$MarketTemplateInstallsTableTableManager get marketTemplateInstalls =>
      $$MarketTemplateInstallsTableTableManager(
          _db, _db.marketTemplateInstalls);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(_db, _db.divinationTypes);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db, _db.divinations);
  $$CombinedDivinationsTableTableManager get combinedDivinations =>
      $$CombinedDivinationsTableTableManager(_db, _db.combinedDivinations);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db, _db.panels);
  $$SubDivinationTypesTableTableManager get subDivinationTypes =>
      $$SubDivinationTypesTableTableManager(_db, _db.subDivinationTypes);
  $$SeekerDivinationMappersTableTableManager get seekerDivinationMappers =>
      $$SeekerDivinationMappersTableTableManager(
          _db, _db.seekerDivinationMappers);
  $$DivinationPanelMappersTableTableManager get divinationPanelMappers =>
      $$DivinationPanelMappersTableTableManager(
          _db, _db.divinationPanelMappers);
  $$PanelSkillClassMappersTableTableManager get panelSkillClassMappers =>
      $$PanelSkillClassMappersTableTableManager(
          _db, _db.panelSkillClassMappers);
  $$DivinationSubDivinationTypeMappersTableTableManager
      get divinationSubDivinationTypeMappers =>
          $$DivinationSubDivinationTypeMappersTableTableManager(
              _db, _db.divinationSubDivinationTypeMappers);
  $$TimingDivinationsTableTableManager get timingDivinations =>
      $$TimingDivinationsTableTableManager(_db, _db.timingDivinations);
}
