import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'combined_divinations_dao.g.dart';

@DriftAccessor(tables: [CombinedDivinations])
class CombinedDivinationsDao extends DatabaseAccessor<AppDatabase>
    with _$CombinedDivinationsDaoMixin {
  final AppDatabase db;
  CombinedDivinationsDao(this.db) : super(db);

  SimpleSelectStatement<$CombinedDivinationsTable, CombinedDivination>
      _baseSelect() => select(db.combinedDivinations);

  Future<List<CombinedDivination>> getAllCombinedDivinations() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<CombinedDivination?> getCombinedDivinationByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertCombinedDivination(CombinedDivinationsCompanion companion) {
    return into(db.combinedDivinations).insert(companion);
  }

  Future<bool> updateCombinedDivination(
      CombinedDivinationsCompanion companion) {
    return update(db.combinedDivinations).replace(companion);
  }

  Future<int> softDeleteCombinedDivination(String uuid) {
    return (update(db.combinedDivinations)..where((t) => t.uuid.equals(uuid)))
        .write(CombinedDivinationsCompanion(deletedAt: Value(DateTime.now())));
  }
}
