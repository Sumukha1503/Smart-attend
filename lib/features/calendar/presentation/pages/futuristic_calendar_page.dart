import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';

class FuturisticCalendarPage extends StatefulWidget {
  const FuturisticCalendarPage({super.key});

  @override
  State<FuturisticCalendarPage> createState() => _FuturisticCalendarPageState();
}

class _FuturisticCalendarPageState extends State<FuturisticCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    // Mock events with neon markers
    final now = DateTime.now();
    _events = {
      DateTime(now.year, now.month, now.day): [
        {
          'course': 'CS201',
          'status': 'present',
          'time': '10:00 AM',
          'color': FuturisticTheme.neonGreen,
        },
        {
          'course': 'CS203',
          'status': 'present',
          'time': '2:00 PM',
          'color': FuturisticTheme.neonGreen,
        },
      ],
      DateTime(now.year, now.month, now.day - 1): [
        {
          'course': 'CS201',
          'status': 'absent',
          'time': '10:00 AM',
          'color': FuturisticTheme.plasmaRed,
        },
      ],
      DateTime(now.year, now.month, now.day - 2): [
        {
          'course': 'CS201',
          'status': 'present',
          'time': '10:00 AM',
          'color': FuturisticTheme.neonGreen,
        },
        {
          'course': 'CS203',
          'status': 'present',
          'time': '2:00 PM',
          'color': FuturisticTheme.neonGreen,
        },
        {
          'course': 'CS205',
          'status': 'present',
          'time': '4:00 PM',
          'color': FuturisticTheme.neonGreen,
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(child: _buildHeader()),
                SizedBox(height: 24.h),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildCalendar(),
                ),
                SizedBox(height: 24.h),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildEventsList(),
                ),
              ],
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
          Icon(Icons.calendar_today, color: FuturisticTheme.neonCyan, size: 24.sp),
          SizedBox(width: 8.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonCyanGradient.createShader(bounds),
            child: Text(
              'ATTENDANCE CALENDAR',
              style: FuturisticTheme.h4Futuristic.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.today, color: FuturisticTheme.neonCyan),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIMELINE VIEW',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Track Your Attendance',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          HapticFeedback.lightImpact();
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        // Styling
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: FuturisticTheme.neonCyan.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: FuturisticTheme.neonCyan,
              width: 2,
            ),
          ),
          todayTextStyle: FuturisticTheme.bodyTechBold.copyWith(
            color: FuturisticTheme.neonCyan,
          ),
          // Selected
          selectedDecoration: BoxDecoration(
            gradient: FuturisticTheme.neonCyanGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: FuturisticTheme.neonCyan.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          selectedTextStyle: FuturisticTheme.bodyTechBold.copyWith(
            color: Colors.white,
          ),
          // Default
          defaultTextStyle: FuturisticTheme.bodyTech.copyWith(
            fontSize: 14.sp,
          ),
          weekendTextStyle: FuturisticTheme.bodyTech.copyWith(
            fontSize: 14.sp,
            color: FuturisticTheme.neonMagenta.withOpacity(0.7),
          ),
          outsideTextStyle: FuturisticTheme.bodyTech.copyWith(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          // Markers
          markerDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(
              color: FuturisticTheme.neonCyan.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan,
          ),
          titleTextStyle: FuturisticTheme.h4Futuristic.copyWith(
            fontSize: 18.sp,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: FuturisticTheme.neonCyan,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: FuturisticTheme.neonCyan,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
          weekendStyle: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonMagenta.withOpacity(0.7),
          ),
        ),
        // Custom builders
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox.shrink();

            final eventList = events.cast<Map<String, dynamic>>();
            final hasPresent = eventList.any((e) => e['status'] == 'present');
            final hasAbsent = eventList.any((e) => e['status'] == 'absent');

            return Positioned(
              bottom: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasPresent)
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FuturisticTheme.neonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: FuturisticTheme.neonGreen.withOpacity(0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  if (hasAbsent)
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FuturisticTheme.plasmaRed,
                        boxShadow: [
                          BoxShadow(
                            color: FuturisticTheme.plasmaRed.withOpacity(0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);

    if (events.isEmpty) {
      return GlassContainer(
        padding: EdgeInsets.all(32.w),
        borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48.sp,
                color: FuturisticTheme.neonCyan.withOpacity(0.5),
              ),
              SizedBox(height: 12.h),
              Text(
                'No events for this day',
                style: FuturisticTheme.bodyTech.copyWith(
                  color: FuturisticTheme.neonCyan.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVENTS',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(
          events.length,
          (index) => FadeInUp(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: _buildEventCard(events[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return NeonGlowContainer(
      glowColor: event['color'],
      glowIntensity: 0.3,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [event['color'], event['color'].withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                event['status'] == 'present'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['course'],
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${event['time']} • ${event['status'].toUpperCase()}',
                  style: FuturisticTheme.captionTech.copyWith(
                    color: event['color'],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: event['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: event['color'].withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              event['status'] == 'present' ? 'P' : 'A',
              style: FuturisticTheme.bodyTechBold.copyWith(
                color: event['color'],
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
