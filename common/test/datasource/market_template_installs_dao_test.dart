import 'package:common/database/app_database.dart';
import 'package:common/database/daos/market_template_installs_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MarketTemplateInstallsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    dao = MarketTemplateInstallsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert and findByLocalTemplateUuid roundtrip', () async {
    final now = DateTime.utc(2026, 1, 15, 2, 3, 4);

    await dao.upsertInstall(
      localTemplateUuid: 'local-1',
      marketTemplateId: 'mkt-1',
      marketVersionId: 'ver-1',
      installedAt: now,
    );

    final loaded = await dao.findByLocalTemplateUuid('local-1');
    expect(loaded, isNotNull);
    expect(loaded!.localTemplateUuid, equals('local-1'));
    expect(loaded.marketTemplateId, equals('mkt-1'));
    expect(loaded.marketVersionId, equals('ver-1'));
    expect(loaded.installedAt.toUtc(), equals(now));
    expect(loaded.deletedAt, isNull);
  });

  test('softDelete hides row from baseSelect', () async {
    await dao.upsertInstall(
      localTemplateUuid: 'local-2',
      marketTemplateId: 'mkt-2',
      marketVersionId: 'ver-2',
    );

    final deleted = await dao.softDeleteByLocalTemplateUuid('local-2');
    expect(deleted, equals(1));

    final loaded = await dao.findByLocalTemplateUuid('local-2');
    expect(loaded, isNull);
  });

  test('listByMarketTemplateId filters deleted rows', () async {
    await dao.upsertInstall(
      localTemplateUuid: 'local-3a',
      marketTemplateId: 'mkt-3',
      marketVersionId: 'ver-3a',
      installedAt: DateTime.utc(2026, 1, 10),
    );
    await dao.upsertInstall(
      localTemplateUuid: 'local-3b',
      marketTemplateId: 'mkt-3',
      marketVersionId: 'ver-3b',
      installedAt: DateTime.utc(2026, 1, 11),
    );

    await dao.softDeleteByLocalTemplateUuid('local-3a');

    final list = await dao.listByMarketTemplateId('mkt-3');
    expect(list.length, equals(1));
    expect(list.single.localTemplateUuid, equals('local-3b'));
  });
}
