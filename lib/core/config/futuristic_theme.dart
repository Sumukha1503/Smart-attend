import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 2025 Cyber-Future Theme - Aurora Glass & Neon
class FuturisticTheme {
  // ========== COLOR PALETTE ==========
  
  // Background Colors
  static const Color deepSpace = Color(0xFF050A30);
  static const Color midnight = Color(0xFF000000);
  static const Color darkVoid = Color(0xFF0A0E27);
  
  // Neon Accent Colors
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonPurple = Color(0xFF9D00FF);
  
  // Status Colors
  static const Color neonGreen = Color(0xFF39FF14); // Good attendance ≥85%
  static const Color solarOrange = Color(0xFFFF5F1F); // Warning 75-84%
  static const Color plasmaRed = Color(0xFFFF003C); // Critical <75%
  
  // Glass Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // ========== GRADIENTS ==========
  
  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF050A30),
      Color(0xFF1A0B2E),
      Color(0xFF0F0524),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF00D4FF)],
  );
  
  static const LinearGradient neonMagentaGradient = LinearGradient(
    colors: [Color(0xFFFF00FF), Color(0xFFD400D4)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF39FF14), Color(0xFF00FF88)],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF5F1F), Color(0xFFFF8C00)],
  );
  
  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFFF003C), Color(0xFFFF1744)],
  );
  
  // ========== TEXT STYLES ==========
  
  // Headers - Space Grotesk
  static TextStyle get h1Futuristic => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1.5,
        height: 1.1,
      );
  
  static TextStyle get h2Futuristic => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1.0,
      );
  
  static TextStyle get h3Futuristic => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.5,
      );
  
  static TextStyle get h4Futuristic => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
  
  // Body - Plus Jakarta Sans
  static TextStyle get bodyTech => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.9),
        height: 1.5,
      );
  
  static TextStyle get bodyTechBold => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
  
  static TextStyle get captionTech => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.6),
      );
  
  static TextStyle get labelTech => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.7),
        letterSpacing: 1.2,
      );
  
  // Numeric Counters
  static TextStyle get numericCounter => GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: neonCyan,
        letterSpacing: -2.0,
      );
  
  static TextStyle get numericCounterSmall => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: neonCyan,
        letterSpacing: -1.0,
      );
  
  // Terminal/Monospace
  static TextStyle get terminalText => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: neonGreen,
        height: 1.6,
      );
  
  // ========== BOX DECORATIONS ==========
  
  /// Glass Card - Primary building block
  static BoxDecoration glassCard({
    double opacity = 0.1,
    Color? borderColor,
    double borderWidth = 1.0,
    List<Color>? gradientColors,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(colors: gradientColors)
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? glassBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? neonCyan).withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Neon Glow Card
  static BoxDecoration neonGlowCard({
    required Color glowColor,
    double glowIntensity = 0.3,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: glowColor.withOpacity(0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(glowIntensity),
          blurRadius: 30,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: glowColor.withOpacity(glowIntensity * 0.5),
          blurRadius: 60,
          spreadRadius: 5,
        ),
      ],
    );
  }
  
  /// Floating Button
  static BoxDecoration floatingButton({
    required Gradient gradient,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: neonCyan.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // ========== THEME DATA ==========
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnight,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        surface: deepSpace,
        background: midnight,
        error: plasmaRed,
      ),
      textTheme: TextTheme(
        displayLarge: h1Futuristic,
        displayMedium: h2Futuristic,
        displaySmall: h3Futuristic,
        headlineMedium: h4Futuristic,
        bodyLarge: bodyTech,
        bodyMedium: bodyTech,
        labelLarge: labelTech,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: h3Futuristic,
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: midnight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        labelStyle: bodyTech,
        hintStyle: captionTech,
      ),
    );
  }
  
  // ========== HELPER METHODS ==========
  
  /// Get status color based on attendance percentage
  static Color getStatusColor(double percentage) {
    if (percentage >= 85) return neonGreen;
    if (percentage >= 75) return solarOrange;
    return plasmaRed;
  }
  
  /// Get status gradient based on attendance percentage
  static LinearGradient getStatusGradient(double percentage) {
    if (percentage >= 85) return successGradient;
    if (percentage >= 75) return warningGradient;
    return criticalGradient;
  }
  
  /// Get status text
  static String getStatusText(double percentage) {
    if (percentage >= 85) return 'EXCELLENT';
    if (percentage >= 75) return 'WARNING';
    return 'CRITICAL';
  }
}
