import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/leave_request.dart';

/// Leave Management Service
/// Handles leave requests, approvals, and document uploads
class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'leaves';

  /// Submit a new leave request
  Future<void> submitLeaveRequest(LeaveRequest request) async {
    try {
      await _firestore.collection(_collection).doc(request.id).set(request.toFirestore());
      print('✅ Leave request submitted: ${request.id}');
    } catch (e) {
      print('❌ Error submitting leave request: $e');
      rethrow;
    }
  }

  /// Upload leave document (medical certificate, etc.)
  Future<String> uploadLeaveDocument({
    required String leaveId,
    required File file,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('leave_documents/$leaveId/$fileName');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Document uploaded: $fileName');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading document: $e');
      rethrow;
    }
  }

  /// Get leave requests for a student
  Future<List<LeaveRequest>> getStudentLeaves(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching student leaves: $e');
      return [];
    }
  }

  /// Get pending leave requests (for faculty/HOD approval)
  Future<List<LeaveRequest>> getPendingLeaves({String? courseId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .orderBy('appliedAt', descending: false);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching pending leaves: $e');
      return [];
    }
  }

  /// Get leave requests stream for real-time updates
  Stream<List<LeaveRequest>> getLeavesStream({
    String? studentId,
    LeaveStatus? status,
  }) {
    Query query = _firestore.collection(_collection);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Approve leave request
  Future<void> approveLeave({
    required String leaveId,
    required String reviewerId,
    required String reviewerName,
    String? comments,
  }) async {
    try {
      await _firestore.collection(_collection).doc(leaveId).update({
        'status': LeaveStatus.approved.name,
        'reviewedBy': reviewerId,
        'reviewerName': reviewerName,
        'reviewedAt': DateTime.now().toIso8601String(),
        if (comments != null) 'reviewComments': comments,
      });
      print('✅ Leave approved: $leaveId');
    } catch (e) {
      print('❌ Error approving leave: $e');
      rethrow;
    }
  }

  /// Reject leave request
  Future<void> rejectLeave({
    required String leaveId,
    required String reviewerId,
    required String reviewerName,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(leaveId).update({
        'status': LeaveStatus.rejected.name,
        'reviewedBy': reviewerId,
        'reviewerName': reviewerName,
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewComments': reason,
      });
      print('✅ Leave rejected: $leaveId');
    } catch (e) {
      print('❌ Error rejecting leave: $e');
      rethrow;
    }
  }

  /// Cancel leave request (by student)
  Future<void> cancelLeave(String leaveId) async {
    try {
      await _firestore.collection(_collection).doc(leaveId).update({
        'status': LeaveStatus.cancelled.name,
      });
      print('✅ Leave cancelled: $leaveId');
    } catch (e) {
      print('❌ Error cancelling leave: $e');
      rethrow;
    }
  }

  /// Get leave balance for a student
  Future<Map<String, int>> getLeaveBalance({
    required String studentId,
    required int medicalQuota,
    required int emergencyQuota,
    required int generalQuota,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: LeaveStatus.approved.name)
          .get();

      int medicalUsed = 0;
      int emergencyUsed = 0;
      int generalUsed = 0;

      for (var doc in snapshot.docs) {
        final leave = LeaveRequest.fromFirestore(doc.data());
        final days = leave.numberOfDays;

        switch (leave.leaveType) {
          case LeaveType.medical:
            medicalUsed += days;
            break;
          case LeaveType.emergency:
            emergencyUsed += days;
            break;
          case LeaveType.general:
            generalUsed += days;
            break;
          default:
            break;
        }
      }

      return {
        'medicalUsed': medicalUsed,
        'medicalRemaining': medicalQuota - medicalUsed,
        'emergencyUsed': emergencyUsed,
        'emergencyRemaining': emergencyQuota - emergencyUsed,
        'generalUsed': generalUsed,
        'generalRemaining': generalQuota - generalUsed,
      };
    } catch (e) {
      print('❌ Error calculating leave balance: $e');
      return {
        'medicalUsed': 0,
        'medicalRemaining': medicalQuota,
        'emergencyUsed': 0,
        'emergencyRemaining': emergencyQuota,
        'generalUsed': 0,
        'generalRemaining': generalQuota,
      };
    }
  }

  /// Get active leaves for a student
  Future<List<LeaveRequest>> getActiveLeaves(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: LeaveStatus.approved.name)
          .get();

      final now = DateTime.now();
      return snapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc.data()))
          .where((leave) => leave.isActive)
          .toList();
    } catch (e) {
      print('❌ Error fetching active leaves: $e');
      return [];
    }
  }

  /// Check if student has leave on a specific date
  Future<bool> hasLeaveOnDate({
    required String studentId,
    required DateTime date,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: LeaveStatus.approved.name)
          .get();

      for (var doc in snapshot.docs) {
        final leave = LeaveRequest.fromFirestore(doc.data());
        if (date.isAfter(leave.startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(leave.endDate.add(const Duration(days: 1)))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error checking leave on date: $e');
      return false;
    }
  }

  /// Get leave statistics for a student
  Future<Map<String, dynamic>> getLeaveStatistics(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .get();

      int totalRequests = snapshot.docs.length;
      int approved = 0;
      int rejected = 0;
      int pending = 0;
      int totalDays = 0;

      for (var doc in snapshot.docs) {
        final leave = LeaveRequest.fromFirestore(doc.data());

        switch (leave.status) {
          case LeaveStatus.approved:
            approved++;
            totalDays += leave.numberOfDays;
            break;
          case LeaveStatus.rejected:
            rejected++;
            break;
          case LeaveStatus.pending:
            pending++;
            break;
          default:
            break;
        }
      }

      return {
        'totalRequests': totalRequests,
        'approved': approved,
        'rejected': rejected,
        'pending': pending,
        'totalDays': totalDays,
        'approvalRate': totalRequests > 0 ? (approved / totalRequests) * 100 : 0.0,
      };
    } catch (e) {
      print('❌ Error calculating leave statistics: $e');
      return {
        'totalRequests': 0,
        'approved': 0,
        'rejected': 0,
        'pending': 0,
        'totalDays': 0,
        'approvalRate': 0.0,
      };
    }
  }

  /// Delete leave document
  Future<void> deleteLeaveDocument(String documentUrl) async {
    try {
      final ref = _storage.refFromURL(documentUrl);
      await ref.delete();
      print('✅ Document deleted');
    } catch (e) {
      print('❌ Error deleting document: $e');
      rethrow;
    }
  }

  /// Update leave request
  Future<void> updateLeaveRequest({
    required String leaveId,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveType? leaveType,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (startDate != null) updates['startDate'] = startDate.toIso8601String();
      if (endDate != null) updates['endDate'] = endDate.toIso8601String();
      if (reason != null) updates['reason'] = reason;
      if (leaveType != null) updates['leaveType'] = leaveType.name;

      if (updates.isNotEmpty) {
        await _firestore.collection(_collection).doc(leaveId).update(updates);
        print('✅ Leave request updated: $leaveId');
      }
    } catch (e) {
      print('❌ Error updating leave request: $e');
      rethrow;
    }
  }
}
