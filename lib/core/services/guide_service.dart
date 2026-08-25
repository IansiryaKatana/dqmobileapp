import '../constants/app_assets.dart';
import 'pilgrimage_guide_fallbacks.dart';

class GuideHubCopy {
  const GuideHubCopy({
    required this.eyebrow,
    required this.title,
    required this.disclaimer,
    this.ayahAr = '',
    this.ayahEn = '',
    this.ayahRef = '',
  });

  final String eyebrow;
  final String title;
  final String disclaimer;
  final String ayahAr;
  final String ayahEn;
  final String ayahRef;
}

class GuideSection {
  const GuideSection({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.hubGroup,
    required this.route,
  });

  final String slug;
  final String title;
  final String subtitle;
  final String badge;
  final String icon;
  final String hubGroup;
  final String route;
}

class GuideStep {
  const GuideStep({
    required this.title,
    required this.body,
    this.imageAsset,
    this.sortOrder = 0,
    this.subtitle = '',
    this.description = '',
    this.arabic,
    this.arabicEn,
    this.icon = '',
    this.iconUrl,
    this.repeatLabel,
    this.timeLabel,
    this.rakaat,
    this.accent,
  });

  final String title;
  final String body;
  final String? imageAsset;
  final int sortOrder;
  final String subtitle;
  final String description;
  final String? arabic;
  final String? arabicEn;
  final String icon;
  final String? iconUrl;
  final String? repeatLabel;
  final String? timeLabel;
  final int? rakaat;
  final String? accent;
}

abstract final class GuideService {
  static const hub = GuideHubCopy(
    eyebrow: 'Seeking the Pleasure of Allah',
    title: 'Umrah & Hajj Guide',
    disclaimer:
        'All guides are based on authentic scholarly sources. Always consult a qualified scholar for personal rulings.',
    ayahAr: 'وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ',
    ayahEn: 'Complete the Hajj and Umrah for Allah',
    ayahRef: '2:196',
  );

  static const sections = [
    GuideSection(
      slug: 'umrah',
      title: 'Umrah Guide',
      subtitle: "Rituals, du'as & essential tips",
      badge: 'Step by Step',
      icon: 'mosque',
      hubGroup: 'journey',
      route: '/guide/umrah',
    ),
    GuideSection(
      slug: 'hajj',
      title: 'Hajj Guide',
      subtitle: 'Pillars, locations & rituals',
      badge: 'Step by Step',
      icon: 'landscape',
      hubGroup: 'journey',
      route: '/guide/hajj',
    ),
    GuideSection(
      slug: 'spiritual-preparation',
      title: 'Spiritual Preparation',
      subtitle: 'Prepare your heart before travel',
      badge: '',
      icon: 'volunteer_activism',
      hubGroup: 'explore',
      route: '/guide/spiritual-preparation',
    ),
    GuideSection(
      slug: 'visiting-madinah',
      title: 'Visiting Madinah',
      subtitle: 'Adab and visits in the blessed city',
      badge: '',
      icon: 'location_city',
      hubGroup: 'explore',
      route: '/guide/visiting-madinah',
    ),
    GuideSection(
      slug: 'logistics',
      title: 'Logistics',
      subtitle: 'Travel, documents & packing',
      badge: '',
      icon: 'luggage',
      hubGroup: 'explore',
      route: '/logistics',
    ),
    GuideSection(
      slug: 'faq',
      title: 'FAQ',
      subtitle: 'Common pilgrimage questions',
      badge: '',
      icon: 'quiz',
      hubGroup: 'explore',
      route: '/faq',
    ),
  ];

  static const stepsBySlug = {
    'umrah': PilgrimageGuideFallbacks.umrah,
    'hajj': PilgrimageGuideFallbacks.hajj,
    'spiritual-preparation': [
      GuideStep(
        title: 'Renew your intention',
        body:
            "Purify your niyyah: seek Allah's pleasure alone, not praise or social media. Write your personal du'a list before departure.",
      ),
      GuideStep(
        title: 'Learn essential du\'as',
        body:
            'Memorise or save Talbiyah, entering the Haram, Tawaf, Sa\'i, and Arafah du\'as. Keep a small printed or offline copy.',
      ),
      GuideStep(
        title: 'Seek forgiveness',
        body:
            'Repent sincerely and settle debts or grudges where possible. Ask loved ones for pardon before travelling.',
      ),
      GuideStep(
        title: 'Increase worship at home',
        body:
            'Pray on time, read Quran daily, and give charity in the weeks before travel so your heart is already inclined to worship.',
      ),
      GuideStep(
        title: 'Study the rituals',
        body:
            'Understand the order of Umrah or Hajj rites from a trusted teacher or app guide so you are not learning only on the ground.',
      ),
      GuideStep(
        title: 'Prepare patience',
        body:
            'Crowds, heat, and delays are part of the journey. Expect hardship and intend sabr for the sake of Allah.',
      ),
    ],
    'visiting-madinah': [
      GuideStep(
        title: 'Enter with adab',
        body:
            'Approach Madinah with humility, abundant salawat upon the Prophet ﷺ, and awareness that you are a guest in the illuminated city.',
      ),
      GuideStep(
        title: 'Pray in Masjid an-Nabawi',
        body:
            'Give priority to obligatory prayers in congregation. The reward for prayer in this mosque is multiplied — plan your schedule around salah.',
      ),
      GuideStep(
        title: 'Visit the Rawdah if possible',
        body:
            "The area between the Prophet's ﷺ pulpit and grave is from the gardens of Paradise. Book permitted visiting slots when required and maintain calm.",
      ),
      GuideStep(
        title: "Send salawat at the Prophet's ﷺ grave",
        body:
            'Stand facing the grave with adab, not raising the voice. Greet the Prophet ﷺ, Abu Bakr and Umar (may Allah be pleased with them) with the prescribed phrases.',
      ),
      GuideStep(
        title: 'Pray at Masjid Quba',
        body:
            'If you can, pray two rak\'ahs in Masjid Quba — the first mosque built in Islam — following the Sunnah of the Prophet ﷺ.',
      ),
      GuideStep(
        title: 'Visit Uhud with reflection',
        body:
            'Remember the martyrs of Uhud, especially Hamzah (may Allah be pleased with him). Make du\'a and take lessons in loyalty and sacrifice.',
      ),
    ],
    'logistics': [
      GuideStep(
        title: 'Documents and visa',
        body:
            'Ensure passport validity (often six months beyond travel), approved visa, vaccination records if required, and printed copies of bookings.',
        imageAsset: AppAssets.logisticsVisa,
      ),
      GuideStep(
        title: 'Flights and transfers',
        body:
            'Confirm arrival city (Jeddah or Madinah), baggage allowance for ihram and gifts, and group pickup arrangements.',
        imageAsset: AppAssets.logisticsHaram,
      ),
      GuideStep(
        title: 'Accommodation',
        body:
            'Save hotel addresses in Arabic and English, note proximity to Haram gates, and share location with family at home.',
        imageAsset: AppAssets.logisticsNabawi,
      ),
      GuideStep(
        title: 'Ihram and clothing',
        body:
            'Pack two sets of ihram if possible, safety pins, sandals that expose ankles, and a waist pouch for essentials.',
        imageAsset: AppAssets.logisticsIhram,
      ),
      GuideStep(
        title: 'Health and comfort',
        body:
            'Carry prescribed medicines, rehydration salts, unscented soap for ihram, and a light foldable mat or prayer garment.',
        imageAsset: AppAssets.logisticsJannat,
      ),
      GuideStep(
        title: 'Money and connectivity',
        body:
            "Use a mix of cards and cash (Saudi riyal). Download offline maps, Quran, and du'a apps before departure.",
        imageAsset: AppAssets.logisticsNusuk,
      ),
    ],
  };

  static List<GuideSection> journeySections() =>
      sections.where((s) => s.hubGroup == 'journey').toList();

  static List<GuideSection> exploreSections() =>
      sections.where((s) => s.hubGroup == 'explore').toList();

  static GuideSection? sectionBySlug(String slug) {
    for (final s in sections) {
      if (s.slug == slug) return s;
    }
    return null;
  }

  static List<GuideStep> stepsFor(String slug) =>
      stepsBySlug[slug] ?? const [];
}
