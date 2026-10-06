import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ParseIntentDto, ProposeEntryResponseDto } from './dto/ai-intent.dto';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(private readonly configService: ConfigService) {}

  /// معالجة النص واستخراج القيد المحاسبي المزدوج المقترح
  async parseIntent(dto: ParseIntentDto): Promise<ProposeEntryResponseDto> {
    const text = dto.text.trim();

    // 1. استخراج المبلغ من النص (أرقام أو كلمات)
    const amount = this.extractAmount(text) || 10000;

    // 2. استخراج الطرف / جهة الاتصال
    const contactName = this.extractContactName(text);

    // 3. تحليل نوع العملية وبناء القيد المزدوج المتوازن
    const proposal = this.classifyOperation(text, amount, contactName);

    return proposal;
  }

  /// استخراج المبلغ المالي بالأرقام
  private extractAmount(text: string): number | null {
    // إزالة الفواصل بين الأرقام مثل 50,000 أو 50،000
    const normalized = text.replace(/,/g, '').replace(/،/g, '');

    // البحث عن أرقام إنجليزية أو هندية/عربية
    const match = normalized.match(/(\d+(\.\d+)?)/);
    if (match) {
      let num = parseFloat(match[1]);
      // إذا كان بعد الرقم كلمة "ألف" نضرب في 1000
      if (/(\d+)\s*(ألف|الف)/.test(normalized)) {
        num = num * 1000;
      } else if (/(\d+)\s*(مليون)/.test(normalized)) {
        num = num * 1000000;
      }
      return num;
    }

    // التعرف على كلمات الأعداد الشائعة
    if (/خمسين ألف|50 الف/.test(text)) return 50000;
    if (/مائة ألف|مية ألف|100 الف/.test(text)) return 100000;
    if (/عشرين ألف|20 الف/.test(text)) return 20000;
    if (/ثلاثين ألف|30 الف/.test(text)) return 30000;
    if (/ألفين|2000/.test(text)) return 2000;
    if (/ألف|1000/.test(text)) return 1000;

    return null;
  }

  /// استخراج اسم العميل أو المورد من النص
  private extractContactName(text: string): string | undefined {
    // أنماط مثل: للزبون [اسم], للمورد [اسم], من العميل [اسم], لـ [اسم]
    const patterns = [
      /(?:للعميل|للزبون|لـ|من العميل|من الزبون|للمورد|من المورد|للشركة|لمؤسسة)\s+([\u0621-\u064A\w]+(?:\s+[\u0621-\u064A\w]+)?)/,
      /(?:باسم|حساب)\s+([\u0621-\u064A\w]+(?:\s+[\u0621-\u064A\w]+)?)/,
    ];

    for (const pat of patterns) {
      const match = text.match(pat);
      if (match && match[1]) {
        return match[1].trim();
      }
    }
    return undefined;
  }

  /// تصنيف العملية واقتراح طرفي القيد المزدوج المتوازن
  private classifyOperation(
    text: string,
    amount: number,
    contactName?: string,
  ): ProposeEntryResponseDto {
    const t = text.toLowerCase();

    // ─── 1. المصروفات التشغيلية ───────────────────────────
    if (
      t.includes('إيجار') ||
      t.includes('ايجار') ||
      t.includes('كهرباء') ||
      t.includes('ماء') ||
      t.includes('نت') ||
      t.includes('إنترنت') ||
      t.includes('بنزين') ||
      t.includes('بترول') ||
      t.includes('مصروف') ||
      t.includes('ضيافة') ||
      t.includes('صيانة')
    ) {
      const isBank = t.includes('بنك') || t.includes('تحويل') || t.includes('شيك') || t.includes('كريمي');
      return {
        operationCode: 'expense',
        title: 'قيد مصروفات تشغيلية (Operating Expense)',
        amount,
        currency: 'YER',
        debitAccount: 'مصروفات تشغيلية (502)',
        debitAccountCode: '502',
        creditAccount: isBank ? 'الحساب البنكي (102)' : 'الصندوق الرئيسي (101)',
        creditAccountCode: isBank ? '102' : '101',
        description: `سداد مصروف تشغيلي (${text})`,
        contactName,
        confidence: 0.95,
        requiresConfirmation: true, // Human-in-the-Loop
      };
    }

    // ─── 2. الرواتب والأجور ──────────────────────────────
    if (t.includes('راتب') || t.includes('رواتب') || t.includes('أجور') || t.includes('سلفة')) {
      return {
        operationCode: 'payroll',
        title: 'قيد صرف رواتب وأجور (Payroll)',
        amount,
        currency: 'YER',
        debitAccount: 'رواتب وأجور الموظفين (503)',
        debitAccountCode: '503',
        creditAccount: 'الصندوق الرئيسي (101)',
        creditAccountCode: '101',
        description: `صرف رواتب موظفين ${contactName ? `لـ ${contactName}` : ''}`,
        contactName,
        confidence: 0.94,
        requiresConfirmation: true,
      };
    }

    // ─── 3. سداد الموردين أو تحصيل من العملاء ────────────
    if (t.includes('سددت للمورد') || t.includes('دفعت للمورد') || t.includes('سداد مورد')) {
      return {
        operationCode: 'supplier_payment',
        title: 'سند صرف وسداد مورد (Supplier Payment)',
        amount,
        currency: 'YER',
        debitAccount: 'الموردون والدائنون (201)',
        debitAccountCode: '201',
        creditAccount: 'الصندوق الرئيسي (101)',
        creditAccountCode: '101',
        description: `سداد دفعة للمورد ${contactName || 'المعتمد'}`,
        contactName,
        confidence: 0.92,
        requiresConfirmation: true,
      };
    }

    if (
      t.includes('قبضت من') ||
      t.includes('استلمت من') ||
      t.includes('تحصيل من') ||
      t.includes('سدد لي') ||
      t.includes('دفعة من')
    ) {
      return {
        operationCode: 'customer_collection',
        title: 'سند قبض وتحصيل عميل (Customer Collection)',
        amount,
        currency: 'YER',
        debitAccount: 'الصندوق الرئيسي (101)',
        debitAccountCode: '101',
        creditAccount: 'العملاء والمدينون (103)',
        creditAccountCode: '103',
        description: `تحصيل دفعة نقدية من العميل ${contactName || ''}`,
        contactName,
        confidence: 0.93,
        requiresConfirmation: true,
      };
    }

    // ─── 4. المشتريات (نقدية أو آجلة) ───────────────────
    if (t.includes('اشتريت') || t.includes('شراء') || t.includes('شرينا') || t.includes('فاتورة مشتريات')) {
      const isCredit = t.includes('آجل') || t.includes('اجل') || t.includes('دين') || t.includes('على الحساب');
      return {
        operationCode: isCredit ? 'credit_purchase' : 'cash_purchase',
        title: isCredit
          ? 'فاتورة مشتريات آجلة (Credit Purchase)'
          : 'فاتورة مشتريات نقدية (Cash Purchase)',
        amount,
        currency: 'YER',
        debitAccount: 'مخزون البضاعة (104)',
        debitAccountCode: '104',
        creditAccount: isCredit ? 'الموردون والدائنون (201)' : 'الصندوق الرئيسي (101)',
        creditAccountCode: isCredit ? '201' : '101',
        description: `مشتريات بضاعة ${isCredit ? 'آجلة' : 'نقدية'} ${contactName ? `من ${contactName}` : ''}`,
        contactName,
        confidence: 0.96,
        requiresConfirmation: true,
      };
    }

    // ─── 5. المبيعات (نقدية أو آجلة) - الافتراضي ─────────
    const isCreditSale =
      t.includes('آجل') || t.includes('اجل') || t.includes('دين') || t.includes('على الحساب') || t.includes('ذمة');

    return {
      operationCode: isCreditSale ? 'credit_sale' : 'cash_sale',
      title: isCreditSale
        ? 'فاتورة مبيعات آجلة (Credit Sale)'
        : 'فاتورة مبيعات نقدية (Cash Sale)',
      amount,
      currency: 'YER',
      debitAccount: isCreditSale ? 'العملاء والمدينون (103)' : 'الصندوق الرئيسي (101)',
      debitAccountCode: isCreditSale ? '103' : '101',
      creditAccount: 'إيرادات المبيعات (401)',
      creditAccountCode: '401',
      description: `مبيعات ${isCreditSale ? 'آجلة' : 'نقدية'} ${contactName ? `للعميل ${contactName}` : ''}`,
      contactName,
      confidence: 0.95,
      requiresConfirmation: true,
    };
  }
}
