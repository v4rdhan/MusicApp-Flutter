import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/song.dart';
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
              Tab(text: '  Recent  '),
              Tab(text: '  Favorites  '),
              Tab(text: '  Playlists  '),
              Tab(text: '  Albums  '),
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
              // Recently Played Tab
              _buildRecentlyPlayedTab(player),
              // Favorites Tab
              _buildFavoritesTab(player),
              // Playlists Tab
              _buildPlaylistsTab(player),
              // Albums Tab
              _buildAlbumsTab(player),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Recently Played ────────────────────────────────────────────────────

  Widget _buildRecentlyPlayedTab(MusicPlayerController player) {
    if (player.recentlyPlayed.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'No recently played',
        subtitle: 'Songs you listen to will appear here',
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Quick-access horizontal carousel of recent album art
        SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              itemCount: player.recentlyPlayed.length.clamp(0, 10),
              itemBuilder: (context, index) {
                final song = player.recentlyPlayed[index];
                return _RecentArtCard(
                  song: song,
                  isPlaying: player.currentSong?.id == song.id &&
                      player.isPlaying,
                  onTap: () => player.playSong(
                    song,
                    playlist: player.recentlyPlayed,
                  ),
                );
              },
            ),
          ),
        ),

        // Divider label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Icon(Icons.history_rounded,
                    color: Colors.white.withOpacity(0.3), size: 16),
                const SizedBox(width: 8),
                Text(
                  'All Recently Played',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.06),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Full list of recently played songs
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = player.recentlyPlayed[index];
              final isCurrentSong =
                  player.currentSong?.id == song.id && player.isPlaying;
              return SongTile(
                song: song,
                isPlaying: isCurrentSong,
                onTap: () => player.playSong(
                  song,
                  playlist: player.recentlyPlayed,
                ),
                trailing: IconButton(
                  onPressed: () => player.toggleFavorite(song),
                  icon: Icon(
                    player.isFavorite(song)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: player.isFavorite(song)
                        ? const Color(0xFFE040FB)
                        : Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 32, minHeight: 32),
                ),
              );
            },
            childCount: player.recentlyPlayed.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ─── Favorites ──────────────────────────────────────────────────────────

  Widget _buildFavoritesTab(MusicPlayerController player) {
    if (player.favorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No favorites yet',
        subtitle: 'Tap the heart icon on any song to save it',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Color(0xFFE040FB), size: 20),
                const SizedBox(width: 10),
                Text(
                  '${player.favorites.length} saved song${player.favorites.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Play all button
                GestureDetector(
                  onTap: () {
                    if (player.favorites.isNotEmpty) {
                      player.playSong(
                        player.favorites.first,
                        playlist: player.favorites,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Color(0xFF6C63FF), size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Play All',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            itemCount: player.favorites.length,
            itemBuilder: (context, index) {
              final song = player.favorites[index];
              final isCurrentSong =
                  player.currentSong?.id == song.id && player.isPlaying;
              return Dismissible(
                key: ValueKey('fav_${song.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Colors.redAccent.withOpacity(0.15),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                ),
                onDismissed: (_) => player.toggleFavorite(song),
                child: SongTile(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Playlists ──────────────────────────────────────────────────────────

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
                    imageUrl: pl.imageUrl,
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

  // ─── Albums ─────────────────────────────────────────────────────────────

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: album.hasNetworkImage
                        ? Image.network(
                            album.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              album.artIcon,
                              color: Colors.white.withOpacity(0.3),
                              size: 50,
                            ),
                          )
                        : Icon(
                            album.artIcon,
                            color: Colors.white.withOpacity(0.3),
                            size: 50,
                          ),
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

  // ─── Empty State ────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Icon(icon,
                color: Colors.white.withOpacity(0.15), size: 44),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recently Played Art Card ─────────────────────────────────────────────────

class _RecentArtCard extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const _RecentArtCard({
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: song.artGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: song.artGradient.first.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (song.hasNetworkImage)
                      Image.network(
                        song.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          song.artIcon,
                          color: Colors.white.withOpacity(0.3),
                          size: 36,
                        ),
                      )
                    else
                      Icon(
                        song.artIcon,
                        color: Colors.white.withOpacity(0.3),
                        size: 36,
                      ),
                    // Playing indicator overlay
                    if (isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.equalizer_rounded,
                            color: Color(0xFF6C63FF),
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: TextStyle(
                color: isPlaying
                    ? const Color(0xFF6C63FF)
                    : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
