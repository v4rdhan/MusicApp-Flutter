import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../services/player_controller.dart';
import '../services/home_view_model.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = HomeViewModelProvider.of(context);
    // Trigger fetch if not already started
    if (!vm.quickPicks.isLoading &&
        !vm.quickPicks.isLoaded &&
        !vm.quickPicks.isError) {
      vm.initialize();
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);
    final vm = HomeViewModelProvider.of(context);

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
          child: _buildFeaturedHero(vm, player),
        ),

        // ─── Quick Picks (Grid) ───────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Quick Picks'),
        ),
        _buildQuickPicks(vm, player),

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
                    imageUrl: song.imageUrl,
                    onTap: () => player.playSong(song,
                        playlist: player.recentlyPlayed),
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
          child: _buildMadeForYou(vm, player),
        ),

        // ─── New Releases ─────────────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'New Releases'),
        ),
        SliverToBoxAdapter(
          child: _buildNewReleases(vm, player),
        ),

        // ─── Trending Songs ───────────────────────────────────────
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Trending Now'),
        ),
        _buildTrendingSongs(vm, player),

        // Bottom padding for mini player
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  // ─── Featured Hero ──────────────────────────────────────────────────────

  Widget _buildFeaturedHero(HomeViewModel vm, MusicPlayerController player) {
    if (vm.featuredPlaylists.isLoading) {
      return const FeaturedHeroSkeleton();
    }

    if (vm.featuredPlaylists.isError) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: SectionError(
          message: vm.featuredPlaylists.errorMessage ??
              'Failed to load featured playlist.',
          onRetry: () => vm.fetchFeaturedPlaylists(),
        ),
      );
    }

    final hero = vm.featuredHero;
    if (hero == null) {
      // Fallback to sample data
      return _buildFeaturedHeroFallback(player);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () {
          // When playlists have songs loaded, play them
          // For now just a visual tap
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: hero.artGradient.first.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background image
              if (hero.hasNetworkImage)
                Positioned.fill(
                  child: Image.network(
                    hero.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6C63FF),
                            const Color(0xFFE040FB),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Fallback gradient when no image
              if (!hero.hasNetworkImage)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
                      ),
                    ),
                  ),
                ),
              // Dark overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              // Decorative icon
              if (!hero.hasNetworkImage)
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.headphones_rounded,
                      size: 150,
                      color: Colors.white.withOpacity(0.1)),
                ),
              // Content
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
                    Text(
                      hero.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hero.description.isNotEmpty
                          ? hero.description
                          : '${hero.songCount ?? 0} songs • ${hero.language ?? ''}',
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
    );
  }

  Widget _buildFeaturedHeroFallback(MusicPlayerController player) {
    return Padding(
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
    );
  }

  // ─── Quick Picks Grid ───────────────────────────────────────────────────

  Widget _buildQuickPicks(HomeViewModel vm, MusicPlayerController player) {
    if (vm.quickPicks.isLoading) {
      return const SliverToBoxAdapter(child: QuickPicksGridSkeleton());
    }

    if (vm.quickPicks.isError) {
      return SliverToBoxAdapter(
        child: SectionError(
          message:
              vm.quickPicks.errorMessage ?? 'Failed to load quick picks.',
          onRetry: () => vm.fetchQuickPicks(),
        ),
      );
    }

    final songs = vm.quickPicks.data ?? allSongs;
    final displayCount = songs.length.clamp(0, 6);

    return SliverPadding(
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
            final song = songs[index];
            final isCurrentSong =
                player.currentSong?.id == song.id && player.isPlaying;
            return GestureDetector(
              onTap: () =>
                  player.playSong(song, playlist: songs),
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
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Left: Image or gradient
                    song.hasNetworkImage
                        ? SizedBox(
                            width: 52,
                            child: Image.network(
                              song.imageUrl!,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                width: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: song.artGradient,
                                  ),
                                ),
                                child: Icon(song.artIcon,
                                    color:
                                        Colors.white.withOpacity(0.85),
                                    size: 22),
                              ),
                            ),
                          )
                        : Container(
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
          childCount: displayCount,
        ),
      ),
    );
  }

  // ─── Made For You ───────────────────────────────────────────────────────

  Widget _buildMadeForYou(HomeViewModel vm, MusicPlayerController player) {
    if (vm.madeForYou.isLoading) {
      return const HorizontalCardListSkeleton();
    }

    if (vm.madeForYou.isError) {
      return InlineSectionError(
        message: vm.madeForYou.errorMessage ??
            'Failed to load playlists.',
        onRetry: () => vm.fetchMadeForYou(),
      );
    }

    final playlists = vm.madeForYou.data;
    if (playlists == null || playlists.isEmpty) {
      // Fallback to sample data
      return SizedBox(
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
      );
    }

    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final pl = playlists[index];
          return HorizontalCard(
            gradient: pl.artGradient,
            icon: pl.artIcon,
            title: pl.title,
            subtitle: pl.description.isNotEmpty
                ? pl.description
                : '${pl.songCount ?? 0} songs',
            imageUrl: pl.imageUrl,
            onTap: () {
              // Playlist tap action — can be expanded later
            },
          );
        },
      ),
    );
  }

  // ─── New Releases ───────────────────────────────────────────────────────

  Widget _buildNewReleases(HomeViewModel vm, MusicPlayerController player) {
    if (vm.newReleases.isLoading) {
      return const HorizontalCardListSkeleton();
    }

    if (vm.newReleases.isError) {
      return InlineSectionError(
        message: vm.newReleases.errorMessage ??
            'Failed to load new releases.',
        onRetry: () => vm.fetchNewReleases(),
      );
    }

    final albums = vm.newReleases.data;
    if (albums == null || albums.isEmpty) {
      // Fallback to sample data
      return SizedBox(
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
      );
    }

    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return HorizontalCard(
            gradient: album.artGradient,
            icon: album.artIcon,
            title: album.title,
            subtitle: album.artist,
            imageUrl: album.imageUrl,
            onTap: () {
              // Album tap — can navigate to album detail
            },
          );
        },
      ),
    );
  }

  // ─── Trending Songs ─────────────────────────────────────────────────────

  Widget _buildTrendingSongs(
      HomeViewModel vm, MusicPlayerController player) {
    if (vm.trendingSongs.isLoading) {
      return const SliverToBoxAdapter(
        child: SongTileListSkeleton(count: 5),
      );
    }

    if (vm.trendingSongs.isError) {
      return SliverToBoxAdapter(
        child: SectionError(
          message: vm.trendingSongs.errorMessage ??
              'Failed to load trending songs.',
          onRetry: () => vm.fetchTrendingSongs(),
        ),
      );
    }

    final songs = vm.trendingSongs.data;
    if (songs == null || songs.isEmpty) {
      // Fallback to sample data
      return SliverList(
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
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          final isCurrentSong =
              player.currentSong?.id == song.id && player.isPlaying;
          return SongTile(
            song: song,
            isPlaying: isCurrentSong,
            onTap: () => player.playSong(song, playlist: songs),
          );
        },
        childCount: songs.length,
      ),
    );
  }
}
