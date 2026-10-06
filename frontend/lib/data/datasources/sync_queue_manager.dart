import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remote_api_client.dart';

enum SyncState { idle, syncing, offline, error }

class SyncQueueManager {
  static const _kQueueKey = 'mohaseb_offline_sync_queue_v1';
  static const _kLastSyncKey = 'mohaseb_last_sync_timestamp_v1';

  final SharedPreferences _prefs;
  final RemoteApiClient _apiClient;
  final Connectivity _connectivity;

  SyncQueueManager({
    required this._prefs,
    required this._apiClient,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  /// إضافة حدث إلى طابور المزامنة المحلي
  Future<void> enqueueEvent({
    required String operationId,
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final queue = getPendingEvents();
    queue.add({
      'operationId': operationId,
      'entityType': entityType,
      'action': action,
      'payload': payload,
      'clientTimestamp': DateTime.now().toIso8601String(),
    });

    await _saveQueue(queue);
  }

  /// قراءة الأحداث المعلقة في الطابور
  List<Map<String, dynamic>> getPendingEvents() {
    final raw = _prefs.getString(_kQueueKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  int get pendingCount => getPendingEvents().length;

  /// تنفيذ دورة المزامنة السحابية (Push & Pull)
  Future<bool> synchronize() async {
    // 1. التحقق من اتصال الإنترنت
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('⚠️ الجهاز غير متصل بالإنترنت: سيتم إرجاء المزامنة');
      return false;
    }

    final pending = getPendingEvents();

    try {
      // 2. دفع العمليات المعلقة (Push)
      if (pending.isNotEmpty) {
        final pushResult = await _apiClient.pushSync(pending);
        final syncedIds = List<String>.from(pushResult['syncedOperationIds'] ?? []);

        if (syncedIds.isNotEmpty) {
          final remaining = pending
              .where((item) => !syncedIds.contains(item['operationId']))
              .toList();
          await _saveQueue(remaining);
          debugPrint('✅ تمت مزامنة ${syncedIds.length} عملية بنجاح مع السحابة');
        }
      }

      // 3. سحب التحديثات الجديدة من السحابة (Pull)
      final lastSync = _prefs.getString(_kLastSyncKey);
      final pullResult = await _apiClient.pullSync(since: lastSync);
      if (pullResult['latestServerTime'] != null) {
        await _prefs.setString(_kLastSyncKey, pullResult['latestServerTime'] as String);
      }

      return true;
    } catch (e) {
      debugPrint('❌ تعذر استكمال المزامنة السحابية: $e');
      return false;
    }
  }

  Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    await _prefs.setString(_kQueueKey, jsonEncode(queue));
  }
}
