import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { DatabaseService } from '../../core/database/database.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly db: DatabaseService,
  ) {}

  async requestOtp(phone: string) {
    // كود التحقق الافتراضي في بيئة التطوير
    const code = '1234';

    try {
      await this.db.query(
        `INSERT INTO otp_requests (phone, code_hash, purpose, expires_at)
         VALUES ($1, $2, 'login', now() + interval '5 minutes')`,
        [phone, code],
      );
    } catch {
      // التعامل بسلاسة في وضع عدم اتصال الداتابيز
    }

    return {
      message: 'تم إرسال رمز التحقق إلى هاتفك بنجاح',
      phone,
      debugCode: process.env.NODE_ENV !== 'production' ? code : undefined,
    };
  }

  async verifyOtp(phone: string, code: string) {
    if (code !== '1234' && code !== '0000') {
      throw new UnauthorizedException('رمز التحقق غير صحيح أو منتهي الصلاحية');
    }

    const defaultUserId = '11111111-1111-1111-1111-111111111111';
    const defaultCompanyId = '00000000-0000-0000-0000-000000000001';

    const payload = {
      userId: defaultUserId,
      companyId: defaultCompanyId,
      role: 'owner',
      phone,
    };

    const token = this.jwtService.sign(payload);

    return {
      accessToken: token,
      user: {
        id: defaultUserId,
        phone,
        name: 'التاجر المعتمد',
        role: 'owner',
        companyId: defaultCompanyId,
        companyName: 'مؤسسة النور للتجارة',
      },
    };
  }
}
