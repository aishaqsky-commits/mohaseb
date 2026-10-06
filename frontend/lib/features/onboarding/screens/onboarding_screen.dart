import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';

/// شاشة الأونبوردينق - الترحيب بالمستخدم الجديد
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      title: 'حاسبي الذكي',
      subtitle: 'أدِر حساباتك بذكاء وبساطة',
      description: 'تطبيق محاسبي متكامل مصمم خصيصاً للتجار ومقدمي الخدمات. سجّل عملياتك بضغطة زر واحدة.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.touch_app_rounded,
      title: 'عمليات بضغطة زر',
      subtitle: 'بيع، شراء، مصروف، تحصيل',
      description: 'لا تحتاج لأي خبرة محاسبية. كل عملية = زر واحد. النظام يسجل القيود تلقائياً.',
      color: AppColors.secondary,
    ),
    _OnboardingPage(
      icon: Icons.psychology_rounded,
      title: 'مساعد ذكي بالذكاء الاصطناعي',
      subtitle: 'تحدث بصوتك أو اكتب',
      description: 'قل "سجّل بيعة نقدية ١٠٠ ألف" والتطبيق يفهمك ويسجل القيد المحاسبي الصحيح.',
      color: AppColors.operationAI,
    ),
    _OnboardingPage(
      icon: Icons.wifi_off_rounded,
      title: 'يعمل بدون إنترنت',
      subtitle: 'سجّل عملياتك في أي وقت',
      description: 'كل البيانات محفوظة محلياً. تتم المزامنة تلقائياً عند توفر الاتصال.',
      color: AppColors.info,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDimens.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── زر التخطي ─────────────────────────────
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(
                    'تخطي',
                    style: AppTypography.labelLarge(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ─── محتوى الصفحات ───────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, isDark);
                },
              ),
            ),

            // ─── المؤشرات وزر المتابعة ──────────────────
            Padding(
              padding: const EdgeInsets.all(AppDimens.xxl),
              child: Column(
                children: [
                  // المؤشرات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: AppDimens.animFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : (isDark ? AppColors.darkDivider : AppColors.grey300),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.xxl),

                  // زر المتابعة
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'ابدأ الآن'
                                : 'التالي',
                            style: AppTypography.titleLarge(color: Colors.white),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة كبيرة مع خلفية متدرجة
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.color.withValues(alpha: 0.15),
                  page.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimens.xxxl),

          // العنوان
          Text(
            page.title,
            style: AppTypography.displaySmall(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: AppDimens.sm),

          // العنوان الفرعي
          Text(
            page.subtitle,
            style: AppTypography.titleLarge(color: page.color),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: AppDimens.lg),

          // الوصف
          Text(
            page.description,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
