import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/sample_data.dart';

class MusicPlayerController extends ChangeNotifier {
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  double _volume = 0.75;
  bool _shuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.off;
  Timer? _timer;
  final List<Song> _favorites = [];
  final List<Song> _recentlyPlayed = [];

  // ─── Getters ───────────────────────────────────────────────────────────
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _currentSong?.duration ?? Duration.zero;
  double get volume => _volume;
  bool get shuffleOn => _shuffleOn;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get favorites => _favorites;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  bool get hasSong => _currentSong != null;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / duration.inMilliseconds;
  }

  // ─── Play Controls ────────────────────────────────────────────────────
  void playSong(Song song, {List<Song>? playlist}) {
    _currentSong = song;
    _position = Duration.zero;
    _isPlaying = true;

    if (playlist != null) {
      _queue = List.from(playlist);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    } else {
      _queue = [song];
      _currentIndex = 0;
    }

    _addToRecentlyPlayed(song);
    _startTimer();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _stopTimer();
    }
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _stopTimer();
    notifyListeners();
  }

  void resume() {
    if (_currentSong == null) return;
    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty) return;

    if (_shuffleOn) {
      final rng = Random();
      _currentIndex = rng.nextInt(_queue.length);
    } else {
      _currentIndex++;
      if (_currentIndex >= _queue.length) {
        if (_repeatMode == RepeatMode.all) {
          _currentIndex = 0;
        } else {
          _currentIndex = _queue.length - 1;
          pause();
          return;
        }
      }
    }

    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _isPlaying = true;
    _addToRecentlyPlayed(_currentSong!);
    _startTimer();
    notifyListeners();
  }

  void previous() {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current song
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        _currentIndex = 0;
        _position = Duration.zero;
        notifyListeners();
        return;
      }
    }

    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _isPlaying = true;
    _addToRecentlyPlayed(_currentSong!);
    _startTimer();
    notifyListeners();
  }

  void seekTo(double value) {
    if (_currentSong == null) return;
    _position = Duration(
      milliseconds: (value * duration.inMilliseconds).round(),
    );
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffleOn = !_shuffleOn;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────────────
  bool isFavorite(Song song) => _favorites.any((s) => s.id == song.id);

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    notifyListeners();
  }

  // ─── Recently Played ─────────────────────────────────────────────────
  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed.removeLast();
    }
  }

  // ─── Timer (simulates playback) ───────────────────────────────────────
  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isPlaying || _currentSong == null) return;

      _position += const Duration(milliseconds: 200);

      if (_position >= duration) {
        if (_repeatMode == RepeatMode.one) {
          _position = Duration.zero;
        } else {
          next();
          return;
        }
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// ─── InheritedWidget for access ─────────────────────────────────────────
class MusicPlayerProvider extends InheritedNotifier<MusicPlayerController> {
  const MusicPlayerProvider({
    super.key,
    required MusicPlayerController controller,
    required super.child,
  }) : super(notifier: controller);

  static MusicPlayerController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MusicPlayerProvider>()!
        .notifier!;
  }
}
