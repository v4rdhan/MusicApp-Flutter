import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/song.dart';
import '../services/player_controller.dart';
import '../widgets/common_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Song> _results = [];

  void _onSearch(String query) {
    setState(() {
      _query = query.trim().toLowerCase();
      if (_query.isEmpty) {
        _results = [];
      } else {
        _results = allSongs.where((s) {
          return s.title.toLowerCase().contains(_query) ||
              s.artist.toLowerCase().contains(_query) ||
              s.album.toLowerCase().contains(_query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
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

        // ─── Results or Categories ──────────────────────────────
        if (_query.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                _results.isEmpty
                    ? 'No results for "$_query"'
                    : '${_results.length} result${_results.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
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
                  return Container(
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
                  );
                },
                childCount: browseCategories.length,
              ),
            ),
          ),
        ],

        // ─── Top Songs ──────────────────────────────────────────
        if (_query.isEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Top Songs'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = allSongs[index];
                final isCurrentSong =
                    player.currentSong?.id == song.id && player.isPlaying;
                return SongTile(
                  song: song,
                  isPlaying: isCurrentSong,
                  onTap: () =>
                      player.playSong(song, playlist: allSongs),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
              childCount: 10,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
