import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Streams Quran recitation audio from EveryAyah CDN (per-ayah MP3s).
abstract final class QuranAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static StreamSubscription<void>? _completeSub;
  static final _ayahController = StreamController<int?>.broadcast();

  static int? _surah;
  static int? _ayah;
  static String? _surahName;
  static int? _lastAyahInSurah;
  static bool _autoAdvance = true;

  static int? get currentSurah => _surah;
  static int? get currentAyah => _ayah;
  static String? get currentSurahName => _surahName;

  /// Emits whenever the playing ayah changes (including null on stop).
  static Stream<int?> get currentAyahStream => _ayahController.stream;

  static Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  static PlayerState get playerState => _player.state;

  static bool get isPlaying => _player.state == PlayerState.playing;

  static bool get isPaused => _player.state == PlayerState.paused;

  static void _ensureCompleteListener() {
    if (_completeSub != null) return;
    _completeSub = _player.onPlayerComplete.listen((_) async {
      if (!_autoAdvance || _surah == null || _ayah == null) return;
      final next = _ayah! + 1;
      if (_lastAyahInSurah != null && next > _lastAyahInSurah!) {
        _setAyah(null);
        return;
      }
      try {
        await playAyah(
          surahNumber: _surah!,
          ayahNumber: next,
          surahName: _surahName,
          lastAyahInSurah: _lastAyahInSurah,
          autoAdvance: _autoAdvance,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Auto-advance failed: $e');
        _setAyah(null);
      }
    });
  }

  static void _setAyah(int? ayah) {
    _ayah = ayah;
    if (!_ayahController.isClosed) _ayahController.add(ayah);
  }

  /// Play a single ayah. When [lastAyahInSurah] is set and [autoAdvance] is true,
  /// playback continues to the next ayah until the end of the surah.
  static Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    String? surahName,
    int? lastAyahInSurah,
    bool autoAdvance = true,
  }) async {
    _ensureCompleteListener();
    final url = _urlFor(surahNumber, ayahNumber);
    _surah = surahNumber;
    if (surahName != null) _surahName = surahName;
    if (lastAyahInSurah != null) _lastAyahInSurah = lastAyahInSurah;
    _autoAdvance = autoAdvance;
    _setAyah(ayahNumber);
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      if (kDebugMode) debugPrint('Audio playback failed: $e');
      rethrow;
    }
  }

  /// Start (or continue) from [fromAyah] through the end of the surah.
  static Future<void> playFromAyah({
    required int surahNumber,
    required int fromAyah,
    required int lastAyahInSurah,
    String? surahName,
  }) {
    return playAyah(
      surahNumber: surahNumber,
      ayahNumber: fromAyah,
      surahName: surahName,
      lastAyahInSurah: lastAyahInSurah,
      autoAdvance: true,
    );
  }

  static Future<void> playSurah(
    int surahNumber, {
    String? surahName,
    int? lastAyahInSurah,
  }) =>
      playAyah(
        surahNumber: surahNumber,
        ayahNumber: 1,
        surahName: surahName,
        lastAyahInSurah: lastAyahInSurah,
        autoAdvance: true,
      );

  static Future<void> pause() => _player.pause();

  static Future<void> resume() => _player.resume();

  static Future<void> stop() async {
    await _player.stop();
    _setAyah(null);
  }

  /// Pause/resume if already on this surah; otherwise start from [fromAyah] (default 1).
  static Future<void> toggle({
    required int surahNumber,
    String? surahName,
    int fromAyah = 1,
    int? lastAyahInSurah,
  }) async {
    final state = _player.state;
    if (state == PlayerState.playing && _surah == surahNumber) {
      await pause();
      return;
    }
    if (state == PlayerState.paused && _surah == surahNumber) {
      await resume();
      return;
    }
    await playFromAyah(
      surahNumber: surahNumber,
      fromAyah: fromAyah,
      lastAyahInSurah: lastAyahInSurah ?? fromAyah,
      surahName: surahName,
    );
  }

  static String _urlFor(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  }
}
