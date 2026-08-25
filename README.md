# Donate Quran

Flutter mobile app for [donatequran.com](https://donatequran.com) — donate, order free Qurans, read, Qibla, and learn.

## Setup

1. Install Flutter 3.12+ and Android Studio / Xcode toolchains.
2. Copy `.env.example` to `.env` and add your keys:
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`
   - `REVENUECAT_API_KEY_ANDROID`, `REVENUECAT_API_KEY_IOS`
   - `STRIPE_PUBLISHABLE_KEY` (`pk_…` only; the secret key is a Supabase Edge Function secret)
3. Run `flutter pub get`.
4. Apply Supabase migrations: `supabase db push`.
5. Deploy Edge Functions (`create-postage-payment`, `complete-postage-order`, `delete-account`, plus existing push/email). Set `STRIPE_SECRET_KEY` in the Supabase dashboard.
6. **Firebase (required for push):** run `flutterfire configure` to replace placeholders in
   `lib/core/config/firebase_options.dart` and generate `google-services.json` / `GoogleService-Info.plist`.
   Until that is done, the app skips FCM init and shows that notifications are not configured.
   Do **not** invent Firebase credentials.
7. **RevenueCat products (donations only):** create store products matching the IDs documented in `.env.example`
   (`dq_donate_*_once|monthly`) and attach them to the current offering. Postage is **not** an IAP product.

## Run

```bash
flutter devices
flutter run --dart-define-from-file=.env -d <device_id>
```

`.env` is not bundled as a Flutter asset. Local and CI builds inject keys with `--dart-define-from-file=.env`.

## Release

See [store/RELEASE_CHECKLIST.md](store/RELEASE_CHECKLIST.md) before App Store / Play submission.

- Android signing: copy `android/key.properties.example` → `android/key.properties` and add your keystore.
- **iOS (build on your Mac — primary path):**
  1. Install Xcode + Flutter, then `sudo xcode-select -s /Applications/Xcode.app`
  2. `cp .env.example .env` and fill keys (include `REVENUECAT_API_KEY_IOS`)
  3. Sign in to Xcode with your Apple ID and select a Team for the Runner target (`./scripts/build-ios.sh open`)
  4. Build:
     - Simulator: `./scripts/build-ios.sh sim` then `flutter run --dart-define-from-file=.env`
     - Release IPA: `APPLE_TEAM_ID=YOUR_TEAM_ID ./scripts/build-ios.sh`
  5. IPA output: `build/ios/ipa/*.ipa` — Bundle ID `com.donatequran.donatequran`
- Optional CI: `codemagic.yaml` still has an `ios-release` workflow if you want cloud builds later.
- Release builds fail closed without Supabase / RevenueCat / Stripe (no fake donation, order, or login success).

## Admin CMS (TanStack)

Staff web app for content, FAQ, ops, and RevenueCat offering IDs (no payment secrets).

1. `cd admin && cp .env.example .env` — set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
2. `npm install && npm run dev` — opens at http://localhost:5174
3. Promote a user to staff in Supabase: `UPDATE profiles SET role = 'admin' WHERE email = 'you@example.com';`
4. Apply migrations including `20260706120000_cms_admin.sql`

**Payments:** Donations use **RevenueCat** (store IAP). Postage uses **Stripe**. Keys live in Flutter `.env` / Codemagic and Supabase secrets — not in the admin. The admin stores offering/package IDs in `app_settings.revenuecat` only.

**Legal site:** static pages in `site/` (privacy, terms, support). Point `donatequran.com` at that folder (Netlify base directory `site`).

## Project structure

- `lib/features/` — screens by domain (donate, order, quran, qibla, auth, more)
- `lib/core/services/` — Supabase, RevenueCat, Stripe postage, Firebase, Quran API
- `lib/shared/widgets/` — design system components
- `admin/` — TanStack React CMS for staff
- `supabase/migrations/` — database schema
- `site/` — public privacy/terms/support pages
