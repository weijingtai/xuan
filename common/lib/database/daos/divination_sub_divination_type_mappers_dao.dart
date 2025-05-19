import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'divination_sub_divination_type_mappers_dao.g.dart';

@DriftAccessor(tables: [DivinationSubDivinationTypeMappers])
class DivinationSubDivinationTypeMappersDao
    extends DatabaseAccessor<AppDatabase>
    with _$DivinationSubDivinationTypeMappersDaoMixin {
  final AppDatabase db;
  DivinationSubDivinationTypeMappersDao(this.db) : super(db);

  SimpleSelectStatement<$DivinationSubDivinationTypeMappersTable,
          DivinationSubDivinationTypeMapper>
      _baseSelect() => select(db.divinationSubDivinationTypeMappers);

  Future<List<DivinationSubDivinationTypeMapper>>
      getAllDivinationSubDivinationTypeMappers() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<DivinationSubDivinationTypeMapper?>
      getDivinationSubDivinationTypeMapperByTypeUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.typeUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<DivinationSubDivinationTypeMapper?>
      getDivinationSubDivinationTypeMapperBySubTypeUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.subTypeUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertDivinationSubDivinationTypeMapper(
      DivinationSubDivinationTypeMappersCompanion companion) {
    return into(db.divinationSubDivinationTypeMappers).insert(companion);
  }

  Future<bool> updateDivinationSubDivinationTypeMapper(
      DivinationSubDivinationTypeMappersCompanion companion) {
    return update(db.divinationSubDivinationTypeMappers).replace(companion);
  }

  Future<int> softDeleteByTypeUuid(String uuid) {
    return (update(db.divinationSubDivinationTypeMappers)
          ..where((t) => t.typeUuid.equals(uuid)))
        .write(DivinationSubDivinationTypeMappersCompanion(
            deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeleteBySubTypeUuid(String uuid) {
    return (update(db.divinationSubDivinationTypeMappers)
          ..where((t) => t.subTypeUuid.equals(uuid)))
        .write(DivinationSubDivinationTypeMappersCompanion(
            deletedAt: Value(DateTime.now())));
  }
}
