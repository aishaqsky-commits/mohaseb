import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class ParseIntentDto {
  @ApiProperty({
    example: 'بعت بضاعة نقداً لمحمد بمبلغ 35000 ريال',
    description: 'النص العربي للعملية باللغة الفصحى أو العامية الدارجة',
  })
  @IsNotEmpty({ message: 'النص المدخل لا يمكن أن يكون فارغاً' })
  @IsString()
  @MaxLength(500, { message: 'طول النص لا يتجاوز 500 حرف' })
  text: string;
}

export class ProposeEntryResponseDto {
  @ApiProperty({ example: 'cash_sale', description: 'كود العملية المحاسبية' })
  operationCode: string;

  @ApiProperty({ example: 'قيد مبيعات نقدية (Cash Sale)', description: 'عنوان القيد المقترح' })
  title: string;

  @ApiProperty({ example: 35000, description: 'المبلغ المستخرج' })
  amount: number;

  @ApiProperty({ example: 'YER', description: 'العملة' })
  currency: string;

  @ApiProperty({ example: 'الصندوق الرئيسي (101)', description: 'الحساب المدين' })
  debitAccount: string;

  @ApiProperty({ example: '101', description: 'كود الحساب المدين' })
  debitAccountCode: string;

  @ApiProperty({ example: 'إيرادات المبيعات (401)', description: 'الحساب الدائن' })
  creditAccount: string;

  @ApiProperty({ example: '401', description: 'كود الحساب الدائن' })
  creditAccountCode: string;

  @ApiProperty({ example: 'مبيعات نقدية للعميل محمد', description: 'بيان العملية' })
  description: string;

  @ApiProperty({ example: 'محمد', description: 'اسم الطرف المستخرج إن وجد', required: false })
  contactName?: string;

  @ApiProperty({ example: 0.95, description: 'درجة الثقة في التحليل (0 - 1)' })
  confidence: number;

  @ApiProperty({ example: true, description: 'يجب تأكيد القيد يدوياً من المحاسب (Human-in-the-Loop)' })
  requiresConfirmation: boolean;
}
