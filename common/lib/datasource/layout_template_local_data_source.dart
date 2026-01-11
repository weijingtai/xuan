import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/outbox_records_dao.dart';
import '../models/layout_template_dto.dart';
import '../persistence/outbox_pusher.dart';

import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/layout_templates_dao.dart';
import '../models/layout_template.dart';

class LayoutTemplateLocalDataSource {
  LayoutTemplateLocalDataSource(this._db)
      : _dao = LayoutTemplatesDao(_db),
        _metaDao = CardTemplateMetaDao(_db),
        _outboxDao = OutboxRecordsDao(_db);

  final AppDatabase _db;
  final LayoutTemplatesDao _dao;
  final CardTemplateMetaDao _metaDao;
  final OutboxRecordsDao _outboxDao;

  static const _entityTypeLayoutTemplate = 'layout_template';
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';
  static const _payloadSchemaVersion = 1;

  static String _fnv1a64Hex(String input) {
    const fnvOffset = 0xcbf29ce484222325;
    const fnvPrime = 0x100000001b3;
    var hash = fnvOffset;
    final bytes = utf8.encode(input);
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * fnvPrime) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

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
  }) async {
    final resolvedScopeUid = scopeUid ?? template.collectionId;
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
    final payloadHash = _fnv1a64Hex(payloadJson);

    await _db.transaction(() async {
      await _dao.upsertTemplate(template);
      await _metaDao.touchModifiedAt(
        templateUuid: template.id,
        modifiedAt: template.updatedAt,
      );
      if (!enqueueOutbox) return;
      await _outboxDao.enqueue(
        OutboxRecordsCompanion.insert(
          operationId: operationId,
          scopeUid: resolvedScopeUid,
          entityType: _entityTypeLayoutTemplate,
          entityId: template.id,
          opType: _opTypeUpsert,
          payloadJson: payloadJson,
          createdAtUtc: nowUtc,
          payloadSummary: Value(template.name),
          payloadHash: Value(payloadHash),
        ),
      );
    });
  }

  Future<void> softDeleteTemplate(
    String collectionId,
    String templateId, {
    bool enqueueOutbox = false,
    String? scopeUid,
  }) async {
    final resolvedScopeUid = scopeUid ?? collectionId;
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final operationId = const Uuid().v4();

    await _db.transaction(() async {
      final existing = await _dao.getById(collectionId, templateId);
      await _dao.softDeleteByIdAt(collectionId, templateId, now);

      if (!enqueueOutbox) return;

      final decodedTemplate = existing == null
          ? null
          : jsonDecode(existing.templateJson) as Object?;

      final payloadJson = jsonEncode({
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
      final payloadHash = _fnv1a64Hex(payloadJson);

      await _outboxDao.enqueue(
        OutboxRecordsCompanion.insert(
          operationId: operationId,
          scopeUid: resolvedScopeUid,
          entityType: _entityTypeLayoutTemplate,
          entityId: templateId,
          opType: _opTypeSoftDelete,
          payloadJson: payloadJson,
          createdAtUtc: nowUtc,
          payloadSummary: Value(existing?.name ?? templateId),
          payloadHash: Value(payloadHash),
        ),
      );
    });
  }

  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (entityType != _entityTypeLayoutTemplate) {
      return LocalApplyResult(
        canAdvanceCursor: false,
        appliedCount: 0,
        outcomes: const [],
        lastError: SyncError(
          code: SyncErrorCode.invalidData,
          message: 'unsupported entityType: $entityType',
        ),
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

      return LocalApplyResult(
        canAdvanceCursor: true,
        appliedCount: appliedCount,
        outcomes: outcomes,
        lastError: null,
      );
    } catch (e) {
      return LocalApplyResult(
        canAdvanceCursor: false,
        appliedCount: 0,
        outcomes: outcomes,
        lastError: SyncError(code: SyncErrorCode.unknown, message: '$e'),
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
