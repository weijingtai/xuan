import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_skill_usage_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CardTemplateSkillUsageDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    dao = CardTemplateSkillUsageDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertUsage inserts multiple rows without overwriting', () async {
    const queryUuid = 'q1';
    const templateUuid = 't1';
    const skillId = 4;

    await dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: templateUuid,
      skillId: skillId,
      usedAt: '2026-01-08T10:30:00+08:00',
    );
    await dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: templateUuid,
      skillId: skillId,
      usedAt: '2026-01-08T10:31:00+08:00',
    );

    final rows = await dao.findByTemplate(templateUuid: templateUuid);
    expect(rows, hasLength(2));
  });

  test('findLatestByQueryAndSkill returns latest used_at row', () async {
    const queryUuid = 'q2';
    const skillId = 4;

    await dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: 't_old',
      skillId: skillId,
      usedAt: '2026-01-08T10:30:00+08:00',
    );
    await dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: 't_new',
      skillId: skillId,
      usedAt: '2026-01-08T10:31:00+08:00',
    );

    final latest = await dao.findLatestByQueryAndSkill(
      queryUuid: queryUuid,
      skillId: skillId,
    );

    expect(latest, isNotNull);
    expect(latest!.templateUuid, equals('t_new'));
    expect(() => DateTime.parse(latest.usedAt), returnsNormally);
  });
}

