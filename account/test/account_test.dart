import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:account/account.dart';

void main() {
  test('account exports compile', () {
    expect(AuthProviderType.emailPassword.name, 'emailPassword');
  });

  test('GuestIdentityStore creates and persists guest appUserId', () async {
    SharedPreferences.setMockInitialValues({});
    final store = GuestIdentityStore(uuid: const Uuid());

    final id1 = await store.getOrCreateGuestAppUserId();
    final id2 = await store.getOrCreateGuestAppUserId();
    expect(id1, isNotEmpty);
    expect(id2, id1);

    await store.clearGuestAppUserId();
    final id3 = await store.getOrCreateGuestAppUserId();
    expect(id3, isNotEmpty);
    expect(id3, isNot(id1));
  });

  test('ActiveAccountStore loads guest mode when no active account', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    final guestStore = GuestIdentityStore(uuid: const Uuid());
    final store = ActiveAccountStore(
      registry: registry,
      guestIdentityStore: guestStore,
    );

    await store.load();
    expect(store.isReady, isTrue);
    expect(store.isGuest, isTrue);
    expect(store.isSignedIn, isFalse);
    expect(store.activeAppUserId, isNotNull);
    expect(store.activeAppUserId, isNotEmpty);
  });

  test('ActiveAccountStore prefers signed-in active account over guest', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    await registry.setActive('signed_in_user');

    final store = ActiveAccountStore(
      registry: registry,
      guestIdentityStore: GuestIdentityStore(uuid: const Uuid()),
    );

    await store.load();
    expect(store.isSignedIn, isTrue);
    expect(store.isGuest, isFalse);
    expect(store.activeAppUserId, 'signed_in_user');
  });

  test('ActiveAccountStore can switch to guest and clear active account', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    final guestStore = GuestIdentityStore(uuid: const Uuid());
    final store = ActiveAccountStore(
      registry: registry,
      guestIdentityStore: guestStore,
    );

    await store.setActiveAppUserId('signed_in_user');
    expect(store.isSignedIn, isTrue);
    expect(store.activeAppUserId, 'signed_in_user');

    await store.switchToGuest();
    expect(store.isGuest, isTrue);
    expect(store.isSignedIn, isFalse);
    expect(store.activeAppUserId, isNotNull);
    expect(store.activeAppUserId, isNotEmpty);

    final active = await registry.getActiveAppUserId();
    expect(active, isNull);
  });
}
