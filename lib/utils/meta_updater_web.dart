import 'dart:html' as html;

void updateThemeColor(String color) {
  try {
    final metas = html.document.getElementsByTagName('meta');
    for (var i = 0; i < metas.length; i++) {
      if (metas[i] is html.MetaElement) {
        final meta = metas[i] as html.MetaElement;
        if (meta.name == 'theme-color') {
          meta.content = color;
        }
      }
    }
  } catch (e) {
    // ignore
  }
}
