import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mohaseb/shared/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('اختبارات مدير الثيم (ThemeNotifier Tests)', () {
    test('الوضع الافتراضي عند عدم وجود قيمة سابقة هو ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(themeProvider);
      expect(theme, ThemeMode.system);
    });

    test('قراءة الوضع الداكن من التخزين فورياً عند الإقلاع (Zero Flash)', () async {
      SharedPreferences.setMockInitialValues({'mohaseb_theme_mode_v1': 'dark'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(themeProvider);
      expect(theme, ThemeMode.dark);
      expect(container.read(isDarkModeProvider), true);
    });

    test('التبديل بين الوضع الداكن والفاتح toggleTheme وحفظه في SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'mohaseb_theme_mode_v1': 'light'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      expect(container.read(themeProvider), ThemeMode.light);

      await notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.dark);
      expect(prefs.getString('mohaseb_theme_mode_v1'), 'dark');

      await notifier.toggleTheme();
      expect(container.read(themeProvider), ThemeMode.light);
      expect(prefs.getString('mohaseb_theme_mode_v1'), 'light');
    });

    test('استخدام setDark و setLight و setSystem وتحديث الحالة', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      await notifier.setDark();
      expect(container.read(themeProvider), ThemeMode.dark);

      await notifier.setLight();
      expect(container.read(themeProvider), ThemeMode.light);

      await notifier.setSystem();
      expect(container.read(themeProvider), ThemeMode.system);
    });
  });
}
