import 'dart:convert';

class JsonUtils {
  /// Cleans and parses a JSON string returned by an LLM.
  ///
  /// Uses a robust 2-step strategy:
  /// 1. Stack-based extraction: Finds the outer-most JSON object/list to ignore conversational text.
  /// 2. Smart Quote Fallback: If standard parsing fails, attempts to replace Chinese smart quotes with standard quotes.
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
