import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'skills_dao.g.dart';
@DriftAccessor(tables: [Skills])
class SkillsDao extends DatabaseAccessor<AppDatabase> with _$SkillsDaoMixin {
  SkillsDao(AppDatabase db) : super(db);

  // 获取所有技能记录的流
  Stream<List<Skill>> getAllSkillsStream() {
    return select(skills).watch();
  }

  // 根据 UUID 获取单个技能记录
  Future<Skill?> getSkillByUuid(int id) {
    return (select(skills)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  // 插入技能记录
  Future<int> insertSkill(SkillsCompanion skill) {
    return into(skills).insert(skill);
  }

  // 更新技能记录
  Future<bool> updateSkill(SkillsCompanion skill) {
    return update(skills).replace(skill);
  }

  // 删除技能记录
  Future<int> deleteSkill(Skill skill) {
    return (delete(skills)..where((s) => s.id.equals(skill.id))).go();
  }
}
    