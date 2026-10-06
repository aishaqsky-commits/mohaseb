# حاسبي الذكي - Smart Ledger Accounting System 📊

> نظام محاسبي متكامل ومزدوج القيد (Double-Entry Accounting System) مبني بتقنيات حديثة لتجار التجزئة، الجملة، ومقدمي الخدمات، مع دعم العمل دون اتصال بالإنترنت (Offline-First) والذكاء الاصطناعي التوليدي تحت إشراف المحاسب (Human-in-the-Loop).

---

## 🌟 المعمارية التقنية للمشروع (Architecture Overview)

```
MOHASEB-NEW02/
├── backend/                  # NestJS Modular Monolith + PostgreSQL
│   ├── src/
│   │   ├── core/            # Database Pool, RLS Policies, Exceptions, Interceptors
│   │   └── modules/
│   │       ├── auth/        # OTP Authentication & JWT
│   │       ├── companies/   # Multi-Tenant Setup & Automated Chart of Accounts
│   │       ├── accounting/  # Posting Rules Engine, Balance Constraints, Reports
│   │       ├── contacts/    # Customers, Suppliers, & Account Statements
│   │       ├── sync/        # Push/Pull Delta Event-Sourcing Sync Engine
│   │       └── ai/          # Arabic NLP Accounting Intent Parser & Proposals
│   └── src/core/database/schema.sql  # Central DDL, RLS & Immutability Triggers
│
└── frontend/                 # Flutter 3.x + Riverpod 3.x (Clean Feature-First)
    ├── lib/
    │   ├── core/            # Design System (Colors, Typography, Zero-Flash Themes, Router)
    │   ├── data/            # Local SQLite Database, Remote API Client, Sync Queue Manager
    │   └── features/
    │       ├── onboarding/  # First-run & Company Setup
    │       ├── auth/        # Phone OTP Verification
    │       ├── dashboard/   # Live Summary Cards, Alerts, Quick Actions
    │       ├── operations/  # Double-Entry Operations & Thermal Receipts (80mm/58mm)
    │       ├── contacts/    # Customer & Supplier Ledgers
    │       ├── reports/     # Income Statement, Balance Sheet, Cash Flow
    │       └── ai_chat/     # Smart AI Accounting Assistant with Confirmation Guard
    └── test/                # Comprehensive Automated Unit & Integration Tests
```

---

## 🚀 المميزات الرئيسية (Core Features)

1. **قيد محاسبي مزدوج إلزامي (Strict Double-Entry Bookkeeping)**:
   - لا يمكن ترحيل أي قيد غير متوازن ($\sum \text{Debit} == \sum \text{Credit}$).
   - عدم قابلية القيود المرحلة للتعديل أو الحذف (Immutability Enforced).

2. **العمل دون اتصال بالإنترنت (Offline-First & Local-First)**:
   - حفظ فوري لكافة المعاملات في قاعدة البيانات المحلية.
   - طابور مزامنة ذكي مع معالجة غير متزامنة (`SyncQueueManager`).
   - مفاتيح تكرار آمنة (UUID Idempotency Keys).

3. **عزل المستأجرين بقوة (PostgreSQL Row-Level Security)**:
   - تطبيق RLS على مستوى الـ Session بواسطة `set_config('app.current_tenant', $1, true)`.

4. **مساعد محاسبي بالذكاء الاصطناعي (AI Accounting Assistant)**:
   - تحليل النصوص والتسجيلات بالعامية والفصحى (استخراج المبالغ، الحسابات، الأطراف).
   - مبدأ **Human-in-the-Loop**: لا يتم ترحيل أي مقترح إلا بعد موافقة وتأكيد المستخدم.

5. **طباعة إيصالات حرارية وفواتير ضريبية (Thermal Printing & Invoicing)**:
   - محاكاة دقيقة للطابعات الحرارية بعرض **80 مم** و **58 مم**.
   - باركود، ختم التوازن المحاسبي، وتصدير ومشاركة PDF.

6. **ثيمات مريحة وتوافق كامل مع العربية (Native Arabic & RTL)**:
   - دعم الوضع الفاتح والداكن بانتقال فوري بدون وميض (Zero UI Flash).

---

## 🛠️ متطلبات التشغيل (Prerequisites)

- **Node.js**: v18+ (تم الاختبار على v24.x)
- **PostgreSQL**: v15+ (تم الاختبار على v17.x)
- **Flutter SDK**: v3.x
- **Git**

---

## ⚡ البدء السريع (Quick Start)

### 1. تشغيل الخادم السحابي (Backend)
```bash
cd backend
npm install
npm run build
npm run start:dev
```
- وثائق Swagger التفاعلية: [http://localhost:3000/api/docs](http://localhost:3000/api/docs)

### 2. تشغيل تطبيق الهاتف / الويب (Frontend)
```bash
cd frontend
flutter pub get
flutter test
flutter run
```

---

## 🧪 الاختبارات الآلية (Testing)

- **اختبارات تطبيق الفلاتر**:
  ```bash
  cd frontend
  flutter test
  ```
  *(13/13 اختبار ناجح تغطي محرك القيود، توازن الحسابات، ثيمات الإقلاع، وطابور المزامنة).*

- **فحص الكود البرمجي (Linter)**:
  ```bash
  flutter analyze
  ```
  *(0 أخطاء و 0 تحذيرات).*

---

## 📄 الترخيص (License)
هذا المشروع مرخص تحت رخصة MIT.
