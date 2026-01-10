import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_setting_dao.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/card_template_setting.dart';
import 'package:common/models/text_style_config.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CardTemplateSettingDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    dao = CardTemplateSettingDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert and findByTemplateUuid roundtrip', () async {
    final now = DateTime.utc(2026, 1, 8, 2, 3, 4);
    final setting = CardTemplateSetting(
      createdAt: now,
      modifiedAt: now,
      deletedAt: null,
      templateUuid: 't1',
      showTitleColumn: false,
      showInCellTitleGlobal: true,
      showInCellTitleByRowType: const {
        RowType.tenGod: true,
        RowType.naYin: false,
      },
      activeColorMode: ColorPreviewMode.blackwhite,
      overridesBySkillId: const {
        1: CardTemplateSettingOverride(
          showTitleColumn: true,
          activeColorMode: ColorPreviewMode.colorful,
        ),
      },
    );

    await dao.upsert(setting);

    final loaded = await dao.findByTemplateUuid('t1');
    expect(loaded, isNotNull);
    expect(loaded!.templateUuid, equals('t1'));
    expect(loaded.createdAt.toUtc(), equals(now));
    expect(loaded.modifiedAt.toUtc(), equals(now));
    expect(loaded.deletedAt, isNull);
    expect(loaded.showTitleColumn, isFalse);
    expect(loaded.showInCellTitleGlobal, isTrue);
    expect(loaded.showInCellTitleByRowType?[RowType.tenGod], isTrue);
    expect(loaded.showInCellTitleByRowType?[RowType.naYin], isFalse);
    expect(loaded.activeColorMode, equals(ColorPreviewMode.blackwhite));
    expect(loaded.overridesBySkillId?[1]?.showTitleColumn, isTrue);
  });

  test('softDelete marks row deleted', () async {
    final now = DateTime.utc(2026, 1, 8, 2, 3, 4);
    final setting = CardTemplateSetting(
      createdAt: now,
      modifiedAt: now,
      deletedAt: null,
      templateUuid: 't2',
    );

    await dao.upsert(setting);
    final deletedCount = await dao.softDelete(templateUuid: 't2');
    expect(deletedCount, equals(1));

    final loaded = await dao.findByTemplateUuid('t2');
    expect(loaded, isNull);
  });
}

