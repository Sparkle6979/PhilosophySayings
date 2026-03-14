import 'package:flutter/foundation.dart';
import 'meta_updater.dart' if (dart.library.html) 'meta_updater_web.dart' as meta_impl;

class ThemeColorHandler {
  static void updateThemeColor(String color) {
    if (kIsWeb) {
      meta_impl.updateThemeColor(color);
    }
  }
}
