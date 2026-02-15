import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/llm_config.dart';

class PreferenceService {
  static const String _keyLLMConfig = 'llm_config';
  static const String _keyFirstRun = 'is_first_run';

  // Singleton pattern
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- First Run Logic ---
  bool get isFirstRun => _prefs.getBool(_keyFirstRun) ?? true;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyFirstRun, false);
  }

  // --- LLM Config ---
  LLMConfig getLLMConfig() {
    final String? jsonString = _prefs.getString(_keyLLMConfig);
    if (jsonString == null) {
      return const LLMConfig(); // Default: Experience Mode + DeepSeek
    }
    try {
      return LLMConfig.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return const LLMConfig(); // Fallback on error
    }
  }

  Future<void> saveLLMConfig(LLMConfig config) async {
    await _prefs.setString(_keyLLMConfig, jsonEncode(config.toJson()));
  }
}
