import 'dart:async';
import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _query = '';
  List<Song> _results = [];
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Top songs state (fetched from API on first load)
  List<Song> _topSongs = [];
  bool _isLoadingTopSongs = true;
  String? _topSongsError;

  @override
  void initState() {
    super.initState();
    _fetchTopSongs();
  }

  Future<void> _fetchTopSongs() async {
    setState(() {
      _isLoadingTopSongs = true;
      _topSongsError = null;
    });
    final result = await _apiService.searchSongs('trending hits', limit: 15);
    if (!mounted) return;
    setState(() {
      _isLoadingTopSongs = false;
      if (result.isSuccess) {
        _topSongs = result.data!.results;
      } else {
        _topSongsError = result.error!.message;
      }
    });
  }

  void _onSearch(String query) {
    final trimmedQuery = query.trim();
    _searchDebounce?.cancel();
    final requestId = ++_searchRequestId;

    setState(() {
      _query = trimmedQuery;
      _results = [];
      _isLoading = trimmedQuery.isNotEmpty;
      _errorMessage = null;
    });

    if (trimmedQuery.isNotEmpty) {
      _searchDebounce = Timer(
        const Duration(milliseconds: 350),
        () => _fetchResults(trimmedQuery, requestId),
      );
    }
  }

  Future<void> _fetchResults(String query, int requestId) async {
    final result = await _apiService.searchSongs(query, limit: 20);
    if (!mounted || requestId != _searchRequestId) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _results = result.data!.results;
        _errorMessage = null;
      } else {
        _results = [];
        _errorMessage = result.error!.message;
      }
    });
  }

  void _retrySearch() {
    final requestId = ++_searchRequestId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fetchResults(_query, requestId);
  }

  /// When a category card is tapped, fill the search bar and trigger search.
  void _onCategoryTap(String categoryTitle) {
    _searchController.text = categoryTitle;
    _onSearch(categoryTitle);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _apiService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ─── Header ─────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        // ─── Search Bar ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Songs, artists, or albums',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withOpacity(0.5)),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                          icon: Icon(Icons.close_rounded,
                              color: Colors.white.withOpacity(0.5)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),

        // ─── Search Results ─────────────────────────────────────
        if (_query.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _isLoading
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Searching...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : _errorMessage != null
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _retrySearch,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : Text(
                          _results.isEmpty
                              ? 'No songs found for "$_query"'
                              : '${_results.length} result${_results.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
            ),
          ),
          if (!_isLoading && _errorMessage == null && _results.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _results[index];
                  final isCurrentSong =
                      player.currentSong?.id == song.id && player.isPlaying;
                  return SongTile(
                    song: song,
                    isPlaying: isCurrentSong,
                    onTap: () =>
                        player.playSong(song, playlist: _results),
                  );
                },
                childCount: _results.length,
              ),
            ),
        ] else ...[
          // ─── Browse Categories ────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Browse Categories'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = browseCategories[index];
                  return GestureDetector(
                    onTap: () => _onCategoryTap(cat.title),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: cat.gradient,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -8,
                            bottom: -8,
                            child: Transform.rotate(
                              angle: 0.3,
                              child: Icon(cat.icon,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.15)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              cat.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: browseCategories.length,
              ),
            ),
          ),
        ],

        // ─── Top Songs (API-fetched trending, shown when not searching) ──
        if (_query.isEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
              child: Row(
                children: [
                  const Text(
                    'Top Songs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.trending_up_rounded,
                      color: const Color(0xFF6C63FF).withOpacity(0.7),
                      size: 20),
                ],
              ),
            ),
          ),
          if (_isLoadingTopSongs)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading trending songs...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_topSongsError != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          color: Colors.white.withOpacity(0.3), size: 36),
                      const SizedBox(height: 12),
                      Text(
                        _topSongsError!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _fetchTopSongs,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _topSongs[index];
                  final isCurrentSong =
                      player.currentSong?.id == song.id && player.isPlaying;
                  return SongTile(
                    song: song,
                    isPlaying: isCurrentSong,
                    onTap: () =>
                        player.playSong(song, playlist: _topSongs),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFF6C63FF)
                              .withOpacity(index < 3 ? 0.2 : 0.08),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index < 3
                                ? const Color(0xFF6C63FF)
                                : Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _topSongs.length,
              ),
            ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
