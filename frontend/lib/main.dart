import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MohasebApp(),
    ),
  );
}

/// التطبيق الرئيسي - حاسبي الذكي
class MohasebApp extends ConsumerWidget {
  const MohasebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'حاسبي الذكي',
      debugShowCheckedModeBanner: false,

      // ─── الثيمات ──────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ─── التنقل ───────────────────────────────────────────
      routerConfig: router,

      // ─── دعم العربية و RTL ────────────────────────────────
      locale: const Locale('ar', 'YE'),
      supportedLocales: const [
        Locale('ar', 'YE'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        // سنضيف الترجمة لاحقاً
      ],

      // ─── اتجاه النص ────────────────────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
