import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/home_view_model.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shimmer_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Guards against scheduling duplicate initialization calls within the same
  /// frame / dependency rebuild. It is reset whenever the viewModel's cache
  /// expires so a fresh fetch can be triggered on the next visit.
  bool _initializationScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = HomeViewModelProvider.of(context);
    // If the cache has expired (or never loaded), allow a new fetch.
    if (!viewModel.isInitialized) {
      _initializationScheduled = false;
    }
    if (!viewModel.isInitialized && !_initializationScheduled) {
      _initializationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) viewModel.initialize();
      });
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
    final viewModel = HomeViewModelProvider.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
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
                  viewModel.languages.isEmpty
                      ? 'What do you want to listen to?'
                      : 'Music picked for ${viewModel.languages.join(', ')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Trending Now'),
        ),
        _buildSongSection(
          state: viewModel.trendingSongs,
          onRetry: viewModel.retryTrendingSongs,
          player: player,
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'New Releases'),
        ),
        SliverToBoxAdapter(child: _buildNewReleases(viewModel)),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Recommended For You'),
        ),
        _buildSongSection(
          state: viewModel.recommendedSongs,
          onRetry: viewModel.retryRecommendedSongs,
          player: player,
        ),
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
                    onTap: () => player.playSong(
                      song,
                      playlist: player.recentlyPlayed,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildSongSection({
    required SectionState<List<Song>> state,
    required Future<void> Function() onRetry,
    required MusicPlayerController player,
  }) {
    if (state.isLoading || state.state == LoadingState.idle) {
      return const SliverToBoxAdapter(
        child: SongTileListSkeleton(count: 3),
      );
    }
    if (state.isError) {
      return SliverToBoxAdapter(
        child: SectionError(
          message: state.errorMessage ?? 'Could not load songs.',
          onRetry: onRetry,
        ),
      );
    }

    final songs = state.data ?? const <Song>[];
    if (songs.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptySection(message: 'No songs found for your languages.'),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          return SongTile(
            song: song,
            isPlaying:
                player.currentSong?.id == song.id && player.isPlaying,
            onTap: () => player.playSong(song, playlist: songs),
          );
        },
        childCount: songs.length,
      ),
    );
  }

  Widget _buildNewReleases(HomeViewModel viewModel) {
    final state = viewModel.newReleases;
    if (state.isLoading || state.state == LoadingState.idle) {
      return const HorizontalCardListSkeleton();
    }
    if (state.isError) {
      return InlineSectionError(
        message: state.errorMessage ?? 'Could not load new releases.',
        onRetry: viewModel.retryNewReleases,
      );
    }

    final albums = state.data ?? const <Album>[];
    if (albums.isEmpty) {
      return const _EmptySection(
        message: 'No new releases found for your languages.',
      );
    }

    final player = MusicPlayerProvider.of(context);
    final apiService = viewModel.apiService;

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
            onTap: () => _playAlbum(
              context: context,
              album: album,
              player: player,
              apiService: apiService,
            ),
          );
        },
      ),
    );
  }

  /// Fetches full album details (with songs) then starts playback.
  /// Shows a snackbar if the album has no playable tracks.
  Future<void> _playAlbum({
    required BuildContext context,
    required Album album,
    required MusicPlayerController player,
    required ApiService apiService,
  }) async {
    // If the album already has embedded songs, play them directly.
    if (album.songs.isNotEmpty) {
      player.playSong(album.songs.first, playlist: album.songs);
      return;
    }

    // Otherwise fetch the full album detail which includes the song list.
    final result = await apiService.getAlbumById(album.id);
    if (!context.mounted) return;

    if (result.isError || result.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error?.message ?? 'Could not load album songs.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final songs = result.data!.songs;
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No playable songs found in this album.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    player.playSong(songs.first, playlist: songs);
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
}
