-- Schema for the Meeting Action Tracker (already applied to the Supabase project).
-- Run this in the Supabase SQL editor to recreate it in a new project.

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

alter table public.actions enable row level security;

-- Open access: anyone with the site can read, add, tick off and delete actions.
-- Only the "done" column can be changed after an action is created.
revoke all on public.actions from anon, authenticated;
grant select, insert, delete on public.actions to anon, authenticated;
grant update (done) on public.actions to anon, authenticated;

create policy "Anyone can read actions" on public.actions
  for select to anon, authenticated using (true);
create policy "Anyone can add actions" on public.actions
  for insert to anon, authenticated with check (true);
create policy "Anyone can tick actions" on public.actions
  for update to anon, authenticated using (true) with check (true);
create policy "Anyone can delete actions" on public.actions
  for delete to anon, authenticated using (true);

-- Optional sample data (flagged so the "Clear samples" button can remove it).
insert into public.actions (text, owner, due, done, is_sample) values
  ('Send revised pricing to the Lim account', 'Priya', '2026-11-06', false, true),
  ('Draft the Q1 hiring plan for review', 'Priya', '2026-11-14', false, true),
  ('Book the venue for the December offsite', 'Marcus', '2026-11-11', false, true),
  ('Confirm launch date with legal', 'Marcus', '2026-11-18', false, true),
  ('Fix the onboarding email bounce issue', 'Daniel', '2026-11-07', false, true),
  ('Share meeting notes with the wider team', 'Daniel', '2026-11-08', true, true),
  ('Update the shared roadmap', 'Mei Ling', '2026-11-09', false, true),
  ('Collect feedback from the pilot customers', 'Mei Ling', '2026-11-04', true, true);
