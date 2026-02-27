import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/llm_config.dart';

class PreferenceService {
  static const String _keyLLMConfig = 'llm_config';
  static const String _keyFirstRun = 'is_first_run';
  static const String _keyDailyUsageDate = 'daily_usage_date';
  static const String _keyDailyUsageCount = 'daily_usage_count';
  static const int maxDailyLimit = 20;

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

  // --- Experience Mode Quota (防薅羊毛机制) ---
  // 判断当前用户是否还有体验额度 (每日 20 次上限)
  bool canUseExperienceMode() {
    final config = getLLMConfig();
    if (config.mode != AppMode.experience) {
      return true; // 极速模式使用用户自定义 Key，不设限制，由大模型平台自行拦截
    }

    final today = _getTodayString();
    final lastDate = _prefs.getString(_keyDailyUsageDate) ?? '';

    // 如果上次使用的日期不是今天，说明是新的一天，额度刷新
    if (lastDate != today) {
      return true;
    }

    // 检查今日已用次数是否小于最大限制 (20)
    final count = _prefs.getInt(_keyDailyUsageCount) ?? 0;
    return count < maxDailyLimit;
  }

  // 每次成功调用大模型后，调用此方法来扣减额度
  Future<void> incrementExperienceUsage() async {
    final config = getLLMConfig();
    if (config.mode != AppMode.experience) {
      return;
    }

    final today = _getTodayString();
    final lastDate = _prefs.getString(_keyDailyUsageDate) ?? '';

    if (lastDate != today) {
      await _prefs.setString(_keyDailyUsageDate, today);
      await _prefs.setInt(_keyDailyUsageCount, 1);
    } else {
      final count = _prefs.getInt(_keyDailyUsageCount) ?? 0;
      await _prefs.setInt(_keyDailyUsageCount, count + 1);
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
