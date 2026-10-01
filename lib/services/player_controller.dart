import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'audio_handler.dart';

class MusicPlayerController extends ChangeNotifier {
  final AudioPlayerHandler _audioHandler;

  MusicPlayerController({required AudioPlayerHandler audioHandler})
      : _audioHandler = audioHandler {
    _listenToAudioStreams();
  }

  // ─── Internal State ─────────────────────────────────────────────────────
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.75;
  bool _shuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _isBuffering = false;
  final List<Song> _favorites = [];
  final List<Song> _recentlyPlayed = [];

  // Stream subscriptions
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<ProcessingState>? _processingSub;
  StreamSubscription<dynamic>? _customEventSub;

  // ─── Getters ───────────────────────────────────────────────────────────
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get shuffleOn => _shuffleOn;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get favorites => _favorites;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  bool get hasSong => _currentSong != null;
  bool get isBuffering => _isBuffering;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // ─── Stream Listeners ──────────────────────────────────────────────────

  void _listenToAudioStreams() {
    // Position updates
    _positionSub = _audioHandler.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Duration updates (changes when a new track loads)
    _durationSub = _audioHandler.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    // Playing state
    _playingSub = _audioHandler.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    // Processing state (buffering, completed, etc.)
    _processingSub = _audioHandler.processingStateStream.listen((state) {
      _isBuffering =
          state == ProcessingState.loading ||
          state == ProcessingState.buffering;

      if (state == ProcessingState.completed) {
        _handleTrackCompletion();
      }
      notifyListeners();
    });

    // Custom events from notification controls (skipToNext, skipToPrevious)
    _customEventSub = _audioHandler.customEvent.listen((event) {
      if (event == 'skipToNext') {
        next();
      } else if (event == 'skipToPrevious') {
        previous();
      }
    });
  }

  void _handleTrackCompletion() {
    if (_repeatMode == RepeatMode.one) {
      // Replay the same song
      if (_currentSong != null) {
        _audioHandler.seek(Duration.zero);
        _audioHandler.play();
      }
    } else {
      next();
    }
  }

  // ─── Play Controls ────────────────────────────────────────────────────

  void playSong(Song song, {List<Song>? playlist}) {
    _currentSong = song;

    if (playlist != null) {
      _queue = List.from(playlist);
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    } else {
      _queue = [song];
      _currentIndex = 0;
    }

    _addToRecentlyPlayed(song);
    _audioHandler.playSong(song);
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong == null) return;
    if (_isPlaying) {
      _audioHandler.pause();
    } else {
      _audioHandler.play();
    }
  }

  void pause() {
    _audioHandler.pause();
  }

  void resume() {
    if (_currentSong == null) return;
    _audioHandler.play();
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
    _addToRecentlyPlayed(_currentSong!);
    _audioHandler.playSong(_currentSong!);
    notifyListeners();
  }

  void previous() {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current song
    if (_position.inSeconds > 3) {
      seekTo(0.0);
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        _currentIndex = 0;
        seekTo(0.0);
        return;
      }
    }

    _currentSong = _queue[_currentIndex];
    _addToRecentlyPlayed(_currentSong!);
    _audioHandler.playSong(_currentSong!);
    notifyListeners();
  }

  void seekTo(double value) {
    if (_duration.inMilliseconds == 0) return;
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    _audioHandler.seek(position);
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _audioHandler.setVolume(_volume);
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

  // ─── Cleanup ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _processingSub?.cancel();
    _customEventSub?.cancel();
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
