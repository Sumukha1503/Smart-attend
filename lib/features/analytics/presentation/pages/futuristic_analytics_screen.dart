import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/attendance_prediction_service.dart';
import '../../../../core/constants/app_routes.dart';

class FuturisticAnalyticsScreen extends StatefulWidget {
  const FuturisticAnalyticsScreen({super.key});

  @override
  State<FuturisticAnalyticsScreen> createState() =>
      _FuturisticAnalyticsScreenState();
}

class _FuturisticAnalyticsScreenState extends State<FuturisticAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final DemoDataService _demoDataService = DemoDataService();
  final AttendancePredictionService _predictionService =
      AttendancePredictionService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _predictions = [];
  Map<String, dynamic> _stats = {};

  late AnimationController _terminalController;
  int _terminalLines = 0;

  @override
  void initState() {
    super.initState();
    _initTerminalAnimation();
    _loadAnalytics();
  }

  void _initTerminalAnimation() {
    _terminalController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _terminalController.addListener(() {
      setState(() {
        _terminalLines = (_terminalController.value * 5).floor();
      });
    });
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final students = await _demoDataService.getStudents();
      final courses = await _demoDataService.getSubjects();

      // Mock weekly data
      final weeklyData = List.generate(7, (index) {
        return {
          'day': index.toDouble(),
          'attendance': 70 + (index * 3).toDouble() + (index % 2 * 5),
        };
      });

      // Mock predictions
      final predictions = [
        {'label': 'Tomorrow', 'value': 85.0, 'confidence': 0.92},
        {'label': 'Next Week', 'value': 83.0, 'confidence': 0.85},
        {'label': 'Next Month', 'value': 80.0, 'confidence': 0.75},
      ];

      setState(() {
        _weeklyData = weeklyData;
        _predictions = predictions;
        _stats = {
          'totalStudents': students.length,
          'totalCourses': courses.length,
          'avgAttendance': 82.5,
          'atRisk': 8,
        };
        _isLoading = false;
      });

      _terminalController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AuroraBackground(
        child: CyberGrid(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  color: FuturisticTheme.neonCyan,
                  backgroundColor: FuturisticTheme.deepSpace,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(child: _buildHeader()),
                        SizedBox(height: 24.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildStatsGrid(),
                        ),
                        SizedBox(height: 24.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: _buildHolographicChart(),
                        ),
                        SizedBox(height: 24.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: _buildTerminalPredictions(),
                        ),
                        SizedBox(height: 24.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          child: _buildDistributionChart(),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: FuturisticTheme.neonCyan),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Icon(Icons.analytics, color: FuturisticTheme.neonMagenta, size: 24.sp),
          SizedBox(width: 8.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonMagentaGradient.createShader(bounds),
            child: Text(
              'ANALYTICS HOLOGRAM',
              style: FuturisticTheme.h4Futuristic.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYSTEM ANALYTICS',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonMagenta.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Real-Time Insights',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'STUDENTS',
            _stats['totalStudents'].toString(),
            Icons.people_outline,
            FuturisticTheme.neonCyan,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'COURSES',
            _stats['totalCourses'].toString(),
            Icons.book_outlined,
            FuturisticTheme.neonMagenta,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return NeonGlowContainer(
      glowColor: color,
      glowIntensity: 0.3,
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 12.h),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [color, color.withOpacity(0.7)])
                    .createShader(bounds),
            child: Text(
              value,
              style: FuturisticTheme.numericCounterSmall.copyWith(
                fontSize: 36.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: FuturisticTheme.labelTech.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicChart() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: FuturisticTheme.neonCyan, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'WEEKLY TREND ANALYSIS',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonCyan,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: FuturisticTheme.neonCyan.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: FuturisticTheme.captionTech.copyWith(
                            fontSize: 10.sp,
                            color: FuturisticTheme.neonCyan.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: FuturisticTheme.captionTech.copyWith(
                              fontSize: 10.sp,
                              color: FuturisticTheme.neonCyan.withOpacity(0.5),
                            ),
                          );
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
                    spots: _weeklyData
                        .map((data) =>
                            FlSpot(data['day'] as double, data['attendance'] as double))
                        .toList(),
                    isCurved: true,
                    gradient: FuturisticTheme.neonCyanGradient,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: FuturisticTheme.neonCyan,
                          strokeWidth: 2,
                          strokeColor: FuturisticTheme.deepSpace,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          FuturisticTheme.neonCyan.withOpacity(0.3),
                          FuturisticTheme.neonCyan.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalPredictions() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonGreen.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: FuturisticTheme.neonGreen, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'AI PREDICTIONS',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FuturisticTheme.neonGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTerminalLine('> Initializing AI prediction engine...', 0),
                _buildTerminalLine('> Loading historical data...', 1),
                _buildTerminalLine('> Running neural network analysis...', 2),
                _buildTerminalLine('> Generating forecasts...', 3),
                _buildTerminalLine('> Analysis complete.', 4),
                if (_terminalLines >= 5) ...[
                  SizedBox(height: 12.h),
                  ..._predictions.map((pred) => _buildPredictionRow(pred)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalLine(String text, int index) {
    if (_terminalLines <= index) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: FuturisticTheme.terminalText.copyWith(
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildPredictionRow(Map<String, dynamic> prediction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: FuturisticTheme.neonGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FuturisticTheme.neonGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction['label'],
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    color: FuturisticTheme.neonGreen,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Confidence: ${(prediction['confidence'] * 100).toInt()}%',
                  style: FuturisticTheme.captionTech.copyWith(
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${prediction['value'].toStringAsFixed(1)}%',
            style: FuturisticTheme.numericCounterSmall.copyWith(
              fontSize: 24.sp,
              color: FuturisticTheme.neonGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonMagenta.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: FuturisticTheme.neonMagenta, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'ATTENDANCE DISTRIBUTION',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonMagenta,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: FuturisticTheme.neonMagenta.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: FuturisticTheme.captionTech.copyWith(
                            fontSize: 10.sp,
                            color: FuturisticTheme.neonMagenta.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const ranges = ['<60', '60-75', '75-85', '>85'];
                        if (value.toInt() >= 0 && value.toInt() < ranges.length) {
                          return Text(
                            ranges[value.toInt()],
                            style: FuturisticTheme.captionTech.copyWith(
                              fontSize: 10.sp,
                              color: FuturisticTheme.neonMagenta.withOpacity(0.5),
                            ),
                          );
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
                  _buildBarGroup(0, 5, FuturisticTheme.plasmaRed),
                  _buildBarGroup(1, 12, FuturisticTheme.solarOrange),
                  _buildBarGroup(2, 25, FuturisticTheme.neonCyan),
                  _buildBarGroup(3, 35, FuturisticTheme.neonGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color, color.withOpacity(0.5)],
          ),
          width: 40.w,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
