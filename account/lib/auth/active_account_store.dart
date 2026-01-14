import 'package:flutter/foundation.dart';

import '../logging/account_log.dart';
import 'account_registry.dart';
import 'guest_identity_store.dart';

enum ActiveAccountMode {
  guest,
  account,
}

class ActiveAccountStore extends ChangeNotifier {
  ActiveAccountStore({
    required AccountRegistry registry,
    required GuestIdentityStore guestIdentityStore,
  })  : _registry = registry,
        _guestIdentityStore = guestIdentityStore;

  final AccountRegistry _registry;
  final GuestIdentityStore _guestIdentityStore;

  bool _ready = false;
  String? _activeAppUserId;
  ActiveAccountMode? _mode;

  bool get isReady => _ready;
  String? get activeAppUserId => _activeAppUserId;
  ActiveAccountMode? get mode => _mode;
  bool get isGuest => _mode == ActiveAccountMode.guest;
  bool get isSignedIn => _mode == ActiveAccountMode.account;

  Future<void> load() async {
    final sw = Stopwatch()..start();
    final signedInAppUserId = await _registry.getActiveAppUserId();
    if (signedInAppUserId != null && signedInAppUserId.isNotEmpty) {
      _activeAppUserId = signedInAppUserId;
      _mode = ActiveAccountMode.account;
    } else {
      _activeAppUserId = await _guestIdentityStore.getOrCreateGuestAppUserId();
      _mode = ActiveAccountMode.guest;
    }
    _ready = true;
    AccountLog.log.i({
      'event': 'active_account.load.ok',
      'isSignedIn': isSignedIn,
      'mode': _mode?.name,
      'activeAppUserId': AccountLog.maskId(_activeAppUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }

  Future<void> setActiveAppUserId(String appUserId) async {
    final sw = Stopwatch()..start();
    _activeAppUserId = appUserId;
    _mode = ActiveAccountMode.account;
    await _registry.setActive(appUserId);
    AccountLog.log.i({
      'event': 'active_account.set_active.ok',
      'mode': _mode?.name,
      'activeAppUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }

  Future<void> switchToGuest() async {
    final sw = Stopwatch()..start();
    await _registry.clearActive();
    _activeAppUserId = await _guestIdentityStore.getOrCreateGuestAppUserId();
    _mode = ActiveAccountMode.guest;
    AccountLog.log.i({
      'event': 'active_account.switch_to_guest.ok',
      'mode': _mode?.name,
      'activeAppUserId': AccountLog.maskId(_activeAppUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
    notifyListeners();
  }

  Future<void> clear() async {
    await switchToGuest();
  }
}
