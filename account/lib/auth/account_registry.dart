import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'account_record.dart';

class AccountRegistry {
  static const _accountsKey = 'auth:accounts';
  static const _activeAppUserIdKey = 'auth:active_app_user_id';

  Future<List<AccountRecord>> listAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AccountRecord.fromJson)
        .toList(growable: false);
  }

  Future<void> upsertAccount(AccountRecord record) async {
    final accounts = await listAccounts();
    final next = <AccountRecord>[for (final a in accounts) if (a.appUserId != record.appUserId) a, record];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _accountsKey,
      jsonEncode(next.map((a) => a.toJson()).toList(growable: false)),
    );
  }

  Future<String?> getActiveAppUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeAppUserIdKey);
  }

  Future<void> setActive(String appUserId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeAppUserIdKey, appUserId);
  }

  Future<void> clearActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeAppUserIdKey);
  }
}

