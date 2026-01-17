import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/layout_template_dto.dart';

import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/layout_templates_dao.dart';
import '../models/layout_template.dart';

class LayoutTemplateLocalDataSource implements LocalApplier {
  LayoutTemplateLocalDataSource(
    this._db, {
    OutboxStore? outboxStore,
    SyncLogger? logger,
  })  : _dao = LayoutTemplatesDao(_db),
        _metaDao = CardTemplateMetaDao(_db),
        _outboxStore = outboxStore,
        _logger = logger ?? SyncLogger.noop();

  final AppDatabase _db;
  final LayoutTemplatesDao _dao;
  final CardTemplateMetaDao _metaDao;
  final OutboxStore? _outboxStore;
  final SyncLogger _logger;

  static const _entityTypeLayoutTemplate = 'layout_template';
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';
  static const _payloadSchemaVersion = 1;

  Future<LayoutTemplateRow?> readAnyLocalRow(
    String collectionId,
    String templateId,
  ) {
    return (_db.select(_db.layoutTemplates)
          ..where(
            (t) =>
                t.collectionId.equals(collectionId) & t.uuid.equals(templateId),
          ))
        .getSingleOrNull();
  }

  Future<List<LayoutTemplateDto>> loadTemplates(String collectionId) async {
    final rows = await _dao.getAllByCollection(collectionId);
    return rows
        .map((row) => jsonDecode(row.templateJson))
        .whereType<Map<String, dynamic>>()
        .map(LayoutTemplateDto.fromJson)
        .toList(growable: false);
  }

  Future<void> upsertTemplate(
    LayoutTemplate template, {
    bool enqueueOutbox = false,
    String? scopeUid,
    bool? isCustomized,
  }) async {
    await _db.transaction(() async {
      await _dao.upsertTemplate(template);
      await _metaDao.touchModifiedAt(
        templateUuid: template.id,
        modifiedAt: template.updatedAt,
        isCustomized: isCustomized,
      );
    });

    if (!enqueueOutbox) return;

    final resolvedScopeUid = scopeUid;
    if (resolvedScopeUid == null || resolvedScopeUid.isEmpty) {
      throw StateError('scopeUid is required when enqueueOutbox is true');
    }

    final store = _outboxStore;
    if (store == null) {
      throw StateError('OutboxStore is required when enqueueOutbox is true');
    }

    final nowUtc = DateTime.now().toUtc();
    final operationId = const Uuid().v4();
    final payloadJson = jsonEncode({
      'schemaVersion': _payloadSchemaVersion,
      'entityType': _entityTypeLayoutTemplate,
      'entityId': template.id,
      'collectionId': template.collectionId,
      'name': template.name,
      'description': template.description,
      'template': template.toJson(),
      'version': template.version,
      'clientUpdatedAt': template.updatedAt.toUtc().toIso8601String(),
      'deletedAt': null,
    });

    await store.enqueue(
      OutboxRecord(
        operationId: operationId,
        scopeUid: resolvedScopeUid,
        entityType: _entityTypeLayoutTemplate,
        entityId: template.id,
        opType: _opTypeUpsert,
        payloadJson: payloadJson,
        createdAtUtc: nowUtc,
        attempt: 0,
      ),
    );
  }

  Future<void> softDeleteTemplate(
    String collectionId,
    String templateId, {
    bool enqueueOutbox = false,
    String? scopeUid,
  }) async {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final operationId = const Uuid().v4();

    String? payloadJson;

    await _db.transaction(() async {
      final existing = await _dao.getById(collectionId, templateId);
      await _dao.softDeleteByIdAt(collectionId, templateId, now);

      if (!enqueueOutbox) return;

      final decodedTemplate = existing == null
          ? null
          : jsonDecode(existing.templateJson) as Object?;

      payloadJson = jsonEncode({
        'schemaVersion': _payloadSchemaVersion,
        'entityType': _entityTypeLayoutTemplate,
        'entityId': templateId,
        'collectionId': collectionId,
        'name': existing?.name,
        'description': existing?.description,
        'template': decodedTemplate,
        'version': existing?.version,
        'clientUpdatedAt': nowUtc.toIso8601String(),
        'deletedAt': nowUtc.toIso8601String(),
      });
    });

    if (!enqueueOutbox) return;

    final resolvedScopeUid = scopeUid;
    if (resolvedScopeUid == null || resolvedScopeUid.isEmpty) {
      throw StateError('scopeUid is required when enqueueOutbox is true');
    }

    final store = _outboxStore;
    if (store == null) {
      throw StateError('OutboxStore is required when enqueueOutbox is true');
    }

    final resolvedPayload = payloadJson;
    if (resolvedPayload == null) {
      throw StateError('payloadJson must be set when enqueueOutbox is true');
    }

    await store.enqueue(
      OutboxRecord(
        operationId: operationId,
        scopeUid: resolvedScopeUid,
        entityType: _entityTypeLayoutTemplate,
        entityId: templateId,
        opType: _opTypeSoftDelete,
        payloadJson: resolvedPayload,
        createdAtUtc: nowUtc,
        attempt: 0,
      ),
    );
  }

  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    _logger.debug(
      'layout_template_apply_start',
      data: <String, Object?>{
        'scopeUid': scopeUid,
        'entityType': entityType,
        'changes': changes.length,
      },
    );

    if (entityType != _entityTypeLayoutTemplate) {
      final err = SyncError(
        code: SyncErrorCode.invalidData,
        message: 'unsupported entityType: $entityType',
      );
      _logger.warn(
        'layout_template_apply_unsupported_entity',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'entityType': entityType,
        },
        error: err,
      );
      return LocalApplyResult(
        canAdvanceCursor: false,
        appliedCount: 0,
        outcomes: const [],
        lastError: err,
      );
    }

    if (changes.isEmpty) {
      return const LocalApplyResult(
        canAdvanceCursor: true,
        appliedCount: 0,
        outcomes: [],
        lastError: null,
      );
    }

    final outcomes = <ChangeApplyOutcome>[];
    var appliedCount = 0;

    Future<LayoutTemplateRow?> readAnyLocalRow(
      String collectionId,
      String templateId,
    ) {
      return (_db.select(_db.layoutTemplates)
            ..where(
              (t) =>
                  t.collectionId.equals(collectionId) & t.uuid.equals(templateId),
            ))
          .getSingleOrNull();
    }

    DateTime? parseUtc(Object? value) {
      if (value is! String) return null;
      final parsed = DateTime.tryParse(value);
      return parsed?.toUtc();
    }

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          Object? decoded;
          try {
            decoded = jsonDecode(change.payloadJson);
          } catch (_) {
            outcomes.add(
              ChangeApplyOutcome(
                operationId: change.operationId,
                entityType: change.entityType,
                entityId: change.entityId,
                decision: ChangeApplyDecision.skipped,
                reason: SkipReasonCode.invalidPayload,
                message: 'payloadJson is not valid json',
              ),
            );
            continue;
          }

          if (decoded is! Map) {
            outcomes.add(
              ChangeApplyOutcome(
                operationId: change.operationId,
                entityType: change.entityType,
                entityId: change.entityId,
                decision: ChangeApplyDecision.skipped,
                reason: SkipReasonCode.invalidPayload,
                message: 'payloadJson must be a map',
              ),
            );
            continue;
          }

          final payload = Map<String, Object?>.from(decoded as Map);
          final collectionId = payload['collectionId'];
          if (collectionId is! String || collectionId.isEmpty) {
            outcomes.add(
              ChangeApplyOutcome(
                operationId: change.operationId,
                entityType: change.entityType,
                entityId: change.entityId,
                decision: ChangeApplyDecision.skipped,
                reason: SkipReasonCode.invalidPayload,
                message: 'missing collectionId',
              ),
            );
            continue;
          }

          final localRow = await readAnyLocalRow(collectionId, change.entityId);

          if (change.opType == _opTypeUpsert) {
            final templateObj = payload['template'];
            if (templateObj is! Map) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'upsert requires template',
                ),
              );
              continue;
            }

            LayoutTemplate remoteTemplate;
            try {
              remoteTemplate = LayoutTemplate.fromJson(
                Map<String, dynamic>.from(templateObj as Map),
              );
            } catch (e) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'template parse failed: $e',
                ),
              );
              continue;
            }

            final remoteAt = remoteTemplate.updatedAt.toUtc();

            if (localRow != null) {
              final localDeletedAt = localRow.deletedAt?.toUtc();
              if (localDeletedAt != null && localDeletedAt.isAfter(remoteAt)) {
                outcomes.add(
                  ChangeApplyOutcome(
                    operationId: change.operationId,
                    entityType: change.entityType,
                    entityId: change.entityId,
                    decision: ChangeApplyDecision.skipped,
                    reason: SkipReasonCode.conflictLwwLost,
                    message: null,
                  ),
                );
                continue;
              }

              final localUpdatedAt = localRow.updatedAt.toUtc();
              if (localUpdatedAt.isAfter(remoteAt)) {
                outcomes.add(
                  ChangeApplyOutcome(
                    operationId: change.operationId,
                    entityType: change.entityType,
                    entityId: change.entityId,
                    decision: ChangeApplyDecision.skipped,
                    reason: SkipReasonCode.olderThanLocal,
                    message: null,
                  ),
                );
                continue;
              }
            }

            await _dao.upsertTemplate(remoteTemplate);
            await _metaDao.touchModifiedAt(
              templateUuid: remoteTemplate.id,
              modifiedAt: remoteTemplate.updatedAt,
            );

            appliedCount += 1;
            outcomes.add(
              ChangeApplyOutcome(
                operationId: change.operationId,
                entityType: change.entityType,
                entityId: change.entityId,
                decision: ChangeApplyDecision.applied,
                reason: null,
                message: null,
              ),
            );
            continue;
          }

          if (change.opType == _opTypeSoftDelete) {
            final deletedAt =
                parseUtc(payload['deletedAt']) ?? change.serverTimeUtc?.toUtc();
            final remoteDeletedAt =
                deletedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            if (localRow == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.alreadyApplied,
                  message: null,
                ),
              );
              continue;
            }

            final localDeletedAt = localRow.deletedAt?.toUtc();
            if (localDeletedAt != null) {
              if (!localDeletedAt.isBefore(remoteDeletedAt)) {
                outcomes.add(
                  ChangeApplyOutcome(
                    operationId: change.operationId,
                    entityType: change.entityType,
                    entityId: change.entityId,
                    decision: ChangeApplyDecision.skipped,
                    reason: SkipReasonCode.alreadyApplied,
                    message: null,
                  ),
                );
                continue;
              }
            } else {
              final localUpdatedAt = localRow.updatedAt.toUtc();
              if (localUpdatedAt.isAfter(remoteDeletedAt)) {
                outcomes.add(
                  ChangeApplyOutcome(
                    operationId: change.operationId,
                    entityType: change.entityType,
                    entityId: change.entityId,
                    decision: ChangeApplyDecision.skipped,
                    reason: SkipReasonCode.conflictLwwLost,
                    message: null,
                  ),
                );
                continue;
              }
            }

            await _dao.softDeleteByIdAt(
              collectionId,
              change.entityId,
              remoteDeletedAt.toLocal(),
            );

            appliedCount += 1;
            outcomes.add(
              ChangeApplyOutcome(
                operationId: change.operationId,
                entityType: change.entityType,
                entityId: change.entityId,
                decision: ChangeApplyDecision.applied,
                reason: null,
                message: null,
              ),
            );
            continue;
          }

          outcomes.add(
            ChangeApplyOutcome(
              operationId: change.operationId,
              entityType: change.entityType,
              entityId: change.entityId,
              decision: ChangeApplyDecision.skipped,
              reason: SkipReasonCode.invalidPayload,
              message: 'unknown opType: ${change.opType}',
            ),
          );
        }
      });

      var skipped = 0;
      for (final o in outcomes) {
        if (o.decision == ChangeApplyDecision.skipped) skipped += 1;
      }

      _logger.info(
        'layout_template_apply_ok',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'changes': changes.length,
          'applied': appliedCount,
          'skipped': skipped,
        },
      );

      return LocalApplyResult(
        canAdvanceCursor: true,
        appliedCount: appliedCount,
        outcomes: outcomes,
        lastError: null,
      );
    } catch (e, st) {
      final err = SyncError(code: SyncErrorCode.unknown, message: '$e');
      _logger.error(
        'layout_template_apply_error',
        data: <String, Object?>{
          'scopeUid': scopeUid,
          'changes': changes.length,
          'applied': appliedCount,
        },
        error: e,
        stackTrace: st,
      );
      return LocalApplyResult(
        canAdvanceCursor: false,
        appliedCount: 0,
        outcomes: outcomes,
        lastError: err,
      );
    }
  }

  Future<void> persistTemplates(
    String collectionId,
    List<LayoutTemplateDto> templates,
  ) async {
    final domainTemplates =
        templates.map((dto) => dto.toDomain()).toList(growable: false);

    await _db.transaction(() async {
      await _dao.upsertAllTemplates(domainTemplates);
      for (final template in domainTemplates) {
        await _metaDao.touchModifiedAt(
          templateUuid: template.id,
          modifiedAt: template.updatedAt,
        );
      }
      await _dao.softDeleteMissing(
        collectionId,
        domainTemplates.map((t) => t.id).toSet(),
      );
    });
  }

  Future<void> removeCollection(String collectionId) async {
    await _dao.softDeleteByCollection(collectionId);
  }
}
