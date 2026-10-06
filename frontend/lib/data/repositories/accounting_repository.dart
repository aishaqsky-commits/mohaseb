import 'package:uuid/uuid.dart';
import '../datasources/local_database.dart';
import '../datasources/sync_queue_manager.dart';
import '../models/account_model.dart';
import '../models/contact_model.dart';
import '../models/journal_entry_model.dart';
import '../models/operation_model.dart';

class AccountingRepository {
  final LocalDatabase _localDb;
  final SyncQueueManager? _syncQueue;
  final _uuid = const Uuid();

  AccountingRepository(this._localDb, [this._syncQueue]);

  List<AccountModel> getAccounts() => _localDb.getAccounts();
  List<ContactModel> getContacts() => _localDb.getContacts();
  List<JournalEntryModel> getJournalEntries() => _localDb.getJournalEntries();

  /// محرك الترحيل المحاسبي (Posting Engine)
  /// يُنفذ العملية، يولد القيد المزدوج، يتحقق من التوازن، ويحدث الأرصدة
  Future<JournalEntryModel> postOperation({
    required String operationCode,
    required double amount,
    String? contactId,
    String? customDescription,
    DateTime? date,
    EntrySource source = EntrySource.button,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('المبلغ يجب أن يكون أكبر من الصفر');
    }

    final opDef = OperationTypeDefinition.fromCode(operationCode);
    final accounts = _localDb.getAccounts();
    final contacts = _localDb.getContacts();
    final entries = _localDb.getJournalEntries();

    // البحث عن الحسابات حسب دورها في الدليل المحاسبي
    final debitAccount = accounts.firstWhere(
      (a) => a.accountRole == opDef.debitRole,
      orElse: () => accounts.firstWhere((a) => a.type == AccountType.asset),
    );

    final creditAccount = accounts.firstWhere(
      (a) => a.accountRole == opDef.creditRole,
      orElse: () => accounts.firstWhere((a) => a.type == AccountType.revenue),
    );

    ContactModel? contact;
    if (contactId != null) {
      contact = contacts.cast<ContactModel?>().firstWhere(
            (c) => c?.id == contactId,
            orElse: () => null,
          );
    }

    final entryId = _uuid.v4();
    final operationId = _uuid.v4();
    final entryDate = date ?? DateTime.now();
    final entryNumber = entries.length + 1;
    final description = customDescription ??
        '${opDef.title} ${contact != null ? "- ${contact.name}" : ""} بمبلغ ${amount.toStringAsFixed(0)} ر.ي';

    // 1. توليد سطور القيد المزدوج
    final debitLine = JournalLineModel(
      id: _uuid.v4(),
      accountId: debitAccount.id,
      accountName: debitAccount.nameAr,
      debit: amount,
      credit: 0.0,
      contactId: contact?.id,
      contactName: contact?.name,
      memo: 'مدين: ${opDef.title}',
    );

    final creditLine = JournalLineModel(
      id: _uuid.v4(),
      accountId: creditAccount.id,
      accountName: creditAccount.nameAr,
      debit: 0.0,
      credit: amount,
      contactId: contact?.id,
      contactName: contact?.name,
      memo: 'دائن: ${opDef.title}',
    );

    final entry = JournalEntryModel(
      id: entryId,
      entryNumber: entryNumber,
      entryDate: entryDate,
      referenceType: opDef.code,
      referenceId: operationId,
      description: description,
      source: source,
      status: EntryStatus.posted,
      operationId: operationId,
      lines: [debitLine, creditLine],
      createdAt: DateTime.now(),
    );

    // 2. التحقق الصارم من توازن القيد
    if (!entry.isBalanced) {
      throw StateError('فشل ترحيل القيد: القيد غير متوازن رياضياً (Debit != Credit)');
    }

    // 3. تحديث أرصدة الحسابات في الدليل المحاسبي
    final updatedAccounts = accounts.map((acc) {
      if (acc.id == debitAccount.id) {
        final newBal = _applyLineEffect(acc, debit: amount, credit: 0);
        return acc.copyWith(balance: newBal);
      } else if (acc.id == creditAccount.id) {
        final newBal = _applyLineEffect(acc, debit: 0, credit: amount);
        return acc.copyWith(balance: newBal);
      }
      return acc;
    }).toList();

    // 4. تحديث رصيد جهة الاتصال إن وُجدت
    final updatedContacts = contacts.map((c) {
      if (contact != null && c.id == contact.id) {
        double delta = 0.0;
        if (opDef.code == 'credit_sale') {
          delta = amount; // زادت مديونية العميل
        } else if (opDef.code == 'customer_collection') {
          delta = -amount; // سدد العميل جزء من دينه
        } else if (opDef.code == 'credit_purchase') {
          delta = -amount; // زادت ديون المورد علينا
        } else if (opDef.code == 'supplier_payment') {
          delta = amount; // سددنا للمورد
        }
        return c.copyWith(balance: c.balance + delta);
      }
      return c;
    }).toList();

    // 5. حفظ التغييرات محلياً في قاعدة البيانات
    final updatedEntries = [entry, ...entries];
    await _localDb.saveAccounts(updatedAccounts);
    await _localDb.saveContacts(updatedContacts);
    await _localDb.saveJournalEntries(updatedEntries);

    // 6. إضافة العملية إلى طابور المزامنة السحابية غير المتصلة (Offline Sync Queue)
    final syncQueue = _syncQueue;
    if (syncQueue != null) {
      await syncQueue.enqueueEvent(
        operationId: operationId,
        entityType: 'journal_entry',
        action: 'create',
        payload: {
          'operationCode': opDef.code,
          'amount': amount,
          'contactId': contact?.id,
          'description': description,
          'date': entryDate.toIso8601String(),
        },
      );
      // محاولة مزامنة سحابية غير معطلة للواجهة (Background Sync)
      syncQueue.synchronize().ignore();
    }

    return entry;
  }

  /// تطبيق أثر حركة المدين/الدائن على الحساب وفق طبيعته المحاسبية
  double _applyLineEffect(AccountModel acc, {required double debit, required double credit}) {
    if (acc.type.normalBalance == 'debit') {
      // الأصول والمصروفات: تزيد بالمدين وتنقص بالدائن
      return acc.balance + (debit - credit);
    } else {
      // الخصوم وحقوق الملكية والإيرادات: تزيد بالدائن وتنقص بالمدين
      return acc.balance + (credit - debit);
    }
  }
}
