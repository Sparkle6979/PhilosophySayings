import 'dart:math';
import '../models/quote.dart';

// Service Layer: 负责所有的数据获取
// 这里我们先用 Mock 数据来测试 UI，之后会替换成真实的 HTTP 请求
class LLMService {
  // TODO: Replace with your actual implementation or environment variables
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl =
      'https://api.openai.com/v1'; // Or DeepSeek/Gemini URL

  // 模拟一个网络延迟
  Future<Quote> fetchRandomQuote() async {
    // 如果没有配置 Key，使用 Mock 数据
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      return _fetchMockQuote();
    }

    try {
      // 真实 HTTP 请求代码骨架 (Generic Skeleton)
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // or deepseek-chat
          'messages': [
            {
              'role': 'system',
              'content': 'You are a profound philosopher. Output strict JSON.',
            },
            // ... prompt logic
          ],
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        // Parse JSON and return Quote
      }
      */

      // 暂时 Fallback 到 Mock
      return _fetchMockQuote();
    } catch (e) {
      print('Error fetching quote: $e');
      return _fetchMockQuote();
    }
  }

  Future<Quote> _fetchMockQuote() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = [
      {
        "text": "那些听不见音乐的人，认为跳舞的人疯了。",
        "author": "尼采",
        "tagline": "手拿锤子在悬崖边起舞的反叛者",
        "bio": "弗里德里希·尼采（1844-1900），德国哲学家，主要探讨权力意志、超人学说。",
        "explanation":
            "这句话常常用来比喻那些因为缺乏理解（听不见音乐）而对他人行为（跳舞）产生误解和偏见的人。在尼采看来，只有通过深刻的生命体验，才能理解“酒神精神”般的狂醉与释放。",
        "imageUrl": "assets/images/nietzsche_0.png",
      },
      {
        "text": "知之为知之，不知为不知，是知也。",
        "author": "孔子",
        "tagline": "万世师表，温良恭俭让的铸魂人",
        "bio": "孔子（公元前551年―公元前479年），中国古代思想家、教育家，儒家学派创始人。",
        "explanation":
            "这是关于认知的诚实。它不仅仅是承认无知，而是将“承认无知”本身视为一种智慧。在信息爆炸的今天，保持这种智识上的谦逊尤为重要。",
        "imageUrl": "assets/images/confucius_0.png",
      },
      {
        "text": "语言是存在的家。",
        "author": "马丁·海德格尔",
        "tagline": "在黑森林里守望存在的牧羊人",
        "bio": "马丁·海德格尔（1889-1976），德国哲学家，20世纪存在主义哲学的代表人物。",
        "explanation":
            "这句话揭示了语言与存在之间深刻的本体论关系。人以语言为家，在语言中栖居；通过语言，人得以触碰和理解存在的真理。语言不仅仅是工具，更是我们构建和理解世界的根基。",
        "imageUrl": "assets/images/heidegger_0.png",
      },
    ];

    final randomItem = mockData[Random().nextInt(mockData.length)];

    // 动态解析图片
    final authorName = randomItem['author'] as String;
    final resolvedImage = _resolveImageUrl(authorName);

    // 更新 randomItem 中的 imageUrl
    final itemWithImage = Map<String, dynamic>.from(randomItem);
    itemWithImage['imageUrl'] = resolvedImage;

    return Quote.fromJson(itemWithImage);
  }

  /// 智能资产映射器: 根据作者名模糊匹配本地资源
  String? _resolveImageUrl(String authorName) {
    final normalizedName = authorName.toLowerCase().trim();

    // 映射规则表: multiline inputs match a LIST of assets
    // 格式: (Keywords List, Assets List)
    final rules = [
      (
        keywords: ['nietzsche', '尼采', 'friedrich'],
        assets: [
          'assets/images/nietzsche_0.png',
          'assets/images/nietzsche_1.png',
          'assets/images/nietzsche_2.png',
        ],
      ),
      (
        keywords: ['confucius', '孔子', 'kongzi', 'kong'],
        assets: [
          'assets/images/confucius_0.png',
          'assets/images/confucius_1.png',
          'assets/images/confucius_2.png',
        ],
      ),
      (
        keywords: ['heidegger', '海德格尔', 'martin'],
        assets: [
          'assets/images/heidegger_0.png',
          'assets/images/heidegger_1.png',
          'assets/images/heidegger_2.png',
        ],
      ),
      // 单张图的我们也转为 List 处理，保持一致性
      (keywords: ['plato', '柏拉图'], assets: ['assets/images/plato.png']),
      (keywords: ['socrates', '苏格拉底'], assets: ['assets/images/socrates.png']),
      (
        keywords: ['aristotle', '亚里士多德'],
        assets: ['assets/images/aristotle.png'],
      ),
    ];

    for (final rule in rules) {
      for (final keyword in rule.keywords) {
        if (normalizedName.contains(keyword)) {
          // 随机返回一张图片
          final assets = rule.assets;
          return assets[Random().nextInt(assets.length)];
        }
      }
    }

    // 默认回退
    return null;
  }
}
