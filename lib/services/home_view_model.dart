import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum LoadingState { idle, loading, loaded, error }

class SectionState<T> {
  final LoadingState state;
  final T? data;
  final String? errorMessage;

  const SectionState({
    this.state = LoadingState.idle,
    this.data,
    this.errorMessage,
  });

  bool get isLoading => state == LoadingState.loading;
  bool get isLoaded => state == LoadingState.loaded;
  bool get isError => state == LoadingState.error;
}

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  HomeViewModel({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  List<String> languages = const [];
  bool _initialized = false;
  bool get isInitialized => _initialized;

  SectionState<List<Song>> trendingSongs = const SectionState();
  SectionState<List<Album>> newReleases = const SectionState();
  SectionState<List<Song>> recommendedSongs = const SectionState();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    languages = _storageService
        .getSelectedLanguages()
        .map((language) => language.trim())
        .where((language) => language.isNotEmpty)
        .toList();

    if (languages.isEmpty) {
      const message = 'Choose music languages to get recommendations.';
      trendingSongs = const SectionState(
        state: LoadingState.error,
        errorMessage: message,
      );
      newReleases = const SectionState(
        state: LoadingState.error,
        errorMessage: message,
      );
      recommendedSongs = const SectionState(
        state: LoadingState.error,
        errorMessage: message,
      );
      notifyListeners();
      return;
    }

    await Future.wait([fetchTrendingSongs(), fetchNewReleases()]);
    await fetchRecommendedSongs();
  }

  Future<void> fetchTrendingSongs() async {
    trendingSongs = const SectionState(state: LoadingState.loading);
    notifyListeners();
    trendingSongs = await _fetchSongsAcrossLanguages(
      queryForLanguage: (language) => '$language trending songs',
    );
    notifyListeners();
  }

  Future<void> fetchNewReleases() async {
    newReleases = const SectionState(state: LoadingState.loading);
    notifyListeners();

    final responses = await Future.wait(
      languages.map(
        (language) =>
            _apiService.searchAlbums('$language new releases', limit: 8),
      ),
    );
    final successful = responses.where((result) => result.isSuccess).toList();
    if (successful.isEmpty) {
      newReleases = SectionState(
        state: LoadingState.error,
        errorMessage: _firstError(responses) ?? 'Could not load new releases.',
      );
    } else {
      final albums = <String, Album>{};
      for (final result in successful) {
        for (final album in result.data!.results) {
          albums.putIfAbsent(album.id, () => album);
        }
      }
      newReleases = SectionState(
        state: LoadingState.loaded,
        data: albums.values.toList(),
      );
    }
    notifyListeners();
  }

  Future<void> fetchRecommendedSongs() async {
    recommendedSongs = const SectionState(state: LoadingState.loading);
    notifyListeners();

    final seeds = <String, Song>{};
    for (final song in (trendingSongs.data ?? const <Song>[])) {
      if (song.language == null ||
          languages.any(
            (language) =>
                language.toLowerCase() == song.language!.toLowerCase(),
          )) {
        seeds.putIfAbsent(song.id, () => song);
      }
      if (seeds.length >= languages.length) break;
    }

    if (seeds.isEmpty) {
      recommendedSongs = const SectionState(
        state: LoadingState.error,
        errorMessage: 'No language-matched songs are available to recommend.',
      );
      notifyListeners();
      return;
    }

    final responses = await Future.wait(
      seeds.values.map((song) => _apiService.getSongSuggestions(song.id)),
    );
    final successful = responses.where((result) => result.isSuccess).toList();
    final suggestedSongs =
        successful.expand((result) => result.data!).toList();
    final preferredLanguages =
        languages.map((language) => language.toLowerCase()).toSet();
    final languageMatchedSuggestions = suggestedSongs.where((song) {
      final language = song.language?.toLowerCase();
      return language == null ||
          language.isEmpty ||
          preferredLanguages.contains(language);
    }).toList();

    if (languageMatchedSuggestions.isEmpty) {
      final fallbackResponses = await Future.wait(
        languages.map(
          (language) =>
              _apiService.searchSongs('$language recommended songs', limit: 10),
        ),
      );
      final successfulFallbacks =
          fallbackResponses.where((result) => result.isSuccess).toList();
      if (successfulFallbacks.isEmpty) {
        recommendedSongs = SectionState(
          state: LoadingState.error,
          errorMessage: _firstError(responses) ??
              _firstError(fallbackResponses) ??
              'Could not load recommendations.',
        );
      } else {
        final songs = <String, Song>{};
        for (final result in successfulFallbacks) {
          for (final song in result.data!.results) {
            songs.putIfAbsent(song.id, () => song);
          }
        }
        recommendedSongs = SectionState(
          state: LoadingState.loaded,
          data: songs.values.toList(),
        );
      }
    } else {
      final songs = <String, Song>{};
      for (final song in languageMatchedSuggestions) {
        songs.putIfAbsent(song.id, () => song);
      }
      recommendedSongs = SectionState(
        state: LoadingState.loaded,
        data: songs.values.toList(),
      );
    }
    notifyListeners();
  }

  Future<SectionState<List<Song>>> _fetchSongsAcrossLanguages({
    required String Function(String language) queryForLanguage,
  }) async {
    final responses = await Future.wait(
      languages.map(
        (language) => _apiService.searchSongs(
          queryForLanguage(language),
          limit: 10,
        ),
      ),
    );
    final successful = responses.where((result) => result.isSuccess).toList();
    if (successful.isEmpty) {
      return SectionState(
        state: LoadingState.error,
        errorMessage: _firstError(responses) ?? 'Could not load songs.',
      );
    }

    final songs = <String, Song>{};
    for (final result in successful) {
      for (final song in result.data!.results) {
        songs.putIfAbsent(song.id, () => song);
      }
    }
    return SectionState(
      state: LoadingState.loaded,
      data: songs.values.toList(),
    );
  }

  Future<void> retryTrendingSongs() => fetchTrendingSongs();
  Future<void> retryNewReleases() => fetchNewReleases();
  Future<void> retryRecommendedSongs() => fetchRecommendedSongs();

  String? _firstError<T>(Iterable<ApiResult<T>> results) {
    for (final result in results) {
      if (result.error != null) return result.error!.message;
    }
    return null;
  }
}

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
