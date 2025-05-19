import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'divination_types_dao.g.dart';

@DriftAccessor(tables: [DivinationTypes])
class DivinationTypesDao extends DatabaseAccessor<AppDatabase>
    with _$DivinationTypesDaoMixin {
  final AppDatabase db;
  DivinationTypesDao(this.db) : super(db);

  SimpleSelectStatement<$DivinationTypesTable, DivinationType> _baseSelect() => 
      select(db.divinationTypes);

  Future<List<DivinationType>> getAllDivinationTypes() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<DivinationType?> getDivinationTypeByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertDivinationType(DivinationTypesCompanion companion) {
    return into(db.divinationTypes).insert(companion);
  }

  Future<bool> updateDivinationType(DivinationTypesCompanion companion) {
    return update(db.divinationTypes).replace(companion);
  }

  Future<int> softDeleteDivinationType(String uuid) {
    return (update(db.divinationTypes)..where((t) => t.uuid.equals(uuid)))
        .write(DivinationTypesCompanion(deletedAt: Value(DateTime.now())));
  }
}