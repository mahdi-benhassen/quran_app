import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/khatm_progress.dart';

class KhatmViewModel extends ChangeNotifier {
  static const String _storageKey = 'khatm_progress';

  KhatmProgress _progress = KhatmProgress();
  KhatmProgress get progress => _progress;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  KhatmViewModel() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        _progress = KhatmProgress.fromJsonString(jsonString);
      }
    } catch (e) {
      print('Error loading khatm progress: $e');
      _progress = KhatmProgress();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _progress.toJsonString());
  }

  void markSurahComplete(int surahNumber) {
    _progress.completedSurahs.add(surahNumber);
    notifyListeners();
    _saveProgress();
  }

  void markSurahIncomplete(int surahNumber) {
    _progress.completedSurahs.remove(surahNumber);
    notifyListeners();
    _saveProgress();
  }

  void toggleSurah(int surahNumber) {
    if (_progress.isSurahComplete(surahNumber)) {
      markSurahIncomplete(surahNumber);
    } else {
      markSurahComplete(surahNumber);
    }
  }

  void setLastRead(int surahNumber, int ayahNumber) {
    _progress.lastReadSurah = surahNumber;
    _progress.lastReadAyah = ayahNumber;
    notifyListeners();
    _saveProgress();
  }

  void setTargetDate(DateTime? date) {
    _progress.targetDate = date;
    notifyListeners();
    _saveProgress();
  }

  Future<void> resetProgress() async {
    _progress = KhatmProgress();
    notifyListeners();
    await _saveProgress();
  }

  bool isSurahComplete(int surahNumber) =>
      _progress.isSurahComplete(surahNumber);

  double get progressPercent => _progress.progressPercent;
  int get completedCount => _progress.completedCount;
  int get remainingCount => _progress.remainingCount;
  int get lastReadSurah => _progress.lastReadSurah;
  int get lastReadAyah => _progress.lastReadAyah;
}
