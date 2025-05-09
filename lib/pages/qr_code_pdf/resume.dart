import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

const PdfColor preto = PdfColor.fromInt(0xFF000000);
const PdfColor pretoborda = PdfColor.fromInt(0x4C000000);

const PdfColor branco = PdfColor.fromInt(0xFFF7FAFF);
const PdfColor vermelho = PdfColor.fromInt(0xFFFF0000);
const PdfColor verde = PdfColor.fromInt(0xFF00E113);

const PdfColor gradiente1 = PdfColor.fromInt(0xFF7F9DFE);
const PdfColor gradiente2 = PdfColor.fromInt(0x420842FF);
const PdfColor gradiente3 = PdfColor.fromInt(0xF4547CFE);

const sep = 120.0;

Future<pw.MemoryImage> loadImageFromUrlOrAsset(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final List<int> bytes = response.bodyBytes;
      return pw.MemoryImage(
          Uint8List.fromList(bytes)); // Convertendo para Uint8List
    }
  } catch (e) {
    // Lide com o erro, se necessário
    print('Erro ao carregar a imagem da URL: $e');
  }

  final img.Image branco = img.Image(width: 1, height: 1);
  img.fill(branco, color: img.ColorFloat16.rgb(1.0, 1.0, 1.0));

  final Uint8List pngBytes = Uint8List.fromList(img.encodePng(branco));
  return pw.MemoryImage(pngBytes);
}

Future<pw.MemoryImage> loadQrCodeImageFromData(String data) async {
  if (data == '') {
    final ByteData imageData =
        await rootBundle.load('assets/images/profile.png');
    final bytes = imageData.buffer.asUint8List();
    return pw.MemoryImage(Uint8List.fromList(bytes));
  }
  try {
    final qrPainter = QrPainter(
      data: data,
      version: 3,
    );

    final image = await qrPainter.toImageData(800.0);
    final bytes = image?.buffer.asUint8List() ?? Uint8List(0);
    return pw.MemoryImage(Uint8List.fromList(bytes));
  } catch (e) {
    // Lide com o erro, se necessário
    print('Erro ao gerar o QR code: $e');
  }

  // Se falhar, carregue uma imagem local como fallback
  try {
    final ByteData imageData =
        await rootBundle.load('assets/images/profile.png');
    final bytes = imageData.buffer.asUint8List();
    return pw.MemoryImage(Uint8List.fromList(bytes));
  } catch (e) {
    // Lide com o erro, se necessário
    print('Erro ao carregar a imagem local: $e');
    return pw.MemoryImage(Uint8List(0));
  }
}

Future<Uint8List> generateResume(
  PdfPageFormat format,
  List<List<String>> _listOfLists,
  String _urlqr,
  String _tipolubcal,
  String _vallubcal,
  String _ultimatrocaoleo,
  String _proxtrocaoleo,
  String _urlimgmaq,
  String _nomemaq,
  String _tipomaq,
) async {
  final doc = pw.Document(title: 'My Résumé', author: 'David PHAM-VAN');
  List<List<String>> listOfLists = _listOfLists;
  final String vallubcal = _vallubcal;
  String tipolubcal = _tipolubcal;
  final String ultimatrocaoleo = _ultimatrocaoleo;
  final String proxtrocaoleo = _proxtrocaoleo;
  final String urlqr = _urlqr;
  final String urlimgmaq = _urlimgmaq;
  final String nomemaq = _nomemaq;
  final String tipomaq = _tipomaq;

  final qrCodeImage = await loadQrCodeImageFromData(urlqr);

  double qrcentemargin;

  final profileImagemaq = await loadImageFromUrlOrAsset(urlimgmaq);

  bool filtrointevisible = false;
  bool filtroextevisible = false;
  bool separadorevisible = false;
  bool combustvisible = false;

  bool qrCente;

  if (vallubcal != '')
    (qrCente = true);
  else
    (qrCente = false);

  if (vallubcal != '' || tipolubcal == '')
    (tipolubcal = 'Calibrar e lubrificar');
  Future<pw.Font> loadCustomFont(String fonturi) async {
    final ByteData fontData = await rootBundle.load(fonturi);
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    return ttf;
  }

  final w300 = await loadCustomFont('fonts/inter/w300.ttf');
  final w400 = await loadCustomFont('fonts/inter/w400.ttf');
  final w600 = await loadCustomFont('fonts/inter/w600.ttf');
  final w700 = await loadCustomFont('fonts/inter/w700.ttf');
  final w800 = await loadCustomFont('fonts/inter/w800.ttf');

// Exemplo de uso

  List<List<String>> listafiltros = [];

  for (List<String> innerList in listOfLists) {
    if (listafiltros.length < 4 &&
        innerList.isNotEmpty &&
        innerList[0].isNotEmpty &&
        innerList[0] != 'NaN') {
      if (innerList.length >= 5) {
        listafiltros.add(List<String>.from(innerList.sublist(0, 5)));
      } else {
        listafiltros.add(List<String>.from(innerList));
      }
      int countListafiltros = listafiltros.length;

      filtrointevisible = countListafiltros >= 1;
      filtroextevisible = countListafiltros >= 2;
      separadorevisible = countListafiltros >= 3;
      combustvisible = countListafiltros >= 4;
    }
  }

// Adiciona listas vazias caso necessário para garantir um total de 4 listas
  while (listafiltros.length < 4) {
    listafiltros.add([
      '',
      '',
      '',
      '',
      '',
    ]);
  }

  final profileImage1 = await loadImageFromUrlOrAsset(listafiltros[0][2]);
  final profileImage2 = await loadImageFromUrlOrAsset(listafiltros[1][2]);
  final profileImage3 = await loadImageFromUrlOrAsset(listafiltros[2][2]);
  final profileImage4 = await loadImageFromUrlOrAsset(listafiltros[3][2]);

  if (qrCente)
    (qrcentemargin = 0);
  else
    (qrcentemargin = 65);

  print('dde');
  doc.addPage(
    pw.MultiPage(
        margin: pw.EdgeInsets.fromLTRB(35.9 /*35.9*/, 20.8, 0, 0),
        build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                      child: pw.Container(
                          margin: pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Container(
                                    width: 512, //512
                                    height: 362.01,
                                    child: pw.Stack(children: [
                                      pw.Container(
                                        width: 255.3,
                                        height: 362.01,
                                        child: pw.Stack(
                                          children: [
                                            pw.Positioned(
                                                left: 0.37,
                                                top: 0.50,
                                                child: pw.Container(
                                                  width: 253.37,
                                                  height: 368.01,
                                                  //clipBehavior: Clip.antiAlias,
                                                  decoration: pw.BoxDecoration(
                                                    gradient: pw.LinearGradient(
                                                      begin: pw.Alignment(
                                                          0.00, -1.00),
                                                      end: pw.Alignment(0, 1),
                                                      colors: [
                                                        gradiente1,
                                                        gradiente2,
                                                        gradiente3
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      pw.BoxShadow(
                                                        color: preto,
                                                        blurRadius: 4,
                                                        offset: PdfPoint(0, 4),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: pw.Stack(children: [
                                                    pw.Positioned(
                                                        left: 4,
                                                        top: 3.80,
                                                        child: pw.Container(
                                                          width: 250.73,
                                                          height: 362.70,
                                                          child: pw.Stack(
                                                            children: [
                                                              pw.Positioned(
                                                                left: 0,
                                                                top: 165,
                                                                child: pw
                                                                    .Container(
                                                                  width: 245.78,
                                                                  height: 26.94,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Opacity(
                                                                          opacity:
                                                                              0.99,
                                                                          child:
                                                                              pw.Container(
                                                                            width:
                                                                                245.78,
                                                                            height:
                                                                                26.94,
                                                                            decoration:
                                                                                pw.BoxDecoration(
                                                                              color: branco,
                                                                              border: pw.Border.all(
                                                                                width: 1,
                                                                                color: pretoborda,
                                                                              ),
                                                                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            3.37,
                                                                        top:
                                                                            1.17,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              239.88,
                                                                          height:
                                                                              20.60,
                                                                          child:
                                                                              pw.Opacity(
                                                                            opacity:
                                                                                0.90,
                                                                            child:
                                                                                pw.Text(
                                                                              ultimatrocaoleo,
                                                                              textAlign: pw.TextAlign.center,
                                                                              style: pw.TextStyle(
                                                                                color: preto,
                                                                                fontSize: 23,
                                                                                font: w400,
                                                                                height: 0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 10.73,
                                                                top: 210.70,
                                                                child: pw
                                                                    .Container(
                                                                  width: 227,
                                                                  decoration: pw
                                                                      .BoxDecoration(
                                                                    border:
                                                                        pw.Border
                                                                            .all(
                                                                      width:
                                                                          0.50,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 16.73,
                                                                top: 345.40,
                                                                child: pw
                                                                    .Container(
                                                                  width: 212,
                                                                  decoration: pw
                                                                      .BoxDecoration(
                                                                    border:
                                                                        pw.Border
                                                                            .all(
                                                                      width:
                                                                          1.40,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 3.63,
                                                                top: 150.30,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 239,
                                                                  height: 9,
                                                                  child:
                                                                      pw.Text(
                                                                    'Última Troca de óleo',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          preto,
                                                                      fontSize:
                                                                          13,
                                                                      //fontBold: ,
                                                                      //fontFamily: 'Inter',

                                                                      height:
                                                                          0.07,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 1.73,
                                                                top: 50.70,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 90,
                                                                  height: 9,
                                                                  child: pw
                                                                      .Transform(
                                                                    transform: Matrix4
                                                                        .identity()
                                                                      ..translate(
                                                                          0.0,
                                                                          0.0)
                                                                      ..rotateZ(
                                                                          -1.57),
                                                                    child:
                                                                        pw.Text(
                                                                      tipomaq,
                                                                      textAlign: pw
                                                                          .TextAlign
                                                                          .center,
                                                                      style: pw
                                                                          .TextStyle(
                                                                        color:
                                                                            preto,
                                                                        fontSize:
                                                                            8,
                                                                        font:
                                                                            w400,
                                                                        height:
                                                                            0.19,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (filtrointevisible ||
                                                                  filtroextevisible ||
                                                                  separadorevisible ||
                                                                  combustvisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            10.73,
                                                                        top:
                                                                            193.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              240,
                                                                          height:
                                                                              10,
                                                                          child:
                                                                              pw.Text(
                                                                            'Filtros',
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 14,

                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0.06,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              pw.Positioned(
                                                                left: 106.73,
                                                                top: 345.70,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 50,
                                                                  height: 10,
                                                                  child:
                                                                      pw.Text(
                                                                    'Supervisor',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          preto,
                                                                      fontSize:
                                                                          9,
                                                                      // fontFamily: 'Inter',
                                                                      font:
                                                                          w300, //fontWeight: FontWeight.w300,,
                                                                      height:
                                                                          0.15,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 3.50,
                                                                top: 0.80,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 144,
                                                                  height: 23,
                                                                  child:
                                                                      pw.Text(
                                                                    'Última troca',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          vermelho,
                                                                      fontSize:
                                                                          21.50,
                                                                      // fontFamily: 'Inter',
                                                                      font:
                                                                          w800,
                                                                      height: 0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (qrCente)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            126.73,
                                                                        top:
                                                                            74.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              111,
                                                                          height:
                                                                              13,
                                                                          child:
                                                                              pw.Text(
                                                                            tipolubcal,
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            125.81,
                                                                        top:
                                                                            89.05,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              114.23,
                                                                          height:
                                                                              19.81,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 114.23,
                                                                                    height: 19.81,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.17,
                                                                                top: 2.38,
                                                                                child: pw.SizedBox(
                                                                                  width: 108.68,
                                                                                  height: 15.05,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      vallubcal,
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 12,
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              pw.Positioned(
                                                                left: 208.73,
                                                                top: 229.70,
                                                                child: pw
                                                                    .Container(
                                                                  width: 17,
                                                                  height: 10,
                                                                  //clipBehavior: Clip.antiAlias,
                                                                  decoration: pw
                                                                      .BoxDecoration(),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 10.58,
                                                                top: 29.16,
                                                                child: pw
                                                                    .Container(
                                                                  width: 225.80,
                                                                  height: 29.68,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              225.80,
                                                                          height:
                                                                              29.68,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 225.80,
                                                                                    height: 29.68,
                                                                                    decoration: pw.BoxDecoration(color: branco, borderRadius: pw.BorderRadius.circular(4)),
                                                                                  ),
                                                                                ),
                                                                              ),
/*
                                                                        pw.Positioned(
                                                                          left: 6.34,
                                                                          top: 3.56,
                                                                          child: pw.SizedBox(
                                                                            width: 217.19,
                                                                            height: 22.56,
                                                                            child: pw.Opacity(
                                                                              opacity: 0.90,
                                                                              child: pw.Text(
                                                                                'Terça - feira',
                                                                                textAlign: pw.TextAlign.center,
                                                                                style: pw.TextStyle(
                                                                                  color: branco,
                                                                                  fontSize: 10,
                                                                                  // fontFamily: 'Inter',
                                                                                    font:w400 ,
                                                                                  height: 0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        */
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            6.67,
                                                                        top: 0,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              212.46,
                                                                          height:
                                                                              29.68,
                                                                          child:
                                                                              pw.Center(
                                                                            child:
                                                                                pw.Text(
                                                                              nomemaq,
                                                                              textAlign: pw.TextAlign.center,
                                                                              style: pw.TextStyle(
                                                                                color: preto,
                                                                                fontSize: 13,
                                                                                // fontFamily: 'Inter',
                                                                                font: w700,
                                                                                height: 0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 101.73,
                                                                top: 272.21,
                                                                child: pw
                                                                    .Container(
                                                                        width:
                                                                            16,
                                                                        height:
                                                                            9.95),
                                                              ),
                                                              pw.Positioned(
                                                                left: 179.16,
                                                                top: 0,
                                                                child: pw
                                                                    .Container(
                                                                  width: 62.03,
                                                                  height: 25.99,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              62.03,
                                                                          height:
                                                                              25.99,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            color:
                                                                                branco,
                                                                            border:
                                                                                pw.Border.all(
                                                                              width: 0.10,
                                                                              color: pretoborda,
                                                                            ),
                                                                            borderRadius:
                                                                                pw.BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              62.03,
                                                                          height:
                                                                              25.99,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImagemaq,
                                                                              fit: pw.BoxFit.fill,
                                                                            ),
                                                                            borderRadius:
                                                                                pw.BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 15.12 +
                                                                    qrcentemargin,
                                                                top: 64.09,
                                                                child: pw
                                                                    .Container(
                                                                  width: 85.42,
                                                                  height: 85.21,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              85.42,
                                                                          height:
                                                                              85.21,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            color:
                                                                                branco,
                                                                            border:
                                                                                pw.Border.all(
                                                                              width: 1.60,
                                                                              color: pretoborda,
                                                                            ),
                                                                            borderRadius:
                                                                                pw.BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            6.41,
                                                                        top:
                                                                            6.39,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              71.90,
                                                                          height:
                                                                              71.72,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: qrCodeImage,
                                                                              fit: pw.BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (filtrointevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            97.63,
                                                                        top:
                                                                            214.51,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage1,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            1.73,
                                                                        top: /*topc +*/
                                                                            215.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[0][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top:
                                                                            229.86,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[0][0],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top:
                                                                            251.96,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[0][3],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (filtroextevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            224.73,
                                                                        top:
                                                                            214.51,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage2,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            124.73,
                                                                        top: /*topc +*/
                                                                            215.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[1][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            123.98,
                                                                        top:
                                                                            230.54,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.56,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.56,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.32,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 113.63,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[1][0],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            123.98,
                                                                        top:
                                                                            252.41,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.44,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.44,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.32,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 113.63,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[1][3],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (separadorevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            97.63,
                                                                        top:
                                                                            275.18,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage3,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            1.73,
                                                                        top: /*topc +*/
                                                                            276.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[2][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            0.83,
                                                                        top:
                                                                            290.62,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[2][0],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            0.83,
                                                                        top:
                                                                            312.72,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[2][3],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (combustvisible)
                                                                (pw.Stack(
                                                                  children: [
                                                                    pw.Positioned(
                                                                      left:
                                                                          224.73,
                                                                      top:
                                                                          275.18,
                                                                      child: pw
                                                                          .Container(
                                                                        width:
                                                                            13.50,
                                                                        height:
                                                                            13.50,
                                                                        decoration:
                                                                            pw.BoxDecoration(
                                                                          image:
                                                                              pw.DecorationImage(
                                                                            image:
                                                                                profileImage4,
                                                                            fit:
                                                                                pw.BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    pw.Positioned(
                                                                      left:
                                                                          126.73,
                                                                      top: /*topc +*/
                                                                          276.70,
                                                                      child: pw
                                                                          .SizedBox(
                                                                        width:
                                                                            94.54,
                                                                        height:
                                                                            15.08,
                                                                        child: pw
                                                                            .Text(
                                                                          listafiltros[3]
                                                                              [
                                                                              1],
                                                                          textAlign: pw
                                                                              .TextAlign
                                                                              .center,
                                                                          style:
                                                                              pw.TextStyle(
                                                                            color:
                                                                                preto,
                                                                            fontSize:
                                                                                10,
                                                                            // fontFamily: 'Inter',
                                                                            font:
                                                                                w600, //fontWeight: FontWeight.w600,
                                                                            height:
                                                                                0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    pw.Positioned(
                                                                      left:
                                                                          124.14,
                                                                      top:
                                                                          290.62,
                                                                      child: pw
                                                                          .Container(
                                                                        width:
                                                                            118.58,
                                                                        height:
                                                                            19.73,
                                                                        child: pw
                                                                            .Stack(
                                                                          children: [
                                                                            pw.Positioned(
                                                                              left: 0,
                                                                              top: 0,
                                                                              child: pw.Opacity(
                                                                                opacity: 0.99,
                                                                                child: pw.Container(
                                                                                  width: 118.58,
                                                                                  height: 19.73,
                                                                                  decoration: pw.BoxDecoration(
                                                                                    color: branco,
                                                                                    border: pw.Border.all(
                                                                                      width: 1,
                                                                                      color: pretoborda,
                                                                                    ),
                                                                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Positioned(
                                                                              left: 3.29,
                                                                              top: 2.37,
                                                                              child: pw.SizedBox(
                                                                                width: 112.82,
                                                                                height: 14.99,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.90,
                                                                                  child: pw.Text(
                                                                                    listafiltros[3][0],
                                                                                    textAlign: pw.TextAlign.center,
                                                                                    style: pw.TextStyle(
                                                                                      color: preto,
                                                                                      fontSize: 11,
                                                                                      // fontFamily: 'Inter',
                                                                                      font: w400,
                                                                                      height: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    pw.Positioned(
                                                                      left:
                                                                          123.98,
                                                                      top:
                                                                          312.73,
                                                                      child: pw
                                                                          .Container(
                                                                        width:
                                                                            118.68,
                                                                        height:
                                                                            19.73,
                                                                        child: pw
                                                                            .Stack(
                                                                          children: [
                                                                            pw.Positioned(
                                                                              left: 0,
                                                                              top: 0,
                                                                              child: pw.Opacity(
                                                                                opacity: 0.99,
                                                                                child: pw.Container(
                                                                                  width: 118.68,
                                                                                  height: 19.73,
                                                                                  decoration: pw.BoxDecoration(
                                                                                    color: branco,
                                                                                    border: pw.Border.all(
                                                                                      width: 1,
                                                                                      color: pretoborda,
                                                                                    ),
                                                                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Positioned(
                                                                              left: 3.30,
                                                                              top: 2.37,
                                                                              child: pw.SizedBox(
                                                                                width: 112.92,
                                                                                height: 14.99,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.90,
                                                                                  child: pw.Text(
                                                                                    listafiltros[3][3],
                                                                                    textAlign: pw.TextAlign.center,
                                                                                    style: pw.TextStyle(
                                                                                      color: preto,
                                                                                      fontSize: 11,
                                                                                      // fontFamily: 'Inter',
                                                                                      font: w400,
                                                                                      height: 0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                            ],
                                                          ),
                                                        )),
                                                  ]),
                                                )),
                                          ],
                                        ),
                                      ),
                                      pw.Positioned(
                                        left: 256.2,
                                        top: 0,
                                        child: pw.Container(
                                          width: 255.3,
                                          height: 362.01,
                                          child: pw.Stack(
                                            children: [
                                              pw.Positioned(
                                                left: 0.37,
                                                top: 0.50,
                                                child: pw.Container(
                                                  width: 253.37,
                                                  height: 368.01,
                                                  //clipBehavior: Clip.antiAlias,
                                                  decoration: pw.BoxDecoration(
                                                    gradient: pw.LinearGradient(
                                                      begin: pw.Alignment(
                                                          0.00, -1.00),
                                                      end: pw.Alignment(0, 1),
                                                      colors: [
                                                        gradiente1,
                                                        gradiente2,
                                                        gradiente3
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      pw.BoxShadow(
                                                        color: preto,
                                                        blurRadius: 4,
                                                        offset: PdfPoint(0, 4),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: pw.Stack(
                                                    children: [
                                                      pw.Positioned(
                                                        left: 2.50,
                                                        top: 3.80,
                                                        child: pw.Container(
                                                          width: 250.73,
                                                          height: 362.70,
                                                          child: pw.Stack(
                                                            children: [
                                                              pw.Positioned(
                                                                left: 2.09,
                                                                top: 165.8,
                                                                child: pw
                                                                    .Container(
                                                                  width: 245.78,
                                                                  height: 26.94,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Opacity(
                                                                          opacity:
                                                                              0.99,
                                                                          child:
                                                                              pw.Container(
                                                                            width:
                                                                                245.78,
                                                                            height:
                                                                                26.94,
                                                                            decoration:
                                                                                pw.BoxDecoration(
                                                                              color: branco,
                                                                              border: pw.Border.all(
                                                                                width: 1,
                                                                                color: pretoborda,
                                                                              ),
                                                                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            3.37,
                                                                        top:
                                                                            1.17,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              239.88,
                                                                          height:
                                                                              20.60,
                                                                          child:
                                                                              pw.Opacity(
                                                                            opacity:
                                                                                0.90,
                                                                            child:
                                                                                pw.Text(
                                                                              proxtrocaoleo,
                                                                              textAlign: pw.TextAlign.center,
                                                                              style: pw.TextStyle(
                                                                                color: preto,
                                                                                fontSize: 23,
                                                                                // fontFamily: 'Inter',
                                                                                // fontWeight: pw.FontWeight.normal,
                                                                                height: 0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (qrCente)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            126.73,
                                                                        top:
                                                                            74.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              111,
                                                                          height:
                                                                              13,
                                                                          child:
                                                                              pw.Text(
                                                                            tipolubcal,
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            125.81,
                                                                        top:
                                                                            89.05,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              114.23,
                                                                          height:
                                                                              19.81,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 114.23,
                                                                                    height: 19.81,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.17,
                                                                                top: 2.38,
                                                                                child: pw.SizedBox(
                                                                                  width: 108.68,
                                                                                  height: 15.05,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      vallubcal,
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 12,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              pw.Positioned(
                                                                left: 10.73,
                                                                top: 210.70,
                                                                child: pw
                                                                    .Container(
                                                                  width: 227,
                                                                  decoration: pw
                                                                      .BoxDecoration(
                                                                    border:
                                                                        pw.Border
                                                                            .all(
                                                                      width:
                                                                          0.50,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 16.73,
                                                                top: 345.40,
                                                                child: pw
                                                                    .Container(
                                                                  width: 212,
                                                                  decoration: pw
                                                                      .BoxDecoration(
                                                                    border:
                                                                        pw.Border
                                                                            .all(
                                                                      width:
                                                                          1.40,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 7.73,
                                                                top: 150.30,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 239,
                                                                  height: 9,
                                                                  child:
                                                                      pw.Text(
                                                                    'Próxima Troca de óleo',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          preto,
                                                                      fontSize:
                                                                          13,
                                                                      // fontFamily: 'Inter',
                                                                      font:
                                                                          w400,
                                                                      height:
                                                                          0.07,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 1.73,
                                                                top: 50.70,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 90,
                                                                  height: 9,
                                                                  child: pw
                                                                      .Transform(
                                                                    transform: Matrix4
                                                                        .identity()
                                                                      ..translate(
                                                                          0.0,
                                                                          0.0)
                                                                      ..rotateZ(
                                                                          -1.57),
                                                                    child:
                                                                        pw.Text(
                                                                      tipomaq,
                                                                      textAlign: pw
                                                                          .TextAlign
                                                                          .center,
                                                                      style: pw
                                                                          .TextStyle(
                                                                        color:
                                                                            preto,
                                                                        fontSize:
                                                                            8,
                                                                        // fontFamily: 'Inter',
                                                                        font:
                                                                            w400,
                                                                        height:
                                                                            0.19,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (filtrointevisible ||
                                                                  filtroextevisible ||
                                                                  separadorevisible ||
                                                                  combustvisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            10.73,
                                                                        top:
                                                                            194.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              240,
                                                                          height:
                                                                              10,
                                                                          child:
                                                                              pw.Text(
                                                                            'Filtros',
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 14,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0.06,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              pw.Positioned(
                                                                left: 106.73,
                                                                top: 345.70,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 50,
                                                                  height: 10,
                                                                  child:
                                                                      pw.Text(
                                                                    'Supervisor',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          preto,
                                                                      fontSize:
                                                                          9,
                                                                      // fontFamily: 'Inter',
                                                                      font:
                                                                          w300, //fontWeight: FontWeight.w300,,
                                                                      height:
                                                                          0.15,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 3.50,
                                                                top: 0.20,
                                                                child:
                                                                    pw.SizedBox(
                                                                  width: 163,
                                                                  height: 23,
                                                                  child:
                                                                      pw.Text(
                                                                    'Próxima troca',
                                                                    textAlign: pw
                                                                        .TextAlign
                                                                        .center,
                                                                    style: pw
                                                                        .TextStyle(
                                                                      color:
                                                                          verde,
                                                                      fontSize:
                                                                          21.50,
                                                                      // fontFamily: 'Inter',
                                                                      font:
                                                                          w800,
                                                                      height: 0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 208.73,
                                                                top: 229.70,
                                                                child: pw
                                                                    .Container(
                                                                  width: 17,
                                                                  height: 10,
                                                                  //clipBehavior: Clip.antiAlias,
                                                                  decoration: pw
                                                                      .BoxDecoration(),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 10.58,
                                                                top: 29.16,
                                                                child: pw
                                                                    .Container(
                                                                  width: 225.80,
                                                                  height: 29.68,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              225.80,
                                                                          height:
                                                                              29.68,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 225.80,
                                                                                    height: 29.68,
                                                                                    decoration: pw.BoxDecoration(color: branco, borderRadius: pw.BorderRadius.circular(4)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 6.34,
                                                                                top: 3.56,
                                                                                child: pw.SizedBox(
                                                                                  width: 217.19,
                                                                                  height: 22.56,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      'Terça - feira',
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: branco,
                                                                                        fontSize: 10,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            6.67,
                                                                        top: 0,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              212.46,
                                                                          height:
                                                                              29.68,
                                                                          child:
                                                                              pw.Center(
                                                                            child:
                                                                                pw.Text(
                                                                              nomemaq,
                                                                              textAlign: pw.TextAlign.center,
                                                                              style: pw.TextStyle(
                                                                                color: preto,
                                                                                fontSize: 13,
                                                                                // fontFamily: 'Inter',
                                                                                font: w700,
                                                                                height: 0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              pw.Positioned(
                                                                left: 101.73,
                                                                top: 272.21,
                                                                child: pw
                                                                    .Container(
                                                                        width:
                                                                            16,
                                                                        height:
                                                                            9.95),
                                                              ),
                                                              pw.Positioned(
                                                                  left: 179.16,
                                                                  top: 0,
                                                                  child: pw
                                                                      .Container(
                                                                    width:
                                                                        62.03,
                                                                    height:
                                                                        25.99,
                                                                    child: pw
                                                                        .Stack(
                                                                      children: [
                                                                        pw.Positioned(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          child:
                                                                              pw.Container(
                                                                            width:
                                                                                62.03,
                                                                            height:
                                                                                25.99,
                                                                            decoration:
                                                                                pw.BoxDecoration(
                                                                              color: branco,
                                                                              border: pw.Border.all(
                                                                                width: 0.10,
                                                                                color: pretoborda,
                                                                              ),
                                                                              borderRadius: pw.BorderRadius.circular(10),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        pw.Positioned(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          child:
                                                                              pw.Container(
                                                                            width:
                                                                                62.03,
                                                                            height:
                                                                                25.99,
                                                                            decoration:
                                                                                pw.BoxDecoration(
                                                                              image: pw.DecorationImage(
                                                                                image: profileImagemaq,
                                                                                fit: pw.BoxFit.fill,
                                                                              ),
                                                                              borderRadius: pw.BorderRadius.circular(10),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                              pw.Positioned(
                                                                left: 15.12 +
                                                                    qrcentemargin,
                                                                top: 64.09,
                                                                child: pw
                                                                    .Container(
                                                                  width: 85.42,
                                                                  height: 85.21,
                                                                  child:
                                                                      pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              85.42,
                                                                          height:
                                                                              85.21,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            color:
                                                                                branco,
                                                                            border:
                                                                                pw.Border.all(
                                                                              width: 1.60,
                                                                              color: pretoborda,
                                                                            ),
                                                                            borderRadius:
                                                                                pw.BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            6.41,
                                                                        top:
                                                                            6.39,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              71.90,
                                                                          height:
                                                                              71.72,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: qrCodeImage,
                                                                              fit: pw.BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              if (filtrointevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            1.13,
                                                                        top: /*topc +*/
                                                                            229.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[0][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            98.13,
                                                                        top:
                                                                            228.43,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage1,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left: 0,
                                                                        top:
                                                                            244.40,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[0][4],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (filtroextevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            224.13,
                                                                        top:
                                                                            228.43,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage2,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            126.13,
                                                                        top: /*topc +*/
                                                                            229.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[1][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            123.98,
                                                                        top:
                                                                            244.41,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.44,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.44,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.32,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 113.63,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[1][4],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (separadorevisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            1.73,
                                                                        top: /*topc +*/
                                                                            276.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[2][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            97.73,
                                                                        top:
                                                                            275.18,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage3,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            0.83,
                                                                        top:
                                                                            290.62,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              119.98,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 119.98,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.33,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 114.15,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[2][4],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                              if (combustvisible)
                                                                (pw.Stack(
                                                                    children: [
                                                                      pw.Positioned(
                                                                        left:
                                                                            224.73,
                                                                        top:
                                                                            275.18,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              13.50,
                                                                          height:
                                                                              13.50,
                                                                          decoration:
                                                                              pw.BoxDecoration(
                                                                            image:
                                                                                pw.DecorationImage(
                                                                              image: profileImage4,
                                                                              fit: pw.BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            126.73,
                                                                        top: /*topc +*/
                                                                            276.70,
                                                                        child: pw
                                                                            .SizedBox(
                                                                          width:
                                                                              94.54,
                                                                          height:
                                                                              15.08,
                                                                          child:
                                                                              pw.Text(
                                                                            listafiltros[3][1],
                                                                            textAlign:
                                                                                pw.TextAlign.center,
                                                                            style:
                                                                                pw.TextStyle(
                                                                              color: preto,
                                                                              fontSize: 10,
                                                                              // fontFamily: 'Inter',
                                                                              font: w600, //fontWeight: FontWeight.w600,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      pw.Positioned(
                                                                        left:
                                                                            124.14,
                                                                        top:
                                                                            290.62,
                                                                        child: pw
                                                                            .Container(
                                                                          width:
                                                                              118.58,
                                                                          height:
                                                                              19.73,
                                                                          child:
                                                                              pw.Stack(
                                                                            children: [
                                                                              pw.Positioned(
                                                                                left: 0,
                                                                                top: 0,
                                                                                child: pw.Opacity(
                                                                                  opacity: 0.99,
                                                                                  child: pw.Container(
                                                                                    width: 118.58,
                                                                                    height: 19.73,
                                                                                    decoration: pw.BoxDecoration(
                                                                                      color: branco,
                                                                                      border: pw.Border.all(
                                                                                        width: 1,
                                                                                        color: pretoborda,
                                                                                      ),
                                                                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.1)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              pw.Positioned(
                                                                                left: 3.29,
                                                                                top: 2.37,
                                                                                child: pw.SizedBox(
                                                                                  width: 112.82,
                                                                                  height: 14.99,
                                                                                  child: pw.Opacity(
                                                                                    opacity: 0.90,
                                                                                    child: pw.Text(
                                                                                      listafiltros[3][4],
                                                                                      textAlign: pw.TextAlign.center,
                                                                                      style: pw.TextStyle(
                                                                                        color: preto,
                                                                                        fontSize: 11,
                                                                                        // fontFamily: 'Inter',
                                                                                        font: w400,
                                                                                        height: 0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]))
                              ])))
                ],
              ),
            ]),
  );
  return doc.save();
}
