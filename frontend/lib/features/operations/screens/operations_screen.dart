import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/journal_entry_model.dart';
import '../providers/operations_provider.dart';
import '../widgets/thermal_receipt_dialog.dart';

/// شاشة العمليات وسجل قيود اليومية
class OperationsScreen extends ConsumerStatefulWidget {
  const OperationsScreen({super.key});

  @override
  ConsumerState<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends ConsumerState<OperationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات والقيود'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'المبيعات'),
            Tab(text: 'المشتريات'),
            Tab(text: 'الخزينة والمصروفات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntriesList(accountingState.entries, 'all', isDark),
          _buildEntriesList(
            accountingState.entries.where((e) => e.referenceType.contains('sale')).toList(),
            'sales',
            isDark,
          ),
          _buildEntriesList(
            accountingState.entries.where((e) => e.referenceType.contains('purchase')).toList(),
            'purchases',
            isDark,
          ),
          _buildEntriesList(
            accountingState.entries.where((e) => !e.referenceType.contains('sale') && !e.referenceType.contains('purchase')).toList(),
            'treasury',
            isDark,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOperationPicker(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('عملية جديدة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEntriesList(List<JournalEntryModel> entries, String category, bool isDark) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              'لا توجد عمليات مسجلة في هذا القسم',
              style: AppTypography.titleMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'اضغط على "عملية جديدة" لتسجيل بيع أو شراء أو مصروف فوري',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('yyyy/MM/dd hh:mm a');

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.lg),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isIncome = entry.referenceType.contains('sale') || entry.referenceType.contains('collection');
        final amount = entry.totalDebit;

        return Container(
          margin: const EdgeInsets.only(bottom: AppDimens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg,
              vertical: AppDimens.sm,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                color: (isIncome ? AppColors.income : AppColors.expense)
                    .withValues(alpha: 0.12),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
            title: Text(
              entry.description,
              style: AppTypography.titleSmall(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  'قيد #${entry.entryNumber} • ${dateFormat.format(entry.entryDate)}',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.success.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    'مرحل',
                    style: AppTypography.labelSmall(color: AppColors.success),
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? "+" : "-"}${amount.toStringAsFixed(0)}',
                  style: AppTypography.moneySmall(
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
                Text(
                  'ر.ي',
                  style: AppTypography.labelSmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            onTap: () => _showEntryDetails(context, entry, isDark),
          ),
        );
      },
    );
  }

  void _showEntryDetails(BuildContext context, JournalEntryModel entry, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل قيد اليومية #${entry.entryNumber}',
                    style: AppTypography.titleLarge(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('متوازن ✓', style: AppTypography.labelSmall(color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sm),
              Text(entry.description, style: AppTypography.bodyMedium()),
              const Divider(height: 24),
              ...entry.lines.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(line.accountName, style: AppTypography.bodyMedium()),
                        Text(
                          line.debit > 0
                              ? 'مدين: ${line.debit.toStringAsFixed(0)} ر.ي'
                              : 'دائن: ${line.credit.toStringAsFixed(0)} ر.ي',
                          style: AppTypography.bodySmall(
                            color: line.debit > 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي القيد', style: AppTypography.titleMedium()),
                  Text(
                    '${entry.totalDebit.toStringAsFixed(0)} ر.ي',
                    style: AppTypography.moneyMedium(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ThermalReceiptDialog.show(context, entry);
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: const Text('عرض وطباعة الإيصال الحراري (80mm/58mm)'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOperationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppDimens.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Text(
                  'اختر نوع العملية',
                  style: AppTypography.titleLarge(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.xl),
                  children: [
                    _buildPickerItem(ctx, 'cash_sale', 'بيع نقدي', Icons.point_of_sale_rounded, AppColors.operationSale, 'استلام نقد فوري'),
                    _buildPickerItem(ctx, 'credit_sale', 'بيع آجل', Icons.receipt_long_rounded, AppColors.income, 'تسجيل دين على عميل'),
                    _buildPickerItem(ctx, 'cash_purchase', 'شراء نقدي', Icons.shopping_cart_rounded, AppColors.operationPurchase, 'دفع كاش لشراء بضاعة'),
                    _buildPickerItem(ctx, 'credit_purchase', 'شراء آجل', Icons.inventory_2_rounded, AppColors.secondary, 'شراء بضاعة بالدين من مورد'),
                    _buildPickerItem(ctx, 'expense', 'مصروف عام', Icons.money_off_rounded, AppColors.operationExpense, 'إيجار، كهرباء، صيانة'),
                    _buildPickerItem(ctx, 'customer_collection', 'قبض من عميل', Icons.download_rounded, AppColors.success, 'تحصيل دين من عميل'),
                    _buildPickerItem(ctx, 'supplier_payment', 'سداد لمورد', Icons.upload_rounded, AppColors.warning, 'سداد دين لمورد'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerItem(
    BuildContext context,
    String type,
    String title,
    IconData icon,
    Color color,
    String desc,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: AppTypography.titleMedium()),
      subtitle: Text(desc, style: AppTypography.bodySmall()),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: () {
        Navigator.pop(context);
        context.push(AppRoutes.operationForm, extra: type);
      },
    );
  }
}
