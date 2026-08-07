import 'dart:convert';

import 'package:http/http.dart' as http;

class SurahSummary {
  const SurahSummary({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.verses,
  });

  final int number;
  final String name;
  final String arabicName;
  final int verses;
}

class Ayah {
  const Ayah({
    required this.number,
    required this.arabic,
    required this.translation,
    this.surahNumber,
    this.surahName,
  });

  final int number;
  final String arabic;
  final String translation;
  final int? surahNumber;
  final String? surahName;
}

class JuzSummary {
  const JuzSummary({required this.number, required this.name});

  final int number;
  final String name;
}

class SearchResult {
  const SearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.snippet,
  });

  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String snippet;
}

abstract final class QuranService {
  static const _base = 'https://api.alquran.cloud/v1';

  static Future<List<SurahSummary>> fetchSurahs() async {
    final response = await http.get(Uri.parse('$_base/surah'));
    if (response.statusCode != 200) throw Exception('Failed to load surahs');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return SurahSummary(
        number: map['number'] as int,
        name: map['englishName'] as String,
        arabicName: map['name'] as String,
        verses: map['numberOfAyahs'] as int,
      );
    }).toList();
  }

  static Future<List<Ayah>> fetchSurahAyahs(int number) async {
    final response = await http.get(
      Uri.parse('$_base/surah/$number/editions/quran-uthmani,en.asad'),
    );
    if (response.statusCode != 200) throw Exception('Failed to load surah');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final editions = data['data'] as List<dynamic>;
    final arabic = editions[0]['ayahs'] as List<dynamic>;
    final english = editions[1]['ayahs'] as List<dynamic>;
    return List.generate(arabic.length, (i) {
      return Ayah(
        number: arabic[i]['numberInSurah'] as int,
        arabic: arabic[i]['text'] as String,
        translation: english[i]['text'] as String,
        surahNumber: number,
      );
    });
  }

  static Future<List<Ayah>> fetchJuzAyahs(int juzNumber) async {
    final response = await http.get(
      Uri.parse('$_base/juz/$juzNumber/editions/quran-uthmani,en.asad'),
    );
    if (response.statusCode != 200) throw Exception('Failed to load juz');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final editions = data['data'] as List<dynamic>;
    final arabic = editions[0]['ayahs'] as List<dynamic>;
    final english = editions[1]['ayahs'] as List<dynamic>;
    return List.generate(arabic.length, (i) {
      final surahNum = arabic[i]['surah']?['number'] as int? ?? 1;
      final surahName = arabic[i]['surah']?['englishName'] as String? ?? 'Surah $surahNum';
      return Ayah(
        number: arabic[i]['numberInSurah'] as int,
        arabic: arabic[i]['text'] as String,
        translation: english[i]['text'] as String,
        surahNumber: surahNum,
        surahName: surahName,
      );
    });
  }

  static List<JuzSummary> juzList() => List.generate(
        30,
        (i) => JuzSummary(number: i + 1, name: 'Juz ${i + 1}'),
      );

  static Future<List<SearchResult>> search(String query) async {
    if (query.trim().length < 2) return [];
    final encoded = Uri.encodeComponent(query.trim());
    final response = await http.get(Uri.parse('$_base/search/$encoded/all/en.asad'));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final matches = data['data']['matches'] as List<dynamic>? ?? [];
    return matches.take(40).map((item) {
      final map = item as Map<String, dynamic>;
      final surah = map['surah'] as Map<String, dynamic>;
      return SearchResult(
        surahNumber: surah['number'] as int,
        surahName: surah['englishName'] as String,
        ayahNumber: map['numberInSurah'] as int,
        snippet: map['text'] as String,
      );
    }).toList();
  }

  static List<SurahSummary> fallbackSurahs() => const [
        SurahSummary(number: 1, name: 'Al-Fatihah', arabicName: 'الفاتحة', verses: 7),
        SurahSummary(number: 2, name: 'Al-Baqarah', arabicName: 'البقرة', verses: 286),
        SurahSummary(number: 3, name: 'Ali Imran', arabicName: 'آل عمران', verses: 200),
        SurahSummary(number: 4, name: 'An-Nisa', arabicName: 'النساء', verses: 176),
        SurahSummary(number: 5, name: 'Al-Maidah', arabicName: 'المائدة', verses: 120),
      ];
}
