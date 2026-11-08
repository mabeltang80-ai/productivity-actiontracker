-- Schema for the Meeting Action Tracker (already applied to the Supabase project).
-- Run this in the Supabase SQL editor to recreate it in a new project.
--
-- Passwords live in Supabase's built-in auth.users table. The tables below sit beside it.
-- User accounts are NOT created here. Create the first admin in the dashboard
-- (Authentication > Users, email username@actiontracker.example, tick "Auto confirm user"),
-- then add its profile row:
--   insert into public.profiles (id, username, display_name, role)
--   values ('<the user id>', 'admin', 'Admin', 'admin');
-- Further users are added from the app by an admin (Account > Add a user).

-- Actions ---------------------------------------------------------------
create table public.actions (
  id uuid primary key default gen_random_uuid(),
  text text not null check (char_length(btrim(text)) between 1 and 200),
  owner text not null check (char_length(btrim(owner)) between 1 and 60),
  due date not null,
  done boolean not null default false,
  is_sample boolean not null default false,
  created_at timestamptz not null default now()
);
comment on table public.actions is 'Meeting actions: one row per agreed action with owner, due date and done flag.';

-- Profiles: one per person allowed to use the tracker, linked to auth.users ----
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9._-]{2,30}$'),
  display_name text not null check (char_length(btrim(display_name)) between 1 and 60),
  role text not null default 'member' check (role in ('admin', 'member')),
  created_at timestamptz not null default now()
);
comment on table public.profiles is 'Tracker users: username, display name and role, linked one-to-one to auth.users. A person can use the tracker only if they have a row here.';

-- Helper used by the policies. Kept in a private schema so it is not exposed by the API.
create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create function private.is_member()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.profiles where id = (select auth.uid()));
$$;
revoke execute on function private.is_member() from public, anon;
grant execute on function private.is_member() to authenticated;

-- Access: only signed-in people with a profile ------------------------------
alter table public.actions enable row level security;
alter table public.profiles enable row level security;

revoke all on public.actions from anon, authenticated;
revoke all on public.profiles from anon, authenticated;
grant select, insert, delete on public.actions to authenticated;
grant update (done) on public.actions to authenticated;   -- only the done flag can change
grant select on public.profiles to authenticated;          -- profiles are written by the create-user function only

create policy "Members can read actions" on public.actions
  for select to authenticated using ((select private.is_member()));
create policy "Members can add actions" on public.actions
  for insert to authenticated with check ((select private.is_member()));
create policy "Members can tick actions" on public.actions
  for update to authenticated
  using ((select private.is_member())) with check ((select private.is_member()));
create policy "Members can delete actions" on public.actions
  for delete to authenticated using ((select private.is_member()));

create policy "Members can read profiles" on public.profiles
  for select to authenticated using ((select private.is_member()));
