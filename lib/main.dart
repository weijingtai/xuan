import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:account/account.dart';
import 'package:common/common_logger.dart';
import 'package:common/database/app_database.dart' as db;
import 'package:common/database/world_info_database.dart' as world_db;
import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:common/datamodel/seeker_model.dart';
import 'package:common/datamodel/timing_divination_model.dart';
import 'package:common/enums.dart';
import 'package:common/datasource/geo_location_repository.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/datasource/loca_binary/world_country_repository.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_firebase/persistence_firebase.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:uuid/uuid.dart';
import 'package:xuan/pages/conditional_route_widget.dart';
import 'package:xuan/pages/cross_platform_main_page.dart';
import 'package:xuan/pages/root_page.dart';
import 'package:xuan/routes.dart';
import 'ephe_web_helper.dart' if (dart.library.ffi) 'ephe_io_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'NavigatorGenerator.dart';

bool _firebaseReady = false;
String? _firestoreDeviceId;
const String _publicScopeUid = 'public';

class _UnavailableRemoteGateway implements RemoteGateway {
  _UnavailableRemoteGateway({
    required SyncLogger logger,
    required String reason,
  })  : _logger = logger,
        _reason = reason;

  final SyncLogger _logger;
  final String _reason;

  String _redact(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}…${value.substring(value.length - 3)}';
  }

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    final err = SyncError(
      code: SyncErrorCode.permission,
      message: 'Remote gateway unavailable: $_reason',
    );
    _logger.warn(
      'remote_gateway_unavailable',
      data: <String, Object?>{
        'op': 'push',
        'reason': _reason,
        'scopeUid': _redact(record.scopeUid),
        'entityType': record.entityType,
        'entityId': _redact(record.entityId),
        'operationId': record.operationId,
      },
      error: err,
    );
    return err;
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    _logger.warn(
      'remote_gateway_unavailable',
      data: <String, Object?>{
        'op': 'listChanges',
        'reason': _reason,
        'scopeUid': _redact(scopeUid),
        'entityType': entityType,
        'limit': limit,
        'sinceCursorType': sinceCursor?.runtimeType.toString(),
      },
    );
    return const RemoteChangesPage(
      changes: [],
      nextCursor: null,
      hasMore: false,
    );
  }
}

class _UnavailableAuthAdapter implements AuthAdapter {
  const _UnavailableAuthAdapter();

  static StateError _err() => StateError('FirebaseAuth not initialized');

  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) {
    return Future<AuthSession>.error(_err());
  }

  @override
  Future<AuthSession> signInAnonymously() {
    return Future<AuthSession>.error(_err());
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return Future<void>.error(_err());
  }

  @override
  Future<void> signOut() {
    return Future<void>.error(_err());
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return Future<void>.error(_err());
  }

  @override
  Future<void> deleteAccount() {
    return Future<void>.error(_err());
  }
}

class _UnavailableIdentityResolver implements IdentityResolver {
  const _UnavailableIdentityResolver();

  static StateError _err() =>
      StateError('FirebaseDatabase/FirebaseFirestore not initialized');

  @override
  Future<String> resolveAppUserId(AuthSession session) {
    return Future<String>.error(_err());
  }

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) {
    return Future<void>.error(_err());
  }
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseReady = true;
  } catch (e) {
    _firebaseReady = false;
    CommonLogger().logger.w('Firebase initializeApp skipped: $e');
  }

  _firestoreDeviceId ??= const Uuid().v4();

  await initSweph([
    'packages/sweph/assets/ephe/sefstars.txt',
  ]);
}

void main() async {
  await initServices();
  runApp(const _BootstrapApp());
}

QueryExecutor _driftExecutor(String name) {
  return driftDatabase(
    name: name,
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
            );
          }
        }
      },
    ),
  );
}

class _ActiveAccountScopeProvider implements AuthScopeProvider {
  _ActiveAccountScopeProvider(this._store);

  final ActiveAccountStore _store;

  @override
  Future<String> getScopeUid() async {
    final uid = _store.activeAppUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError('No active appUserId');
    }
    return uid;
  }
}

class _CompositeLocalApplier implements LocalApplier {
  _CompositeLocalApplier(this._routes);

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

class _DivinationLocalApplier implements LocalApplier {
  _DivinationLocalApplier(this._db);

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

class _SeekerLocalApplier implements LocalApplier {
  _SeekerLocalApplier(this._db);

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

class _TimingDivinationLocalApplier implements LocalApplier {
  _TimingDivinationLocalApplier(this._db);

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
          Map<String, dynamic>.from(candidate));
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

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Uuid>(create: (_) => const Uuid()),
        Provider<AccountRegistry>(create: (_) => AccountRegistry()),
        Provider<GuestIdentityStore>(
          create: (ctx) => GuestIdentityStore(uuid: ctx.read<Uuid>()),
        ),
        ChangeNotifierProvider<ActiveAccountStore>(
          create: (ctx) => ActiveAccountStore(
            registry: ctx.read<AccountRegistry>(),
            guestIdentityStore: ctx.read<GuestIdentityStore>(),
          )..load(),
        ),
        Provider<DeviceIdentity>(
          create: (ctx) => DeviceIdentity(
            deviceId: _firestoreDeviceId ?? const Uuid().v4(),
            platform: kIsWeb ? 'web' : defaultTargetPlatform.toString(),
            formFactor: kIsWeb
                ? 'web'
                : (defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS)
                    ? 'mobile'
                    : 'desktop',
          ),
        ),
        Provider<FirebaseFirestore?>(
          create: (_) => _firebaseReady ? FirebaseFirestore.instance : null,
        ),
        Provider<FirebaseDatabase?>(
          create: (_) => _firebaseReady ? FirebaseDatabase.instance : null,
        ),
        Provider<FirebaseAuth?>(
          create: (_) => _firebaseReady ? FirebaseAuth.instance : null,
        ),
        Provider<AuthAdapter>(
          create: (ctx) {
            final auth = ctx.read<FirebaseAuth?>();
            if (auth == null) {
              return const _UnavailableAuthAdapter();
            }
            return FirebaseEmailAuthAdapter(auth: auth);
          },
        ),
        Provider<IdentityResolver>(
          create: (ctx) {
            final database = ctx.read<FirebaseDatabase?>();
            if (database != null) {
              return FirebaseRealtimeIdentityResolver(
                database: database,
                uuid: ctx.read<Uuid>(),
              );
            }

            final firestore = ctx.read<FirebaseFirestore?>();
            if (firestore != null) {
              return FirebaseIdentityResolver(
                firestore: firestore,
                uuid: ctx.read<Uuid>(),
              );
            }

            return const _UnavailableIdentityResolver();
          },
        ),
        Provider<AuthCoordinator>(
          create: (ctx) => AuthCoordinator(
            authAdapter: ctx.read<AuthAdapter>(),
            identityResolver: ctx.read<IdentityResolver>(),
            accountRegistry: ctx.read<AccountRegistry>(),
            activeAccountStore: ctx.read<ActiveAccountStore>(),
          ),
        ),
      ],
      child: const _AuthSessionBridge(child: _AuthAwareApp()),
    );
  }
}

class _AuthSessionBridge extends StatefulWidget {
  const _AuthSessionBridge({required this.child});

  final Widget child;

  @override
  State<_AuthSessionBridge> createState() => _AuthSessionBridgeState();
}

class _AuthSessionBridgeState extends State<_AuthSessionBridge> {
  StreamSubscription<AuthSession?>? _sub;
  Future<void> _serial = Future<void>.value();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;

    final coordinator = context.read<AuthCoordinator>();
    _sub = coordinator.sessionChanges().listen((session) {
      _serial = _serial.then((_) => _handle(session));
    });
  }

  Future<void> _handle(AuthSession? session) async {
    if (!mounted) return;

    final active = context.read<ActiveAccountStore>();
    final coordinator = context.read<AuthCoordinator>();

    if (session == null) {
      if (active.isSignedIn) {
        await active.switchToGuest();
      }
      return;
    }

    if (session.providerType == AuthProviderType.anonymous) {
      return;
    }

    await coordinator.activateSession(session);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AuthAwareApp extends StatelessWidget {
  const _AuthAwareApp();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ActiveAccountStore>();
    if (!store.isReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final appUserId = store.activeAppUserId;
    if (appUserId == null || appUserId.isEmpty) {
      return const MaterialApp(home: AuthPage());
    }
    return KeyedSubtree(
      key: ValueKey(appUserId),
      child: MultiProvider(
        providers: [
          Provider<AuthScopeProvider>(
            create: (ctx) =>
                _ActiveAccountScopeProvider(ctx.read<ActiveAccountStore>()),
          ),
          Provider<RingBufferLogSink>(
            create: (_) => RingBufferLogSink(
              capacity: kReleaseMode ? 300 : 3000,
            ),
          ),
          Provider<SyncLogger>(
            create: (ctx) {
              final buffer = ctx.read<RingBufferLogSink>();
              final sink = kDebugMode
                  ? CompositeLogSink(
                      <SyncLogSink>[PrintLogSink(printer: debugPrint), buffer],
                    )
                  : buffer;
              return SyncLogger(
                sink: sink,
                minLevel: kDebugMode ? SyncLogLevel.debug : SyncLogLevel.warn,
              );
            },
          ),
          Provider<db.AppDatabase>(
            create: (ctx) => db.AppDatabase(
              _driftExecutor('app_database_$appUserId'),
            ),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<world_db.WorldInfoDatabase>(
            create: (ctx) => world_db.WorldInfoDatabase(),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<PersistenceDriftDatabase>(
            create: (ctx) => PersistenceDriftDatabase(
              _driftExecutor('persistence_drift_$appUserId'),
            ),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<OutboxStore>(
            create: (ctx) => DriftOutboxStore(
              dao: ctx.read<PersistenceDriftDatabase>().outboxRecordsDao,
            ),
          ),
          Provider<SyncStateStore>(
            create: (ctx) => DriftSyncStateStore(
              dao: ctx.read<PersistenceDriftDatabase>().syncStatesDao,
            ),
          ),
          Provider<RemoteGateway>(
            create: (ctx) {
              final log = ctx.read<SyncLogger>();
              if (!ctx.read<ActiveAccountStore>().isSignedIn) {
                return _UnavailableRemoteGateway(
                  logger: log,
                  reason: 'not_signed_in',
                );
              }
              final database = ctx.read<FirebaseDatabase?>();
              if (database == null) {
                return _UnavailableRemoteGateway(
                  logger: log,
                  reason: 'firebase_database_null',
                );
              }
              return FirebaseRealtimeRemoteGateway(
                database: database,
                device: ctx.read<DeviceIdentity>(),
                nowUtc: () => DateTime.now().toUtc(),
                module: 'common',
                logger: log,
              );
            },
          ),
          Provider<LayoutTemplateLocalDataSource>(
            create: (ctx) => LayoutTemplateLocalDataSource(
              ctx.read<db.AppDatabase>(),
              outboxStore: ctx.read<OutboxStore>(),
              logger: ctx.read<SyncLogger>(),
            ),
          ),
          Provider<_DivinationLocalApplier>(
            create: (ctx) =>
                _DivinationLocalApplier(ctx.read<db.AppDatabase>()),
          ),
          Provider<_SeekerLocalApplier>(
            create: (ctx) => _SeekerLocalApplier(ctx.read<db.AppDatabase>()),
          ),
          Provider<_TimingDivinationLocalApplier>(
            create: (ctx) =>
                _TimingDivinationLocalApplier(ctx.read<db.AppDatabase>()),
          ),
          Provider<LocalApplier>(
            create: (ctx) => _CompositeLocalApplier(
              <String, LocalApplier>{
                'layout_template': ctx.read<LayoutTemplateLocalDataSource>(),
                'divination': ctx.read<_DivinationLocalApplier>(),
                'seeker': ctx.read<_SeekerLocalApplier>(),
                'timing_divination': ctx.read<_TimingDivinationLocalApplier>(),
              },
            ),
          ),
          Provider<SyncCoordinator>(
            create: (ctx) => SyncCoordinator(
              outboxStore: ctx.read<OutboxStore>(),
              syncStateStore: ctx.read<SyncStateStore>(),
              remoteGateway: ctx.read<RemoteGateway>(),
              localApplier: ctx.read<LocalApplier>(),
              nowUtc: () => DateTime.now().toUtc(),
              logger: ctx.read<SyncLogger>(),
            ),
          ),
          Provider<SyncRuntime>(
            create: (ctx) {
              final runtime = SyncRuntime(
                coordinator: ctx.read<SyncCoordinator>(),
                authScopeProvider: ctx.read<AuthScopeProvider>(),
                enablePushTimer: false,
                pushInterval: const Duration(seconds: 15),
                pullInterval: const Duration(seconds: 15),
                minBackoff: const Duration(seconds: 2),
                maxBackoff: const Duration(minutes: 2),
                logger: ctx.read<SyncLogger>(),
              );
              runtime.setPullEntityTypes(
                const <String>[
                  'layout_template',
                  'divination',
                  'seeker',
                  'timing_divination',
                ],
                triggerImmediately: false,
              );
              return runtime;
            },
            dispose: (ctx, runtime) {
              runtime.stop();
              runtime.dispose();
            },
          ),
          Provider<PublicSyncRuntime>(
            create: (ctx) {
              final log = ctx.read<SyncLogger>();
              final database = ctx.read<FirebaseDatabase?>();
              final remoteGateway = database == null
                  ? _UnavailableRemoteGateway(
                      logger: log,
                      reason: 'firebase_database_null',
                    )
                  : FirebaseRealtimeRemoteGateway(
                      database: database,
                      device: ctx.read<DeviceIdentity>(),
                      nowUtc: () => DateTime.now().toUtc(),
                      module: 'common',
                      logger: log,
                    );

              final coordinator = SyncCoordinator(
                outboxStore: ctx.read<OutboxStore>(),
                syncStateStore: ctx.read<SyncStateStore>(),
                remoteGateway: remoteGateway,
                localApplier: ctx.read<LocalApplier>(),
                nowUtc: () => DateTime.now().toUtc(),
                logger: log,
              );

              final runtime = SyncRuntime(
                coordinator: coordinator,
                enablePush: false,
                pushInterval: const Duration(seconds: 15),
                pullInterval: const Duration(seconds: 15),
                minBackoff: const Duration(seconds: 2),
                maxBackoff: const Duration(minutes: 2),
                logger: log,
              );
              runtime.setPullEntityTypes(
                const <String>['layout_template'],
                triggerImmediately: false,
              );
              return PublicSyncRuntime(runtime);
            },
            dispose: (ctx, publicRuntime) {
              publicRuntime.runtime.stop();
              publicRuntime.runtime.dispose();
            },
          ),
          Provider<GuestAccountConflictDelegate>(
            create: (ctx) => _GuestConflictDelegate(
              appDb: ctx.read<db.AppDatabase>(),
              persistenceDb: ctx.read<PersistenceDriftDatabase>(),
              uuid: ctx.read<Uuid>(),
            ),
          ),
          Provider<WorldCountryRepository>(
            create: (ctx) => WorldCountryRepository(
              path: 'assets/dataset/world_country.pro',
              regionJsonFilePath: 'assets/dataset/regions.json',
            ),
          ),
          Provider<GeoLocationRepository>(
            create: (ctx) => GeoLocationRepository(
              path: 'assets/dataset/province_city_area_lng_lat.json',
            ),
          ),
          ListenableProvider<TimezoneLocationViewModel>(
            create: (ctx) => TimezoneLocationViewModel(
                appFeatureModule: AppFeatureModule.Golabel),
          ),
          ListenableProvider<DevEnterPageViewModel>(
              create: (ctx) =>
                  DevEnterPageViewModel(appDatabase: ctx.read<db.AppDatabase>())
                    ..initState()),
          // ...StrategyProviders.providers,
        ],
        child: store.isSignedIn
            ? const _SignedInSyncShell(child: MyApp())
            : const _GuestAnonBootstrap(child: MyApp()),
      ),
    );
  }
}

class _GuestAnonBootstrap extends StatefulWidget {
  const _GuestAnonBootstrap({required this.child});

  final Widget child;

  @override
  State<_GuestAnonBootstrap> createState() => _GuestAnonBootstrapState();
}

class _GuestAnonBootstrapState extends State<_GuestAnonBootstrap>
    with WidgetsBindingObserver {
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PublicSyncRuntime>()
          .runtime
          .start(scopeUid: _publicScopeUid);
      _trySignInAnonymously();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PublicSyncRuntime>().runtime.triggerPullAll();
    }
  }

  @override
  void dispose() {
    context.read<PublicSyncRuntime>().runtime.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _trySignInAnonymously() async {
    if (!mounted) return;
    if (_attempted) return;
    _attempted = true;

    final store = context.read<ActiveAccountStore>();
    if (!store.isGuest || store.isSignedIn) return;

    final auth = context.read<FirebaseAuth?>();
    final firestore = context.read<FirebaseFirestore?>();
    if (auth == null || firestore == null) return;

    try {
      await context.read<AuthCoordinator>().signInAnonymously();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _GuestConflictDelegate implements GuestAccountConflictDelegate {
  _GuestConflictDelegate({
    required db.AppDatabase appDb,
    required PersistenceDriftDatabase persistenceDb,
    required Uuid uuid,
  })  : _appDb = appDb,
        _persistenceDb = persistenceDb,
        _uuid = uuid;

  final db.AppDatabase _appDb;
  final PersistenceDriftDatabase _persistenceDb;
  final Uuid _uuid;

  @override
  Future<void> mergeGuestIntoAccount({
    required String guestAppUserId,
    required String accountAppUserId,
  }) async {
    final accountAppDb = db.AppDatabase(
      _driftExecutor('app_database_$accountAppUserId'),
    );
    final accountPersistenceDb = PersistenceDriftDatabase(
      _driftExecutor('persistence_drift_$accountAppUserId'),
    );

    try {
      final remap = await _mergeLayoutTemplates(
        from: _appDb,
        to: accountAppDb,
      );
      await _mergeCardTemplateMetas(
        from: _appDb,
        to: accountAppDb,
        remapTemplateUuid: remap,
      );
      await _mergeCardTemplateSettings(
        from: _appDb,
        to: accountAppDb,
        remapTemplateUuid: remap,
      );
      await _rewriteOutboxIntoAccountDb(
        from: _persistenceDb,
        to: accountPersistenceDb,
        guestAppUserId: guestAppUserId,
        accountAppUserId: accountAppUserId,
        remapEntityId: remap,
      );

      await _wipeAllTables(_appDb);
      await _wipeAllTables(_persistenceDb);
    } finally {
      await accountAppDb.close();
      await accountPersistenceDb.close();
    }
  }

  @override
  Future<void> discardGuest({required String guestAppUserId}) async {
    await _wipeAllTables(_appDb);
    await _wipeAllTables(_persistenceDb);
  }

  Future<void> _wipeAllTables(GeneratedDatabase db) async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await db.transaction(() async {
        for (final table in db.allTables) {
          await db.delete(table).go();
        }
      });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<Map<String, String>> _mergeLayoutTemplates({
    required db.AppDatabase from,
    required db.AppDatabase to,
  }) async {
    final rows = await from.select(from.layoutTemplates).get();
    if (rows.isEmpty) return const {};

    final ids = rows.map((r) => r.uuid).toSet().toList(growable: false);
    final existing = await (to.select(to.layoutTemplates)
          ..where((t) => t.uuid.isIn(ids)))
        .get();
    final existingIds = existing.map((r) => r.uuid).toSet();

    final remap = <String, String>{};
    final inserts = <db.LayoutTemplatesCompanion>[];

    for (final r in rows) {
      var uuid = r.uuid;
      var templateJson = r.templateJson;
      if (existingIds.contains(uuid)) {
        final newId = _uuid.v4();
        remap[uuid] = newId;
        uuid = newId;
        templateJson = _rewriteLayoutTemplateJsonId(templateJson, newId);
      }

      inserts.add(
        db.LayoutTemplatesCompanion.insert(
          uuid: uuid,
          collectionId: r.collectionId,
          name: r.name,
          description: Value(r.description),
          templateJson: templateJson,
          version: r.version,
          updatedAt: r.updatedAt,
          deletedAt: Value(r.deletedAt),
        ),
      );
    }

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(to.layoutTemplates, inserts);
    });

    return remap;
  }

  String _rewriteLayoutTemplateJsonId(String templateJson, String newId) {
    final decoded = jsonDecode(templateJson);
    if (decoded is! Map<String, dynamic>) return templateJson;
    decoded['id'] = newId;
    return jsonEncode(decoded);
  }

  String _rewriteLayoutTemplatePayloadJson(String payloadJson, String newId) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) return payloadJson;
    decoded['entityId'] = newId;
    final template = decoded['template'];
    if (template is Map<String, dynamic>) {
      template['id'] = newId;
    }
    return jsonEncode(decoded);
  }

  Future<void> _mergeCardTemplateMetas({
    required db.AppDatabase from,
    required db.AppDatabase to,
    required Map<String, String> remapTemplateUuid,
  }) async {
    final rows = await from.select(from.cardTemplateMetas).get();
    if (rows.isEmpty) return;

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(
        to.cardTemplateMetas,
        rows
            .map(
              (r) => db.CardTemplateMetasCompanion.insert(
                templateUuid:
                    remapTemplateUuid[r.templateUuid] ?? r.templateUuid,
                createdAt: r.createdAt,
                modifiedAt: r.modifiedAt,
                deletedAt: Value(r.deletedAt),
                authorUuid: Value(r.authorUuid),
                createFromCardUuid: Value(r.createFromCardUuid),
                isCustomized: Value(r.isCustomized),
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _mergeCardTemplateSettings({
    required db.AppDatabase from,
    required db.AppDatabase to,
    required Map<String, String> remapTemplateUuid,
  }) async {
    final rows = await from.select(from.cardTemplateSettings).get();
    if (rows.isEmpty) return;

    await to.batch((batch) {
      batch.insertAllOnConflictUpdate(
        to.cardTemplateSettings,
        rows
            .map(
              (r) => db.CardTemplateSettingsCompanion.insert(
                templateUuid:
                    remapTemplateUuid[r.templateUuid] ?? r.templateUuid,
                createdAt: r.createdAt,
                modifiedAt: r.modifiedAt,
                deletedAt: Value(r.deletedAt),
                settingJson: r.settingJson,
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _rewriteOutboxIntoAccountDb({
    required PersistenceDriftDatabase from,
    required PersistenceDriftDatabase to,
    required String guestAppUserId,
    required String accountAppUserId,
    required Map<String, String> remapEntityId,
  }) async {
    final rows = await from.outboxRecordsDao.listRetryable(
      scopeUid: guestAppUserId,
    );
    if (rows.isEmpty) return;

    final nowUtc = DateTime.now().toUtc();
    final inserts = rows.map((r) {
      final remapped = r.entityType == 'layout_template'
          ? (remapEntityId[r.entityId] ?? r.entityId)
          : r.entityId;
      final payloadJson = (r.entityType == 'layout_template' &&
              remapEntityId.containsKey(r.entityId))
          ? _rewriteLayoutTemplatePayloadJson(
              r.payloadJson,
              remapped,
            )
          : r.payloadJson;

      return OutboxRecordsCompanion.insert(
        operationId: _uuid.v4(),
        scopeUid: accountAppUserId,
        entityType: r.entityType,
        entityId: remapped,
        opType: r.opType,
        payloadJson: payloadJson,
        createdAtUtc: nowUtc,
      );
    }).toList(growable: false);

    await to.outboxRecordsDao.enqueueMany(inserts);
    await from.outboxRecordsDao.deleteByScope(scopeUid: guestAppUserId);
  }
}

class _SignedInSyncShell extends StatefulWidget {
  const _SignedInSyncShell({required this.child});

  final Widget child;

  @override
  State<_SignedInSyncShell> createState() => _SignedInSyncShellState();
}

class _SignedInSyncShellState extends State<_SignedInSyncShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncRuntime>().start();
      context
          .read<PublicSyncRuntime>()
          .runtime
          .start(scopeUid: _publicScopeUid);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SyncRuntime>().triggerPush();
      context.read<SyncRuntime>().triggerPullAll();
      context.read<PublicSyncRuntime>().runtime.triggerPullAll();
    }
  }

  @override
  void dispose() {
    context.read<SyncRuntime>().stop();
    context.read<PublicSyncRuntime>().runtime.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return buildNewXuan();
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      onGenerateRoute: NavigatorGenerator.generateRoute,
      initialRoute: '/qizhengsiyu/panel',
      // initialRoute: '/one_year',
      // initialRoute: '/dev', // 七政四余
      // initialRoute: '/common/dev', // 占测记录
      // initialRoute: '/qizhengsiyu/panel', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      // initialRoute: '/tiebanshenshu/kao_ding_liu_qin',
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // main
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildNewXuan() {
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 480, name: MOBILE),
          const Breakpoint(start: 481, end: 800, name: PHONE),
          const Breakpoint(start: 801, end: 1024, name: TABLET),
          const Breakpoint(start: 1025, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
      initialRoute: "/",
      onGenerateInitialRoutes: (initialRoute) {
        final Uri uri = Uri.parse(initialRoute);
        return [
          buildPage(path: uri.path, queryParams: uri.queryParameters),
        ];
      },
      onGenerateRoute: (RouteSettings settings) {
        // A custom `fadeThrough` route transition animation.
        final Uri uri = Uri.parse(settings.name ?? '/');
        return Routes.fadeThrough(
            settings: settings,
            builder: (context) {
              // Wrap widgets with another widget based on the route.
              // Wrap the page with the ResponsiveScaledBox for desired pages.
              //   final Uri uri = Uri.parse(settings.name ?? '/');
              return ConditionalRouteWidget(
                  routesExcluded: const [], // Excluding a page from AutoScale.
                  builder: (context, child) =>
                      child ??
                      ResponsiveScaledBox(
                          // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
                          // Set the fixed width value based on the active breakpoint.
                          width: ResponsiveValue<double>(context,
                              conditionalValues: [
                                // const Condition.equals(name: MOBILE, value: 450),
                                const Condition.between(
                                    start: 0, end: 450, value: 0),
                                const Condition.between(
                                    start: 800, end: 1100, value: 800),
                                Condition.between(
                                    start: 1000,
                                    end: double.maxFinite.toInt(),
                                    value: 1000),
                              ]).value,
                          child: child!),
                  child: BouncingScrollWrapper.builder(
                      context, buildPageByName(uri.path),
                      dragWithMouse: true));
            });
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   final Uri uri = Uri.parse(settings.name ?? '/');
      //   return buildPage(path: uri.path, queryParams: uri.queryParameters);
      // },

      // initialRoute: '/qizhengsiyu',
      // initialRoute: '/one_year',
      // initialRoute: '/qizhengsiyu', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      // initialRoute: '/daliuren', // 大六壬
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // mai
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildPageByName(String name) {
    switch (name) {
      case '/':
      case CrossPlatformMainPage.routeName:
        return const CrossPlatformMainPage();
      // case PostPage.name:
      //   return const PostPage();
      // case TypographyPage.name:
      //   return const TypographyPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Route<dynamic> buildPage(
      {required String path, Map<String, String> queryParams = const {}}) {
    return Routes.noAnimation(
        settings: RouteSettings(
            name: (path.startsWith('/') == false) ? '/$path' : path),
        builder: (context) {
          String pathName =
              path != '/' && path.startsWith('/') ? path.substring(1) : path;
          return switch (pathName) {
            // '/' || ListPage.name => const ListPage(),
            "ok" =>
              // Breakpoints can be nested.
              // Here's an example of custom "per-page" breakpoints.
              ResponsiveBreakpoints(breakpoints: [
                Breakpoint(start: 0, end: 480, name: MOBILE),
                Breakpoint(start: 481, end: 1200, name: TABLET),
                Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
              ], child: RootPage()),
            '/' ||
            CrossPlatformMainPage.routeName =>
              const CrossPlatformMainPage(),
            // TypographyPage.name => const TypographyPage(),
            _ => const SizedBox.shrink(),
          };
        });
  }
}
