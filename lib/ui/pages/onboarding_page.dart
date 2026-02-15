import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
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
              const Spacer(),
              // Title
              const Text(
                "哲学 · 密室",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "与跨越时空的思想灵魂，\n进行一场深度的对话。",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const Spacer(),
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
                        "以访客身份，在此短暂驻足。\n每日虽有界限，亦能窥见星光。",
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
            ],
          ),
        ),
      ),
    );
  }
}
