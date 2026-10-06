import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';

/// قسم التنبيهات في لوحة التحكم
class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final alerts = [
      _Alert(
        'ديون متأخرة',
        '3 عملاء تجاوزوا فترة السداد',
        Icons.warning_amber_rounded,
        AppColors.warning,
      ),
      _Alert(
        'مخزون منخفض',
        '5 أصناف وصلت لحد إعادة الطلب',
        Icons.inventory_rounded,
        AppColors.error,
      ),
    ];

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppDimens.sm),
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            color: alert.color.withValues(alpha: 0.08),
            border: Border.all(
              color: alert.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(alert.icon, color: alert.color, size: 24),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: AppTypography.titleSmall(color: alert.color),
                    ),
                    Text(
                      alert.message,
                      style: AppTypography.bodySmall(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Alert {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _Alert(this.title, this.message, this.icon, this.color);
}
