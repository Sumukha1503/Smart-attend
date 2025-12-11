/// Leave Request Model
/// Represents a leave application submitted by a student
class LeaveRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String studentUsn;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveType leaveType;
  final List<String> documents; // URLs to uploaded documents
  final LeaveStatus status;
  final DateTime appliedAt;
  final String? reviewedBy;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final String? reviewComments;

  LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentUsn,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
    this.documents = const [],
    required this.status,
    required this.appliedAt,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
    this.reviewComments,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentUsn': studentUsn,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'leaveType': leaveType.name,
      'documents': documents,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewerName': reviewerName,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewComments': reviewComments,
    };
  }

  /// Create from Firestore document
  factory LeaveRequest.fromFirestore(Map<String, dynamic> data) {
    return LeaveRequest(
      id: data['id'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentUsn: data['studentUsn'] ?? '',
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      reason: data['reason'] ?? '',
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == data['leaveType'],
        orElse: () => LeaveType.general,
      ),
      documents: List<String>.from(data['documents'] ?? []),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => LeaveStatus.pending,
      ),
      appliedAt: DateTime.parse(data['appliedAt']),
      reviewedBy: data['reviewedBy'],
      reviewerName: data['reviewerName'],
      reviewedAt: data['reviewedAt'] != null ? DateTime.parse(data['reviewedAt']) : null,
      reviewComments: data['reviewComments'],
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() => toFirestore();

  /// Create from Map
  factory LeaveRequest.fromMap(Map<String, dynamic> data) => LeaveRequest.fromFirestore(data);

  /// Get number of days
  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if leave is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Copy with method
  LeaveRequest copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentUsn,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveType? leaveType,
    List<String>? documents,
    LeaveStatus? status,
    DateTime? appliedAt,
    String? reviewedBy,
    String? reviewerName,
    DateTime? reviewedAt,
    String? reviewComments,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentUsn: studentUsn ?? this.studentUsn,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      leaveType: leaveType ?? this.leaveType,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }
}

/// Leave Type Enum
enum LeaveType {
  medical,
  emergency,
  general,
  family,
  other,
}

/// Leave Status Enum
enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

/// Extension for LeaveType
extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.medical:
        return 'Medical Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.general:
        return 'General Leave';
      case LeaveType.family:
        return 'Family Emergency';
      case LeaveType.other:
        return 'Other';
    }
  }
}

/// Extension for LeaveStatus
extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == LeaveStatus.pending;
  bool get isApproved => this == LeaveStatus.approved;
  bool get isRejected => this == LeaveStatus.rejected;
  bool get isCancelled => this == LeaveStatus.cancelled;
}
