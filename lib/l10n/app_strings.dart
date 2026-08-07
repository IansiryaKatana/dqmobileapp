import 'package:flutter/material.dart';

/// Lightweight UI strings.
///
/// Limitation: only a small set of labels are translated. Most screens still
/// use hardcoded English. Arabic/Urdu selection applies RTL via [isRtl] in app.dart.
class AppStrings {
  const AppStrings(this.language);

  final String language;

  bool get isRtl => language == 'Arabic' || language == 'Urdu';

  String get appName => _t('Donate Quran', 'تبرع بالقرآن', 'قرآن عطیہ');
  String get home => _t('Home', 'الرئيسية', 'ہوم');
  String get donate => _t('Donate', 'تبرع', 'عطیہ');
  String get order => _t('Order', 'اطلب', 'آرڈر');
  String get quran => _t('Quran', 'القرآن', 'قرآن');
  String get saved => _t('Saved', 'المحفوظ', 'محفوظ');
  String get more => _t('More', 'المزيد', 'مزید');
  String get signIn => _t('Sign In', 'تسجيل الدخول', 'سائن ان');
  String get continueReading => _t('Continue Reading', 'تابع القراءة', 'پڑھنا جاری رکھیں');

  String _t(String en, String ar, String ur) {
    return switch (language) {
      'Arabic' => ar,
      'Urdu' => ur,
      _ => en,
    };
  }
}

extension AppStringsContext on BuildContext {
  AppStrings strings(String language) => AppStrings(language);
}
