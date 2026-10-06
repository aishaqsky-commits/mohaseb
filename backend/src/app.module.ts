import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './core/database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { CompaniesModule } from './modules/companies/companies.module';
import { AccountingModule } from './modules/accounting/accounting.module';
import { ContactsModule } from './modules/contacts/contacts.module';
import { SyncModule } from './modules/sync/sync.module';
import { AiModule } from './modules/ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.example'],
    }),
    DatabaseModule,
    AuthModule,
    CompaniesModule,
    AccountingModule,
    ContactsModule,
    SyncModule,
    AiModule,
  ],
})
export class AppModule {}
