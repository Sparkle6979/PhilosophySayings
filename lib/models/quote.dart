class Quote {
  final String text;
  final String author;
  final String? tagline; // 新增：哲人的一句话形容
  final String explanation; // Agent 提供的"深层批注"
  final String? imageUrl; // 哲学家的图片 URL 或 Asset 路径
  final String? bio; // 哲学家生平简介

  Quote({
    required this.text,
    required this.author,
    this.tagline,
    required this.explanation,
    this.imageUrl,
    this.bio,
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
    };
  }
}
