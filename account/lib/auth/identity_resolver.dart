import 'auth_session.dart';

class IdentityMappingConflict implements Exception {
  const IdentityMappingConflict({
    required this.baasUid,
    required this.expectedAppUserId,
    required this.existingAppUserId,
  });

  final String baasUid;
  final String expectedAppUserId;
  final String existingAppUserId;

  @override
  String toString() {
    return 'IdentityMappingConflict(baasUid=$baasUid, expectedAppUserId=$expectedAppUserId, existingAppUserId=$existingAppUserId)';
  }
}

abstract class IdentityResolver {
  Future<String> resolveAppUserId(AuthSession session);

  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  });
}
