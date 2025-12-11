import 'dart:math';
import '../services/attendance_service.dart';
import '../services/demo_data_service.dart';

class AttendancePredictionService {
  static final AttendancePredictionService _instance = AttendancePredictionService._internal();
  factory AttendancePredictionService() => _instance;
  AttendancePredictionService._internal();

  final AttendanceService _attendanceService = AttendanceService();
  final DemoDataService _demoDataService = DemoDataService();

  /// Predict future attendance percentage
  Future<Map<String, dynamic>> predictFutureAttendance({
    required String studentId,
    required String courseId,
    required int daysAhead,
  }) async {
    try {
      // Get historical attendance data
      final currentSummary = await _attendanceService.calculateAttendancePercentage(
        studentId: studentId,
        courseId: courseId,
      );

      final currentPercentage = currentSummary['percentage'] as double;
      final totalClasses = currentSummary['totalClasses'] as int;
      final presentClasses = currentSummary['presentClasses'] as int;

      // Simple linear prediction based on current trend
      // In production, use more sophisticated ML models
      final attendanceRate = totalClasses > 0 ? presentClasses / totalClasses : 0.0;
      
      // Predict with slight randomness to simulate real behavior
      final random = Random();
      final variance = 0.05; // 5% variance
      
      List<Map<String, dynamic>> predictions = [];
      double predictedPercentage = currentPercentage;
      
      for (int i = 1; i <= daysAhead; i++) {
        // Simulate attendance probability
        final willAttend = random.nextDouble() < (attendanceRate + (random.nextDouble() * variance - variance / 2));
        
        final newTotal = totalClasses + i;
        final newPresent = presentClasses + (willAttend ? i : (i * attendanceRate).round());
        predictedPercentage = (newPresent / newTotal) * 100;
        
        predictions.add({
          'day': i,
          'date': DateTime.now().add(Duration(days: i)).toIso8601String(),
          'predictedPercentage': predictedPercentage,
          'willAttend': willAttend,
          'confidence': _calculateConfidence(totalClasses, i),
        });
      }

      return {
        'currentPercentage': currentPercentage,
        'predictions': predictions,
        'trend': _analyzeTrend(predictions),
        'recommendation': _generateRecommendation(currentPercentage, predictions.last['predictedPercentage']),
      };
    } catch (e) {
      print('Error predicting attendance: $e');
      return {
        'error': e.toString(),
        'currentPercentage': 0.0,
        'predictions': [],
      };
    }
  }

  /// Calculate classes needed to reach target percentage
  Future<Map<String, dynamic>> calculateClassesNeeded({
    required String studentId,
    required String courseId,
    required double targetPercentage,
  }) async {
    try {
      final summary = await _attendanceService.calculateAttendancePercentage(
        studentId: studentId,
        courseId: courseId,
      );

      final currentPercentage = summary['percentage'] as double;
      final totalClasses = summary['totalClasses'] as int;
      final presentClasses = summary['presentClasses'] as int;

      if (currentPercentage >= targetPercentage) {
        return {
          'classesNeeded': 0,
          'message': 'Target already achieved!',
          'currentPercentage': currentPercentage,
          'targetPercentage': targetPercentage,
        };
      }

      // Calculate classes needed
      // Formula: (P + x) / (T + x) = target/100
      // Solving for x: x = (target*T - 100*P) / (100 - target)
      final x = ((targetPercentage * totalClasses) - (100 * presentClasses)) / (100 - targetPercentage);
      final classesNeeded = x.ceil();

      return {
        'classesNeeded': classesNeeded,
        'message': 'Attend next $classesNeeded consecutive classes',
        'currentPercentage': currentPercentage,
        'targetPercentage': targetPercentage,
        'projectedPercentage': ((presentClasses + classesNeeded) / (totalClasses + classesNeeded)) * 100,
      };
    } catch (e) {
      print('Error calculating classes needed: $e');
      return {
        'error': e.toString(),
        'classesNeeded': 0,
      };
    }
  }

  /// Identify at-risk students using ML-like pattern recognition
  Future<List<Map<String, dynamic>>> identifyAtRiskStudents({
    required String courseId,
    double riskThreshold = 75.0,
  }) async {
    try {
      final students = await _demoDataService.getStudents();
      List<Map<String, dynamic>> atRiskStudents = [];

      for (var student in students) {
        final summary = await _attendanceService.calculateAttendancePercentage(
          studentId: student['id'],
          courseId: courseId,
        );

        final percentage = summary['percentage'] as double;
        
        if (percentage < riskThreshold) {
          // Calculate risk score (0-100, higher = more risk)
          final riskScore = _calculateRiskScore(
            percentage: percentage,
            totalClasses: summary['totalClasses'] as int,
            threshold: riskThreshold,
          );

          atRiskStudents.add({
            'studentId': student['id'],
            'studentName': student['name'],
            'usn': student['usn'],
            'currentPercentage': percentage,
            'riskScore': riskScore,
            'riskLevel': _getRiskLevel(riskScore),
            'classesNeeded': await _getClassesNeededForStudent(
              student['id'],
              courseId,
              riskThreshold,
            ),
            'trend': _predictTrend(percentage, summary['totalClasses'] as int),
          });
        }
      }

      // Sort by risk score (highest first)
      atRiskStudents.sort((a, b) => (b['riskScore'] as double).compareTo(a['riskScore'] as double));

      return atRiskStudents;
    } catch (e) {
      print('Error identifying at-risk students: $e');
      return [];
    }
  }

  /// Detect anomalies in attendance patterns
  Future<List<Map<String, dynamic>>> detectAnomalies({
    required String studentId,
    required String courseId,
  }) async {
    try {
      // Get attendance history
      // In production, analyze actual attendance records
      final summary = await _attendanceService.calculateAttendancePercentage(
        studentId: studentId,
        courseId: courseId,
      );

      List<Map<String, dynamic>> anomalies = [];

      // Detect sudden drops
      final percentage = summary['percentage'] as double;
      if (percentage < 60) {
        anomalies.add({
          'type': 'sudden_drop',
          'severity': 'high',
          'message': 'Attendance dropped below 60%',
          'recommendation': 'Immediate intervention required',
        });
      } else if (percentage < 75) {
        anomalies.add({
          'type': 'approaching_threshold',
          'severity': 'medium',
          'message': 'Attendance approaching minimum threshold',
          'recommendation': 'Monitor closely and encourage attendance',
        });
      }

      // Detect irregular patterns (mock data)
      final random = Random();
      if (random.nextDouble() < 0.3) {
        anomalies.add({
          'type': 'irregular_pattern',
          'severity': 'low',
          'message': 'Irregular attendance pattern detected',
          'recommendation': 'Check for personal issues or scheduling conflicts',
        });
      }

      return anomalies;
    } catch (e) {
      print('Error detecting anomalies: $e');
      return [];
    }
  }

  /// Generate smart recommendations
  Future<List<String>> generateRecommendations({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final summary = await _attendanceService.calculateAttendancePercentage(
        studentId: studentId,
        courseId: courseId,
      );

      final percentage = summary['percentage'] as double;
      List<String> recommendations = [];

      if (percentage >= 85) {
        recommendations.add('✅ Excellent attendance! Keep it up!');
        recommendations.add('💡 You can afford to miss 1-2 classes if needed');
      } else if (percentage >= 75) {
        recommendations.add('⚠️ You\'re at the minimum threshold');
        recommendations.add('💡 Attend all upcoming classes to maintain eligibility');
        recommendations.add('📚 Consider attending extra sessions if available');
      } else {
        final classesNeeded = await calculateClassesNeeded(
          studentId: studentId,
          courseId: courseId,
          targetPercentage: 75.0,
        );
        
        recommendations.add('🚨 Urgent: Attendance below minimum!');
        recommendations.add('💡 Attend next ${classesNeeded['classesNeeded']} consecutive classes');
        recommendations.add('📞 Contact faculty to discuss your situation');
        recommendations.add('📝 Submit medical/leave documents if applicable');
      }

      return recommendations;
    } catch (e) {
      print('Error generating recommendations: $e');
      return ['Error generating recommendations'];
    }
  }

  /// Predict optimal class schedule
  Map<String, dynamic> predictOptimalSchedule({
    required Map<String, double> courseAttendances,
    required int availableSlots,
  }) {
    // Sort courses by priority (lowest attendance first)
    final sortedCourses = courseAttendances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    List<String> priorityCourses = [];
    List<String> optionalCourses = [];

    for (var entry in sortedCourses) {
      if (entry.value < 75) {
        priorityCourses.add(entry.key);
      } else {
        optionalCourses.add(entry.key);
      }
    }

    return {
      'priorityCourses': priorityCourses,
      'optionalCourses': optionalCourses,
      'recommendation': priorityCourses.isEmpty
          ? 'All courses have good attendance. Maintain consistency!'
          : 'Focus on: ${priorityCourses.join(", ")}',
    };
  }

  // Helper methods

  double _calculateConfidence(int totalClasses, int daysAhead) {
    // Confidence decreases with prediction distance
    final baseConfidence = totalClasses > 20 ? 0.85 : 0.70;
    final decayRate = 0.02;
    return max(0.5, baseConfidence - (daysAhead * decayRate));
  }

  String _analyzeTrend(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) return 'insufficient_data';
    
    final first = predictions.first['predictedPercentage'] as double;
    final last = predictions.last['predictedPercentage'] as double;
    
    final diff = last - first;
    
    if (diff > 2) return 'improving';
    if (diff < -2) return 'declining';
    return 'stable';
  }

  String _generateRecommendation(double current, double predicted) {
    if (predicted < 75 && current >= 75) {
      return 'Warning: Attendance may drop below threshold. Attend all upcoming classes!';
    } else if (predicted >= 75 && current < 75) {
      return 'Good news: Consistent attendance will bring you above threshold!';
    } else if (predicted < 75) {
      return 'Critical: Immediate action required to improve attendance!';
    } else {
      return 'Maintain current attendance pattern to stay eligible.';
    }
  }

  double _calculateRiskScore({
    required double percentage,
    required int totalClasses,
    required double threshold,
  }) {
    // Risk score based on multiple factors
    final percentageGap = threshold - percentage;
    final dataReliability = min(1.0, totalClasses / 30.0);
    
    // Higher gap = higher risk
    // Less data = higher risk
    final riskScore = (percentageGap * 2) + ((1 - dataReliability) * 20);
    
    return min(100, max(0, riskScore));
  }

  String _getRiskLevel(double riskScore) {
    if (riskScore >= 70) return 'critical';
    if (riskScore >= 40) return 'high';
    if (riskScore >= 20) return 'medium';
    return 'low';
  }

  Future<int> _getClassesNeededForStudent(
    String studentId,
    String courseId,
    double targetPercentage,
  ) async {
    final result = await calculateClassesNeeded(
      studentId: studentId,
      courseId: courseId,
      targetPercentage: targetPercentage,
    );
    return result['classesNeeded'] as int;
  }

  String _predictTrend(double percentage, int totalClasses) {
    if (totalClasses < 10) return 'insufficient_data';
    if (percentage < 60) return 'critical_decline';
    if (percentage < 75) return 'declining';
    if (percentage < 85) return 'stable';
    return 'excellent';
  }
}
