import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../models/contact_model.dart';
import '../models/journal_entry_model.dart';

class LocalDatabase {
  static const _kAccountsKey = 'local_db_accounts_v1';
  static const _kContactsKey = 'local_db_contacts_v1';
  static const _kJournalKey = 'local_db_journal_v1';

  final SharedPreferences _prefs;

  LocalDatabase(this._prefs);

  static Future<LocalDatabase> init() async {
    final prefs = await SharedPreferences.getInstance();
    final db = LocalDatabase(prefs);
    await db._seedIfEmpty();
    return db;
  }

  Future<void> _seedIfEmpty() async {
    // 1. تهيئة دليل الحسابات الافتراضي إذا لم يكن موجوداً
    if (!_prefs.containsKey(_kAccountsKey)) {
      final defaultAccounts = AccountModel.defaultChartOfAccounts;
      await saveAccounts(defaultAccounts);
    }

    // 2. تهيئة جهات الاتصال الافتراضية
    if (!_prefs.containsKey(_kContactsKey)) {
      final defaultContacts = [
        ContactModel(
          id: 'con_1',
          name: 'محمود الصالحي',
          phone: '777123456',
          type: ContactType.customer,
          balance: 145000.0,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ContactModel(
          id: 'con_2',
          name: 'شركة الأمل للتوريدات',
          phone: '771987654',
          type: ContactType.supplier,
          balance: -320000.0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        ContactModel(
          id: 'con_3',
          name: 'سوبرماركت البركة',
          phone: '773445566',
          type: ContactType.customer,
          balance: 85000.0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      await saveContacts(defaultContacts);
    }
  }

  // ─── الحسابات ──────────────────────────────────────────────
  List<AccountModel> getAccounts() {
    final raw = _prefs.getString(_kAccountsKey);
    if (raw == null) return AccountModel.defaultChartOfAccounts;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return AccountModel.defaultChartOfAccounts;
    }
  }

  Future<void> saveAccounts(List<AccountModel> accounts) async {
    final data = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _prefs.setString(_kAccountsKey, data);
  }

  // ─── جهات الاتصال ──────────────────────────────────────────
  List<ContactModel> getContacts() {
    final raw = _prefs.getString(_kContactsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ContactModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveContacts(List<ContactModel> contacts) async {
    final data = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await _prefs.setString(_kContactsKey, data);
  }

  // ─── قيود اليومية ──────────────────────────────────────────
  List<JournalEntryModel> getJournalEntries() {
    final raw = _prefs.getString(_kJournalKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => JournalEntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveJournalEntries(List<JournalEntryModel> entries) async {
    final data = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_kJournalKey, data);
  }
}
