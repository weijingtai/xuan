import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'panels_dao.g.dart';

@DriftAccessor(tables: [Panels])
class PanelsDao extends DatabaseAccessor<AppDatabase>
    with _$PanelsDaoMixin {
  final AppDatabase db;
  PanelsDao(this.db) : super(db);

  SimpleSelectStatement<$PanelsTable, Panel> _baseSelect() => 
      select(db.panels);

  Future<List<Panel>> getAllPanels() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<Panel?> getPanelByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertPanel(PanelsCompanion companion) {
    return into(db.panels).insert(companion);
  }

  Future<bool> updatePanel(PanelsCompanion companion) {
    return update(db.panels).replace(companion);
  }

  Future<int> softDeletePanel(String uuid) {
    return (update(db.panels)..where((t) => t.uuid.equals(uuid)))
        .write(PanelsCompanion(deletedAt: Value(DateTime.now())));
  }
}