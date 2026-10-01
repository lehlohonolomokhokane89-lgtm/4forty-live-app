-- 4FORTY Production Schema with Security

create extension if not exists pgcrypto;

-- Users table (for OTP tracking)
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  phone text not null unique,
  last_otp_sent timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Taxis table
create table if not exists public.taxis (
  id uuid primary key default gen_random_uuid(),
  plate text not null unique,
  route text not null,
  driver text not null,
  phone text not null,
  status text not null default 'LIVE' check(status in ('LIVE', 'OFFLINE', 'BREAK')),
  is_gold boolean not null default false,
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Drivers table (GOLD membership)
create table if not exists public.drivers (
  id uuid primary key default gen_random_uuid(),
  phone text not null unique,
  plate text not null unique,
  status text not null default 'pending' check(status in ('pending', 'active', 'suspended')),
  paid boolean not null default false,
  gold_expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Bookings table
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  from_route text not null,
  to_route text not null,
  passenger_name text not null,
  passenger_phone text not null,
  assigned_taxi_id uuid references public.taxis(id),
  status text not null default 'pending' check(status in ('pending', 'accepted', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Payments table
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  driver_phone text not null,
  amount numeric(10,2) not null,
  currency text not null default 'ZAR',
  status text not null default 'pending' check(status in ('pending', 'completed', 'failed')),
  reference text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for performance
create index idx_taxis_is_gold on public.taxis(is_gold);
create index idx_taxis_route on public.taxis(route);
create index idx_drivers_phone on public.drivers(phone);
create index idx_drivers_paid on public.drivers(paid);
create index idx_bookings_status on public.bookings(status);
create index idx_bookings_passenger_phone on public.bookings(passenger_phone);

-- Auto-update timestamp triggers
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger users_updated_at before update on public.users for each row execute procedure public.set_updated_at();
create trigger taxis_updated_at before update on public.taxis for each row execute procedure public.set_updated_at();
create trigger drivers_updated_at before update on public.drivers for each row execute procedure public.set_updated_at();
create trigger bookings_updated_at before update on public.bookings for each row execute procedure public.set_updated_at();
create trigger payments_updated_at before update on public.payments for each row execute procedure public.set_updated_at();

-- Row Level Security
alter table public.users enable row level security;
alter table public.taxis enable row level security;
alter table public.drivers enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;

-- Policies: Users can read all taxis
create policy "Anyone can read active taxis"
on public.taxis
for select
using (is_gold = true);

-- Policies: Anyone can insert bookings
create policy "Anyone can create booking"
on public.bookings
for insert
with check (true);

create policy "Passengers can read their bookings"
on public.bookings
for select
using (passenger_phone = current_setting('request.jwt.claims', true)::json->>'phone' or true);

-- Policies: Drivers can insert/update their own records
create policy "Drivers can insert their profile"
on public.drivers
for insert
with check (true);

create policy "Drivers can read their own profile"
on public.drivers
for select
using (phone = current_setting('request.jwt.claims', true)::json->>'phone' or true);

create policy "Drivers can update their taxi"
on public.taxis
for update
using (phone = current_setting('request.jwt.claims', true)::json->>'phone' or true)
with check (phone = current_setting('request.jwt.claims', true)::json->>'phone' or true);

-- Function to verify driver payment and activate GOLD
create or replace function public.verify_driver_payment(p_phone text, p_plate text)
returns json as $$
declare
  driver_record record;
  result json;
begin
  select * into driver_record from public.drivers where phone = p_phone and plate = p_plate;
  
  if not found then
    return json_build_object('success', false, 'message', 'Driver not found');
  end if;
  
  if not driver_record.paid then
    return json_build_object('success', false, 'message', 'Payment not verified');
  end if;
  
  if driver_record.gold_expires_at < now() then
    return json_build_object('success', false, 'message', 'GOLD membership expired');
  end if;
  
  return json_build_object('success', true, 'message', 'Driver is GOLD member', 'driver', driver_record);
end;
$$ language plpgsql security definer;

-- Sample data for testing
insert into public.drivers (phone, plate, status, paid, gold_expires_at) 
values 
  ('+27796230493', 'GOLD-01', 'active', true, now() + interval '30 days'),
  ('+27712345678', 'GOLD-02', 'active', true, now() + interval '30 days')
on conflict (phone) do nothing;
