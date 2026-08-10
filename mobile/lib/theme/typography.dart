import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fraunces at a heavy weight for headlines — bold slab-serif character,
/// warm and a little playful. Poppins for everything else — clean,
/// rounded, friendly at small mobile sizes.
class LedgerTypography {
  LedgerTypography._();

  static TextTheme textTheme(Color onSurface) {
    final base = GoogleFonts.poppinsTextTheme();
    final display = GoogleFonts.frauncesTextTheme();

    return base
        .copyWith(
          displayLarge: display.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1.0,
          ),
          headlineLarge: display.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.05,
          ),
          headlineMedium: display.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.1,
          ),
          titleLarge: display.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        )
        .apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        );
  }
}
