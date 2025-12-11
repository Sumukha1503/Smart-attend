import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/demo_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('📝 App will use local storage only');
    print('📖 See .gemini/FIREBASE_SETUP_GUIDE.md for setup instructions');
  }
  
  // Initialize demo data
  final demoDataService = DemoDataService();
  await demoDataService.initializeDemoData();
  
  runApp(const SmartAttendApp());
}
