import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

/// Bridges [just_audio]'s [AudioPlayer] with [audio_service]'s
/// [BaseAudioHandler] so playback continues in the background and
/// exposes notification/lock-screen/Bluetooth media controls.
class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // ─── State exposed to the rest of the app ───────────────────────────────
  Song? _currentAppSong;
  Song? get currentAppSong => _currentAppSong;

  /// Stream that emits the current [Song] (app model) whenever it changes.
  final _currentSongController = StreamController<Song?>.broadcast();
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  // ─── Constructor ────────────────────────────────────────────────────────

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // Configure audio session for music playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Broadcast just_audio's playback state → audio_service's playbackState
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Auto-advance or handle completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // Notify audio_service that the item completed
        // The controller's next() logic will handle queue advancement
      }
    });
  }

  // ─── Public API for the app ─────────────────────────────────────────────

  /// Loads and plays a [Song] from its download URL.
  Future<void> playSong(Song song) async {
    _currentAppSong = song;
    _currentSongController.add(song);

    // Build the MediaItem for notification/lock-screen
    final item = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: song.hasNetworkImage ? Uri.parse(song.imageUrl!) : null,
    );
    mediaItem.add(item);

    // Load and play the audio stream
    if (song.hasDownloadUrl) {
      try {
        await _player.setUrl(song.downloadUrl!);
        _player.play();
      } catch (e) {
        // If streaming fails, the UI will show an error via playback state
        // ignore: avoid_print
        print('AudioPlayerHandler: Failed to load URL: $e');
      }
    }
  }

  // ─── BaseAudioHandler overrides (called by system media controls) ──────

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    // Handled by MusicPlayerController.next() which calls playSong()
    // This is invoked by notification controls — we emit a custom event
    // that the controller listens to.
    customEvent.add('skipToNext');
  }

  @override
  Future<void> skipToPrevious() async {
    customEvent.add('skipToPrevious');
  }

  // ─── Getters for UI binding ─────────────────────────────────────────────

  /// The underlying just_audio player (for direct stream access).
  AudioPlayer get player => _player;

  /// Whether the player is currently playing.
  bool get isPlaying => _player.playing;

  /// Current playback position.
  Duration get position => _player.position;

  /// Total duration of the current track.
  Duration get duration => _player.duration ?? Duration.zero;

  /// Stream of position updates.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration updates.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of playing state.
  Stream<bool> get playingStream => _player.playingStream;

  /// Stream of buffered position.
  Stream<Duration> get bufferedPositionStream =>
      _player.bufferedPositionStream;

  /// Stream of processing state (loading, buffering, ready, completed).
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Volume (0.0 to 1.0).
  double get volume => _player.volume;

  /// Set volume.
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // ─── Cleanup ────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _player.dispose();
    await _currentSongController.close();
  }

  // ─── Private helpers ────────────────────────────────────────────────────

  /// Transforms just_audio's [PlaybackEvent] into audio_service's
  /// [PlaybackState] for notification/lock-screen controls.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
