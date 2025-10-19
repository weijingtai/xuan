import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/layout_template_dto.dart';

void main() {
  const dataSource = LayoutTemplateLocalDataSource();
  const collectionId = 'test-collection';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  LayoutTemplate buildTemplate({String id = 'template-1'}) {
    return LayoutTemplate(
      id: id,
      name: '模板',
      collectionId: collectionId,
      cardStyle: const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FF334155',
        dividerThickness: 1.0,
        globalFontFamily: 'NotoSans',
        globalFontSize: 14,
        globalFontColorHex: '#FF0F172A',
      ),
      chartGroups: [
        ChartGroup(
          id: 'group-1',
          title: '基础分组',
          pillarOrder: [PillarType.year, PillarType.month],
        ),
      ],
      rowConfigs: [
        RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
        ),
      ],
      version: 1,
      updatedAt: DateTime.utc(2024, 1, 1),
    );
  }

  group('LayoutTemplateLocalDataSource', () {
    test('returns empty list when nothing stored', () async {
      final templates = await dataSource.loadTemplates(collectionId);
      expect(templates, isEmpty);
    });

    test('persistTemplates stores templates as JSON payload', () async {
      final template = buildTemplate();

      await dataSource.persistTemplates(
        collectionId,
        [LayoutTemplateDto.fromDomain(template)],
      );

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, hasLength(1));
      expect(stored.first.template, equals(template));
    });

    test('removeCollection clears stored payload', () async {
      final template = buildTemplate();

      await dataSource.persistTemplates(
        collectionId,
        [LayoutTemplateDto.fromDomain(template)],
      );
      await dataSource.removeCollection(collectionId);

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, isEmpty);
    });
  });
}
