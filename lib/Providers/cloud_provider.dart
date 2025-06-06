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
    _cloudEnabled = _syncBox.get('cloudEnabled', defaultValue: false) as bool;

    // Notify listeners whenever the FirebaseAuth user changes.
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  User? get user => _auth.currentUser;
  bool get cloudEnabled => _cloudEnabled && (user != null);
  DateTime? get lastUpdated => _syncBox.get('lastUpdated') as DateTime?;

  void _updateLastUpdated(DateTime time) {
    _syncBox.put('lastUpdated', time);
  }

  Future<DateTime?> fetchRemoteLastUpdated() async {
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection('userModules')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;
      return (doc.data()?["lastUpdated"] as Timestamp?)?.toDate();
    } catch (e) {
      debugPrint('❌ [CloudProvider] Error fetching remote timestamp: $e');
      return null;
    }
  }

  /// Attempts to sign in via Google.
  ///
  /// On the web: show a popup.
  /// On macOS/Windows/Linux: use `google_sign_in` to get tokens and then
  /// call `signInWithCredential(...)`.
  /// On Android/iOS: `google_sign_in` also works, so we treat them the same as desktop here.
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // ─── Web Flow ────────────────────────────────────────────────────────────
        final provider = GoogleAuthProvider();
        await _auth.signInWithPopup(provider);
      } else {
        // ─── Desktop & Mobile Flow (macOS, Windows, Linux, Android, iOS) ─────────
        //
        // Use the `google_sign_in` plugin to open a native account picker.
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // User cancelled the Google sign-in dialog.
          return;
        }

        // Obtain the auth tokens from the selected Google account
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new Firebase credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '❌ [CloudProvider] FirebaseAuthException: ${e.code} – ${e.message}',
      );
    } catch (e) {
      debugPrint(
        '❌ [CloudProvider] Unexpected error during Google sign-in: $e',
      );
    }

    // Notify listeners because `user` may have changed
    notifyListeners();
  }

  /// Signs out of FirebaseAuth. If you want to force the Google cached account
  /// to sign out as well, you can uncomment the `GoogleSignIn().signOut()` call.
  Future<void> signOut() async {
    try {
      // If desired, explicitly sign out of Google on desktop/mobile:
      // await GoogleSignIn().signOut();

      await _auth.signOut();
    } catch (e) {
      debugPrint('❌ [CloudProvider] Error signing out: $e');
    }
    notifyListeners();
  }

  void setCloudEnabled(bool value) {
    _cloudEnabled = value;
    _syncBox.put('cloudEnabled', value);
    notifyListeners();
  }

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

  Future<List<Map<String, dynamic>>?> fetchModulesIfNewer() async {
    if (!cloudEnabled) return null;

    try {
      final doc = await _firestore
          .collection('userModules')
          .doc(user!.uid)
          .get();
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

  /// Always fetches the modules for the signed in user regardless of
  /// `lastUpdated`. Useful for development and testing utilities.
  Future<List<Map<String, dynamic>>?> fetchAllModules({
    bool force = false,
  }) async {
    if (!force && !cloudEnabled) return null;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('userModules')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final remoteTs = (data['lastUpdated'] as Timestamp?)?.toDate();
      if (remoteTs != null) {
        _updateLastUpdated(remoteTs);
      }
      return List<Map<String, dynamic>>.from(data['modules'] as List);
    } catch (e) {
      debugPrint('❌ [CloudProvider] Error fetching all modules: $e');
    }

    return null;
  }
}
