import 'dart:convert';
import 'dart:io';

import 'package:common/features/shared_card_template/market/market_dtos.dart';
import 'package:common/models/layout_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MarketTemplateSummaryDto fromJson', () {
    final dto = MarketTemplateSummaryDto.fromJson({
      'templateId': 't1',
      'latestVersionId': 'v2',
      'name': 'Theme A',
      'description': 'Desc',
      'authorId': 'u1',
      'authorName': 'Alice',
      'tags': ['dark', 'minimal'],
      'downloadCount': 12,
      'createdAtUtc': '2026-01-01T00:00:00.000Z',
      'updatedAtUtc': '2026-01-02T00:00:00.000Z',
    });

    expect(dto.templateId, 't1');
    expect(dto.latestVersionId, 'v2');
    expect(dto.tags, ['dark', 'minimal']);
    expect(dto.downloadCount, 12);
    expect(
        dto.createdAtUtc.toUtc().toIso8601String(), '2026-01-01T00:00:00.000Z');
  });

  test('MarketTemplatesPageDto fromJson', () {
    final page = MarketTemplatesPageDto.fromJson({
      'items': [
        {
          'templateId': 't1',
          'latestVersionId': 'v1',
          'name': 'Theme',
          'description': '',
          'authorId': 'u1',
          'authorName': 'A',
          'tags': [],
          'downloadCount': 0,
          'createdAtUtc': '2026-01-01T00:00:00.000Z',
          'updatedAtUtc': '2026-01-01T00:00:00.000Z',
        }
      ],
      'nextCursor': null,
      'hasMore': false,
    });

    expect(page.items, hasLength(1));
    expect(page.hasMore, isFalse);
  });

  test('MarketTemplatePayloadDto parses chinese blue porcelain payload', () {
    final raw =
        File('assets/templates/chinese/market_payload_blue_porcelain.json')
            .readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final payload = MarketTemplatePayloadDto.fromJson(json);

    expect(payload.schemaVersion, 1);
    expect(payload.templateId, 'tmpl_blue_porcelain');
    expect(payload.versionId, 'v1');
    expect(payload.layoutTemplate.template.name, '中国风·青花瓷');
    expect(
        payload.layoutTemplate.template.cardStyle.dividerColorHex, '#332563EB');
  });

  test('LayoutTemplate parses chinese blue porcelain outbox payload', () {
    final raw =
        File('assets/templates/chinese/outbox_payload_blue_porcelain.json')
            .readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final templateJson = json['template'] as Map<String, dynamic>;
    final template = LayoutTemplate.fromJson(templateJson);

    expect(template.name, '中国风·青花瓷');
    expect(template.cardStyle.globalFontColorHex, '#FF0F172A');
    expect(template.editableTheme, isNotNull);
  });

  test('MarketTemplatePayloadDto parses chinese bamboo green payload', () {
    final raw =
        File('assets/templates/chinese/market_payload_bamboo_green.json')
            .readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final payload = MarketTemplatePayloadDto.fromJson(json);

    expect(payload.schemaVersion, 1);
    expect(payload.templateId, 'tmpl_bamboo_green');
    expect(payload.versionId, 'v1');
    expect(payload.layoutTemplate.template.name, '中国风·竹影青');
    expect(
        payload.layoutTemplate.template.cardStyle.dividerColorHex, '#3331A36A');
  });

  test('LayoutTemplate parses chinese bamboo green outbox payload', () {
    final raw =
        File('assets/templates/chinese/outbox_payload_bamboo_green.json')
            .readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final templateJson = json['template'] as Map<String, dynamic>;
    final template = LayoutTemplate.fromJson(templateJson);

    expect(template.name, '中国风·竹影青');
    expect(template.cardStyle.globalFontColorHex, '#FF14532D');
    expect(template.editableTheme, isNotNull);
  });
}
