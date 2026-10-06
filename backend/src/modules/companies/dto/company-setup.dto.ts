import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export class SetupCompanyDto {
  @ApiProperty({ example: 'مؤسسة النور للإلكترونيات', description: 'اسم المنشأة أو المحل' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ example: 'retail', enum: ['retail', 'services', 'mixed'], description: 'نوع النشاط التجاري' })
  @IsNotEmpty()
  @IsIn(['retail', 'services', 'mixed'])
  activityType: string;

  @ApiProperty({ example: 'YE', description: 'رمز الدولة (YE, SA)' })
  @IsNotEmpty()
  @IsString()
  countryCode: string;

  @ApiProperty({ example: 'YER', description: 'العملة الأساسية (YER, SAR, USD)' })
  @IsNotEmpty()
  @IsString()
  baseCurrency: string;
}
