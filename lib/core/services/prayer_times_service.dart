import 'dart:convert';

import 'package:http/http.dart' as http;

class PrayerTimes {
  const PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;

  List<(String, String)> get entries => [
        ('Fajr', fajr),
        ('Dhuhr', dhuhr),
        ('Asr', asr),
        ('Maghrib', maghrib),
        ('Isha', isha),
      ];
}

abstract final class PrayerTimesService {
  static Future<PrayerTimes> fetch({required double latitude, required double longitude}) async {
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/${DateTime.now().millisecondsSinceEpoch ~/ 1000}'
      '?latitude=$latitude&longitude=$longitude&method=2',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) throw Exception('Failed to load prayer times');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final timings = data['data']['timings'] as Map<String, dynamic>;
    final date = data['data']['date']['readable'] as String;
    String clean(String key) => (timings[key] as String).split(' ').first;
    return PrayerTimes(
      fajr: clean('Fajr'),
      dhuhr: clean('Dhuhr'),
      asr: clean('Asr'),
      maghrib: clean('Maghrib'),
      isha: clean('Isha'),
      date: date,
    );
  }
}
