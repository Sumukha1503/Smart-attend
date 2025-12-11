SmartAttend – Secure Attendance Tracking System
SmartAttend is a role-based attendance tracking system built with Flutter, designed for colleges to manage student attendance securely and transparently. It provides dedicated modules for students, faculty, and HOD/admin with strong device-level security, rich analytics, and automated report generation.​

Features
Student Module
Real-time subject-wise attendance with color-coded status (Good/Warning/Critical).​

Calendar view showing Present/Absent/Leave for each subject.​

Shortage alerts and configurable attendance thresholds (e.g., 75%).​

Leave application with reason, date range, and document upload, plus status tracking.​

Timetable, upcoming class reminders, and exam eligibility warnings based on attendance.​

Faculty Module
Fast bulk attendance marking (mark all present, toggle absentees).​

Class-wise views with student details and attendance statistics.​

Leave request approval / rejection for students.​

Defaulter list generation and shortage identification per subject.​

Course-level Excel/PDF report generation with student-wise percentages and status.​

HOD/Admin Module
Create and manage subjects, semesters, and faculty–subject mapping.​

Department-wide dashboards and consolidated attendance reports.​

Defaulter lists, semester reports, and accreditation/compliance-ready exports (CSV/Excel/PDF).​

User management (students/faculty), role-based access control, and audit logging.​

Security & Session Control
Device binding: each student account is locked to a single approved device (no self-logout / re-login).​

Single active session per student; new sessions from other devices/IPs are blocked until HOD re-approves.​

HOD/Admin tools to approve/revoke devices and reset bindings when needed.​

Reports & Analytics
Course-level Excel reports for each faculty (subject summary, student-wise attendance, defaulters).​

Department-level Excel workbooks with multiple sheets (summary, faculty performance, shortage lists, consolidated semester view).​

Visual analytics: trends over time, class averages, and at-risk students.​

Tech Stack
Frontend: Flutter (Material 3, responsive layouts).​

State Management: (e.g., Riverpod/Bloc/Provider – choose what you use).​

Backend: Firebase/REST API (Node/Django/Flask) for auth, attendance, and reports.​

Database: Firestore / SQL (MySQL/PostgreSQL) depending on backend.​

Reporting: Backend Excel/PDF generation (e.g., using Excel libraries) exposed via API endpoints.​

Project Structure (Example)
text
lib/
  core/
    theme/
    utils/
  data/
    models/
    repositories/
  domain/
    use_cases/
  presentation/
    screens/
      student/
      faculty/
      admin/
    widgets/
This follows a clean architecture style with clear separation between UI, domain logic, and data layers.​

Getting Started
Prerequisites
Flutter SDK installed and configured.​

Android Studio / VS Code with Flutter/Dart plugins.​

Backend (Firebase project or REST API) configured with auth and attendance endpoints.​

Setup
Clone the repository:

bash
git clone <your-repo-url>
cd smartattend
Install dependencies:

bash
flutter pub get
Configure environment:

Add your API base URLs / Firebase config in a .env or config file.

Set up roles (student/faculty/admin) in backend.​

Run the app:

bash
flutter run
Roadmap
Face recognition / biometric integration for proxy prevention.​

Geofencing and location-based attendance validation.​

Parent/guardian portal for real-time monitoring.​

More AI-driven analytics (dropout risk prediction, smart suggestions).
