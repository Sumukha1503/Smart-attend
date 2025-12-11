import '../services/storage_service.dart';
import '../services/device_info_service.dart';
import '../services/approval_service.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/models/device_approval_request_model.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final ApprovalService _approvalService = ApprovalService();

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? usn,
    String? employeeId,
    String? department,
  }) async {
    try {
      // Check if email already exists
      final emailExists = await _storageService.emailExists(email);
      if (emailExists) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Validate USN for students
      if (role == 'Student' && (usn == null || usn.isEmpty)) {
        return {
          'success': false,
          'message': 'USN is required for students',
        };
      }

      // Validate Employee ID for Faculty and HOD
      if ((role == 'Faculty' || role == 'HOD') &&
          (employeeId == null || employeeId.isEmpty)) {
        return {
          'success': false,
          'message': 'Employee ID is required for $role',
        };
      }

      // Create user data
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'usn': usn,
        'employeeId': employeeId,
        'phone': null,
        'profilePicture': null,
        'department': department,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save user
      final saved = await _storageService.saveUser(userData);

      if (saved) {
        return {
          'success': true,
          'message': 'Registration successful',
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to save user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Login user (supports USN, Employee ID, and Admin username)
  Future<Map<String, dynamic>> login({
    required String identifier, // USN, Employee ID, or Username
    required String password,
  }) async {
    try {
      Map<String, dynamic>? user;
      String loginType = '';

      // Determine login type and verify credentials
      if (identifier.contains('@')) {
        // Email login (legacy support)
        user = await _storageService.verifyCredentials(identifier, password);
        loginType = 'email';
      } else if (identifier.toLowerCase().startsWith('admin') ||
          identifier.toLowerCase() == 'admin123') {
        // Admin login
        user = await _storageService.verifyAdminCredentials(
            identifier, password);
        loginType = 'admin';
      } else if (identifier.toUpperCase().contains('FAC') ||
          identifier.toUpperCase().contains('HOD')) {
        // Employee ID login (Faculty/HOD)
        user = await _storageService.verifyCredentialsByEmployeeId(
            identifier, password);
        loginType = 'employeeId';
      } else {
        // USN login (Student)
        user = await _storageService.verifyCredentialsByUsn(
            identifier, password);
        loginType = 'usn';
      }

      if (user != null) {
        // For students, check device approval
        if (user['role'] == 'Student') {
          final deviceId = await _deviceInfoService.getDeviceId();
          final isApproved = await _approvalService.isDeviceApproved(
            user['id'],
            deviceId,
          );

          if (!isApproved) {
            // Check if there's already a pending request
            final hasPending = await _approvalService.hasPendingRequest(
              user['id'],
              deviceId,
            );

            if (!hasPending) {
              // Create approval request
              final deviceInfo = await _deviceInfoService.getDeviceInfo();
              final request = DeviceApprovalRequest(
                id: 'REQ${DateTime.now().millisecondsSinceEpoch}',
                studentId: user['id'],
                studentName: user['name'],
                studentUsn: user['usn'],
                deviceId: deviceId,
                deviceInfo: deviceInfo,
                requestedAt: DateTime.now(),
                status: 'pending',
                department: user['department'],
              );

              await _approvalService.submitApprovalRequest(request);
            }

            return {
              'success': false,
              'needsApproval': true,
              'message': 'Approval request sent to HOD',
              'user': user,
            };
          }
        }

        // Save as current user
        await _storageService.saveCurrentUser(user);

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      } else {
        String errorMessage = 'Invalid credentials';
        if (loginType == 'usn') {
          errorMessage = 'Invalid USN or password';
        } else if (loginType == 'employeeId') {
          errorMessage = 'Invalid Employee ID or password';
        } else if (loginType == 'admin') {
          errorMessage = 'Invalid admin credentials';
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storageService.getCurrentUser();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout
  Future<bool> logout() async {
    return await _storageService.logout();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await _storageService.getCurrentUser();
    return user != null;
  }

  // Update user profile
  Future<bool> updateProfile({
    String? phone,
    String? profilePicture,
  }) async {
    try {
      final currentUser = await _storageService.getCurrentUser();
      if (currentUser == null) return false;

      if (phone != null) currentUser['phone'] = phone;
      if (profilePicture != null) {
        currentUser['profilePicture'] = profilePicture;
      }

      return await _storageService.saveCurrentUser(currentUser);
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
