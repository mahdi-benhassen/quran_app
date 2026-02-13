import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

class ApiService {
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.surahListEndpoint),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahList = data['data'];
        return surahList.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Surahs');
      }
    } catch (e) {
      throw Exception('Error fetching Surahs: $e');
    }
  }

  Future<List<Ayah>> getSurahDetails(int surahNumber) async {
    try {
      // fetching quran-uthmani, en.asad, and ar.alafasy (for audio)
      // Note: Getting 3 editions might be heavy. Let's try 2 first: text + translation.
      // Audio is often a separate concern or included if we use the audio edition as base.
      // The Al Quran Cloud API allows fetching multiple editions.
      // Let's fetch quran-uthmani (Arabic), en.asad (Translation), ar.alafasy (Audio)

      final url =
          '${ApiConstants.baseUrl}/surah/$surahNumber/editions/${ApiConstants.arabicEdition},${ApiConstants.englishEdition},${ApiConstants.audioEdition}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> editions = data['data'];

        // Ensure we have 3 editions
        // Ensure we have 3 editions
        final arabicEdition = editions.firstWhere(
          (e) => e['edition']['identifier'] == ApiConstants.arabicEdition,
        );
        final englishEdition = editions.firstWhere(
          (e) => e['edition']['identifier'] == ApiConstants.englishEdition,
        );
        final audioEdition = editions.firstWhere(
          (e) => e['edition']['identifier'] == ApiConstants.audioEdition,
        );

        final List<dynamic> arabicAyahs = arabicEdition['ayahs'];
        final List<dynamic> englishAyahs = englishEdition['ayahs'];
        final List<dynamic> audioAyahs = audioEdition['ayahs'];

        List<Ayah> ayahs = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          // merge the data
          // We use audio from audioEdition
          Map<String, dynamic> ayahData = arabicAyahs[i];
          ayahData['audio'] = audioAyahs[i]['audio']; // inject audio url

          ayahs.add(Ayah.fromEditions(ayahData, englishAyahs[i]));
        }
        return ayahs;
      } else {
        throw Exception('Failed to load Surah details');
      }
    } catch (e) {
      throw Exception('Error fetching Surah details: $e');
    }
  }
}
