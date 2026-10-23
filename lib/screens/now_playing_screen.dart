import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/song.dart' as models;
import '../services/player_controller.dart';
import '../widgets/queue_bottom_sheet.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
    super.key,
    this.onCollapse,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
  });

  final VoidCallback? onCollapse;
  final ValueChanged<DragStartDetails>? onDragStart;
  final ValueChanged<DragUpdateDetails>? onDragUpdate;
  final ValueChanged<DragEndDetails>? onDragEnd;
  final VoidCallback? onDragCancel;

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _fallbackArtwork(models.Song song) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: song.artGradient),
      ),
      child: Center(
        child: Icon(
          song.artIcon,
          color: Colors.white.withOpacity(0.9),
          size: 72,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.read(context);
    final song = player.currentSong;

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
            bottom: false,
            child: Column(
              children: [
                // ─── Draggable upper zone (header + artwork + title) ───
                Expanded(
                  flex: 7,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragStart: onDragStart,
                    onVerticalDragUpdate: onDragUpdate,
                    onVerticalDragEnd: onDragEnd,
                    onVerticalDragCancel: onDragCancel,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed:
                                    onCollapse ?? () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Playing from Playlist',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      song.album.isEmpty
                                          ? 'Liked Songs'
                                          : song.album,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Hero(
                                  tag: 'album_art_${song.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: song.hasNetworkImage
                                        ? Image.network(
                                            song.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _fallbackArtwork(song),
                                          )
                                        : _fallbackArtwork(song),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListenableBuilder(
                                listenable: player,
                                builder: (context, child) => IconButton(
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Controls zone (slider + playback buttons) ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListenableBuilder(
                        listenable: player,
                        builder: (context, child) => Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackShape:
                                    const _FullWidthSliderTrackShape(),
                                trackHeight: 3.5,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5.5),
                                overlayShape:
                                    const RoundSliderOverlayShape(
                                        overlayRadius: 12),
                                activeTrackColor: song.artGradient.first,
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.12),
                                thumbColor: Colors.white,
                                overlayColor: song.artGradient.first
                                    .withOpacity(0.2),
                              ),
                              child: Slider(
                                value: player.progress.clamp(0.0, 1.0),
                                onChanged: player.seekTo,
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: player,
                        builder: (context, child) => Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: player.toggleShuffle,
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: player.shuffleOn
                                    ? song.artGradient.first
                                    : Colors.white54,
                              ),
                            ),
                            IconButton(
                              onPressed: player.previous,
                              icon: const Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                  size: 32),
                            ),
                            GestureDetector(
                              onTap: player.togglePlayPause,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: song.artGradient,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: song.artGradient.first
                                          .withOpacity(0.45),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  player.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: player.next,
                              icon: const Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                  size: 32),
                            ),
                            IconButton(
                              onPressed: player.toggleRepeat,
                              icon: Icon(
                                player.repeatMode == models.RepeatMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                color:
                                    player.repeatMode != models.RepeatMode.off
                                        ? song.artGradient.first
                                        : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.devices_outlined),
                          color: Colors.white70,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined),
                              color: Colors.white70,
                            ),
                            IconButton(
                              onPressed: () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    QueueBottomSheet(player: player),
                              ),
                              icon: const Icon(Icons.queue_music_outlined),
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullWidthSliderTrackShape extends RectangularSliderTrackShape {
  const _FullWidthSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width,
      trackHeight,
    );
  }
}
