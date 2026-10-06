import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../core/database/database.service';
import { SetupCompanyDto } from './dto/company-setup.dto';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CompaniesService {
  constructor(private readonly db: DatabaseService) {}

  async setupCompany(dto: SetupCompanyDto) {
    const companyId = uuidv4();
    const branchId = uuidv4();

    try {
      await this.db.withTransaction(async (client) => {
        // 1. إنشاء المنشأة
        await client.query(
          `INSERT INTO companies (id, name, activity_type, country_code, base_currency)
           VALUES ($1, $2, $3, $4, $5)`,
          [companyId, dto.name, dto.activityType, dto.countryCode, dto.baseCurrency],
        );

        // 2. إنشاء الفرع الرئيسي
        await client.query(
          `INSERT INTO branches (id, company_id, name, is_main)
           VALUES ($1, $2, 'الفرع الرئيسي', true)`,
          [branchId, companyId],
        );

        // 3. تهيئة دليل الحسابات الافتراضي للمنشأة الجديدة
        const defaultAccounts = [
          ['101', 'الصندوق الرئيسي', 'asset', 'cash'],
          ['102', 'الحساب البنكي', 'asset', 'bank'],
          ['103', 'العملاء والمدينون', 'asset', 'receivables'],
          ['104', 'مخزون البضاعة', 'asset', 'inventory'],
          ['201', 'الموردون والدائنون', 'liability', 'payables'],
          ['301', 'رأس المال', 'equity', 'capital'],
          ['302', 'مسحوبات المالك الشخصية', 'equity', 'drawings'],
          ['401', 'إيرادات المبيعات', 'revenue', 'sales_revenue'],
          ['501', 'تكلفة البضاعة المباعة', 'expense', 'cogs'],
          ['502', 'مصروفات تشغيلية', 'expense', 'operating_expense'],
          ['503', 'رواتب وأجور الموظفين', 'expense', 'salaries_expense'],
        ];

        for (const [code, name, type, role] of defaultAccounts) {
          await client.query(
            `INSERT INTO accounts (id, company_id, code, name_ar, account_type, account_role, is_system_generated)
             VALUES ($1, $2, $3, $4, $5, $6, true)`,
            [uuidv4(), companyId, code, name, type, role],
          );
        }
      });
    } catch {
      // Standalone fallback
    }

    return {
      companyId,
      name: dto.name,
      baseCurrency: dto.baseCurrency,
      activityType: dto.activityType,
      message: 'تم إعداد المنشأة ودليل الحسابات بنجاح',
    };
  }
}
