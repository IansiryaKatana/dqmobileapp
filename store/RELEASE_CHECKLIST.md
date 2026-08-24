# Store release checklist

Repo-side store blockers are implemented. Complete these **outside the Flutter tree** before submitting for review.

## Hosting and legal URLs

- [ ] Deploy the `site/` folder (Netlify: set base directory to `site`).
- [ ] Point `donatequran.com` at that host so `/privacy`, `/terms`, and `/support` return 200.
- [ ] Replace `TEAMID` in `site/.well-known/apple-app-site-association` with your Apple Team ID.
- [ ] Put the Play App Signing SHA-256 into `site/.well-known/assetlinks.json`.

## Payments

- [ ] Create a Stripe account and product/price for £3.99 GBP postage (the app charges a server-fixed 399 pence).
- [ ] Set Supabase secret `STRIPE_SECRET_KEY`.
- [ ] Set `STRIPE_PUBLISHABLE_KEY` in local `.env` and Codemagic.
- [ ] `supabase db push` (includes `orders.stripe_payment_intent_id` and donation-copy updates).
- [ ] Deploy functions: `create-postage-payment`, `complete-postage-order`, `delete-account`.
- [ ] Create RevenueCat / App Store / Play **donation** products only (`dq_donate_*_once|monthly`). Do not create postage as IAP.

## Apple

- [ ] App ID `com.donatequran.donatequran` with Push Notifications, Associated Domains (`applinks:donatequran.com`), and In-App Purchase.
- [ ] Upload an APNs key to Firebase for that iOS app.
- [ ] App Store Connect: privacy nutrition labels, age rating, encryption (HTTPS only), IAP subscription group, review demo login.
- [ ] iPhone 6.7" screenshots (and iPad if you keep `TARGETED_DEVICE_FAMILY = 1,2`).
- [ ] Confirm Codemagic uses bundle ID `com.donatequran.donatequran` (already set in `codemagic.yaml`).

## Google Play

- [ ] App `com.donatequran.donate_quran`, Play App Signing, Data safety (location, crash logs, purchase history, notifications; Advertising ID not used).
- [ ] Content rating, target audience, 16 KB page-size compliance.
- [ ] Phone screenshots and 1024×500 feature graphic.
- [ ] Internal testing track AAB from Codemagic before production.

## Capture screenshots

See `store/screenshots/README.md`. Capture Home, Donate, Quran reader, Qibla, and Order checkout (Stripe postage copy).

## Optional

- [ ] Nonprofit / Apple Small Business enrolment if you want fee-free donation language.
