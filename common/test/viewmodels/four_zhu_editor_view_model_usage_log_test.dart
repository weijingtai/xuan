import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_skill_usage_dao.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/repositories/layout_template_repository.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class _FakeLayoutTemplateRepository implements LayoutTemplateRepository {
  _FakeLayoutTemplateRepository(this._templatesByCollection);

  final Map<String, List<LayoutTemplate>> _templatesByCollection;

  @override
  Future<void> deleteTemplate(String collectionId, String templateId) async {
    final list = _templatesByCollection[collectionId];
    if (list == null) return;
    list.removeWhere((t) => t.id == templateId);
  }

  @override
  Future<List<LayoutTemplate>> getAllTemplates(String collectionId) async {
    return List<LayoutTemplate>.of(
        _templatesByCollection[collectionId] ?? const []);
  }

  @override
  Future<LayoutTemplate?> getTemplateById(
    String collectionId,
    String templateId,
  ) async {
    final list = _templatesByCollection[collectionId] ?? const [];
    for (final t in list) {
      if (t.id == templateId) return t;
    }
    return null;
  }

  @override
  Future<void> saveTemplate(LayoutTemplate template) async {
    final list =
        _templatesByCollection.putIfAbsent(template.collectionId, () => []);
    final idx = list.indexWhere((t) => t.id == template.id);
    if (idx >= 0) {
      list[idx] = template;
    } else {
      list.add(template);
    }
  }
}

void main() {
  test('selectTemplate logs skill usage when context is set', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory(), false);
    addTearDown(() async {
      await db.close();
    });

    final usageDao = CardTemplateSkillUsageDao(db);
    final uuid = const Uuid();
    final now = DateTime.utc(2026, 1, 8, 2, 3, 4);

    LayoutTemplate makeTemplate({required String id}) {
      return LayoutTemplate(
        id: id,
        name: 't-$id',
        collectionId: 'c1',
        cardStyle: const CardStyle(
          dividerType: BorderType.none,
          dividerColorHex: '#00000000',
          dividerThickness: 1.0,
          globalFontFamily: 'NotoSansSC-Regular',
          globalFontSize: 14,
          globalFontColorHex: '#FF0F172A',
          contentPadding: EdgeInsets.zero,
        ),
        chartGroups: [
          ChartGroup(
            id: uuid.v4(),
            title: 'g',
            pillarOrder: const [
              PillarType.rowTitleColumn,
              PillarType.year,
              PillarType.month,
              PillarType.day,
              PillarType.hour,
            ],
          ),
        ],
        rowConfigs: const [],
        editableTheme: const {},
        updatedAt: now,
      );
    }

    final t1 = makeTemplate(id: 't1');
    final t2 = makeTemplate(id: 't2');

    final repo = _FakeLayoutTemplateRepository({
      'c1': [t1, t2],
    });

    final vm = FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repo),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repo),
      saveTemplateUseCase: SaveTemplateUseCase(repo),
      deleteTemplateUseCase: DeleteTemplateUseCase(repo),
      cardTemplateSkillUsageDao: usageDao,
    );

    vm.setUsageContext(queryUuid: 'q1', skillId: 4);
    await vm.initialize(collectionId: 'c1');

    await vm.selectTemplate('t2');

    final latest = await usageDao.findLatestByQueryAndSkill(
      queryUuid: 'q1',
      skillId: 4,
    );

    expect(latest, isNotNull);
    expect(latest!.templateUuid, equals('t2'));
    expect(() => DateTime.parse(latest.usedAt), returnsNormally);
  });
}
