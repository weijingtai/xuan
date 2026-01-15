import 'dart:convert';

import 'package:common/database/app_database.dart' as db;
import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:common/datamodel/seeker_model.dart';
import 'package:common/datamodel/timing_divination_model.dart';
import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

class CompositeLocalApplier implements LocalApplier {
  CompositeLocalApplier(this._routes);

  final Map<String, LocalApplier> _routes;

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    final applier = _routes[entityType];
    if (applier == null) {
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
    return applier.applyRemoteChanges(
      scopeUid: scopeUid,
      entityType: entityType,
      changes: changes,
    );
  }
}

class DivinationLocalApplier implements LocalApplier {
  DivinationLocalApplier(this._db);

  final db.AppDatabase _db;

  static const _entityTypeDivination = 'divination';
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';

  Future<DivinationRequestInfoDataModel?> _readLocal(String uuid) {
    return (_db.select(_db.divinations)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  DivinationRequestInfoDataModel? _parseDivination(String payloadJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    Object? candidate = decoded;
    final wrapped = decoded['divination'];
    if (wrapped is Map) {
      candidate = wrapped;
    }

    if (candidate is! Map) return null;

    try {
      return DivinationRequestInfoDataModel.fromJson(
        Map<String, dynamic>.from(candidate),
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseUtc(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (entityType != _entityTypeDivination) {
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

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          if (change.opType == _opTypeUpsert) {
            final remote = _parseDivination(change.payloadJson);
            if (remote == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'divination parse failed',
                ),
              );
              continue;
            }

            if (remote.uuid != change.entityId) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'entityId mismatch',
                ),
              );
              continue;
            }

            final remoteUpdatedAt = remote.lastUpdatedAt?.toUtc();
            if (remoteUpdatedAt == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing lastUpdatedAt',
                ),
              );
              continue;
            }

            final local = await _readLocal(change.entityId);
            if (local != null) {
              final localDeletedAt = local.deletedAt?.toUtc();
              if (localDeletedAt != null &&
                  localDeletedAt.isAfter(remoteUpdatedAt)) {
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

              final localUpdatedAt =
                  local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
              if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
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

            final companion = db.DivinationsCompanion(
              uuid: Value(remote.uuid),
              createdAt: Value(remote.createdAt),
              lastUpdatedAt: Value(remote.lastUpdatedAt!),
              deletedAt: Value(remote.deletedAt),
              divinationTypeUuid: Value(remote.divinationTypeUuid),
              fateYear: Value(remote.fateYear),
              question: Value(remote.question),
              detail: Value(remote.detail),
              ownerSeekerUuid: Value(remote.ownerSeekerUuid),
              gender: Value(remote.gender),
              seekerName: Value(remote.seekerName),
              tinyPredict: Value(remote.tinyPredict),
              directlyPredict: Value(remote.directlyPredict),
            );

            await _db.into(_db.divinations).insertOnConflictUpdate(companion);

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
            Object? decoded;
            try {
              decoded = jsonDecode(change.payloadJson);
            } catch (_) {
              decoded = null;
            }
            DateTime? deletedAtFromPayload;
            if (decoded is Map) {
              deletedAtFromPayload = _parseUtc(decoded['deletedAt']);
              final wrapped = decoded['divination'];
              if (deletedAtFromPayload == null && wrapped is Map) {
                deletedAtFromPayload = _parseUtc(wrapped['deletedAt']);
              }
            }
            final remoteDeletedAt = deletedAtFromPayload ??
                change.serverTimeUtc?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            final local = await _readLocal(change.entityId);
            if (local == null) {
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

            final localDeletedAt = local.deletedAt?.toUtc();
            if (localDeletedAt != null &&
                !localDeletedAt.isBefore(remoteDeletedAt)) {
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

            final localUpdatedAt =
                local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
            if (localDeletedAt == null &&
                localUpdatedAt.isAfter(remoteDeletedAt)) {
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

            await (_db.update(_db.divinations)
                  ..where((t) => t.uuid.equals(change.entityId)))
                .write(
              db.DivinationsCompanion(
                deletedAt: Value(remoteDeletedAt.toLocal()),
                lastUpdatedAt: Value(remoteDeletedAt.toLocal()),
              ),
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
}

class SeekerLocalApplier implements LocalApplier {
  SeekerLocalApplier(this._db);

  final db.AppDatabase _db;

  static const _entityTypeSeeker = 'seeker';
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';

  Future<SeekerModel?> _readLocal(String uuid) {
    return (_db.select(_db.seekers)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  SeekerModel? _parseSeeker(String payloadJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    Object? candidate = decoded;
    final wrapped = decoded['seeker'];
    if (wrapped is Map) {
      candidate = wrapped;
    }

    if (candidate is! Map) return null;

    try {
      return SeekerModel.fromJson(Map<String, dynamic>.from(candidate));
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseUtc(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (entityType != _entityTypeSeeker) {
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

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          if (change.opType == _opTypeUpsert) {
            final remote = _parseSeeker(change.payloadJson);
            if (remote == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'seeker parse failed',
                ),
              );
              continue;
            }

            if (remote.uuid != change.entityId) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'entityId mismatch',
                ),
              );
              continue;
            }

            final remoteDivinationUuid = remote.divinationUuid;
            if (remoteDivinationUuid == null || remoteDivinationUuid.isEmpty) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing divinationUuid',
                ),
              );
              continue;
            }

            final remoteUpdatedAt =
                remote.lastUpdatedAt?.toUtc() ?? remote.createdAt.toUtc();

            final local = await _readLocal(change.entityId);
            if (local != null) {
              final localDeletedAt = local.deletedAt?.toUtc();
              if (localDeletedAt != null &&
                  localDeletedAt.isAfter(remoteUpdatedAt)) {
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

              final localUpdatedAt =
                  local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
              if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
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

            final companion = db.SeekersCompanion(
              uuid: Value(remote.uuid),
              username: Value(remote.username),
              nickname: Value(remote.nickname),
              gender: Value(remote.gender),
              createdAt: Value(remote.createdAt),
              lastUpdatedAt: Value(remote.lastUpdatedAt),
              deletedAt: Value(remote.deletedAt),
              timingType: Value(remote.timingType),
              datetime: Value(remote.datetime),
              yearGanZhi: Value(remote.yearGanZhi),
              monthGanZhi: Value(remote.monthGanZhi),
              dayGanZhi: Value(remote.dayGanZhi),
              timeGanZhi: Value(remote.timeGanZhi),
              lunarMonth: Value(remote.lunarMonth),
              isLeapMonth: Value(remote.isLeapMonth),
              lunarDay: Value(remote.lunarDay),
              divinationUuid: Value(remoteDivinationUuid),
              timingInfoUuid: Value(remote.timingInfoUuid),
              timingInfoListJson: Value(remote.timingInfoListJson),
              location: Value(remote.location),
            );

            await _db.into(_db.seekers).insertOnConflictUpdate(companion);

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
            Object? decoded;
            try {
              decoded = jsonDecode(change.payloadJson);
            } catch (_) {
              decoded = null;
            }
            DateTime? deletedAtFromPayload;
            if (decoded is Map) {
              deletedAtFromPayload = _parseUtc(decoded['deletedAt']);
              final wrapped = decoded['seeker'];
              if (deletedAtFromPayload == null && wrapped is Map) {
                deletedAtFromPayload = _parseUtc(wrapped['deletedAt']);
              }
            }
            final remoteDeletedAt = deletedAtFromPayload ??
                change.serverTimeUtc?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            final local = await _readLocal(change.entityId);
            if (local == null) {
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

            final localDeletedAt = local.deletedAt?.toUtc();
            if (localDeletedAt != null &&
                !localDeletedAt.isBefore(remoteDeletedAt)) {
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

            final localUpdatedAt =
                local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
            if (localDeletedAt == null &&
                localUpdatedAt.isAfter(remoteDeletedAt)) {
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

            await (_db.update(_db.seekers)
                  ..where((t) => t.uuid.equals(change.entityId)))
                .write(
              db.SeekersCompanion(
                deletedAt: Value(remoteDeletedAt.toLocal()),
                lastUpdatedAt: Value(remoteDeletedAt.toLocal()),
              ),
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
}

class TimingDivinationLocalApplier implements LocalApplier {
  TimingDivinationLocalApplier(this._db);

  final db.AppDatabase _db;

  static const _entityTypeTimingDivination = 'timing_divination';
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';

  Future<TimingDivinationModel?> _readLocal(String uuid) {
    return (_db.select(_db.timingDivinations)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  TimingDivinationModel? _parseTiming(String payloadJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    Object? candidate = decoded;
    final wrapped = decoded['timingDivination'];
    if (wrapped is Map) {
      candidate = wrapped;
    }

    if (candidate is! Map) return null;

    try {
      return TimingDivinationModel.fromJson(
        Map<String, dynamic>.from(candidate),
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseUtc(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (entityType != _entityTypeTimingDivination) {
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

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          if (change.opType == _opTypeUpsert) {
            final remote = _parseTiming(change.payloadJson);
            if (remote == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'timingDivination parse failed',
                ),
              );
              continue;
            }

            if (remote.uuid != change.entityId) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'entityId mismatch',
                ),
              );
              continue;
            }

            final remoteDivinationUuid = remote.divinationUuid;
            if (remoteDivinationUuid == null || remoteDivinationUuid.isEmpty) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing divinationUuid',
                ),
              );
              continue;
            }

            final remoteTimingInfoUuid = remote.timingInfoUuid;
            if (remoteTimingInfoUuid == null || remoteTimingInfoUuid.isEmpty) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing timingInfoUuid',
                ),
              );
              continue;
            }

            final remoteUpdatedAt =
                remote.lastUpdatedAt?.toUtc() ?? remote.createdAt.toUtc();

            final local = await _readLocal(change.entityId);
            if (local != null) {
              final localDeletedAt = local.deletedAt?.toUtc();
              if (localDeletedAt != null &&
                  localDeletedAt.isAfter(remoteUpdatedAt)) {
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

              final localUpdatedAt =
                  local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
              if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
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

            final companion = db.TimingDivinationsCompanion(
              uuid: Value(remote.uuid),
              createdAt: Value(remote.createdAt),
              lastUpdatedAt: Value(remote.lastUpdatedAt),
              deletedAt: Value(remote.deletedAt),
              divinationUuid: Value(remoteDivinationUuid),
              timingType: Value(remote.timingType),
              datetime: Value(remote.datetime),
              isManual: Value(remote.isManual),
              yearGanZhi: Value(remote.yearGanZhi),
              monthGanZhi: Value(remote.monthGanZhi),
              dayGanZhi: Value(remote.dayGanZhi),
              timeGanZhi: Value(remote.timeGanZhi),
              lunarMonth: Value(remote.lunarMonth),
              isLeapMonth: Value(remote.isLeapMonth),
              lunarDay: Value(remote.lunarDay),
              timingInfoUuid: Value(remoteTimingInfoUuid),
              location: Value(remote.location),
              timingInfoListJson: Value(remote.timingInfoListJson),
            );

            await _db
                .into(_db.timingDivinations)
                .insertOnConflictUpdate(companion);

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
            Object? decoded;
            try {
              decoded = jsonDecode(change.payloadJson);
            } catch (_) {
              decoded = null;
            }
            DateTime? deletedAtFromPayload;
            if (decoded is Map) {
              deletedAtFromPayload = _parseUtc(decoded['deletedAt']);
              final wrapped = decoded['timingDivination'];
              if (deletedAtFromPayload == null && wrapped is Map) {
                deletedAtFromPayload = _parseUtc(wrapped['deletedAt']);
              }
            }
            final remoteDeletedAt = deletedAtFromPayload ??
                change.serverTimeUtc?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            final local = await _readLocal(change.entityId);
            if (local == null) {
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

            final localDeletedAt = local.deletedAt?.toUtc();
            if (localDeletedAt != null &&
                !localDeletedAt.isBefore(remoteDeletedAt)) {
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

            final localUpdatedAt =
                local.lastUpdatedAt?.toUtc() ?? local.createdAt.toUtc();
            if (localDeletedAt == null &&
                localUpdatedAt.isAfter(remoteDeletedAt)) {
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

            await (_db.update(_db.timingDivinations)
                  ..where((t) => t.uuid.equals(change.entityId)))
                .write(
              db.TimingDivinationsCompanion(
                deletedAt: Value(remoteDeletedAt.toLocal()),
                lastUpdatedAt: Value(remoteDeletedAt.toLocal()),
              ),
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
}

class SeekerDivinationMapperLocalApplier implements LocalApplier {
  SeekerDivinationMapperLocalApplier(this._db);

  final db.AppDatabase _db;

  static const _entityTypes = <String>{
    'seeker_divination_map',
    'seeker_divination_mapper',
  };
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';

  DateTime? _parseUtc(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }

  _SeekerDivinationMapperPayload? _parsePayload(String payloadJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    Object? candidate = decoded;
    final wrappedA = decoded['seekerDivinationMapper'];
    final wrappedB = decoded['seeker_divination_mapper'];
    if (wrappedA is Map) candidate = wrappedA;
    if (wrappedB is Map) candidate = wrappedB;
    if (candidate is! Map) return null;

    final seekerUuid = candidate['seekerUuid'];
    final divinationUuid = candidate['divinationUuid'];
    if (seekerUuid is! String || seekerUuid.isEmpty) return null;
    if (divinationUuid is! String || divinationUuid.isEmpty) return null;

    final createdAtUtc =
        _parseUtc(candidate['createdAt']) ?? _parseUtc(decoded['createdAt']);
    final lastUpdatedAtUtc = _parseUtc(candidate['lastUpdatedAt']) ??
        _parseUtc(candidate['updatedAt']) ??
        _parseUtc(decoded['lastUpdatedAt']) ??
        _parseUtc(decoded['updatedAt']);
    final deletedAtUtc =
        _parseUtc(candidate['deletedAt']) ?? _parseUtc(decoded['deletedAt']);

    final effectiveCreatedAtUtc = createdAtUtc ??
        lastUpdatedAtUtc ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final effectiveUpdatedAtUtc = lastUpdatedAtUtc ?? effectiveCreatedAtUtc;

    return _SeekerDivinationMapperPayload(
      seekerUuid: seekerUuid,
      divinationUuid: divinationUuid,
      createdAtUtc: effectiveCreatedAtUtc,
      lastUpdatedAtUtc: effectiveUpdatedAtUtc,
      deletedAtUtc: deletedAtUtc,
    );
  }

  Future<_LocalPairMax?> _readLocalMax({
    required String seekerUuid,
    required String divinationUuid,
  }) async {
    final rows = await (_db.select(_db.seekerDivinationMappers)
          ..where(
            (t) =>
                t.seekerUuid.equals(seekerUuid) &
                t.divinationUuid.equals(divinationUuid),
          ))
        .get();

    if (rows.isEmpty) return null;

    DateTime? maxUpdatedAtUtc;
    DateTime? maxDeletedAtUtc;

    for (final row in rows) {
      final updatedAtUtc = row.lastUpdatedAt.toUtc();
      if (maxUpdatedAtUtc == null || updatedAtUtc.isAfter(maxUpdatedAtUtc)) {
        maxUpdatedAtUtc = updatedAtUtc;
      }

      final deletedAt = row.deletedAt;
      if (deletedAt != null) {
        final deletedAtUtc = deletedAt.toUtc();
        if (maxDeletedAtUtc == null || deletedAtUtc.isAfter(maxDeletedAtUtc)) {
          maxDeletedAtUtc = deletedAtUtc;
        }
      }
    }

    return _LocalPairMax(
      maxUpdatedAtUtc: maxUpdatedAtUtc ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      maxDeletedAtUtc: maxDeletedAtUtc,
    );
  }

  List<String>? _parseEntityIdPair(String entityId) {
    final parts = entityId.split('|');
    if (parts.length != 2) return null;
    if (parts[0].isEmpty || parts[1].isEmpty) return null;
    return parts;
  }

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (!_entityTypes.contains(entityType)) {
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

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          if (change.opType == _opTypeUpsert) {
            final remote = _parsePayload(change.payloadJson);
            if (remote == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'seekerDivinationMapper parse failed',
                ),
              );
              continue;
            }

            final remoteUpdatedAtUtc = remote.lastUpdatedAtUtc;
            final localMax = await _readLocalMax(
              seekerUuid: remote.seekerUuid,
              divinationUuid: remote.divinationUuid,
            );
            if (localMax != null) {
              final localDeletedAtUtc = localMax.maxDeletedAtUtc;
              if (localDeletedAtUtc != null &&
                  localDeletedAtUtc.isAfter(remoteUpdatedAtUtc)) {
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

              if (localMax.maxUpdatedAtUtc.isAfter(remoteUpdatedAtUtc)) {
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

            final companion = db.SeekerDivinationMappersCompanion(
              seekerUuid: Value(remote.seekerUuid),
              divinationUuid: Value(remote.divinationUuid),
              createdAt: Value(remote.createdAtUtc.toLocal()),
              lastUpdatedAt: Value(remote.lastUpdatedAtUtc.toLocal()),
              deletedAt: Value(remote.deletedAtUtc?.toLocal()),
            );

            final updated = await (_db.update(_db.seekerDivinationMappers)
                  ..where(
                    (t) =>
                        t.seekerUuid.equals(remote.seekerUuid) &
                        t.divinationUuid.equals(remote.divinationUuid),
                  ))
                .write(companion);
            if (updated == 0) {
              await _db.into(_db.seekerDivinationMappers).insert(companion);
            }

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
            Object? decoded;
            try {
              decoded = jsonDecode(change.payloadJson);
            } catch (_) {
              decoded = null;
            }

            String? seekerUuid;
            String? divinationUuid;
            DateTime? deletedAtFromPayloadUtc;

            if (decoded is Map) {
              final wrappedA = decoded['seekerDivinationMapper'];
              final wrappedB = decoded['seeker_divination_mapper'];
              final candidate = (wrappedA is Map)
                  ? wrappedA
                  : (wrappedB is Map)
                      ? wrappedB
                      : decoded;

              final s = candidate['seekerUuid'];
              final d = candidate['divinationUuid'];
              if (s is String && s.isNotEmpty) seekerUuid = s;
              if (d is String && d.isNotEmpty) divinationUuid = d;

              deletedAtFromPayloadUtc = _parseUtc(candidate['deletedAt']) ??
                  _parseUtc(decoded['deletedAt']);
            }

            if (seekerUuid == null || divinationUuid == null) {
              final pair = _parseEntityIdPair(change.entityId);
              if (pair != null) {
                seekerUuid ??= pair[0];
                divinationUuid ??= pair[1];
              }
            }

            if (seekerUuid == null || divinationUuid == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing seekerUuid/divinationUuid',
                ),
              );
              continue;
            }

            final remoteDeletedAtUtc = deletedAtFromPayloadUtc ??
                change.serverTimeUtc?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            final localMax = await _readLocalMax(
              seekerUuid: seekerUuid!,
              divinationUuid: divinationUuid!,
            );
            if (localMax == null) {
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

            final localDeletedAtUtc = localMax.maxDeletedAtUtc;
            if (localDeletedAtUtc != null &&
                !localDeletedAtUtc.isBefore(remoteDeletedAtUtc)) {
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

            if (localDeletedAtUtc == null &&
                localMax.maxUpdatedAtUtc.isAfter(remoteDeletedAtUtc)) {
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

            await (_db.update(_db.seekerDivinationMappers)
                  ..where(
                    (t) =>
                        t.seekerUuid.equals(seekerUuid!) &
                        t.divinationUuid.equals(divinationUuid!),
                  ))
                .write(
              db.SeekerDivinationMappersCompanion(
                deletedAt: Value(remoteDeletedAtUtc.toLocal()),
                lastUpdatedAt: Value(remoteDeletedAtUtc.toLocal()),
              ),
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
}

class DivinationPanelMapperLocalApplier implements LocalApplier {
  DivinationPanelMapperLocalApplier(this._db);

  final db.AppDatabase _db;

  static const _entityTypes = <String>{
    'divination_panel_map',
    'divination_panel_mapper',
  };
  static const _opTypeUpsert = 'upsert';
  static const _opTypeSoftDelete = 'softDelete';

  DateTime? _parseUtc(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }

  _DivinationPanelMapperPayload? _parsePayload(
    String payloadJson, {
    required DateTime? fallbackTimeUtc,
  }) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    Object? candidate = decoded;
    final wrappedA = decoded['divinationPanelMapper'];
    final wrappedB = decoded['divination_panel_mapper'];
    if (wrappedA is Map) candidate = wrappedA;
    if (wrappedB is Map) candidate = wrappedB;
    if (candidate is! Map) return null;

    final divinationUuid = candidate['divinationUuid'];
    final panelUuid = candidate['panelUuid'];
    if (divinationUuid is! String || divinationUuid.isEmpty) return null;
    if (panelUuid is! String || panelUuid.isEmpty) return null;

    final createdAtUtc = _parseUtc(candidate['createdAt']) ??
        _parseUtc(decoded['createdAt']) ??
        fallbackTimeUtc;
    final deletedAtUtc =
        _parseUtc(candidate['deletedAt']) ?? _parseUtc(decoded['deletedAt']);

    final effectiveCreatedAtUtc =
        createdAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return _DivinationPanelMapperPayload(
      divinationUuid: divinationUuid,
      panelUuid: panelUuid,
      createdAtUtc: effectiveCreatedAtUtc,
      deletedAtUtc: deletedAtUtc,
    );
  }

  Future<_LocalPairMax?> _readLocalMax({
    required String divinationUuid,
    required String panelUuid,
  }) async {
    final rows = await (_db.select(_db.divinationPanelMappers)
          ..where(
            (t) =>
                t.divinationUuid.equals(divinationUuid) &
                t.panelUuid.equals(panelUuid),
          ))
        .get();
    if (rows.isEmpty) return null;

    DateTime? maxUpdatedAtUtc;
    DateTime? maxDeletedAtUtc;
    for (final row in rows) {
      final updatedAtUtc = row.createdAt.toUtc();
      if (maxUpdatedAtUtc == null || updatedAtUtc.isAfter(maxUpdatedAtUtc)) {
        maxUpdatedAtUtc = updatedAtUtc;
      }

      final deletedAt = row.deletedAt;
      if (deletedAt != null) {
        final deletedAtUtc = deletedAt.toUtc();
        if (maxDeletedAtUtc == null || deletedAtUtc.isAfter(maxDeletedAtUtc)) {
          maxDeletedAtUtc = deletedAtUtc;
        }
      }
    }

    return _LocalPairMax(
      maxUpdatedAtUtc: maxUpdatedAtUtc ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      maxDeletedAtUtc: maxDeletedAtUtc,
    );
  }

  List<String>? _parseEntityIdPair(String entityId) {
    final parts = entityId.split('|');
    if (parts.length != 2) return null;
    if (parts[0].isEmpty || parts[1].isEmpty) return null;
    return parts;
  }

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    if (!_entityTypes.contains(entityType)) {
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

    try {
      await _db.transaction(() async {
        for (final change in changes) {
          if (change.opType == _opTypeUpsert) {
            final remote = _parsePayload(
              change.payloadJson,
              fallbackTimeUtc: change.serverTimeUtc?.toUtc(),
            );
            if (remote == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'divinationPanelMapper parse failed',
                ),
              );
              continue;
            }

            final remoteUpdatedAtUtc = remote.createdAtUtc;
            final localMax = await _readLocalMax(
              divinationUuid: remote.divinationUuid,
              panelUuid: remote.panelUuid,
            );
            if (localMax != null) {
              final localDeletedAtUtc = localMax.maxDeletedAtUtc;
              if (localDeletedAtUtc != null &&
                  localDeletedAtUtc.isAfter(remoteUpdatedAtUtc)) {
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

              if (localMax.maxUpdatedAtUtc.isAfter(remoteUpdatedAtUtc)) {
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

            final companion = db.DivinationPanelMappersCompanion(
              divinationUuid: Value(remote.divinationUuid),
              panelUuid: Value(remote.panelUuid),
              createdAt: Value(remote.createdAtUtc.toLocal()),
              deletedAt: Value(remote.deletedAtUtc?.toLocal()),
            );

            final updated = await (_db.update(_db.divinationPanelMappers)
                  ..where(
                    (t) =>
                        t.divinationUuid.equals(remote.divinationUuid) &
                        t.panelUuid.equals(remote.panelUuid),
                  ))
                .write(companion);
            if (updated == 0) {
              await _db.into(_db.divinationPanelMappers).insert(companion);
            }

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
            Object? decoded;
            try {
              decoded = jsonDecode(change.payloadJson);
            } catch (_) {
              decoded = null;
            }

            String? divinationUuid;
            String? panelUuid;
            DateTime? deletedAtFromPayloadUtc;

            if (decoded is Map) {
              final wrappedA = decoded['divinationPanelMapper'];
              final wrappedB = decoded['divination_panel_mapper'];
              final candidate = (wrappedA is Map)
                  ? wrappedA
                  : (wrappedB is Map)
                      ? wrappedB
                      : decoded;

              final d = candidate['divinationUuid'];
              final p = candidate['panelUuid'];
              if (d is String && d.isNotEmpty) divinationUuid = d;
              if (p is String && p.isNotEmpty) panelUuid = p;

              deletedAtFromPayloadUtc = _parseUtc(candidate['deletedAt']) ??
                  _parseUtc(decoded['deletedAt']);
            }

            if (divinationUuid == null || panelUuid == null) {
              final pair = _parseEntityIdPair(change.entityId);
              if (pair != null) {
                divinationUuid ??= pair[0];
                panelUuid ??= pair[1];
              }
            }

            if (divinationUuid == null || panelUuid == null) {
              outcomes.add(
                ChangeApplyOutcome(
                  operationId: change.operationId,
                  entityType: change.entityType,
                  entityId: change.entityId,
                  decision: ChangeApplyDecision.skipped,
                  reason: SkipReasonCode.invalidPayload,
                  message: 'missing divinationUuid/panelUuid',
                ),
              );
              continue;
            }

            final remoteDeletedAtUtc = deletedAtFromPayloadUtc ??
                change.serverTimeUtc?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

            final localMax = await _readLocalMax(
              divinationUuid: divinationUuid!,
              panelUuid: panelUuid!,
            );
            if (localMax == null) {
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

            final localDeletedAtUtc = localMax.maxDeletedAtUtc;
            if (localDeletedAtUtc != null &&
                !localDeletedAtUtc.isBefore(remoteDeletedAtUtc)) {
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

            if (localDeletedAtUtc == null &&
                localMax.maxUpdatedAtUtc.isAfter(remoteDeletedAtUtc)) {
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

            await (_db.update(_db.divinationPanelMappers)
                  ..where(
                    (t) =>
                        t.divinationUuid.equals(divinationUuid!) &
                        t.panelUuid.equals(panelUuid!),
                  ))
                .write(
              db.DivinationPanelMappersCompanion(
                deletedAt: Value(remoteDeletedAtUtc.toLocal()),
              ),
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
}

class _LocalPairMax {
  const _LocalPairMax({
    required this.maxUpdatedAtUtc,
    required this.maxDeletedAtUtc,
  });

  final DateTime maxUpdatedAtUtc;
  final DateTime? maxDeletedAtUtc;
}

class _SeekerDivinationMapperPayload {
  const _SeekerDivinationMapperPayload({
    required this.seekerUuid,
    required this.divinationUuid,
    required this.createdAtUtc,
    required this.lastUpdatedAtUtc,
    required this.deletedAtUtc,
  });

  final String seekerUuid;
  final String divinationUuid;
  final DateTime createdAtUtc;
  final DateTime lastUpdatedAtUtc;
  final DateTime? deletedAtUtc;
}

class _DivinationPanelMapperPayload {
  const _DivinationPanelMapperPayload({
    required this.divinationUuid,
    required this.panelUuid,
    required this.createdAtUtc,
    required this.deletedAtUtc,
  });

  final String divinationUuid;
  final String panelUuid;
  final DateTime createdAtUtc;
  final DateTime? deletedAtUtc;
}
