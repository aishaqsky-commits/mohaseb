import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../operations/providers/operations_provider.dart';

/// بطاقات الملخص المالي الحي في لوحة التحكم
class SummaryCards extends ConsumerWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountingState = ref.watch(accountingProvider);
    final numberFormat = NumberFormat('#,###');

    final cash = accountingState.cashBalance;
    final receivables = accountingState.totalReceivables;
    final payables = accountingState.totalPayables;

    return Column(
      children: [
        // ─── بطاقة الرصيد النقدي الرئيسي ─────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.xl),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'النقد المتاح (الصندوق)',
                    style: AppTypography.titleMedium(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                      vertical: AppDimens.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: Text(
                      'محدّث لحظياً',
                      style: AppTypography.labelSmall(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                numberFormat.format(cash),
                style: AppTypography.moneyLarge(color: Colors.white),
              ),
              Text(
                'ريال يمني (YER)',
                style: AppTypography.bodySmall(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppDimens.lg),
              Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Colors.greenAccent.shade200,
                    size: 18,
                  ),
                  const SizedBox(width: AppDimens.xs),
                  Text(
                    'الدفاتر متوازنة محاسبياً (Double-Entry Balanced)',
                    style: AppTypography.bodySmall(
                      color: Colors.greenAccent.shade200,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.md),

        // ─── بطاقتين جانبيتين (ديون العملاء + مستحقات الموردين) ──────
        Row(
          children: [
            // ديون العملاء
            Expanded(
              child: _MiniSummaryCard(
                title: 'لنا عند العملاء',
                amount: numberFormat.format(receivables),
                icon: Icons.arrow_downward_rounded,
                color: AppColors.income,
                isDark: isDark,
              ),
            ),

            const SizedBox(width: AppDimens.md),

            // مستحقات الموردين
            Expanded(
              child: _MiniSummaryCard(
                title: 'علينا للموردين',
                amount: numberFormat.format(payables),
                icon: Icons.arrow_upward_rounded,
                color: AppColors.expense,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniSummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider.withValues(alpha: 0.3)
              : AppColors.lightDivider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            amount,
            style: AppTypography.moneyMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            'ريال يمني',
            style: AppTypography.labelSmall(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
