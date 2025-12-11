# Faculty Course Assignment - User Guide

## Overview
This guide explains how the course assignment system works and how faculty can start creating sessions.

---

## 🎯 Problem Solved
**Issue**: Faculty members were unable to start sessions because they weren't assigned to any courses.

**Solution**: HOD can now assign faculty to courses through a dedicated Course Assignment interface.

---

## 👥 User Roles & Responsibilities

### HOD (Head of Department)
**Responsibility**: Assign faculty members to courses

**Steps**:
1. Login to the HOD Dashboard
2. Click on **"Course Assign"** card (teal colored)
3. View all available courses
4. For each course:
   - Click **"Assign"** button (for unassigned courses)
   - Click **"Change"** button (to reassign courses)
5. Select faculty from the dropdown
6. Click **"Assign"** to confirm

**Visual Indicators**:
- ✅ **Green check icon**: Course is assigned
- ⚠️ **Orange warning icon**: Course is unassigned

---

### Faculty
**Responsibility**: Create and manage attendance sessions

**Steps**:
1. **Wait for HOD Assignment**
   - Contact your HOD if you see "No Courses Assigned" message
   - HOD must assign you to courses first

2. **Once Assigned**:
   - Go to Faculty Home → **"Create Session"**
   - Select your assigned course from dropdown
   - Set geofence radius (10-100 meters)
   - Click **"Start Session"**

3. **Session Active**:
   - Session runs for 2 minutes
   - Students can mark attendance within geofence
   - You can stop session early if needed

---

## 📋 Complete Workflow

### Initial Setup (One-time)
```
1. HOD logs in
   ↓
2. HOD navigates to "Course Assign"
   ↓
3. HOD assigns faculty to all courses
   ↓
4. Faculty can now create sessions
```

### Daily Usage
```
1. Faculty logs in
   ↓
2. Faculty goes to "Create Session"
   ↓
3. Faculty selects assigned course
   ↓
4. Faculty starts session
   ↓
5. Students join and mark attendance
   ↓
6. Session ends automatically or manually
```

---

## 🔧 Technical Details

### Course Assignment Page
**Location**: `lib/features/hod/presentation/pages/course_assignment_page.dart`

**Features**:
- List all courses with assignment status
- Assign/reassign faculty to courses
- Visual indicators for assignment status
- Real-time updates after assignment
- Pull-to-refresh functionality

### Updated Files
1. **New Files**:
   - `course_assignment_page.dart` - HOD course assignment interface

2. **Modified Files**:
   - `app_routes.dart` - Added courseAssignment route
   - `app.dart` - Added route mapping
   - `hod_dashboard.dart` - Added Course Assign action card
   - `create_geo_session_page.dart` - Improved error messaging

---

## 💡 Key Features

### For HOD
✅ **Visual Assignment Status**
- See which courses are assigned/unassigned at a glance
- Color-coded indicators (green = assigned, orange = unassigned)

✅ **Easy Reassignment**
- Change faculty assignments anytime
- Dropdown selection for easy faculty choice

✅ **Course Information**
- View course code, name, semester, and section
- See currently assigned faculty

### For Faculty
✅ **Clear Error Messages**
- Informative message when no courses assigned
- Guidance on what to do next
- Contact HOD instruction

✅ **Seamless Session Creation**
- Only see courses assigned to you
- No confusion about which courses you can teach

---

## 🎨 UI/UX Improvements

### Course Assignment Page
- **Card-based layout** for easy scanning
- **Color-coded status** for quick identification
- **Action buttons** prominently displayed
- **Refresh functionality** to reload data

### Faculty Session Creation
- **Improved empty state** with helpful guidance
- **Information card** explaining next steps
- **Visual hierarchy** for better readability

---

## 📱 Navigation Paths

### HOD Access
```
HOD Dashboard → Course Assign → Select Course → Assign Faculty
```

### Faculty Access
```
Faculty Home → Create Session → Select Course → Start Session
```

---

## ⚠️ Important Notes

1. **Faculty MUST be assigned** to courses by HOD before they can create sessions
2. **Courses can be reassigned** to different faculty at any time
3. **Changes take effect immediately** - faculty will see updated course list on refresh
4. **One faculty per course** - reassigning will update the faculty for that course

---

## 🐛 Troubleshooting

### Faculty sees "No Courses Assigned"
**Solution**: Contact HOD to assign you to courses

### HOD doesn't see Course Assignment option
**Solution**: 
- Ensure you're logged in as HOD
- Check if the app has been updated
- Restart the app if needed

### Changes not reflecting
**Solution**:
- Pull down to refresh the page
- Log out and log back in
- Restart the app

---

## 🚀 Future Enhancements

Potential improvements for future versions:
- Bulk assignment of faculty to multiple courses
- Assignment history and audit trail
- Notification to faculty when assigned to new courses
- Course load balancing suggestions
- Semester-wise course filtering

---

## 📞 Support

If you encounter any issues:
1. Check this guide first
2. Contact your system administrator
3. Report bugs to the development team

---

**Last Updated**: December 9, 2025
**Version**: 1.1.0
