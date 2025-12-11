import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  /// Generate attendance report PDF
  Future<File> generateAttendanceReportPdf({
    required String studentName,
    required String usn,
    required String courseName,
    required String courseCode,
    required List<Map<String, dynamic>> attendanceRecords,
    required double attendancePercentage,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader('Attendance Report'),
          pw.SizedBox(height: 20),
          
          // Student Info
          _buildInfoSection('Student Information', [
            {'label': 'Name', 'value': studentName},
            {'label': 'USN', 'value': usn},
            {'label': 'Course', 'value': '$courseCode - $courseName'},
            {'label': 'Report Date', 'value': DateFormat('dd MMM yyyy').format(DateTime.now())},
          ]),
          pw.SizedBox(height: 20),
          
          // Summary
          _buildSummaryBox(attendancePercentage, attendanceRecords.length),
          pw.SizedBox(height: 20),
          
          // Attendance Table
          _buildAttendanceTable(attendanceRecords),
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(pdf, 'attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Generate faculty course report PDF
  Future<File> generateFacultyCourseReportPdf({
    required String facultyName,
    required String courseName,
    required String courseCode,
    required String semester,
    required String section,
    required List<Map<String, dynamic>> studentAttendance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader('Faculty Course Report'),
          pw.SizedBox(height: 20),
          
          // Course Info
          _buildInfoSection('Course Information', [
            {'label': 'Course', 'value': '$courseCode - $courseName'},
            {'label': 'Faculty', 'value': facultyName},
            {'label': 'Semester', 'value': semester},
            {'label': 'Section', 'value': section},
            {'label': 'Total Students', 'value': studentAttendance.length.toString()},
          ]),
          pw.SizedBox(height: 20),
          
          // Student Attendance Table
          _buildStudentAttendanceTable(studentAttendance),
          pw.SizedBox(height: 20),
          
          // Statistics
          _buildStatistics(studentAttendance),
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(pdf, 'faculty_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Generate department summary PDF
  Future<File> generateDepartmentSummaryPdf({
    required String departmentName,
    required Map<String, dynamic> statistics,
    required List<Map<String, dynamic>> courseData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader('Department Summary Report'),
          pw.SizedBox(height: 20),
          
          // Department Info
          _buildInfoSection('Department Information', [
            {'label': 'Department', 'value': departmentName},
            {'label': 'Report Period', 'value': DateFormat('MMM yyyy').format(DateTime.now())},
            {'label': 'Total Courses', 'value': statistics['totalCourses'].toString()},
            {'label': 'Total Students', 'value': statistics['totalStudents'].toString()},
            {'label': 'Average Attendance', 'value': '${statistics['averageAttendance']}%'},
          ]),
          pw.SizedBox(height: 20),
          
          // Course-wise Data
          _buildCourseDataTable(courseData),
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(pdf, 'department_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // Helper methods for building PDF components

  pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Smart Attend',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildInfoSection(String title, List<Map<String, String>> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...info.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text(
                        '${item['label']}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Text(item['value']!),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryBox(double percentage, int totalClasses) {
    final color = percentage >= 75 ? PdfColors.green : PdfColors.red;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text(
                '${percentage.toStringAsFixed(1)}%',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.Text('Attendance'),
            ],
          ),
          pw.Column(
            children: [
              pw.Text(
                totalClasses.toString(),
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Total Classes'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAttendanceTable(List<Map<String, dynamic>> records) {
    return pw.Table.fromTextArray(
      headers: ['Date', 'Course', 'Status', 'Time'],
      data: records.map((record) => [
        DateFormat('dd MMM yyyy').format(DateTime.parse(record['date'])),
        record['courseName'],
        record['status'],
        record['time'] ?? 'N/A',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
    );
  }

  pw.Widget _buildStudentAttendanceTable(List<Map<String, dynamic>> students) {
    return pw.Table.fromTextArray(
      headers: ['USN', 'Name', 'Present', 'Absent', 'Percentage'],
      data: students.map((student) => [
        student['usn'],
        student['name'],
        student['present'].toString(),
        student['absent'].toString(),
        '${student['percentage']}%',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
    );
  }

  pw.Widget _buildCourseDataTable(List<Map<String, dynamic>> courses) {
    return pw.Table.fromTextArray(
      headers: ['Course Code', 'Course Name', 'Faculty', 'Avg Attendance'],
      data: courses.map((course) => [
        course['code'],
        course['name'],
        course['faculty'],
        '${course['avgAttendance']}%',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
    );
  }

  pw.Widget _buildStatistics(List<Map<String, dynamic>> students) {
    final avgAttendance = students.isEmpty
        ? 0.0
        : students.map((s) => s['percentage'] as double).reduce((a, b) => a + b) / students.length;
    final atRisk = students.where((s) => s['percentage'] < 75).length;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Statistics',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Class Average: ${avgAttendance.toStringAsFixed(1)}%'),
          pw.Text('Students at Risk: $atRisk'),
          pw.Text('Eligible for Exam: ${students.length - atRisk}'),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by Smart Attend',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.Text(
              DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Future<File> _savePdf(pw.Document pdf, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Print PDF
  Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Share PDF
  Future<void> sharePdf(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
  }
}
