-- VORTEX — fundação de autorização/RLS
-- Somente estrutura e policies genéricas. Nenhum usuário, role ou permissão é inserido.

create or replace function public.vtx_current_organization_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select p.organization_id
  from public.vtx_profiles p
  where p.id = auth.uid()
    and p.status = 'ACTIVE'::public.vtx_user_status
  limit 1;
$$;

create or replace function public.vtx_has_permission(p_permission text, p_unit_id uuid default null)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with profile as (
    select p.id, p.organization_id
    from public.vtx_profiles p
    where p.id = auth.uid()
      and p.status = 'ACTIVE'::public.vtx_user_status
  ), override_match as (
    select upo.allowed
    from public.vtx_user_permission_overrides upo
    join profile p on p.id = upo.profile_id
    where upo.permission_code = p_permission
      and (upo.unit_id is null or p_unit_id is null or upo.unit_id = p_unit_id)
    order by (upo.unit_id is not null) desc
    limit 1
  ), role_match as (
    select bool_or(rp.allowed) as allowed
    from public.vtx_user_roles ur
    join public.vtx_roles r on r.id = ur.role_id and r.active
    join public.vtx_role_permissions rp on rp.role_id = r.id
    join profile p on p.id = ur.profile_id
    where rp.permission_code = p_permission
      and (ur.unit_id is null or p_unit_id is null or ur.unit_id = p_unit_id)
  )
  select coalesce(
    (select allowed from override_match),
    (select allowed from role_match),
    false
  );
$$;

grant execute on function public.vtx_current_organization_id() to authenticated;
grant execute on function public.vtx_has_permission(text, uuid) to authenticated;

-- RLS habilitada nas tabelas multiempresa. Policies mais granulares por módulo entram nas migrations de cada domínio.
do $$
declare
  t text;
begin
  foreach t in array array[
    'vtx_organizations','vtx_units','vtx_profiles','vtx_roles','vtx_role_permissions','vtx_user_roles',
    'vtx_user_permission_overrides','vtx_branding','vtx_terminals','vtx_categories','vtx_products',
    'vtx_ingredients','vtx_recipes','vtx_suppliers','vtx_inventory_movements','vtx_purchase_history',
    'vtx_production_batches','vtx_loss_records','vtx_customers','vtx_tables','vtx_tabs','vtx_orders',
    'vtx_order_items','vtx_cash_sessions','vtx_cash_movements','vtx_sales','vtx_sale_items','vtx_payments',
    'vtx_tips','vtx_loyalty_ledger','vtx_printers','vtx_payment_terminals','vtx_fiscal_documents',
    'vtx_financial_entries','vtx_settings','vtx_audit_log'
  ]
  loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Perfil: o usuário pode ler seu próprio perfil.
create policy vtx_profiles_select_self
on public.vtx_profiles
for select
to authenticated
using (id = auth.uid());

-- Organização e branding: membro ativo lê apenas a própria organização.
create policy vtx_organizations_select_member
on public.vtx_organizations
for select
to authenticated
using (id = public.vtx_current_organization_id());

create policy vtx_branding_select_member
on public.vtx_branding
for select
to authenticated
using (organization_id = public.vtx_current_organization_id());

-- Unidades: isolamento organizacional básico.
create policy vtx_units_select_org
on public.vtx_units
for select
to authenticated
using (organization_id = public.vtx_current_organization_id());

-- Catálogo operacional básico de leitura por organização.
create policy vtx_categories_select_org on public.vtx_categories for select to authenticated
using (organization_id = public.vtx_current_organization_id());
create policy vtx_products_select_org on public.vtx_products for select to authenticated
using (organization_id = public.vtx_current_organization_id());
create policy vtx_tables_select_org on public.vtx_tables for select to authenticated
using (organization_id = public.vtx_current_organization_id());

-- Nenhuma policy ampla de escrita é criada aqui de propósito.
-- Escritas sensíveis serão feitas por RPCs transacionais SECURITY DEFINER com checks explícitos de vtx_has_permission().
