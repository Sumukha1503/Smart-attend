import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock Network Service for Session Sharing
/// 
/// IMPORTANT: This is a MOCK service for demonstration purposes.
/// In a real production app, you would replace this with actual API calls
/// to a backend server (e.g., Firebase, REST API, etc.)
/// 
/// Current Limitation: This still uses SharedPreferences, which is device-specific.
/// Sessions created on Device A will NOT be visible on Device B.
/// 
/// To enable true cross-device communication, you need:
/// 1. A backend server (Node.js, Django, Firebase, etc.)
/// 2. Real-time database (Firestore, MongoDB, PostgreSQL, etc.)
/// 3. API endpoints for creating and fetching sessions
class SessionNetworkService {
  static final SessionNetworkService _instance = SessionNetworkService._internal();
  
  factory SessionNetworkService() {
    return _instance;
  }
  
  SessionNetworkService._internal();

  /// Create a session (would be an API POST in production)
  Future<void> createSession(Map<String, dynamic> session) async {
    // In production, this would be:
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/sessions'),
    //   body: jsonEncode(session),
    // );
    
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getActiveSessions();
    sessions.add(session);
    final sessionsJson = sessions.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('active_sessions', sessionsJson);
    
    print('📡 [MOCK API] Session created: ${session['courseName']}');
  }

  /// Get active sessions (would be an API GET in production)
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    // In production, this would be:
    // final response = await http.get(
    //   Uri.parse('https://your-api.com/sessions/active'),
    // );
    // return jsonDecode(response.body);
    
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('active_sessions') ?? [];
    
    final allSessions = sessionsJson
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
    
    // Filter expired sessions
    final now = DateTime.now();
    final activeSessions = allSessions.where((s) {
      final createdAt = DateTime.parse(s['createdAt']);
      return now.difference(createdAt).inMinutes < 2;
    }).toList();
    
    // Clean up expired sessions
    if (activeSessions.length != allSessions.length) {
      final activeSessionsJson = activeSessions.map((s) => jsonEncode(s)).toList();
      await prefs.setStringList('active_sessions', activeSessionsJson);
    }
    
    print('📡 [MOCK API] Active sessions fetched: ${activeSessions.length}');
    return activeSessions;
  }

  /// Delete a session (would be an API DELETE in production)
  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getActiveSessions();
    sessions.removeWhere((s) => s['id'] == sessionId);
    final sessionsJson = sessions.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('active_sessions', sessionsJson);
    
    print('📡 [MOCK API] Session deleted: $sessionId');
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_sessions');
    print('📡 [MOCK API] All sessions cleared');
  }
}
