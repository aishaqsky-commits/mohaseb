import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../core/database/database.service';
import { AccountingService } from '../accounting/accounting.service';
import { SyncPushDto } from './dto/sync.dto';

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(
    private readonly db: DatabaseService,
    private readonly accountingService: AccountingService,
  ) {}

  /// معالجة ودفع أحداث التزامن من الجهاز إلى الخادم السحابي
  async processPush(tenantId: string, dto: SyncPushDto) {
    const syncedIds: string[] = [];
    const errors: { operationId: string; message: string }[] = [];

    for (const event of dto.events) {
      try {
        await this.db.withTenant(tenantId, async (client) => {
          // 1. تسجيل الحدث في طابور sync_queue السحابي
          await client.query(
            `INSERT INTO sync_queue (company_id, operation_id, entity_type, action, payload, device_id)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (operation_id) DO NOTHING`,
            [
              tenantId,
              event.operationId,
              event.entityType,
              event.action,
              JSON.stringify(event.payload),
              event.deviceId || null,
            ],
          );
        });

        // 2. إذا كان الحدث قيداً محاسبياً، نقوم بتسجيله في الدفاتر
        if (event.entityType === 'journal_entry' && event.action === 'create') {
          await this.accountingService.postOperation(tenantId, {
            operationCode: event.payload.operationCode || 'cash_sale',
            amount: Number(event.payload.amount || 0),
            contactId: event.payload.contactId,
            description: event.payload.description,
            operationId: event.operationId,
            date: event.payload.date,
          });
        }

        syncedIds.push(event.operationId);
      } catch (err: any) {
        this.logger.error(`Sync error on event ${event.operationId}: ${err.message}`);
        errors.push({ operationId: event.operationId, message: err.message });
      }
    }

    return {
      successCount: syncedIds.length,
      syncedOperationIds: syncedIds,
      errors: errors.length > 0 ? errors : undefined,
      serverTime: new Date().toISOString(),
    };
  }

  /// سحب التحديثات الجديدة من الخادم إلى تطبيق التاجر
  async processPull(tenantId: string, since?: string) {
    try {
      const res = await this.db.withTenant(tenantId, async (client) => {
        return client.query(
          `SELECT operation_id, entity_type, action, payload, synced_at
           FROM sync_queue
           WHERE company_id = $1 AND ($2::TIMESTAMPTZ IS NULL OR synced_at > $2::TIMESTAMPTZ)
           ORDER BY synced_at ASC
           LIMIT 500`,
          [tenantId, since || null],
        );
      });

      return {
        deltaEvents: res.rows,
        latestServerTime: new Date().toISOString(),
      };
    } catch {
      return {
        deltaEvents: [],
        latestServerTime: new Date().toISOString(),
      };
    }
  }
}
