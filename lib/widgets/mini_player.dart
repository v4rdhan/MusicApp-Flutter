import 'package:flutter/material.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);
    final song = player.currentSong;

    if (song == null) return const SizedBox.shrink();
    final progress =
        player.progress.isFinite ? player.progress.clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const NowPlayingScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A2E),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 2.5,
                child: CustomPaint(
                  painter: _MiniPlayerProgressPainter(
                    progress: progress,
                    color: song.artGradient.first,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Row(
                  children: [
                    Hero(
                      tag: 'album_art_${song.id}',
                      child: GradientArt(
                        gradient: song.artGradient,
                        icon: song.artIcon,
                        size: 44,
                        iconSize: 20,
                        borderRadius: 10,
                        imageUrl: song.imageUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => player.togglePlayPause(),
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerProgressPainter extends CustomPainter {
  const _MiniPlayerProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniPlayerProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}
