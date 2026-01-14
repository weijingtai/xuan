import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../logging/account_log.dart';

class GuestIdentityStore {
  GuestIdentityStore({required Uuid uuid}) : _uuid = uuid;

  static const _guestAppUserIdKey = 'guest:app_user_id';

  final Uuid _uuid;

  Future<String> getOrCreateGuestAppUserId() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_guestAppUserIdKey);
    if (existing != null && existing.isNotEmpty) {
      AccountLog.log.d({
        'event': 'guest_identity.get_or_create.hit',
        'guestAppUserId': AccountLog.maskId(existing),
        'durationMs': sw.elapsedMilliseconds,
      });
      return existing;
    }

    final created = _uuid.v4();
    await prefs.setString(_guestAppUserIdKey, created);
    AccountLog.log.i({
      'event': 'guest_identity.get_or_create.created',
      'guestAppUserId': AccountLog.maskId(created),
      'durationMs': sw.elapsedMilliseconds,
    });
    return created;
  }

  Future<void> clearGuestAppUserId() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestAppUserIdKey);
    AccountLog.log.i({
      'event': 'guest_identity.clear.ok',
      'durationMs': sw.elapsedMilliseconds,
    });
  }
}

