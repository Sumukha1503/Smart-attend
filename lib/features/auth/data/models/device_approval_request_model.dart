class DeviceApprovalRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String studentUsn;
  final String deviceId;
  final String deviceInfo;
  final DateTime requestedAt;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? department;

  DeviceApprovalRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentUsn,
    required this.deviceId,
    required this.deviceInfo,
    required this.requestedAt,
    required this.status,
    this.approvedAt,
    this.approvedBy,
    this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentUsn': studentUsn,
      'deviceId': deviceId,
      'deviceInfo': deviceInfo,
      'requestedAt': requestedAt.toIso8601String(),
      'status': status,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'department': department,
    };
  }

  factory DeviceApprovalRequest.fromJson(Map<String, dynamic> json) {
    return DeviceApprovalRequest(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentUsn: json['studentUsn'] as String,
      deviceId: json['deviceId'] as String,
      deviceInfo: json['deviceInfo'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      status: json['status'] as String,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      department: json['department'] as String?,
    );
  }
}
