create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.vtx_current_organization_id()
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

create or replace function private.vtx_has_permission(p_permission text, p_unit_id uuid default null)
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

revoke all on function private.vtx_current_organization_id() from public, anon;
revoke all on function private.vtx_has_permission(text, uuid) from public, anon;
grant execute on function private.vtx_current_organization_id() to authenticated;
grant execute on function private.vtx_has_permission(text, uuid) to authenticated;

alter table public.vtx_permissions enable row level security;

drop policy if exists vtx_permissions_select_authenticated on public.vtx_permissions;
create policy vtx_permissions_select_authenticated
on public.vtx_permissions
for select
to authenticated
using (true);

drop policy if exists vtx_organizations_select_member on public.vtx_organizations;
create policy vtx_organizations_select_member
on public.vtx_organizations
for select
to authenticated
using (id = private.vtx_current_organization_id());

drop policy if exists vtx_branding_select_member on public.vtx_branding;
create policy vtx_branding_select_member
on public.vtx_branding
for select
to authenticated
using (organization_id = private.vtx_current_organization_id());

drop policy if exists vtx_units_select_org on public.vtx_units;
create policy vtx_units_select_org
on public.vtx_units
for select
to authenticated
using (organization_id = private.vtx_current_organization_id());

drop policy if exists vtx_categories_select_org on public.vtx_categories;
create policy vtx_categories_select_org on public.vtx_categories for select to authenticated
using (organization_id = private.vtx_current_organization_id());

drop policy if exists vtx_products_select_org on public.vtx_products;
create policy vtx_products_select_org on public.vtx_products for select to authenticated
using (organization_id = private.vtx_current_organization_id());

drop policy if exists vtx_tables_select_org on public.vtx_tables;
create policy vtx_tables_select_org on public.vtx_tables for select to authenticated
using (organization_id = private.vtx_current_organization_id());

drop function if exists public.vtx_has_permission(text, uuid);
drop function if exists public.vtx_current_organization_id();
