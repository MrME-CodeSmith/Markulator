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

    // Whenever the FirebaseAuth user state changes, notify listeners so UI can rebuild
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  /// The currently signed-in Firebase [User], or null if no one is signed in.
  User? get user => _auth.currentUser;

  /// True only if the user is signed in *and* the local "_cloudEnabled" flag is true.
  bool get cloudEnabled => _cloudEnabled && (user != null);

  /// The last time we successfully synced to Firestore, stored locally in Hive.
  DateTime? get lastUpdated => _syncBox.get('lastUpdated') as DateTime?;

  void _updateLastUpdated(DateTime time) {
    _syncBox.put('lastUpdated', time);
  }

  /// Trigger Google Sign-In, then hand off the resulting credentials to FirebaseAuth.
  Future<void> signInWithGoogle() async {
    try {
      // 1. Open the native Google sign-in dialog (mobile/desktop/web)
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the Google sign-in flow.
        return;
      }

      // 2. Retrieve the authentication tokens from the selected Google account.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new Firebase credential using the Google tokens.
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credential.
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '❌ [CloudProvider] FirebaseAuthException: ${e.code} – ${e.message}');
    } catch (e) {
      debugPrint(
          '❌ [CloudProvider] Unexpected error during Google sign-in: $e');
    }

    // Notify any listeners (e.g., UI widgets) that the auth state likely changed.
    notifyListeners();
  }

  /// Signs out of FirebaseAuth. (GoogleSignIn does not require a separate sign-out on web.)
  Future<void> signOut() async {
    try {
      // If you ever need to explicitly sign out of GoogleSignIn on mobile:
      // await GoogleSignIn().signOut();

      await _auth.signOut();
    } catch (e) {
      debugPrint('❌ [CloudProvider] Error signing out: $e');
    }
    notifyListeners();
  }

  /// Toggle the “cloud sync” flag. Only does anything if [user] != null.
  void setCloudEnabled(bool value) {
    _cloudEnabled = value;
    notifyListeners();
  }

  /// Pushes the `modules` list to Firestore under `userModules/{uid}`.
  Future<void> syncModules(List<Map<String, dynamic>> modules) async {
    if (!cloudEnabled) return;

    final now = DateTime.now();
    try {
      await _firestore.collection('userModules').doc(user!.uid).set({
        'modules': modules,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _updateLastUpdated(now);
    } catch (e) {
      debugPrint('❌ [CloudProvider] Failed to sync modules: $e');
    }
  }

  /// Fetches modules from Firestore only if the remote `lastUpdated` is newer
  /// than the locally stored `lastUpdated`. Returns `null` if nothing new.
  Future<List<Map<String, dynamic>>?> fetchModulesIfNewer() async {
    if (!cloudEnabled) return null;

    try {
      final doc =
          await _firestore.collection('userModules').doc(user!.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final remoteTs = (data['lastUpdated'] as Timestamp?)?.toDate();
      if (remoteTs != null &&
          (lastUpdated == null || remoteTs.isAfter(lastUpdated!))) {
        _updateLastUpdated(remoteTs);
        return List<Map<String, dynamic>>.from(data['modules'] as List);
      }
    } catch (e) {
      debugPrint('❌ [CloudProvider] Error fetching modules: $e');
    }

    return null;
  }
}
