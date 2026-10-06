import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';

/// شبكة العمليات السريعة
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _QuickAction('بيع نقدي', Icons.point_of_sale_rounded, AppColors.operationSale, 'cash_sale'),
      _QuickAction('بيع آجل', Icons.credit_card_rounded, AppColors.operationSale, 'credit_sale'),
      _QuickAction('تحصيل', Icons.account_balance_wallet_rounded, AppColors.income, 'collect'),
      _QuickAction('شراء نقدي', Icons.shopping_cart_rounded, AppColors.operationPurchase, 'cash_purchase'),
      _QuickAction('شراء آجل', Icons.receipt_rounded, AppColors.operationPurchase, 'credit_purchase'),
      _QuickAction('دفع مورد', Icons.payments_rounded, AppColors.expense, 'pay_supplier'),
      _QuickAction('مصروف', Icons.money_off_rounded, AppColors.operationExpense, 'expense'),
      _QuickAction('رواتب', Icons.groups_rounded, AppColors.operationPayroll, 'payroll'),
      _QuickAction('إيداع رأسمال', Icons.savings_rounded, AppColors.operationCapital, 'capital'),
      _QuickAction('سحب مالك', Icons.account_balance_rounded, AppColors.warning, 'drawing'),
      _QuickAction('جرد المخزون', Icons.inventory_2_rounded, AppColors.operationInventory, 'inventory_adj'),
      _QuickAction('تالف', Icons.delete_sweep_rounded, AppColors.error, 'damage'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppDimens.md,
        crossAxisSpacing: AppDimens.md,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionButton(
          action: action,
          isDark: isDark,
          onTap: () {
            context.push(AppRoutes.operationForm, extra: action.code);
          },
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _QuickAction action;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(
              color: isDark
                  ? AppColors.darkDivider.withValues(alpha: 0.5)
                  : AppColors.lightDivider.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  color: action.color.withValues(alpha: 0.12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                action.label,
                style: AppTypography.labelSmall(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String code;

  _QuickAction(this.label, this.icon, this.color, this.code);
}
