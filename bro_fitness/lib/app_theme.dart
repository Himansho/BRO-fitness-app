import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF00E5FF);      // Electric Cyan
  static const Color secondaryColor = Color(0xFF7C4DFF);    // Deep Purple
  static const Color accentColor = Color(0xFF69FF47);       // Neon Green (PRs)
  static const Color dangerColor = Color(0xFFFF5252);       // Red (warnings)
  static const Color warningColor = Color(0xFFFFD740);      // Amber

  // Background layers
  static const Color bgDark = Color(0xFF0A0A0F);            // Near-black
  static const Color bgCard = Color(0xFF13131A);            // Card background
  static const Color bgCardAlt = Color(0xFF1C1C28);         // Alt card
  static const Color bgSurface = Color(0xFF22223A);         // Surface/input

  // Text
  static const Color textPrimary = Color(0xFFEEEEFF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF555577);

  // Macros
  static const Color proteinColor = Color(0xFF4FC3F7);      // Blue
  static const Color carbsColor = Color(0xFFFFB74D);        // Orange
  static const Color fatColor = Color(0xFFEF5350);          // Red
  static const Color calorieColor = Color(0xFF69FF47);      // Green

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: bgCard,
      error: dangerColor,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: bgDark,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: primaryColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: primaryColor,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E1E2E), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2A40)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2A40)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
      prefixIconColor: textSecondary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bgSurface,
      selectedColor: primaryColor.withAlpha(40),
      labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
      side: const BorderSide(color: Color(0xFF2A2A40)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF1E1E2E), thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textMuted, fontSize: 12),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bgCardAlt,
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: textPrimary,
      iconColor: textSecondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primaryColor : textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primaryColor.withAlpha(80) : bgSurface),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryColor,
      thumbColor: primaryColor,
      inactiveTrackColor: bgSurface,
      overlayColor: Color(0x2000E5FF),
    ),
  );
}

// Gradient helpers
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF13131A), Color(0xFF1C1C28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient prGradient = LinearGradient(
    colors: [Color(0xFFFFD740), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
