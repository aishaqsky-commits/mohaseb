import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface UserPayload {
  userId: string;
  companyId: string;
  role: string;
  phone: string;
}

export const CurrentUser = createParamDecorator(
  (data: keyof UserPayload | undefined, ctx: ExecutionContext): UserPayload | any => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user || {
      userId: '11111111-1111-1111-1111-111111111111',
      companyId: '00000000-0000-0000-0000-000000000001',
      role: 'owner',
      phone: '+967777123456',
    };

    return data ? user[data] : user;
  },
);

export const CurrentTenant = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest();
    return request.user?.companyId || '00000000-0000-0000-0000-000000000001';
  },
);
