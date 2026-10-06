-- ====================================================================
-- Smart Ledger Accounting System - Central Database Schema (DDL)
-- Compliant with Phase 1/2 Architecture & RLS Multi-Tenancy
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── 1. الجغرافيا والعملات (Lookups) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS currencies (
    code CHAR(3) PRIMARY KEY,
    name_ar VARCHAR(50) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    decimal_places SMALLINT NOT NULL DEFAULT 2
);

INSERT INTO currencies (code, name_ar, symbol, decimal_places) VALUES
('YER', 'ريال يمني', 'ر.ي', 0),
('SAR', 'ريال سعودي', 'ر.س', 2),
('USD', 'دولار أمريكي', '$', 2)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS countries (
    code CHAR(2) PRIMARY KEY,
    name_ar VARCHAR(50) NOT NULL,
    phone_prefix VARCHAR(10) NOT NULL,
    default_currency CHAR(3) REFERENCES currencies(code)
);

INSERT INTO countries (code, name_ar, phone_prefix, default_currency) VALUES
('YE', 'اليمن', '+967', 'YER'),
('SA', 'المملكة العربية السعودية', '+966', 'SAR')
ON CONFLICT (code) DO NOTHING;

-- ─── 2. المنشآت والمستأجرين (Tenants & Companies) ───────────────────
CREATE TABLE IF NOT EXISTS companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    activity_type VARCHAR(30) NOT NULL CHECK (activity_type IN ('retail', 'services', 'mixed')),
    country_code CHAR(2) NOT NULL REFERENCES countries(code),
    base_currency CHAR(3) NOT NULL REFERENCES currencies(code),
    fiscal_year_start SMALLINT NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    settings_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    is_main BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── 3. المستخدمون والجلسات والمصادقة (Users & Auth) ────────────────
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(150),
    role VARCHAR(30) NOT NULL DEFAULT 'owner' CHECK (role IN ('owner', 'accountant', 'sales', 'inventory', 'cashier', 'viewer')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'invited')),
    last_active_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(company_id, phone)
);

CREATE TABLE IF NOT EXISTS otp_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) NOT NULL,
    code_hash TEXT NOT NULL,
    purpose VARCHAR(20) NOT NULL,
    attempts SMALLINT NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── 4. المحرك المحاسبي وشجرة الحسابات (Accounting Engine) ───────────
CREATE TABLE IF NOT EXISTS account_types (
    code VARCHAR(20) PRIMARY KEY,
    name_ar VARCHAR(50) NOT NULL,
    normal_balance VARCHAR(10) NOT NULL CHECK (normal_balance IN ('debit', 'credit'))
);

INSERT INTO account_types (code, name_ar, normal_balance) VALUES
('asset', 'أصول', 'debit'),
('liability', 'خصوم', 'credit'),
('equity', 'حقوق ملكية', 'credit'),
('revenue', 'إيرادات', 'credit'),
('expense', 'مصروفات', 'debit')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name_ar VARCHAR(150) NOT NULL,
    account_type VARCHAR(20) NOT NULL REFERENCES account_types(code),
    parent_id UUID REFERENCES accounts(id),
    account_role VARCHAR(50),
    is_system_generated BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    currency CHAR(3) REFERENCES currencies(code),
    cached_balance NUMERIC(18,4) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(company_id, code)
);

CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('customer', 'supplier', 'both')),
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150),
    address TEXT,
    credit_limit NUMERIC(18,4),
    cached_balance NUMERIC(18,4) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- رؤوس قيود اليومية (Journal Entries Header)
CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    entry_number BIGINT NOT NULL,
    entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
    reference_type VARCHAR(50) NOT NULL,
    reference_id UUID,
    description TEXT NOT NULL,
    source VARCHAR(20) NOT NULL DEFAULT 'button' CHECK (source IN ('manual', 'button', 'ai', 'system')),
    status VARCHAR(20) NOT NULL DEFAULT 'posted' CHECK (status IN ('draft', 'posted', 'reversed')),
    reversal_of UUID REFERENCES journal_entries(id),
    created_by UUID REFERENCES users(id),
    operation_id UUID NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- سطور قيد اليومية (Journal Entry Lines)
CREATE TABLE IF NOT EXISTS journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id),
    debit NUMERIC(18,4) NOT NULL DEFAULT 0 CHECK (debit >= 0),
    credit NUMERIC(18,4) NOT NULL DEFAULT 0 CHECK (credit >= 0),
    contact_id UUID REFERENCES contacts(id),
    memo VARCHAR(255),
    line_order SMALLINT NOT NULL DEFAULT 0,
    CONSTRAINT chk_single_side CHECK (
        (debit > 0 AND credit = 0) OR (credit > 0 AND debit = 0)
    )
);

-- ─── 5. طابور المزامنة السحابية (Offline-First Sync Queue) ───────────
CREATE TABLE IF NOT EXISTS sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    operation_id UUID NOT NULL UNIQUE,
    entity_type VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('create', 'update', 'delete')),
    payload JSONB NOT NULL,
    device_id VARCHAR(100),
    synced_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── 6. الدوال ومحفزات التحقق (Triggers & Functions) ─────────────────
CREATE OR REPLACE FUNCTION fn_validate_journal_balance() RETURNS TRIGGER AS $$
DECLARE
    total_debit NUMERIC(18,4);
    total_credit NUMERIC(18,4);
BEGIN
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0)
    INTO total_debit, total_credit
    FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    IF total_debit <> total_credit THEN
        RAISE EXCEPTION 'Unbalanced Entry: Debit % != Credit %', total_debit, total_credit;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_prevent_posted_edit() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'posted' AND (TG_OP = 'DELETE' OR NEW.status != 'reversed') THEN
        RAISE EXCEPTION 'Cannot edit a posted entry. Use a reversal entry instead (Immutability Enforced).';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_posted_edit ON journal_entries;
CREATE TRIGGER trg_prevent_posted_edit
BEFORE UPDATE OR DELETE ON journal_entries
FOR EACH ROW EXECUTE FUNCTION fn_prevent_posted_edit();

-- ─── 7. عزل المستأجرين (Row-Level Security) ──────────────────────────
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_isolation_accounts ON accounts;
CREATE POLICY tenant_isolation_accounts ON accounts
FOR ALL USING (company_id = NULLIF(current_setting('app.current_tenant', true), '')::UUID);

DROP POLICY IF EXISTS tenant_isolation_contacts ON contacts;
CREATE POLICY tenant_isolation_contacts ON contacts
FOR ALL USING (company_id = NULLIF(current_setting('app.current_tenant', true), '')::UUID);

DROP POLICY IF EXISTS tenant_isolation_journal ON journal_entries;
CREATE POLICY tenant_isolation_journal ON journal_entries
FOR ALL USING (company_id = NULLIF(current_setting('app.current_tenant', true), '')::UUID);

DROP POLICY IF EXISTS tenant_isolation_sync ON sync_queue;
CREATE POLICY tenant_isolation_sync ON sync_queue
FOR ALL USING (company_id = NULLIF(current_setting('app.current_tenant', true), '')::UUID);

-- ─── 8. المنشأة التجريبية الافتراضية ودليل الحسابات (Default Seed) ──────
INSERT INTO companies (id, name, activity_type, country_code, base_currency)
VALUES ('00000000-0000-0000-0000-000000000001', 'مؤسسة النور للتجارة (الافتراضية)', 'retail', 'YE', 'YER')
ON CONFLICT (id) DO NOTHING;

INSERT INTO branches (id, company_id, name, is_main)
VALUES ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'الفرع الرئيسي', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO accounts (id, company_id, code, name_ar, account_type, account_role, is_system_generated) VALUES
('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001', '101', 'الصندوق الرئيسي', 'asset', 'cash', true),
('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001', '102', 'الحساب البنكي', 'asset', 'bank', true),
('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000001', '103', 'العملاء والمدينون', 'asset', 'receivables', true),
('00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000001', '104', 'مخزون البضاعة', 'asset', 'inventory', true),
('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000001', '201', 'الموردون والدائنون', 'liability', 'payables', true),
('00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000001', '301', 'رأس المال', 'equity', 'capital', true),
('00000000-0000-0000-0000-000000000302', '00000000-0000-0000-0000-000000000001', '302', 'مسحوبات المالك الشخصية', 'equity', 'drawings', true),
('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000001', '401', 'إيرادات المبيعات', 'revenue', 'sales_revenue', true),
('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000001', '501', 'تكلفة البضاعة المباعة', 'expense', 'cogs', true),
('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000001', '502', 'مصروفات تشغيلية', 'expense', 'operating_expense', true),
('00000000-0000-0000-0000-000000000503', '00000000-0000-0000-0000-000000000001', '503', 'رواتب وأجور الموظفين', 'expense', 'salaries_expense', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, company_id, name, phone, role, status)
VALUES ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000001', 'التاجر المعتمد', '+967771234567', 'owner', 'active')
ON CONFLICT (id) DO NOTHING;

