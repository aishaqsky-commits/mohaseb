import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/alerts_section.dart';

/// الشاشة الرئيسية - لوحة التحكم (Dashboard)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── الهيدر ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.darkGradient : AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.xxl, AppDimens.lg, AppDimens.xxl, AppDimens.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // أيقونة المستخدم
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحباً، أحمد 👋',
                                    style: AppTypography.titleLarge(color: Colors.white),
                                  ),
                                  Text(
                                    'محلات النور للإلكترونيات',
                                    style: AppTypography.bodySmall(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // أيقونة الإشعارات
                            IconButton(
                              onPressed: () {},
                              icon: Badge(
                                label: const Text('3'),
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── المحتوى ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── بطاقات الملخص ──────────────────────
                  const SummaryCards()
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppDimens.xxl),

                  // ─── التنبيهات ───────────────────────────
                  const AlertsSection()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppDimens.xxl),

                  // ─── العمليات السريعة ────────────────────
                  Text(
                    'العمليات السريعة',
                    style: AppTypography.headlineSmall(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppDimens.md),

                  const QuickActionsGrid()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppDimens.xxl),

                  // ─── آخر العمليات ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'آخر العمليات',
                        style: AppTypography.headlineSmall(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const RecentTransactions()
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppDimens.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
