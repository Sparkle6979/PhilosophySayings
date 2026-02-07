import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart'; // Explicit import
import 'dart:ui' as ui;

class ShareService {
  /// Captures the widget wrapped in the GlobalKey as an image and shares it.
  ///
  /// [globalKey]: The key of the RepaintBoundary wrapping the widget.
  /// [pixelRatio]: The quality of the captured image (default 3.0 for high res).
  static Future<void> captureAndShare(
    GlobalKey globalKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      // 1. Locate the render boundary
      final RenderRepaintBoundary? boundary =
          globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception("RenderRepaintBoundary not found");
      }

      // 2. Capture image as byte data
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception("Failed to convert image to byte data");
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 3. Save to temporary file (Use Documents to avoid aggressive temp cleanup)
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/philosophy_quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes, flush: true);

      if (!await imageFile.exists()) {
        throw Exception("File not found after writing: $imagePath");
      }

      // 4. Share the file
      final xFile = XFile(imagePath);
      await Share.shareXFiles([xFile], text: 'Shared from Philosophy Sayings');
    } catch (e) {
      print('Error sharing image: $e');
      // Rethrow so UI can show a snackbar if needed, or handle it here
      throw e;
    }
  }
}
