# Security Policy for 4FORTY

## Key Security Principles

### 1. Authentication
- ✅ Phone-based OTP authentication
- ✅ User sessions stored in localStorage (phone only)
- ✅ No passwords needed
- ⚠️ Production: Use Supabase Auth for better session management

### 2. Database Access
- ✅ Row-Level Security (RLS) enabled on all tables
- ✅ Users can only read GOLD taxis
- ✅ Drivers can only update their own taxi record
- ✅ Bookings are immutable (no delete/update for users)
- ⚠️ Never expose `service_role_key` in frontend

### 3. API Keys
- ✅ Use `anon/public key` in browser only
- ✅ Keep `service_role_key` server-side only
- ✅ Rotate keys regularly
- ✅ Monitor Supabase dashboard for suspicious activity

### 4. Sensitive Data
- ✅ Phone numbers are hashed in payment records
- ✅ GPS coordinates are rounded (±0.15 degrees)
- ⚠️ HTTPS required for production
- ⚠️ Add rate limiting for OTP requests

### 5. Admin Operations
- ⚠️ Payment verification should be done server-side
- ⚠️ Use Supabase Edge Functions for admin tasks
- ⚠️ Never trust client-side "paid" checks
- ⚠️ Implement webhook verification for payment gateways

### 6. Data Validation
- ✅ Phone number format validation
- ✅ License plate format validation
- ✅ Route whitelist validation
- ⚠️ Backend should re-validate all inputs

## Vulnerability Reporting

If you find a security issue:
1. Do NOT post in issues
2. Email: security@4forty-app.com
3. Include: description, reproduction steps, impact
4. Allow 48 hours for response

## Best Practices for Deployment

### Before Going Live
1. [ ] Set up Supabase Auth
2. [ ] Integrate real OTP provider (Twilio, AWS SNS)
3. [ ] Set up payment gateway (PayFast, Yoco)
4. [ ] Enable HTTPS/SSL
5. [ ] Configure CORS properly
6. [ ] Add rate limiting to API endpoints
7. [ ] Set up error logging (Sentry, LogRocket)
8. [ ] Test all RLS policies
9. [ ] Backup database regularly
10. [ ] Set up monitoring & alerts

### Production Checklist
- [ ] Remove demo OTP code
- [ ] Enable email verification
- [ ] Set up admin dashboard
- [ ] Implement payment verification webhooks
- [ ] Add audit logging for sensitive operations
- [ ] Set up DDoS protection (Cloudflare)
- [ ] Enable database encryption at rest
- [ ] Configure backup retention
- [ ] Document incident response plan
- [ ] Test disaster recovery

## Known Limitations

1. **OTP is demo-only**: Currently accepts any 6-digit code
   - Fix: Integrate Twilio or AWS SNS

2. **Payment verification is manual**: Handled via WhatsApp
   - Fix: Integrate PayFast/Yoco webhooks

3. **GPS is randomized**: No real location tracking
   - Fix: Request device location from driver app

4. **No session timeout**: User stays logged in
   - Fix: Add 24-hour auto-logout in production

5. **No rate limiting**: Can spam bookings
   - Fix: Add Supabase functions with rate limiting

## Compliance

- [ ] POPIA (South African data protection)
- [ ] GDPR (if serving EU users)
- [ ] PCI DSS (if handling payments directly)
- [ ] SOC 2 (for enterprise deployment)
