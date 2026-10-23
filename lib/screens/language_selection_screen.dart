import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Available music languages with emoji flags for visual appeal.
class _Language {
  final String name;
  final String emoji;
  const _Language(this.name, this.emoji);
}

const List<_Language> _availableLanguages = [
  _Language('English', '🇬🇧'),
  _Language('Hindi', '🇮🇳'),
  _Language('Punjabi', '🎵'),
  _Language('Tamil', '🎶'),
  _Language('Telugu', '🎤'),
  _Language('Bengali', '🎸'),
  _Language('Marathi', '🥁'),
  _Language('Gujarati', '🎹'),
  _Language('Kannada', '🎻'),
  _Language('Malayalam', '🎺'),
  _Language('Urdu', '🎼'),
  _Language('Spanish', '🇪🇸'),
  _Language('Korean', '🇰🇷'),
  _Language('Japanese', '🇯🇵'),
  _Language('Arabic', '🇸🇦'),
  _Language('French', '🇫🇷'),
];

class LanguageSelectionScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onComplete;

  const LanguageSelectionScreen({
    super.key,
    required this.storageService,
    required this.onComplete,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selected = {};
  bool _isSaving = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selected.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    await widget.storageService.saveSelectedLanguages(_selected.toList());
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ─── Icon ───────────────────────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 28),

                // ─── Title ──────────────────────────────────────────
                const Text(
                  'Choose your\nmusic languages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Select one or more to personalize your feed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 32),

                // ─── Language Grid ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableLanguages.map((lang) {
                        final isSelected = _selected.contains(lang.name);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selected.remove(lang.name);
                              } else {
                                _selected.add(lang.name);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.06),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white.withValues(alpha: 0.08),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  lang.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Continue Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selected.isEmpty ? 0.4 : 1.0,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        disabledBackgroundColor:
                            const Color(0xFF6C63FF).withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selected.isEmpty
                                  ? 'Select at least one language'
                                  : 'Continue  →',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
