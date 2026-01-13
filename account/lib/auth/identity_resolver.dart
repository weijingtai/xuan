import 'auth_session.dart';

abstract class IdentityResolver {
  Future<String> resolveAppUserId(AuthSession session);
}
