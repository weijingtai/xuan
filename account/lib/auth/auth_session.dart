enum AuthProviderType {
  emailPassword,
}

class AuthSession {
  const AuthSession({
    required this.baasUid,
    required this.providerType,
    required this.issuedAt,
    this.idToken,
    this.email,
  });

  final String baasUid;
  final String? idToken;
  final String? email;
  final AuthProviderType providerType;
  final DateTime issuedAt;
}
