class Ayah {
  final int number;
  final String text; // Arabic text
  final String translation; // English translation
  final String audio; // Audio URL (if available directly or constructed)
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  Ayah({
    required this.number,
    required this.text,
    required this.translation,
    required this.audio,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  // Factory to create from two API responses (Arabic & English)
  // We assume both lists are sorted and matching in length/order.
  factory Ayah.fromEditions(
    Map<String, dynamic> arabicJson,
    Map<String, dynamic> translationJson,
  ) {
    // The audio might be in the arabicJson if we queried with audio edition,
    // but usually we query text editions and audio handles separately or the API gives audio in a specific edition.
    // For now, let's assume we might get audio or construct it.

    return Ayah(
      number: arabicJson['number'],
      text: arabicJson['text'],
      translation: translationJson['text'],
      audio:
          arabicJson['audio'] ?? '', // API 'ar.alafasy' edition includes audio
      numberInSurah: arabicJson['numberInSurah'],
      juz: arabicJson['juz'],
      manzil: arabicJson['manzil'],
      page: arabicJson['page'],
      ruku: arabicJson['ruku'],
      hizbQuarter: arabicJson['hizbQuarter'],
      sajda: arabicJson['sajda'] is bool
          ? arabicJson['sajda']
          : (arabicJson['sajda'] != false),
    );
  }
}
