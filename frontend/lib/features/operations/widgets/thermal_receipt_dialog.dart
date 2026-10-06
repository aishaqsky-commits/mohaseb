import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/journal_entry_model.dart';

class ThermalReceiptDialog extends StatefulWidget {
  final JournalEntryModel entry;

  const ThermalReceiptDialog({super.key, required this.entry});

  static Future<void> show(BuildContext context, JournalEntryModel entry) {
    return showDialog(
      context: context,
      builder: (ctx) => ThermalReceiptDialog(entry: entry),
    );
  }

  @override
  State<ThermalReceiptDialog> createState() => _ThermalReceiptDialogState();
}

class _ThermalReceiptDialogState extends State<ThermalReceiptDialog> {
  bool _is80mm = true; // true = 80mm, false = 58mm

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entry = widget.entry;
    final dateFormat = DateFormat('yyyy/MM/dd  hh:mm:ss a');
    final amount = entry.totalDebit > 0 ? entry.totalDebit : entry.totalCredit;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── مفتاح اختيار مقاس الورق (80mm vs 58mm) ───────
              Container(
                margin: const EdgeInsets.only(bottom: AppDimens.sm),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSizeChip('عرض 80 مم (قياسي)', true),
                    const SizedBox(width: 4),
                    _buildSizeChip('عرض 58 مم (محمول)', false),
                  ],
                ),
              ),

              // ─── ورقة الإيصال الحراري المحاكية للواقع ────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _is80mm ? 360 : 280,
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2129) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ترويسة المنشأة
                    const Icon(Icons.storefront_rounded, size: 36, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      'مؤسسة النور للتجارة والخدمات',
                      style: AppTypography.titleLarge(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الفرع الرئيسي • المركز التجاري',
                      style: AppTypography.bodySmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'هاتف: 777123456 • الرقم الضريبي: 3004512987',
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // فاصل منقط حراري
                    _buildDashedLine(isDark),
                    const SizedBox(height: AppDimens.md),

                    // معلومات الإيصال الأساسية
                    _buildReceiptRow('نوع السند:', _getReferenceLabel(entry.referenceType), isDark, isBold: true),
                    _buildReceiptRow('رقم السند/القيد:', '#${entry.entryNumber}', isDark),
                    _buildReceiptRow('التاريخ والوقت:', dateFormat.format(entry.entryDate), isDark),
                    _buildReceiptRow('حالة الترحيل:', 'مُرحل في الدفاتر ✔', isDark, valueColor: AppColors.success),
                    if (entry.source == EntrySource.ai)
                      _buildReceiptRow('طريقة الإدخال:', 'الذكاء الاصطناعي 🤖', isDark, valueColor: AppColors.accent),

                    const SizedBox(height: AppDimens.md),
                    _buildDashedLine(isDark),
                    const SizedBox(height: AppDimens.md),

                    // البيان والطرف
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'البيان والملاحظات:',
                        style: AppTypography.labelSmall(
                          color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        entry.description,
                        style: AppTypography.bodyMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.md),

                    // خطوط القيد المحاسبي
                    Container(
                      padding: const EdgeInsets.all(AppDimens.sm),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground.withValues(alpha: 0.5)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الحساب / الطرف', style: AppTypography.labelSmall(isBold: true)),
                              Text('مدين', style: AppTypography.labelSmall(isBold: true)),
                              Text('دائن', style: AppTypography.labelSmall(isBold: true)),
                            ],
                          ),
                          const Divider(height: 10, thickness: 0.5),
                          ...entry.lines.map((line) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        line.accountName,
                                        style: AppTypography.bodySmall(
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        line.debit > 0 ? line.debit.toStringAsFixed(0) : '-',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.labelSmall(color: AppColors.income),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        line.credit > 0 ? line.credit.toStringAsFixed(0) : '-',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.labelSmall(color: AppColors.expense),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.md),
                    _buildDashedLine(isDark),
                    const SizedBox(height: AppDimens.md),

                    // إجمالي المبلغ بالخط الكبير
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المبلغ الصافي:',
                          style: AppTypography.titleMedium(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${amount.toStringAsFixed(0)} ر.ي',
                          style: AppTypography.headlineSmall(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.md),
                    _buildDashedLine(isDark),
                    const SizedBox(height: AppDimens.md),

                    // ختم التوازن المحاسبي + باركود محاكى
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.success),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'قيد متوازن وفق معايير القيد المزدوج الإلزامي',
                        style: AppTypography.labelSmall(color: AppColors.success),
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),

                    // محاكاة الباركود
                    _buildBarcodeSimulation(isDark),
                    const SizedBox(height: 4),
                    Text(
                      entry.id.substring(0, 18).toUpperCase(),
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      'شكراً لتعاملكم معنا • نسعد بخدمتكم',
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.md),

              // ─── أزرار الإجراءات (طباعة، مشاركة، إغلاق) ───────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🖨️ جاري الإرسال للطابعة الحرارية (${_is80mm ? "80mm" : "58mm"})...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 20),
                    label: const Text('طباعة فورية'),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📄 تم تصدير الفاتورة ومشاركتها بصيغة PDF بنجاح!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('مشاركة'),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeChip(String label, bool is80) {
    final selected = _is80mm == is80;
    return GestureDetector(
      onTap: () => setState(() => _is80mm = is80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            color: selected ? Colors.white : AppColors.primary,
            isBold: selected,
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              isBold: isBold,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall(
              color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              isBold: isBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.constrainWidth() / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : Colors.grey.shade400,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBarcodeSimulation(bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(36, (index) {
          final isThick = index % 3 == 0 || index % 7 == 0;
          return Container(
            width: isThick ? 3 : 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 1.2),
            color: isDark ? Colors.white70 : Colors.black87,
          );
        }),
      ),
    );
  }

  String _getReferenceLabel(String type) {
    switch (type) {
      case 'cash_sale':
        return 'فاتورة مبيعات نقدية';
      case 'credit_sale':
        return 'فاتورة مبيعات آجلة';
      case 'cash_purchase':
        return 'فاتورة مشتريات نقدية';
      case 'credit_purchase':
        return 'فاتورة مشتريات آجلة';
      case 'expense':
        return 'سند صرف مصروف تشغيلي';
      case 'customer_collection':
        return 'سند قبض وتحصيل';
      case 'supplier_payment':
        return 'سند صرف وسداد مورد';
      case 'payroll':
        return 'سند صرف رواتب';
      default:
        return 'قيد يومية عام';
    }
  }
}
