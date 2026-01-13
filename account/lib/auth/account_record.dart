import 'auth_session.dart';

class AccountRecord {
  const AccountRecord({
    required this.appUserId,
    required this.baasUid,
    required this.providerType,
    required this.lastLoginAtUtc,
    this.email,
  });

  final String appUserId;
  final String baasUid;
  final AuthProviderType providerType;
  final DateTime lastLoginAtUtc;
  final String? email;

  Map<String, Object?> toJson() {
    return {
      'appUserId': appUserId,
      'baasUid': baasUid,
      'providerType': providerType.name,
      'lastLoginAtUtc': lastLoginAtUtc.toIso8601String(),
      'email': email,
    };
  }

  static AccountRecord fromJson(Map<String, Object?> json) {
    final providerTypeRaw = json['providerType'];
    final providerType = AuthProviderType.values.firstWhere(
      (e) => e.name == providerTypeRaw,
      orElse: () => AuthProviderType.emailPassword,
    );

    return AccountRecord(
      appUserId: (json['appUserId'] as String?) ?? '',
      baasUid: (json['baasUid'] as String?) ?? '',
      providerType: providerType,
      lastLoginAtUtc: DateTime.parse((json['lastLoginAtUtc'] as String?) ?? ''),
      email: json['email'] as String?,
    );
  }
}
