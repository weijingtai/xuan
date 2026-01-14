import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../logging/account_log.dart';
import 'account_record.dart';

class AccountRegistry {
  static const _accountsKey = 'auth:accounts';
  static const _activeAppUserIdKey = 'auth:active_app_user_id';

  Future<List<AccountRecord>> listAccounts() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) {
      AccountLog.log.d({
        'event': 'account_registry.list.empty',
        'durationMs': sw.elapsedMilliseconds,
      });
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      AccountLog.log.w({
        'event': 'account_registry.list.invalid_shape',
        'durationMs': sw.elapsedMilliseconds,
      });
      return const [];
    }

    final list = decoded
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AccountRecord.fromJson)
        .toList(growable: false);

    AccountLog.log.d({
      'event': 'account_registry.list.ok',
      'count': list.length,
      'durationMs': sw.elapsedMilliseconds,
    });

    return list;
  }

  Future<void> upsertAccount(AccountRecord record) async {
    final sw = Stopwatch()..start();
    final accounts = await listAccounts();
    final next = <AccountRecord>[
      for (final a in accounts)
        if (a.appUserId != record.appUserId) a,
      record
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _accountsKey,
      jsonEncode(next.map((a) => a.toJson()).toList(growable: false)),
    );

    AccountLog.log.i({
      'event': 'account_registry.upsert.ok',
      'appUserId': AccountLog.maskId(record.appUserId),
      'count': next.length,
      'durationMs': sw.elapsedMilliseconds,
    });
  }

  Future<String?> getActiveAppUserId() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_activeAppUserIdKey);
    AccountLog.log.d({
      'event': 'account_registry.get_active.ok',
      'activeAppUserId': AccountLog.maskId(id),
      'durationMs': sw.elapsedMilliseconds,
    });
    return id;
  }

  Future<void> setActive(String appUserId) async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeAppUserIdKey, appUserId);
    AccountLog.log.i({
      'event': 'account_registry.set_active.ok',
      'activeAppUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
  }

  Future<void> clearActive() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeAppUserIdKey);
    AccountLog.log.i({
      'event': 'account_registry.clear_active.ok',
      'durationMs': sw.elapsedMilliseconds,
    });
  }
}

