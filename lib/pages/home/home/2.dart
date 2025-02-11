import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
// Para realizar requisições HTTP

Future<void> downloadFile(context,String url, String fileName) async {
  try {
    // Obter o diretório de downloads
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$fileName';

    // Criar o arquivo
    await Dio().download(url, savePath);

    // Mostrar mensagem de sucesso (opcional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Arquivo baixado com sucesso!'),
      ),
    );
  } catch (e) {
    print('Erro ao baixar arquivo: $e');
    // Mostrar mensagem de erro ao usuário
  }
}
