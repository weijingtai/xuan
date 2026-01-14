import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:account/account.dart';

void main() {
  test('account exports compile', () {
    expect(AuthProviderType.emailPassword.name, 'emailPassword');
  });

  test('guest -> register keeps same appUserId', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    final guestStore = GuestIdentityStore(uuid: const Uuid());
    final active = ActiveAccountStore(registry: registry, guestIdentityStore: guestStore);
    await active.load();
    final guestId = active.activeAppUserId!;

    final fakeAdapter = _FakeAuthAdapter(
      session: AuthSession(
        baasUid: 'baas-1',
        providerType: AuthProviderType.emailPassword,
        issuedAt: DateTime.now().toUtc(),
      ),
    );
    final fakeResolver = _FakeIdentityResolver(resolvedAppUserId: 'resolved-app-user');

    final coordinator = AuthCoordinator(
      authAdapter: fakeAdapter,
      identityResolver: fakeResolver,
      accountRegistry: registry,
      activeAccountStore: active,
    );

    await coordinator.signInOrRegisterWithEmailPassword(email: 'a@b.c', password: 'p');

    expect(active.isSignedIn, isTrue);
    expect(active.activeAppUserId, guestId);
  });

  test('guest -> anonymous mapping called', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    final guestStore = GuestIdentityStore(uuid: const Uuid());
    final active = ActiveAccountStore(registry: registry, guestIdentityStore: guestStore);
    await active.load();
    final guestId = active.activeAppUserId!;

    final fakeAdapter = _FakeAuthAdapter(
      session: AuthSession(
        baasUid: 'baas-2',
        providerType: AuthProviderType.anonymous,
        issuedAt: DateTime.now().toUtc(),
      ),
    );
    final fakeResolver = _FakeIdentityResolver(resolvedAppUserId: 'resolved-app-user');

    final coordinator = AuthCoordinator(
      authAdapter: fakeAdapter,
      identityResolver: fakeResolver,
      accountRegistry: registry,
      activeAccountStore: active,
    );

    await coordinator.signInAnonymously();

    expect(fakeResolver.lastEnsuredAppUserId, guestId);
    expect(active.isSignedIn, isTrue);
    expect(active.activeAppUserId, guestId);
  });

  test('guest -> sign in existing account throws GuestAccountConflict', () async {
    SharedPreferences.setMockInitialValues({});
    final registry = AccountRegistry();
    final guestStore = GuestIdentityStore(uuid: const Uuid());
    final active = ActiveAccountStore(registry: registry, guestIdentityStore: guestStore);
    await active.load();
    final guestId = active.activeAppUserId!;

    final fakeAdapter = _FakeAuthAdapter(
      session: AuthSession(
        baasUid: 'baas-3',
        providerType: AuthProviderType.emailPassword,
        issuedAt: DateTime.now().toUtc(),
      ),
    );
    final fakeResolver = _FakeIdentityResolver(resolvedAppUserId: 'account-app-user');

    final coordinator = AuthCoordinator(
      authAdapter: fakeAdapter,
      identityResolver: fakeResolver,
      accountRegistry: registry,
      activeAccountStore: active,
    );

    try {
      await coordinator.signInWithEmailPassword(email: 'a@b.c', password: 'p');
      fail('expected GuestAccountConflict');
    } on GuestAccountConflict catch (e) {
      expect(e.guestAppUserId, guestId);
      expect(e.accountAppUserId, 'account-app-user');
      expect(active.activeAppUserId, guestId);
      expect(active.isSignedIn, isFalse);
    }
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

class _FakeAuthAdapter implements AuthAdapter {
  _FakeAuthAdapter({required this.session});
  final AuthSession session;

  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) async {
    return session;
  }

  @override
  Future<AuthSession> signInAnonymously() async => session;

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updatePassword({required String newPassword}) async {}

  @override
  Future<void> deleteAccount() async {}
}

class _FakeIdentityResolver implements IdentityResolver {
  _FakeIdentityResolver({required this.resolvedAppUserId});
  final String resolvedAppUserId;
  String? lastEnsuredAppUserId;

  @override
  Future<String> resolveAppUserId(AuthSession session) async => resolvedAppUserId;

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) async {
    lastEnsuredAppUserId = appUserId;
  }
}
