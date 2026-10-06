import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateContactDto {
  @ApiProperty({ example: 'customer', enum: ['customer', 'supplier', 'both'], description: 'نوع جهة الاتصال' })
  @IsNotEmpty()
  @IsIn(['customer', 'supplier', 'both'])
  type: string;

  @ApiProperty({ example: 'محمود الصالحي', description: 'الاسم الكامل' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: '777123456', description: 'رقم الهاتف' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: 'صنعاء - شارع الزبيري', description: 'العنوان' })
  @IsOptional()
  @IsString()
  address?: string;
}
