import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, IsUUID } from 'class-validator';

export class PostOperationDto {
  @ApiProperty({
    example: 'cash_sale',
    description: 'كود العملية (cash_sale, credit_sale, cash_purchase, credit_purchase, expense, payroll, etc.)',
  })
  @IsNotEmpty()
  @IsString()
  operationCode: string;

  @ApiProperty({ example: 45000, description: 'المبلغ الإجمالي للعملية' })
  @IsNumber()
  @IsPositive({ message: 'المبلغ يجب أن يكون أكبر من الصفر' })
  amount: number;

  @ApiPropertyOptional({ example: '11111111-2222-3333-4444-555555555555', description: 'معرف العميل أو المورد' })
  @IsOptional()
  @IsString()
  contactId?: string;

  @ApiPropertyOptional({ example: 'مبيعات نقدية للعميل محمد', description: 'بيان وملاحظات العملية' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    description: 'معرف فريد للعملية لتفادي التكرار (Idempotency Key / UUID)',
  })
  @IsNotEmpty()
  @IsUUID('4', { message: 'operationId يجب أن يكون بصيغة UUID v4' })
  operationId: string;

  @ApiPropertyOptional({ example: '2026-10-06T10:00:00Z', description: 'تاريخ العملية' })
  @IsOptional()
  @IsString()
  date?: string;
}
