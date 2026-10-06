import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الخطوط لتطبيق حاسبي الذكي
/// يستخدم خط Cairo للعربية - خط عصري وواضح
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ─── العناوين الكبيرة ──────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => _base(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle displayMedium({Color? color}) => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle displaySmall({Color? color}) => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  // ─── العناوين ──────────────────────────────────────────────
  static TextStyle headlineLarge({Color? color}) => _base(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  static TextStyle headlineMedium({Color? color}) => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle headlineSmall({Color? color}) => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // ─── العناوين الفرعية ──────────────────────────────────────
  static TextStyle titleLarge({Color? color}) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.5,
      );

  static TextStyle titleMedium({Color? color}) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.5,
      );

  static TextStyle titleSmall({Color? color}) => _base(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.5,
      );

  // ─── النص العادي ────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodyMedium({Color? color}) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodySmall({Color? color, FontWeight? fontWeight, bool isBold = false}) => _base(
        fontSize: 12,
        fontWeight: isBold ? FontWeight.w700 : (fontWeight ?? FontWeight.w400),
        color: color,
        height: 1.6,
      );

  // ─── النص الثانوي ──────────────────────────────────────────
  static TextStyle labelLarge({Color? color}) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle labelMedium({Color? color}) => _base(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall({Color? color, FontWeight? fontWeight, bool isBold = false}) => _base(
        fontSize: 11,
        fontWeight: isBold ? FontWeight.w700 : (fontWeight ?? FontWeight.w500),
        color: color,
        height: 1.4,
      );

  // ─── الأرقام (مالية) ────────────────────────────────────────
  static TextStyle moneyLarge({Color? color}) => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle moneyMedium({Color? color}) => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle moneySmall({Color? color}) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );
}
