import { Body, Controller, Get, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AccountingService } from './accounting.service';
import { PostOperationDto } from './dto/accounting.dto';
import { CurrentTenant, CurrentUser } from '../../core/decorators/current-user.decorator';

@ApiTags('المحاسبة والقيود (Accounting & Ledger)')
@ApiBearerAuth()
@Controller('api/v1/accounting')
export class AccountingController {
  constructor(private readonly accountingService: AccountingService) {}

  @Get('accounts')
  @ApiOperation({ summary: 'جلب دليل الحسابات وأرصدة المنشأة (Chart of Accounts)' })
  @ApiResponse({ status: 200, description: 'قائمة الحسابات' })
  async getAccounts(@CurrentTenant() tenantId: string) {
    return this.accountingService.getAccounts(tenantId);
  }

  @Post('operations/post')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'ترحيل عملية سريعة وتوليد قيد مزدوج متوازن (Post Operation)' })
  @ApiResponse({ status: 201, description: 'تم ترحيل القيد بنجاح' })
  async postOperation(
    @CurrentTenant() tenantId: string,
    @CurrentUser('userId') userId: string,
    @Body() dto: PostOperationDto,
  ) {
    return this.accountingService.postOperation(tenantId, dto, userId);
  }

  @Get('journal-entries')
  @ApiOperation({ summary: 'جلب سجل قيود اليومية للدفاتر المحاسبية (Journal Entries)' })
  @ApiResponse({ status: 200, description: 'سجل القيود' })
  async getJournalEntries(@CurrentTenant() tenantId: string) {
    return this.accountingService.getJournalEntries(tenantId);
  }

  @Get('reports/income-statement')
  @ApiOperation({ summary: 'تقرير قائمة الدخل والأرباح والخسائر (Income Statement)' })
  @ApiResponse({ status: 200, description: 'بيانات قائمة الدخل' })
  async getIncomeStatement(@CurrentTenant() tenantId: string) {
    return this.accountingService.getIncomeStatement(tenantId);
  }

  @Get('reports/balance-sheet')
  @ApiOperation({ summary: 'تقرير المركز المالي / الميزانية العمومية (Balance Sheet)' })
  @ApiResponse({ status: 200, description: 'بيانات الميزانية العمومية' })
  async getBalanceSheet(@CurrentTenant() tenantId: string) {
    return this.accountingService.getBalanceSheet(tenantId);
  }
}
