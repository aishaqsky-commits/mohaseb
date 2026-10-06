# 🏗️ خطة بناء تطبيق حاسبي الذكي - Flutter Frontend

## المرحلة الحالية: Phase 0 - الأساسيات

### البنية المعمارية
```
d:\MOHASEB\
├── frontend/                    # Flutter App
│   ├── lib/
│   │   ├── core/               # أساسيات المشروع
│   │   │   ├── theme/          # التصميم والألوان
│   │   │   ├── constants/      # الثوابت
│   │   │   ├── utils/          # أدوات مساعدة
│   │   │   ├── extensions/     # إضافات Dart
│   │   │   └── router/         # التنقل (GoRouter)
│   │   ├── data/               # طبقة البيانات
│   │   │   ├── models/         # نماذج البيانات
│   │   │   ├── repositories/   # المستودعات
│   │   │   ├── datasources/    # مصادر البيانات (Local/Remote)
│   │   │   └── database/       # Drift (SQLite)
│   │   ├── features/           # الميزات (Feature-First)
│   │   │   ├── auth/           # المصادقة
│   │   │   ├── onboarding/     # التهيئة الأولى
│   │   │   ├── dashboard/      # لوحة التحكم
│   │   │   ├── operations/     # العمليات المحاسبية
│   │   │   ├── contacts/       # العملاء والموردين
│   │   │   ├── inventory/      # المخزون
│   │   │   ├── reports/        # التقارير
│   │   │   ├── ai_chat/        # المحادثة الذكية
│   │   │   ├── hr/             # الموارد البشرية
│   │   │   └── settings/       # الإعدادات
│   │   ├── shared/             # مكونات مشتركة
│   │   │   ├── widgets/        # عناصر واجهة مشتركة
│   │   │   ├── providers/      # Riverpod Providers
│   │   │   └── l10n/           # الترجمة
│   │   └── main.dart
│   ├── assets/                 # الصور والخطوط
│   ├── test/                   # الاختبارات
│   └── pubspec.yaml
└── backend/                     # (مستقبلاً) NestJS
```

### الحزم المطلوبة (Flutter)

| الحزمة | الغرض |
|--------|--------|
| `flutter_riverpod` + `riverpod_annotation` | إدارة الحالة |
| `go_router` | التنقل الذكي |
| `drift` + `sqlite3_flutter_libs` | قاعدة البيانات المحلية |
| `freezed` + `json_serializable` | نماذج البيانات Immutable |
| `dio` | HTTP Client |
| `flutter_localizations` + `intl` | دعم العربية (RTL) |
| `google_fonts` | خطوط (Cairo/Tajawal) |
| `flutter_svg` | أيقونات SVG |
| `fl_chart` | الرسوم البيانية |
| `uuid` | توليد UUID |
| `path_provider` | مسارات النظام |
| `shared_preferences` | التخزين البسيط |

### ترتيب التنفيذ

1. ✅ إنشاء مشروع Flutter وإعداد الحزم
2. ✅ إعداد البنية المعمارية النظيفة (Feature-First Architecture)
3. ✅ إعداد نظام التصميم (Design System - ألوان، خطوط، ثيمات Dark/Light)
4. ✅ إعداد التنقل الكامل (GoRouter مع ShellRoute)
5. ✅ شاشات التهيئة والمصادقة (Onboarding, Login, OTP, Company Setup)
6. ✅ شاشة لوحة التحكم الحية (Dashboard, Summary Cards, Alerts, Recent Transactions)
7. ✅ شبكة أزرار العمليات السريعة (Quick Actions Grid)
8. ✅ نماذج البيانات المحاسبية (AccountModel, ContactModel, JournalEntryModel, OperationModel)
9. ✅ قاعدة البيانات والتخزين المحلي المحمي (Local Database & Seeding)
10. ✅ محرك الترحيل المحاسبي والقيد المزدوج (Posting Rules Engine مع فحص التوازن الصارم)
11. ✅ شاشات جهات الاتصال والتقارير المالية والذكاء الاصطناعي والإعدادات
12. ✅ اختبارات الوحدة الأوتوماتيكية لمحرك المحاسبة (100% Passed)

## المرحلة التالية: Phase 2 - المزامنة السحابية وبناء واجهات الـ Backend (NestJS + PostgreSQL)

1. [ ] إعداد خادم NestJS مع نمط Modular Monolith
2. [ ] إعداد قاعدة بيانات PostgreSQL 15+ وتطبيق عزل المستأجرين (RLS)
3. [ ] بناء طابور المزامنة `sync_queue` لمزامنة العمليات غير المتزامنة (Event Sourcing / Offline Sync)
4. [ ] دمج AI Gateway المتعدد المزودين (Gemini / Whisper / OpenAI)

> [!IMPORTANT]
> جميع الشاشات تدعم RTL والعربية بنسبة 100%
> التحقق الرياضي من توازن القيد (Debit == Credit) مفعل ومختبر أوتوماتيكياً

