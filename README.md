# 4FORTY LIVE

A simple live taxi booking app starter using HTML, JavaScript, Leaflet, and Supabase.

## Files
- `index.html` — frontend app
- `supabase/schema.sql` — database schema

## Setup
1. Create a Supabase project.
2. Paste the contents of `supabase/schema.sql` into the SQL editor.
3. Replace these values in `index.html`:
   - `SUPABASE_URL`
   - `SUPABASE_KEY`
4. Open `index.html` in a browser.

## Security note
- Use only the Supabase publishable/anon key in the browser.
- Keep service-role keys out of frontend code.
- Use Supabase Auth and server-side validation for production.
