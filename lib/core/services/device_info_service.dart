import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get unique device identifier
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android ID
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      } else {
        return 'unknown_platform';
      }
    } catch (e) {
      print('Error getting device ID: $e');
      return 'error_device_id';
    }
  }

  // Get device information as a readable string
  Future<String> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      print('Error getting device info: $e');
      return 'Unknown Device';
    }
  }

  // Get device model
  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
