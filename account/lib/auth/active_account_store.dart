import 'package:flutter/foundation.dart';

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
    _activeAppUserId = await _registry.getActiveAppUserId();
    _ready = true;
    notifyListeners();
  }

  Future<void> setActiveAppUserId(String appUserId) async {
    _activeAppUserId = appUserId;
    await _registry.setActive(appUserId);
    notifyListeners();
  }

  Future<void> clear() async {
    _activeAppUserId = null;
    await _registry.clearActive();
    notifyListeners();
  }
}
