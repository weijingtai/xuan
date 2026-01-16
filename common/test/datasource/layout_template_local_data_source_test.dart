import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/layout_template_dto.dart';
import 'package:common/models/text_style_config.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  const collectionId = 'test-collection';

  late AppDatabase db;
  late LayoutTemplateLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    dataSource = LayoutTemplateLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
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
          textStyleConfig: TextStyleConfig.defaultConfig,
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

    test('upsertTemplate enqueues outbox record when enabled', () async {
      final template = buildTemplate();
      final outbox = _RecordingOutboxStore();
      final dataSourceWithOutbox = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outbox,
      );

      await dataSourceWithOutbox.upsertTemplate(
        template,
        enqueueOutbox: true,
        scopeUid: collectionId,
      );

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, hasLength(1));

      expect(outbox.enqueued, hasLength(1));
      final record = outbox.enqueued.single;
      expect(record.entityType, equals('layout_template'));
      expect(record.entityId, equals(template.id));
      expect(record.opType, equals('upsert'));
      expect(record.payloadJson, isNotEmpty);
    });

    test('softDeleteTemplate enqueues outbox record when enabled', () async {
      final template = buildTemplate();
      final outbox = _RecordingOutboxStore();
      final dataSourceWithOutbox = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outbox,
      );

      await dataSource.upsertTemplate(
        template,
        enqueueOutbox: false,
      );
      await dataSourceWithOutbox.softDeleteTemplate(
        collectionId,
        template.id,
        enqueueOutbox: true,
        scopeUid: collectionId,
      );

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, isEmpty);

      expect(outbox.enqueued, hasLength(1));
      final record = outbox.enqueued.single;
      expect(record.entityType, equals('layout_template'));
      expect(record.entityId, equals(template.id));
      expect(record.opType, equals('softDelete'));
      expect(record.payloadJson, isNotEmpty);
    });

    test('applyRemoteChanges upserts without enqueuing outbox', () async {
      final template = buildTemplate(id: 't1');
      final serverAt = DateTime.utc(2026, 1, 10, 12, 0, 0);

      final outbox = _RecordingOutboxStore();
      final dataSourceWithOutbox = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outbox,
      );

      final change = RemoteChange(
        operationId: 'op1',
        entityType: 'layout_template',
        entityId: template.id,
        opType: 'upsert',
        cursor:
            TimestampCursor(serverUpdatedAtUtc: serverAt, tieBreaker: 'op1'),
        payloadJson: jsonEncode({
          'schemaVersion': 1,
          'entityType': 'layout_template',
          'entityId': template.id,
          'collectionId': collectionId,
          'name': template.name,
          'description': template.description,
          'template': template.toJson(),
          'version': template.version,
          'clientUpdatedAt': template.updatedAt.toUtc().toIso8601String(),
          'deletedAt': null,
        }),
        serverTimeUtc: serverAt,
      );

      final result = await dataSourceWithOutbox.applyRemoteChanges(
        scopeUid: 'u1',
        entityType: 'layout_template',
        changes: [change],
      );

      expect(result.lastError, isNull);
      expect(result.canAdvanceCursor, isTrue);
      expect(result.appliedCount, equals(1));
      expect(
          result.outcomes.single.decision, equals(ChangeApplyDecision.applied));

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, hasLength(1));
      expect(stored.single.template, equals(template));

      expect(outbox.enqueued, isEmpty);
    });

    test('applyRemoteChanges skips upsert when local is newer (LWW)', () async {
      final remote = buildTemplate(id: 't1').copyWith(
        name: 'Remote',
        updatedAt: DateTime.utc(2024, 1, 1, 0, 0, 0),
      );
      final local = remote.copyWith(
        name: 'Local',
        updatedAt: DateTime.utc(2024, 1, 2, 0, 0, 0),
      );

      final outbox = _RecordingOutboxStore();
      final dataSourceWithOutbox = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outbox,
      );

      await dataSource.upsertTemplate(local, enqueueOutbox: false);

      final serverAt = DateTime.utc(2026, 1, 10, 12, 0, 0);
      final change = RemoteChange(
        operationId: 'op1',
        entityType: 'layout_template',
        entityId: remote.id,
        opType: 'upsert',
        cursor:
            TimestampCursor(serverUpdatedAtUtc: serverAt, tieBreaker: 'op1'),
        payloadJson: jsonEncode({
          'schemaVersion': 1,
          'entityType': 'layout_template',
          'entityId': remote.id,
          'collectionId': collectionId,
          'name': remote.name,
          'description': remote.description,
          'template': remote.toJson(),
          'version': remote.version,
          'clientUpdatedAt': remote.updatedAt.toUtc().toIso8601String(),
          'deletedAt': null,
        }),
        serverTimeUtc: serverAt,
      );

      final result = await dataSourceWithOutbox.applyRemoteChanges(
        scopeUid: 'u1',
        entityType: 'layout_template',
        changes: [change],
      );

      expect(result.lastError, isNull);
      expect(result.canAdvanceCursor, isTrue);
      expect(result.appliedCount, equals(0));
      expect(
          result.outcomes.single.decision, equals(ChangeApplyDecision.skipped));
      expect(
          result.outcomes.single.reason, equals(SkipReasonCode.olderThanLocal));

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored.single.template.name, equals('Local'));
      expect(stored.single.template.updatedAt.toUtc(),
          equals(local.updatedAt.toUtc()));

      expect(outbox.enqueued, isEmpty);
    });

    test(
        'applyRemoteChanges applies remote softDelete without enqueuing outbox',
        () async {
      final template = buildTemplate(id: 't1');
      await dataSource.upsertTemplate(template, enqueueOutbox: false);

      final outbox = _RecordingOutboxStore();
      final dataSourceWithOutbox = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outbox,
      );

      final deletedAt = DateTime.utc(2026, 1, 10, 13, 0, 0);
      final change = RemoteChange(
        operationId: 'op2',
        entityType: 'layout_template',
        entityId: template.id,
        opType: 'softDelete',
        cursor:
            TimestampCursor(serverUpdatedAtUtc: deletedAt, tieBreaker: 'op2'),
        payloadJson: jsonEncode({
          'schemaVersion': 1,
          'entityType': 'layout_template',
          'entityId': template.id,
          'collectionId': collectionId,
          'name': template.name,
          'description': template.description,
          'version': template.version,
          'clientUpdatedAt': deletedAt.toUtc().toIso8601String(),
          'deletedAt': deletedAt.toUtc().toIso8601String(),
        }),
        serverTimeUtc: deletedAt,
      );

      final result = await dataSourceWithOutbox.applyRemoteChanges(
        scopeUid: 'u1',
        entityType: 'layout_template',
        changes: [change],
      );

      expect(result.lastError, isNull);
      expect(result.canAdvanceCursor, isTrue);
      expect(result.appliedCount, equals(1));
      expect(
          result.outcomes.single.decision, equals(ChangeApplyDecision.applied));

      final stored = await dataSource.loadTemplates(collectionId);
      expect(stored, isEmpty);

      expect(outbox.enqueued, isEmpty);
    });
  });
}

class _RecordingOutboxStore implements OutboxStore {
  final List<OutboxRecord> enqueued = <OutboxRecord>[];
  final Map<String, StreamController<int>> _backlogControllersByScopeUid =
      <String, StreamController<int>>{};

  StreamController<int> _controllerFor(String scopeUid) {
    return _backlogControllersByScopeUid.putIfAbsent(
      scopeUid,
      () => StreamController<int>.broadcast(),
    );
  }

  Future<void> _emitBacklog(String scopeUid) async {
    if (!_backlogControllersByScopeUid.containsKey(scopeUid)) return;
    _controllerFor(scopeUid).add(await backlogCount(scopeUid));
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {
    enqueued.add(record);
    await _emitBacklog(record.scopeUid);
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    return enqueued.where((r) => r.scopeUid == scopeUid).take(limit).toList();
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {}

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {}

  @override
  Future<int> backlogCount(String scopeUid) async {
    return enqueued.where((r) => r.scopeUid == scopeUid).length;
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    return (() async* {
      yield await backlogCount(scopeUid);
      yield* _controllerFor(scopeUid).stream;
    })().distinct();
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    return 0;
  }
}
