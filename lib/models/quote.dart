class Quote {
  final String text;
  final String author;
  final String? tagline; // 新增：哲人的一句话形容
  final String explanation; // Agent 提供的"深层批注"
  final String? imageUrl; // 哲学家的图片 URL 或 Asset 路径
  final String? bio; // 哲学家生平简介
  final String? lifeYears; // 生卒年 (e.g. 1844-1900)
  final String? theme; // 此次生成的哲学主题 (e.g. 存在主义)
  final bool isMock; // 是否为降级数据 (Mock/Offline)

  Quote({
    required this.text,
    required this.author,
    this.tagline,
    required this.explanation,
    this.imageUrl,
    this.bio,
    this.lifeYears,
    this.theme,
    this.isMock = false,
  });

  // 用于从 JSON (LLM 返回或 DB 读取) 解析数据
  // 这是 Dart 中最常用的工厂构造函数模式，类似 Java 的 static Quote fromJson(...)
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] ?? '',
      author: json['author'] ?? 'Unknown',
      tagline: json['tagline'],
      explanation: json['explanation'] ?? '',
      imageUrl: json['imageUrl'],
      bio: json['bio'],
      lifeYears: json['life_years'], // 注意 json key 必须对应 prompt 里的 snake_case
      theme: json['theme'],
      isMock: json['isMock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'tagline': tagline,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'bio': bio,
      'life_years': lifeYears,
      'theme': theme,
      'isMock': isMock,
    };
  }
}
