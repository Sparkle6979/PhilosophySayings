import 'dart:math';
import '../models/quote.dart';

// Service Layer: 负责所有的数据获取
// 这里我们先用 Mock 数据来测试 UI，之后会替换成真实的 HTTP 请求
class LLMService {
  // 模拟一个网络延迟
  Future<Quote> fetchRandomQuote() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 这里模拟 LLM 返回的 JSON 结构
    // 在真实 Agent 开发中，我们会 Prompt LLM 返回这种标准格式
    final mockData = [
      {
        "text": "那些听不见音乐的人，认为跳舞的人疯了。",
        "author": "尼采",
        "bio": "弗里德里希·尼采（1844-1900），德国哲学家，主要探讨权力意志、超人学说。",
        "explanation":
            "这句话常常用来比喻那些因为缺乏理解（听不见音乐）而对他人行为（跳舞）产生误解和偏见的人。在尼采看来，只有通过深刻的生命体验，才能理解“酒神精神”般的狂醉与释放。",
        "imageUrl": "assets/images/nietzsche.png",
      },
      {
        "text": "知之为知之，不知为不知，是知也。",
        "author": "孔子",
        "bio": "孔子（公元前551年―公元前479年），中国古代思想家、教育家，儒家学派创始人。",
        "explanation":
            "这是关于认知的诚实。它不仅仅是承认无知，而是将“承认无知”本身视为一种智慧。在信息爆炸的今天，保持这种智识上的谦逊尤为重要。",
        "imageUrl": "assets/images/confucius.png",
      },
    ];

    final randomItem = mockData[Random().nextInt(mockData.length)];

    // 动态解析图片
    final authorName = randomItem['author'] as String;
    final resolvedImage = _resolveImageUrl(authorName);

    // 更新 randomItem 中的 imageUrl
    // 注意：这里我们创建一个新的 Map，因为 randomItem 可能是不可变的（取决于实现）
    final itemWithImage = Map<String, dynamic>.from(randomItem);
    itemWithImage['imageUrl'] = resolvedImage;

    return Quote.fromJson(itemWithImage);
  }

  /// 智能资产映射器: 根据作者名模糊匹配本地资源
  String? _resolveImageUrl(String authorName) {
    final normalizedName = authorName.toLowerCase().trim();

    // 映射规则表: multiline inputs match a single asset
    // 格式: (Keywords List, Asset Path)
    final rules = [
      (
        keywords: ['nietzsche', '尼采', 'friedrich'],
        asset: 'assets/images/nietzsche.png',
      ),
      (
        keywords: ['confucius', '孔子', 'kongzi', 'kong'],
        asset: 'assets/images/confucius.png',
      ),
      (keywords: ['plato', '柏拉图'], asset: 'assets/images/plato.png'),
      (keywords: ['socrates', '苏格拉底'], asset: 'assets/images/socrates.png'),
      (keywords: ['aristotle', '亚里士多德'], asset: 'assets/images/aristotle.png'),
    ];

    for (final rule in rules) {
      for (final keyword in rule.keywords) {
        if (normalizedName.contains(keyword)) {
          return rule.asset;
        }
      }
    }

    // 默认回退 (如果没有匹配到任何特定的哲学家，可以返回 null 或通用图)
    return null; // QuoteCard 会处理 null Case，显示默认 Icon
  }
}
