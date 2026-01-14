import 'package:flutter/foundation.dart';

import '../logging/account_log.dart';
import 'account_registry.dart';

class ActiveAccountStore extends ChangeNotifier {
  ActiveAccountStore({required AccountRegistry registry})
      : _registry = registry;

  final AccountRegistry _registry;

  bool _ready = false;
  String? _activeAppUserId;

  bool get isReady => _ready;
  String? get activeAppUserId => _activeAppUserId;
  bool get isSignedIn =>
      _activeAppUserId != null && _activeAppUserId!.isNotEmpty;

  Future<void> load() async {
    final sw = Stopwatch()..start();
    _activeAppUserId = await _registry.getActiveAppUserId();
    _ready = true;
    AccountLog.log.i({
      'event': 'active_account.load.ok',
      'isSignedIn': isSignedIn,
      'activeAppUserId': AccountLog.maskId(_activeAppUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }

  Future<void> setActiveAppUserId(String appUserId) async {
    final sw = Stopwatch()..start();
    _activeAppUserId = appUserId;
    await _registry.setActive(appUserId);
    AccountLog.log.i({
      'event': 'active_account.set_active.ok',
      'activeAppUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }

  Future<void> clear() async {
    final sw = Stopwatch()..start();
    _activeAppUserId = null;
    await _registry.clearActive();
    AccountLog.log.i({
      'event': 'active_account.clear.ok',
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }
}
