import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';

class QuranRepository {
  final ApiService _apiService;

  QuranRepository(this._apiService);

  Future<List<Surah>> getAllSurahs() async {
    return await _apiService.getSurahs();
  }

  Future<List<Ayah>> getSurahVerses(int surahNumber) async {
    return await _apiService.getSurahDetails(surahNumber);
  }
}
