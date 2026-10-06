import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/contact_model.dart';
import '../providers/operations_provider.dart';
import '../widgets/thermal_receipt_dialog.dart';

/// شاشة نموذج العملية المحاسبية
class OperationFormScreen extends ConsumerStatefulWidget {
  final String operationType;

  const OperationFormScreen({super.key, required this.operationType});

  @override
  ConsumerState<OperationFormScreen> createState() => _OperationFormScreenState();
}

class _OperationFormScreenState extends ConsumerState<OperationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedContactId;
  bool _isLoading = false;
  bool _showPreview = false;

  Map<String, _OperationConfig> get _configs => {
        'cash_sale': _OperationConfig('بيع نقدي', Icons.point_of_sale_rounded, AppColors.operationSale, 'الصندوق الرئيسي (أصول)', 'إيرادات المبيعات (إيرادات)'),
        'credit_sale': _OperationConfig('بيع آجل', Icons.receipt_long_rounded, AppColors.income, 'العملاء (ذمم مدينة)', 'إيرادات المبيعات (إيرادات)'),
        'cash_purchase': _OperationConfig('شراء نقدي', Icons.shopping_cart_rounded, AppColors.operationPurchase, 'مخزون البضاعة (أصول)', 'الصندوق الرئيسي (أصول)'),
        'credit_purchase': _OperationConfig('شراء آجل', Icons.inventory_2_rounded, AppColors.secondary, 'مخزون البضاعة (أصول)', 'الموردون (ذمم دائنة)'),
        'expense': _OperationConfig('مصروف عام', Icons.money_off_rounded, AppColors.operationExpense, 'مصروفات تشغيلية (مصروفات)', 'الصندوق الرئيسي (أصول)'),
        'payroll': _OperationConfig('صرف رواتب', Icons.badge_rounded, AppColors.operationPayroll, 'رواتب وأجور (مصروفات)', 'الصندوق الرئيسي (أصول)'),
        'customer_collection': _OperationConfig('قبض من عميل', Icons.download_rounded, AppColors.success, 'الصندوق الرئيسي (أصول)', 'العملاء (ذمم مدينة)'),
        'collect': _OperationConfig('قبض من عميل', Icons.download_rounded, AppColors.success, 'الصندوق الرئيسي (أصول)', 'العملاء (ذمم مدينة)'),
        'supplier_payment': _OperationConfig('سداد لمورد', Icons.upload_rounded, AppColors.warning, 'الموردون (ذمم دائنة)', 'الصندوق الرئيسي (أصول)'),
        'pay_supplier': _OperationConfig('سداد لمورد', Icons.upload_rounded, AppColors.warning, 'الموردون (ذمم دائنة)', 'الصندوق الرئيسي (أصول)'),
        'capital_deposit': _OperationConfig('إيداع رأسمال', Icons.account_balance_rounded, AppColors.operationCapital, 'الصندوق الرئيسي (أصول)', 'رأس المال (حقوق ملكية)'),
        'capital': _OperationConfig('إيداع رأسمال', Icons.account_balance_rounded, AppColors.operationCapital, 'الصندوق الرئيسي (أصول)', 'رأس المال (حقوق ملكية)'),
        'owner_drawing': _OperationConfig('مسحوبات شخصية', Icons.person_remove_rounded, const Color(0xFFE91E63), 'مسحوبات المالك (حقوق ملكية)', 'الصندوق الرئيسي (أصول)'),
        'drawing': _OperationConfig('مسحوبات شخصية', Icons.person_remove_rounded, const Color(0xFFE91E63), 'مسحوبات المالك (حقوق ملكية)', 'الصندوق الرئيسي (أصول)'),
      };

  _OperationConfig get _config =>
      _configs[widget.operationType] ?? _configs['cash_sale']!;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveOperation() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final entry = await ref.read(accountingProvider.notifier).executeOperation(
        operationCode: widget.operationType,
        amount: amount,
        contactId: _selectedContactId,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text('تم تسجيل ${_config.title} بنجاح (قيد رقم #${entry?.entryNumber ?? ""})'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          action: entry != null
              ? SnackBarAction(
                  label: 'طباعة الإيصال 🖨️',
                  textColor: Colors.amberAccent,
                  onPressed: () => ThermalReceiptDialog.show(context, entry),
                )
              : null,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء حفظ العملية: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountingState = ref.watch(accountingProvider);
    final availableContacts = accountingState.contacts.where((c) {
      if (_isCustomerOp) {
        return c.type == ContactType.customer || c.type == ContactType.both;
      } else {
        return c.type == ContactType.supplier || c.type == ContactType.both;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_config.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── أيقونة العملية ──────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _config.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(_config.icon, size: 36, color: _config.color),
                ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              ),

              const SizedBox(height: AppDimens.xxl),

              // ─── المبلغ ──────────────────────────────────
              Text(
                'المبلغ',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                style: AppTypography.moneyMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: 'ر.ي',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: _config.color),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'الرجاء إدخال المبلغ';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'المبلغ غير صحيح';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppDimens.lg),

              // ─── جهة الاتصال (عميل أو مورد) ──────────────
              if (_needsContact) ...[
                Text(
                  _isCustomerOp ? 'العميل' : 'المورد',
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                DropdownButtonFormField<String>(
                  initialValue: _selectedContactId,
                  decoration: InputDecoration(
                    hintText: 'اختر ${_isCustomerOp ? "العميل" : "المورد"}',
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                  items: availableContacts.map((contact) {
                    return DropdownMenuItem(
                      value: contact.id,
                      child: Text('${contact.name} (${contact.phone})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedContactId = value),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: AppDimens.lg),
              ],

              // ─── البيان / الملاحظات ────────────────────────
              Text(
                'البيان (اختياري)',
                style: AppTypography.titleMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات إضافية عن العملية...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppDimens.xl),

              // ─── معاينة القيد المحاسبي المزدوج ─────────────
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _showPreview,
                  onExpansionChanged: (val) => setState(() => _showPreview = val),
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: AppDimens.xs),
                      Text(
                        'معاينة القيد المحاسبي المزدوج',
                        style: AppTypography.titleSmall(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الطرف المدين (+)', style: AppTypography.labelSmall(color: AppColors.success)),
                              Text(_config.debitAccount, style: AppTypography.bodySmall()),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الطرف الدائن (-)', style: AppTypography.labelSmall(color: AppColors.error)),
                              Text(_config.creditAccount, style: AppTypography.bodySmall()),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('حالة القيد', style: AppTypography.labelSmall()),
                              Text('متوازن محاسبياً (Debit = Credit)', style: AppTypography.labelSmall(color: AppColors.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.xxxl),

              // ─── زر الحفظ ──────────────────────────────
              SizedBox(
                height: AppDimens.buttonHeightXl,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveOperation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _config.color,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded, size: 24),
                            const SizedBox(width: AppDimens.sm),
                            Text(
                              'تسجيل ${_config.title}',
                              style: AppTypography.titleLarge(color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  bool get _needsContact {
    return ['credit_sale', 'credit_purchase', 'customer_collection', 'supplier_payment', 'collect', 'pay_supplier']
        .contains(widget.operationType);
  }

  bool get _isCustomerOp {
    return ['credit_sale', 'customer_collection', 'collect'].contains(widget.operationType);
  }
}

class _OperationConfig {
  final String title;
  final IconData icon;
  final Color color;
  final String debitAccount;
  final String creditAccount;

  _OperationConfig(
    this.title,
    this.icon,
    this.color,
    this.debitAccount,
    this.creditAccount,
  );
}
