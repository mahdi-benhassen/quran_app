import 'package:flutter/foundation.dart';
import '../data/models/surah.dart';
import '../data/models/ayah.dart';
import '../data/repositories/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repository;

  List<Surah> _surahs = [];
  List<Surah> get surahs => _surahs;
  List<Surah> _filteredSurahs = [];
  List<Surah> get filteredSurahs => _filteredSurahs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Cache for loaded Surah details to avoid re-fetching
  final Map<int, List<Ayah>> _surahDetailsCache = {};

  QuranViewModel(this._repository);

  Future<void> fetchSurahs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _surahs = await _repository.getAllSurahs();
      _filteredSurahs = _surahs;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchSurahs(String query) {
    if (query.isEmpty) {
      _filteredSurahs = _surahs;
    } else {
      _filteredSurahs = _surahs.where((surah) {
        return surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
            surah.englishNameTranslation.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            surah.name.contains(query) ||
            surah.number.toString() == query;
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Ayah>> getSurahDetails(int surahNumber) async {
    if (_surahDetailsCache.containsKey(surahNumber)) {
      return _surahDetailsCache[surahNumber]!;
    }

    try {
      final ayahs = await _repository.getSurahVerses(surahNumber);
      _surahDetailsCache[surahNumber] = ayahs;
      return ayahs;
    } catch (e) {
      rethrow;
    }
  }
}
