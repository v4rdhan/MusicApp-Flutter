import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final List<Color> artGradient;
  final IconData artIcon;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artGradient,
    this.artIcon = Icons.music_note,
  });

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class Album {
  final String id;
  final String title;
  final String artist;
  final List<Color> artGradient;
  final IconData artIcon;
  final List<String> songIds;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artGradient,
    this.artIcon = Icons.album,
    required this.songIds,
  });
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final List<Color> artGradient;
  final IconData artIcon;
  final List<String> songIds;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.artGradient,
    this.artIcon = Icons.playlist_play,
    required this.songIds,
  });
}

enum RepeatMode { off, one, all }
