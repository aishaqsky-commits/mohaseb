import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mohaseb/data/models/journal_entry_model.dart';
import 'package:mohaseb/data/datasources/local_database.dart';
import 'package:mohaseb/data/datasources/sync_queue_manager.dart';
import 'package:mohaseb/data/datasources/remote_api_client.dart';
import 'package:mohaseb/data/repositories/accounting_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('اختبارات تكامل الذكاء الاصطناعي والمزامنة السحابية (AI & Sync Integration)', () {
    late LocalDatabase localDb;
    late SharedPreferences prefs;
    late SyncQueueManager syncQueue;
    late AccountingRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localDb = await LocalDatabase.init();
      final apiClient = RemoteApiClient();
      syncQueue = SyncQueueManager(prefs: prefs, apiClient: apiClient);
      repo = AccountingRepository(localDb, syncQueue);
    });

    test('ترحيل عملية ناتجة عن مقترح الذكاء الاصطناعي مع حفظ مصدر القيد وتوازنه', () async {
      final initialEntriesCount = repo.getJournalEntries().length;

      final entry = await repo.postOperation(
        operationCode: 'expense',
        amount: 25000,
        customDescription: 'سداد مصروف كهرباء مقترح من المساعد الذكي',
        source: EntrySource.ai,
      );

      expect(entry.isBalanced, true);
      expect(entry.totalDebit, 25000);
      expect(entry.totalCredit, 25000);
      expect(entry.source, EntrySource.ai);
      expect(repo.getJournalEntries().length, initialEntriesCount + 1);

      // التأكد من إدراج الحدث في طابور المزامنة المحلية
      final pendingEvents = syncQueue.getPendingEvents();
      expect(pendingEvents.isNotEmpty, true);
      final lastEvent = pendingEvents.last;
      expect(lastEvent['entityType'], 'journal_entry');
      expect(lastEvent['action'], 'create');
      final payload = lastEvent['payload'] as Map<String, dynamic>;
      expect(payload['amount'], 25000);
      expect(payload['operationCode'], 'expense');
    });

    test('إدارة طابور المزامنة عند انقطاع الاتصال وحفظ العمليات محلياً دون فقدان', () async {
      await syncQueue.enqueueEvent(
        operationId: 'sync_test_op_123',
        entityType: 'journal_entry',
        action: 'create',
        payload: {
          'operationCode': 'cash_sale',
          'amount': 40000,
          'description': 'مبيعات نقدية أثناء انقطاع الإنترنت',
        },
      );

      final events = syncQueue.getPendingEvents();
      expect(events.any((e) => e['operationId'] == 'sync_test_op_123'), true);
      expect(syncQueue.pendingCount, greaterThanOrEqualTo(1));
    });

    test('تأكيد قاعدة القيد المزدوج الإلزامية: مجموع المدين يساوي دائماً مجموع الدائن', () async {
      final operations = [
        ('cash_sale', 15000.0),
        ('credit_sale', 42000.0),
        ('cash_purchase', 35000.0),
        ('expense', 8000.0),
        ('customer_collection', 12000.0),
        ('supplier_payment', 20000.0),
      ];

      for (final (code, amount) in operations) {
        final entry = await repo.postOperation(
          operationCode: code,
          amount: amount,
          source: EntrySource.ai,
        );

        expect(entry.isBalanced, true, reason: 'العملية $code يجب أن تكون متوازنة تماماً');
        expect(entry.totalDebit, amount);
        expect(entry.totalCredit, amount);
      }
    });
  });
}
