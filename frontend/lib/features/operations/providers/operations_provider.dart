import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local_database.dart';
import '../../../data/datasources/remote_api_client.dart';
import '../../../data/datasources/sync_queue_manager.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../../data/repositories/accounting_repository.dart';
import '../../../shared/providers/theme_provider.dart';

/// حالة النظام المحاسبي العامة
class AccountingState {
  final bool isLoading;
  final List<AccountModel> accounts;
  final List<ContactModel> contacts;
  final List<JournalEntryModel> entries;

  const AccountingState({
    this.isLoading = false,
    this.accounts = const [],
    this.contacts = const [],
    this.entries = const [],
  });

  AccountingState copyWith({
    bool? isLoading,
    List<AccountModel>? accounts,
    List<ContactModel>? contacts,
    List<JournalEntryModel>? entries,
  }) {
    return AccountingState(
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      contacts: contacts ?? this.contacts,
      entries: entries ?? this.entries,
    );
  }

  // ─── مقاييس مالية محسوبة فورياً ─────────────────────────────
  double get cashBalance {
    final cashAcc = accounts.firstWhere(
      (a) => a.accountRole == 'cash',
      orElse: () => accounts.firstWhere(
        (a) => a.type == AccountType.asset,
        orElse: () => const AccountModel(
          id: '',
          code: '',
          nameAr: '',
          type: AccountType.asset,
          balance: 0,
        ),
      ),
    );
    return cashAcc.balance;
  }

  double get totalSales {
    final revAcc = accounts.firstWhere(
      (a) => a.accountRole == 'sales_revenue',
      orElse: () => const AccountModel(
        id: '',
        code: '',
        nameAr: '',
        type: AccountType.revenue,
        balance: 0,
      ),
    );
    return revAcc.balance;
  }

  double get totalReceivables => contacts
      .where((c) => c.balance > 0)
      .fold(0.0, (sum, c) => sum + c.balance);

  double get totalPayables => contacts
      .where((c) => c.balance < 0)
      .fold(0.0, (sum, c) => sum + c.balance.abs());
}

/// مدير الحالة المحاسبية (Accounting Notifier)
class AccountingNotifier extends Notifier<AccountingState> {
  AccountingRepository? _repo;

  @override
  AccountingState build() {
    _init();
    return const AccountingState(isLoading: true);
  }

  Future<void> _init() async {
    final localDb = await LocalDatabase.init();
    final prefs = ref.read(sharedPreferencesProvider);
    final apiClient = RemoteApiClient();
    final syncQueue = SyncQueueManager(prefs: prefs, apiClient: apiClient);

    _repo = AccountingRepository(localDb, syncQueue);

    state = AccountingState(
      isLoading: false,
      accounts: _repo!.getAccounts(),
      contacts: _repo!.getContacts(),
      entries: _repo!.getJournalEntries(),
    );

    // مزامنة هادئة في الخلفية عند بدء التشغيل
    syncQueue.synchronize().ignore();
  }

  /// ترحيل عملية جديدة
  Future<JournalEntryModel?> executeOperation({
    required String operationCode,
    required double amount,
    String? contactId,
    String? description,
    DateTime? date,
    EntrySource source = EntrySource.button,
  }) async {
    if (_repo == null) return null;

    final entry = await _repo!.postOperation(
      operationCode: operationCode,
      amount: amount,
      contactId: contactId,
      customDescription: description,
      date: date,
      source: source,
    );

    // تحديث الحالة فوراً للواجهة
    state = state.copyWith(
      accounts: _repo!.getAccounts(),
      contacts: _repo!.getContacts(),
      entries: _repo!.getJournalEntries(),
    );

    return entry;
  }
}

final accountingProvider = NotifierProvider<AccountingNotifier, AccountingState>(
  AccountingNotifier.new,
);
