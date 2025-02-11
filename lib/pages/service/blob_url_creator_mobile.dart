import 'dart:convert';
import 'dart:typed_data';

class BlobUrlCreator {
  static String createBlobUrl(Uint8List bytes, String mimeType) {
    final base64Data = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64Data';
  }
}
