-- Shared travel guide storage. Run once in the Supabase SQL Editor.
-- The public site can call only these two functions; direct table access is revoked.

create table if not exists public.shared_trip_guides (
  share_key text primary key check (share_key ~ '^[a-f0-9]{48}$'),
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.shared_trip_guides enable row level security;
revoke all on table public.shared_trip_guides from public, anon, authenticated;
grant usage on schema public to anon;

create or replace function public.get_shared_guide(p_share_key text)
returns jsonb
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select jsonb_build_object('state', g.state, 'updated_at', g.updated_at)
  from public.shared_trip_guides as g
  where g.share_key = p_share_key
$$;

create or replace function public.save_shared_guide(p_share_key text, p_state jsonb)
returns timestamptz
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  saved_at timestamptz;
begin
  if p_share_key is null or p_share_key !~ '^[a-f0-9]{48}$' then
    raise exception 'Invalid share key';
  end if;
  if p_state is null then
    raise exception 'Guide state is required';
  end if;

  insert into public.shared_trip_guides (share_key, state, updated_at)
  values (p_share_key, p_state, now())
  on conflict (share_key) do update
    set state = excluded.state, updated_at = now()
  returning updated_at into saved_at;

  return saved_at;
end;
$$;

revoke all on function public.get_shared_guide(text) from public;
revoke all on function public.save_shared_guide(text, jsonb) from public;
grant execute on function public.get_shared_guide(text) to anon;
grant execute on function public.save_shared_guide(text, jsonb) to anon;



-- Private map artwork is returned only through the invitation-key RPC.
create table if not exists public.shared_trip_guide_assets (
  share_key text primary key references public.shared_trip_guides(share_key) on delete cascade,
  atlas_photo text not null,
  cover_photo text not null,
  updated_at timestamptz not null default now(),
  constraint shared_trip_guide_assets_key_format check (share_key ~ '^[a-f0-9]{48}$'),
  constraint shared_trip_guide_assets_atlas_format check (atlas_photo like 'data:image/jpeg;base64,%'),
  constraint shared_trip_guide_assets_cover_format check (cover_photo like 'data:image/jpeg;base64,%')
);

alter table public.shared_trip_guide_assets enable row level security;
revoke all on table public.shared_trip_guide_assets from public, anon, authenticated;

create or replace function public.get_shared_guide_map(p_share_key text)
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public
as $$
declare
  result jsonb;
begin
  if p_share_key is null or p_share_key !~ '^[a-f0-9]{48}$' then
    raise exception 'Invalid share key';
  end if;

  select jsonb_build_object(
    'atlas_photo', a.atlas_photo,
    'cover_photo', a.cover_photo
  ) into result
  from public.shared_trip_guide_assets as a
  where a.share_key = p_share_key;

  return result;
end;
$$;

revoke all on function public.get_shared_guide_map(text) from public;
grant execute on function public.get_shared_guide_map(text) to anon;
