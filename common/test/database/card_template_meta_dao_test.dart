import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_meta_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CardTemplateMetaDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    dao = CardTemplateMetaDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('touchModifiedAt inserts row when missing', () async {
    final now = DateTime.utc(2026, 1, 8, 2, 3, 4);
    await dao.touchModifiedAt(templateUuid: 't1', modifiedAt: now);

    final row = await dao.findByTemplateUuid('t1');
    expect(row, isNotNull);
    expect(row!.templateUuid, equals('t1'));
    expect(row.createdAt.toUtc(), equals(now));
    expect(row.modifiedAt.toUtc(), equals(now));
    expect(row.deletedAt, isNull);
  });

  test('touchModifiedAt updates modifiedAt when exists', () async {
    final t1 = DateTime.utc(2026, 1, 8, 1, 0, 0);
    final t2 = DateTime.utc(2026, 1, 8, 3, 0, 0);

    await dao.touchModifiedAt(templateUuid: 't2', modifiedAt: t1);
    await dao.touchModifiedAt(templateUuid: 't2', modifiedAt: t2);

    final row = await dao.findByTemplateUuid('t2');
    expect(row, isNotNull);
    expect(row!.modifiedAt.toUtc(), equals(t2));
  });
}
