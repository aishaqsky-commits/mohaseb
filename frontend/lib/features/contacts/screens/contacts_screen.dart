import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/contact_model.dart';
import '../../operations/providers/operations_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  String _selectedFilter = 'all'; // 'all', 'customers', 'suppliers'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountingState = ref.watch(accountingProvider);
    final contacts = accountingState.contacts;

    final filtered = contacts.where((c) {
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'customers' && (c.type == ContactType.customer || c.type == ContactType.both)) ||
          (_selectedFilter == 'suppliers' && (c.type == ContactType.supplier || c.type == ContactType.both));
      final matchesSearch = c.name.contains(_searchQuery) || c.phone.contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    final totalReceivable = contacts
        .where((c) => c.balance > 0)
        .fold(0.0, (sum, c) => sum + c.balance);
    final totalPayable = contacts
        .where((c) => c.balance < 0)
        .fold(0.0, (sum, c) => sum + c.balance.abs());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'العملاء والموردون',
          style: AppTypography.headlineSmall(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'إضافة جهة اتصال',
            onPressed: () => _showAddContactDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── كروت الملخص المالي للديون والمستحقات ───────────────
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'لنا عند العملاء',
                    amount: totalReceivable,
                    color: AppColors.success,
                    icon: Icons.call_received_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: _buildMetricCard(
                    title: 'علينا للموردين',
                    amount: totalPayable,
                    color: AppColors.error,
                    icon: Icons.call_made_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // ─── شريط البحث ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: AppDimens.sm),

          // ─── أزرار الفلترة ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            child: Row(
              children: [
                _buildFilterChip('all', 'الكل (${contacts.length})', isDark),
                const SizedBox(width: AppDimens.sm),
                _buildFilterChip(
                  'customers',
                  'العملاء (${contacts.where((c) => c.type == ContactType.customer || c.type == ContactType.both).length})',
                  isDark,
                ),
                const SizedBox(width: AppDimens.sm),
                _buildFilterChip(
                  'suppliers',
                  'الموردون (${contacts.where((c) => c.type == ContactType.supplier || c.type == ContactType.both).length})',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),

          // ─── قائمة جهات الاتصال ─────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد جهات اتصال مطابقة',
                      style: AppTypography.bodyMedium(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimens.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildContactTile(item, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة جهة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            '${amount.toStringAsFixed(0)} ر.ي',
            style: AppTypography.moneyMedium(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => setState(() => _selectedFilter = key),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelMedium(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ),
    );
  }

  Widget _buildContactTile(ContactModel item, bool isDark) {
    final isCustomer = item.type == ContactType.customer;
    final isDue = item.balance != 0;

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isCustomer
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.secondary.withValues(alpha: 0.12),
            child: Icon(
              isCustomer ? Icons.person_outline_rounded : Icons.storefront_outlined,
              color: isCustomer ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.phone.isEmpty ? 'لا يوجد هاتف' : item.phone,
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.balance.abs().toStringAsFixed(0)} ر.ي',
                style: AppTypography.moneySmall(
                  color: item.balance > 0
                      ? AppColors.success
                      : (item.balance < 0 ? AppColors.error : AppColors.textDisabled),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                !isDue
                    ? 'خالص'
                    : (item.balance > 0 ? 'رصيد عليه' : 'رصيد له'),
                style: AppTypography.labelSmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String type = 'customer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: AppDimens.lg,
                right: AppDimens.lg,
                top: AppDimens.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.lg,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusLg),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إضافة جهة اتصال جديدة',
                    style: AppTypography.titleLarge(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('عميل')),
                          selected: type == 'customer',
                          onSelected: (selected) {
                            if (selected) setModalState(() => type = 'customer');
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('مورد')),
                          selected: type == 'supplier',
                          onSelected: (selected) {
                            if (selected) setModalState(() => type = 'supplier');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت إضافة ${nameCtrl.text.trim()} بنجاح'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: const Text('حفظ جهة الاتصال'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
