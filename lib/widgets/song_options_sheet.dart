import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/song.dart';
import '../services/player_controller.dart';
import 'common_widgets.dart';

Future<void> showSongOptionsSheet(BuildContext context, Song song) {
  final player = MusicPlayerProvider.read(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SongOptionsSheet(song: song, player: player),
  );
}

class _SongOptionsSheet extends StatelessWidget {
  const _SongOptionsSheet({required this.song, required this.player});

  final Song song;
  final MusicPlayerController player;

  Future<void> _choosePlaylist(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (pickerContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Add to playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final playlist in allPlaylists)
              ListTile(
                leading: Icon(
                  playlist.songIds.contains(song.id)
                      ? Icons.check_circle_rounded
                      : Icons.playlist_play_rounded,
                  color: playlist.songIds.contains(song.id)
                      ? const Color(0xFF6C63FF)
                      : Colors.white70,
                ),
                title: Text(
                  playlist.title,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  player.addSongToPlaylist(playlist, song);
                  Navigator.pop(pickerContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to ${playlist.title}')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Remove from favorites?'),
        content: Text('Remove "${song.title}" from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      player.toggleFavorite(song);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF21A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    GradientArt(
                      gradient: song.artGradient,
                      icon: song.artIcon,
                      size: 48,
                      iconSize: 22,
                      borderRadius: 8,
                      imageUrl: song.imageUrl,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${song.artist} • ${song.album}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 0.5, color: Colors.grey.shade800, height: 1),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('Add to playlist'),
                onTap: () => _choosePlaylist(context),
              ),
              ListTile(
                leading: const Icon(Icons.queue_music_rounded),
                title: const Text('Add to queue'),
                onTap: () {
                  player.addToQueue(song);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${song.title} to queue')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Remove from favorites'),
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                onTap: () => _confirmRemove(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
