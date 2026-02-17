import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primary = Color(0xFF0891B2);
  static const Color _secondary = Color(0xFF22D3EE);
  static const Color _cta = Color(0xFF059669);
  static const Color _background = Color(0xFFECFEFF);
  static const Color _onBackground = Color(0xFF164E63);
  static const Color _error = Color(0xFFDC2626);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
    );

    final schemeBase = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );

    final scheme = schemeBase.copyWith(
      primary: _primary,
      secondary: _secondary,
      tertiary: _cta,
      surface: Colors.white,
      error: _error,
      onSurface: _onBackground,
    );

    final textBase = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final bodyTextTheme = GoogleFonts.notoSansTextTheme(textBase);

    final textTheme = bodyTextTheme.copyWith(
      displayLarge: GoogleFonts.figtree(
        textStyle: bodyTextTheme.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      displayMedium: GoogleFonts.figtree(
        textStyle: bodyTextTheme.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.figtree(
        textStyle: bodyTextTheme.displaySmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: GoogleFonts.figtree(
        textStyle: bodyTextTheme.headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: GoogleFonts.figtree(
        textStyle: bodyTextTheme.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.figtree(
        textStyle: bodyTextTheme.headlineSmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.figtree(
        textStyle: bodyTextTheme.titleLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleMedium: GoogleFonts.figtree(
        textStyle: bodyTextTheme.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.figtree(
        textStyle: bodyTextTheme.titleSmall,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.primary.withValues(alpha: 0.12),
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(
              color: scheme.primary.withValues(alpha: 0.35), width: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteTextStyle: textTheme.headlineSmall,
        dayPeriodTextStyle: textTheme.labelLarge,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerHeadlineStyle: textTheme.titleLarge,
        dayStyle: textTheme.bodyMedium,
      ),
    );
  }
}
