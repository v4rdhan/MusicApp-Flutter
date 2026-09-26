import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ─────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            'Your Library',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ─── Tabs ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF6C63FF).withOpacity(0.2),
            ),
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: '  Playlists  '),
              Tab(text: '  Songs  '),
              Tab(text: '  Albums  '),
              Tab(text: '  Favorites  '),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ─── Tab Content ────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Playlists Tab
              _buildPlaylistsTab(player),
              // Songs Tab
              _buildSongsTab(player),
              // Albums Tab
              _buildAlbumsTab(player),
              // Favorites Tab
              _buildFavoritesTab(player),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistsTab(MusicPlayerController player) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: allPlaylists.length,
      itemBuilder: (context, index) {
        final pl = allPlaylists[index];
        final songs = getSongsByIds(pl.songIds);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (songs.isNotEmpty) {
                player.playSong(songs.first, playlist: songs);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GradientArt(
                    gradient: pl.artGradient,
                    icon: pl.artIcon,
                    size: 60,
                    iconSize: 28,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pl.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pl.description} • ${pl.songIds.length} songs',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.play_circle_filled_rounded,
                      color: Colors.white.withOpacity(0.3), size: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongsTab(MusicPlayerController player) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: allSongs.length,
      itemBuilder: (context, index) {
        final song = allSongs[index];
        final isCurrentSong =
            player.currentSong?.id == song.id && player.isPlaying;
        return SongTile(
          song: song,
          isPlaying: isCurrentSong,
          onTap: () => player.playSong(song, playlist: allSongs),
        );
      },
    );
  }

  Widget _buildAlbumsTab(MusicPlayerController player) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: allAlbums.length,
      itemBuilder: (context, index) {
        final album = allAlbums[index];
        return GestureDetector(
          onTap: () {
            final songs = getSongsByIds(album.songIds);
            if (songs.isNotEmpty) {
              player.playSong(songs.first, playlist: songs);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: album.artGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: album.artGradient.first.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    album.artIcon,
                    color: Colors.white.withOpacity(0.3),
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                album.title,
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
                album.artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(MusicPlayerController player) {
    if (player.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded,
                color: Colors.white.withOpacity(0.15), size: 72),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart icon on any song',
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: player.favorites.length,
      itemBuilder: (context, index) {
        final song = player.favorites[index];
        final isCurrentSong =
            player.currentSong?.id == song.id && player.isPlaying;
        return SongTile(
          song: song,
          isPlaying: isCurrentSong,
          onTap: () =>
              player.playSong(song, playlist: player.favorites),
          trailing: IconButton(
            onPressed: () => player.toggleFavorite(song),
            icon: const Icon(Icons.favorite_rounded,
                color: Color(0xFFE040FB), size: 20),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
                minWidth: 32, minHeight: 32),
          ),
        );
      },
    );
  }
}
