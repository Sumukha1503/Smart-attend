import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

/// Excel Report Generation Service
/// Generates comprehensive attendance reports in Excel format
class ExcelReportService {
  static final ExcelReportService _instance = ExcelReportService._internal();
  factory ExcelReportService() => _instance;
  ExcelReportService._internal();

  /// Generate Faculty Course Report
  /// 
  /// Creates a detailed Excel report for a specific course with:
  /// - Course and faculty details
  /// - Student-wise attendance table
  /// - Summary statistics
  /// - Color-coded status indicators
  Future<File> generateFacultyCourseReport({
    required String courseCode,
    required String courseName,
    required String facultyName,
    required String semester,
    required String section,
    required int totalClasses,
    required List<Map<String, dynamic>> studentAttendance,
    String? startDate,
    String? endDate,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance_Report'];

    // Set column widths
    sheet.setColumnWidth(0, 8);  // Sl No
    sheet.setColumnWidth(1, 12); // Roll No
    sheet.setColumnWidth(2, 25); // Student Name
    sheet.setColumnWidth(3, 15); // USN
    sheet.setColumnWidth(4, 10); // Present
    sheet.setColumnWidth(5, 10); // Absent
    sheet.setColumnWidth(6, 10); // Leave
    sheet.setColumnWidth(7, 10); // Total
    sheet.setColumnWidth(8, 12); // Percentage
    sheet.setColumnWidth(9, 10); // Status

    int currentRow = 0;

    // Header Section
    _addHeaderCell(sheet, currentRow, 0, 'ATTENDANCE REPORT', colspan: 10);
    currentRow += 2;

    // Course Details
    _addCell(sheet, currentRow, 0, 'Course:', bold: true);
    _addCell(sheet, currentRow, 1, '$courseCode - $courseName', colspan: 3);
    _addCell(sheet, currentRow, 5, 'Semester:', bold: true);
    _addCell(sheet, currentRow, 6, semester);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Faculty:', bold: true);
    _addCell(sheet, currentRow, 1, facultyName, colspan: 3);
    _addCell(sheet, currentRow, 5, 'Section:', bold: true);
    _addCell(sheet, currentRow, 6, section);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Total Classes:', bold: true);
    _addCell(sheet, currentRow, 1, totalClasses.toString());
    _addCell(sheet, currentRow, 5, 'Period:', bold: true);
    _addCell(sheet, currentRow, 6, startDate != null && endDate != null 
        ? '$startDate to $endDate' 
        : 'Full Semester');
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Generated On:', bold: true);
    _addCell(sheet, currentRow, 1, DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now()), colspan: 3);
    currentRow += 2;

    // Table Headers
    final headers = ['Sl', 'Roll', 'Student Name', 'USN', 'P', 'A', 'L', 'Tot', '%', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      _addCell(sheet, currentRow, i, headers[i], bold: true, backgroundColor: '#4CAF50');
    }
    currentRow++;

    // Student Data
    int slNo = 1;
    double totalPercentage = 0;
    int atRiskCount = 0;
    String? highestStudent;
    double highestPercentage = 0;
    String? lowestStudent;
    double lowestPercentage = 100;

    for (var student in studentAttendance) {
      final present = student['present'] ?? 0;
      final absent = student['absent'] ?? 0;
      final leave = student['leave'] ?? 0;
      final total = present + absent + leave;
      final percentage = total > 0 ? (present / total) * 100 : 0.0;

      // Track statistics
      totalPercentage += percentage;
      if (percentage < 75) atRiskCount++;
      if (percentage > highestPercentage) {
        highestPercentage = percentage;
        highestStudent = student['name'];
      }
      if (percentage < lowestPercentage) {
        lowestPercentage = percentage;
        lowestStudent = student['name'];
      }

      // Add row
      _addCell(sheet, currentRow, 0, slNo.toString());
      _addCell(sheet, currentRow, 1, student['rollNo'] ?? '');
      _addCell(sheet, currentRow, 2, student['name'] ?? '');
      _addCell(sheet, currentRow, 3, student['usn'] ?? '');
      _addCell(sheet, currentRow, 4, present.toString());
      _addCell(sheet, currentRow, 5, absent.toString());
      _addCell(sheet, currentRow, 6, leave.toString());
      _addCell(sheet, currentRow, 7, total.toString());
      _addCell(sheet, currentRow, 8, '${percentage.toStringAsFixed(1)}%');
      
      // Status with color coding
      String status;
      String bgColor;
      if (percentage >= 85) {
        status = '🟢';
        bgColor = '#C8E6C9';
      } else if (percentage >= 75) {
        status = '🟠';
        bgColor = '#FFE0B2';
      } else {
        status = '🔴';
        bgColor = '#FFCDD2';
      }
      _addCell(sheet, currentRow, 9, status, backgroundColor: bgColor);

      slNo++;
      currentRow++;
    }

    currentRow += 2;

    // Summary Section
    final avgPercentage = studentAttendance.isNotEmpty 
        ? totalPercentage / studentAttendance.length 
        : 0.0;
    final examEligible = studentAttendance.where((s) {
      final p = s['present'] ?? 0;
      final total = (s['present'] ?? 0) + (s['absent'] ?? 0) + (s['leave'] ?? 0);
      return total > 0 && (p / total) * 100 >= 75;
    }).length;

    _addCell(sheet, currentRow, 0, 'SUMMARY', bold: true, backgroundColor: '#2196F3', colspan: 10);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Highest Attendance:', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, '$highestStudent (${highestPercentage.toStringAsFixed(1)}%)', colspan: 3);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Lowest Attendance:', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, '$lowestStudent (${lowestPercentage.toStringAsFixed(1)}%)', colspan: 3);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Class Average:', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, '${avgPercentage.toStringAsFixed(1)}%', colspan: 3);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'At-Risk Students (<75%):', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, atRiskCount.toString(), colspan: 3);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Exam Eligible (≥75%):', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, examEligible.toString(), colspan: 3);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'Exam Ineligible (<75%):', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, (studentAttendance.length - examEligible).toString(), colspan: 3);
    currentRow += 3;

    // Signature Section
    _addCell(sheet, currentRow, 0, 'Faculty Signature:', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, '___________________', colspan: 3);
    _addCell(sheet, currentRow, 6, 'Date:', bold: true);
    _addCell(sheet, currentRow, 7, '___________', colspan: 2);
    currentRow++;

    _addCell(sheet, currentRow, 0, 'HOD Verification:', bold: true, colspan: 2);
    _addCell(sheet, currentRow, 2, '___________________', colspan: 3);
    currentRow++;

    // Save file
    final fileName = 'Attendance_${courseCode}_${DateFormat('ddMMMyyy').format(DateTime.now())}.xlsx';
    return await _saveExcelFile(excel, fileName);
  }

  /// Generate HOD Department Report
  /// 
  /// Creates a comprehensive department-wide report with multiple sheets
  Future<File> generateHODDepartmentReport({
    required String department,
    required List<Map<String, dynamic>> courses,
    required Map<String, List<Map<String, dynamic>>> courseAttendance,
  }) async {
    final excel = Excel.createExcel();

    // Sheet 1: Department Summary
    final summarySheet = excel['Department_Summary'];
    _createDepartmentSummarySheet(summarySheet, department, courses);

    // Sheet 2: Faculty Performance
    final facultySheet = excel['Faculty_Performance'];
    _createFacultyPerformanceSheet(facultySheet, courses);

    // Sheet 3: Shortage Report
    final shortageSheet = excel['Shortage_Report'];
    _createShortageReportSheet(shortageSheet, courseAttendance);

    // Remove default sheet
    excel.delete('Sheet1');

    // Save file
    final fileName = 'Department_Report_${department}_${DateFormat('ddMMMyyy').format(DateTime.now())}.xlsx';
    return await _saveExcelFile(excel, fileName);
  }

  /// Helper method to add a cell
  void _addCell(
    Sheet sheet,
    int row,
    int col,
    dynamic value, {
    bool bold = false,
    String? backgroundColor,
    int colspan = 1,
  }) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value.toString());
    
    if (bold || backgroundColor != null) {
      cell.cellStyle = CellStyle(
        bold: bold,
        backgroundColorHex: backgroundColor != null ? ExcelColor.fromHexString(backgroundColor) : null,
      );
    }
  }

  /// Helper method to add header cell
  void _addHeaderCell(Sheet sheet, int row, int col, String value, {int colspan = 1}) {
    _addCell(
      sheet,
      row,
      col,
      value,
      bold: true,
      backgroundColor: '#1976D2',
    );
  }

  /// Create department summary sheet
  void _createDepartmentSummarySheet(
    Sheet sheet,
    String department,
    List<Map<String, dynamic>> courses,
  ) {
    int row = 0;
    _addHeaderCell(sheet, row, 0, 'DEPARTMENT SUMMARY - $department', colspan: 6);
    row += 2;

    // Headers
    final headers = ['Course Code', 'Course Name', 'Faculty', 'Students', 'Avg %', 'At-Risk'];
    for (int i = 0; i < headers.length; i++) {
      _addCell(sheet, row, i, headers[i], bold: true, backgroundColor: '#4CAF50');
    }
    row++;

    // Course data
    for (var course in courses) {
      _addCell(sheet, row, 0, course['code'] ?? '');
      _addCell(sheet, row, 1, course['name'] ?? '');
      _addCell(sheet, row, 2, course['faculty'] ?? '');
      _addCell(sheet, row, 3, course['studentCount'] ?? 0);
      _addCell(sheet, row, 4, '${course['avgAttendance'] ?? 0}%');
      _addCell(sheet, row, 5, course['atRiskCount'] ?? 0);
      row++;
    }
  }

  /// Create faculty performance sheet
  void _createFacultyPerformanceSheet(
    Sheet sheet,
    List<Map<String, dynamic>> courses,
  ) {
    int row = 0;
    _addHeaderCell(sheet, row, 0, 'FACULTY PERFORMANCE', colspan: 5);
    row += 2;

    // Headers
    final headers = ['Faculty Name', 'Courses', 'Students', 'Avg %', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      _addCell(sheet, row, i, headers[i], bold: true, backgroundColor: '#4CAF50');
    }
    row++;

    // Faculty data (grouped by faculty)
    final facultyMap = <String, Map<String, dynamic>>{};
    for (var course in courses) {
      final facultyName = course['faculty'] ?? 'Unknown';
      if (!facultyMap.containsKey(facultyName)) {
        facultyMap[facultyName] = {
          'courses': 0,
          'students': 0,
          'totalAvg': 0.0,
        };
      }
      facultyMap[facultyName]!['courses'] = (facultyMap[facultyName]!['courses'] as int) + 1;
      facultyMap[facultyName]!['students'] = (facultyMap[facultyName]!['students'] as int) + (course['studentCount'] ?? 0);
      facultyMap[facultyName]!['totalAvg'] = (facultyMap[facultyName]!['totalAvg'] as double) + (course['avgAttendance'] ?? 0.0);
    }

    facultyMap.forEach((name, data) {
      final avgPercentage = data['courses'] > 0 ? data['totalAvg'] / data['courses'] : 0.0;
      _addCell(sheet, row, 0, name);
      _addCell(sheet, row, 1, data['courses'].toString());
      _addCell(sheet, row, 2, data['students'].toString());
      _addCell(sheet, row, 3, '${avgPercentage.toStringAsFixed(1)}%');
      _addCell(sheet, row, 4, avgPercentage >= 80 ? '✅ Good' : '⚠️ Needs Attention');
      row++;
    });
  }

  /// Create shortage report sheet
  void _createShortageReportSheet(
    Sheet sheet,
    Map<String, List<Map<String, dynamic>>> courseAttendance,
  ) {
    int row = 0;
    _addHeaderCell(sheet, row, 0, 'SHORTAGE REPORT (Students <75%)', colspan: 5);
    row += 2;

    // Headers
    final headers = ['Course', 'Roll No', 'Student Name', 'Attendance %', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      _addCell(sheet, row, i, headers[i], bold: true, backgroundColor: '#F44336');
    }
    row++;

    // At-risk students
    courseAttendance.forEach((courseCode, students) {
      for (var student in students) {
        final percentage = student['percentage'] ?? 0.0;
        if (percentage < 75) {
          _addCell(sheet, row, 0, courseCode);
          _addCell(sheet, row, 1, student['rollNo'] ?? '');
          _addCell(sheet, row, 2, student['name'] ?? '');
          _addCell(sheet, row, 3, '${percentage.toStringAsFixed(1)}%');
          _addCell(sheet, row, 4, '🔴 Critical', backgroundColor: '#FFCDD2');
          row++;
        }
      }
    });
  }

  /// Save Excel file to device
  Future<File> _saveExcelFile(Excel excel, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file;
  }

  /// Open generated Excel file
  Future<void> openExcelFile(File file) async {
    await OpenFilex.open(file.path);
  }
}
