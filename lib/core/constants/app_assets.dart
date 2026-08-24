/// Central asset paths — keep in sync with [pubspec.yaml] and Figma exports.
abstract final class AppAssets {
  static const logoWordmark = 'assets/images/app_icon.png';
  static const appIcon = 'assets/images/app_icon.png';
  static const onboardingBg = 'assets/images/donate_quran_bg.png';
  /// Home banner + order product fallback (Donate Quran product shot).
  static const quranBookshot = 'assets/images/donate_quran_product.png';
  static const kaabaIcon = 'assets/icons/kaaba.svg';

  static const logisticsVisa = 'assets/images/logistics_visa.jpg';
  static const logisticsIhram = 'assets/images/logistics_ihram.jpg';
  static const logisticsHaram = 'assets/images/logistics_haram.jpg';
  static const logisticsNabawi = 'assets/images/logistics_nabawi.jpg';
  static const logisticsJannat = 'assets/images/logistics_jannat.jpg';
  static const logisticsNusuk = 'assets/images/logistics_nusuk.jpg';

  static const wuduBismillah = 'assets/images/wudu_bismillah.png';

  /// App Media `wudu.{slot}` keys, in guide step order.
  static const wuduStepSlots = [
    'bismillah',
    'hands',
    'mouth',
    'nose',
    'face',
    'arms',
    'head',
    'ears',
    'feet',
    'closing',
  ];

  /// App Media `pray-*.{slot}` keys shared across Fajr–Isha.
  static const prayStepSlots = [
    'intention',
    'takbir',
    'qiyam',
    'ruku',
    'itidal',
    'sujud',
    'jalsa',
    'sujud2',
    'tashahhud',
    'salam',
  ];

  static const prayGuideSlugs = {
    'fajr': 'pray-fajr',
    'dhuhr': 'pray-dhuhr',
    'asr': 'pray-asr',
    'maghrib': 'pray-maghrib',
    'isha': 'pray-isha',
  };

  static String? prayGuideSlugForName(String name) {
    final key = name.toLowerCase().trim();
    return prayGuideSlugs[key];
  }

  static String wuduSlotFor({required int stepNumber, required String title}) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized.contains('bismillah')) return 'bismillah';
    if (normalized.contains('hand')) return 'hands';
    if (normalized.contains('mouth')) return 'mouth';
    if (normalized.contains('nose') || normalized.contains('nostril')) return 'nose';
    if (normalized.contains('face')) return 'face';
    if (normalized.contains('arm') || normalized.contains('elbow')) return 'arms';
    if (normalized.contains('head') || normalized.contains('hair')) return 'head';
    if (normalized.contains('ear')) return 'ears';
    if (normalized.contains('foot') || normalized.contains('feet') || normalized.contains('ankle')) {
      return 'feet';
    }
    if (normalized.contains('clos') || normalized.contains('dua') || normalized.contains('shahada')) {
      return 'closing';
    }
    final i = stepNumber - 1;
    if (i >= 0 && i < wuduStepSlots.length) return wuduStepSlots[i];
    return wuduStepSlots.first;
  }

  static String praySlotFor({required int stepNumber, required String title}) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized.contains('intention') || normalized.contains('niyyah')) return 'intention';
    if (normalized.contains('takbir')) return 'takbir';
    if (normalized.contains('qiyam') || normalized.contains('standing') || normalized.contains('fatihah')) {
      return 'qiyam';
    }
    if (normalized.contains('ruku') || normalized.contains('bow')) return 'ruku';
    if (normalized.contains('itidal') || normalized.contains('afterruku')) return 'itidal';
    if (normalized.contains('jalsa') || normalized.contains('between')) return 'jalsa';
    if (normalized.contains('second') && normalized.contains('sujud')) return 'sujud2';
    if (normalized.contains('sujud') || normalized.contains('prostrat')) {
      return stepNumber >= 8 ? 'sujud2' : 'sujud';
    }
    if (normalized.contains('tashahhud') || normalized.contains('sitting')) return 'tashahhud';
    if (normalized.contains('salam') || normalized.contains('ending')) return 'salam';
    final i = stepNumber - 1;
    if (i >= 0 && i < prayStepSlots.length) return prayStepSlots[i];
    return prayStepSlots.first;
  }
}
