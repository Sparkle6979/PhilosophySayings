import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/onboarding_page.dart';
import 'services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize PreferenceService
  final prefs = PreferenceService();
  await prefs.init();

  runApp(MyApp(isFirstRun: prefs.isFirstRun));
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;

  const MyApp({Key? key, required this.isFirstRun}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Philosophy Sayings',
      debugShowCheckedModeBanner: false, // 去掉右上角的 Debug 标签
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        // 全局配置 Google Fonts，让整个 App 都有统一的文字风格
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: isFirstRun ? const OnboardingPage() : const HomePage(),
    );
  }
}
