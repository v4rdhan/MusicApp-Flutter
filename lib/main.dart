import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_handler.dart';
import 'services/player_controller.dart';
import 'services/api_service.dart';
import 'services/home_view_model.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_app.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  runApp(MusicApp(audioHandler: audioHandler));
}

class MusicApp extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  const MusicApp({super.key, required this.audioHandler});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  late final MusicPlayerController _playerController;
  late final ApiService _apiService;
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _playerController = MusicPlayerController(audioHandler: widget.audioHandler);
    _apiService = ApiService();
    _homeViewModel = HomeViewModel(apiService: _apiService);
  }

  @override
  void dispose() {
    _playerController.dispose();
    _homeViewModel.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MusicPlayerProvider(
      controller: _playerController,
      child: HomeViewModelProvider(
        viewModel: _homeViewModel,
        child: MaterialApp(
          title: 'Music App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0A0F),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              secondary: Color(0xFFE040FB),
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            splashColor: const Color(0xFF6C63FF).withOpacity(0.08),
            highlightColor: Colors.white.withOpacity(0.03),
          ),
          home: const AppShell(),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayerProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Subtle background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Mini Player + Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Player
                if (player.hasSong) const MiniPlayer(),

                // Bottom Navigation
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0F).withOpacity(0.95),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            isSelected: _currentIndex == 0,
                            onTap: () =>
                                setState(() => _currentIndex = 0),
                          ),
                          _NavItem(
                            icon: Icons.search_rounded,
                            label: 'Search',
                            isSelected: _currentIndex == 1,
                            onTap: () =>
                                setState(() => _currentIndex = 1),
                          ),
                          _NavItem(
                            icon: Icons.library_music_rounded,
                            label: 'Library',
                            isSelected: _currentIndex == 2,
                            onTap: () =>
                                setState(() => _currentIndex = 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.15)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
