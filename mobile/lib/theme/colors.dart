import 'package:flutter/material.dart';

/// Warm cream + coral-orange consumer palette — bold, friendly, and
/// approachable rather than institutional. Blue is reserved for links and
/// location cues; orange is the single brand/action color.
class LedgerColors {
  LedgerColors._();

  // Light
  static const Color lightPrimary = Color(0xFFFF5722);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFFDE4D4);
  static const Color lightOnPrimaryContainer = Color(0xFFB8380C);

  static const Color lightSecondary = Color(0xFF3B6EF6);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFDCE7FE);
  static const Color lightOnSecondaryContainer = Color(0xFF1D4ED8);

  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightOnSuccess = Color(0xFFFFFFFF);
  static const Color lightSuccessContainer = Color(0xFFDCFCE7);
  static const Color lightOnSuccessContainer = Color(0xFF14532D);

  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFEE2E2);
  static const Color lightOnErrorContainer = Color(0xFF7F1D1D);

  static const Color lightInk = Color(0xFF1A1A1A);
  static const Color lightInkMuted = Color(0xFF8A8A8A);

  static const Color lightSurfaceLowest = Color(0xFFFBF1E4);
  static const Color lightSurfaceLow = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFF3E9DA);
  static const Color lightSurfaceHighest = Color(0xFFE9DCC8);
  static const Color lightOutline = Color(0xFFEDE1D0);
  static const Color lightOutlineVariant = Color(0xFFF3E9DA);

  // Dark — desaturated/lighter tonal variants, not an inversion.
  static const Color darkPrimary = Color(0xFFFF8A5C);
  static const Color darkOnPrimary = Color(0xFF3D1200);
  static const Color darkPrimaryContainer = Color(0xFF7A2A0A);
  static const Color darkOnPrimaryContainer = Color(0xFFFDE4D4);

  static const Color darkSecondary = Color(0xFF8FADFB);
  static const Color darkOnSecondary = Color(0xFF0B2159);
  static const Color darkSecondaryContainer = Color(0xFF1E3A8A);
  static const Color darkOnSecondaryContainer = Color(0xFFDCE7FE);

  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkOnSuccess = Color(0xFF0A2E17);
  static const Color darkSuccessContainer = Color(0xFF14532D);
  static const Color darkOnSuccessContainer = Color(0xFFBBF7D0);

  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF450A0A);
  static const Color darkErrorContainer = Color(0xFF7F1D1D);
  static const Color darkOnErrorContainer = Color(0xFFFECACA);

  static const Color darkInk = Color(0xFFF3EDE3);
  static const Color darkInkMuted = Color(0xFFB4A995);

  static const Color darkSurfaceLowest = Color(0xFF1C1611);
  static const Color darkSurfaceLow = Color(0xFF241C15);
  static const Color darkSurface = Color(0xFF241C15);
  static const Color darkSurfaceHigh = Color(0xFF2E241B);
  static const Color darkSurfaceHighest = Color(0xFF382C20);
  static const Color darkOutline = Color(0xFF4A3B2A);
  static const Color darkOutlineVariant = Color(0xFF2E241B);

  static ColorScheme light() => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        tertiary: lightSuccess,
        onTertiary: lightOnSuccess,
        tertiaryContainer: lightSuccessContainer,
        onTertiaryContainer: lightOnSuccessContainer,
        error: lightError,
        onError: lightOnError,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightOnErrorContainer,
        surface: lightSurface,
        onSurface: lightInk,
        onSurfaceVariant: lightInkMuted,
        surfaceContainerLowest: lightSurfaceLowest,
        surfaceContainerLow: lightSurfaceLow,
        surfaceContainer: lightSurface,
        surfaceContainerHigh: lightSurfaceHigh,
        surfaceContainerHighest: lightSurfaceHighest,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
      );

  static ColorScheme dark() => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkSuccess,
        onTertiary: darkOnSuccess,
        tertiaryContainer: darkSuccessContainer,
        onTertiaryContainer: darkOnSuccessContainer,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnErrorContainer,
        surface: darkSurface,
        onSurface: darkInk,
        onSurfaceVariant: darkInkMuted,
        surfaceContainerLowest: darkSurfaceLowest,
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainer: darkSurface,
        surfaceContainerHigh: darkSurfaceHigh,
        surfaceContainerHighest: darkSurfaceHighest,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
      );
}
