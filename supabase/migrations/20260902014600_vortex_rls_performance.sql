drop policy if exists vtx_profiles_select_self on public.vtx_profiles;
create policy vtx_profiles_select_self
on public.vtx_profiles
for select
to authenticated
using (id = (select auth.uid()));
