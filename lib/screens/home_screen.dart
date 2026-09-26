import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ─── Header ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What do you want to listen to?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Featured Hero Card ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: GestureDetector(
              onTap: () {
                final playlist = getSongsByIds(allPlaylists[2].songIds);
                if (playlist.isNotEmpty) {
                  player.playSong(playlist.first, playlist: playlist);
                }
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.headphones_rounded,
                          size: 150,
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '✦  FEATURED PLAYLIST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Late Night Drives',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cruise through the city • 5 songs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ─── Quick Picks (Grid) ───────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Quick Picks'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = allSongs[index];
                final isCurrentSong =
                    player.currentSong?.id == song.id && player.isPlaying;
                return GestureDetector(
                  onTap: () =>
                      player.playSong(song, playlist: allSongs),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: isCurrentSong
                            ? song.artGradient.first.withOpacity(0.5)
                            : Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(9),
                              bottomLeft: Radius.circular(9),
                            ),
                            gradient: LinearGradient(
                              colors: song.artGradient,
                            ),
                          ),
                          child: Icon(song.artIcon,
                              color: Colors.white.withOpacity(0.85),
                              size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            song.title,
                            style: TextStyle(
                              color: isCurrentSong
                                  ? song.artGradient.first
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                );
              },
              childCount: 6,
            ),
          ),
        ),

        // ─── Recently Played ──────────────────────────────────────
        if (player.recentlyPlayed.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Recently Played'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 195,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20),
                itemCount: player.recentlyPlayed.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final song = player.recentlyPlayed[index];
                  return HorizontalCard(
                    gradient: song.artGradient,
                    icon: song.artIcon,
                    title: song.title,
                    subtitle: song.artist,
                    onTap: () => player.playSong(song, playlist: player.recentlyPlayed),
                  );
                },
              ),
            ),
          ),
        ],

        // ─── Made For You (Playlists) ─────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Made For You'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20),
              itemCount: allPlaylists.length,
              itemBuilder: (context, index) {
                final pl = allPlaylists[index];
                return HorizontalCard(
                  gradient: pl.artGradient,
                  icon: pl.artIcon,
                  title: pl.title,
                  subtitle: pl.description,
                  onTap: () {
                    final songs = getSongsByIds(pl.songIds);
                    if (songs.isNotEmpty) {
                      player.playSong(songs.first, playlist: songs);
                    }
                  },
                );
              },
            ),
          ),
        ),

        // ─── New Releases ─────────────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'New Releases'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20),
              itemCount: allAlbums.length,
              itemBuilder: (context, index) {
                final album = allAlbums[index];
                return HorizontalCard(
                  gradient: album.artGradient,
                  icon: album.artIcon,
                  title: album.title,
                  subtitle: album.artist,
                  onTap: () {
                    final songs = getSongsByIds(album.songIds);
                    if (songs.isNotEmpty) {
                      player.playSong(songs.first, playlist: songs);
                    }
                  },
                );
              },
            ),
          ),
        ),

        // ─── Trending Songs ───────────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Trending Now'),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = allSongs[index + 6];
              final isCurrentSong =
                  player.currentSong?.id == song.id && player.isPlaying;
              return SongTile(
                song: song,
                isPlaying: isCurrentSong,
                onTap: () =>
                    player.playSong(song, playlist: allSongs.sublist(6)),
              );
            },
            childCount: 8,
          ),
        ),

        // Bottom padding for mini player
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }
}
