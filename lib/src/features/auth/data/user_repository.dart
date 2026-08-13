import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final FirebaseFirestore _db;
  static final Map<String, Map<String, dynamic>> _memoryCache = {};

  UserRepository(this._db);

  String _cacheKey(String uid) => 'healthos_user_profile_$uid';

  /// Saves or updates user profile locally in SharedPreferences + Memory cache
  Future<void> _saveToLocalCache(String uid, Map<String, dynamic> data) async {
    try {
      final existing =
          _memoryCache[uid] ?? await _loadFromLocalCache(uid) ?? {};
      final merged = {...existing, ...data};

      final cleanMap = <String, dynamic>{};
      merged.forEach((key, value) {
        if (value is DateTime) {
          cleanMap[key] = value.toIso8601String();
        } else if (value is Timestamp) {
          cleanMap[key] = value.toDate().toIso8601String();
        } else if (value is FieldValue) {
          // Skip FieldValue instances for JSON serialization
        } else {
          cleanMap[key] = value;
        }
      });
      _memoryCache[uid] = cleanMap;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey(uid), jsonEncode(cleanMap));
    } catch (_) {}
  }

  /// Drops the cached profile for [uid] from memory and disk.
  ///
  /// Called on sign-out. Without this the static memory cache outlives the
  /// session, so the next sign-in briefly re-emits the previous user's profile
  /// before Firestore responds.
  Future<void> clearCache(String uid) async {
    _memoryCache.remove(uid);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey(uid));
    } catch (_) {}
  }

  /// Reads cached user profile from SharedPreferences or Memory
  Future<Map<String, dynamic>?> _loadFromLocalCache(String uid) async {
    if (_memoryCache.containsKey(uid) && _memoryCache[uid]!.isNotEmpty) {
      return _memoryCache[uid];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _memoryCache[uid] = decoded;
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Retrieves user profile data with guaranteed fallback to local cache
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final localData = await _loadFromLocalCache(uid);

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final remoteData = doc.data()!;
        final merged = {...?localData, ...remoteData};
        await _saveToLocalCache(uid, merged);
        return merged;
      }
    } catch (_) {
      // Return local cached profile if network or Firestore throws
    }

    return localData;
  }

  /// Watch user profile stream with immediate local cache emission and real-time Firestore updates
  Stream<Map<String, dynamic>?> watchUserData(String uid) async* {
    final localData = await _loadFromLocalCache(uid);
    if (localData != null && localData.isNotEmpty) {
      yield localData;
    }

    try {
      yield* _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .asyncMap((doc) async {
            if (doc.exists && doc.data() != null) {
              final remoteData = doc.data()!;
              final merged = {...?localData, ...remoteData};
              await _saveToLocalCache(uid, merged);
              return merged;
            }
            return localData;
          });
    } catch (_) {
      if (localData != null) {
        yield localData;
      }
    }
  }

  /// Creates and saves user profile data permanently to Firestore + SharedPreferences
  Future<void> createUserData(String uid, Map<String, dynamic> data) async {
    final cleanData = Map<String, dynamic>.from(data);
    cleanData['createdAt'] ??= DateTime.now().toIso8601String();
    cleanData['updatedAt'] = DateTime.now().toIso8601String();

    // 1. Immediately cache locally so UI updates instantly and role is permanently saved
    await _saveToLocalCache(uid, cleanData);

    // 2. Persist to Firestore database
    try {
      final mergedForFirestore = {
        ...cleanData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _db
          .collection('users')
          .doc(uid)
          .set(mergedForFirestore, SetOptions(merge: true));
    } catch (_) {
      // Local cache already saved; even if Firestore write fails temporarily offline, user data is safe!
    }
  }

  /// Records an authentication provider (e.g. 'password', 'emailLink', 'google.com')
  Future<void> recordSignInProvider(
    String uid,
    String providerId, {
    String? email,
    String? name,
  }) async {
    try {
      final localData = await _loadFromLocalCache(uid);

      if (email != null || name != null) {
        final localUpdate = <String, dynamic>{
          if (email != null) 'email': email.toLowerCase(),
          if (name != null &&
              (localData?['name'] == null ||
                  (localData!['name'] as String).isEmpty))
            'name': name,
        };
        await _saveToLocalCache(uid, localUpdate);
      }

      final updateData = <String, dynamic>{
        'authProviders': FieldValue.arrayUnion([providerId]),
        'lastSignInAt': FieldValue.serverTimestamp(),
        if (email != null) 'email': email.toLowerCase(),
        if (name != null) 'name': name,
      };
      await _db
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Searches for an existing user document by email address.
  Future<String?> findUidByEmail(String email) async {
    try {
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
    } catch (_) {}
    return null;
  }

  Stream<List<Map<String, dynamic>>> watchPatients() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['uid'] = doc.id;
                return data;
              }).toList()
                ..sort(
                  (a, b) =>
                      (a['name'] as String? ?? '').compareTo(
                        b['name'] as String? ?? '',
                      ),
                ),
        );
  }
}
