class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:3000';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // ─── مسارات المصادقة ──────────────────────────────────────
  static const String requestOtp = '/api/v1/auth/request-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';

  // ─── مسارات المحاسبة ──────────────────────────────────────
  static const String accounts = '/api/v1/accounting/accounts';
  static const String postOperation = '/api/v1/accounting/operations/post';
  static const String journalEntries = '/api/v1/accounting/journal-entries';
  static const String incomeStatement = '/api/v1/accounting/reports/income-statement';
  static const String balanceSheet = '/api/v1/accounting/reports/balance-sheet';

  // ─── مسارات العملاء والموردين ─────────────────────────────
  static const String contacts = '/api/v1/contacts';

  // ─── مسارات المزامنة السحابية ─────────────────────────────
  static const String syncPush = '/api/v1/sync/push';
  static const String syncPull = '/api/v1/sync/pull';

  // ─── الذكاء الاصطناعي ──────────────────────────────────────
  static const String aiParseIntent = '/api/v1/ai/parse-intent';
}
