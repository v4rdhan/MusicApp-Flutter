import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);
    final song = player.currentSong;
    final screenSize = MediaQuery.sizeOf(context);
    final artworkSize = min(screenSize.width * 0.7, screenSize.height * 0.42);

    if (song == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: Text('No song playing',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (song.hasNetworkImage)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Image.network(
                song.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  song.artGradient.first.withOpacity(0.58),
                  const Color(0xFF0A0A0F).withOpacity(0.88),
                  const Color(0xFF0A0A0F),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // ─── Top bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const Expanded(
                      child: Text(
                        'NOW PLAYING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white70, size: 24),
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 16),

              // ─── Album Art ────────────────────────────────────────
              Hero(
                tag: 'album_art_${song.id}',
                child: GradientArt(
                  gradient: song.artGradient,
                  icon: song.artIcon,
                  size: artworkSize,
                  iconSize: artworkSize * 0.36,
                  borderRadius: 24,
                  imageUrl: song.imageUrl,
                ),
              ),

                  const SizedBox(height: 20),

              // ─── Song Info ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => player.toggleFavorite(song),
                      icon: Icon(
                        player.isFavorite(song)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: player.isFavorite(song)
                            ? const Color(0xFFE040FB)
                            : Colors.white60,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 16),

              // ─── Progress Bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16),
                        activeTrackColor: song.artGradient.first,
                        inactiveTrackColor: Colors.white.withOpacity(0.12),
                        thumbColor: Colors.white,
                        overlayColor:
                            song.artGradient.first.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: player.progress.clamp(0.0, 1.0),
                        onChanged: (v) => player.seekTo(v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(player.position),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(player.duration),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 8),

              // ─── Controls ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => player.toggleShuffle(),
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: player.shuffleOn
                            ? song.artGradient.first
                            : Colors.white54,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () => player.previous(),
                      icon: const Icon(Icons.skip_previous_rounded,
                          color: Colors.white, size: 36),
                    ),
                    // Play/Pause button
                    GestureDetector(
                      onTap: () => player.togglePlayPause(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: song.artGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: song.artGradient.first.withOpacity(0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          player.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => player.next(),
                      icon: const Icon(Icons.skip_next_rounded,
                          color: Colors.white, size: 36),
                    ),
                    IconButton(
                      onPressed: () => player.toggleRepeat(),
                      icon: Icon(
                        player.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: player.repeatMode != RepeatMode.off
                            ? song.artGradient.first
                            : Colors.white54,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 8),

              // ─── Volume ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Icon(Icons.volume_down_rounded,
                        color: Colors.white.withOpacity(0.5), size: 20),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12),
                          activeTrackColor: Colors.white.withOpacity(0.7),
                          inactiveTrackColor: Colors.white.withOpacity(0.12),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: player.volume,
                          onChanged: (v) => player.setVolume(v),
                        ),
                      ),
                    ),
                    Icon(Icons.volume_up_rounded,
                        color: Colors.white.withOpacity(0.5), size: 20),
                  ],
                ),
              ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
