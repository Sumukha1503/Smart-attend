# 🔥 Firebase Setup Guide for Smart Attend

This guide will help you set up Firebase Firestore for **cross-device session synchronization** in your Smart Attend app.

## 📋 Prerequisites

- Google account
- Flutter project (already set up ✅)
- Firebase dependencies installed (already done ✅)

## 🚀 Step-by-Step Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add Project"** or **"Create a project"**
3. Enter project name: `smart-attend` (or your choice)
4. **Disable Google Analytics** (optional for development)
5. Click **"Create Project"**
6. Wait for project creation to complete

### Step 2: Add Android App to Firebase

1. In your Firebase project, click the **Android icon** to add an Android app
2. **Android package name**: Find this in `android/app/build.gradle`
   ```gradle
   defaultConfig {
       applicationId "com.example.smart_attend"  // ← Copy this
   }
   ```
3. **App nickname**: "Smart Attend Android" (optional)
4. **Debug signing certificate SHA-1**: Leave blank for now (optional)
5. Click **"Register app"**

### Step 3: Download Configuration File

1. Download `google-services.json` file
2. Place it in: `android/app/google-services.json`
   ```
   smart_attend/
   └── android/
       └── app/
           └── google-services.json  ← Place here
   ```

### Step 4: Configure Android Build Files

#### 4.1 Project-level `build.gradle`

Open `android/build.gradle` and add:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'  // ← Add this
    }
}
```

#### 4.2 App-level `build.gradle`

Open `android/app/build.gradle` and add at the **bottom** of the file:

```gradle
apply plugin: 'com.google.gms.google-services'  // ← Add this line at the end
```

Also ensure minimum SDK version is 21 or higher:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // ← Must be 21 or higher
    }
}
```

### Step 5: Configure FlutterFire CLI (Recommended)

This automates the configuration process:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

The CLI will:
- Auto-detect your Firebase project
- Generate `lib/firebase_options.dart`
- Configure all platforms (Android/iOS)

**If you already have `firebase_options.dart`, you can skip this step.**

### Step 6: Enable Firestore Database

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.time < timestamp.date(2025, 2, 1);
       }
     }
   }
   ```
4. Select a location (choose closest to your users)
5. Click **"Enable"**

### Step 7: Set Up Production Security Rules

Once you're ready for production, update Firestore rules:

1. Go to **Firestore Database** → **Rules**
2. Replace with these secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Sessions collection
    match /sessions/{sessionId} {
      // Anyone can read active sessions
      allow read: if true;
      
      // Anyone can create sessions (you can add auth later)
      allow create: if true;
      
      // Only allow updates to mark as inactive
      allow update: if request.resource.data.diff(resource.data).affectedKeys()
                      .hasOnly(['isActive']);
      
      // Allow deletion of old sessions
      allow delete: if true;
    }
  }
}
```

**For production with authentication**, use:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    match /sessions/{sessionId} {
      // Anyone can read active sessions
      allow read: if request.auth != null;
      
      // Only faculty can create sessions
      allow create: if request.auth != null 
                    && request.resource.data.facultyId == request.auth.uid;
      
      // Only creator can update/delete
      allow update, delete: if request.auth != null 
                            && resource.data.facultyId == request.auth.uid;
    }
  }
}
```

### Step 8: Test the Setup

1. **Run the app on Device A (Faculty)**:
   ```bash
   flutter run
   ```
   - Login as faculty
   - Create a session
   - Check Firebase Console → Firestore Database
   - You should see the session appear!

2. **Run the app on Device B (Student)**:
   ```bash
   flutter run
   ```
   - Login as student
   - Navigate to "Join Session"
   - You should see the session **in real-time**! 🎉

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `build.gradle` files updated
- [ ] `firebase_options.dart` exists in `lib/`
- [ ] Firestore Database enabled
- [ ] Security rules configured
- [ ] App runs without Firebase errors
- [ ] Sessions sync across devices

## 🔍 Troubleshooting

### Error: "Default FirebaseApp is not initialized"

**Solution**: Ensure `Firebase.initializeApp()` is called in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SmartAttendApp());
}
```

### Error: "google-services.json not found"

**Solution**: 
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Run `flutter clean` and `flutter pub get`

### Error: "Firestore permission denied"

**Solution**: Update Firestore security rules to allow read/write access (see Step 7)

### Sessions not appearing on other devices

**Checklist**:
1. ✅ Both devices have internet connection
2. ✅ Firebase is initialized successfully
3. ✅ Firestore rules allow read access
4. ✅ Session was created successfully (check Firebase Console)
5. ✅ Student page is using `StreamBuilder` with `getActiveSessionsStream()`

## 📊 Monitoring

### View Sessions in Firebase Console

1. Go to Firebase Console → Firestore Database
2. You'll see `sessions` collection
3. Each document represents an active session
4. You can manually delete sessions here

### Check Logs

The app prints helpful logs:
- `✅ Firebase: Session created - [Course Name]`
- `📡 Firebase Stream: X active sessions`
- `❌ Firebase: Error [details]`

## 🎯 What's Implemented

✅ **Real-time cross-device sync** - Sessions appear instantly on all devices
✅ **Automatic expiration** - Sessions expire after 2 minutes
✅ **Fallback to local storage** - Works offline with SharedPreferences
✅ **Live countdown timer** - Shows remaining time for each session
✅ **Connection indicator** - Green "Live" badge shows real-time status
✅ **Error handling** - Graceful fallback if Firebase fails
✅ **StreamBuilder UI** - Automatic UI updates without manual refresh

## 🚀 Next Steps

1. **Add Firebase Authentication** - Secure user login
2. **Store attendance records** - Save who attended which session
3. **Add analytics** - Track session usage
4. **Enable offline persistence** - Cache sessions locally
5. **Add push notifications** - Notify students of new sessions

## 📚 Resources

- [Firebase Console](https://console.firebase.google.com)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

---

**Need help?** Check the logs in your terminal or Firebase Console for detailed error messages.
