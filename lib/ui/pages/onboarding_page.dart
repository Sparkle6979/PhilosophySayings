import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/preference_service.dart';
import '../../services/ambient_service.dart';
import '../../models/llm_config.dart';
import 'home_page.dart';
import 'settings_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  void _finishOnboarding(
    BuildContext context, {
    bool navigateToSettings = false,
  }) async {
    final prefs = PreferenceService();
    await prefs.init(); // Ensure init
    await prefs.completeOnboarding(); // Mark as not first run

    if (!context.mounted) return;

    if (navigateToSettings) {
      // Auto-enable Speed Mode (Deep Connection) for Seekers
      final config = prefs.getLLMConfig().copyWith(mode: AppMode.speed);
      await prefs.saveLLMConfig(config);

      if (!context.mounted) return;

      // Go to Settings, then user can go back to Home manually or we push Home then Settings
      // Better flow: Push Replacement to Home, then Push Settings on top
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
    } else {
      // Direct to Home (Experience Mode is default)
      // Debug fix: Ensure we reset to Experience mode if user chose Wanderer
      final config = prefs.getLLMConfig().copyWith(mode: AppMode.experience);
      await prefs.saveLLMConfig(config);

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image & Title Section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Background Image (Right/Center)
                    Positioned(
                      right: -50,
                      top: 20,
                      bottom: 20,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          'assets/images/philosopher_default.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Left-Aligned Text
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                      ), // Shift right slightly
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: double.infinity,
                          ), // Force full width
                          const Text(
                            "全知之海",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: Colors.black87,
                              fontFamily:
                                  ' serif', // Use serif if available or default
                            ),
                          ),
                          Text(
                            "Philosophy Sayings",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.cinzel(
                              // Using Google Fonts for English title
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "与跨越时空的思想灵魂，\n进行一场深度的对话。",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Choice A: Wanderer (Experience)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () =>
                      _finishOnboarding(context, navigateToSettings: false),
                  child: const Column(
                    children: [
                      Text(
                        "漫步者 (The Wanderer)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "以游者身份，在此短暂驻足。\n每日虽有界限，亦能窥见星光。",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Choice B: Seeker (Speed Mode/Custom Key)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  onPressed: () =>
                      _finishOnboarding(context, navigateToSettings: true),
                  child: const Column(
                    children: [
                      Text(
                        "求索者 (The Seeker)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "手持真理之钥 (API Key)，\n开启无尽的思辨之门。",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _buildMusicToggle(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the ambient music toggle icon.
  /// Placed on the initial screen to allow immediate user interaction,
  /// satisfying Web Audio API restrictions which require a user gesture.
  Widget _buildMusicToggle() {
    return Align(
      alignment: Alignment.center,
      child: ListenableBuilder(
        listenable: AmbientService.instance,
        builder: (context, _) {
          final isEnabled = AmbientService.instance.isEnabled;
          return IconButton(
            icon: Icon(
              isEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
              color: isEnabled ? Colors.black87 : Colors.black26,
              size: 24,
            ),
            tooltip: isEnabled ? "关闭环境音 / Disable Ambient Music" : "开启环境音 / Enable Ambient Music",
            onPressed: () async {
              HapticFeedback.lightImpact();
              await AmbientService.instance.toggle();
            },
          );
        },
      ),
    );
  }
}
