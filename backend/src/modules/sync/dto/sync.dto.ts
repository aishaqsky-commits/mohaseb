import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsArray, IsIn, IsNotEmpty, IsObject, IsOptional, IsString, IsUUID, ValidateNested } from 'class-validator';

export class SyncEventDto {
  @ApiProperty({ example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', description: 'معرف فريد للعملية لتفادي التكرار (UUID)' })
  @IsNotEmpty()
  @IsUUID('4')
  operationId: string;

  @ApiProperty({ example: 'journal_entry', enum: ['journal_entry', 'contact', 'company_settings'], description: 'نوع الكيان' })
  @IsNotEmpty()
  @IsString()
  entityType: string;

  @ApiProperty({ example: 'create', enum: ['create', 'update', 'delete'], description: 'نوع الإجراء' })
  @IsNotEmpty()
  @IsIn(['create', 'update', 'delete'])
  action: string;

  @ApiProperty({ example: { amount: 35000, operationCode: 'cash_sale' }, description: 'حمولة العملية المحدثة محلياً' })
  @IsNotEmpty()
  @IsObject()
  payload: Record<string, any>;

  @ApiPropertyOptional({ example: 'device_android_9988', description: 'معرف الجهاز المصدر' })
  @IsOptional()
  @IsString()
  deviceId?: string;
}

export class SyncPushDto {
  @ApiProperty({ type: [SyncEventDto], description: 'قائمة الأحداث المخزنة محلياً في طابور sync_queue' })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncEventDto)
  events: SyncEventDto[];
}

export class SyncPullQueryDto {
  @ApiPropertyOptional({ example: '2026-10-06T00:00:00Z', description: 'تاريخ آخر مزامنة ناجحة' })
  @IsOptional()
  @IsString()
  since?: string;
}
