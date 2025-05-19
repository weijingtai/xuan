import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'divination_panel_mappers_dao.g.dart';

@DriftAccessor(tables: [DivinationPanelMappers])
class DivinationPanelMappersDao extends DatabaseAccessor<AppDatabase>
    with _$DivinationPanelMappersDaoMixin {
  final AppDatabase db;
  DivinationPanelMappersDao(this.db) : super(db);

  SimpleSelectStatement<$DivinationPanelMappersTable, DivinationPanelMapper>
      _baseSelect() => select(db.divinationPanelMappers);

  Future<List<DivinationPanelMapper>> getAllDivinationPanelMappers() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<DivinationPanelMapper?> getDivinationPanelMapperByPanelUuid(
      String uuid) {
    return (_baseSelect()
          ..where((t) => t.panelUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<DivinationPanelMapper?> getDivinationPanelMapperByDivinationUuid(
      String uuid) {
    return (_baseSelect()
          ..where((t) => t.divinationUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertDivinationPanelMapper(
      DivinationPanelMappersCompanion companion) {
    return into(db.divinationPanelMappers).insert(companion);
  }

  Future<bool> updateDivinationPanelMapper(
      DivinationPanelMappersCompanion companion) {
    return update(db.divinationPanelMappers).replace(companion);
  }

  Future<int> softDeleteDivinationPanelMapperByDivinationUuid(String uuid) {
    return (update(db.divinationPanelMappers)
          ..where((t) => t.divinationUuid.equals(uuid)))
        .write(
            DivinationPanelMappersCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeleteDivinationPanelMapperByPanelUuid(String uuid) {
    return (update(db.divinationPanelMappers)
          ..where((t) => t.panelUuid.equals(uuid)))
        .write(
            DivinationPanelMappersCompanion(deletedAt: Value(DateTime.now())));
  }
}
