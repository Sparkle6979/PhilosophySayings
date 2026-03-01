import 'dart:math';
import 'package:flutter/services.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import '../config/prompts.dart'; // 引入配置文件
import '../models/quote.dart';
import '../models/llm_config.dart';
import 'preference_service.dart';
import '../utils/json_utils.dart';

// Service Layer: 负责所有的数据获取
class LLMService {
  // DeepSeek Defaults (Support CI Injection via --dart-define)
  static const String _defaultApiKey = const String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );
  // 最近出现过的哲学家名单 (用于避免短期重复)
  final List<String> _recentAuthors = [];
  // 最近涉及过的哲学领域 (用于强制多元化)
  final List<String> _recentThemes = [];
  // 最近出现过的名言内容 (用于避免内容重复)
  final List<String> _recentQuotes = [];

  // --- LangChain 核心概念讲解 ---
  // Runnable: LangChain 中的标准可执行单元。它可以是一个链条 (Chain)、一个提示词模板 (PromptTemplate) 或一个模型 (Model)。
  // 通过 .pipe() 方法，我们可以将多个 Runnable 组合成一个新的、更大的 Runnable。
  late Runnable _stringChain; // 用于获取名言的 Chain，最终输出字符串 (String)
  late Runnable _openingChain; // 用于生成密室开场白的 Chain
  late Runnable _chatChain; // 用于在密室中持续对话的 Chain
  late LLMConfig _currentConfig;
  late String _activeModel;
  late String _activeBaseUrl;

  LLMService() {
    _initChains();
  }

  void reloadConfig() {
    print("🔄 Reloading LLM Config...");
    _initChains();
  }

  void _initChains() {
    // 1. Load Config
    try {
      _currentConfig = PreferenceService().getLLMConfig();
    } catch (e) {
      _currentConfig = const LLMConfig();
    }

    String finalApiKey = _currentConfig.apiKey;
    _activeBaseUrl = _currentConfig.baseUrl;
    _activeModel = _currentConfig.modelName;

    // 体验模式 Override
    if (_currentConfig.mode == AppMode.experience) {
      finalApiKey = _defaultApiKey; // Use internal limited key
      _activeBaseUrl = 'https://api.deepseek.com';
      _activeModel = 'deepseek-chat';
    }

    print(
      "🤖 Initializing LLM: Mode=${_currentConfig.mode}, Provider=${_currentConfig.provider} -> Actual Endpoint: $_activeBaseUrl, Actual Model: $_activeModel",
    );

    // 2. 初始化模型 (Chat Model)
    final model = ChatOpenAI(
      apiKey: finalApiKey,
      baseUrl: _activeBaseUrl,
      defaultOptions: ChatOpenAIOptions(
        temperature: _currentConfig.effectiveTemperature,
        model: _activeModel,
        maxTokens: _currentConfig.effectiveMaxTokens,
      ),
    );

    // 3. 定义 Prompt (PromptTemplate - 提示词模板)
    // 提示词模板就像是一个填空题，我们在运行时把变量（如 {input}, {excluded_authors}）填进去，
    // 组装成一段完整的对话历史交由大模型处理。
    final promptTemplate = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.fetchQuoteSystemPrompt,
      ),
      HumanChatMessagePromptTemplate.fromTemplate('请赐予我一句智慧。Output JSON only.'),
    ]);

    // 4. 构建 Chain (将多个组件用管道串联起来)
    // 这里的 .pipe() 就像是流水线：
    // PromptTemplate 填好词 -> 传给 -> Model 生成回复 -> 传给 -> StringOutputParser 提取文本。
    _stringChain = promptTemplate.pipe(model).pipe(const StringOutputParser());

    // --- Philosopher's Chamber: Opening Chain (密室开场白流水线) ---
    final openingPrompt = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.philosopherChamberOpeningSystemPrompt,
      ),
      HumanChatMessagePromptTemplate.fromTemplate('访客已入座。请开始你的发问。'),
    ]);
    _openingChain = openingPrompt.pipe(model).pipe(const StringOutputParser());

    // --- Philosopher's Chamber: Chat Chain (密室对话流水线) ---
    final chatPrompt = ChatPromptTemplate.fromPromptMessages([
      SystemChatMessagePromptTemplate.fromTemplate(
        AppPrompts.philosopherChamberChatSystemPrompt,
      ),
      // MessagesPlaceholder 是一个动态占位符，用来插入一连串的历史消息对象 (ChatMessages)
      // 这让大模型能够“记住”之前的聊天记录。
      MessagesPlaceholder(variableName: 'history'),
      HumanChatMessagePromptTemplate.fromTemplate('{input}'),
    ]);
    _chatChain = chatPrompt.pipe(model).pipe(const StringOutputParser());
  }

  /// 核心方法：获取一条随机哲学金句
  Future<Quote> fetchRandomQuote() async {
    // 1. 检查 Key 配置 (只在极速模式下检查空 Key)
    if (_currentConfig.mode == AppMode.speed && _currentConfig.apiKey.isEmpty) {
      print('⚠️ [Speed Mode] API Key is empty. Using Mock Data.');
      return _fetchMockQuote();
    }

    // 检查 API Key 格式 (仅在非体验模式下)
    if (_currentConfig.mode != AppMode.experience &&
        !_currentConfig.apiKey.startsWith('sk-')) {
      print('⚠️ API Key format seems invalid (does not start with sk-).');
    } else if (_currentConfig.mode != AppMode.experience) {
      print(
        '✅ API Key detected (prefix: ${_currentConfig.apiKey.substring(0, 5)}...)',
      );
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

      print(
        '🚀 Sending request to LLM [Actual Model: $_activeModel]...',
      ); // invoke(): 这是 Runnable 执行的方法。我们将字典包裹的变量传进去，
      // 它会经历 Prompt -> Model -> OutputParser，最后吐出结果。
      final String rawContent =
          await _stringChain.invoke({
                'excluded_authors': excludedAuthorsStr,
                'excluded_themes': excludedThemesStr,
                'excluded_quotes': excludedQuotesStr,
              }, options: options)
              as String;

      print('📝 Raw Content: $rawContent');

      // 手动调用 Parser 解析 JSON: 从模型返回的一堆混杂文字中，提取合法的 JSON，
      // 并防止因为模型产生的奇怪的特殊符号导致解析崩溃。
      final Map<String, dynamic> result = JsonUtils.sanitizeAndParseJson(
        rawContent,
      );
      print(
        '✅ LLM Response [Actual Model: $_activeModel]: $result',
      ); // 6. 后处理：本地资产映射 (查找对应的画像)
      final authorName = result['author'] as String;
      final newTheme = result['theme'] as String?;

      // 智能解析图片
      final resolvedImage = await _resolveImageUrl(authorName);

      // --- 更新历史记录 (LRU Cache 逻辑，防止 Race Condition 导致重复) ---
      // Authors
      _recentAuthors.remove(authorName);
      _recentAuthors.add(authorName);
      if (_recentAuthors.length > 8) _recentAuthors.removeAt(0);

      // Themes
      if (newTheme != null && newTheme.isNotEmpty) {
        _recentThemes.remove(newTheme);
        _recentThemes.add(newTheme);
        if (_recentThemes.length > 4) _recentThemes.removeAt(0);
      }

      // Quotes
      final quoteText = result['text'] as String;
      _recentQuotes.remove(quoteText);
      _recentQuotes.add(quoteText);
      if (_recentQuotes.length > 25) _recentQuotes.removeAt(0); // 记住最近 25 条名言
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

    itemWithImage['isMock'] = true; // Mark as mock data

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
      'foucault': 'foucault',
      '福柯': 'foucault',
      '米歇尔·福柯': 'foucault',
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
      'protagoras': 'protagoras',
      '普罗泰戈拉': 'protagoras',
      'thrasymachus': 'thrasymachus',
      '色拉叙马霍斯': 'thrasymachus',
      'russell': 'russell',
      '罗素': 'russell',
      'hume': 'hume',
      '休谟': 'hume',
      'einstein': 'einstein',
      '爱因斯坦': 'einstein',
      'luxun': 'luxun',
      '鲁迅': 'luxun',
      'dostoevsky': 'dostoevsky',
      '陀思妥耶夫斯基': 'dostoevsky',
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
    // 检查 Key
    if (_currentConfig.mode == AppMode.speed && _currentConfig.apiKey.isEmpty) {
      // Mock Fallback
      await Future.delayed(const Duration(seconds: 1));
      return '你为何因这句话而停留？"${quote.text}"... 是因为你在虚无中感到寒冷了吗？(Mock)';
    }

    try {
      print(
        '🗣️ Generating opening question via LLM [Actual Model: $_activeModel]...',
      );
      final res = await _openingChain.invoke({
        'author': quote.author,
        'bio': quote.bio,
        'tagline': quote.tagline,
        'quote': quote.text,
      });
      print('✅ Opening generated: $res');
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
    // 检查 Key
    if (_currentConfig.mode == AppMode.speed && _currentConfig.apiKey.isEmpty) {
      // Mock Fallback
      await Future.delayed(const Duration(seconds: 1));
      return '这是模拟的回复。你的思考很有深度，但我们现在处于离线模式。';
    }

    try {
      // 将自定义的 Map 聊天记录转换成 LangChain 专用的 ChatMessage 对象列表。
      // 模型只有通过区分 Human(人) 和 AI(机器) 角色，才能正确理解上下文对话走向。
      final List<ChatMessage> chatHistory = history.map((msg) {
        if (msg['role'] == 'user') {
          return ChatMessage.humanText(msg['content']!);
        } else {
          return ChatMessage.ai(msg['content']!);
        }
      }).toList();

      print(
        '🗣️ Chatting with philosopher via LLM [Actual Model: $_activeModel]...',
      );
      // 执行含有历史记录的聊天流水线
      final res = await _chatChain.invoke({
        'author': quote.author,
        'bio': quote.bio,
        'tagline': quote.tagline,
        'quote': quote.text,
        'history':
            chatHistory, // 将上面的 List<ChatMessage> 传递给 MessagesPlaceholder
        'input': input,
      });
      print('✅ Chat response received: $res');
      return res.toString();
    } catch (e) {
      print('Error chatting: $e');
      return '（哲学家陷入了沉思... 似乎信号中断了）';
    }
  }
}
