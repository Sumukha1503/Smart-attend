import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Enhanced Notification Service initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      return await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }
    
    return false;
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_attend_channel',
      'Smart Attend Notifications',
      channelDescription: 'Notifications for attendance and sessions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show session start notification
  Future<void> notifySessionStart({
    required String courseName,
    required String courseCode,
    required String facultyName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎓 Session Started',
      body: '$courseCode - $courseName by $facultyName',
      payload: 'session_start',
    );
  }

  /// Show session end notification
  Future<void> notifySessionEnd({
    required String courseName,
    required String courseCode,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⏰ Session Ended',
      body: '$courseCode - $courseName session has ended',
      payload: 'session_end',
    );
  }

  /// Show leave approval notification
  Future<void> notifyLeaveApproved({
    required String leaveType,
    required String startDate,
    required String endDate,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Leave Approved',
      body: 'Your $leaveType from $startDate to $endDate has been approved',
      payload: 'leave_approved',
    );
  }

  /// Show leave rejection notification
  Future<void> notifyLeaveRejected({
    required String leaveType,
    required String reason,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '❌ Leave Rejected',
      body: 'Your $leaveType was rejected. Reason: $reason',
      payload: 'leave_rejected',
    );
  }

  /// Show low attendance alert
  Future<void> notifyLowAttendance({
    required String courseName,
    required double percentage,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⚠️ Low Attendance Alert',
      body: 'Your attendance in $courseName is $percentage%. Minimum required: 75%',
      payload: 'low_attendance',
    );
  }

  /// Show course assignment notification (for faculty)
  Future<void> notifyCourseAssigned({
    required String courseName,
    required String courseCode,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📚 New Course Assigned',
      body: 'You have been assigned to $courseCode - $courseName',
      payload: 'course_assigned',
    );
  }

  /// Show attendance marked notification
  Future<void> notifyAttendanceMarked({
    required String courseName,
    required String status,
  }) async {
    final emoji = status == 'Present' ? '✅' : '❌';
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '$emoji Attendance Marked',
      body: 'Your attendance for $courseName has been marked as $status',
      payload: 'attendance_marked',
    );
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_attend_channel',
      'Smart Attend Notifications',
      channelDescription: 'Notifications for attendance and sessions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
