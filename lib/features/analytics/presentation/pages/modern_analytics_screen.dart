import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/modern_theme.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';

/// Modern Professional Analytics Screen
/// "Data Beauty" - Clean charts with smooth curves and gradients
class ModernAnalyticsScreen extends StatefulWidget {
  const ModernAnalyticsScreen({super.key});

  @override
  State<ModernAnalyticsScreen> createState() => _ModernAnalyticsScreenState();
}

class _ModernAnalyticsScreenState extends State<ModernAnalyticsScreen> {
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();

  String _userId = '';
  List<Map<String, dynamic>> _subjects = [];
  Map<String, double> _attendancePercentages = {};
  bool _isLoading = true;
  String _selectedPeriod = 'Month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await _authService.getCurrentUser();
    if (user != null) {
      _userId = user.id;
      _subjects = await _demoDataService.getSubjects();

      for (var subject in _subjects) {
        final percentage = await _demoDataService.getAttendancePercentage(
          _userId,
          subject['id'],
        );
        _attendancePercentages[subject['id']] = percentage;
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.offWhite,
      appBar: GlassAppBar(
        title: 'Analytics',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: ModernTheme.royalBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),

                    // Overall Stats
                    _buildOverallStats(),
                    const SizedBox(height: 24),

                    // Attendance Trend Chart
                    _buildAttendanceTrendCard(),
                    const SizedBox(height: 24),

                    // Subject-wise Breakdown
                    _buildSubjectBreakdownCard(),
                    const SizedBox(height: 24),

                    // Weekly Pattern
                    _buildWeeklyPatternCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Week', 'Month', 'Semester', 'Year'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedPeriod = period);
                  // Show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Showing data for: $period'),
                      duration: const Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ModernTheme.royalBlue
                        : ModernTheme.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected ? ModernTheme.softShadow : null,
                    border: Border.all(
                      color: isSelected
                          ? ModernTheme.royalBlue
                          : ModernTheme.borderLight,
                    ),
                  ),
                  child: Text(
                    period,
                    style: ModernTheme.labelBold.copyWith(
                      color: isSelected
                          ? ModernTheme.pureWhite
                          : ModernTheme.slateGrey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverallStats() {
    final avgAttendance = _attendancePercentages.isEmpty
        ? 0.0
        : _attendancePercentages.values.reduce((a, b) => a + b) /
            _attendancePercentages.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Overall',
            value: '${avgAttendance.toStringAsFixed(1)}%',
            icon: Icons.analytics_rounded,
            color: ModernTheme.royalBlue,
            trend: null, // Removed hardcoded trend
            trendUp: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total Subjects',
            value: '${_subjects.length}',
            icon: Icons.book_rounded,
            color: ModernTheme.softEmerald,
            trend: null, // Removed hardcoded trend
            trendUp: true,
          ),
        ),
      ],
    );
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool trendUp = true,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced from 10 to 8
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20), // Reduced from 24 to 20
          ),
          const SizedBox(height: 12), // Reduced from 16 to 12
          Text(
            title,
            style: ModernTheme.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Flexible row to prevent overflow
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: ModernTheme.h2.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend != null) ...[ 
                  const SizedBox(width: 4), // Reduced from 8 to 4
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
                      decoration: BoxDecoration(
                        color: (trendUp ? ModernTheme.softEmerald : ModernTheme.rose)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 10, // Reduced from 12 to 10
                            color: trendUp ? ModernTheme.softEmerald : ModernTheme.rose,
                          ),
                          const SizedBox(width: 2), // Reduced from 4 to 2
                          Flexible(
                            child: Text(
                              trend,
                              style: ModernTheme.caption.copyWith(
                                color: trendUp ? ModernTheme.softEmerald : ModernTheme.rose,
                                fontWeight: FontWeight.w600,
                                fontSize: 10, // Smaller font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrendCard() {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance Trend', style: ModernTheme.h4),
              StatusChip.good('Improving'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: ModernTheme.borderLight,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: ModernTheme.caption,
                            ),
                          );
                        }
                        return const SizedBox();
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
                          style: ModernTheme.caption,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 75),
                      const FlSpot(1, 78),
                      const FlSpot(2, 82),
                      const FlSpot(3, 85),
                      const FlSpot(4, 88),
                      const FlSpot(5, 90),
                    ],
                    isCurved: true,
                    color: ModernTheme.royalBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: ModernTheme.pureWhite,
                          strokeWidth: 2,
                          strokeColor: ModernTheme.royalBlue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ModernTheme.royalBlue.withOpacity(0.3),
                          ModernTheme.royalBlue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => ModernTheme.darkSlate,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%',
                          ModernTheme.caption.copyWith(
                            color: ModernTheme.pureWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdownCard() {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject-wise Breakdown', style: ModernTheme.h4),
          const SizedBox(height: 20),
          if (_subjects.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.slateGrey,
                  ),
                ),
              ),
            )
          else
            ..._subjects.map((subject) {
              final percentage = _attendancePercentages[subject['id']] ?? 0.0;
              return _buildSubjectProgressBar(
                subject['name'],
                percentage,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubjectProgressBar(String name, double percentage) {
    final color = ModernTheme.getAttendanceColor(percentage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: ModernTheme.labelBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: ModernTheme.labelBold.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: ModernTheme.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPatternCard() {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Pattern', style: ModernTheme.h4),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => ModernTheme.darkSlate,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(0)}%',
                        ModernTheme.caption.copyWith(
                          color: ModernTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: ModernTheme.caption,
                            ),
                          );
                        }
                        return const SizedBox();
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
                          style: ModernTheme.caption,
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: ModernTheme.borderLight,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 85),
                  _buildBarGroup(1, 90),
                  _buildBarGroup(2, 88),
                  _buildBarGroup(3, 92),
                  _buildBarGroup(4, 87),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              ModernTheme.royalBlue,
              ModernTheme.deepIndigo,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ModernTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ModernTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Filter Options', style: ModernTheme.h3),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Range'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Subjects'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Report'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
