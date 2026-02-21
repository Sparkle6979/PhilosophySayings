import 'dart:convert';

class JsonUtils {
  /// 核心工具类：清理并解析 LLM 返回的 JSON 字符串。
  ///
  /// 【大模型开发的痛点】：即使在 Prompt 里强调 "Output JSON only"，大模型 (尤其是参数较小的廉价模型)
  /// 经常会混杂 Markdown 代码块 (```json ... ```)、前言后语 (如"好的，以下是：")，
  /// 甚至在生成内部双引号时忘记转义，导致标准的 `jsonDecode` 直接崩溃。
  ///
  /// 为了解决这个工程难题，我们实行 3 级柔性容错策略：
  /// 1. Stack-based 括号匹配：精准剥离首尾的多余聊天废话。
  /// 2. 中文弯引号替换：修复模型自作聪明把 JSON 结构的双引号写成中文双引号的错误。
  /// 3. Mask-Protect-Restore (掩码-保护-还原) 算法：专门修复【未转义的内部双引号】带来的致命结构破坏。
  static Map<String, dynamic> sanitizeAndParseJson(String raw) {
    // 1. Find JSON start (first '{' or '[')
    int start = -1;
    for (int i = 0; i < raw.length; i++) {
      if (raw[i] == '{' || raw[i] == '[') {
        start = i;
        break;
      }
    }

    if (start == -1) {
      throw const FormatException('No JSON start found ({ or [)');
    }

    // 2. Find matching end (Stack-based matching)
    int end = -1;
    int balance = 0;
    bool inString = false;
    bool isEscaped = false;
    final startChar = raw[start];
    final endChar = startChar == '{' ? '}' : ']';

    for (int i = start; i < raw.length; i++) {
      final char = raw[i];

      if (isEscaped) {
        isEscaped = false;
        continue;
      }

      if (char == '\\') {
        isEscaped = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == startChar) {
          balance++;
        } else if (char == endChar) {
          balance--;
          if (balance == 0) {
            end = i;
            break;
          }
        }
      }
    }

    if (end == -1) {
      // Fallback: simple lastIndexOf if stack failed
      if (startChar == '{') {
        end = raw.lastIndexOf('}');
      } else {
        end = raw.lastIndexOf(']');
      }

      if (end == -1 || end <= start) {
        throw const FormatException(
          'Malformed JSON: Found start but no matching end.',
        );
      }
    }

    // 3. Extract content
    String content = raw.substring(start, end + 1);

    // 4. Try Parsing Strategies
    try {
      // Strategy A: Parse as is
      return _parseJsonContent(content);
    } catch (e) {
      // Strategy B: Replace Smart Quotes (Fix for structural smart quotes)
      try {
        final sanitized = content.replaceAll('“', '"').replaceAll('”', '"');
        print(
          '⚠️ Strategy A failed ($e). Trying Strategy B (Smart Quote Sanitization)...',
        );
        return _parseJsonContent(sanitized);
      } catch (e2) {
        // Strategy C: Mask-Protect-Restore (Heuristic for Unescaped Quotes)
        // Solves: "text": "He said "Hello"" -> "text": "He said 'Hello'"
        try {
          print(
            '⚠️ Strategy B failed ($e2). Trying Strategy C (Mask-Protect-Restore)...',
          );

          String heuristic = content;

          // 1. Mask valid structural quotes (preceded/followed by { [ : ,)
          // Mask Start Quotes: { "  [ "  : "  , "
          heuristic = heuristic.replaceAllMapped(
            RegExp(r'([\{\[\:,])(\s*)"'),
            (match) => '${match.group(1)}${match.group(2)}___Q___',
          );

          // Mask End Quotes: " }  " ]  " ,  " :
          heuristic = heuristic.replaceAllMapped(
            RegExp(r'"(\s*[\}\]\:,])'),
            (match) => '___Q___${match.group(1)}',
          );

          // 2. Replace all remaining (invalid) double quotes with single quotes
          heuristic = heuristic.replaceAll('"', "'");

          // 3. Restore structural quotes
          heuristic = heuristic.replaceAll('___Q___', '"');

          return _parseJsonContent(heuristic);
        } catch (e3) {
          print('❌ JSON Parse Error (Final): $e3');
          print('📝 Extracted content was: $content');
          rethrow;
        }
      }
    }
  }

  static Map<String, dynamic> _parseJsonContent(String content) {
    final decoded = jsonDecode(content);

    // Compat: Handle JSON Array
    if (decoded is List) {
      if (decoded.isNotEmpty && decoded.first is Map) {
        print(
          '⚠️ Warning: LLM returned a List instead of Map. Using first element.',
        );
        return Map<String, dynamic>.from(decoded.first as Map);
      } else {
        throw const FormatException(
          'LLM returned a List but it was empty or not containing Maps.',
        );
      }
    }

    // Standard Case: Map
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw FormatException('Unexpected JSON structure: ${decoded.runtimeType}');
  }
}
