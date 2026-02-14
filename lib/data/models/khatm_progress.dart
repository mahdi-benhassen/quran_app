import 'dart:convert';

class KhatmProgress {
  final Set<int> completedSurahs;
  int lastReadSurah;
  int lastReadAyah;
  final DateTime startDate;
  DateTime? targetDate;
  final List<DateTime> completionHistory;

  KhatmProgress({
    Set<int>? completedSurahs,
    this.lastReadSurah = 1,
    this.lastReadAyah = 1,
    DateTime? startDate,
    this.targetDate,
    List<DateTime>? completionHistory,
  }) : completedSurahs = completedSurahs ?? {},
       startDate = startDate ?? DateTime.now(),
       completionHistory = completionHistory ?? [];

  double get progressPercent => completedSurahs.length / 114.0;

  int get completedCount => completedSurahs.length;

  int get remainingCount => 114 - completedSurahs.length;

  bool isSurahComplete(int surahNumber) =>
      completedSurahs.contains(surahNumber);

  int get completionsInLast30Days {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return completionHistory
        .where((date) => date.isAfter(thirtyDaysAgo))
        .length;
  }

  int get daysRemaining {
    if (targetDate == null) return 0;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  int get dailyTarget {
    if (daysRemaining == 0) return remainingCount;
    return (remainingCount / daysRemaining).ceil();
  }

  Map<String, dynamic> toJson() => {
    'completedSurahs': completedSurahs.toList(),
    'lastReadSurah': lastReadSurah,
    'lastReadAyah': lastReadAyah,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
    'completionHistory': completionHistory
        .map((e) => e.toIso8601String())
        .toList(),
  };

  factory KhatmProgress.fromJson(Map<String, dynamic> json) {
    return KhatmProgress(
      completedSurahs: (json['completedSurahs'] as List<dynamic>)
          .map((e) => e as int)
          .toSet(),
      lastReadSurah: json['lastReadSurah'] ?? 1,
      lastReadAyah: json['lastReadAyah'] ?? 1,
      startDate: DateTime.parse(json['startDate']),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      completionHistory:
          (json['completionHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory KhatmProgress.fromJsonString(String jsonString) {
    return KhatmProgress.fromJson(jsonDecode(jsonString));
  }
}
