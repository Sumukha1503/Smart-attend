import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/demo_data_service.dart';

class DepartmentStatsPage extends StatefulWidget {
  const DepartmentStatsPage({super.key});

  @override
  State<DepartmentStatsPage> createState() => _DepartmentStatsPageState();
}

class _DepartmentStatsPageState extends State<DepartmentStatsPage> {
  final DemoDataService _demoDataService = DemoDataService();
  int _studentCount = 0;
  int _facultyCount = 0;
  double _avgAttendance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final students = await _demoDataService.getStudents();
    final faculty = await _demoDataService.getFaculty();
    
    setState(() {
      _studentCount = students.length;
      _facultyCount = faculty.length;
      _avgAttendance = 85.5; // Dummy value for now
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Department Stats')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  context,
                  title: 'Average Attendance',
                  value: '${_avgAttendance.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Students',
                        value: '$_studentCount',
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Faculty',
                        value: '$_facultyCount',
                        icon: Icons.school,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Attendance Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()}%',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              String text;
                              switch (value.toInt()) {
                                case 0:
                                  text = 'Mon';
                                  break;
                                case 1:
                                  text = 'Tue';
                                  break;
                                case 2:
                                  text = 'Wed';
                                  break;
                                case 3:
                                  text = 'Thu';
                                  break;
                                case 4:
                                  text = 'Fri';
                                  break;
                                default:
                                  return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(text, style: style),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: Colors.blue)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 90, color: Colors.blue)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 78, color: Colors.blue)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 82, color: Colors.blue)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 88, color: Colors.blue)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
