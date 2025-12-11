import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // Save a user to local storage
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final users = await getAllUsers();
      
      // Add new user
      users.add(userData);
      
      // Save back to storage
      final usersJson = users.map((user) => jsonEncode(user)).toList();
      return await prefs.setStringList(_usersKey, usersJson);
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(Map<String, dynamic> updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();
      
      final index = users.indexWhere((u) => u['id'] == updatedUser['id']);
      if (index != -1) {
        users[index] = updatedUser;
        final usersJson = users.map((user) => jsonEncode(user)).toList();
        return await prefs.setStringList(_usersKey, usersJson);
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();
      
      users.removeWhere((u) => u['id'] == userId);
      
      final usersJson = users.map((user) => jsonEncode(user)).toList();
      return await prefs.setStringList(_usersKey, usersJson);
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Get all registered users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      return usersJson
          .map((userStr) => jsonDecode(userStr) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    final users = await getAllUsers();
    return users.any((user) => user['email'] == email);
  }

  // Verify login credentials
  Future<Map<String, dynamic>?> verifyCredentials(
      String email, String password) async {
    final users = await getAllUsers();
    
    try {
      return users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Verify login credentials by USN (case-insensitive for students)
  Future<Map<String, dynamic>?> verifyCredentialsByUsn(
      String usn, String password) async {
    final users = await getAllUsers();
    
    try {
      return users.firstWhere(
        (user) => 
          user['usn'] != null && 
          user['usn'].toString().toLowerCase() == usn.toLowerCase() && 
          user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Verify login credentials by Employee ID (for Faculty and HOD)
  Future<Map<String, dynamic>?> verifyCredentialsByEmployeeId(
      String employeeId, String password) async {
    final users = await getAllUsers();
    
    try {
      return users.firstWhere(
        (user) => 
          user['employeeId'] != null && 
          user['employeeId'].toString().toUpperCase() == employeeId.toUpperCase() && 
          user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Verify admin credentials (username-based)
  Future<Map<String, dynamic>?> verifyAdminCredentials(
      String username, String password) async {
    final users = await getAllUsers();
    
    try {
      return users.firstWhere(
        (user) => 
          user['role'] == 'Admin' &&
          (user['username'] == username || user['email'] == username) && 
          user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Save current logged-in user
  Future<bool> saveCurrentUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_currentUserKey, jsonEncode(userData));
    } catch (e) {
      print('Error saving current user: $e');
      return false;
    }
  }

  // Get current logged-in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  // Clear all data (for testing)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
