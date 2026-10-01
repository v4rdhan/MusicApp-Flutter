import 'package:flutter/material.dart';

// ─── Shared Types ───────────────────────────────────────────────────────────

/// Represents an image at a specific quality level from the API.
class ImageQuality {
  final String quality;
  final String url;

  const ImageQuality({required this.quality, required this.url});

  factory ImageQuality.fromJson(Map<String, dynamic> json) {
    return ImageQuality(
      quality: json['quality'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'quality': quality, 'url': url};
}

/// Represents a download URL at a specific bitrate from the API.
class DownloadQuality {
  final String quality;
  final String url;

  const DownloadQuality({required this.quality, required this.url});

  factory DownloadQuality.fromJson(Map<String, dynamic> json) {
    return DownloadQuality(
      quality: json['quality'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'quality': quality, 'url': url};
}

/// Represents an artist reference (used inside song/album artist lists).
class ArtistInfo {
  final String id;
  final String name;
  final String role;
  final String type;
  final List<ImageQuality> image;
  final String url;

  const ArtistInfo({
    required this.id,
    required this.name,
    this.role = '',
    this.type = 'artist',
    this.image = const [],
    this.url = '',
  });

  factory ArtistInfo.fromJson(Map<String, dynamic> json) {
    return ArtistInfo(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      type: json['type'] as String? ?? 'artist',
      image: (json['image'] as List<dynamic>?)
              ?.map((e) => ImageQuality.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'type': type,
        'image': image.map((e) => e.toJson()).toList(),
        'url': url,
      };

  /// Best available image URL, or empty string.
  String get imageUrl {
    if (image.isEmpty) return '';
    // Prefer the highest quality (last in the list, typically 500x500)
    return image.last.url;
  }
}

/// Helper to extract the best image URL from a list of [ImageQuality].
String bestImageUrl(List<ImageQuality> images) {
  if (images.isEmpty) return '';
  return images.last.url;
}

/// Helper to extract the best download URL from a list of [DownloadQuality].
/// Prefers 320kbps > 160kbps > 96kbps > first available.
String bestDownloadUrl(List<DownloadQuality> downloads) {
  if (downloads.isEmpty) return '';
  for (final preferred in ['320kbps', '160kbps', '96kbps']) {
    final match = downloads.where((d) => d.quality == preferred);
    if (match.isNotEmpty) return match.first.url;
  }
  return downloads.last.url;
}

// ─── Gradient palette for items without cover art ───────────────────────────
const _fallbackGradients = [
  [Color(0xFF6C63FF), Color(0xFF3F51B5)],
  [Color(0xFFE040FB), Color(0xFFFF5722)],
  [Color(0xFF00BCD4), Color(0xFF009688)],
  [Color(0xFFFF9800), Color(0xFFFFEB3B)],
  [Color(0xFF9C27B0), Color(0xFF6C63FF)],
  [Color(0xFFE91E63), Color(0xFFF44336)],
  [Color(0xFF4CAF50), Color(0xFF00BCD4)],
  [Color(0xFF3F51B5), Color(0xFF9C27B0)],
  [Color(0xFFFFC107), Color(0xFFE91E63)],
  [Color(0xFF009688), Color(0xFF2196F3)],
];

List<Color> _gradientForId(String id) {
  final index = id.hashCode.abs() % _fallbackGradients.length;
  return _fallbackGradients[index];
}

// ─── Song ───────────────────────────────────────────────────────────────────

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;

  // Visual fallbacks (used by existing UI widgets)
  final List<Color> artGradient;
  final IconData artIcon;

  // API data (optional — null when using sample data)
  final String? imageUrl;
  final String? downloadUrl;
  final List<ImageQuality> images;
  final List<DownloadQuality> downloadUrls;
  final String? year;
  final String? language;
  final bool? hasLyrics;
  final int? playCount;
  final String? albumId;
  final List<ArtistInfo> primaryArtists;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artGradient,
    this.artIcon = Icons.music_note,
    this.imageUrl,
    this.downloadUrl,
    this.images = const [],
    this.downloadUrls = const [],
    this.year,
    this.language,
    this.hasLyrics,
    this.playCount,
    this.albumId,
    this.primaryArtists = const [],
  });

  /// Creates a [Song] from the JioSaavn search/songs API response item.
  factory Song.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>?)
            ?.map((e) => ImageQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final downloads = (json['downloadUrl'] as List<dynamic>?)
            ?.map((e) => DownloadQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Extract primary artists
    List<ArtistInfo> primaryArtists = [];
    String artistName = '';
    if (json['artists'] != null && json['artists'] is Map) {
      final artists = json['artists'] as Map<String, dynamic>;
      primaryArtists = (artists['primary'] as List<dynamic>?)
              ?.map((e) => ArtistInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      artistName = primaryArtists.map((a) => a.name).join(', ');
    }
    // Fallback for global search response which uses 'primaryArtists' string
    if (artistName.isEmpty) {
      artistName = json['primaryArtists'] as String? ??
          json['singers'] as String? ??
          'Unknown Artist';
    }

    // Album name
    String albumName = '';
    String? albumId;
    if (json['album'] != null && json['album'] is Map) {
      albumName = json['album']['name'] as String? ?? '';
      albumId = (json['album']['id'] ?? '').toString();
    } else if (json['album'] is String) {
      albumName = json['album'] as String;
    }

    final id = (json['id'] ?? '').toString();
    final durationSecs = json['duration'] as int? ?? 0;

    return Song(
      id: id,
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      artist: artistName,
      album: albumName,
      duration: Duration(seconds: durationSecs),
      artGradient: _gradientForId(id),
      artIcon: Icons.music_note,
      imageUrl: bestImageUrl(images),
      downloadUrl: bestDownloadUrl(downloads),
      images: images,
      downloadUrls: downloads,
      year: json['year']?.toString(),
      language: json['language'] as String?,
      hasLyrics: json['hasLyrics'] as bool?,
      playCount: json['playCount'] as int?,
      albumId: albumId,
      primaryArtists: primaryArtists,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'duration': duration.inSeconds,
        'year': year,
        'language': language,
        'hasLyrics': hasLyrics,
        'playCount': playCount,
        'album': {'id': albumId ?? '', 'name': album},
        'artists': {
          'primary': primaryArtists.map((a) => a.toJson()).toList(),
        },
        'image': images.map((e) => e.toJson()).toList(),
        'downloadUrl': downloadUrls.map((e) => e.toJson()).toList(),
      };

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Whether this song has a network image (from API).
  bool get hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Whether this song has a playable download URL.
  bool get hasDownloadUrl => downloadUrl != null && downloadUrl!.isNotEmpty;
}

// ─── Album ──────────────────────────────────────────────────────────────────

class Album {
  final String id;
  final String title;
  final String artist;
  final List<Color> artGradient;
  final IconData artIcon;
  final List<String> songIds;

  // API data
  final String? imageUrl;
  final List<ImageQuality> images;
  final String? year;
  final String? language;
  final String? description;
  final int? songCount;
  final List<ArtistInfo> primaryArtists;
  final List<Song> songs;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artGradient,
    this.artIcon = Icons.album,
    required this.songIds,
    this.imageUrl,
    this.images = const [],
    this.year,
    this.language,
    this.description,
    this.songCount,
    this.primaryArtists = const [],
    this.songs = const [],
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>?)
            ?.map((e) => ImageQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<ArtistInfo> primaryArtists = [];
    String artistName = '';
    if (json['artists'] != null && json['artists'] is Map) {
      primaryArtists = (json['artists']['primary'] as List<dynamic>?)
              ?.map((e) => ArtistInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      artistName = primaryArtists.map((a) => a.name).join(', ');
    }
    if (artistName.isEmpty) {
      artistName = json['artist'] as String? ?? 'Unknown Artist';
    }

    // Parse embedded songs if present
    final songsJson = json['songs'] as List<dynamic>? ?? [];
    final songs = songsJson
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList();

    final id = (json['id'] ?? '').toString();

    return Album(
      id: id,
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      artist: artistName,
      artGradient: _gradientForId(id),
      artIcon: Icons.album,
      songIds: songs.map((s) => s.id).toList(),
      imageUrl: bestImageUrl(images),
      images: images,
      year: json['year']?.toString(),
      language: json['language'] as String?,
      description: json['description'] as String?,
      songCount: json['songCount'] as int?,
      primaryArtists: primaryArtists,
      songs: songs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'year': year,
        'language': language,
        'description': description,
        'songCount': songCount,
        'artists': {
          'primary': primaryArtists.map((a) => a.toJson()).toList(),
        },
        'image': images.map((e) => e.toJson()).toList(),
        'songs': songs.map((s) => s.toJson()).toList(),
      };

  bool get hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;
}

// ─── Playlist ───────────────────────────────────────────────────────────────

class Playlist {
  final String id;
  final String title;
  final String description;
  final List<Color> artGradient;
  final IconData artIcon;
  final List<String> songIds;

  // API data
  final String? imageUrl;
  final List<ImageQuality> images;
  final String? language;
  final int? songCount;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.artGradient,
    this.artIcon = Icons.playlist_play,
    required this.songIds,
    this.imageUrl,
    this.images = const [],
    this.language,
    this.songCount,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>?)
            ?.map((e) => ImageQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final id = (json['id'] ?? '').toString();

    return Playlist(
      id: id,
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      artGradient: _gradientForId(id),
      artIcon: Icons.playlist_play,
      songIds: const [],
      imageUrl: bestImageUrl(images),
      images: images,
      language: json['language'] as String?,
      songCount: json['songCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'description': description,
        'language': language,
        'songCount': songCount,
        'image': images.map((e) => e.toJson()).toList(),
      };

  bool get hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;
}

// ─── Artist ─────────────────────────────────────────────────────────────────

class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final List<ImageQuality> images;
  final String? url;
  final String? role;
  final String? type;
  final String? dominantLanguage;
  final String? dominantType;
  final int? followerCount;
  final int? fanCount;
  final bool? isVerified;
  final List<Song> topSongs;
  final List<Album> topAlbums;
  final List<Song> singles;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.images = const [],
    this.url,
    this.role,
    this.type,
    this.dominantLanguage,
    this.dominantType,
    this.followerCount,
    this.fanCount,
    this.isVerified,
    this.topSongs = const [],
    this.topAlbums = const [],
    this.singles = const [],
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>?)
            ?.map((e) => ImageQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Artist(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      imageUrl: bestImageUrl(images),
      images: images,
      url: json['url'] as String?,
      role: json['role'] as String?,
      type: json['type'] as String?,
      dominantLanguage: json['dominantLanguage'] as String?,
      dominantType: json['dominantType'] as String?,
      followerCount: json['followerCount'] as int?,
      fanCount: json['fanCount'] as int?,
      isVerified: json['isVerified'] as bool?,
      topSongs: (json['topSongs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topAlbums: (json['topAlbums'] as List<dynamic>?)
              ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      singles: (json['singles'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'role': role,
        'type': type,
        'image': images.map((e) => e.toJson()).toList(),
      };

  bool get hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;

  List<Color> get artGradient => _gradientForId(id);
}

// ─── Enums ──────────────────────────────────────────────────────────────────

enum RepeatMode { off, one, all }
