import { Body, Controller, Get, Param, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ContactsService } from './contacts.service';
import { CreateContactDto } from './dto/contact.dto';
import { CurrentTenant } from '../../core/decorators/current-user.decorator';

@ApiTags('العملاء والموردون (Contacts & Sub-Ledgers)')
@ApiBearerAuth()
@Controller('api/v1/contacts')
export class ContactsController {
  constructor(private readonly contactsService: ContactsService) {}

  @Get()
  @ApiOperation({ summary: 'جلب قائمة العملاء والموردين مع أرصدتهم' })
  @ApiResponse({ status: 200, description: 'قائمة جهات الاتصال' })
  async getContacts(@CurrentTenant() tenantId: string) {
    return this.contactsService.getContacts(tenantId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'إضافة عميل أو مورد جديد' })
  @ApiResponse({ status: 201, description: 'تمت الإضافة بنجاح' })
  async createContact(
    @CurrentTenant() tenantId: string,
    @Body() dto: CreateContactDto,
  ) {
    return this.contactsService.createContact(tenantId, dto);
  }

  @Get(':id/statement')
  @ApiOperation({ summary: 'كشف حساب تفصيلي للعميل أو المورد (Account Statement)' })
  @ApiResponse({ status: 200, description: 'كشف الحساب' })
  async getContactStatement(
    @CurrentTenant() tenantId: string,
    @Param('id') contactId: string,
  ) {
    return this.contactsService.getContactStatement(tenantId, contactId);
  }
}
