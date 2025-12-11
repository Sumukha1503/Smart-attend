# Smart Attend - Complete System Implementation Plan

## Overview
This document outlines the complete implementation of the Smart Attend system with all requested features.

## Implementation Status

### ✅ COMPLETED
1. Device Approval Request Model created
2. User Model updated with employeeId, phone, profilePicture fields

### 🚧 IN PROGRESS - CRITICAL FEATURES

#### Phase 1: Authentication System Overhaul
- [ ] Update login system to support Employee ID for Faculty/HOD
- [ ] Add Admin role and login
- [ ] Implement device approval workflow for students
- [ ] Create pending approval screen for students
- [ ] Update demo data with new credentials

#### Phase 2: Storage & Services
- [ ] Create device info service to get unique device ID
- [ ] Update storage service for approval requests
- [ ] Create approval management service for HOD
- [ ] Update auth service for new login flows

#### Phase 3: Student Module
- [ ] Create pending approval page
- [ ] Update student dashboard with semester/courses
- [ ] Create student profile page (editable: photo, phone)
- [ ] Implement device approval check on login

#### Phase 4: Faculty Module  
- [ ] Create faculty dashboard
- [ ] Implement course management (add courses, assign sections)
- [ ] Create faculty profile page (editable: photo, phone)
- [ ] Auto-enroll students when course assigned

#### Phase 5: HOD Module
- [ ] Create HOD dashboard
- [ ] Implement approval requests page
- [ ] Add approve/reject functionality
- [ ] Create HOD profile page (editable: photo, phone)

#### Phase 6: Admin Module
- [ ] Create admin dashboard
- [ ] Admin login system
- [ ] Admin management features

#### Phase 7: UI/UX Enhancements
- [ ] Add Floating Action Button (FAB) navigation
- [ ] Create bottom navigation bar
- [ ] Add smooth screen transitions
- [ ] Remove all "Coming Soon" placeholders
- [ ] Make all quick actions functional

### Demo Credentials (New)
```
Admin:
- Username: admin123
- Password: Admin@123

HOD:
- Employee ID: HOD001
- Password: HOD@123

Faculty:
- Employee ID: FAC001
- Password: Faculty@123

Student:
- USN: 1AB23CS001
- Password: Student@123
```

## Key Changes from Current System

### Login System Changes
**OLD:**
- Students: USN + Password (direct login)
- Faculty: Email + Password
- HOD: Email + Password

**NEW:**
- Students: USN + Password → Approval required on first login/new device
- Faculty: Employee ID + Password
- HOD: Employee ID + Password  
- Admin: Username + Password

### Student Flow
1. Enter USN + Password
2. If first time OR new device:
   - Send approval request to HOD
   - Show "Pending Approval" screen
   - Cannot access app until approved
3. If approved device:
   - Login directly to dashboard

### Navigation
- Add FAB with tabs: Home, Courses, Profile, Notifications
- Bottom navigation for easy switching
- Remove logout for students (already done)

## Technical Implementation Notes

### Device Identification
- Use `device_info_plus` package to get unique device ID
- Store approved device IDs per student
- Check device ID on every login

### Approval Workflow
1. Student logs in from new device
2. System creates DeviceApprovalRequest
3. HOD sees pending requests
4. HOD approves/rejects
5. Student can login if approved

### Data Structure
```dart
ApprovedDevices: {
  studentId: [deviceId1, deviceId2, ...]
}

PendingRequests: [
  DeviceApprovalRequest objects
]
```

## Files to Create/Update

### New Files
- `lib/features/auth/presentation/pages/pending_approval_page.dart`
- `lib/features/student/presentation/pages/student_profile_page.dart`
- `lib/features/faculty/presentation/pages/faculty_dashboard.dart`
- `lib/features/faculty/presentation/pages/course_management_page.dart`
- `lib/features/faculty/presentation/pages/faculty_profile_page.dart`
- `lib/features/hod/presentation/pages/hod_profile_page.dart`
- `lib/features/admin/presentation/pages/admin_dashboard.dart`
- `lib/core/services/device_info_service.dart`
- `lib/core/services/approval_service.dart`
- `lib/core/widgets/bottom_nav_bar.dart`

### Files to Update
- `lib/core/services/auth_service.dart` - New login logic
- `lib/core/services/storage_service.dart` - Approval storage
- `lib/core/services/demo_data_service.dart` - New demo users
- `lib/features/auth/presentation/pages/login_page.dart` - Employee ID support
- `lib/features/student/presentation/pages/student_home_page.dart` - Remove placeholders
- `lib/app.dart` - Add new routes

## Priority Order
1. ✅ Models updated
2. Device info service
3. Approval service  
4. Updated auth service
5. Pending approval page
6. Updated login page
7. HOD approval page
8. Update demo data
9. FAB navigation
10. Profile pages
11. Course management

## Estimated Complexity
- High: Authentication overhaul, approval workflow
- Medium: Profile pages, course management
- Low: UI updates, navigation

---
**Note:** This is a major system overhaul. Implementation will be done in phases to ensure stability.
