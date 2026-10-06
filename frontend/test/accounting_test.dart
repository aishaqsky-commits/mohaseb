import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mohaseb/data/models/account_model.dart';
import 'package:mohaseb/data/models/contact_model.dart';
import 'package:mohaseb/data/datasources/local_database.dart';
import 'package:mohaseb/data/repositories/accounting_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('محرك القيود والترحيل المحاسبي (Accounting Engine Tests)', () {
    late LocalDatabase localDb;
    late AccountingRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      localDb = await LocalDatabase.init();
      repo = AccountingRepository(localDb);
    });

    test('تهيئة دليل الحسابات الافتراضي بنجاح وتوازن الأرصدة التأسيسية', () {
      final accounts = repo.getAccounts();
      expect(accounts.isNotEmpty, true);

      final cashAcc = accounts.firstWhere((a) => a.accountRole == 'cash');
      expect(cashAcc.type, AccountType.asset);
      expect(cashAcc.type.normalBalance, 'debit');

      final salesAcc = accounts.firstWhere((a) => a.accountRole == 'sales_revenue');
      expect(salesAcc.type, AccountType.revenue);
      expect(salesAcc.type.normalBalance, 'credit');
    });

    test('التحقق من توازن القيد المزدوج لعملية بيع نقدي (Cash Sale)', () async {
      final entry = await repo.postOperation(
        operationCode: 'cash_sale',
        amount: 50000,
        customDescription: 'بيع نقدي تجريبي',
      );

      expect(entry.isBalanced, true);
      expect(entry.totalDebit, 50000);
      expect(entry.totalCredit, 50000);
      expect(entry.lines.length, 2);

      final debitLine = entry.lines.firstWhere((l) => l.debit > 0);
      expect(debitLine.accountName.contains('الصندوق'), true);

      final creditLine = entry.lines.firstWhere((l) => l.credit > 0);
      expect(creditLine.accountName.contains('المبيعات'), true);
    });

    test('تسجيل بيع آجل وتحديث مديونية العميل وتوازن القيد', () async {
      final contacts = repo.getContacts();
      final customer = contacts.firstWhere((c) => c.type == ContactType.customer);
      final initialBalance = customer.balance;

      final entry = await repo.postOperation(
        operationCode: 'credit_sale',
        amount: 30000,
        contactId: customer.id,
      );

      expect(entry.isBalanced, true);
      expect(entry.totalDebit, 30000);
      expect(entry.totalCredit, 30000);

      final updatedContacts = repo.getContacts();
      final updatedCustomer = updatedContacts.firstWhere((c) => c.id == customer.id);
      expect(updatedCustomer.balance, initialBalance + 30000);
    });

    test('تسجيل تحصيل من عميل ونقصان مديونيته وتوازن القيد', () async {
      final contacts = repo.getContacts();
      final customer = contacts.firstWhere((c) => c.type == ContactType.customer);
      final initialBalance = customer.balance;

      final entry = await repo.postOperation(
        operationCode: 'customer_collection',
        amount: 15000,
        contactId: customer.id,
      );

      expect(entry.isBalanced, true);
      expect(entry.totalDebit, 15000);
      expect(entry.totalCredit, 15000);

      final updatedContacts = repo.getContacts();
      final updatedCustomer = updatedContacts.firstWhere((c) => c.id == customer.id);
      expect(updatedCustomer.balance, initialBalance - 15000);
    });

    test('تسجيل مصروف تشغيلي وتأثيره على رصيد الصندوق والمصروفات', () async {
      final accountsBefore = repo.getAccounts();
      final cashBefore = accountsBefore.firstWhere((a) => a.accountRole == 'cash').balance;

      final entry = await repo.postOperation(
        operationCode: 'expense',
        amount: 20000,
        customDescription: 'سداد فاتورة إنترنت',
      );

      expect(entry.isBalanced, true);

      final accountsAfter = repo.getAccounts();
      final cashAfter = accountsAfter.firstWhere((a) => a.accountRole == 'cash').balance;
      expect(cashAfter, cashBefore - 20000);
    });

    test('رفض المبالغ الصفرية أو السالبة فورياً لحماية دقة البيانات', () async {
      expect(
        () => repo.postOperation(operationCode: 'cash_sale', amount: 0),
        throwsArgumentError,
      );
      expect(
        () => repo.postOperation(operationCode: 'cash_sale', amount: -500),
        throwsArgumentError,
      );
    });
  });
}
