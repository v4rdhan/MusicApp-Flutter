import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

// ─── Error Types ────────────────────────────────────────────────────────────

/// Base class for all API errors.
sealed class ApiError implements Exception {
  final String message;
  const ApiError(this.message);

  @override
  String toString() => message;
}

/// Network-level error (no internet, DNS failure, etc.)
class NetworkError extends ApiError {
  const NetworkError([super.message = 'Network error. Check your connection.']);
}

/// Request timed out.
class TimeoutError extends ApiError {
  const TimeoutError([super.message = 'Request timed out. Try again.']);
}

/// Server returned an HTTP error status code.
class ServerError extends ApiError {
  final int statusCode;
  const ServerError(this.statusCode,
      [super.message = 'Server error. Try again later.']);
}

/// The API returned success:false or the response could not be parsed.
class ParseError extends ApiError {
  const ParseError([super.message = 'Unexpected response from server.']);
}

// ─── Result Type ────────────────────────────────────────────────────────────

/// A simple Result wrapper for API calls.
class ApiResult<T> {
  final T? data;
  final ApiError? error;

  const ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(ApiError error) => ApiResult._(error: error);

  bool get isSuccess => data != null;
  bool get isError => error != null;
}

// ─── Search Results ─────────────────────────────────────────────────────────

/// Container for global search results.
class GlobalSearchResult {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;
  final List<Song> topQuery;

  const GlobalSearchResult({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.topQuery = const [],
  });
}

/// Paginated result container.
class PaginatedResult<T> {
  final int total;
  final int start;
  final List<T> results;

  const PaginatedResult({
    this.total = 0,
    this.start = 0,
    this.results = const [],
  });
}

// ─── API Service ────────────────────────────────────────────────────────────

class ApiService {
  static const String _baseUrl =
      'https://jiosaavn-api-serk.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Disposes the underlying HTTP client.
  void dispose() {
    _client.close();
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Private Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Makes a GET request and returns the parsed JSON map.
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode >= 500) {
        throw ServerError(response.statusCode, 'Server error (${response.statusCode})');
      }
      if (response.statusCode >= 400) {
        throw ServerError(
            response.statusCode, 'Request failed (${response.statusCode})');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] != true) {
        throw const ParseError('API returned unsuccessful response.');
      }

      return body;
    } on TimeoutException {
      throw const TimeoutError();
    } on http.ClientException {
      throw const NetworkError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw NetworkError('Unexpected error: $e');
    }
  }

  /// Wraps an async operation into an [ApiResult].
  Future<ApiResult<T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      return ApiResult.success(result);
    } on ApiError catch (e) {
      return ApiResult.failure(e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Global Search
  // ──────────────────────────────────────────────────────────────────────────

  /// Performs a global search across songs, albums, artists, playlists.
  Future<ApiResult<GlobalSearchResult>> globalSearch(String query) async {
    return _wrap(() async {
      final body = await _get('/search', queryParams: {'query': query});
      final data = body['data'] as Map<String, dynamic>;

      return GlobalSearchResult(
        songs: _parseResultsList<Song>(data['songs'], Song.fromJson),
        albums: _parseResultsList<Album>(data['albums'], Album.fromJson),
        artists: _parseResultsList<Artist>(data['artists'], Artist.fromJson),
        playlists:
            _parseResultsList<Playlist>(data['playlists'], Playlist.fromJson),
        topQuery: _parseResultsList<Song>(data['topQuery'], Song.fromJson),
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Song Search
  // ──────────────────────────────────────────────────────────────────────────

  /// Searches for songs.
  Future<ApiResult<PaginatedResult<Song>>> searchSongs(
    String query, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/search/songs', queryParams: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Song>(
        total: data['total'] as int? ?? 0,
        start: data['start'] as int? ?? 0,
        results: (data['results'] as List<dynamic>?)
                ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Album Search
  // ──────────────────────────────────────────────────────────────────────────

  /// Searches for albums.
  Future<ApiResult<PaginatedResult<Album>>> searchAlbums(
    String query, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/search/albums', queryParams: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Album>(
        total: data['total'] as int? ?? 0,
        start: data['start'] as int? ?? 0,
        results: (data['results'] as List<dynamic>?)
                ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Artist Search
  // ──────────────────────────────────────────────────────────────────────────

  /// Searches for artists.
  Future<ApiResult<PaginatedResult<Artist>>> searchArtists(
    String query, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/search/artists', queryParams: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Artist>(
        total: data['total'] as int? ?? 0,
        start: data['start'] as int? ?? 0,
        results: (data['results'] as List<dynamic>?)
                ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Playlist Search
  // ──────────────────────────────────────────────────────────────────────────

  /// Searches for playlists.
  Future<ApiResult<PaginatedResult<Playlist>>> searchPlaylists(
    String query, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/search/playlists', queryParams: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Playlist>(
        total: data['total'] as int? ?? 0,
        start: data['start'] as int? ?? 0,
        results: (data['results'] as List<dynamic>?)
                ?.map((e) => Playlist.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Song by ID
  // ──────────────────────────────────────────────────────────────────────────

  /// Retrieves a song by its ID.
  Future<ApiResult<Song>> getSongById(String songId) async {
    return _wrap(() async {
      final body = await _get('/songs/$songId');
      final data = body['data'] as List<dynamic>;
      if (data.isEmpty) throw const ParseError('Song not found.');
      return Song.fromJson(data.first as Map<String, dynamic>);
    });
  }

  /// Retrieves multiple songs by IDs (comma-separated).
  Future<ApiResult<List<Song>>> getSongsByIds(List<String> songIds) async {
    return _wrap(() async {
      final body = await _get('/songs/${songIds.join(',')}');
      final data = body['data'] as List<dynamic>;
      return data
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Song Suggestions
  // ──────────────────────────────────────────────────────────────────────────

  /// Retrieves song suggestions based on a song ID.
  Future<ApiResult<List<Song>>> getSongSuggestions(String songId) async {
    return _wrap(() async {
      final body = await _get('/songs/$songId/suggestions');
      final data = body['data'] as List<dynamic>;
      return data
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Artist by ID
  // ──────────────────────────────────────────────────────────────────────────

  /// Retrieves an artist's full profile by ID.
  Future<ApiResult<Artist>> getArtistById(String artistId) async {
    return _wrap(() async {
      final body = await _get('/artists/$artistId');
      final data = body['data'] as Map<String, dynamic>;
      return Artist.fromJson(data);
    });
  }

  /// Retrieves an artist's songs.
  Future<ApiResult<PaginatedResult<Song>>> getArtistSongs(
    String artistId, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/artists/$artistId/songs', queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Song>(
        total: data['total'] as int? ?? 0,
        results: (data['songs'] as List<dynamic>?)
                ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  /// Retrieves an artist's albums.
  Future<ApiResult<PaginatedResult<Album>>> getArtistAlbums(
    String artistId, {
    int page = 0,
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/artists/$artistId/albums', queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;

      return PaginatedResult<Album>(
        total: data['total'] as int? ?? 0,
        results: (data['albums'] as List<dynamic>?)
                ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Home Screen Convenience Methods
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches "Quick Picks" — trending songs for the home screen.
  /// Uses a search for popular/trending terms.
  Future<ApiResult<List<Song>>> getQuickPicks({int limit = 10}) async {
    return _wrap(() async {
      final body = await _get('/search/songs', queryParams: {
        'query': 'trending',
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;
      return (data['results'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  /// Fetches "Featured Playlists" for the home screen.
  Future<ApiResult<List<Playlist>>> getFeaturedPlaylists(
      {int limit = 10}) async {
    return _wrap(() async {
      final body = await _get('/search/playlists', queryParams: {
        'query': 'top hits',
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;
      return (data['results'] as List<dynamic>?)
              ?.map((e) => Playlist.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  /// Fetches songs for a browse category (e.g., "Pop", "Rock", "Hip Hop").
  Future<ApiResult<List<Song>>> getCategorySongs(
    String category, {
    int limit = 20,
  }) async {
    return _wrap(() async {
      final body = await _get('/search/songs', queryParams: {
        'query': '$category hits',
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;
      return (data['results'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  /// Fetches new album releases.
  Future<ApiResult<List<Album>>> getNewReleases({int limit = 10}) async {
    return _wrap(() async {
      final body = await _get('/search/albums', queryParams: {
        'query': 'new releases 2024',
        'limit': limit.toString(),
      });
      final data = body['data'] as Map<String, dynamic>;
      return (data['results'] as List<dynamic>?)
              ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Private Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Parses results list from the global search response shape:
  /// { "results": [...], "position": N }
  List<T> _parseResultsList<T>(
    dynamic section,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (section == null || section is! Map<String, dynamic>) return [];
    final results = section['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
