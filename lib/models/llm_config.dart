enum LLMProvider { deepseek, qwen, minimax, moonshot }

enum AppMode {
  experience, // 内置体验模式
  speed, // 极速模式 (自定义 Key)
}

class LLMConfig {
  final AppMode mode;
  final LLMProvider provider;
  final String apiKey;
  final double? temperature;
  final int? maxTokens;

  // 预设配置
  static const Map<LLMProvider, String> _baseUrls = {
    LLMProvider.deepseek: 'https://api.deepseek.com',
    LLMProvider.qwen: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    LLMProvider.minimax: 'https://api.minimax.chat/v1',
    LLMProvider.moonshot: 'https://api.moonshot.cn/v1',
  };

  static const Map<LLMProvider, String> _modelNames = {
    LLMProvider.deepseek: 'deepseek-chat',
    LLMProvider.qwen: 'qwen-max', // Upgraded to max based on user discussion
    LLMProvider.minimax: 'M2-her',
    LLMProvider.moonshot: 'moonshot-v1-128k',
  };

  static const Map<LLMProvider, double> _defaultTemperatures = {
    LLMProvider.deepseek: 1.5,
    LLMProvider.qwen: 0.8,
    LLMProvider.minimax: 1.0,
    LLMProvider.moonshot: 0.3, // Kimi prefers lower temperature for strict JSON
  };

  static const Map<LLMProvider, int> _defaultMaxTokens = {
    LLMProvider.deepseek: 800,
    LLMProvider.qwen: 800,
    LLMProvider.minimax: 800,
    LLMProvider.moonshot: 800,
  };

  const LLMConfig({
    this.mode = AppMode.experience,
    this.provider = LLMProvider.deepseek,
    this.apiKey = '',
    this.temperature,
    this.maxTokens,
  });

  String get baseUrl => _baseUrls[provider]!;
  String get modelName => _modelNames[provider]!;

  double get effectiveTemperature =>
      temperature ?? _defaultTemperatures[provider] ?? 0.7;
  int get effectiveMaxTokens => maxTokens ?? _defaultMaxTokens[provider] ?? 800;

  // JSON Serialization
  Map<String, dynamic> toJson() => {
    'mode': mode.index,
    'provider': provider.index,
    'apiKey': apiKey,
    'temperature': temperature,
    'maxTokens': maxTokens,
  };

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      mode: AppMode.values[json['mode'] ?? 0],
      provider: LLMProvider.values[json['provider'] ?? 0],
      apiKey: json['apiKey'] ?? '',
      temperature: json['temperature'] as double?,
      maxTokens: json['maxTokens'] as int?,
    );
  }

  // CopyWith
  LLMConfig copyWith({
    AppMode? mode,
    LLMProvider? provider,
    String? apiKey,
    double? temperature,
    int? maxTokens,
  }) {
    return LLMConfig(
      mode: mode ?? this.mode,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
