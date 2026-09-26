import 'package:flutter/material.dart';
import '../models/song.dart';

// ─── Gradient Palettes ─────────────────────────────────────────────────────
const _gPurpleBlue = [Color(0xFF6C63FF), Color(0xFF3F51B5)];
const _gPinkOrange = [Color(0xFFE040FB), Color(0xFFFF5722)];
const _gCyanTeal = [Color(0xFF00BCD4), Color(0xFF009688)];
const _gOrangeYellow = [Color(0xFFFF9800), Color(0xFFFFEB3B)];
const _gDeepPurple = [Color(0xFF9C27B0), Color(0xFF6C63FF)];
const _gRedPink = [Color(0xFFE91E63), Color(0xFFF44336)];
const _gGreenCyan = [Color(0xFF4CAF50), Color(0xFF00BCD4)];
const _gIndigoPurple = [Color(0xFF3F51B5), Color(0xFF9C27B0)];
const _gAmberRed = [Color(0xFFFFC107), Color(0xFFE91E63)];
const _gTealBlue = [Color(0xFF009688), Color(0xFF2196F3)];
const _gRosePink = [Color(0xFFFF6B9D), Color(0xFFC44569)];
const _gSunset = [Color(0xFFFF6F61), Color(0xFFDE4463)];
const _gMidnight = [Color(0xFF2C3E50), Color(0xFF4CA1AF)];
const _gForest = [Color(0xFF11998E), Color(0xFF38EF7D)];
const _gLavender = [Color(0xFFA18CD1), Color(0xFFFBC2EB)];

// ─── Songs ─────────────────────────────────────────────────────────────────
final List<Song> allSongs = [
  Song(
    id: 's1',
    title: 'Midnight Dreams',
    artist: 'Luna Echo',
    album: 'Midnight Dreams',
    duration: const Duration(minutes: 3, seconds: 45),
    artGradient: _gDeepPurple,
    artIcon: Icons.nightlight_round,
  ),
  Song(
    id: 's2',
    title: 'Electric Pulse',
    artist: 'Neon Waves',
    album: 'Electric Vibes',
    duration: const Duration(minutes: 4, seconds: 12),
    artGradient: _gPinkOrange,
    artIcon: Icons.electric_bolt,
  ),
  Song(
    id: 's3',
    title: 'Golden Hour',
    artist: 'Sunset Drive',
    album: 'Golden Collection',
    duration: const Duration(minutes: 3, seconds: 28),
    artGradient: _gOrangeYellow,
    artIcon: Icons.wb_sunny,
  ),
  Song(
    id: 's4',
    title: 'Starlight Serenade',
    artist: 'Cosmic Drift',
    album: 'Cosmic Journey',
    duration: const Duration(minutes: 5, seconds: 3),
    artGradient: _gPurpleBlue,
    artIcon: Icons.star,
  ),
  Song(
    id: 's5',
    title: 'Ocean Waves',
    artist: 'Azure Tide',
    album: 'Deep Waters',
    duration: const Duration(minutes: 4, seconds: 37),
    artGradient: _gCyanTeal,
    artIcon: Icons.waves,
  ),
  Song(
    id: 's6',
    title: 'City Lights',
    artist: 'Metro Beats',
    album: 'Urban Pulse',
    duration: const Duration(minutes: 3, seconds: 15),
    artGradient: _gAmberRed,
    artIcon: Icons.location_city,
  ),
  Song(
    id: 's7',
    title: 'Velvet Sky',
    artist: 'Aurora Sound',
    album: 'Northern Lights',
    duration: const Duration(minutes: 4, seconds: 52),
    artGradient: _gLavender,
    artIcon: Icons.cloud,
  ),
  Song(
    id: 's8',
    title: 'Digital Rain',
    artist: 'Cyber Flux',
    album: 'Binary World',
    duration: const Duration(minutes: 3, seconds: 58),
    artGradient: _gGreenCyan,
    artIcon: Icons.code,
  ),
  Song(
    id: 's9',
    title: 'Summer Breeze',
    artist: 'Tropical Haze',
    album: 'Island Vibes',
    duration: const Duration(minutes: 3, seconds: 33),
    artGradient: _gForest,
    artIcon: Icons.beach_access,
  ),
  Song(
    id: 's10',
    title: 'Neon Nights',
    artist: 'Synth Valley',
    album: 'Synthwave Dreams',
    duration: const Duration(minutes: 4, seconds: 45),
    artGradient: _gRedPink,
    artIcon: Icons.nightlife,
  ),
  Song(
    id: 's11',
    title: 'Crystal Clear',
    artist: 'Diamond Echo',
    album: 'Reflections',
    duration: const Duration(minutes: 3, seconds: 22),
    artGradient: _gTealBlue,
    artIcon: Icons.diamond,
  ),
  Song(
    id: 's12',
    title: 'Fade Away',
    artist: 'Ghost Signal',
    album: 'Phantom Frequencies',
    duration: const Duration(minutes: 4, seconds: 8),
    artGradient: _gMidnight,
    artIcon: Icons.blur_on,
  ),
  Song(
    id: 's13',
    title: 'Rise Up',
    artist: 'Phoenix Fire',
    album: 'Ashes to Flames',
    duration: const Duration(minutes: 3, seconds: 55),
    artGradient: _gSunset,
    artIcon: Icons.local_fire_department,
  ),
  Song(
    id: 's14',
    title: 'Deep Blue',
    artist: 'Ocean Floor',
    album: 'Abyssal Zone',
    duration: const Duration(minutes: 5, seconds: 17),
    artGradient: _gIndigoPurple,
    artIcon: Icons.water,
  ),
  Song(
    id: 's15',
    title: 'Wild Heart',
    artist: 'Thunder Chase',
    album: 'Storm Riders',
    duration: const Duration(minutes: 3, seconds: 41),
    artGradient: _gRosePink,
    artIcon: Icons.favorite,
  ),
  Song(
    id: 's16',
    title: 'Lunar Eclipse',
    artist: 'Luna Echo',
    album: 'Midnight Dreams',
    duration: const Duration(minutes: 4, seconds: 23),
    artGradient: _gDeepPurple,
    artIcon: Icons.dark_mode,
  ),
  Song(
    id: 's17',
    title: 'Voltage',
    artist: 'Neon Waves',
    album: 'Electric Vibes',
    duration: const Duration(minutes: 3, seconds: 38),
    artGradient: _gPinkOrange,
    artIcon: Icons.flash_on,
  ),
  Song(
    id: 's18',
    title: 'Dusk till Dawn',
    artist: 'Sunset Drive',
    album: 'Golden Collection',
    duration: const Duration(minutes: 4, seconds: 5),
    artGradient: _gOrangeYellow,
    artIcon: Icons.wb_twilight,
  ),
  Song(
    id: 's19',
    title: 'Nebula',
    artist: 'Cosmic Drift',
    album: 'Cosmic Journey',
    duration: const Duration(minutes: 6, seconds: 12),
    artGradient: _gPurpleBlue,
    artIcon: Icons.auto_awesome,
  ),
  Song(
    id: 's20',
    title: 'Coral Reef',
    artist: 'Azure Tide',
    album: 'Deep Waters',
    duration: const Duration(minutes: 3, seconds: 49),
    artGradient: _gCyanTeal,
    artIcon: Icons.sailing,
  ),
];

// ─── Albums ────────────────────────────────────────────────────────────────
final List<Album> allAlbums = [
  Album(
    id: 'a1',
    title: 'Midnight Dreams',
    artist: 'Luna Echo',
    artGradient: _gDeepPurple,
    artIcon: Icons.nightlight_round,
    songIds: ['s1', 's16'],
  ),
  Album(
    id: 'a2',
    title: 'Electric Vibes',
    artist: 'Neon Waves',
    artGradient: _gPinkOrange,
    artIcon: Icons.electric_bolt,
    songIds: ['s2', 's17'],
  ),
  Album(
    id: 'a3',
    title: 'Golden Collection',
    artist: 'Sunset Drive',
    artGradient: _gOrangeYellow,
    artIcon: Icons.wb_sunny,
    songIds: ['s3', 's18'],
  ),
  Album(
    id: 'a4',
    title: 'Cosmic Journey',
    artist: 'Cosmic Drift',
    artGradient: _gPurpleBlue,
    artIcon: Icons.star,
    songIds: ['s4', 's19'],
  ),
  Album(
    id: 'a5',
    title: 'Deep Waters',
    artist: 'Azure Tide',
    artGradient: _gCyanTeal,
    artIcon: Icons.waves,
    songIds: ['s5', 's20'],
  ),
  Album(
    id: 'a6',
    title: 'Urban Pulse',
    artist: 'Metro Beats',
    artGradient: _gAmberRed,
    artIcon: Icons.location_city,
    songIds: ['s6'],
  ),
  Album(
    id: 'a7',
    title: 'Northern Lights',
    artist: 'Aurora Sound',
    artGradient: _gLavender,
    artIcon: Icons.cloud,
    songIds: ['s7'],
  ),
  Album(
    id: 'a8',
    title: 'Storm Riders',
    artist: 'Thunder Chase',
    artGradient: _gRosePink,
    artIcon: Icons.favorite,
    songIds: ['s15'],
  ),
];

// ─── Playlists ─────────────────────────────────────────────────────────────
final List<Playlist> allPlaylists = [
  Playlist(
    id: 'p1',
    title: 'Chill Vibes',
    description: 'Relax and unwind',
    artGradient: _gCyanTeal,
    artIcon: Icons.spa,
    songIds: ['s5', 's7', 's9', 's11', 's14'],
  ),
  Playlist(
    id: 'p2',
    title: 'Workout Energy',
    description: 'Push your limits',
    artGradient: _gRedPink,
    artIcon: Icons.fitness_center,
    songIds: ['s2', 's6', 's10', 's13', 's15'],
  ),
  Playlist(
    id: 'p3',
    title: 'Late Night Drives',
    description: 'Cruise through the city',
    artGradient: _gMidnight,
    artIcon: Icons.directions_car,
    songIds: ['s1', 's4', 's10', 's12', 's16'],
  ),
  Playlist(
    id: 'p4',
    title: 'Focus & Study',
    description: 'Concentrate deeply',
    artGradient: _gGreenCyan,
    artIcon: Icons.psychology,
    songIds: ['s8', 's11', 's14', 's19', 's20'],
  ),
  Playlist(
    id: 'p5',
    title: 'Party Mix',
    description: 'Turn up the volume',
    artGradient: _gPinkOrange,
    artIcon: Icons.celebration,
    songIds: ['s2', 's3', 's6', 's10', 's13', 's15', 's17'],
  ),
  Playlist(
    id: 'p6',
    title: 'Acoustic Soul',
    description: 'Raw and authentic',
    artGradient: _gOrangeYellow,
    artIcon: Icons.piano,
    songIds: ['s3', 's7', 's9', 's18'],
  ),
];

// ─── Browse Categories ─────────────────────────────────────────────────────
class BrowseCategory {
  final String title;
  final List<Color> gradient;
  final IconData icon;

  const BrowseCategory({
    required this.title,
    required this.gradient,
    required this.icon,
  });
}

final List<BrowseCategory> browseCategories = [
  BrowseCategory(title: 'Pop', gradient: _gPinkOrange, icon: Icons.music_note),
  BrowseCategory(title: 'Rock', gradient: _gRedPink, icon: Icons.music_note_rounded),
  BrowseCategory(title: 'Hip Hop', gradient: _gAmberRed, icon: Icons.headphones),
  BrowseCategory(title: 'Electronic', gradient: _gPurpleBlue, icon: Icons.equalizer),
  BrowseCategory(title: 'Jazz', gradient: _gOrangeYellow, icon: Icons.piano),
  BrowseCategory(title: 'Classical', gradient: _gLavender, icon: Icons.library_music),
  BrowseCategory(title: 'R&B', gradient: _gDeepPurple, icon: Icons.mic),
  BrowseCategory(title: 'Indie', gradient: _gForest, icon: Icons.landscape),
  BrowseCategory(title: 'Country', gradient: _gSunset, icon: Icons.park),
  BrowseCategory(title: 'Latin', gradient: _gRosePink, icon: Icons.local_fire_department),
  BrowseCategory(title: 'Ambient', gradient: _gMidnight, icon: Icons.nightlight),
  BrowseCategory(title: 'Lo-Fi', gradient: _gTealBlue, icon: Icons.headset),
];

// ─── Helper ────────────────────────────────────────────────────────────────
Song? getSongById(String id) {
  try {
    return allSongs.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}

List<Song> getSongsByIds(List<String> ids) {
  return ids.map((id) => getSongById(id)).whereType<Song>().toList();
}
