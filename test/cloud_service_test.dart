import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';

import 'package:markulator/data/services/cloud_service.dart';
import 'package:markulator/main.dart';

class MockAuth extends Mock implements FirebaseAuth {}
class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-user';
}

void main() {
  setUp(() async {
    await setUpTestHive();
    await Hive.openBox(syncInfoBox);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('syncDegrees and fetchDegreesIfNewer round trip', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockAuth();
    final user = FakeUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(user));

    final service = CloudService(auth: auth, firestore: firestore);
    service.setCloudEnabled(true);

    final degrees = [
      {
        'name': 'CS',
        'years': [
          {
            'yearIndex': 1,
            'modules': [
              {
                'name': 'A',
                'mark': 80.0,
                'weight': 0.0,
                'autoWeight': true,
                'credits': 10.0,
                'contributors': []
              }
            ]
          }
        ]
      }
    ];

    await service.syncDegrees(degrees);

    final fetched = await service.fetchDegreesIfNewer();
    expect(fetched, isNotNull);
    expect(fetched!.first['name'], 'CS');
  });
}
