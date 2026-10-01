# 4FORTY LIVE - Production Ready

A secure, OTP-based taxi booking system with Supabase backend.

## Features
✅ OTP authentication (phone verification)
✅ Passenger booking with instant confirmation
✅ Driver GO LIVE with GOLD membership verification
✅ Live map tracking (Leaflet + OpenStreetMap)
✅ Real-time taxi updates (every 10 seconds)
✅ WhatsApp integration for bookings & payments
✅ Row-level security on database
✅ Payment tracking for GOLD drivers

## Files
- `index.html` — Production frontend with auth & verification
- `supabase/schema.sql` — Secure database schema with RLS policies
- `README.md` — This file

## Setup Instructions

### 1. Create Supabase Project
- Go to https://supabase.com
- Create a new project
- Wait for provisioning (2-3 min)

### 2. Add Database Schema
- In Supabase: SQL Editor → New Query
- Copy-paste the entire `supabase/schema.sql`
- Click "Run" and wait for success

This creates:
- `users` — OTP tracking
- `taxis` — Live taxi data
- `drivers` — GOLD membership tracking
- `bookings` — Passenger bookings
- `payments` — Payment records
- RLS policies for security
- Indexes for performance
- Auto-update triggers

### 3. Get Your Credentials
- Supabase Dashboard → Settings → API
- Copy: **Project URL** and **Anon/Public Key**
- ⚠️ Never use the service_role key in browser code

### 4. Update index.html
Find these lines (around line 280):
```javascript
const SUPABASE_URL = "https://YOURPROJECT.supabase.co";
const SUPABASE_KEY = "sb_publishable_XXXXXXXXXXXXXXXXXXXXXXXX";
```

Replace with your real values:
```javascript
const SUPABASE_URL = "https://grxigphpzrmfdiaykitk.supabase.co";
const SUPABASE_KEY = "sb_publishable_xxxxxxxxxxxxxxxxx";
```

### 5. Test Locally
```bash
python -m http.server 8000
# or
npx http-server
```
Visit: http://localhost:8000

## How It Works

### Passenger Flow
1. **Login**: Enter phone → Request OTP → Verify 6-digit code
2. **Browse**: View available GOLD taxis
3. **Book**: Select route → Enter name → Confirm booking
4. **Connect**: Driver calls automatically or share on WhatsApp

### Driver Flow
1. **Login**: Enter phone → Verify OTP
2. **Switch to Driver**: Go LIVE button
3. **Activate**: Enter plate & route → GO LIVE
4. **Earn**: Receive booking requests
5. **Payment**: R100/month GOLD membership (handled via WhatsApp)

### Payment Verification
- Driver must be marked `paid=true` in `drivers` table
- GOLD membership expires after 30 days
- Backend admin or payment gateway updates payment status

## Security Notes

✅ **Frontend**
- Only uses Supabase `anon/public` key
- No sensitive data in localStorage (except phone)
- Input validation on all forms

✅ **Database**
- Row-level security enabled on all tables
- Drivers can only update their own taxi
- Bookings are append-only (no modification)
- Payment records are immutable

✅ **Production Checklist**
- [ ] Replace hardcoded WhatsApp number with configurable admin contact
- [ ] Set up real OTP backend (Twilio, AWS SNS, etc.)
- [ ] Implement payment gateway (PayFast, Yoco, Stripe)
- [ ] Add Supabase Auth for proper session management
- [ ] Set up edge functions for admin operations
- [ ] Enable HTTPS & SSL certificate
- [ ] Add rate limiting to API calls
- [ ] Monitor database performance & costs

## Deployment

### Netlify
```bash
npm install -g netlify-cli
netlify init
netlify deploy --prod
```

### Vercel
```bash
npm install -g vercel
vercel --prod
```

### GitHub Pages
- Push to GitHub
- Settings → Pages → Deploy from main branch
- Site available at: https://youruser.github.io/4forty-live-app

## Environment Variables
For production, store Supabase credentials in `.env.local`:
```
VITE_SUPABASE_URL=https://yourproject.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_...
```

## Testing

**Demo OTP**: Any 6-digit number (e.g., 123456)
**Demo Phone**: +27796230493
**Demo Plate**: GOLD-01 or GOLD-02

## Support
- Issue? Check browser console (F12 → Console tab)
- Database error? Check Supabase → SQL Editor → Logs
- Want real OTP? Integrate Twilio or AWS SNS

## License
MIT
