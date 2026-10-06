import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class RemoteApiClient {
  final Dio _dio;
  String? _authToken;

  RemoteApiClient({String? baseUrl, Dio? customDio})
      : _dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          debugPrint('API Error: [${error.response?.statusCode}] ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  // ─── المصادقة ──────────────────────────────────────────────
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final res = await _dio.post(ApiConstants.requestOtp, data: {'phone': phone});
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await _dio.post(ApiConstants.verifyOtp, data: {'phone': phone, 'code': code});
    final data = (res.data['data'] as Map<String, dynamic>?) ?? {};
    if (data['accessToken'] != null) {
      setAuthToken(data['accessToken'] as String);
    }
    return data;
  }

  // ─── المحاسبة ──────────────────────────────────────────────
  Future<List<dynamic>> getAccounts() async {
    final res = await _dio.get(ApiConstants.accounts);
    return (res.data['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> postOperation({
    required String operationCode,
    required double amount,
    String? contactId,
    String? description,
    required String operationId,
  }) async {
    final res = await _dio.post(
      ApiConstants.postOperation,
      data: {
        'operationCode': operationCode,
        'amount': amount,
        'contactId': contactId,
        'description': description,
        'operationId': operationId,
      },
    );
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<List<dynamic>> getJournalEntries() async {
    final res = await _dio.get(ApiConstants.journalEntries);
    return (res.data['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> getIncomeStatement() async {
    final res = await _dio.get(ApiConstants.incomeStatement);
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getBalanceSheet() async {
    final res = await _dio.get(ApiConstants.balanceSheet);
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  // ─── العملاء والموردون ─────────────────────────────────────
  Future<List<dynamic>> getContacts() async {
    final res = await _dio.get(ApiConstants.contacts);
    return (res.data['data'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> createContact({
    required String name,
    required String type,
    String? phone,
    String? address,
  }) async {
    final res = await _dio.post(
      ApiConstants.contacts,
      data: {'name': name, 'type': type, 'phone': phone, 'address': address},
    );
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  // ─── المزامنة السحابية ─────────────────────────────────────
  Future<Map<String, dynamic>> pushSync(List<Map<String, dynamic>> events) async {
    final res = await _dio.post(ApiConstants.syncPush, data: {'events': events});
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> pullSync({String? since}) async {
    final res = await _dio.get(
      ApiConstants.syncPull,
      queryParameters: since != null ? {'since': since} : null,
    );
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }

  // ─── مساعد الذكاء الاصطناعي ──────────────────────────────
  Future<Map<String, dynamic>> parseAiIntent(String text) async {
    final res = await _dio.post(ApiConstants.aiParseIntent, data: {'text': text});
    return (res.data['data'] as Map<String, dynamic>?) ?? {};
  }
}
