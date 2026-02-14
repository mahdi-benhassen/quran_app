import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../view_models/quran_view_model.dart';
import '../../view_models/khatm_view_model.dart';
import '../../data/models/surah.dart';
import 'surah_detail_screen.dart';
import 'settings_screen.dart';
import 'khatm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quran Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SurahSearchDelegate());
            },
          ),
          Consumer<KhatmViewModel>(
            builder: (context, khatmModel, _) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KhatmScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${khatmModel.completedCount}/114',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (khatmModel.completionsInLast30Days > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '✕${khatmModel.completionsInLast30Days}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
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
      body: Consumer<QuranViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.surahs.isEmpty) {
            return _buildShimmerLoading();
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  ElevatedButton(
                    onPressed: viewModel.fetchSurahs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.filteredSurahs.length,
            itemBuilder: (context, index) {
              final surah = viewModel.filteredSurahs[index];
              return _buildSurahCard(context, surah);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah) {
    final isComplete = context.watch<KhatmViewModel>().isSurahComplete(
      surah.number,
    );

    return Card(
      elevation: isComplete ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isComplete ? const Color(0xFFE8F5E9) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailScreen(surah: surah),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete
                      ? const Color(0xFF4CAF50)
                      : AppColors.primary.withOpacity(0.1),
                ),
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${surah.number}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isComplete ? Colors.grey[600] : null,
                      ),
                    ),
                    Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Verses',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                surah.name,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  color: isComplete ? Colors.grey[400] : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurahSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          context.read<QuranViewModel>().searchSurahs('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    context.read<QuranViewModel>().searchSurahs(query);
    return const SizedBox(); // Results are shown in the main list if we strictly follow the viewmodel filter
    // But SearchDelegate usually wants its own view.
    // For simplicity, let's just trigger the search in ViewModel and show nothing here,
    // OR duplicate the list view here.
    // Let's implement a simple list view here.
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final viewModel = context.watch<QuranViewModel>();
    final suggestions = viewModel.surahs.where((surah) {
      return surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
          surah.englishNameTranslation.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          surah.name.contains(query);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final surah = suggestions[index];
        return ListTile(
          title: Text(surah.englishName),
          subtitle: Text(surah.englishNameTranslation),
          trailing: Text(
            surah.name,
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(surah: surah),
              ),
            );
          },
        );
      },
    );
  }
}
