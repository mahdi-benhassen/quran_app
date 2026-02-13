import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/ayah.dart';

class AudioViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Ayah? _currentAyah;
  Ayah? get currentAyah => _currentAyah;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _position = Duration.zero;
  Duration get position => _position;

  List<Ayah> _playlist = [];
  int _currentIndex = -1;

  AudioViewModel() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _position = Duration.zero;
        _onPlayerCompletion();
      }
    });
  }

  Future<void> playSurah(List<Ayah> ayahs, {int startIndex = 0}) async {
    _playlist = ayahs;
    _currentIndex = startIndex;
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length) {
      await playAyah(_playlist[_currentIndex]);
    }
  }

  Future<void> playAyah(Ayah ayah) async {
    try {
      _currentAyah = ayah;
      // If we are playing a single ayah not from playlist flow, update index if possible
      if (_playlist.contains(ayah)) {
        _currentIndex = _playlist.indexOf(ayah);
      } else {
        // standalone play, clear playlist? or set single
        // let's keep playlist but maybe reset current index logic if needed
        // For simplicity, just play.
      }

      notifyListeners();

      if (ayah.audio.isNotEmpty) {
        await _player.setUrl(ayah.audio);
        await _player.play();
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void _onPlayerCompletion() {
    if (_currentIndex != -1 && _currentIndex < _playlist.length - 1) {
      _currentIndex++;
      playAyah(_playlist[_currentIndex]);
    } else {
      _isPlaying = false;
      _currentIndex = -1;
      // _currentAyah = null; // Optional: keep last ayah shown
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
