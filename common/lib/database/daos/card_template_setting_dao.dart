import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/card_template_setting.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'card_template_setting_dao.g.dart';

@DriftAccessor(tables: [CardTemplateSettings])
class CardTemplateSettingDao extends DatabaseAccessor<AppDatabase>
    with _$CardTemplateSettingDaoMixin {
  CardTemplateSettingDao(this.db) : super(db);

  final AppDatabase db;

  SimpleSelectStatement<$CardTemplateSettingsTable, CardTemplateSettingRecord>
      _baseSelect() {
    return select(db.cardTemplateSettings)
      ..where((t) => t.deletedAt.isNull());
  }

  Future<CardTemplateSetting?> findByTemplateUuid(String templateUuid) async {
    final row = await (_baseSelect()
          ..where((t) => t.templateUuid.equals(templateUuid)))
        .getSingleOrNull();
    if (row == null) return null;

    final decoded = jsonDecode(row.settingJson);
    if (decoded is! Map<String, dynamic>) return null;
    return CardTemplateSetting.fromJson(decoded);
  }

  Future<void> upsert(CardTemplateSetting setting) async {
    final encoded = jsonEncode(setting.toJson());

    final updated = await (update(db.cardTemplateSettings)
          ..where((t) => t.templateUuid.equals(setting.templateUuid)))
        .write(
      CardTemplateSettingsCompanion(
        createdAt: Value(setting.createdAt),
        modifiedAt: Value(setting.modifiedAt),
        deletedAt: const Value(null),
        settingJson: Value(encoded),
      ),
    );

    if (updated > 0) return;

    await into(db.cardTemplateSettings).insert(
      CardTemplateSettingsCompanion.insert(
        templateUuid: setting.templateUuid,
        createdAt: setting.createdAt,
        modifiedAt: setting.modifiedAt,
        deletedAt: const Value(null),
        settingJson: encoded,
      ),
    );
  }

  Future<int> softDelete({required String templateUuid}) {
    final now = DateTime.now();
    return (update(db.cardTemplateSettings)
          ..where((t) => t.templateUuid.equals(templateUuid)))
        .write(
      CardTemplateSettingsCompanion(
        modifiedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
  }
}

