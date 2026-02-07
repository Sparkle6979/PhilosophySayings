import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import '../models/quote.dart';

// Service Layer: 负责所有的数据获取
class LLMService {
  // TODO: Replace with your actual implementation or environment variables
  // 暂时硬编码 Key，后续会改为从 Settings 读取
  // DeepSeek API Key (Hiding for GitHub upload)
  static const String _apiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: '',
  );

  // DeepSeek Base URL
  // Docs: https://api-docs.deepseek.com/
  static const String _baseUrl = 'https://api.deepseek.com';

  // 最近出现过的哲学家名单 (用于避免短期重复)
  final List<String> _recentAuthors = [];
  // 最近涉及过的哲学领域 (用于强制多元化)
  final List<String> _recentThemes = [];
  // 最近出现过的名言内容 (用于避免内容重复)
  final List<String> _recentQuotes = [];

  // 缓存 Chain 实例，避免重复创建
  late final Runnable _stringChain;

  LLMService() {
    // 初始化 Chain
    // 1. 初始化模型
    final model = ChatOpenAI(
      apiKey: _apiKey,
      baseUrl: _baseUrl,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 1.5, // High temperature for max diversity
        model: 'deepseek-chat',
      ),
    );

    // 2. 定义 Prompt
    final promptTemplate = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate('''
你是一位博古通今的哲学大师。请从**非中国古代**的哲学名家中，随机挑选一位。

**约束条件**:
1. **排除中国古代哲学家**: 聚焦于西方哲学史（古希腊、中世纪、近现代）或其他非中国传统。
2. **避免重复作者**: 不要是以下哲学家：[{excluded_authors}]。
3. **避免重复主题**: 请尽量避开以下哲学领域：[{excluded_themes}]，尝试探索其他领域（如伦理学、形而上学、政治哲学、美学、逻辑学、科学哲学等）。
4. **避免重复名言**: 绝对不要返回以下内容或与之极其相似的名言：[{excluded_quotes}]。
5. **存在主义倾向**: 该用户倾向于使用存在主义（尼采、加缪、海德格尔、萨特、克尔凯郭尔）来探讨现代虚无主义。请在选择时，20% 的时间应优先考虑这些哲学家或主题，但同时也要保持多样性。.
6. 必须返回严格的 JSON 格式。

JSON 字段要求：
- text: 名言正文（中文）。**必须精炼、深刻, 是这句名言最广为流传的版本**，尽量控制在 40 字以内。如果是翻译，请使用优美凝练的中文。
- author: 哲学家姓名（中文）。
- life_years: 哲学家的生卒年（例如 "1844-1900" 或 "前470-前399"）。
- theme: 这句名言所属的哲学领域（例如 "存在主义" 或 "伦理学"）。
- tagline: 一句简短的、极具画面感或深意的形容（Contextual Tagline），不要超过12个字。
- bio: 哲学家生平简介（50字以内）。
- explanation: 对这句名言的深度哲学解析（精炼深刻，150字以内）。
'''),
      HumanChatMessagePromptTemplate.fromTemplate('请赐予我一句智慧。Output JSON only.'),
    ]);

    // 3. 构建 Chain
    // 分步执行以避免泛型类型推断问题
    _stringChain = promptTemplate.pipe(model).pipe(const StringOutputParser());
  }

  /// 核心方法：获取一条随机哲学金句
  Future<Quote> fetchRandomQuote() async {
    // 1. 检查 Key 配置，如果未配置则降级使用 Mock
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      print('⚠️ API Key not detected. Using Mock Data.');
      return _fetchMockQuote();
    }

    try {
      final RunnableOptions options = RunnableOptions();

      // 获取排除列表
      final String excludedAuthorsStr = _recentAuthors.isNotEmpty
          ? _recentAuthors.join(', ')
          : "无";
      final String excludedThemesStr = _recentThemes.isNotEmpty
          ? _recentThemes.join(', ')
          : "无";
      final String excludedQuotesStr = _recentQuotes.isNotEmpty
          ? _recentQuotes.join(' | ') // 使用分隔符避免混淆
          : "无";

      print('🚫 Excluded Authors: $excludedAuthorsStr');
      print('🚫 Excluded Themes: $excludedThemesStr');
      print('🚫 Excluded Quotes: $excludedQuotesStr');

      print('🚀 Sending request to LLM...');
      final String rawContent =
          await _stringChain.invoke({
                'excluded_authors': excludedAuthorsStr,
                'excluded_themes': excludedThemesStr,
                'excluded_quotes': excludedQuotesStr,
              }, options: options)
              as String;

      print('📝 Raw Content: $rawContent');

      // 手动调用 Parser
      final Map<String, dynamic> result = _sanitizeAndParseJson(rawContent);
      print('✅ LLM Response: $result');

      // 6. 后处理：本地资产映射
      final authorName = result['author'] as String;
      final newTheme = result['theme'] as String?;

      // 智能解析图片
      final resolvedImage = await _resolveImageUrl(authorName);

      // --- 更新历史记录 ---
      // Authors
      _recentAuthors.add(authorName);
      if (_recentAuthors.length > 5) _recentAuthors.removeAt(0);

      // Themes
      if (newTheme != null && newTheme.isNotEmpty) {
        _recentThemes.add(newTheme);
        if (_recentThemes.length > 4) _recentThemes.removeAt(0); // 记住最近 4 个主题
      }

      // Quotes
      final quoteText = result['text'] as String;
      _recentQuotes.add(quoteText);
      if (_recentQuotes.length > 10) _recentQuotes.removeAt(0); // 记住最近 10 条名言
      // ------------------

      // 合并数据
      final quoteData = Map<String, dynamic>.from(result);
      quoteData['imageUrl'] = resolvedImage;

      return Quote.fromJson(quoteData);
    } catch (e) {
      print('❌ Error fetching quote from LLM: $e');
      // 发生任何错误（网络、解析、配额不足），优雅降级到 Mock
      return _fetchMockQuote();
    }
  }

  /// Mock 数据生成 (Fallback)
  Future<Quote> _fetchMockQuote() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = [
      {
        "text": "那些听不见音乐的人，认为跳舞的人疯了。",
        "author": "尼采",
        "life_years": "1844-1900",
        "theme": "存在主义",
        "tagline": "手拿锤子的反叛者",
        "bio": "弗里德里希·尼采（1844-1900），德国哲学家，主要探讨权力意志、超人学说。",
        "explanation":
            "这句话常常用来比喻那些因为缺乏理解（听不见音乐）而对他人行为（跳舞）产生误解和偏见的人。在尼采看来，只有通过深刻的生命体验，才能理解“酒神精神”般的狂醉与释放。",
        "imageUrl": "assets/images/nietzsche_0.png",
      },
      {
        "text": "知之为知之，不知为不知，是知也。",
        "author": "孔子",
        "life_years": "前551-前479",
        "theme": "儒家伦理",
        "tagline": "万世师表",
        "bio": "孔子（公元前551年―公元前479年），中国古代思想家、教育家，儒家学派创始人。",
        "explanation":
            "这是关于认知的诚实。它不仅仅是承认无知，而是将“承认无知”本身视为一种智慧。在信息爆炸的今天，保持这种智识上的谦逊尤为重要。",
        "imageUrl": "assets/images/confucius_0.png",
      },
      {
        "text": "语言是存在的家。",
        "author": "海德格尔",
        "life_years": "1889-1976",
        "theme": "现象学",
        "tagline": "林中路上的牧羊人",
        "bio": "马丁·海德格尔（1889-1976），德国哲学家，20世纪存在主义哲学的代表人物。",
        "explanation":
            "这句话揭示了语言与存在之间深刻的本体论关系。人以语言为家，在语言中栖居；通过语言，人得以触碰和理解存在的真理。语言不仅仅是工具，更是我们构建和理解世界的根基。",
        "imageUrl": "assets/images/heidegger_0.png",
      },
    ];

    final randomItem = mockData[Random().nextInt(mockData.length)];

    // 动态解析图片 (即使是 Mock 数据也走一遍逻辑，确保一致性)
    final authorName = randomItem['author'] as String;
    // 如果 Mock 数据里自带了 imageUrl 且有效，优先用自带的；否则尝试 resolve
    final resolvedImage =
        await _resolveImageUrl(authorName) ?? randomItem['imageUrl'];

    final itemWithImage = Map<String, dynamic>.from(randomItem);
    itemWithImage['imageUrl'] = resolvedImage;

    return Quote.fromJson(itemWithImage);
  }

  /// 智能资产映射器: 根据作者名模糊匹配本地资源 (动态加载)
  Future<String?> _resolveImageUrl(String authorName) async {
    final normalizedName = authorName.toLowerCase().trim();

    // 1. 定义名称到资产前缀的映射
    final nameToPrefix = {
      'nietzsche': 'nietzsche',
      '尼采': 'nietzsche',
      'friedrich': 'nietzsche',
      'confucius': 'confucius',
      '孔子': 'confucius',
      'kongzi': 'confucius',
      'heidegger': 'heidegger',
      '海德格尔': 'heidegger',
      'sartre': 'sartre',
      '萨特': 'sartre',
      'camus': 'camus',
      '加缪': 'camus',
      'kierkegaard': 'kierkegaard',
      '克尔凯郭尔': 'kierkegaard',
    };

    String? prefix;
    for (final entry in nameToPrefix.entries) {
      if (normalizedName.contains(entry.key)) {
        prefix = entry.value;
        break;
      }
    }

    if (prefix == null) {
      // 默认回退：使用剪影通用图
      return 'assets/images/philosopher_default.png';
    }

    try {
      // 2. 利用 AssetManifest 动态获取匹配的所有图片
      // 这里的 assets/Images/$prefix 可以匹配尼采的多张：nietzsche_0.png, nietzsche_1.png...
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest
          .listAssets()
          .where(
            (path) =>
                path.startsWith('assets/images/$prefix') &&
                path.endsWith('.png'),
          )
          .toList();

      if (assets.isEmpty) {
        // 默认回退：使用剪影通用图
        return 'assets/images/philosopher_default.png';
      }

      // 3. 随机返回一张图片
      return assets[Random().nextInt(assets.length)];
    } catch (e) {
      print('Warning: Asset mapping failed: $e');
      // 默认回退：使用剪影通用图
      return 'assets/images/philosopher_default.png';
    }
  }

  /// 辅助方法：清洗并解析 LLM 返回的 JSON 字符串
  /// 能够处理 ```json 包裹的代码块
  Map<String, dynamic> _sanitizeAndParseJson(String raw) {
    String clean = raw.trim();
    // 去除 Markdown 代码块标记
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) {
      clean = clean.substring(0, clean.length - 3);
    }
    return jsonDecode(clean) as Map<String, dynamic>;
  }
}
