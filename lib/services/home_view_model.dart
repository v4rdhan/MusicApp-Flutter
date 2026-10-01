import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';

// ─── Loading State ──────────────────────────────────────────────────────────

enum LoadingState { idle, loading, loaded, error }

/// Represents the state of a single data section.
class SectionState<T> {
  final LoadingState state;
  final T? data;
  final String? errorMessage;

  const SectionState({
    this.state = LoadingState.idle,
    this.data,
    this.errorMessage,
  });

  SectionState<T> copyWith({
    LoadingState? state,
    T? data,
    String? errorMessage,
  }) {
    return SectionState<T>(
      state: state ?? this.state,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => state == LoadingState.loading;
  bool get isLoaded => state == LoadingState.loaded;
  bool get isError => state == LoadingState.error;
  bool get hasData => data != null;
}

// ─── Home View Model ────────────────────────────────────────────────────────

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService;

  HomeViewModel({required ApiService apiService})
      : _apiService = apiService;

  // ─── Section States ─────────────────────────────────────────────────────
  SectionState<List<Song>> quickPicks =
      const SectionState<List<Song>>();
  SectionState<List<Playlist>> featuredPlaylists =
      const SectionState<List<Playlist>>();
  SectionState<List<Playlist>> madeForYou =
      const SectionState<List<Playlist>>();
  SectionState<List<Album>> newReleases =
      const SectionState<List<Album>>();
  SectionState<List<Song>> trendingSongs =
      const SectionState<List<Song>>();

  // Featured hero playlist (first featured playlist)
  Playlist? get featuredHero {
    if (featuredPlaylists.hasData && featuredPlaylists.data!.isNotEmpty) {
      return featuredPlaylists.data!.first;
    }
    return null;
  }

  // ─── Initialization ─────────────────────────────────────────────────────

  /// Fetches all home screen data in parallel.
  Future<void> initialize() async {
    await Future.wait([
      fetchQuickPicks(),
      fetchFeaturedPlaylists(),
      fetchMadeForYou(),
      fetchNewReleases(),
      fetchTrendingSongs(),
    ]);
  }

  // ─── Individual Fetchers ────────────────────────────────────────────────

  Future<void> fetchQuickPicks() async {
    quickPicks = quickPicks.copyWith(state: LoadingState.loading);
    notifyListeners();

    final result = await _apiService.searchSongs('trending hits', limit: 10);
    if (result.isSuccess) {
      quickPicks = SectionState(
        state: LoadingState.loaded,
        data: result.data!.results,
      );
    } else {
      quickPicks = SectionState(
        state: LoadingState.error,
        errorMessage: result.error!.message,
      );
    }
    notifyListeners();
  }

  Future<void> fetchFeaturedPlaylists() async {
    featuredPlaylists =
        featuredPlaylists.copyWith(state: LoadingState.loading);
    notifyListeners();

    final result =
        await _apiService.searchPlaylists('top hits', limit: 6);
    if (result.isSuccess) {
      featuredPlaylists = SectionState(
        state: LoadingState.loaded,
        data: result.data!.results,
      );
    } else {
      featuredPlaylists = SectionState(
        state: LoadingState.error,
        errorMessage: result.error!.message,
      );
    }
    notifyListeners();
  }

  Future<void> fetchMadeForYou() async {
    madeForYou = madeForYou.copyWith(state: LoadingState.loading);
    notifyListeners();

    final result = await _apiService.searchPlaylists('chill vibes', limit: 8);
    if (result.isSuccess) {
      madeForYou = SectionState(
        state: LoadingState.loaded,
        data: result.data!.results,
      );
    } else {
      madeForYou = SectionState(
        state: LoadingState.error,
        errorMessage: result.error!.message,
      );
    }
    notifyListeners();
  }

  Future<void> fetchNewReleases() async {
    newReleases = newReleases.copyWith(state: LoadingState.loading);
    notifyListeners();

    final result =
        await _apiService.searchAlbums('new releases 2024', limit: 8);
    if (result.isSuccess) {
      newReleases = SectionState(
        state: LoadingState.loaded,
        data: result.data!.results,
      );
    } else {
      newReleases = SectionState(
        state: LoadingState.error,
        errorMessage: result.error!.message,
      );
    }
    notifyListeners();
  }

  Future<void> fetchTrendingSongs() async {
    trendingSongs = trendingSongs.copyWith(state: LoadingState.loading);
    notifyListeners();

    final result = await _apiService.searchSongs('popular songs', limit: 10);
    if (result.isSuccess) {
      trendingSongs = SectionState(
        state: LoadingState.loaded,
        data: result.data!.results,
      );
    } else {
      trendingSongs = SectionState(
        state: LoadingState.error,
        errorMessage: result.error!.message,
      );
    }
    notifyListeners();
  }

  /// Retries all failed sections.
  Future<void> retryFailed() async {
    final futures = <Future<void>>[];
    if (quickPicks.isError) futures.add(fetchQuickPicks());
    if (featuredPlaylists.isError) futures.add(fetchFeaturedPlaylists());
    if (madeForYou.isError) futures.add(fetchMadeForYou());
    if (newReleases.isError) futures.add(fetchNewReleases());
    if (trendingSongs.isError) futures.add(fetchTrendingSongs());
    if (futures.isEmpty) {
      // If nothing failed but we have no data, re-initialize everything
      await initialize();
    } else {
      await Future.wait(futures);
    }
  }
}

// ─── InheritedWidget for access ─────────────────────────────────────────────

class HomeViewModelProvider extends InheritedNotifier<HomeViewModel> {
  const HomeViewModelProvider({
    super.key,
    required HomeViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  static HomeViewModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeViewModelProvider>()!
        .notifier!;
  }
}
