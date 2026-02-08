import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import '../config/prompts.dart'; // 引入配置文件
import '../models/quote.dart';

// Service Layer: 负责所有的数据获取
class LLMService {
  // TODO: Replace with your actual implementation or environment variables
  // 暂时硬编码 Key，后续会改为从 Settings 读取
  // DeepSeek API Key (Hiding for GitHub upload)
  static const String _apiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue:
        '', // Key removed for security. Pass via --dart-define=DEEPSEEK_API_KEY=...
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
  // [LangChain 概念]: Runnable 是 LangChain 中的基本工作单元，不仅是一个类，更是一个协议。
  // 所有的 Chain、Model、OutputParser 都实现了 Runnable 接口，这意味着它们可以被
  // 统一调用 (.invoke) 或 串联 (.pipe)。
  late final Runnable _stringChain;

  LLMService() {
    // 初始化 Chain
    // 1. 初始化模型 (Chat Model)
    // [LangChain 概念]: ChatOpenAI 是对 OpenAI 兼容接口的封装。
    // 它负责与 LLM 服务端通信。
    final model = ChatOpenAI(
      apiKey: _apiKey,
      baseUrl: _baseUrl,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 1.5, // High temperature for max diversity (创造性)
        model: 'deepseek-chat',
      ),
    );

    // 2. 定义 Prompt (Prompt Template)
    // [LangChain 概念]: ChatPromptTemplate 用于构建发送给 LLM 的消息列表。
    // 它将静态的指令 (System Prompt) 和动态的用户输入 (Human Prompt) 结合起来。
    // 其中的 {variable} 是占位符，会在运行时被 .invoke() 传入的参数替换。
    final promptTemplate = ChatPromptTemplate.fromPromptMessages([
      // System Message: 设定 AI 的角色和行为规范 (从 config/prompts.dart 读取)
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.fetchQuoteSystemPrompt,
      ),
      // Human Message: 用户的实际请求
      HumanChatMessagePromptTemplate.fromTemplate('请赐予我一句智慧。Output JSON only.'),
    ]);

    // 3. 构建 Chain (LCEL - LangChain Expression Language)
    // [LangChain 概念]: Pipe (|) 运算符
    // 这行代码展示了 LangChain 最核心的特性：链式调用。
    // 数据流向: PromptTemplate -> Model -> OutputParser
    // 1. PromptTemplate 接收参数，生成 List<ChatMessage>
    // 2. Model 接收消息，调用 API，返回 ChatResult
    // 3. StringOutputParser 接收 ChatResult，提取出 content 字符串
    _stringChain = promptTemplate.pipe(model).pipe(const StringOutputParser());

    // --- Philosopher's Chamber: Opening Chain ---
    // [LangChain 概念]: 不同的任务需要不同的 Chain
    // 这里我们定义了一个专门用于生成“开场白”的 Prompt
    final openingPrompt = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.philosopherChamberOpeningSystemPrompt,
      ),
      HumanChatMessagePromptTemplate.fromTemplate('访客已入座。请开始你的发问。'),
    ]);
    _openingChain = openingPrompt.pipe(model).pipe(const StringOutputParser());

    // --- Philosopher's Chamber: Chat Chain ---
    // [LangChain 概念]: 带有历史记录的 Prompt
    final chatPrompt = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.philosopherChamberChatSystemPrompt,
      ),
      // [LangChain 概念]: MessagesPlaceholder
      // 这是一个特殊的占位符，用于插入对话历史 (History)。
      // 它会被替换为一系列的 ChatMessage 对象 (HumanMessage, AIMessage)。
      MessagesPlaceholder(variableName: 'history'),
      HumanChatMessagePromptTemplate.fromTemplate('{input}'),
    ]);
    _chatChain = chatPrompt.pipe(model).pipe(const StringOutputParser());
  }

  late final Runnable _openingChain;
  late final Runnable _chatChain;

  /// 核心方法：获取一条随机哲学金句
  Future<Quote> fetchRandomQuote() async {
    // 1. 检查 Key 配置
    if (_apiKey.isEmpty) {
      print('⚠️ DEEPSEEK_API_KEY is empty. Using Mock Data.');
      print(
        '💡 Tip: Ensure you are using the "Local Debug" configuration in your IDE.',
      );
      return _fetchMockQuote();
    }

    if (!_apiKey.startsWith('sk-')) {
      print('⚠️ API Key format seems invalid (does not start with sk-).');
    } else {
      print('✅ API Key detected (prefix: ${_apiKey.substring(0, 5)}...)');
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
      if (_recentQuotes.length > 20) _recentQuotes.removeAt(0); // 记住最近 15 条名言
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
      'descartes': 'descartes',
      '笛卡尔': 'descartes',
      'socrates': 'socrates',
      '苏格拉底': 'socrates',
      'pascal': 'pascal',
      '帕斯卡': 'pascal',
      'weber': 'weber',
      '韦伯': 'weber',
      'kant': 'kant',
      '康德': 'kant',
      'marx': 'marx',
      '马克思': 'marx',
      'hegel': 'hegel',
      '黑格尔': 'hegel',
      'proust': 'proust',
      '普鲁斯特': 'proust',
      'heraclitus': 'heraclitus',
      '赫拉克利特': 'heraclitus',
      'bacon': 'bacon',
      '培根': 'bacon',
      'rousseau': 'rousseau',
      '卢梭': 'rousseau',
      'spinoza': 'spinoza',
      '斯宾诺莎': 'spinoza',
      'schopenhauer': 'schopenhauer',
      '叔本华': 'schopenhauer',
      'plato': 'plato',
      '柏拉图': 'plato',
      'aristotle': 'aristotle',
      '亚里士多德': 'aristotle',
      'husserl': 'husserl',
      '胡塞尔': 'husserl',
      'wittgenstein': 'wittgenstein',
      '维特根斯坦': 'wittgenstein',
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

  /// --- Philosopher's Chamber Logic ---

  /// 生成“密室”开场白
  Future<String> generateOpeningQuestion(Quote quote) async {
    if (_apiKey.isEmpty) {
      // Mock Fallback
      await Future.delayed(const Duration(seconds: 1));
      return '你为何因这句话而停留？"${quote.text}"... 是因为你在虚无中感到寒冷了吗？(Mock)';
    }

    try {
      final res = await _openingChain.invoke({
        'author': quote.author,
        'bio': quote.bio,
        'tagline': quote.tagline,
        'quote': quote.text,
      });
      return res.toString();
    } catch (e) {
      print('Error generating opening: $e');
      return '你凝视着这句话... 它唤醒了你心中的什么？'; // Fallback generic opening
    }
  }

  /// 与哲学家对话
  Future<String> chatWithPhilosopher(
    Quote quote,
    String input,
    List<Map<String, String>> history,
  ) async {
    if (_apiKey.isEmpty) {
      // Mock Fallback
      await Future.delayed(const Duration(seconds: 1));
      return '这是模拟的回复。你的思考很有深度，但我们现在处于离线模式。';
    }

    try {
      // Convert history map to LangChain Message objects
      // Note: This is a simplified conversion. For robust history, use proper Message classes.
      // But passing raw input/history logic might differ based on LangChain Dart version.
      // LangChain Dart: MessagesPlaceholder expects a list of ChatMessage.

      final List<ChatMessage> chatHistory = history.map((msg) {
        if (msg['role'] == 'user') {
          return ChatMessage.humanText(msg['content']!);
        } else {
          return ChatMessage.ai(msg['content']!);
        }
      }).toList();

      final res = await _chatChain.invoke({
        'author': quote.author,
        'bio': quote.bio,
        'tagline': quote.tagline,
        'quote': quote.text,
        'history': chatHistory,
        'input': input,
      });
      return res.toString();
    } catch (e) {
      print('Error chatting: $e');
      return '（哲学家陷入了沉思... 似乎信号中断了）';
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
