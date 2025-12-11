# SmartAttend – Secure Role-Based Attendance System

SmartAttend is a modern, production-ready attendance tracking system built with **Flutter** and a secure backend.  
It is designed for colleges and universities with separate flows for **Students**, **Faculty**, and **HOD/Admin**, focusing on accurate tracking, strong security, and rich analytics. [web:21][web:22]

---

## ✨ Features

### 👨‍🎓 Student

- Real-time **subject-wise attendance** with color-coded status (Good / Warning / Critical). [web:21]  
- **Calendar view** for each subject showing Present / Absent / Leave. [web:21][web:22]  
- **Shortage alerts** and configurable minimum attendance threshold (e.g. 75%). [web:21]  
- **Leave management**: apply for leave with reason, date range, and attachments; track pending/approved/rejected status. [web:21][web:22]  
- **Timetable & reminders** for upcoming classes and exam eligibility warnings based on attendance. [web:22][web:27]

### 👨‍🏫 Faculty

- Fast **bulk attendance marking** (mark all present, toggle absentees). [web:24]  
- Class-wise student list with key details and **attendance stats**. [web:21][web:23]  
- Approve/reject **student leave requests**. [web:21][web:22]  
- Generate **defaulter lists** and identify at-risk students for counseling. [web:21]  
- Export **course-wise Excel/PDF reports** with student-wise attendance %, status, and summary metrics. [web:31][web:42]

### 🧑‍💼 HOD / Admin

- Manage **subjects, semesters, sections** and faculty–subject mapping. [web:27]  
- Department-wide **dashboards** and consolidated semester reports. [web:21][web:22]  
- Generate accreditation/compliance-ready exports in **CSV / Excel / PDF** formats. [web:21][web:31][web:42]  
- Role-based **user management** (students, faculty, sub-admins) and audit logging. [web:25][web:133]

### 🔐 Security & Sessions

- **Device binding:** each student account is locked to a **single, approved device** (no direct re-login after reinstall). [web:36][web:44][web:46]  
- **Single active session** per student; new sessions from other devices/IPs are blocked until HOD re-approves. [web:38][web:41]  
- HOD/Admin can approve/revoke devices and **reset bindings** when required. [web:36][web:41]

### 📊 Reports & Analytics

- Faculty-level **course reports** in Excel (subject summary, student-wise stats, defaulters, eligibility). [web:31][web:42]  
- HOD-level **department workbooks** with multiple sheets: summary, faculty performance, shortage report, consolidated semester view. [web:31][web:42]  
- Visual analytics: attendance trends, class averages, and at-risk lists. [web:21][web:22]

---

## 🛠 Tech Stack

- **Frontend:** Flutter, Material 3, responsive layouts. [web:68][web:114]  
- **State Management:** (e.g.) Riverpod / Bloc / Provider (pluggable). [web:117]  
- **Backend:** Firebase or REST API (Node / Django / Flask) for auth, attendance, and reports. [web:10][web:131]  
- **Database:** Firestore or SQL (MySQL / PostgreSQL), depending on backend. [web:10][web:131]  
- **Reporting:** Backend-side Excel/PDF generation exposed via APIs. [web:31][web:42]

---

## 📁 Project Structure (example)
lib/
core/
theme/
utils/
data/
models/
datasources/
repositories/
domain/
entities/
use_cases/
presentation/
screens/
student/
faculty/
admin/
widgets/
providers/

Follows a **clean architecture** style with clear separation of UI, domain, and data layers. [web:117][web:120]

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed and configured. [web:68][web:70]  
- Android Studio or VS Code with Flutter/Dart plugins. [web:68]  
- Backend (Firebase project or REST API) set up with auth and attendance endpoints. [web:10][web:128]

### Installation
clone the repo
git clone <your-repo-url>
cd smartattend

install dependencies
flutter pub get

run the app (debug)
flutter run


### Configuration

- Add your API base URLs / Firebase configuration in a config file or `.env`. [web:129][web:131]  
- Ensure backend roles (student / faculty / admin) and security rules are configured. [web:10][web:131]

---

## 🗺 Roadmap

- 🔍 Face recognition / biometric integration to prevent proxy attendance. [web:10][web:137][web:138]  
- 📍 Geofencing and location-based validation for on-campus attendance. [web:131][web:137]  
- 👪 Parent/guardian portal for real-time monitoring and alerts. [web:40][web:43]  
- 🧠 AI-driven analytics (dropout risk, smart recommendations, anomaly detection). [web:21][web:111]

---



