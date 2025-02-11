import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';

Future<void> downloadFile(
    BuildContext context, String url, String fileName) async {
  try {
    // Busca os dados do arquivo
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Salva o arquivo

      final bytes = response.bodyBytes;
      final mimeType = mime(fileName) ?? 'application/octet-stream';

      final blob = html.Blob([bytes], mimeType);
      final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
      html.Url.revokeObjectUrl(downloadUrl);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Arquivo baixado com sucesso')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Falha ao baixar o arquivo')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Erro: $e')));
  }
}
