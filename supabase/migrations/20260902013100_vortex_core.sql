-- VORTEX — core relacional multiempresa/multiunidade
-- Estrutura nova. Nenhum INSERT de dados da planilha legada é executado.

create extension if not exists pgcrypto;

create type public.vtx_user_status as enum ('ACTIVE','BLOCKED','INACTIVE');
create type public.vtx_terminal_status as enum ('ACTIVE','INACTIVE','OFFLINE');
create type public.vtx_cash_status as enum ('OPEN','CLOSED');
create type public.vtx_table_status as enum ('AVAILABLE','OCCUPIED','RESERVED','DISABLED');
create type public.vtx_tab_status as enum ('OPEN','CLOSING','CLOSED','CANCELLED');
create type public.vtx_order_status as enum ('DRAFT','SENT','IN_PREPARATION','READY','DELIVERED','CANCELLED');
create type public.vtx_order_item_status as enum ('ACTIVE','CANCEL_REQUESTED','CANCELLED','PREPARING','READY','DELIVERED');
create type public.vtx_payment_status as enum ('PENDING','WAITING_CARD','APPROVED','DECLINED','CANCELLED','REFUNDED','ERROR');
create type public.vtx_payment_method as enum ('CASH','PIX','DEBIT','CREDIT','VOUCHER','OTHER');
create type public.vtx_fiscal_status as enum ('PENDING','AUTHORIZED','REJECTED','CANCELLED','CONTINGENCY','ERROR');
create type public.vtx_device_status as enum ('ACTIVE','INACTIVE','OFFLINE','BUSY','ERROR');

create table public.vtx_organizations (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  legal_name text,
  trade_name text not null,
  document text,
  email text,
  phone text,
  timezone text not null default 'America/Sao_Paulo',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vtx_units (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  code text not null,
  name text not null,
  document text,
  email text,
  phone text,
  address jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table public.vtx_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  default_unit_id uuid references public.vtx_units(id) on delete set null,
  employee_code text,
  full_name text not null,
  cpf text,
  phone text,
  status public.vtx_user_status not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, cpf)
);

create table public.vtx_roles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.vtx_organizations(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  is_system boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table public.vtx_permissions (
  code text primary key,
  module text not null,
  name text not null,
  description text
);

create table public.vtx_role_permissions (
  role_id uuid not null references public.vtx_roles(id) on delete cascade,
  permission_code text not null references public.vtx_permissions(code) on delete cascade,
  allowed boolean not null default true,
  primary key (role_id, permission_code)
);

create table public.vtx_user_roles (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.vtx_profiles(id) on delete cascade,
  role_id uuid not null references public.vtx_roles(id) on delete cascade,
  unit_id uuid references public.vtx_units(id) on delete cascade
);

create unique index vtx_user_roles_scope_uq
  on public.vtx_user_roles(profile_id, role_id, coalesce(unit_id, '00000000-0000-0000-0000-000000000000'::uuid));

create table public.vtx_user_permission_overrides (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.vtx_profiles(id) on delete cascade,
  permission_code text not null references public.vtx_permissions(code) on delete cascade,
  unit_id uuid references public.vtx_units(id) on delete cascade,
  allowed boolean not null
);

create unique index vtx_user_permission_overrides_scope_uq
  on public.vtx_user_permission_overrides(profile_id, permission_code, coalesce(unit_id, '00000000-0000-0000-0000-000000000000'::uuid));

create table public.vtx_branding (
  organization_id uuid primary key references public.vtx_organizations(id) on delete cascade,
  business_name text,
  logo_path text,
  app_icon_path text,
  primary_color text,
  secondary_color text,
  accent_color text,
  background_color text,
  surface_color text,
  text_color text,
  theme_preset text,
  powered_by_vortex boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.vtx_terminals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  code text not null,
  name text not null,
  bridge_device_id text,
  status public.vtx_terminal_status not null default 'ACTIVE',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (unit_id, code)
);

create table public.vtx_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  active boolean not null default true,
  unique (organization_id, name)
);

create table public.vtx_products (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  category_id uuid references public.vtx_categories(id) on delete set null,
  sku text,
  name text not null,
  sale_price numeric(14,2) not null default 0,
  yield_quantity numeric(18,4) not null default 1,
  shelf_life_days integer,
  production_type text,
  prep_minutes numeric(12,2),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, sku)
);

create table public.vtx_ingredients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  name text not null,
  purchase_unit text,
  package_quantity numeric(18,4),
  package_cost numeric(14,4),
  base_unit_cost numeric(18,8),
  minimum_stock numeric(18,4),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table public.vtx_recipes (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.vtx_products(id) on delete cascade,
  ingredient_id uuid not null references public.vtx_ingredients(id) on delete restrict,
  quantity numeric(18,6) not null,
  unique (product_id, ingredient_id)
);

create table public.vtx_suppliers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  legal_name text not null,
  document text,
  phone text,
  pix_key text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.vtx_inventory_movements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  ingredient_id uuid references public.vtx_ingredients(id) on delete restrict,
  product_id uuid references public.vtx_products(id) on delete restrict,
  movement_type text not null,
  quantity numeric(18,6) not null,
  unit_cost numeric(18,8),
  reference_type text,
  reference_id uuid,
  reason text,
  created_by uuid references public.vtx_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  check (ingredient_id is not null or product_id is not null)
);

create table public.vtx_purchase_history (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  supplier_id uuid references public.vtx_suppliers(id) on delete set null,
  ingredient_id uuid references public.vtx_ingredients(id) on delete set null,
  quantity numeric(18,4) not null default 0,
  total_amount numeric(14,2) not null default 0,
  purchased_at timestamptz not null default now(),
  active boolean not null default true
);

create table public.vtx_production_batches (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  product_id uuid not null references public.vtx_products(id) on delete restrict,
  quantity_produced numeric(18,4) not null,
  batch_cost numeric(14,4) not null default 0,
  produced_at timestamptz not null default now(),
  expires_at date,
  status text not null,
  created_by uuid references public.vtx_profiles(id) on delete set null
);

create table public.vtx_loss_records (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  ingredient_id uuid references public.vtx_ingredients(id) on delete set null,
  product_id uuid references public.vtx_products(id) on delete set null,
  quantity numeric(18,6) not null,
  reason text not null,
  created_by uuid references public.vtx_profiles(id) on delete set null,
  authorized_by uuid references public.vtx_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.vtx_customers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  name text,
  cpf text,
  phone text,
  email text,
  marketing_consent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, phone),
  unique (organization_id, cpf)
);

create table public.vtx_tables (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  number integer not null,
  name text,
  status public.vtx_table_status not null default 'AVAILABLE',
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (unit_id, number)
);

create table public.vtx_tabs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  table_id uuid references public.vtx_tables(id) on delete set null,
  customer_id uuid references public.vtx_customers(id) on delete set null,
  opened_by uuid references public.vtx_profiles(id) on delete set null,
  opened_at timestamptz not null default now(),
  closed_at timestamptz,
  status public.vtx_tab_status not null default 'OPEN'
);

create table public.vtx_orders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  tab_id uuid references public.vtx_tabs(id) on delete set null,
  table_id uuid references public.vtx_tables(id) on delete set null,
  waiter_id uuid references public.vtx_profiles(id) on delete set null,
  waiter_cpf_snapshot text,
  terminal_id uuid references public.vtx_terminals(id) on delete set null,
  status public.vtx_order_status not null default 'DRAFT',
  notes text,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  updated_at timestamptz not null default now(),
  version integer not null default 1
);

create table public.vtx_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.vtx_orders(id) on delete cascade,
  product_id uuid not null references public.vtx_products(id) on delete restrict,
  quantity numeric(18,4) not null,
  unit_price numeric(14,2) not null,
  status public.vtx_order_item_status not null default 'ACTIVE',
  notes text,
  cancel_reason text,
  cancel_requested_by uuid references public.vtx_profiles(id) on delete set null,
  cancelled_by uuid references public.vtx_profiles(id) on delete set null,
  cancellation_authorized_by uuid references public.vtx_profiles(id) on delete set null,
  cancelled_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.vtx_cash_sessions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  terminal_id uuid not null references public.vtx_terminals(id) on delete restrict,
  opened_by uuid not null references public.vtx_profiles(id) on delete restrict,
  closed_by uuid references public.vtx_profiles(id) on delete set null,
  opened_at timestamptz not null default now(),
  closed_at timestamptz,
  opening_amount numeric(14,2) not null default 0,
  expected_amount numeric(14,2),
  counted_amount numeric(14,2),
  difference_amount numeric(14,2),
  status public.vtx_cash_status not null default 'OPEN'
);

create unique index vtx_one_open_cash_per_terminal
  on public.vtx_cash_sessions(terminal_id)
  where status = 'OPEN';

create table public.vtx_cash_movements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  cash_session_id uuid not null references public.vtx_cash_sessions(id) on delete cascade,
  movement_type text not null,
  amount numeric(14,2) not null,
  reason text,
  created_by uuid references public.vtx_profiles(id) on delete set null,
  authorized_by uuid references public.vtx_profiles(id) on delete set null,
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now()
);

create table public.vtx_sales (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  terminal_id uuid references public.vtx_terminals(id) on delete set null,
  cash_session_id uuid references public.vtx_cash_sessions(id) on delete set null,
  tab_id uuid references public.vtx_tabs(id) on delete set null,
  customer_id uuid references public.vtx_customers(id) on delete set null,
  waiter_id uuid references public.vtx_profiles(id) on delete set null,
  waiter_cpf_snapshot text,
  sold_by uuid references public.vtx_profiles(id) on delete set null,
  subtotal numeric(14,2) not null default 0,
  discount_amount numeric(14,2) not null default 0,
  service_rate numeric(7,4) not null default 0,
  service_amount numeric(14,2) not null default 0,
  service_accepted boolean,
  total_amount numeric(14,2) not null default 0,
  status text not null default 'COMPLETED',
  sold_at timestamptz not null default now()
);

create table public.vtx_sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.vtx_sales(id) on delete cascade,
  product_id uuid references public.vtx_products(id) on delete restrict,
  description_snapshot text not null,
  quantity numeric(18,4) not null,
  unit_price numeric(14,2) not null,
  total_amount numeric(14,2) not null
);

create table public.vtx_payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  sale_id uuid not null references public.vtx_sales(id) on delete cascade,
  method public.vtx_payment_method not null,
  status public.vtx_payment_status not null default 'PENDING',
  amount numeric(14,2) not null,
  installments integer not null default 1,
  provider text,
  payment_terminal_id uuid,
  bridge_job_id text,
  provider_transaction_id text,
  nsu text,
  authorization_code text,
  card_brand text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  approved_at timestamptz
);

create table public.vtx_tips (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  sale_id uuid not null references public.vtx_sales(id) on delete cascade,
  waiter_id uuid references public.vtx_profiles(id) on delete set null,
  waiter_cpf_snapshot text,
  suggested_rate numeric(7,4) not null default 10,
  accepted boolean not null default false,
  amount numeric(14,2) not null default 0,
  created_at timestamptz not null default now()
);

create table public.vtx_loyalty_ledger (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  customer_id uuid not null references public.vtx_customers(id) on delete cascade,
  sale_id uuid references public.vtx_sales(id) on delete set null,
  points_delta numeric(14,2) not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table public.vtx_printers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  terminal_id uuid references public.vtx_terminals(id) on delete set null,
  name text not null,
  connection_type text not null,
  device_identifier text,
  role text not null default 'RECEIPT',
  paper_width_mm integer,
  is_default boolean not null default false,
  status public.vtx_device_status not null default 'OFFLINE',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.vtx_payment_terminals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  terminal_id uuid references public.vtx_terminals(id) on delete set null,
  name text not null,
  provider text not null,
  model text,
  protocol text,
  device_identifier text,
  is_default boolean not null default false,
  status public.vtx_device_status not null default 'OFFLINE',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.vtx_payments
  add constraint vtx_payments_payment_terminal_fk
  foreign key (payment_terminal_id) references public.vtx_payment_terminals(id) on delete set null;

create table public.vtx_fiscal_documents (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid not null references public.vtx_units(id) on delete cascade,
  sale_id uuid not null references public.vtx_sales(id) on delete restrict,
  model text not null,
  series text,
  document_number text,
  access_key text,
  protocol text,
  status public.vtx_fiscal_status not null default 'PENDING',
  xml_path text,
  danfe_path text,
  qr_code text,
  provider text,
  provider_payload jsonb not null default '{}'::jsonb,
  error_message text,
  authorized_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  unique (sale_id, model)
);

create table public.vtx_financial_entries (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid references public.vtx_units(id) on delete set null,
  entry_type text not null,
  category text,
  amount numeric(14,2) not null,
  due_date date,
  paid_at timestamptz,
  status text,
  description text,
  sale_id uuid references public.vtx_sales(id) on delete set null,
  supplier_id uuid references public.vtx_suppliers(id) on delete set null,
  customer_id uuid references public.vtx_customers(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.vtx_settings (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.vtx_organizations(id) on delete cascade,
  unit_id uuid references public.vtx_units(id) on delete cascade,
  key text not null,
  value jsonb not null default 'null'::jsonb,
  updated_at timestamptz not null default now()
);

create unique index vtx_settings_scope_uq
  on public.vtx_settings(organization_id, coalesce(unit_id, '00000000-0000-0000-0000-000000000000'::uuid), key);

create table public.vtx_audit_log (
  id bigint generated always as identity primary key,
  organization_id uuid not null references public.vtx_organizations(id) on delete restrict,
  unit_id uuid references public.vtx_units(id) on delete set null,
  actor_id uuid references public.vtx_profiles(id) on delete set null,
  authorizer_id uuid references public.vtx_profiles(id) on delete set null,
  terminal_id uuid references public.vtx_terminals(id) on delete set null,
  action text not null,
  entity_type text,
  entity_id text,
  reason text,
  before_data jsonb,
  after_data jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index vtx_profiles_org_idx on public.vtx_profiles(organization_id);
create index vtx_orders_unit_status_idx on public.vtx_orders(unit_id, status, created_at desc);
create index vtx_order_items_order_idx on public.vtx_order_items(order_id);
create index vtx_sales_unit_date_idx on public.vtx_sales(unit_id, sold_at desc);
create index vtx_payments_sale_idx on public.vtx_payments(sale_id);
create index vtx_inventory_unit_date_idx on public.vtx_inventory_movements(unit_id, created_at desc);
create index vtx_audit_org_date_idx on public.vtx_audit_log(organization_id, created_at desc);
create index vtx_fiscal_sale_idx on public.vtx_fiscal_documents(sale_id);
