import 'package:drift/drift.dart';
import '../../datamodel/divination_request_info_datamodel.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'divinations_dao.g.dart';

@DriftAccessor(tables: [Divinations])
class DivinationsDao extends DatabaseAccessor<AppDatabase>
    with _$DivinationsDaoMixin {
  final AppDatabase db;
  DivinationsDao(this.db) : super(db);

  SimpleSelectStatement<$DivinationsTable, DivinationRequestInfoDataModel>
      _baseSelect() => select(db.divinations);

  Future<List<DivinationRequestInfoDataModel>> getAllDivinations() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<DivinationRequestInfoDataModel?> getDivinationByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertDivination(DivinationsCompanion companion) {
    return into(db.divinations).insert(companion);
  }

  Future<bool> updateDivination(DivinationsCompanion companion) {
    return update(db.divinations).replace(companion);
  }

  Future<int> softDeleteDivination(String uuid) {
    return (update(db.divinations)..where((t) => t.uuid.equals(uuid)))
        .write(DivinationsCompanion(deletedAt: Value(DateTime.now())));
  }
}
