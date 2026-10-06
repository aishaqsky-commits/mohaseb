import { Body, Controller, Get, Post, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SyncService } from './sync.service';
import { SyncPushDto, SyncPullQueryDto } from './dto/sync.dto';
import { CurrentTenant } from '../../core/decorators/current-user.decorator';

@ApiTags('المزامنة السحابية (Offline-First Sync)')
@ApiBearerAuth()
@Controller('api/v1/sync')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('push')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'دفع أحداث العمليات المخزنة محلياً إلى الخادم (Sync Push)' })
  @ApiResponse({ status: 200, description: 'تمت مزامنة الأحداث بنجاح' })
  async push(
    @CurrentTenant() tenantId: string,
    @Body() dto: SyncPushDto,
  ) {
    return this.syncService.processPush(tenantId, dto);
  }

  @Get('pull')
  @ApiOperation({ summary: 'سحب التغييرات والأحداث الجديدة من الخادم السحابي (Sync Pull)' })
  @ApiResponse({ status: 200, description: 'قائمة الأحداث الجديدة' })
  async pull(
    @CurrentTenant() tenantId: string,
    @Query() query: SyncPullQueryDto,
  ) {
    return this.syncService.processPull(tenantId, query.since);
  }
}
