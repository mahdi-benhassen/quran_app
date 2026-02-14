import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/surah.dart';
import '../../data/models/ayah.dart';
import '../../view_models/quran_view_model.dart';
import '../../view_models/audio_view_model.dart';
import '../../view_models/settings_view_model.dart';
import 'settings_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranViewModel>().getSurahDetails(widget.surah.number);

      // Listen to audio changes and scroll to current ayah
      context.read<AudioViewModel>().addListener(_scrollToCurrentAyah);
    });
  }

  void _scrollToCurrentAyah() {
    final audioModel = context.read<AudioViewModel>();
    if (audioModel.currentAyah != null && _scrollController.isAttached) {
      final currentAyah = audioModel.currentAyah!;
      // Index is numberInSurah (1-indexed), so we use it directly for the list (which has bismillah at index 0)
      final scrollIndex =
          currentAyah.numberInSurah; // This accounts for bismillah at index 0

      _scrollController.scrollTo(
        index: scrollIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position item 20% from top of viewport
      );
    }
  }

  @override
  void dispose() {
    context.read<AudioViewModel>().removeListener(_scrollToCurrentAyah);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopInfo(),
          Expanded(
            child: Consumer<QuranViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // We need to check if details are loaded for THIS surah
                // The ViewModel caches them.
                // We should probably expose a "currentSurahDetails" or similar,
                // OR use a FutureBuilder here if we want to be cleaner.
                // But ViewModel pattern implies we check the state.
                // Let's use a FutureBuilder wrapping the ViewModel call for simplicity in this specific view
                // OR just access the cache if we expose it, but ViewModel encapsulates it.
                // Let's rely on FutureBuilder for the async call setup in initState,
                // but actually, we called it in initState. ViewModel should have a state for "loading details".
                // The current `isLoading` in ViewModel is global. That's a flaw.
                // Better: Use FutureBuilder.

                return FutureBuilder<List<Ayah>>(
                  future: viewModel.getSurahDetails(widget.surah.number),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No verses found'));
                    }

                    final ayahs = snapshot.data!;
                    return ScrollablePositionedList.separated(
                      itemScrollController: _scrollController,
                      itemPositionsListener: _positionsListener,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          ayahs.length +
                          1, // +1 for Bismillah if needed, or just header
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildBismillah(widget.surah.number);
                        }
                        final ayah = ayahs[index - 1];
                        return _buildAyahItem(ayah, () {
                          // Check if already playing this ayah, toggle pause
                          final audioModel = context.read<AudioViewModel>();
                          if (audioModel.currentAyah == ayah &&
                              audioModel.isPlaying) {
                            audioModel.pause();
                          } else {
                            audioModel.playSurah(ayahs, startIndex: index - 1);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildTopInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Text(
            widget.surah.name,
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            '${widget.surah.revelationType} • ${widget.surah.numberOfAyahs} Verses',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah(int surahNumber) {
    if (surahNumber == 1 || surahNumber == 9) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      alignment: Alignment.center,
      child: Image.network(
        'https://islamic.network/assets/img/bismillah.png', // Or use text
        color: AppColors.textPrimary,
        height: 50,
        errorBuilder: (_, __, ___) => Text(
          "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
          style: GoogleFonts.amiri(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAyahItem(Ayah ayah, VoidCallback onPlay) {
    return Consumer2<AudioViewModel, SettingsViewModel>(
      builder: (context, audioModel, settingsModel, child) {
        final isPlaying =
            audioModel.currentAyah?.number == ayah.number &&
            audioModel.isPlaying;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPlaying
                    ? AppColors.secondary.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 30,
                          color: AppColors.primary,
                        ),
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ayah.text,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: settingsModel.arabicFontSize,
                height: 2.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ayah.translation,
              textAlign: TextAlign.left,
              style: GoogleFonts.lato(
                fontSize: settingsModel.translationFontSize,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return Consumer<AudioViewModel>(
      builder: (context, audioModel, child) {
        if (audioModel.currentAyah == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  audioModel.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  if (audioModel.isPlaying) {
                    audioModel.pause();
                  } else {
                    audioModel.playAyah(audioModel.currentAyah!);
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Surah ${widget.surah.englishName} : Ayah ${audioModel.currentAyah?.numberInSurah}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    LinearProgressIndicator(
                      value: audioModel.duration.inMilliseconds > 0
                          ? audioModel.position.inMilliseconds /
                                audioModel.duration.inMilliseconds
                          : 0.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
