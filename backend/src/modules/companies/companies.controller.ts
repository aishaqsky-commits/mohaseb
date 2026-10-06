import { Body, Controller, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CompaniesService } from './companies.service';
import { SetupCompanyDto } from './dto/company-setup.dto';

@ApiTags('إدارة المنشآت والشركات (Companies & Tenants)')
@Controller('api/v1/companies')
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post('setup')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'تهيئة منشأة جديدة وتوليد دليل الحسابات الافتراضي لها' })
  @ApiResponse({ status: 201, description: 'تمت تهيئة المنشأة بنجاح' })
  async setupCompany(@Body() dto: SetupCompanyDto) {
    return this.companiesService.setupCompany(dto);
  }
}
