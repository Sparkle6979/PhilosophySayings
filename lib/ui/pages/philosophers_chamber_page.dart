import 'package:flutter/material.dart';
import '../../models/quote.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/llm_service.dart';

class PhilosophersChamberPage extends StatefulWidget {
  final Quote quote;
  final List<Map<String, String>>? initialHistory;
  final Function(List<Map<String, String>>) onChatUpdated;

  const PhilosophersChamberPage({
    Key? key,
    required this.quote,
    this.initialHistory,
    required this.onChatUpdated,
  }) : super(key: key);

  @override
  State<PhilosophersChamberPage> createState() =>
      _PhilosophersChamberPageState();
}

class _PhilosophersChamberPageState extends State<PhilosophersChamberPage> {
  // --- UI 控制器 (Controllers) ---
  // TextEditingController 用于读取和清空输入框。
  // ScrollController 用于在收到新消息时，自动将聊天列表滚动到底部。
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LLMService _llmService = LLMService();

  // 聊天记录存储。格式与 LangChain 期望的结构相似：[{'role': 'user', 'content': '...'}, ...]
  final List<Map<String, String>> _messages = [];

  // 状态变量
  bool _isTyping = true; // 最初为 true，因为设定是“哲学家主动先开口”
  bool _showIntro = true; // 控制“正在进入密室”全屏动画的显示与淡出

  @override
  void initState() {
    super.initState();
    // Start entrance animation sequence
    _playEntranceAnimation();

    // Check for existing history (Persistence Logic)
    // [逻辑说明]: 如果传入了 initialHistory，说明是“重返”密室。
    // 我们直接加载历史记录，并跳过开场白生成。
    if (widget.initialHistory != null && widget.initialHistory!.isNotEmpty) {
      _messages.addAll(widget.initialHistory!);
      _isTyping = false;
      // Scroll to bottom after frame
      // [Flutter 技巧]: 在构建完成后执行滚动，确保 ListView 已经渲染了内容。
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      // Simulate the opening line only if no history
      // [逻辑说明]: 首次进入，模拟哲学家“主动”开口。
      _simulateOpening();
    }
  }

  void _playEntranceAnimation() async {
    // Keep the text visible for a moment - increased delay for atmosphere
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _showIntro = false; // Trigger fade out
      });
    }
  }

  void _simulateOpening() async {
    // Artificial delay for atmosphere (沉浸感) - match entrance
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;
    // ... (rest of _simulateOpening is fine, just need to match context)

    try {
      // Call LLM for dynamic opening based on the quote
      final opening = await _llmService.generateOpeningQuestion(widget.quote);
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': opening});
          _isTyping = false;
          // [状态提升]: 通知父组件 (HomePage) 更新历史记录，以便持久化
          widget.onChatUpdated(_messages);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': '（哲学家似乎在沉思，没有说话...）'});
          _isTyping = false;
          widget.onChatUpdated(_messages); // Sync update
        });
      }
    }
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text;
    _textController.clear(); // 发送后立即清空输入框，提升体验

    // --- 乐观 UI 更新 (Optimistic UI Update) ---
    // 即使还没有收到大模型回复，也先将用户的消息上屏，
    // 让界面显得极其响应迅速，不卡顿。
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true; // 显示 "Thinking..." 等待动画
      widget.onChatUpdated(_messages); // [状态提升] 同步更新首页的缓存
    });
    _scrollToBottom();

    try {
      // Call LLM
      final response = await _llmService.chatWithPhilosopher(
        widget.quote,
        text,
        _messages, // Pass full history for context
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isTyping = false;
          _scrollToBottom();
          widget.onChatUpdated(_messages); // Sync update
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': '（似乎有一股不可抗力切断了你们的连接...）',
          });
          _isTyping = false;
          _scrollToBottom();
          widget.onChatUpdated(_messages); // Sync update
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Deep immersive background
      body: Stack(
        children: [
          // 1. Soul Watermark (Background Image)
          Positioned.fill(
            child: Opacity(
              opacity: 0.08, // Very subtle "soul" presence
              child: Image.asset(
                widget.quote.imageUrl ??
                    'assets/images/philosopher_default.png',
                fit: BoxFit.cover, // Cover the entire screen
                alignment: Alignment.center,
              ),
            ),
          ),

          // 2. Main Content
          Column(
            children: [
              // Custom AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                toolbarHeight: 120, // Taller AppBar for spacious header
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.quote.author,
                        style: GoogleFonts.imFellEnglishSc(
                          color: Colors.white70,
                          fontSize: 24, // Slightly larger name
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.quote.lifeYears != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.quote.lifeYears!,
                          style: GoogleFonts.lato(
                            color: Colors.white38,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                      if (widget.quote.tagline != null &&
                          widget.quote.tagline!.isNotEmpty) ...[
                        const SizedBox(height: 6), // More spacing
                        Text(
                          widget.quote.tagline!,
                          style: GoogleFonts.lato(
                            color: Colors.white60,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10), // More spacing before quote
                      Text(
                        widget.quote.text,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chat Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.white10
                              : Colors.transparent, // Minimalist
                          borderRadius: BorderRadius.circular(12),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: Colors.white12,
                                ), // Subtle border
                        ),
                        child: SelectableText(
                          msg['content']!,
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Typing Indicator
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Thinking...",
                      style: TextStyle(
                        color: Colors.white24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

              // Input Area
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align bottom for multiline
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white70,
                          maxLines: 4,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction
                              .send, // Allow "Enter" to trigger submit
                          decoration: InputDecoration(
                            hintText: "Type your thought...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) =>
                              _sendMessage(), // Handle send action
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Entrance Animation Overlay
          IgnorePointer(
            ignoring: !_showIntro, // Let touches pass through when hidden
            child: AnimatedOpacity(
              opacity: _showIntro ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000), // Slow fade out
              curve: Curves.easeInOut,
              child: Container(
                color: Colors.black, // Opaque black cover
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "正在进入",
                        style: GoogleFonts.lato(
                          color: Colors.white38,
                          fontSize: 14,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "哲学家的密室",
                        style: GoogleFonts.imFellEnglishSc(
                          color: Colors.white70,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Kiyoshi Kasai Quote
                      Text(
                        "“密室，是人类意识的现象学还原。”",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerifSc(
                          color: Colors.white70,
                          fontSize: 18,
                          letterSpacing: 2.0,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "—— 笠井洁《哲学者们的密室》",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
