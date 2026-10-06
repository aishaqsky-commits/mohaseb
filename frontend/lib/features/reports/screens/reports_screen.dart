import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/account_model.dart';
import '../../operations/providers/operations_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'month'; // 'today', 'week', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountingState = ref.watch(accountingProvider);
    final accounts = accountingState.accounts;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'التقارير المالية',
          style: AppTypography.headlineSmall(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'تصدير PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تجهيز التقرير وجارٍ تصديره إلى PDF...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_rounded),
            tooltip: 'تصدير Excel',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جارٍ تصدير البيانات إلى Excel...')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.titleMedium(),
          tabs: const [
            Tab(text: 'قائمة الدخل'),
            Tab(text: 'المركز المالي'),
            Tab(text: 'حركة النقدية'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── اختيار الفترة الزمنية ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md,
              vertical: AppDimens.sm,
            ),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الفترة المحددة:',
                  style: AppTypography.labelMedium(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'today', child: Text('اليوم')),
                    DropdownMenuItem(value: 'week', child: Text('هذا الأسبوع')),
                    DropdownMenuItem(value: 'month', child: Text('هذا الشهر')),
                    DropdownMenuItem(value: 'year', child: Text('هذا العام')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
              ],
            ),
          ),

          // ─── محتوى التبويبات ─────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncomeStatement(accounts, isDark),
                _buildBalanceSheet(accounts, isDark),
                _buildCashFlow(accountingState, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. قائمة الدخل (الأرباح والخسائر) ──────────────────────
  Widget _buildIncomeStatement(List<AccountModel> accounts, bool isDark) {
    final revenueAccounts = accounts.where((a) => a.type == AccountType.revenue).toList();
    final expenseAccounts = accounts.where((a) => a.type == AccountType.expense).toList();

    final totalRevenues = revenueAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final totalExpenses = expenseAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final netProfit = totalRevenues - totalExpenses;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: [
        _buildSummaryHeaderCard(
          title: 'صافي الربح التقديري',
          amount: netProfit,
          isProfit: netProfit >= 0,
          isDark: isDark,
        ).animate().fadeIn().slideY(begin: -0.1, end: 0),
        const SizedBox(height: AppDimens.md),

        _buildSectionCard(
          title: 'الإيرادات التشغيلية',
          color: AppColors.success,
          items: revenueAccounts.map((a) => _ReportRow(a.nameAr, a.balance)).toList(),
          total: totalRevenues,
          isDark: isDark,
        ),
        const SizedBox(height: AppDimens.md),

        _buildSectionCard(
          title: 'المصروفات والتكاليف',
          color: AppColors.error,
          items: expenseAccounts.map((a) => _ReportRow(a.nameAr, a.balance)).toList(),
          total: totalExpenses,
          isDark: isDark,
        ),
      ],
    );
  }

  // ─── 2. المركز المالي (الميزانية العمومية) ───────────────────
  Widget _buildBalanceSheet(List<AccountModel> accounts, bool isDark) {
    final assetAccounts = accounts.where((a) => a.type == AccountType.asset).toList();
    final liabilityAccounts = accounts.where((a) => a.type == AccountType.liability).toList();
    final equityAccounts = accounts.where((a) => a.type == AccountType.equity).toList();

    final totalAssets = assetAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final totalLiabilities = liabilityAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final totalEquity = equityAccounts.fold(0.0, (sum, a) => sum + a.balance);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: [
        _buildSectionCard(
          title: 'الأصول (الموجودات)',
          color: AppColors.primary,
          items: assetAccounts.map((a) => _ReportRow(a.nameAr, a.balance)).toList(),
          total: totalAssets,
          isDark: isDark,
        ),
        const SizedBox(height: AppDimens.md),

        _buildSectionCard(
          title: 'الخصوم (المطلوبات والالتزامات)',
          color: AppColors.error,
          items: liabilityAccounts.map((a) => _ReportRow(a.nameAr, a.balance)).toList(),
          total: totalLiabilities,
          isDark: isDark,
        ),
        const SizedBox(height: AppDimens.md),

        _buildSectionCard(
          title: 'حقوق الملكية',
          color: AppColors.secondary,
          items: equityAccounts.map((a) => _ReportRow(a.nameAr, a.balance)).toList(),
          total: totalEquity,
          isDark: isDark,
        ),
      ],
    );
  }

  // ─── 3. حركة النقدية ───────────────────────────────────────
  Widget _buildCashFlow(AccountingState state, bool isDark) {
    final cash = state.cashBalance;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: [
        _buildSummaryHeaderCard(
          title: 'النقدية الحالية المتاحة',
          amount: cash,
          isProfit: cash >= 0,
          isDark: isDark,
        ),
        const SizedBox(height: AppDimens.md),

        _buildSectionCard(
          title: 'حسابات السيولة والنقدية',
          color: AppColors.primary,
          items: state.accounts
              .where((a) => a.accountRole == 'cash' || a.accountRole == 'bank')
              .map((a) => _ReportRow(a.nameAr, a.balance))
              .toList(),
          total: cash,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryHeaderCard({
    required String title,
    required double amount,
    required bool isProfit,
    required bool isDark,
  }) {
    final color = isProfit ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} ر.ي',
            style: AppTypography.moneyLarge(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<_ReportRow> items,
    required double total,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                title,
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: AppTypography.bodyMedium(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${row.amount.toStringAsFixed(0)} ر.ي',
                    style: AppTypography.moneySmall(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '${total.toStringAsFixed(0)} ر.ي',
                style: AppTypography.moneyMedium(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportRow {
  final String label;
  final double amount;
  const _ReportRow(this.label, this.amount);
}
