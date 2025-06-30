-- Enable Row Level Security
alter table public.users enable row level security;

-- 1. Policies for 'users' table

-- Allow users to view their own profile
drop policy if exists "Allow individual users to view their own profile" on public.users;
create policy "Allow individual users to view their own profile"
on public.users for select
to authenticated
using (auth.uid() = id);

-- Allow users to update their own profile
drop policy if exists "Allow individual users to update their own profile" on public.users;
create policy "Allow individual users to update their own profile"
on public.users for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- Allow new users to be created (handles the trigger from auth.users)
drop policy if exists "Allow new user creation" on public.users;
create policy "Allow new user creation"
on public.users for insert
to authenticated
with check (auth.uid() = id);


-- 2. Policies for 'routes' table

-- Enable Row Level Security
alter table public.routes enable row level security;

-- Allow authenticated users to view all routes
drop policy if exists "Allow authenticated users to view all routes" on public.routes;
create policy "Allow authenticated users to view all routes"
on public.routes for select
to authenticated
using (true);

-- Allow users to insert new routes for themselves
drop policy if exists "Allow authenticated users to insert routes" on public.routes;
create policy "Allow authenticated users to insert routes"
on public.routes for insert
to authenticated
with check (auth.uid() = creator_id);

-- Allow users to update their own routes
drop policy if exists "Allow individual users to update their own routes" on public.routes;
create policy "Allow individual users to update their own routes"
on public.routes for update
to authenticated
using (auth.uid() = creator_id)
with check (auth.uid() = creator_id);

-- Allow users to delete their own routes
drop policy if exists "Allow individual users to delete their own routes" on public.routes;
create policy "Allow individual users to delete their own routes"
on public.routes for delete
to authenticated
using (auth.uid() = creator_id);


-- 3. Policies for 'route_tips' table

-- Enable Row Level Security
alter table public.route_tips enable row level security;

-- Allow authenticated users to view all tips
drop policy if exists "Allow authenticated users to view all tips" on public.route_tips;
create policy "Allow authenticated users to view all tips"
on public.route_tips for select
to authenticated
using (true);

-- Allow users to insert new tips for themselves
drop policy if exists "Allow authenticated users to insert tips" on public.route_tips;
create policy "Allow authenticated users to insert tips"
on public.route_tips for insert
to authenticated
with check (auth.uid() = creator_id); 