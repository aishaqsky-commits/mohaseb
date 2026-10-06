import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مزود SharedPreferences العام المحقون في جذر التطبيق (main.dart)
/// يضمن عدم حدوث وميض في الثيم (Zero Flash) عند الإقلاع
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'يجب تهيئة sharedPreferencesProvider عبر ProviderScope.overrides في main.dart',
  );
});

/// مزود مساعد لمعرفة ما إذا كان الوضع المختار داكناً صراحة
final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeProvider);
  return mode == ThemeMode.dark;
});

/// مدير حالة السمة (فاتح / داكن / تلقائي) وفق أفضل ممارسات Riverpod
class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'mohaseb_theme_mode_v1';

  @override
  ThemeMode build() {
    // قراءة متزامنة فورية تمنع الوميض ومشاكل عدم التزامن
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedMode = prefs.getString(_themeKey);

    switch (savedMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// تعيين نمط محدد وحفظه محلياً
  Future<void> setTheme(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_themeKey, mode.name);
    } catch (e) {
      debugPrint('تحذير: تعذر حفظ الثيم في SharedPreferences: $e');
    }
  }

  /// التبديل السريع بين الوضعين الفاتح والداكن
  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(nextMode);
  }

  /// تفعيل الوضع الفاتح
  Future<void> setLight() async => setTheme(ThemeMode.light);

  /// تفعيل الوضع الداكن
  Future<void> setDark() async => setTheme(ThemeMode.dark);

  /// تفعيل الوضع التلقائي المتوافق مع إعدادات نظام الجهاز
  Future<void> setSystem() async => setTheme(ThemeMode.system);
}

/// المزود الرئيسي للثيم
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
