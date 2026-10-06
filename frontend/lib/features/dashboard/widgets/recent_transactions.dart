import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../operations/providers/operations_provider.dart';

/// قسم آخر العمليات الحي
class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountingState = ref.watch(accountingProvider);
    final entries = accountingState.entries;
    final numberFormat = NumberFormat('#,###');
    final timeFormat = DateFormat('hh:mm a');

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'لا توجد عمليات مسجلة بعد',
              style: AppTypography.titleMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'استخدم أزرار العمليات السريعة لتسجيل أول عملية',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
            ),
          ],
        ),
      );
    }

    final recentList = entries.take(5).toList();

    return Column(
      children: recentList.map((entry) {
        final isIncome = entry.referenceType.contains('sale') || entry.referenceType.contains('collection');
        final amount = entry.totalDebit;
        final color = isIncome ? AppColors.income : AppColors.expense;
        final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: AppDimens.sm),
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // أيقونة العملية
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(width: AppDimens.md),

              // تفاصيل العملية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'قيد #${entry.entryNumber} • مرحل ✓',
                      style: AppTypography.bodySmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // المبلغ والوقت
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${numberFormat.format(amount)}',
                    style: AppTypography.moneySmall(color: color),
                  ),
                  Text(
                    timeFormat.format(entry.entryDate),
                    style: AppTypography.labelSmall(
                      color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
