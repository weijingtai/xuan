import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'skill_classes_dao.g.dart';

@DriftAccessor(tables: [SkillClasses])
class SkillClassesDao extends DatabaseAccessor<AppDatabase>
    with _$SkillClassesDaoMixin {
  final AppDatabase db;
  SkillClassesDao(this.db) : super(db);

  SimpleSelectStatement<$SkillClassesTable, SkillClass> _baseSelect() => 
      select(db.skillClasses);

  Future<List<SkillClass>> getAllSkillClasses() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<SkillClass?> getSkillClassByUuid(String uuid) {
    return (_baseSelect()
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertSkillClass(SkillClassesCompanion companion) {
    return into(db.skillClasses).insert(companion);
  }

  Future<bool> updateSkillClass(SkillClassesCompanion companion) {
    return update(db.skillClasses).replace(companion);
  }

  Future<int> softDeleteSkillClass(String uuid) {
    return (update(db.skillClasses)..where((t) => t.uuid.equals(uuid)))
        .write(SkillClassesCompanion(deletedAt: Value(DateTime.now())));
  }
}
