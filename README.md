# Donate Quran

Flutter mobile app for [donatequran.org](https://donatequran.org) — donate, order free Qurans, read, Qibla, and learn.

## Setup

1. Install Flutter 3.12+ and Android Studio / Xcode toolchains.
2. Copy `.env.example` to `.env` and add your keys:
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`
   - `REVENUECAT_API_KEY_ANDROID`, `REVENUECAT_API_KEY_IOS`
3. Add `.env` to `pubspec.yaml` assets for release builds (or use `--dart-define-from-file=.env`).
4. Run `flutter pub get`.
5. Apply Supabase migrations: `supabase db push`.
6. **Firebase (required for push):** run `flutterfire configure` to replace placeholders in
   `lib/core/config/firebase_options.dart` and generate `google-services.json` / `GoogleService-Info.plist`.
   Until that is done, the app skips FCM init and shows that notifications are not configured.
   Do **not** invent Firebase credentials.
7. **RevenueCat products:** create store products matching the IDs documented in `.env.example`
   (`dq_donate_*_once|monthly`, `dq_postage_399`) and attach them to the current offering.

## Run

```bash
flutter devices
flutter run -d <device_id>
```

## Release

- Android signing: copy `android/key.properties.example` → `android/key.properties` and add your keystore.
- CI: Codemagic workflows in `codemagic.yaml` inject env vars and run analyze/test before build.
- Release builds fail closed without Supabase / RevenueCat (no fake donation, order, or login success).

## Admin CMS (TanStack)

Staff web app for content, FAQ, ops, and RevenueCat offering IDs (no payment secrets).

1. `cd admin && cp .env.example .env` — set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
2. `npm install && npm run dev` — opens at http://localhost:5174
3. Promote a user to staff in Supabase: `UPDATE profiles SET role = 'admin' WHERE email = 'you@example.com';`
4. Apply migrations including `20260706120000_cms_admin.sql`

**Payments:** Mobile uses **RevenueCat only**. API keys live in Flutter `.env` / Codemagic — not in the admin. The admin stores offering/package IDs in `app_settings.revenuecat` only.

**Email:** Donation confirmation email is not wired yet. See `supabase/functions/donation-email/` scaffold (Resend or similar). Success UI does not claim an email was sent.

## Project structure

- `lib/features/` — screens by domain (donate, order, quran, qibla, auth, more)
- `lib/core/services/` — Supabase, RevenueCat, Firebase, Quran API
- `lib/shared/widgets/` — design system components
- `admin/` — TanStack React CMS for staff
- `supabase/migrations/` — database schema
