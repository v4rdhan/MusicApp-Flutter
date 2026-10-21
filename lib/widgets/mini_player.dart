import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  static const double _miniHeight = 72;
  static const double _navigationHeight = 59;
  static const double _fadeExtent = 0.28;
  static const double _flingVelocity = 700;

  late final AnimationController _extent = AnimationController(
    vsync: this,
    value: 0,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _expandedFade = CurvedAnimation(
    parent: _extent,
    curve: const Interval(0, _fadeExtent),
  );
  late final Animation<double> _miniFade = ReverseAnimation(_expandedFade);

  void _dragStart(DragStartDetails details) {
    _extent.stop(canceled: true);
  }

  void _dragUpdate(DragUpdateDetails details, double travelRange) {
    _extent.value =
        (_extent.value - details.delta.dy / travelRange).clamp(0.0, 1.0).toDouble();
  }

  void _dragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -_flingVelocity) {
      _expand();
    } else if (velocity > _flingVelocity) {
      _collapse();
    } else {
      _snap(_extent.value >= 0.5);
    }
  }

  void _dragCancel() => _snap(_extent.value >= 0.5);

  void _expand() => _snap(true);

  void _collapse() => _snap(false);

  void _snap(bool expanded) {
    _extent.stop(canceled: true);
    _extent.animateTo(
      expanded ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.read(context);

    return ValueListenableBuilder<Song?>(
      valueListenable: player.currentSongListenable,
      builder: (context, song, _) {
        if (song == null) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final navigationHeight =
                _navigationHeight + MediaQuery.paddingOf(context).bottom;
            final travelRange = (constraints.maxHeight -
                    navigationHeight -
                    _miniHeight)
                .clamp(1.0, constraints.maxHeight)
                .toDouble();
            final nowPlaying = NowPlayingScreen(
              onCollapse: _collapse,
              onDragStart: _dragStart,
              onDragUpdate: (details) => _dragUpdate(details, travelRange),
              onDragEnd: _dragEnd,
              onDragCancel: _dragCancel,
            );
            final miniHeader = _MiniPlayerHeader(
              onTap: _expand,
              onDragStart: _dragStart,
              onDragUpdate: (details) => _dragUpdate(details, travelRange),
              onDragEnd: _dragEnd,
              onDragCancel: _dragCancel,
            );

            final layers = Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _extent,
                  child: FadeTransition(
                    opacity: _expandedFade,
                    child: RepaintBoundary(child: nowPlaying),
                  ),
                  builder: (context, child) {
                    final top = travelRange * (1 - _extent.value);
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: -top,
                      height: constraints.maxHeight,
                      child: IgnorePointer(
                        ignoring: _extent.value < 1,
                        child: child,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: _miniHeight,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _extent,
                    child: FadeTransition(
                      opacity: _miniFade,
                      child: miniHeader,
                    ),
                    builder: (context, extent, child) => IgnorePointer(
                      ignoring: extent >= 1,
                      child: child,
                    ),
                  ),
                ),
              ],
            );

            return AnimatedBuilder(
              animation: _extent,
              child: layers,
              builder: (context, child) {
                final extent = _extent.value;
                final panelHeight = _miniHeight +
                    (constraints.maxHeight - _miniHeight) * extent;
                final panelBottom = navigationHeight * (1 - extent);
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: panelBottom,
                      height: panelHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18 * (1 - extent)),
                        ),
                        child: child,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MiniPlayerHeader extends StatelessWidget {
  const _MiniPlayerHeader({
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final VoidCallback onTap;
  final ValueChanged<DragStartDetails> onDragStart;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.read(context);

    return ListenableBuilder(
      listenable: player,
      builder: (context, child) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();
        final progress = player.progress.isFinite
            ? player.progress.clamp(0.0, 1.0).toDouble()
            : 0.0;

        return GestureDetector(
          onTap: onTap,
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          onVerticalDragCancel: onDragCancel,
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1A2E),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                      child: Row(
                        children: [
                          GradientArt(
                            gradient: song.artGradient,
                            icon: song.artIcon,
                            size: 44,
                            iconSize: 20,
                            borderRadius: 10,
                            imageUrl: song.imageUrl,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                            onPressed: player.togglePlayPause,
                            icon: Icon(
                              player.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
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
