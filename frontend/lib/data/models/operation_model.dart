import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum OperationCategory {
  sales('مبيعات'),
  purchases('مشتريات'),
  treasury('خزينة ومصروفات'),
  equity('حقوق الملكية');

  final String labelAr;
  const OperationCategory(this.labelAr);
}

class OperationTypeDefinition {
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final OperationCategory category;
  final String debitRole; // Role in chart of accounts
  final String creditRole; // Role in chart of accounts
  final bool requiresContact;
  final bool isCustomerContact; // true: customer, false: supplier

  const OperationTypeDefinition({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.category,
    required this.debitRole,
    required this.creditRole,
    this.requiresContact = false,
    this.isCustomerContact = true,
  });

  /// قائمة العمليات الـ 10 المعيارية حسب وثيقة المشروع الشاملة
  static const List<OperationTypeDefinition> all = [
    // 1. بيع نقدي
    OperationTypeDefinition(
      code: 'cash_sale',
      title: 'بيع نقدي',
      subtitle: 'استلام نقد فوري مقابل بيع بضاعة أو خدمة',
      icon: Icons.point_of_sale_rounded,
      color: AppColors.operationSale,
      category: OperationCategory.sales,
      debitRole: 'cash',
      creditRole: 'sales_revenue',
    ),
    // 2. بيع آجل
    OperationTypeDefinition(
      code: 'credit_sale',
      title: 'بيع آجل (دين للعميل)',
      subtitle: 'تسجيل بضاعة على حساب عميل للدفع لاحقاً',
      icon: Icons.receipt_long_rounded,
      color: AppColors.income,
      category: OperationCategory.sales,
      debitRole: 'receivables',
      creditRole: 'sales_revenue',
      requiresContact: true,
      isCustomerContact: true,
    ),
    // 3. شراء نقدي
    OperationTypeDefinition(
      code: 'cash_purchase',
      title: 'شراء نقدي',
      subtitle: 'دفع كاش فوري لشراء بضاعة للمخزن',
      icon: Icons.shopping_cart_rounded,
      color: AppColors.operationPurchase,
      category: OperationCategory.purchases,
      debitRole: 'inventory',
      creditRole: 'cash',
    ),
    // 4. شراء آجل
    OperationTypeDefinition(
      code: 'credit_purchase',
      title: 'شراء آجل (دين من مورد)',
      subtitle: 'استلام بضاعة بالآجل من مورد للمخزن',
      icon: Icons.inventory_2_rounded,
      color: AppColors.secondary,
      category: OperationCategory.purchases,
      debitRole: 'inventory',
      creditRole: 'payables',
      requiresContact: true,
      isCustomerContact: false,
    ),
    // 5. مصروف عام
    OperationTypeDefinition(
      code: 'expense',
      title: 'تسجيل مصروف',
      subtitle: 'إيجار، كهرباء، صيانة، إنترنت، ضيافة',
      icon: Icons.money_off_rounded,
      color: AppColors.operationExpense,
      category: OperationCategory.treasury,
      debitRole: 'operating_expense',
      creditRole: 'cash',
    ),
    // 6. رواتب وأجور
    OperationTypeDefinition(
      code: 'payroll',
      title: 'صرف رواتب',
      subtitle: 'دفع رواتب الموظفين والعمال نقداً',
      icon: Icons.badge_rounded,
      color: AppColors.operationPayroll,
      category: OperationCategory.treasury,
      debitRole: 'salaries_expense',
      creditRole: 'cash',
    ),
    // 7. تحصيل من عميل
    OperationTypeDefinition(
      code: 'customer_collection',
      title: 'قبض من عميل',
      subtitle: 'استلام دفعة نقدية وسداد دين من عميل',
      icon: Icons.download_rounded,
      color: AppColors.success,
      category: OperationCategory.treasury,
      debitRole: 'cash',
      creditRole: 'receivables',
      requiresContact: true,
      isCustomerContact: true,
    ),
    // 8. سداد لمورد
    OperationTypeDefinition(
      code: 'supplier_payment',
      title: 'سداد لمورد',
      subtitle: 'دفع دفعة نقدية لمورد من الديون المستحقة',
      icon: Icons.upload_rounded,
      color: AppColors.warning,
      category: OperationCategory.treasury,
      debitRole: 'payables',
      creditRole: 'cash',
      requiresContact: true,
      isCustomerContact: false,
    ),
    // 9. إيداع رأس مال
    OperationTypeDefinition(
      code: 'capital_deposit',
      title: 'إيداع رأس مال',
      subtitle: 'إضافة أموال شخصية إلى الصندوق لزيادة رأس المال',
      icon: Icons.account_balance_rounded,
      color: AppColors.operationCapital,
      category: OperationCategory.equity,
      debitRole: 'cash',
      creditRole: 'capital',
    ),
    // 10. مسحوبات شخصية
    OperationTypeDefinition(
      code: 'owner_drawing',
      title: 'مسحوبات شخصية',
      subtitle: 'سحب أموال من الصندوق للاستخدام الشخصي للمالك',
      icon: Icons.person_remove_rounded,
      color: Color(0xFFE91E63),
      category: OperationCategory.equity,
      debitRole: 'drawings',
      creditRole: 'cash',
    ),
  ];

  static OperationTypeDefinition fromCode(String rawCode) {
    var code = rawCode;
    if (code == 'collect') code = 'customer_collection';
    if (code == 'pay_supplier') code = 'supplier_payment';
    if (code == 'capital') code = 'capital_deposit';
    if (code == 'drawing') code = 'owner_drawing';

    return all.firstWhere(
      (op) => op.code == code,
      orElse: () => all.first,
    );
  }
}
