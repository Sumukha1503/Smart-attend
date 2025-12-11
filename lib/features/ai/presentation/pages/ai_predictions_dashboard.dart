import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/attendance_prediction_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';

class AIPredictionsDashboard extends StatefulWidget {
  const AIPredictionsDashboard({super.key});

  @override
  State<AIPredictionsDashboard> createState() => _AIPredictionsDashboardState();
}

class _AIPredictionsDashboardState extends State<AIPredictionsDashboard> {
  final AttendancePredictionService _predictionService = AttendancePredictionService();
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();
  
  bool _isLoading = true;
  Map<String, dynamic> _predictionData = {};
  List<Map<String, dynamic>> _atRiskStudents = [];
  List<String> _recommendations = [];
  
  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }
  
  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      
      // For demo, use first course
      final courses = await _demoDataService.getSubjects();
      if (courses.isEmpty) return;
      
      final courseId = courses.first['id'];
      
      // Get predictions
      final predictions = await _predictionService.predictFutureAttendance(
        studentId: user.id,
        courseId: courseId,
        daysAhead: 7,
      );
      
      // Get at-risk students (for HOD/Faculty)
      final atRisk = await _predictionService.identifyAtRiskStudents(
        courseId: courseId,
      );
      
      // Get recommendations
      final recommendations = await _predictionService.generateRecommendations(
        studentId: user.id,
        courseId: courseId,
      );
      
      setState(() {
        _predictionData = predictions;
        _atRiskStudents = atRisk;
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading predictions: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Predictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPredictions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPredictions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Status
                    _buildCurrentStatus(),
                    const SizedBox(height: 24),
                    
                    // Prediction Chart
                    Text(
                      '7-Day Attendance Forecast',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildPredictionChart(),
                    const SizedBox(height: 24),
                    
                    // Recommendations
                    Text(
                      'AI Recommendations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendations(),
                    const SizedBox(height: 24),
                    
                    // At-Risk Students (for faculty/HOD)
                    if (_atRiskStudents.isNotEmpty) ...[
                      Text(
                        'At-Risk Students',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildAtRiskList(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildCurrentStatus() {
    final currentPercentage = _predictionData['currentPercentage'] ?? 0.0;
    final trend = _predictionData['trend'] ?? 'stable';
    
    Color trendColor = Colors.blue;
    IconData trendIcon = Icons.trending_flat;
    
    if (trend == 'improving') {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (trend == 'declining') {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentPercentage >= 75
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics,
                size: 48,
                color: currentPercentage >= 75 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Attendance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentPercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: currentPercentage >= 75 ? Colors.green : Colors.red,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trend.toUpperCase(),
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPredictionChart() {
    final predictions = _predictionData['predictions'] as List? ?? [];
    if (predictions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No prediction data available')),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < predictions.length) {
                        return Text('Day ${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: predictions.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value['predictedPercentage'] as double,
                    );
                  }).toList(),
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.purple.withOpacity(0.1),
                  ),
                ),
              ],
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecommendations() {
    if (_recommendations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recommendations available'),
        ),
      );
    }
    
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recommendations.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final recommendation = _recommendations[index];
          IconData icon = Icons.lightbulb_outline;
          Color color = Colors.blue;
          
          if (recommendation.contains('✅')) {
            icon = Icons.check_circle_outline;
            color = Colors.green;
          } else if (recommendation.contains('⚠️')) {
            icon = Icons.warning_amber;
            color = Colors.orange;
          } else if (recommendation.contains('🚨')) {
            icon = Icons.error_outline;
            color = Colors.red;
          }
          
          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(recommendation),
          );
        },
      ),
    );
  }
  
  Widget _buildAtRiskList() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _atRiskStudents.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final student = _atRiskStudents[index];
          final riskLevel = student['riskLevel'] as String;
          
          Color riskColor = Colors.orange;
          if (riskLevel == 'critical') riskColor = Colors.red;
          if (riskLevel == 'high') riskColor = Colors.deepOrange;
          if (riskLevel == 'medium') riskColor = Colors.orange;
          if (riskLevel == 'low') riskColor = Colors.yellow;
          
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: riskColor),
            ),
            title: Text(student['studentName']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USN: ${student['usn']}'),
                Text('Attendance: ${student['currentPercentage'].toStringAsFixed(1)}%'),
                Text('Classes Needed: ${student['classesNeeded']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                riskLevel.toUpperCase(),
                style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
