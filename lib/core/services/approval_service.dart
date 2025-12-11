import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/auth/data/models/device_approval_request_model.dart';

class ApprovalService {
  static const String _approvalRequestsKey = 'approval_requests';
  static const String _approvedDevicesKey = 'approved_devices';

  // Submit approval request
  Future<bool> submitApprovalRequest(DeviceApprovalRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = await getAllApprovalRequests();
      
      // Add new request
      requests.add(request.toJson());
      
      // Save back to storage
      final requestsJson = requests.map((r) => jsonEncode(r)).toList();
      return await prefs.setStringList(_approvalRequestsKey, requestsJson);
    } catch (e) {
      print('Error submitting approval request: $e');
      return false;
    }
  }

  // Get all approval requests
  Future<List<Map<String, dynamic>>> getAllApprovalRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getStringList(_approvalRequestsKey) ?? [];
      
      return requestsJson
          .map((r) => jsonDecode(r) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting approval requests: $e');
      return [];
    }
  }

  // Get pending approval requests
  Future<List<DeviceApprovalRequest>> getPendingRequests() async {
    final requests = await getAllApprovalRequests();
    return requests
        .where((r) => r['status'] == 'pending')
        .map((r) => DeviceApprovalRequest.fromJson(r))
        .toList();
  }

  // Check if student has pending request for this device
  Future<bool> hasPendingRequest(String studentId, String deviceId) async {
    final requests = await getAllApprovalRequests();
    return requests.any((r) =>
        r['studentId'] == studentId &&
        r['deviceId'] == deviceId &&
        r['status'] == 'pending');
  }

  // Approve request
  Future<bool> approveRequest(String requestId, String approvedBy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = await getAllApprovalRequests();
      
      // Find and update request
      final index = requests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        requests[index]['status'] = 'approved';
        requests[index]['approvedAt'] = DateTime.now().toIso8601String();
        requests[index]['approvedBy'] = approvedBy;
        
        // Save updated requests
        final requestsJson = requests.map((r) => jsonEncode(r)).toList();
        await prefs.setStringList(_approvalRequestsKey, requestsJson);
        
        // Add to approved devices
        final request = requests[index];
        await _addApprovedDevice(request['studentId'], request['deviceId']);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  // Reject request
  Future<bool> rejectRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = await getAllApprovalRequests();
      
      // Find and update request
      final index = requests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        requests[index]['status'] = 'rejected';
        
        // Save updated requests
        final requestsJson = requests.map((r) => jsonEncode(r)).toList();
        return await prefs.setStringList(_approvalRequestsKey, requestsJson);
      }
      return false;
    } catch (e) {
      print('Error rejecting request: $e');
      return false;
    }
  }

  // Add approved device
  Future<bool> _addApprovedDevice(String studentId, String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final approvedDevices = await _getApprovedDevicesMap();
      
      if (!approvedDevices.containsKey(studentId)) {
        approvedDevices[studentId] = [];
      }
      
      if (!approvedDevices[studentId]!.contains(deviceId)) {
        approvedDevices[studentId]!.add(deviceId);
      }
      
      // Save back to storage
      return await prefs.setString(
        _approvedDevicesKey,
        jsonEncode(approvedDevices),
      );
    } catch (e) {
      print('Error adding approved device: $e');
      return false;
    }
  }

  // Check if device is approved for student
  Future<bool> isDeviceApproved(String studentId, String deviceId) async {
    final approvedDevices = await _getApprovedDevicesMap();
    return approvedDevices[studentId]?.contains(deviceId) ?? false;
  }

  // Get approved devices map
  Future<Map<String, List<String>>> _getApprovedDevicesMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString(_approvedDevicesKey);
      
      if (devicesJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(devicesJson);
        return decoded.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      }
      return {};
    } catch (e) {
      print('Error getting approved devices: $e');
      return {};
    }
  }

  // Get approval request for student and device
  Future<DeviceApprovalRequest?> getRequestForDevice(
      String studentId, String deviceId) async {
    final requests = await getAllApprovalRequests();
    try {
      final request = requests.firstWhere(
        (r) => r['studentId'] == studentId && r['deviceId'] == deviceId,
      );
      return DeviceApprovalRequest.fromJson(request);
    } catch (e) {
      return null;
    }
  }
}
