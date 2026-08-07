# Store Screenshots

Capture screenshots on these device profiles for Play Store and App Store submission:

| Device | Resolution | Screens to capture |
|--------|------------|-------------------|
| Phone (6.7") | 1290×2796 | Home, Donate, Quran reader, Qibla, Saved |
| 7" tablet | 1200×1920 | Home (tablet layout), Quran, More |
| 10" tablet | 2048×2732 | Home (tablet layout), Donate checkout |

## Commands

```bash
flutter run -d <device_id>
# Navigate to each screen, then capture via device or:
flutter screenshot --out=store/screenshots/home_phone.png
```

Replace placeholder assets in `assets/icon/app_icon.png` with final brand artwork before submission.
