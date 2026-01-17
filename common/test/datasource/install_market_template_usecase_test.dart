import 'dart:async';

import 'package:common/database/app_database.dart';
import 'package:common/database/daos/market_template_installs_dao.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/features/shared_card_template/market/market_dtos.dart';
import 'package:common/features/shared_card_template/market/market_gateway.dart';
import 'package:common/features/shared_card_template/usecase/install_market_template_usecase.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/layout_template_dto.dart';
import 'package:common/models/text_style_config.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

class _FakeMarketGateway implements MarketGateway {
  _FakeMarketGateway(this._payload);

  final MarketTemplatePayloadDto _payload;

  @override
  Future<MarketTemplatePayloadDto> getTemplatePayload({
    required String templateId,
    required String versionId,
  }) async {
    return _payload;
  }

  @override
  Future<MarketTemplateDetailDto> getTemplateDetail({
    required String templateId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MarketTemplatesPageDto> listTemplates({
    String? cursor,
    int limit = 20,
    String? query,
    List<String>? tags,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MarketTemplateDetailDto> publishTemplate({
    required PublishMarketTemplateRequestDto request,
  }) {
    throw UnimplementedError();
  }
}

class _FixedScopeProvider implements AuthScopeProvider {
  _FixedScopeProvider(this._scopeUid);

  final String _scopeUid;

  @override
  Future<String> getScopeUid() async {
    return _scopeUid;
  }
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

void main() {
  late AppDatabase db;
  late LayoutTemplateLocalDataSource localDataSource;
  late MarketTemplateInstallsDao installsDao;
  late _RecordingOutboxStore outboxStore;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    outboxStore = _RecordingOutboxStore();
    localDataSource = LayoutTemplateLocalDataSource(db, outboxStore: outboxStore);
    installsDao = MarketTemplateInstallsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  LayoutTemplate buildTemplate({required String id, required String collectionId}) {
    return LayoutTemplate(
      id: id,
      name: 'Market Theme',
      description: 'From market',
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
      updatedAt: DateTime.utc(2024, 1, 1),
      version: 1,
    );
  }

  test('install stores local template and mapping', () async {
    const targetCollectionId = 'four_zhu_templates';
    final now = DateTime.utc(2026, 1, 15, 12, 0, 0);

    final remoteTemplate = buildTemplate(
      id: 'remote-template-uuid',
      collectionId: 'remote-collection',
    );

    final payload = MarketTemplatePayloadDto(
      schemaVersion: 1,
      templateId: 'mkt-1',
      versionId: 'ver-1',
      layoutTemplate: LayoutTemplateDto.fromDomain(remoteTemplate),
    );

    const scopeUid = 'u1';

    final useCase = InstallMarketTemplateUseCase(
      marketGateway: _FakeMarketGateway(payload),
      localDataSource: localDataSource,
      marketTemplateInstallsDao: installsDao,
      authScopeProvider: _FixedScopeProvider(scopeUid),
      now: () => now,
    );

    final installed = await useCase(
      collectionId: targetCollectionId,
      marketTemplateId: 'mkt-1',
      marketVersionId: 'ver-1',
    );

    expect(installed.collectionId, targetCollectionId);
    expect(installed.id, isNot(equals('remote-template-uuid')));
    expect(installed.updatedAt, now);

    final stored = await localDataSource.loadTemplates(targetCollectionId);
    expect(stored, hasLength(1));
    expect(stored.single.template.id, installed.id);

    final mapping = await installsDao.findByLocalTemplateUuid(installed.id);
    expect(mapping, isNotNull);
    expect(mapping!.marketTemplateId, equals('mkt-1'));
    expect(mapping.marketVersionId, equals('ver-1'));

    expect(outboxStore.enqueued, hasLength(1));
    final record = outboxStore.enqueued.single;
    expect(record.scopeUid, equals(scopeUid));
    expect(record.entityType, equals('layout_template'));
    expect(record.entityId, equals(installed.id));
    expect(record.opType, equals('upsert'));
    expect(record.payloadJson, isNotEmpty);
  });
}

