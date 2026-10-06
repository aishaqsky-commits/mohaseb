enum AccountType {
  asset('asset', 'أصول', 'debit'),
  liability('liability', 'خصوم', 'credit'),
  equity('equity', 'حقوق ملكية', 'credit'),
  revenue('revenue', 'إيرادات', 'credit'),
  expense('expense', 'مصروفات', 'debit');

  final String code;
  final String nameAr;
  final String normalBalance; // 'debit' or 'credit'

  const AccountType(this.code, this.nameAr, this.normalBalance);
}

class AccountModel {
  final String id;
  final String code;
  final String nameAr;
  final AccountType type;
  final String? accountRole; // cash, bank, receivables, payables, inventory, sales, expenses, etc.
  final double balance;
  final bool isSystem;

  const AccountModel({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.type,
    this.accountRole,
    this.balance = 0.0,
    this.isSystem = false,
  });

  AccountModel copyWith({
    String? id,
    String? code,
    String? nameAr,
    AccountType? type,
    String? accountRole,
    double? balance,
    bool? isSystem,
  }) {
    return AccountModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      accountRole: accountRole ?? this.accountRole,
      balance: balance ?? this.balance,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'nameAr': nameAr,
        'type': type.code,
        'accountRole': accountRole,
        'balance': balance,
        'isSystem': isSystem,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      code: json['code'] as String,
      nameAr: json['nameAr'] as String,
      type: AccountType.values.firstWhere((t) => t.code == json['type']),
      accountRole: json['accountRole'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  /// دليل الحسابات الافتراضي المبسط للأنشطة التجارية والخدمية
  static List<AccountModel> get defaultChartOfAccounts => [
        // ─── 1. الأصول ──────────────────────────────────────
        const AccountModel(
          id: 'acc_101',
          code: '101',
          nameAr: 'الصندوق الرئيسي (النقدية)',
          type: AccountType.asset,
          accountRole: 'cash',
          balance: 850000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_102',
          code: '102',
          nameAr: 'الحساب البنكي (الكريمي / بنك اليمن الدولي)',
          type: AccountType.asset,
          accountRole: 'bank',
          balance: 1200000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_103',
          code: '103',
          nameAr: 'العملاء والمدينون (الذمم المدينة)',
          type: AccountType.asset,
          accountRole: 'receivables',
          balance: 600000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_104',
          code: '104',
          nameAr: 'مخزون البضاعة',
          type: AccountType.asset,
          accountRole: 'inventory',
          balance: 2000000.0,
          isSystem: true,
        ),

        // ─── 2. الخصوم ──────────────────────────────────────
        const AccountModel(
          id: 'acc_201',
          code: '201',
          nameAr: 'الموردون والدائنون (الذمم الدائنة)',
          type: AccountType.liability,
          accountRole: 'payables',
          balance: 470000.0,
          isSystem: true,
        ),

        // ─── 3. حقوق الملكية ────────────────────────────────
        const AccountModel(
          id: 'acc_301',
          code: '301',
          nameAr: 'رأس المال',
          type: AccountType.equity,
          accountRole: 'capital',
          balance: 3830000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_302',
          code: '302',
          nameAr: 'مسحوبات المالك الشخصية',
          type: AccountType.equity,
          accountRole: 'drawings',
          balance: 50000.0,
          isSystem: true,
        ),

        // ─── 4. الإيرادات ────────────────────────────────────
        const AccountModel(
          id: 'acc_401',
          code: '401',
          nameAr: 'إيرادات المبيعات',
          type: AccountType.revenue,
          accountRole: 'sales_revenue',
          balance: 1250000.0,
          isSystem: true,
        ),

        // ─── 5. المصروفات ───────────────────────────────────
        const AccountModel(
          id: 'acc_501',
          code: '501',
          nameAr: 'تكلفة البضاعة المباعة',
          type: AccountType.expense,
          accountRole: 'cogs',
          balance: 720000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_502',
          code: '502',
          nameAr: 'مصروفات تشغيلية وعمومية (إيجار / كهرباء)',
          type: AccountType.expense,
          accountRole: 'operating_expense',
          balance: 115000.0,
          isSystem: true,
        ),
        const AccountModel(
          id: 'acc_503',
          code: '503',
          nameAr: 'رواتب وأجور الموظفين',
          type: AccountType.expense,
          accountRole: 'salaries_expense',
          balance: 65000.0,
          isSystem: true,
        ),
      ];
}
