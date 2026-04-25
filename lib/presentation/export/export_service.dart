import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

abstract class ExportService {
  Future<void> share(String title, String text);
  Future<void> printNote(String title, String text);
  Future<bool> download(String title, String text);
}

class RealExportService implements ExportService {
  @override
  Future<void> share(String title, String text) async {
    final content = title.isEmpty ? text : '$title\n\n$text';
    await SharePlus.instance.share(ShareParams(text: content));
  }

  @override
  Future<void> printNote(String title, String text) async {
    await Printing.layoutPdf(
      name: title.isEmpty ? 'Note' : title,
      onLayout: (_) async => _textPdfBytes(title, text),
    );
  }

  // Minimal plain-text PDF using raw PDF syntax.
  Uint8List _textPdfBytes(String title, String text) {
    final content = title.isEmpty ? text : '$title\n\n$text';
    final escaped = content
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)');
    final body = '''%PDF-1.4
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj
3 0 obj<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<</Font<</F1<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>>>>>>/Contents 4 0 R>>endobj
4 0 obj<</Length ${escaped.length + 32}>>
stream
BT /F1 12 Tf 72 720 Td ($escaped) Tj ET
endstream
endobj
xref
0 5
trailer<</Root 1 0 R/Size 5>>
startxref
0
%%EOF''';
    return Uint8List.fromList(body.codeUnits);
  }

  @override
  Future<bool> download(String title, String text) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeTitle = (title.isEmpty ? 'Untitled' : title)
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      await File('${dir.path}/$safeTitle.txt').writeAsString(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final exportServiceProvider = Provider<ExportService>(
  (_) => RealExportService(),
);
