import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'auth_session.dart';
import 'identity_resolver.dart';

class FirebaseIdentityResolver implements IdentityResolver {
  FirebaseIdentityResolver({
    required FirebaseFirestore firestore,
    required Uuid uuid,
  })  : _firestore = firestore,
        _uuid = uuid;

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  @override
  Future<String> resolveAppUserId(AuthSession session) async {
    final baasUid = session.baasUid;
    final doc = _firestore.collection('identity_map').doc(baasUid);
    final snapshot = await doc.get();
    final existing = snapshot.data();
    final existingAppUserId = existing == null ? null : existing['appUserId'];
    if (existingAppUserId is String && existingAppUserId.isNotEmpty) {
      return existingAppUserId;
    }

    final appUserId = _uuid.v4();
    await doc.set({
      'appUserId': appUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
      'providerType': session.providerType.name,
      'schemaVersion': 1,
    });
    return appUserId;
  }
}

