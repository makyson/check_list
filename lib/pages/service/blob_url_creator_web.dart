import 'dart:typed_data';
import 'dart:html' as html;

class BlobUrlCreator {
  static String createBlobUrl(Uint8List bytes, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    return url;
  }
}
