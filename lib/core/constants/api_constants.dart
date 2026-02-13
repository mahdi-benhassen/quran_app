class ApiConstants {
  static const String baseUrl = 'http://api.alquran.cloud/v1';
  static const String surahListEndpoint = '$baseUrl/surah';
  
  // Editions
  static const String arabicEdition = 'quran-uthmani';
  static const String englishEdition = 'en.asad';
  static const String audioEdition = 'ar.alafasy'; // For audio URLs

  static String getSurahDetails(int number) {
    return '$baseUrl/surah/$number/editions/$arabicEdition,$englishEdition';
  }
  
  static String getAudioUrl(int surahNumber, int ayahNumber) {
    // Example: https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3
    // Note: The API returns audio URLs in the response, but we can also construct them if needed.
    // For now, we'll rely on the API response which includes audio.
    return ''; 
  }
}
