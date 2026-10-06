import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsPhoneNumber, IsString, Length } from 'class-validator';

export class RequestOtpDto {
  @ApiProperty({ example: '+967777123456', description: 'رقم هاتف المستخدم مع رمز الدولة' })
  @IsNotEmpty({ message: 'رقم الهاتف مطلوب' })
  @IsString()
  phone: string;
}

export class VerifyOtpDto {
  @ApiProperty({ example: '+967777123456', description: 'رقم هاتف المستخدم' })
  @IsNotEmpty()
  phone: string;

  @ApiProperty({ example: '1234', description: 'رمز التحقق OTP المكون من 4 أو 6 أرقام' })
  @IsNotEmpty()
  @Length(4, 6, { message: 'رمز التحقق يجب أن يكون بين 4 إلى 6 أرقام' })
  code: string;
}
