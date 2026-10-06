import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { TransformInterceptor } from './core/interceptors/transform.interceptor';
import { AllExceptionsFilter } from './core/filters/http-exception.filter';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  // ─── 1. تفعيل CORS لكافة تطبيقات الويب والموبايل ─────────────
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  // ─── 2. الحماية والتحقق من صحة المدخلات (Validation) ────────
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: true,
    }),
  );

  // ─── 3. الفلاتر والمحولات القياسية (Global Interceptors) ──────
  app.useGlobalInterceptors(new TransformInterceptor());
  app.useGlobalFilters(new AllExceptionsFilter());

  // ─── 4. توثيق الـ API عبر Swagger / OpenAPI (API-First) ─────
  const config = new DocumentBuilder()
    .setTitle('حاسبي الذكي - Smart Ledger Accounting Backend')
    .setDescription(
      'الخلفية السحابية لنظام المحاسبة الذكي لتجار السلع والخدمات مع دعم المزامنة غير المتصلة و RLS Multi-Tenancy',
    )
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'أدخل رمز JWT للدخول',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('المصادقة وتسجيل الدخول (Auth)')
    .addTag('إدارة المنشآت والشركات (Companies & Tenants)')
    .addTag('المحاسبة والقيود (Accounting & Ledger)')
    .addTag('العملاء والموردون (Contacts & Sub-Ledgers)')
    .addTag('المزامنة السحابية (Offline-First Sync)')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'وثائق API - حاسبي الذكي',
  });

  // ─── 5. تشغيل الخادم ────────────────────────────────────────
  const port = process.env.PORT || 3000;
  await app.listen(port);

  logger.log(`🚀 الخادم يعمل بنجاح على: http://localhost:${port}`);
  logger.log(`📚 وثائق الـ API التفاعلية متاحة على: http://localhost:${port}/api/docs`);
}

bootstrap();
