import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../features/auth/data/models/geo_session_model.dart';

/// Firebase Firestore Session Service
/// 
/// This service handles real-time session synchronization across devices
/// using Firebase Firestore. Sessions created on one device will be
/// immediately visible on all other devices.
class FirebaseSessionService {
  static final FirebaseSessionService _instance = FirebaseSessionService._internal();
  
  factory FirebaseSessionService() {
    return _instance;
  }
  
  FirebaseSessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _sessionsCollection = 'sessions';

  /// Create a new session
  /// 
  /// This will store the session in Firestore, making it immediately
  /// available to all devices.
  Future<void> createSession(Map<String, dynamic> session) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(session['id'])
          .set({
        ...session,
        'createdAt': session['createdAt'], // Keep original timestamp
        'expiresAt': session['expiresAt'] ?? DateTime.now().add(const Duration(minutes: 2)).toIso8601String(),
        'isActive': true,
      });
      
      print('✅ Firebase: Session created - ${session['courseName']}');
    } catch (e) {
      print('❌ Firebase: Error creating session - $e');
      rethrow;
    }
  }

  /// Get active sessions as a Stream (real-time updates)
  /// 
  /// This returns a stream that automatically updates when sessions
  /// are added, modified, or deleted in Firestore.
  /// 
  /// **This is the key method for cross-device real-time sync!**
  Stream<List<Map<String, dynamic>>> getActiveSessionsStream() {
    final now = DateTime.now();
    final twoMinutesAgo = now.subtract(const Duration(minutes: 2));
    
    return _firestore
        .collection(_sessionsCollection)
        .where('isActive', isEqualTo: true)
        .where('createdAt', isGreaterThan: twoMinutesAgo.toIso8601String())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Ensure all required fields exist
        return {
          'id': data['id'] ?? doc.id,
          'courseId': data['courseId'] ?? '',
          'courseName': data['courseName'] ?? 'Unknown Course',
          'courseCode': data['courseCode'] ?? '',
          'facultyId': data['facultyId'] ?? '',
          'facultyName': data['facultyName'] ?? '',
          'createdAt': data['createdAt'] ?? now.toIso8601String(),
          'expiresAt': data['expiresAt'] ?? now.add(const Duration(minutes: 2)).toIso8601String(),
          'isActive': data['isActive'] ?? true,
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'radius': data['radius'] ?? 50.0,
        };
      }).toList();
      
      // Filter out expired sessions
      final activeSessions = sessions.where((session) {
        try {
          final expiresAt = DateTime.parse(session['expiresAt']);
          return now.isBefore(expiresAt);
        } catch (e) {
          return false;
        }
      }).toList();
      
      print('📡 Firebase Stream: ${activeSessions.length} active sessions');
      return activeSessions;
    }).handleError((error) {
      print('❌ Firebase Stream Error: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Get active sessions as a Future (one-time fetch)
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final now = DateTime.now();
      final twoMinutesAgo = now.subtract(const Duration(minutes: 2));
      
      final snapshot = await _firestore
          .collection(_sessionsCollection)
          .where('isActive', isEqualTo: true)
          .where('createdAt', isGreaterThan: twoMinutesAgo.toIso8601String())
          .orderBy('createdAt', descending: true)
          .get();
      
      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        
        return {
          'id': data['id'] ?? doc.id,
          'courseId': data['courseId'] ?? '',
          'courseName': data['courseName'] ?? 'Unknown Course',
          'courseCode': data['courseCode'] ?? '',
          'facultyId': data['facultyId'] ?? '',
          'facultyName': data['facultyName'] ?? '',
          'createdAt': data['createdAt'] ?? now.toIso8601String(),
          'expiresAt': data['expiresAt'] ?? now.add(const Duration(minutes: 2)).toIso8601String(),
          'isActive': data['isActive'] ?? true,
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'radius': data['radius'] ?? 50.0,
        };
      }).toList();
      
      // Filter out expired sessions
      final activeSessions = sessions.where((session) {
        try {
          final expiresAt = DateTime.parse(session['expiresAt']);
          return now.isBefore(expiresAt);
        } catch (e) {
          return false;
        }
      }).toList();
      
      print('📡 Firebase: ${activeSessions.length} active sessions fetched');
      return activeSessions;
    } catch (e) {
      print('❌ Firebase: Error fetching sessions - $e');
      return [];
    }
  }

  /// End a session (mark as inactive)
  Future<void> endSession(String sessionId) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .update({'isActive': false});
      
      print('✅ Firebase: Session ended - $sessionId');
    } catch (e) {
      print('❌ Firebase: Error ending session - $e');
      rethrow;
    }
  }

  /// Delete a specific session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .delete();
      
      print('✅ Firebase: Session deleted - $sessionId');
    } catch (e) {
      print('❌ Firebase: Error deleting session - $e');
      rethrow;
    }
  }

  /// Clean up expired sessions
  /// 
  /// This removes sessions older than 2 minutes from Firestore
  Future<void> cleanupExpiredSessions() async {
    try {
      final now = DateTime.now();
      final twoMinutesAgo = now.subtract(const Duration(minutes: 2));
      
      final snapshot = await _firestore
          .collection(_sessionsCollection)
          .where('createdAt', isLessThan: twoMinutesAgo.toIso8601String())
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('🧹 Firebase: Cleaned up ${snapshot.docs.length} expired sessions');
    } catch (e) {
      print('❌ Firebase: Error cleaning up sessions - $e');
    }
  }

  /// Clear all sessions (for testing/reset)
  Future<void> clearAllSessions() async {
    try {
      final snapshot = await _firestore.collection(_sessionsCollection).get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('🧹 Firebase: All sessions cleared');
    } catch (e) {
      print('❌ Firebase: Error clearing sessions - $e');
      rethrow;
    }
  }

  /// Listen to a specific session
  Stream<Map<String, dynamic>?> getSessionStream(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      
      final data = snapshot.data()!;
      return {
        'id': data['id'] ?? sessionId,
        'courseId': data['courseId'] ?? '',
        'courseName': data['courseName'] ?? '',
        'courseCode': data['courseCode'] ?? '',
        'facultyId': data['facultyId'] ?? '',
        'facultyName': data['facultyName'] ?? '',
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'expiresAt': data['expiresAt'] ?? DateTime.now().add(const Duration(minutes: 2)).toIso8601String(),
        'isActive': data['isActive'] ?? true,
        'latitude': data['latitude'] ?? 0.0,
        'longitude': data['longitude'] ?? 0.0,
        'radius': data['radius'] ?? 50.0,
      };
    });
  }

  /// Get sessions for a specific course
  Stream<List<Map<String, dynamic>>> getSessionsForCourse(String courseId) {
    final now = DateTime.now();
    
    return _firestore
        .collection(_sessionsCollection)
        .where('courseId', isEqualTo: courseId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Get sessions created by a specific faculty
  Stream<List<Map<String, dynamic>>> getSessionsByFaculty(String facultyId) {
    return _firestore
        .collection(_sessionsCollection)
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }
}

