-- Supabase SQL schema for 4FORTY app

create extension if not exists pgcrypto;

create table if not exists public.taxis (
  id uuid primary key default gen_random_uuid(),
  plate text not null unique,
  route text not null,
  driver text,
  phone text,
  status text not null default 'LIVE',
  is_gold boolean not null default false,
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  from_route text not null,
  to_route text not null,
  passenger_name text not null,
  passenger_phone text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.drivers (
  id uuid primary key default gen_random_uuid(),
  phone text not null unique,
  plate text not null unique,
  status text not null default 'pending',
  paid boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger taxis_updated_at
before update on public.taxis
for each row
execute procedure public.set_updated_at();

create trigger drivers_updated_at
before update on public.drivers
for each row
execute procedure public.set_updated_at();

alter table public.taxis enable row level security;
alter table public.bookings enable row level security;
alter table public.drivers enable row level security;

create policy "Anyone can read live taxis"
on public.taxis
for select
using (true);

create policy "Anyone can insert booking"
on public.bookings
for insert
with check (true);

create policy "Anyone can insert driver"
on public.drivers
for insert
with check (true);
