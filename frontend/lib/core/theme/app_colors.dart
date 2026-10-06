import 'package:flutter/material.dart';

/// نظام الألوان الرئيسي لتطبيق حاسبي الذكي
/// يدعم الوضع الفاتح والداكن مع لوحة ألوان متناسقة
class AppColors {
  AppColors._();

  // ─── الألوان الأساسية ───────────────────────────────────────
  static const Color primary = Color(0xFF1B6B4A);        // أخضر داكن - يرمز للمال والنمو
  static const Color primaryLight = Color(0xFF2E9B6E);   // أخضر فاتح
  static const Color primaryDark = Color(0xFF0D4A32);    // أخضر غامق جداً
  static const Color primarySurface = Color(0xFFE8F5E9); // خلفية خضراء فاتحة جداً

  // ─── الألوان الثانوية ──────────────────────────────────────
  static const Color secondary = Color(0xFF1A73E8);      // أزرق Google
  static const Color secondaryLight = Color(0xFF4A9AF5);
  static const Color secondaryDark = Color(0xFF0D47A1);

  // ─── ألوان الحالة ─────────────────────────────────────────
  static const Color success = Color(0xFF00C853);        // نجاح
  static const Color warning = Color(0xFFFF9800);        // تحذير
  static const Color error = Color(0xFFE53935);          // خطأ
  static const Color info = Color(0xFF2196F3);           // معلومات

  // ─── ألوان المحاسبة ────────────────────────────────────────
  static const Color income = Color(0xFF00C853);         // إيرادات - أخضر
  static const Color expense = Color(0xFFE53935);        // مصروفات - أحمر
  static const Color debit = Color(0xFF1565C0);          // مدين - أزرق
  static const Color credit = Color(0xFFE65100);         // دائن - برتقالي

  // ─── ألوان محايدة ──────────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ─── الوضع الفاتح ─────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightDivider = Color(0xFFE8ECF4);
  static const Color lightTextPrimary = Color(0xFF1D1D35);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // ─── ألوان تكميلية وحدود ────────────────────────────────────
  static const Color accent = Color(0xFF7C4DFF);          // بنفسجي ذكي
  static const Color lightBorder = Color(0xFFE8ECF4);
  static const Color darkBorder = Color(0xFF2D3142);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ─── الوضع الداكن ─────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkCard = Color(0xFF222639);
  static const Color darkDivider = Color(0xFF2D3142);
  static const Color darkTextPrimary = Color(0xFFF1F3F9);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);

  // ─── تدرجات ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1D27), Color(0xFF0F1117)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── ألوان أزرار العمليات ──────────────────────────────────
  static const Color operationSale = Color(0xFF00C853);
  static const Color operationPurchase = Color(0xFF2196F3);
  static const Color operationExpense = Color(0xFFE53935);
  static const Color operationPayroll = Color(0xFF9C27B0);
  static const Color operationCapital = Color(0xFFFF9800);
  static const Color operationInventory = Color(0xFF00BCD4);
  static const Color operationAI = Color(0xFF7C4DFF);
}
