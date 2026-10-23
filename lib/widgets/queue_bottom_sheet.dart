import 'dart:async';

import 'package:flutter/material.dart';

import '../services/player_controller.dart';
import 'common_widgets.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key, required this.player});

  final MusicPlayerController player;

  static Timer? _sleepTimer;

  Future<void> _showSleepTimer(BuildContext context) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sleep timer'),
        children: [
          for (final minutes in [5, 10, 15, 30, 45, 60])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, minutes),
              child: Text('$minutes minutes'),
            ),
          if (_sleepTimer?.isActive ?? false)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 0),
              child: const Text('Cancel timer'),
            ),
        ],
      ),
    );

    if (minutes == null) return;
    _sleepTimer?.cancel();
    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), player.pause);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.82;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xF21A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: player,
          builder: (context, child) {
            final currentSong = player.currentSong;
            final queue = player.queue;
            final upcoming = player.currentIndex >= 0
                ? queue.skip(player.currentIndex + 1).toList()
                : queue;

            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Queue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Playing ${currentSong?.album.isNotEmpty == true ? currentSong!.album : 'Liked Songs'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
                if (currentSong != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GradientArt(
                            gradient: currentSong.artGradient,
                            icon: currentSong.artIcon,
                            size: 48,
                            iconSize: 22,
                            borderRadius: 8,
                            imageUrl: currentSong.imageUrl,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: currentSong.artGradient.first,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  currentSong.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: player.togglePlayPause,
                            icon: Icon(
                              player.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: currentSong.artGradient.first,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        player.shuffleOn
                            ? Icons.shuffle_rounded
                            : Icons.queue_music_rounded,
                        color: player.shuffleOn
                            ? currentSong?.artGradient.first ?? Colors.white
                            : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        player.shuffleOn ? 'Shuffling from:' : 'Next In Queue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: upcoming.isEmpty
                      ? Center(
                          child: Text(
                            'No upcoming songs',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: upcoming.length,
                          itemBuilder: (context, index) {
                            final song = upcoming[index];
                            return ListTile(
                              key: ValueKey(song.id),
                              onTap: () {
                                player.playSong(song, playlist: queue);
                                Navigator.pop(context);
                              },
                              leading: GradientArt(
                                gradient: song.artGradient,
                                icon: song.artIcon,
                                size: 44,
                                iconSize: 20,
                                borderRadius: 8,
                                imageUrl: song.imageUrl,
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              trailing: Icon(
                                Icons.drag_handle_rounded,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QueueActionButton(
                          icon: Icons.shuffle_rounded,
                          label: 'Shuffle',
                          isActive: player.shuffleOn,
                          onPressed: player.toggleShuffle,
                          activeColor:
                              currentSong?.artGradient.first ?? Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QueueActionButton(
                          icon: Icons.timer_outlined,
                          label: 'Timer',
                          onPressed: () => _showSleepTimer(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QueueActionButton extends StatelessWidget {
  const _QueueActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.activeColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: isActive ? activeColor : Colors.white70),
      label: Text(
        label,
        style: TextStyle(color: isActive ? activeColor : Colors.white),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        side: BorderSide(
          color: isActive ? activeColor.withValues(alpha: 0.6) : Colors.white24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
