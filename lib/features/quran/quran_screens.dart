import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/router/app_router.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/quran_audio_service.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/content_service.dart';
import '../../core/services/quran_service.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/utils/dq_refresh.dart';
import '../../shared/utils/haptics.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/figma_components.dart';

final quranSearchProvider = FutureProvider.family<List<SearchResult>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  return QuranService.search(query);
});

final surahListProvider = FutureProvider<List<SurahSummary>>((ref) async {
  try {
    return await QuranService.fetchSurahs();
  } catch (_) {
    return QuranService.fallbackSurahs();
  }
});

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

enum _QuranTab { surah, juz, bookmarks, topics }

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  _QuranTab _tab = _QuranTab.surah;
  String _query = '';
  bool _audioPlaying = false;
  StreamSubscription<PlayerState>? _audioSub;

  @override
  void initState() {
    super.initState();
    _audioPlaying = QuranAudioService.isPlaying;
    _audioSub = QuranAudioService.playerStateStream.listen((state) {
      if (mounted) setState(() => _audioPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() {
    return dqPullRefresh(
      ref,
      invalidate: [surahListProvider, quranTopicsProvider, bookmarkServiceProvider],
      awaitExtras: () async {
        await Future.wait([
          ref.read(surahListProvider.future),
          ref.read(quranTopicsProvider.future),
          ref.read(bookmarkServiceProvider.future),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);
    final bookmarksAsync = ref.watch(bookmarkServiceProvider);
    final topicsAsync = ref.watch(quranTopicsProvider);
    final progress = bookmarksAsync.maybeWhen(
      data: (s) => s.readingProgress,
      orElse: () => null,
    );
    final audioTitle = QuranAudioService.currentSurahName ??
        (QuranAudioService.currentSurah != null ? 'Surah ${QuranAudioService.currentSurah}' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Quran', style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DqSearchField(
            hint: 'Search surah, ayah or keyword',
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 12),
        if (progress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DqContinueReadingCard(
              surah: '${progress.surahName} · Ayah ${progress.ayahNumber}',
              ayah: '${progress.ayahNumber}',
              subtitle: 'Continue where you left off',
              onContinue: () => context.push(
                '/quran/reader',
                extra: QuranReaderArgs(
                  surahNumber: progress.surahNumber,
                  surahName: progress.surahName,
                  initialAyah: progress.ayahNumber,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DqContinueReadingCard(
              surah: 'Start reading',
              ayah: '1',
              subtitle: 'Open Surah Al-Fatihah',
              onContinue: () => context.push(
                '/quran/reader',
                extra: const QuranReaderArgs(surahNumber: 1, surahName: 'Al-Fatihah', initialAyah: 1),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (_query.length >= 2)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _searchResults(),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DqPillTabs<_QuranTab>(
              tabs: _QuranTab.values,
              selected: _tab,
              onSelected: (t) => setState(() => _tab = t),
              labelBuilder: (t) => switch (t) {
                _QuranTab.surah => 'Surah',
                _QuranTab.juz => 'Juz',
                _QuranTab.bookmarks => 'Bookmarks',
                _QuranTab.topics => 'Topics',
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _tabContent(context, surahsAsync, bookmarksAsync, topicsAsync),
            ),
          ),
        ],
        if (audioTitle != null)
          DqMiniAudioBar(
            title: audioTitle,
            reciter: 'Mishary Alafasy',
            playing: _audioPlaying,
            progress: _audioPlaying ? null : 0,
            onToggle: () async {
              final surah = QuranAudioService.currentSurah ?? progress?.surahNumber ?? 1;
              final name = QuranAudioService.currentSurahName ?? progress?.surahName;
              try {
                await QuranAudioService.toggle(surahNumber: surah, surahName: name);
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not play audio')),
                  );
                }
              }
            },
          ),
      ],
    );
  }

  Widget _tabContent(
    BuildContext context,
    AsyncValue<List<SurahSummary>> surahsAsync,
    AsyncValue<BookmarkService> bookmarksAsync,
    AsyncValue<List<QuranTopic>> topicsAsync,
  ) {
    return switch (_tab) {
      _QuranTab.surah => surahsAsync.when(
          loading: () => _scrollablePlaceholder(const DqLoadingOverlay(message: 'Loading surahs...')),
          error: (_, __) => _scrollablePlaceholder(
            const DqEmptyState(icon: Icons.cloud_off, title: 'Offline', message: 'Showing cached surah list.'),
          ),
          data: (surahs) {
            final filtered = surahs.where((s) => s.name.toLowerCase().contains(_query) || s.arabicName.contains(_query)).toList();
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = filtered[i];
                return DqSurahRow(
                  number: s.number,
                  nameEn: s.name,
                  nameAr: s.arabicName,
                  verses: s.verses,
                  onTap: () => context.push('/quran/reader', extra: QuranReaderArgs(surahNumber: s.number, surahName: s.name)),
                );
              },
            );
          },
        ),
      _QuranTab.juz => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          itemCount: QuranService.juzList().length,
          itemBuilder: (_, i) {
            final juz = QuranService.juzList()[i];
            return ListTile(
              title: Text(juz.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/quran/juz', extra: juz.number),
            );
          },
        ),
      _QuranTab.bookmarks => bookmarksAsync.when(
          loading: () => _scrollablePlaceholder(const DqLoadingOverlay()),
          error: (_, __) => _scrollablePlaceholder(
            const DqEmptyState(icon: Icons.bookmark_outline, title: 'No bookmarks', message: 'Bookmark ayahs while reading.'),
          ),
          data: (service) => service.bookmarks.isEmpty
              ? _scrollablePlaceholder(
                  const DqEmptyState(icon: Icons.bookmark_outline, title: 'No bookmarks', message: 'Bookmark ayahs while reading.'),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  itemCount: service.bookmarks.length,
                  itemBuilder: (_, i) {
                    final b = service.bookmarks[i];
                    return ListTile(
                      title: Text('${b.surahName} — Ayah ${b.ayahNumber}'),
                      onTap: () => context.push('/quran/reader', extra: QuranReaderArgs(surahNumber: b.surahNumber, surahName: b.surahName, initialAyah: b.ayahNumber)),
                    );
                  },
                ),
        ),
      _QuranTab.topics => topicsAsync.when(
          loading: () => _scrollablePlaceholder(const DqLoadingOverlay(message: 'Loading topics...')),
          error: (_, __) => _topicsList(context, ContentService.quranTopics),
          data: (topics) => _topicsList(context, topics),
        ),
    };
  }

  Widget _scrollablePlaceholder(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 160, child: child),
      ],
    );
  }

  Widget _searchResults() {
    final resultsAsync = ref.watch(quranSearchProvider(_query));
    return resultsAsync.when(
      loading: () => _scrollablePlaceholder(const DqLoadingOverlay(message: 'Searching Quran...')),
      error: (_, __) => _scrollablePlaceholder(
        const DqEmptyState(icon: Icons.search_off, title: 'Search unavailable', message: 'Check your connection and try again.'),
      ),
      data: (results) {
        if (results.isEmpty) {
          return _scrollablePlaceholder(
            const DqEmptyState(icon: Icons.search, title: 'No results', message: 'Try a different keyword.'),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: results.length,
          itemBuilder: (_, i) {
            final r = results[i];
            return ListTile(
              title: Text('${r.surahName} — Ayah ${r.ayahNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(r.snippet, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () => context.push('/quran/reader', extra: QuranReaderArgs(surahNumber: r.surahNumber, surahName: r.surahName, initialAyah: r.ayahNumber)),
            );
          },
        );
      },
    );
  }

  Widget _topicsList(BuildContext context, List<QuranTopic> topics) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: topics.length,
      itemBuilder: (_, i) {
        final topic = topics[i];
        return DqCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(topic.description, style: TextStyle(color: context.dq.muted, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: topic.surahNumbers.map((n) {
                  return ActionChip(
                    label: Text('Surah $n'),
                    onPressed: () => context.push('/quran/reader', extra: QuranReaderArgs(surahNumber: n, surahName: 'Surah $n')),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

}

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialAyah,
  });

  final int surahNumber;
  final String surahName;
  final int? initialAyah;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  double _fontSize = 24;
  bool _playing = false;
  bool _showTranslation = true;
  int? _selectedAyah;
  int? _playingAyah;
  final _scrollController = ScrollController();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<int?>? _ayahSub;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _selectedAyah = widget.initialAyah;
    _playingAyah = QuranAudioService.currentSurah == widget.surahNumber
        ? QuranAudioService.currentAyah
        : null;
    _playing = QuranAudioService.isPlaying &&
        QuranAudioService.currentSurah == widget.surahNumber;

    _stateSub = QuranAudioService.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playing = state == PlayerState.playing &&
            QuranAudioService.currentSurah == widget.surahNumber;
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          if (QuranAudioService.currentAyah == null) _playingAyah = null;
        }
      });
    });
    _ayahSub = QuranAudioService.currentAyahStream.listen((ayah) {
      if (!mounted) return;
      if (QuranAudioService.currentSurah != widget.surahNumber) return;
      setState(() {
        _playingAyah = ayah;
        if (ayah != null) _selectedAyah = ayah;
      });
      _scrollToAyah(ayah);
      if (ayah != null) unawaited(_persistProgress(ayah));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistProgress(widget.initialAyah ?? 1);
    });
  }

  Future<void> _persistProgress(int ayahNumber) async {
    final service = await ref.read(bookmarkServiceProvider.future);
    await service.saveReadingProgress(ReadingProgress(
      surahNumber: widget.surahNumber,
      surahName: widget.surahName,
      ayahNumber: ayahNumber,
    ));
    ref.invalidate(bookmarkServiceProvider);
  }

  void _scrollToAyah(int? ayahNumber) {
    if (ayahNumber == null || !_scrollController.hasClients) return;
    final ayahs = ref.read(_ayahProvider(widget.surahNumber)).valueOrNull;
    if (ayahs == null) return;
    final index = ayahs.indexWhere((a) => a.number == ayahNumber);
    if (index < 0) return;
    final target = (index * 140.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _playAyah(int ayahNumber, {required int lastAyah}) async {
    setState(() {
      _selectedAyah = ayahNumber;
      _playingAyah = ayahNumber;
    });
    try {
      await QuranAudioService.playFromAyah(
        surahNumber: widget.surahNumber,
        fromAyah: ayahNumber,
        lastAyahInSurah: lastAyah,
        surahName: widget.surahName,
      );
      await DqHaptics.light();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play this ayah')),
        );
      }
    }
  }

  Future<void> _toggleListen({required int lastAyah}) async {
    try {
      if (_playing) {
        await QuranAudioService.pause();
        return;
      }
      if (QuranAudioService.isPaused &&
          QuranAudioService.currentSurah == widget.surahNumber) {
        await QuranAudioService.resume();
        return;
      }
      final from = _selectedAyah ?? _playingAyah ?? widget.initialAyah ?? 1;
      await QuranAudioService.playFromAyah(
        surahNumber: widget.surahNumber,
        fromAyah: from,
        lastAyahInSurah: lastAyah,
        surahName: widget.surahName,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _ayahSub?.cancel();
    // Keep audio playing when leaving? Plan said dispose stops — keep stop for focus.
    QuranAudioService.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(_ayahProvider(widget.surahNumber));
    final textColor = context.colors.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  DqBackButton(onPressed: () => context.pop()),
                  Expanded(
                    child: Text(widget.surahName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  ),
                  Semantics(
                    label: 'Toggle translation',
                    button: true,
                    child: IconButton(
                      onPressed: () => setState(() => _showTranslation = !_showTranslation),
                      icon: Icon(_showTranslation ? Icons.translate : Icons.translate_outlined, color: textColor),
                    ),
                  ),
                  Semantics(
                    label: 'Increase font size',
                    button: true,
                    child: IconButton(
                      onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(18, 36)),
                      icon: Icon(Icons.text_increase, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            if (_playingAyah != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Playing ayah $_playingAyah — tap any verse to start from there',
                  style: TextStyle(fontSize: 12, color: context.dq.muted),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Tap a verse to select and listen',
                  style: TextStyle(fontSize: 12, color: context.dq.muted),
                ),
              ),
            Expanded(
              child: ayahsAsync.when(
                loading: () => const DqLoadingOverlay(message: 'Loading surah...'),
                error: (_, __) => const DqEmptyState(icon: Icons.error_outline, title: 'Could not load', message: 'Check your connection and try again.'),
                data: (ayahs) {
                  if (!_didInitialScroll && widget.initialAyah != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _didInitialScroll = true;
                      final index = ayahs.indexWhere((a) => a.number == widget.initialAyah);
                      if (index > 0 && _scrollController.hasClients) {
                        _scrollController.jumpTo(
                          (index * 140.0).clamp(0.0, _scrollController.position.maxScrollExtent),
                        );
                      }
                    });
                  }
                  final lastAyah = ayahs.isEmpty ? 1 : ayahs.last.number;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: ayahs.length,
                    itemBuilder: (_, i) {
                      final ayah = ayahs[i];
                      final isPlaying = _playingAyah == ayah.number;
                      final isSelected = _selectedAyah == ayah.number;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: isPlaying
                              ? context.colors.secondary.withValues(alpha: 0.12)
                              : isSelected
                                  ? context.colors.secondary.withValues(alpha: 0.06)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _playAyah(ayah.number, lastAyah: lastAyah),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPlaying
                                              ? context.colors.secondary
                                              : context.dq.surfaceAlt,
                                        ),
                                        child: Text(
                                          '${ayah.number}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isPlaying ? Colors.white : textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          ayah.arabic,
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.amiri(
                                            fontSize: _fontSize,
                                            height: 2,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: isPlaying ? 'Playing' : 'Play ayah',
                                        onPressed: () => _playAyah(ayah.number, lastAyah: lastAyah),
                                        icon: Icon(
                                          isPlaying ? Icons.volume_up : Icons.play_arrow_rounded,
                                          color: context.colors.secondary,
                                          size: 22,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Bookmark ayah',
                                        onPressed: () => _bookmarkAyah(ayah.number),
                                        icon: Icon(Icons.bookmark_outline, color: context.colors.secondary, size: 20),
                                      ),
                                    ],
                                  ),
                                  if (_showTranslation) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${ayah.number}. ${ayah.translation}',
                                      style: TextStyle(fontSize: 14, color: context.dq.muted, height: 1.6),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.dq.cardBorder)),
              ),
              child: ayahsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (ayahs) {
                  final lastAyah = ayahs.isEmpty ? 1 : ayahs.last.number;
                  final listenLabel = _playing
                      ? 'Pause'
                      : (_selectedAyah != null ? 'Listen from $_selectedAyah' : 'Listen');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _action(
                        _playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        listenLabel,
                        () => _toggleListen(lastAyah: lastAyah),
                      ),
                      _action(
                        Icons.share_outlined,
                        'Share',
                        () => Share.share(
                          _selectedAyah != null
                              ? 'Reading ${widget.surahName} ayah $_selectedAyah on Donate Quran'
                              : 'Reading ${widget.surahName} on Donate Quran',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookmarkAyah(int ayahNumber) async {
    final service = await ref.read(bookmarkServiceProvider.future);
    await service.addBookmark(Bookmark(
      surahName: widget.surahName,
      surahNumber: widget.surahNumber,
      ayahNumber: ayahNumber,
      savedAt: DateTime.now(),
    ));
    await service.saveReadingProgress(ReadingProgress(
      surahNumber: widget.surahNumber,
      surahName: widget.surahName,
      ayahNumber: ayahNumber,
    ));
    ref.invalidate(bookmarkServiceProvider);
    await DqHaptics.light();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bookmarked ayah $ayahNumber')));
    }
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: context.colors.onSurface, size: 22),
            Text(label, style: TextStyle(fontSize: 11, color: context.colors.onSurface)),
          ],
        ),
      ),
    );
  }
}

final _ayahProvider = FutureProvider.family<List<Ayah>, int>((ref, surahNumber) {
  return QuranService.fetchSurahAyahs(surahNumber);
});

class JuzReaderScreen extends ConsumerWidget {
  const JuzReaderScreen({super.key, required this.juzNumber});

  final int juzNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(_juzProvider(juzNumber));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Juz $juzNumber', onBack: () => context.pop()),
            Expanded(
              child: ayahsAsync.when(
                loading: () => const DqLoadingOverlay(message: 'Loading juz...'),
                error: (_, __) => const DqEmptyState(icon: Icons.error_outline, title: 'Could not load juz', message: 'Check your connection.'),
                data: (ayahs) => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: ayahs.length,
                  itemBuilder: (_, i) {
                    final ayah = ayahs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${ayah.surahName} · Ayah ${ayah.number}', style: TextStyle(color: context.dq.muted, fontSize: 12)),
                          Text(ayah.arabic, textAlign: TextAlign.right, style: GoogleFonts.amiri(fontSize: 22, height: 2)),
                          const SizedBox(height: 6),
                          Text(ayah.translation, style: TextStyle(color: context.dq.muted, fontSize: 13)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _juzProvider = FutureProvider.family<List<Ayah>, int>((ref, juzNumber) {
  return QuranService.fetchJuzAyahs(juzNumber);
});
