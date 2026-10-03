import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

/// Handles local persistence for favorites and recently played songs
/// using shared_preferences. Song data is stored as JSON arrays.
class StorageService {
  static const String _favoritesKey = 'favorites_songs';
  static const String _recentlyPlayedKey = 'recently_played_songs';
  static const int _maxRecentlyPlayed = 50;

  SharedPreferences? _prefs;

  /// Must be called once before any read/write operations.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Favorites ──────────────────────────────────────────────────────────

  /// Returns all favorited songs from local storage.
  List<Song> getFavorites() {
    final raw = _prefs?.getStringList(_favoritesKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .map((json) {
          try {
            return Song.fromJson(jsonDecode(json) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Song>()
        .toList();
  }

  /// Persists the full favorites list.
  Future<void> saveFavorites(List<Song> favorites) async {
    final encoded = favorites.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs?.setStringList(_favoritesKey, encoded);
  }

  // ─── Recently Played ───────────────────────────────────────────────────

  /// Returns recently played songs from local storage.
  List<Song> getRecentlyPlayed() {
    final raw = _prefs?.getStringList(_recentlyPlayedKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .map((json) {
          try {
            return Song.fromJson(jsonDecode(json) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Song>()
        .toList();
  }

  /// Persists the recently played list (capped at [_maxRecentlyPlayed]).
  Future<void> saveRecentlyPlayed(List<Song> songs) async {
    final capped = songs.take(_maxRecentlyPlayed).toList();
    final encoded = capped.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs?.setStringList(_recentlyPlayedKey, encoded);
  }
}
