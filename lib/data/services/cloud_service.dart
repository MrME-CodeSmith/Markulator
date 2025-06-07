import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';

class CloudService with ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _cloudEnabled = false;
  late final Box _syncBox;

  CloudService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _syncBox = Hive.box(syncInfoBox);
    _cloudEnabled = _syncBox.get('cloudEnabled', defaultValue: false) as bool;
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  User? get user => _auth.currentUser;
  bool get cloudEnabled => _cloudEnabled && (user != null);
  DateTime? get lastUpdated => _syncBox.get('lastUpdated') as DateTime?;

  void _updateLastUpdated(DateTime time) {
    _syncBox.put('lastUpdated', time);
  }

  void setCloudEnabled(bool value) {
    _cloudEnabled = value;
    _syncBox.put('cloudEnabled', value);
    notifyListeners();
  }

  Future<DateTime?> fetchRemoteLastUpdated() async {
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection('userModules')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;
      return (doc.data()?['lastUpdated'] as Timestamp?)?.toDate();
    } catch (e) {
      debugPrint('❌ [CloudService] Error fetching remote timestamp: $e');
      return null;
    }
  }

  Future<DateTime?> fetchDegreeRemoteLastUpdated() async {
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection('userDegrees')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;
      return (doc.data()?['lastUpdated'] as Timestamp?)?.toDate();
    } catch (e) {
      debugPrint('❌ [CloudService] Error fetching remote degree timestamp: $e');
      return null;
    }
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
      debugPrint('❌ [CloudService] Failed to sync modules: $e');
    }
  }

  Future<void> syncDegrees(List<Map<String, dynamic>> degrees) async {
    if (!cloudEnabled) return;
    final now = DateTime.now();
    try {
      final modules = degrees
          .expand((d) => (d['years'] as List)
              .expand((y) => List<Map<String, dynamic>>.from(y['modules'] as List)))
          .toList();
      await _firestore.collection('userDegrees').doc(user!.uid).set({
        'degrees': degrees,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _firestore.collection('userModules').doc(user!.uid).set({
        'modules': modules,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _updateLastUpdated(now);
    } catch (e) {
      debugPrint('❌ [CloudService] Failed to sync degrees: $e');
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
      debugPrint('❌ [CloudService] Error fetching modules: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchDegreesIfNewer() async {
    if (!cloudEnabled) return null;
    try {
      final doc = await _firestore
          .collection('userDegrees')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final remoteTs = (data['lastUpdated'] as Timestamp?)?.toDate();
        if (remoteTs != null &&
            (lastUpdated == null || remoteTs.isAfter(lastUpdated!))) {
          _updateLastUpdated(remoteTs);
          return List<Map<String, dynamic>>.from(data['degrees'] as List);
        }
      } else {
        // migration from modules collection
        final legacy = await _firestore
            .collection('userModules')
            .doc(user!.uid)
            .get();
        if (legacy.exists) {
          final ldata = legacy.data()!;
          final modules = List<Map<String, dynamic>>.from(ldata['modules'] as List);
          await syncDegrees([
            {
              'name': 'Default Degree',
              'years': [
                {
                  'yearIndex': 1,
                  'modules': modules,
                }
              ],
            }
          ]);
          return [
            {
              'name': 'Default Degree',
              'years': [
                {
                  'yearIndex': 1,
                  'modules': modules,
                }
              ],
            }
          ];
        }
      }
    } catch (e) {
      debugPrint('❌ [CloudService] Error fetching degrees: $e');
    }
    return null;
  }

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
      debugPrint('❌ [CloudService] Error fetching all modules: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchAllDegrees({bool force = false}) async {
    if (!force && !cloudEnabled) return null;
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection('userDegrees')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      final remoteTs = (data['lastUpdated'] as Timestamp?)?.toDate();
      if (remoteTs != null) {
        _updateLastUpdated(remoteTs);
      }
      return List<Map<String, dynamic>>.from(data['degrees'] as List);
    } catch (e) {
      debugPrint('❌ [CloudService] Error fetching all degrees: $e');
    }
    return null;
  }

  Future<void> syncSettings(Map<String, dynamic> settings) async {
    if (!cloudEnabled) return;
    try {
      await _firestore
          .collection('userSettings')
          .doc(user!.uid)
          .set(settings, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ [CloudService] Failed to sync settings: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchSettings() async {
    if (!cloudEnabled) return null;
    try {
      final doc = await _firestore
          .collection('userSettings')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('❌ [CloudService] Error fetching settings: $e');
      return null;
    }
  }
}
