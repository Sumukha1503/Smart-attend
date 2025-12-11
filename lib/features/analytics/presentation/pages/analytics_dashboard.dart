import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/attendance_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final DemoDataService _demoDataService = DemoDataService();
  final AttendanceService _attendanceService = AttendanceService();
  
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }
  
  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all students and courses
      final students = await _demoDataService.getStudents();
      final courses = await _demoDataService.getSubjects();
      
      // Calculate overall statistics
      int totalStudents = students.length;
      int totalCourses = courses.length;
      
      // Get attendance data for trend analysis
      List<Map<String, double>> weeklyData = [];
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        weeklyData.add({
          'day': i.toDouble(),
          'attendance': 70 + (i * 5).toDouble(), // Mock data - replace with real data
        });
      }
      
      // Calculate at-risk students
      int atRiskCount = 0;
      for (var student in students) {
        // Mock calculation - replace with real attendance data
        final percentage = 65 + (student['id'].hashCode % 30);
        if (percentage < 75) atRiskCount++;
      }
      
      setState(() {
        _analyticsData = {
          'totalStudents': totalStudents,
          'totalCourses': totalCourses,
          'averageAttendance': 82.5,
          'atRiskStudents': atRiskCount,
          'weeklyTrend': weeklyData,
          'topPerformers': students.take(5).toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    
                    // Weekly Trend Chart
                    Text(
                      'Weekly Attendance Trend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyTrendChart(),
                    const SizedBox(height: 24),
                    
                    // Department Distribution
                    Text(
                      'Attendance Distribution',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDistributionChart(),
                    const SizedBox(height: 24),
                    
                    // Top Performers
                    Text(
                      'Top Performers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopPerformers(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Students',
          _analyticsData['totalStudents'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Courses',
          _analyticsData['totalCourses'].toString(),
          Icons.book,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Attendance',
          '${_analyticsData['averageAttendance']}%',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'At Risk',
          _analyticsData['atRiskStudents'].toString(),
          Icons.warning,
          Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyTrendChart() {
    final weeklyData = _analyticsData['weeklyTrend'] as List<Map<String, double>>;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
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
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(days[value.toInt()],
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
                  spots: weeklyData
                      .map((data) => FlSpot(data['day']!, data['attendance']!))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
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
  
  Widget _buildDistributionChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const ranges = ['<60%', '60-75%', '75-85%', '>85%'];
                      if (value.toInt() >= 0 && value.toInt() < ranges.length) {
                        return Text(ranges[value.toInt()],
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
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.red)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.orange)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 25, color: Colors.blue)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 35, color: Colors.green)]),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopPerformers() {
    final topPerformers = _analyticsData['topPerformers'] as List;
    
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topPerformers.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final student = topPerformers[index];
          final percentage = 85 + (5 - index) * 2; // Mock data
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(student['name']),
            subtitle: Text(student['usn']),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
