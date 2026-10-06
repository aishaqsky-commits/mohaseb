import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/company_setup_screen.dart';
import '../../features/dashboard/screens/main_shell_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/operations/screens/operations_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/ai_chat/screens/ai_chat_screen.dart';
import '../../features/operations/screens/operation_form_screen.dart';

/// مسارات التطبيق
class AppRoutes {
  AppRoutes._();

  // ─── المسارات الرئيسية ─────────────────────────────────
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String companySetup = '/company-setup';

  // ─── الشاشات الرئيسية (Shell) ─────────────────────────
  static const String dashboard = '/dashboard';
  static const String operations = '/operations';
  static const String contacts = '/contacts';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // ─── شاشات فرعية ───────────────────────────────────────
  static const String aiChat = '/ai-chat';
  static const String operationForm = '/operation-form';
}

/// مزود الراوتر
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    routes: [
      // ─── الأونبوردينق ──────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ─── تسجيل الدخول ──────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── التحقق من الرمز ────────────────────────────────
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // ─── إعداد الشركة ──────────────────────────────────
      GoRoute(
        path: AppRoutes.companySetup,
        builder: (context, state) => const CompanySetupScreen(),
      ),

      // ─── الشل الرئيسي (BottomNav) ──────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.operations,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperationsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.contacts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // ─── شاشات فرعية ────────────────────────────────────
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.operationForm,
        builder: (context, state) {
          final operationType = state.extra as String? ?? 'cash_sale';
          return OperationFormScreen(operationType: operationType);
        },
      ),
    ],
  );
});
