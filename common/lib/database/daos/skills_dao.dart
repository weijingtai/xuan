import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'skills_dao.g.dart';

@DriftAccessor(tables: [Skills])
class SkillsDao extends DatabaseAccessor<AppDatabase> with _$SkillsDaoMixin {
  final AppDatabase db;
  SkillsDao(this.db) : super(db);

  SimpleSelectStatement<$SkillsTable, Skill> _baseSelect() => select(db.skills);

  Future<List<Skill>> getAllSkills() {
    return (_baseSelect()..where((tbl) => tbl.deletedAt.isNull())).get();
  }

  Future<Skill?> getSkillById(int id) {
    return (_baseSelect()..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> insertSkill(SkillsCompanion companion) {
    return into(db.skills).insert(companion);
  }

  Future<bool> updateSkill(SkillsCompanion companion) {
    return update(db.skills).replace(companion);
  }

  Future<int> softDeleteSkill(int id) {
    return (update(db.skills)..where((t) => t.id.equals(id)))
        .write(SkillsCompanion(deletedAt: Value(DateTime.now())));
  }
}
