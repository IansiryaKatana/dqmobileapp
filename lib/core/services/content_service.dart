class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.topic,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String topic;
}

class QuranTopic {
  const QuranTopic({required this.name, required this.description, required this.surahNumbers});

  final String name;
  final String description;
  final List<int> surahNumbers;
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

abstract final class ContentService {
  static const articles = [
    Article(
      id: 'fatihah',
      title: 'Understanding Surah Al-Fatihah',
      summary: 'The opening chapter and its significance.',
      topic: 'Quran',
      body: '''
Surah Al-Fatihah is the opening chapter of the Quran and is recited in every unit of Muslim prayer.

It summarizes the core relationship between the worshipper and Allah: praise, seeking guidance, and asking for the straight path.

Reflect on each verse slowly. Many scholars describe Al-Fatihah as a summary of the entire Quran.
''',
    ),
    Article(
      id: 'pillars',
      title: 'The Five Pillars of Islam',
      summary: 'Foundation of Muslim practice.',
      topic: 'Faith',
      body: '''
The five pillars are the framework of Muslim life:

1. Shahada — declaration of faith
2. Salah — prayer five times daily
3. Zakat — charitable giving
4. Sawm — fasting in Ramadan
5. Hajj — pilgrimage for those able

Each pillar connects belief with action and community responsibility.
''',
    ),
    Article(
      id: 'wudu-intro',
      title: 'Introduction to Wudu',
      summary: 'Purification before prayer.',
      topic: 'Prayer',
      body: '''
Wudu is the ritual washing performed before prayer. It prepares the body and heart for standing before Allah.

The essential steps include washing the hands, rinsing the mouth and nose, washing the face and arms, wiping the head, and washing the feet.

Use the in-app Wudu Guide for a step-by-step walkthrough with illustrations.
''',
    ),
    Article(
      id: 'new-muslim-prayer',
      title: 'Learning to Pray as a New Muslim',
      summary: 'A gentle starting guide.',
      topic: 'New Muslim',
      body: '''
Learning to pray takes time and patience. Start with one prayer — often Maghrib or Fajr — and learn its movements and recitations.

Use a printed guide or the New Muslim section in this app. Ask a scholar if you are unsure about any step.

Allah rewards sincere effort. Consistency matters more than perfection on day one.
''',
    ),
  ];

  static const books = [
    Article(
      id: 'book-new-muslim',
      title: 'New Muslim Guide',
      summary: 'Essential first steps in Islam.',
      topic: 'Books',
      body: 'A curated path covering belief, prayer, Quran, and community — available through Donate Quran Learn.',
    ),
    Article(
      id: 'book-wudu',
      title: 'Wudu & Purification',
      summary: 'Complete purification guide.',
      topic: 'Books',
      body: 'Step-by-step wudu with common questions answered for new Muslims.',
    ),
  ];

  static const quranTopics = [
    QuranTopic(
      name: 'Mercy & Compassion',
      description: 'Surahs highlighting Allah\'s mercy',
      surahNumbers: [1, 55, 93],
    ),
    QuranTopic(
      name: 'Patience & Trials',
      description: 'Strength through difficulty',
      surahNumbers: [2, 12, 94],
    ),
    QuranTopic(
      name: 'Prayer & Worship',
      description: 'Guidance on salah and devotion',
      surahNumbers: [1, 87, 103],
    ),
    QuranTopic(
      name: 'Stories of Prophets',
      description: 'Lessons from earlier nations',
      surahNumbers: [12, 19, 21],
    ),
  ];

  static const faq = [
    FaqItem(
      question: 'Where does my donation go?',
      answer: 'Donations fund Quran printing and distribution. If you pay through the App Store or Play Store, those stores may deduct a processing fee; the remainder goes to printing.',
    ),
    FaqItem(
      question: 'Is the Quran really free?',
      answer: 'Yes, Quran copies are free. Postage and packaging may apply for orders.',
    ),
    FaqItem(
      question: 'How long does delivery take?',
      answer: 'Typically 5–10 business days depending on your location.',
    ),
  ];

  static Article? articleById(String id) {
    for (final a in [...articles, ...books]) {
      if (a.id == id) return a;
    }
    return null;
  }
}
