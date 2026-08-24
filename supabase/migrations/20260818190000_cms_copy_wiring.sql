-- Wire remaining in-app copy through app_settings.
-- Merge on conflict so production taglines and custom markdown are not wiped.

-- Extra donate chrome fields (existing tagline / guest_message win).
UPDATE public.app_settings
SET value = (
  jsonb_build_object(
    'hero_title', 'Fund Quran printing today',
    'hero_subtitle', 'Every £5 funds one Quran copy.',
    'impact_cards', $dq_impact$[{"label": "Sponsor 1 Quran", "amount_label": "£5"}, {"label": "Sponsor 5 Qurans", "amount_label": "£25"}, {"label": "Sponsor 10 Qurans", "amount_label": "£50"}, {"label": "Sponsor a Box", "amount_label": "£250"}]$dq_impact$::jsonb,
    'checkout_store_note', 'Payment uses the App Store / Play Store checkout via RevenueCat. Supported amounts: £5, £10, £25, £50, £100.',
    'monthly_renew_note', 'Monthly donations auto-renew at {{amount}} until you cancel in your Apple ID or Google Play subscription settings. Restore purchases from Profile if a receipt is missing.',
    'success_title', 'May Allah reward you',
    'success_subtitle', 'Your donation of {{amount}} has been received.'
  ) || value
)
WHERE key = 'donate_copy';

INSERT INTO public.app_settings (key, value, description) VALUES
(
  'legal_documents',
  jsonb_build_object(
    'privacy_md', $dq_privacy$# Donate Quran — Privacy Policy

**Last updated:** 18 August 2026

Donate Quran (“we”, “us”) provides the Donate Quran mobile app for donating toward Quran printing, ordering free Quran copies, reading, Qibla, and learning.

## Information We Collect

- **Account information:** name and email when you create an account.
- **Donation data:** amount, frequency, receipt identifiers, and optional “on behalf of” names. Donations are processed by the App Store or Google Play via RevenueCat. We do not store card numbers.
- **Order data:** delivery address, language, quantity, and postage payment identifiers. Postage is processed by Stripe. We do not store card numbers.
- **Location:** approximate or precise location when you allow it, used for Qibla direction and prayer times. You can refuse or later revoke this in device settings.
- **Device motion:** compass / motion sensors for the Qibla compass.
- **Device information:** push notification tokens so we can send order updates, donation confirmations, and scholar replies.
- **Diagnostics:** crash reports via Firebase Crashlytics in release builds, to keep the app stable.
- **Usage data:** in-app interactions that help us improve content and reliability.

## How We Use Your Information

- Process donations and Quran orders.
- Send order updates and donation receipts (when email is configured).
- Respond to scholar questions.
- Show Qibla direction and prayer times.
- Improve app functionality and security.

## Data Storage

Application data is stored using Supabase (PostgreSQL) with row-level security. Payment card details are handled by Apple, Google, or Stripe — we do not store full card numbers.

## Third-Party Services

- **Supabase** — authentication and database
- **Firebase Cloud Messaging** — push notifications
- **Firebase Crashlytics** — crash reporting
- **RevenueCat** — App Store / Play Store donation purchases
- **Stripe** — postage payments for physical Quran deliveries

## Your Rights

You may request access or correction of your data by emailing support@donatequran.com.

If you have an account, you can **delete it in the app** (Profile → Delete account). Deletion removes your login and profile. Donation and order records may be retained in anonymised form for accounting and fulfilment.

## Contact

Email: support@donatequran.com
$dq_privacy$,
    'terms_md', $dq_terms$# Donate Quran — Terms & Conditions

**Last updated:** 18 August 2026

These terms apply to the Donate Quran mobile app. By using the app you agree to them.

## Donations

Donations fund Quran printing and distribution. Payments for donations are made through the App Store or Google Play (via RevenueCat). Those stores may deduct a processing fee; the remainder of each donation goes toward printing.

Monthly donations are auto-renewing subscriptions. They renew at the same price until you cancel in your Apple ID or Google Play subscription settings. Restore previous purchases from Profile → Restore purchases.

## Quran orders

Quran copies are free. Postage and packaging is charged separately through Stripe (not the App Store or Play Store), because it is a physical delivery. We aim to dispatch within 5–10 business days. Delivery times vary by destination.

## Accounts

You are responsible for the email and password you use. You may delete your account at any time from Profile → Delete account.

## Content

The Quran text, translations, and educational articles are provided for personal, non-commercial use. Do not misuse Ask a Scholar to send abusive or unlawful content.

## Liability

The app is provided as-is. We are not liable for delays in printing or delivery caused by carriers or events outside our control.

## Changes

We may update these terms. The “Last updated” date at the top will change when we do.

## Contact

support@donatequran.com
$dq_terms$,
    'support_md', $dq_support$# Donate Quran — Support

Need help with donations, Quran orders, or the app?

## Contact

Email **support@donatequran.com** and include:

- Your order reference (starts with `DQ-ORD-`) or donation receipt id, if relevant
- The device and app version you are using
- A short description of what went wrong

## Common questions

**Where does my donation go?**  
Donations fund Quran printing. If you pay through the App Store or Play Store, those stores may deduct a processing fee. The remainder goes to printing.

**How do I cancel a monthly donation?**  
Open your device subscription settings (Apple ID subscriptions, or Google Play → Payments & subscriptions) and cancel Donate Quran there. You can also tap Restore purchases in the app Profile if a receipt is missing.

**How do I delete my account?**  
Open Profile → Delete account. This is available while you are signed in.

**Privacy and terms**  
See the Privacy Policy and Terms in the app (More → Account) or at [donatequran.com/privacy](https://donatequran.com/privacy) and [donatequran.com/terms](https://donatequran.com/terms).

## Website

[donatequran.com](https://donatequran.com)
$dq_support$
  ),
  'In-app Privacy, Terms, and Support markdown. Public site HTML is deployed separately.'
),
(
  'onboarding',
  $dq_onboarding${"brand": "Donate Quran", "intro_title": "Give the gift\nof Quran", "intro_subtitle": "Donate, order, read and share the Quran\nthrough one trusted app.", "intro_cta": "GET STARTED", "why_title": "Why\nDonate Quran?", "why_subtitle": "Your donation helps provide free Qurans to those who need them most. Together, we can spread the message and bring guidance to every heart.", "skip_label": "Skip", "create_account_cta": "Create Account", "sign_in_cta": "Sign In"}$dq_onboarding$::jsonb,
  'Onboarding intro and why-Donate-Quran copy'
),
(
  'permissions',
  $dq_permissions${"title": "Allow permissions", "subtitle": "Enable notifications and location for the best experience — order updates, donation receipts, and accurate Qibla direction.", "notifications_title": "Notifications", "notifications_description": "Order updates, donation confirmations, and scholar replies.", "location_title": "Location", "location_description": "Used for Qibla direction and prayer times near you.", "continue_label": "Continue to app", "skip_label": "Not now"}$dq_permissions$::jsonb,
  'Permissions screen copy'
),
(
  'logistics',
  $dq_logistics${
  "groups": [
    {
      "label": "Before You Travel",
      "items": [
        {
          "title": "Umrah Visa",
          "snippet": "e-Visa SAR 535 · Visa on arrival SAR 480",
          "icon": "assignment_turned_in_outlined",
          "kind": "visaGrid",
          "visa_cards": [
            {
              "title": "e-Visa",
              "lines": [
                "SAR 535 (~£114)",
                "Application & insurance included"
              ]
            },
            {
              "title": "On Arrival",
              "lines": [
                "SAR 480 (~£102)",
                "+ SAR 180 medical (~£38)"
              ]
            }
          ]
        },
        {
          "title": "Ihram — What to Know",
          "snippet": "Ghusl · Niyyah · Two unstitched cloths",
          "icon": "checkroom_outlined",
          "kind": "ihramSteps",
          "ihram_steps": [
            {
              "n": "1",
              "title": "Ghusl & Prayer",
              "desc": "Perform ghusl (bath) and 2 rakat nafl salah before entering Ihram."
            },
            {
              "n": "2",
              "title": "Enter before Meeqat",
              "desc": "Ihram must be entered before the meeqat boundary. On a flight, the airline will announce the crossing point."
            },
            {
              "n": "3",
              "title": "Wear the Garments",
              "desc": "Two white unstitched cloths — izar (lower) and rida (upper). Slippers must leave the middle bone uncovered."
            }
          ]
        }
      ]
    },
    {
      "label": "Holy Sites",
      "items": [
        {
          "title": "Masjid al-Haram, Makkah",
          "snippet": "Grand Mosque tips · Arrive 30 min early",
          "icon": "account_balance_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "🏨",
              "text": "Take a hotel card so you can find your way back."
            },
            {
              "emoji": "🚪",
              "text": "Identify the closest door to the Haram from your hotel."
            },
            {
              "emoji": "⏰",
              "text": "Arrive at least 30 min before salaah time to find a spot."
            },
            {
              "emoji": "🕌",
              "text": "For Jumu'ah, arrive no later than 10am in off-peak seasons."
            }
          ]
        },
        {
          "title": "Masjid an-Nabawi, Madinah",
          "snippet": "Rawdah booking · Respectful adab",
          "icon": "mosque_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "📱",
              "text": "Book Rawdah visit slots via the Nusuk app in advance."
            },
            {
              "emoji": "🤲",
              "text": "Make du'a quietly and avoid blocking walkways."
            },
            {
              "emoji": "👟",
              "text": "Wear comfortable shoes — you will walk significant distances."
            }
          ]
        },
        {
          "title": "Jannat al-Baqi",
          "snippet": "Visiting the blessed cemetery",
          "icon": "park_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "🕊️",
              "text": "Visit with humility and make du'a for the deceased companions."
            },
            {
              "emoji": "📵",
              "text": "Photography is discouraged — focus on reflection and prayer."
            }
          ]
        }
      ]
    },
    {
      "label": "Apps & Booking",
      "items": [
        {
          "title": "Nusuk App",
          "snippet": "Official Saudi pilgrimage platform",
          "icon": "smartphone_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "📲",
              "text": "Download Nusuk for Umrah permits, Rawdah slots, and transport."
            },
            {
              "emoji": "🪪",
              "text": "Link your passport and visa for seamless check-in."
            }
          ]
        },
        {
          "title": "Money & Payments",
          "snippet": "SAR cash · Cards widely accepted",
          "icon": "payments_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "💳",
              "text": "Major credit cards work in hotels and malls."
            },
            {
              "emoji": "💵",
              "text": "Keep some Saudi Riyals for taxis and small vendors."
            }
          ]
        },
        {
          "title": "Mobile & Internet",
          "snippet": "eSIM · Local SIM at airport",
          "icon": "wifi_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "📶",
              "text": "Purchase a local SIM or eSIM at the airport for maps and Nusuk."
            },
            {
              "emoji": "🔋",
              "text": "Carry a power bank — you will use your phone heavily."
            }
          ]
        },
        {
          "title": "Haramain Train",
          "snippet": "Makkah ↔ Madinah high-speed rail",
          "icon": "train_outlined",
          "kind": "emojiTips",
          "tips": [
            {
              "emoji": "🚄",
              "text": "Book train tickets early during peak Hajj and Ramadan seasons."
            },
            {
              "emoji": "🧳",
              "text": "Arrive at the station at least 60 minutes before departure."
            }
          ]
        }
      ]
    }
  ]
}$dq_logistics$::jsonb,
  'Logistics groups/items copy. Images remain on app_page_media.'
)
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value || public.app_settings.value,
  description = COALESCE(public.app_settings.description, EXCLUDED.description),
  updated_at = now();
