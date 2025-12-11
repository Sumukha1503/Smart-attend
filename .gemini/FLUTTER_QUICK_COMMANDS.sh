# Flutter Development Quick Commands
# Use these commands for efficient development workflow

# ============================================
# INITIAL SETUP (Run once after optimizations)
# ============================================

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# ============================================
# DEVELOPMENT WORKFLOW (Daily Use)
# ============================================

# Start app in debug mode (FASTEST for development)
flutter run --debug

# After app is running, use these keyboard shortcuts:
# - Press 'r' for Hot Reload (1-2 seconds) - Use for most changes
# - Press 'R' for Hot Restart (5-10 seconds) - Use for state changes
# - Press 'q' to quit

# ============================================
# TESTING & PROFILING
# ============================================

# Profile mode (for performance testing)
flutter run --profile

# Release mode (for final testing only)
flutter run --release

# Run with verbose output (to debug slow builds)
flutter run --verbose

# ============================================
# TROUBLESHOOTING
# ============================================

# Check Flutter setup
flutter doctor -v

# Check for outdated packages
flutter pub outdated

# Clean everything and rebuild (if issues persist)
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run

# ============================================
# BUILD ANALYSIS
# ============================================

# Analyze app size
flutter build apk --analyze-size

# Profile Gradle build time
cd android
gradlew --profile --offline --rerun-tasks assembleDebug
# Report will be in: android/build/reports/profile/

# ============================================
# MAINTENANCE
# ============================================

# Update Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# ============================================
# ANTIVIRUS EXCLUSIONS (Windows Defender)
# ============================================

# Add these directories to Windows Defender exclusions:
# 1. e:\Flutter\smart_attend\build
# 2. e:\Flutter\smart_attend\.dart_tool
# 3. e:\Flutter\smart_attend\android\build
# 4. C:\Users\sumuk\.gradle
# 5. C:\Users\sumuk\.pub-cache

# To add exclusions via PowerShell (Run as Administrator):
# Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\build"
# Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\.dart_tool"
# Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\android\build"
# Add-MpPreference -ExclusionPath "C:\Users\sumuk\.gradle"
# Add-MpPreference -ExclusionPath "C:\Users\sumuk\.pub-cache"

# ============================================
# EXPECTED BUILD TIMES (After Optimizations)
# ============================================

# Cold Start (first run): 20-40 seconds
# Hot Reload (r): < 2 seconds
# Hot Restart (R): 5-10 seconds
# Incremental Build: 10-20 seconds

# ============================================
# TIPS
# ============================================

# 1. Always use Hot Reload (r) when possible
# 2. Only use Hot Restart (R) for state changes
# 3. Only do full restart for native code/dependency changes
# 4. Keep app running during development
# 5. Use --debug mode for development (fastest)
# 6. Use --profile mode only for performance testing
# 7. Use --release mode only for final testing
