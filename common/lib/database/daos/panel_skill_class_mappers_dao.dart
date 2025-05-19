import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'panel_skill_class_mappers_dao.g.dart';

@DriftAccessor(tables: [PanelSkillClassMappers])
class PanelSkillClassMappersDao extends DatabaseAccessor<AppDatabase>
    with _$PanelSkillClassMappersDaoMixin {
  final AppDatabase db;
  PanelSkillClassMappersDao(this.db) : super(db);

  SimpleSelectStatement<$PanelSkillClassMappersTable, PanelSkillClassMapper>
      _baseSelect() => select(db.panelSkillClassMappers);

  Future<List<PanelSkillClassMapper>> getAllPanelSkillClassMappers() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<PanelSkillClassMapper?> getPanelSkillClassMapperByPanelUuid(
      String uuid) {
    return (_baseSelect()
          ..where((t) => t.panelUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<PanelSkillClassMapper?> getPanelSkillClassMapperBySkillClassUuid(
      String uuid) {
    return (_baseSelect()
          ..where((t) => t.skillClassUuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertPanelSkillClassMapper(
      PanelSkillClassMappersCompanion companion) {
    return into(db.panelSkillClassMappers).insert(companion);
  }

  Future<bool> updatePanelSkillClassMapper(
      PanelSkillClassMappersCompanion companion) {
    return update(db.panelSkillClassMappers).replace(companion);
  }

  Future<int> softDeletePanelSkillClassMapperByPanelUuid(String uuid) {
    return (update(db.panelSkillClassMappers)
          ..where((t) => t.panelUuid.equals(uuid)))
        .write(
            PanelSkillClassMappersCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeletePanelSkillClassMapperBySkillClassUuid(String uuid) {
    return (update(db.panelSkillClassMappers)
          ..where((t) => t.skillClassUuid.equals(uuid)))
        .write(
            PanelSkillClassMappersCompanion(deletedAt: Value(DateTime.now())));
  }
}
