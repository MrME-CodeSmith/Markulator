import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';

class CloudProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _cloudEnabled = false;
  late final Box _syncBox;

  CloudProvider() {
    _syncBox = Hive.box(syncInfoBox);
  }

  User? get user => _auth.currentUser;
  bool get cloudEnabled => _cloudEnabled && user != null;
  DateTime? get lastUpdated => _syncBox.get('lastUpdated');

  void _updateLastUpdated(DateTime time) {
    _syncBox.put('lastUpdated', time);
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user canceled
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  void setCloudEnabled(bool value) {
    _cloudEnabled = value;
    notifyListeners();
  }

  Future<void> syncModules(List<Map<String, dynamic>> modules) async {
    if (cloudEnabled) {
      final now = DateTime.now();
      await _firestore.collection('userModules').doc(user!.uid).set({
        'modules': modules,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      _updateLastUpdated(now);
    }
  }

  Future<List<Map<String, dynamic>>?> fetchModulesIfNewer() async {
    if (!cloudEnabled) return null;
    final doc = await _firestore.collection('userModules').doc(user!.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final remoteTs = (data['lastUpdated'] as Timestamp?)?.toDate();
    if (remoteTs != null && (lastUpdated == null || remoteTs.isAfter(lastUpdated!))) {
      _updateLastUpdated(remoteTs);
      return List<Map<String, dynamic>>.from(data['modules'] as List);
    }
    return null;
  }
}
