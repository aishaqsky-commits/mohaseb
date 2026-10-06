import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import pg from 'pg';
import * as fs from 'fs';
import * as path from 'path';

const { Pool } = pg;

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(DatabaseService.name);
  private pool: pg.Pool;

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    this.pool = new Pool({
      host: this.configService.get<string>('DB_HOST', 'localhost'),
      port: Number(this.configService.get<number>('DB_PORT', 5432)),
      user: this.configService.get<string>('DB_USER', 'postgres'),
      password: this.configService.get<string>('DB_PASSWORD', 'postgres'),
      database: this.configService.get<string>('DB_NAME', 'mohaseb_db'),
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    });

    this.pool.on('error', (err) => {
      this.logger.error('Unexpected error on idle PostgreSQL client', err.stack);
    });

    await this.testConnectionAndMigrate();
  }

  async onModuleDestroy() {
    if (this.pool) {
      await this.pool.end();
      this.logger.log('PostgreSQL connection pool closed');
    }
  }

  private async testConnectionAndMigrate() {
    try {
      const client = await this.pool.connect();
      this.logger.log('✅ Connected to PostgreSQL database successfully');

      try {
        let schemaPath = path.join(__dirname, 'schema.sql');
        if (!fs.existsSync(schemaPath)) {
          schemaPath = path.join(process.cwd(), 'src', 'core', 'database', 'schema.sql');
        }
        if (fs.existsSync(schemaPath)) {
          const sql = fs.readFileSync(schemaPath, 'utf8');
          await client.query(sql);
          this.logger.log('✅ PostgreSQL Schema migrations applied successfully');
        }
      } catch (err: any) {
        this.logger.warn(`Migration notice: ${err.message}`);
      } finally {
        client.release();
      }
    } catch (err: any) {
      this.logger.warn(`PostgreSQL not reachable on initial startup (${err.message}). Application will continue in standalone / mock mode.`);
    }
  }

  /// تنفيذ استعلام عادي
  async query<T = any>(sql: string, params: any[] = []): Promise<pg.QueryResult<T>> {
    return this.pool.query<T>(sql, params);
  }

  /// تنفيذ استعلام تحت سياق مستأجر محدد مع تفعيل Row-Level Security (RLS)
  async withTenant<T>(tenantId: string, callback: (client: pg.PoolClient) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      // تعيين المستأجر الحالي لفرض سياسات الـ RLS على مستوى الـ Session بطريقة آمنة
      await client.query(`SELECT set_config('app.current_tenant', $1, true)`, [tenantId]);

      const result = await callback(client);

      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /// تنفيذ معاملة عامة (Transaction)
  async withTransaction<T>(callback: (client: pg.PoolClient) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}
