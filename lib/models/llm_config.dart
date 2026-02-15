enum LLMProvider { deepseek, qwen, minimax }

enum AppMode {
  experience, // 内置体验模式
  speed, // 极速模式 (自定义 Key)
}

class LLMConfig {
  final AppMode mode;
  final LLMProvider provider;
  final String apiKey;

  // 预设配置
  static const Map<LLMProvider, String> _baseUrls = {
    LLMProvider.deepseek: 'https://api.deepseek.com',
    LLMProvider.qwen: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    LLMProvider.minimax: 'https://api.minimax.chat/v1',
  };

  static const Map<LLMProvider, String> _modelNames = {
    LLMProvider.deepseek: 'deepseek-chat',
    LLMProvider.qwen: 'qwen-plus',
    LLMProvider.minimax: 'abab6.5s-chat',
  };

  const LLMConfig({
    this.mode = AppMode.experience,
    this.provider = LLMProvider.deepseek,
    this.apiKey = '',
  });

  String get baseUrl => _baseUrls[provider]!;
  String get modelName => _modelNames[provider]!;

  // JSON Serialization
  Map<String, dynamic> toJson() => {
    'mode': mode.index,
    'provider': provider.index,
    'apiKey': apiKey,
  };

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      mode: AppMode.values[json['mode'] ?? 0],
      provider: LLMProvider.values[json['provider'] ?? 0],
      apiKey: json['apiKey'] ?? '',
    );
  }

  // CopyWith
  LLMConfig copyWith({AppMode? mode, LLMProvider? provider, String? apiKey}) {
    return LLMConfig(
      mode: mode ?? this.mode,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
