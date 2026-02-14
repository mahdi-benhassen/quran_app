import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../view_models/khatm_view_model.dart';
import '../../view_models/quran_view_model.dart';
import '../../data/models/surah.dart';
import 'surah_detail_screen.dart';

class KhatmScreen extends StatelessWidget {
  const KhatmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Khatm Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'reset') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Progress?'),
                    content: const Text(
                      'This will clear all your reading progress. Are you sure?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<KhatmViewModel>().resetProgress();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Reset Progress'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<KhatmViewModel, QuranViewModel>(
        builder: (context, khatmModel, quranModel, child) {
          return Column(
            children: [
              _buildProgressHeader(context, khatmModel),
              _buildContinueButton(context, khatmModel, quranModel),
              const SizedBox(height: 8),
              Expanded(
                child: _buildSurahChecklist(context, khatmModel, quranModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, KhatmViewModel model) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: model.progressPercent,
                    strokeWidth: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD54F),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${model.completedCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '/114',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khatm Al-Quran',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(model.progressPercent * 100).toStringAsFixed(1)}% Complete',
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${model.completionsInLast30Days} Khatms (30d)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${model.remainingCount} Surahs remaining',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (model.completedCount == 114) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showFinalizeDialog(context, model);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: const Color(0xFF1B5E20),
                    ),
                    icon: const Icon(Icons.stars),
                    label: const Text('Complete Khatm'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalizeDialog(BuildContext context, KhatmViewModel model) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mabrouk! 🎉'),
        content: const Text(
          'Congratulations on completing the full Quran! Would you like to record this Khatm and start a new one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              model.finalizeKhatm();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Khatm recorded! Starting new progress...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Record & Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    KhatmViewModel khatmModel,
    QuranViewModel quranModel,
  ) {
    final lastSurahNum = khatmModel.lastReadSurah;
    final surahs = quranModel.surahs;

    // Find the surah object
    Surah? lastSurah;
    try {
      lastSurah = surahs.firstWhere((s) => s.number == lastSurahNum);
    } catch (_) {
      lastSurah = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (lastSurah != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahDetailScreen(surah: lastSurah!),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue Reading',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        lastSurah != null
                            ? '${lastSurah.englishName} • Ayah ${khatmModel.lastReadAyah}'
                            : 'Start from Al-Fatiha',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahChecklist(
    BuildContext context,
    KhatmViewModel khatmModel,
    QuranViewModel quranModel,
  ) {
    final surahs = quranModel.surahs;
    if (surahs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isComplete = khatmModel.isSurahComplete(surah.number);

        return Card(
          elevation: isComplete ? 0 : 1,
          margin: const EdgeInsets.only(bottom: 6),
          color: isComplete ? const Color(0xFFE8F5E9) : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahDetailScreen(surah: surah),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => khatmModel.toggleSurah(surah.number),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isComplete
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[200],
                        border: Border.all(
                          color: isComplete
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isComplete
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Center(
                              child: Text(
                                '${surah.number}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Surah info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.englishName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: isComplete
                                ? TextDecoration.lineThrough
                                : null,
                            color: isComplete
                                ? Colors.grey[600]
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${surah.numberOfAyahs} Verses • ${surah.revelationType}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arabic name
                  Text(
                    surah.name,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: isComplete ? Colors.grey[400] : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
