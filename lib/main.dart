import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/onboarding_page.dart';
import 'services/preference_service.dart';

void main() async {
  // 1. Flutter 引擎绑定：在执行任何需要与原生平台层 (如 iOS/Android) 交互的代码前，必须调用。
  // SharedPreference 的初始化就需要这一步。
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 初始化全局服务 (Service Layer)
  // 这里我们使用单例模式 (Singleton) 获取 PreferenceService。
  // 初始化过程是异步的 (从本地磁盘读取设置)，所以加上 await。
  final prefs = PreferenceService();
  await prefs.init();

  // 3. 启动应用
  // 将通过读取本地缓存判断是否为首次运行，传入顶层 Widget。
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
