import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isInitialized = false;

  /// Initialize biometric authentication
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    print('✅ Biometric Auth Service initialized');
  }

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  /// Check if device has biometric hardware
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        print('⚠️ Device does not support biometrics');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        print('✅ Biometric authentication successful');
        await _logAuthenticationEvent('success');
      } else {
        print('❌ Biometric authentication failed');
        await _logAuthenticationEvent('failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      await _logAuthenticationEvent('error: ${e.message}');
      return false;
    }
  }

  /// Authenticate for attendance marking
  Future<bool> authenticateForAttendance() async {
    return await authenticate(
      reason: 'Authenticate to mark attendance',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for session creation
  Future<bool> authenticateForSession() async {
    return await authenticate(
      reason: 'Authenticate to create session',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for sensitive data access
  Future<bool> authenticateForSensitiveData() async {
    return await authenticate(
      reason: 'Authenticate to access sensitive data',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Enable biometric authentication for user
  Future<bool> enableBiometricAuth(String userId) async {
    try {
      // First authenticate to enable
      final authenticated = await authenticate(
        reason: 'Authenticate to enable biometric login',
      );

      if (!authenticated) return false;

      // Store biometric preference
      await _secureStorage.write(
        key: 'biometric_enabled_$userId',
        value: 'true',
      );

      await _secureStorage.write(
        key: 'biometric_enabled_at',
        value: DateTime.now().toIso8601String(),
      );

      print('✅ Biometric authentication enabled for user: $userId');
      return true;
    } catch (e) {
      print('Error enabling biometric auth: $e');
      return false;
    }
  }

  /// Disable biometric authentication for user
  Future<void> disableBiometricAuth(String userId) async {
    try {
      await _secureStorage.delete(key: 'biometric_enabled_$userId');
      await _secureStorage.delete(key: 'biometric_enabled_at');
      print('✅ Biometric authentication disabled for user: $userId');
    } catch (e) {
      print('Error disabling biometric auth: $e');
    }
  }

  /// Check if biometric is enabled for user
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final enabled = await _secureStorage.read(key: 'biometric_enabled_$userId');
      return enabled == 'true';
    } catch (e) {
      print('Error checking biometric status: $e');
      return false;
    }
  }

  /// Store sensitive data securely
  Future<void> storeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      print('✅ Secure data stored: $key');
    } catch (e) {
      print('Error storing secure data: $e');
    }
  }

  /// Retrieve sensitive data securely
  Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error retrieving secure data: $e');
      return null;
    }
  }

  /// Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      print('✅ Secure data deleted: $key');
    } catch (e) {
      print('Error deleting secure data: $e');
    }
  }

  /// Clear all secure data
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      print('✅ All secure data cleared');
    } catch (e) {
      print('Error clearing secure data: $e');
    }
  }

  /// Log authentication event
  Future<void> _logAuthenticationEvent(String event) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logs = await _secureStorage.read(key: 'auth_logs') ?? '[]';
      final logList = logs.split(',');
      logList.add('$timestamp: $event');
      
      // Keep only last 50 logs
      if (logList.length > 50) {
        logList.removeRange(0, logList.length - 50);
      }
      
      await _secureStorage.write(key: 'auth_logs', value: logList.join(','));
    } catch (e) {
      print('Error logging authentication event: $e');
    }
  }

  /// Get authentication logs
  Future<List<String>> getAuthenticationLogs() async {
    try {
      final logs = await _secureStorage.read(key: 'auth_logs') ?? '';
      return logs.isEmpty ? [] : logs.split(',');
    } catch (e) {
      print('Error getting authentication logs: $e');
      return [];
    }
  }

  /// Get biometric capabilities info
  Future<Map<String, dynamic>> getBiometricInfo() async {
    final canCheck = await canCheckBiometrics();
    final isSupported = await isDeviceSupported();
    final availableBiometrics = await getAvailableBiometrics();

    return {
      'canCheckBiometrics': canCheck,
      'isDeviceSupported': isSupported,
      'availableBiometrics': availableBiometrics.map((e) => e.name).toList(),
      'hasFingerprint': availableBiometrics.contains(BiometricType.fingerprint),
      'hasFace': availableBiometrics.contains(BiometricType.face),
      'hasIris': availableBiometrics.contains(BiometricType.iris),
    };
  }

  /// Stop authentication (cancel ongoing authentication)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      print('✅ Authentication stopped');
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }
}
