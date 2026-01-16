import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_firebase/persistence_firebase.dart';

void main() {
  test('package imports', () {
    expect(FirestoreRemoteGateway, isNotNull);
    expect(FirebaseRealtimeRemoteGateway, isNotNull);
  });
}
