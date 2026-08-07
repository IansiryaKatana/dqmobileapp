# Donate Quran Admin

TanStack React CMS for staff — content, FAQ, operations, and RevenueCat offering configuration.

**Payments:** RevenueCat only on mobile. Never store RevenueCat API keys or webhook secrets in this app.

## Setup

```bash
cd admin
cp .env.example .env
npm install
npm run dev
```

## Staff access

After signing up in the mobile app (or Supabase Auth), promote the user:

```sql
UPDATE public.profiles SET role = 'admin' WHERE email = 'you@example.com';
```

Roles: `user` (default), `editor`, `admin`.

## What you can manage

| Area | Table / storage |
|------|-----------------|
| Articles, books, campaigns | `content_items` |
| FAQ | `faq_items` |
| Quran topics | `quran_topics` |
| Home / donate copy | `app_settings` |
| RevenueCat offering IDs | `app_settings.revenuecat` |
| Media uploads | `cms-media` bucket |
| Donations, orders, scholar Q&A | read-only ops views |
