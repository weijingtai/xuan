import 'types.dart';

abstract class OutboxStore {
  Future<void> enqueue(OutboxRecord record);

  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  });

  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  });

  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  });

  Future<int> backlogCount(String scopeUid);

  Future<int> deadCount(String scopeUid);
}

abstract class SyncStateStore {
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  });

  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  });

  Future<void> clear({
    required String scopeUid,
    required String entityType,
  });

  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  });

  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  });
}

abstract class RemoteGateway {
  Future<SyncError?> push(OutboxRecord record);

  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  });
}

abstract class LocalApplier {
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  });
}

class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.platform,
    required this.formFactor,
    this.model,
    this.osVersion,
    this.appVersion,
  });

  final String deviceId;
  final String platform;
  final String formFactor;
  final String? model;
  final String? osVersion;
  final String? appVersion;
}

abstract class DeviceIdentityProvider {
  Future<DeviceIdentity> get();
}

abstract class AuthScopeProvider {
  Future<String> getScopeUid();
}
