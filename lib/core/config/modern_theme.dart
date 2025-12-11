import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Professional Theme - Soft Modern Aesthetic
/// Inspired by Stripe, Airbnb, Linear, and Notion
class ModernTheme {
  // ============================================
  // COLOR PALETTE - Soft Modern
  // ============================================
  
  // Backgrounds
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color slateGrey = Color(0xFF64748B);
  static const Color lightSlateGrey = Color(0xFF94A3B8);
  
  // Primary Brand Colors
  static const Color royalBlue = Color(0xFF3B82F6);
  static const Color deepIndigo = Color(0xFF4F46E5);
  
  // Status Colors (Soft/Pastel)
  static const Color softEmerald = Color(0xFF10B981);
  static const Color softEmeraldBg = Color(0xFFD1FAE5);
  
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFFFEF3C7);
  
  static const Color rose = Color(0xFFE11D48);
  static const Color roseBg = Color(0xFFFFE4E6);
  
  static const Color blueGrey = Color(0xFF94A3B8);
  static const Color blueGreyBg = Color(0xFFE2E8F0);
  
  // Borders
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  
  // ============================================
  // GRADIENTS
  // ============================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [royalBlue, deepIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [pureWhite, Color(0xFFF0F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================
  // SHADOWS - Soft Elevation
  // ============================================
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  // ============================================
  // TYPOGRAPHY - Professional Sans-Serif
  // ============================================
  
  // Headings - Poppins SemiBold
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.2,
  );
  
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.3,
  );
  
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.4,
  );
  
  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.4,
  );
  
  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.5,
  );
  
  // Body Text - Inter Regular
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: darkSlate,
    height: 1.6,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: darkSlate,
    height: 1.6,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: slateGrey,
    height: 1.5,
  );
  
  // Labels & Captions
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: slateGrey,
    height: 1.4,
  );
  
  static TextStyle get labelBold => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: darkSlate,
    height: 1.4,
  );
  
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: slateGrey,
    height: 1.4,
  );
  
  static TextStyle get captionBold => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: slateGrey,
    height: 1.4,
  );
  
  // Button Text
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: pureWhite,
    height: 1.2,
    letterSpacing: 0.3,
  );
  
  // ============================================
  // BORDER RADIUS
  // ============================================
  
  static BorderRadius get radiusSmall => BorderRadius.circular(12);
  static BorderRadius get radiusMedium => BorderRadius.circular(16);
  static BorderRadius get radiusLarge => BorderRadius.circular(20);
  static BorderRadius get radiusXLarge => BorderRadius.circular(24);
  
  // ============================================
  // SPACING
  // ============================================
  
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  // ============================================
  // THEME DATA
  // ============================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: royalBlue,
        secondary: deepIndigo,
        surface: pureWhite,
        background: offWhite,
        error: rose,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: darkSlate,
        onBackground: darkSlate,
        onError: pureWhite,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: offWhite,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h4,
        iconTheme: const IconThemeData(color: darkSlate),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: radiusLarge,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: royalBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: rose, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        hintStyle: label.copyWith(color: lightSlateGrey),
        labelStyle: label,
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalBlue,
          foregroundColor: pureWhite,
          elevation: 0,
          shadowColor: royalBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: radiusMedium,
          ),
          textStyle: button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: royalBlue,
          textStyle: button.copyWith(color: royalBlue),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: slateGrey,
        size: 24,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: royalBlue,
        unselectedItemColor: slateGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: captionBold,
        unselectedLabelStyle: caption,
      ),
    );
  }
  
  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get status color based on attendance percentage
  static Color getAttendanceColor(double percentage) {
    if (percentage >= 75) return softEmerald;
    if (percentage >= 60) return amber;
    return rose;
  }
  
  /// Get status background color based on attendance percentage
  static Color getAttendanceBackgroundColor(double percentage) {
    if (percentage >= 75) return softEmeraldBg;
    if (percentage >= 60) return amberBg;
    return roseBg;
  }
  
  /// Get status text based on attendance percentage
  static String getAttendanceStatus(double percentage) {
    if (percentage >= 75) return 'Good';
    if (percentage >= 60) return 'Warning';
    return 'Critical';
  }
}
