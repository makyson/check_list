import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:untitled/api.dart';

import 'resume.dart';

class MachineInfo {
  final String nome;
  final String imageUrl;
  final String description;
  final String pdf;
  final String modelo;
  final String ultimaTrocaData;
  final String ultimaTrocaHorim;
  final String dataAtual;
  final String horiAtual;
  final String hrTraba;
  final String intervalo;
  final String hrRest;
  final String vallubcal;
  final String tipolubcal;
  final String urlqrcode;
  final String proximatrocahor;

  final List<Filter> filtros;

  MachineInfo({
    required this.nome,
    required this.imageUrl,
    required this.description,
    required this.pdf,
    required this.modelo,
    required this.ultimaTrocaData,
    required this.ultimaTrocaHorim,
    required this.dataAtual,
    required this.horiAtual,
    required this.hrTraba,
    required this.intervalo,
    required this.hrRest,
    required this.filtros,
    required this.vallubcal,
    required this.tipolubcal,
    required this.urlqrcode,
    required this.proximatrocahor,
  });
}

class Filter {
  final String urlImagem;
  final String nomeFiltro;
  final String horasRest;
  final String nomeSol;
  final String nomeReq;
  final String referencia;
  final String obs;
  final String dataUltima;
  final String horInit;
  final String proximatrocahor;

  Filter({
    required this.urlImagem,
    required this.nomeFiltro,
    required this.horasRest,
    required this.nomeSol,
    required this.nomeReq,
    required this.referencia,
    required this.obs,
    required this.dataUltima,
    required this.horInit,
    required this.proximatrocahor,
  });
}

class PreencherFichaScreen extends StatefulWidget {
  const PreencherFichaScreen({Key? key}) : super(key: key);

  @override
  _MachineDataScreenState createState() => _MachineDataScreenState();
}

class _MachineDataScreenState extends State<PreencherFichaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  String? valLubController;
  final TextEditingController trocaAtualController = TextEditingController();
  final TextEditingController trocaProxController = TextEditingController();
  final TextEditingController qrCodeController = TextEditingController();
  final TextEditingController urlImagemController = TextEditingController();

  Uint8List? pdfGerado;
  List<Map<String, TextEditingController>> filtros = [];

  @override
  void initState() {
    super.initState();
    // Começa com um filtro por padrão
  }

  final List<String> diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  Widget buildFiltroForm(int index) {
    final filtro = filtros[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          TextFormField(
            controller: filtro["nomeFiltro"],
            decoration: InputDecoration(
                labelText: 'Nome do Filtro', border: OutlineInputBorder()),
            onChanged: (_) =>
                setState(() {}), // força rebuild para atualizar o título
            validator: (value) =>
                value!.isEmpty ? 'Informe o nome do filtro' : null,
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: filtro["urlImagem"],
            decoration: InputDecoration(
                labelText: 'URL da Imagem do Filtro',
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: filtro["horinit"],
            decoration: InputDecoration(
                labelText: 'Horímetro Inicial', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: filtro["dataUltima"],
            decoration: InputDecoration(
                labelText: 'Data da Última Troca',
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: filtro["proxTroca"],
            decoration: InputDecoration(
                labelText: 'Próxima Troca', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 8,
          ),
          if (filtros.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    filtros.removeAt(index);
                  });
                },
                icon: Icon(Icons.remove_circle, color: Colors.red),
                label: Text("Remover", style: TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> gerarPDF() async {
    if (!_formKey.currentState!.validate()) return;

    final List<List<String>> listaFiltros = filtros.map((filtro) {
      return [
        filtro["horinit"]!.text,
        filtro["nomeFiltro"]!.text,
        filtro["urlImagem"]!.text,
        filtro["dataUltima"]!.text,
        filtro["proxTroca"]!.text,
      ];
    }).toList();

    final pdf = await generateResume(
      PdfPageFormat.a4,
      listaFiltros,
      qrCodeController.text,
      valLubController ?? '',
      valLubController ?? '',
      trocaAtualController.text,
      trocaProxController.text,
      urlImagemController.text,
      nomeController.text,
      modeloController.text,
    );

    setState(() {
      pdfGerado = pdf;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preencher Ficha Manualmente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                    labelText: 'Nome da Máquina', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: modeloController,
                decoration: InputDecoration(
                    labelText: 'Modelo', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 8,
              ),
              DropdownButtonFormField<String?>(
                value: valLubController,
                decoration: InputDecoration(
                  labelText: 'Dia da troca',
                  border: OutlineInputBorder(),
                ),
                icon: valLubController == null
                    ? null
                    : ElevatedButton(
                        child: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            valLubController = null;
                          });
                        },
                      ),
                items: diasDaSemana.map((dia) {
                  return DropdownMenuItem<String>(
                    value: dia,
                    child: Text(dia),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    valLubController = value!;
                  });
                },
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: trocaAtualController,
                decoration: InputDecoration(
                    labelText: 'Última troca de óleo',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: trocaProxController,
                decoration: InputDecoration(
                    labelText: 'Próxima troca de óleo',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: qrCodeController,
                decoration: InputDecoration(
                    labelText: 'URL do QR Code', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: urlImagemController,
                decoration: InputDecoration(
                    labelText: 'URL da Imagem da Máquina',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 8,
              ),
              const SizedBox(height: 16),
              Text(
                'Filtros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filtros.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      filtros[index]["nomeFiltro"]!.text.isEmpty
                          ? 'Filtro ${index + 1}'
                          : filtros[index]["nomeFiltro"]!.text,
                    ),
                    children: [buildFiltroForm(index)],
                  );
                },
              ),
              if (filtros.length < 4)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      filtros.add({
                        "horinit": TextEditingController(),
                        "nomeFiltro": TextEditingController(),
                        "urlImagem": TextEditingController(),
                        "dataUltima": TextEditingController(),
                        "proxTroca": TextEditingController(),
                      });
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Adicionar Filtro'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: gerarPDF,
                child: Text('Gerar PDF'),
              ),
              const SizedBox(height: 20),
              if (pdfGerado != null)
                Column(
                  children: [
                    Text('Pré-visualização do PDF'),
                    Container(
                      height: 500,
                      child: PdfPreview(
                        build: (format) async => pdfGerado!,
                        useActions: true,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class qr_code_pdf extends StatelessWidget {
  final String? urlqr;
  final String? tipolubcal;
  final String? vallubcal;
  final String? ultimatrocaoleo;
  final String? proxtrocaoleo;
  final String? urlimgmaq;
  final String? nomemaq;
  final String? tipomaq;
  final List<List<String>>? data;
  final String? apirest;

  const qr_code_pdf({
    super.key,
    this.urlqr = '',
    this.tipolubcal = '',
    this.vallubcal = '',
    this.ultimatrocaoleo = '',
    this.proxtrocaoleo = '',
    this.urlimgmaq = '',
    this.nomemaq = '',
    this.tipomaq = '',
    this.data,
    this.apirest,
  });

  Future<Map<String, dynamic>> fetchMachineData(String machineId) async {
    print('resposta $machineId');
    final response =
        await http.get(Uri.parse(apidevprod() + 'maquina/novo/$machineId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollbarTheme = ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
    );

    return MaterialApp(
        theme: ThemeData.light().copyWith(scrollbarTheme: scrollbarTheme),
        darkTheme: ThemeData.dark().copyWith(scrollbarTheme: scrollbarTheme),
        title: nomemaq != '' ? '$nomemaq' : 'Gesso integral',
        home: MyApp(
          proxtrocaoleo: proxtrocaoleo,
          nomemaq: nomemaq,
          data: data,
          tipolubcal: tipolubcal,
          tipomaq: tipomaq,
          ultimatrocaoleo: ultimatrocaoleo,
          urlimgmaq: urlimgmaq,
          urlqr: urlqr,
          vallubcal: vallubcal,
        ));
  }
}

class MyApp extends StatefulWidget {
  final String? urlqr;
  final String? tipolubcal;
  final String? vallubcal;
  final String? ultimatrocaoleo;
  final String? proxtrocaoleo;
  final String? urlimgmaq;
  final String? nomemaq;
  final String? tipomaq;
  final List<List<String>>? data;

  const MyApp({
    super.key,
    this.urlqr = '',
    this.tipolubcal = '',
    this.vallubcal = '',
    this.ultimatrocaoleo = '',
    this.proxtrocaoleo = '',
    this.urlimgmaq = '',
    this.nomemaq = '',
    this.tipomaq = '',
    this.data,
  });

  @override
  MyAppState createState() {
    return MyAppState(
      proxtrocaoleo: proxtrocaoleo,
      nomemaq: nomemaq,
      data: data ?? [[]],
      tipolubcal: tipolubcal,
      tipomaq: tipomaq,
      ultimatrocaoleo: ultimatrocaoleo,
      urlimgmaq: urlimgmaq,
      urlqr: urlqr,
      vallubcal: vallubcal,
    );
  }
}

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final String? urlqr;
  final String? tipolubcal;
  final String? vallubcal;
  final String? ultimatrocaoleo;
  final String? proxtrocaoleo;
  final String? urlimgmaq;
  final String? nomemaq;
  final String? tipomaq;
  final List<List<String>>? data;

  MyAppState({
    this.urlqr = '',
    this.tipolubcal = '',
    this.vallubcal = '',
    this.ultimatrocaoleo = '',
    this.proxtrocaoleo = '',
    this.urlimgmaq = '',
    this.nomemaq = '',
    this.tipomaq = '',
    this.data,
  });

  Uint8List _pdfvar = Uint8List(0);

  bool _isLoading = true;

  bool _isPrinting = false;
  bool _isSharing = false;

  PrintingInfo? printingInfo;
  Uint8List? pdfBytes;

  @override
  void initState() {
    setState(() {
      _isLoading = true; // Armazena o PDF carregado na variável
    });
    super.initState();
    _loadPdf();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadPdf() async {
    final loadedPdf = await generateResume(
        PdfPageFormat.a4,
        data!,
        urlqr!,
        tipolubcal!,
        vallubcal!,
        ultimatrocaoleo!,
        proxtrocaoleo!,
        urlimgmaq!,
        nomemaq!,
        tipomaq!);

    setState(() {
      _pdfvar = loadedPdf; // Armazena o PDF carregado na variável
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;

    Future<void> printPdf() async {
      if (_isPrinting) {
        return;
      }

      setState(() {
        _isPrinting = true;
      });

      try {
        final pdf = _pdfvar;

        await Printing.layoutPdf(onLayout: (_) async => pdf);
        // Resto do seu código
      } catch (e) {
        print('Erro ao imprimir o PDF: $e');
      } finally {
        setState(() {
          _isPrinting = false;
        });
      }
    }

    Future<void> loadAndSharePdf() async {
      if (_isSharing) {
        return;
      }

      setState(() {
        _isSharing = true;
      });

      // Carrega o PDF usando a função generateResume
      pdfBytes = _pdfvar;

      if (pdfBytes != null) {
        // Compartilha o PDF carregado
        await Printing.sharePdf(
            bytes: pdfBytes!, filename: 'meu_documento.pdf');
      } else {
        // Trata o caso de falha ao carregar o PDF
        print('Falha ao carregar o PDF.');
      }

      setState(() {
        _isSharing = false;
      });
    }

    double iconSize = MediaQuery.of(context).size.width * 0.02;
    double int_media = 0;

    print(iconSize);

    if (kIsWeb) {
      if (iconSize < 6.24) {
        int_media = 13;
      } else if (iconSize <= 8) {
        int_media = 18;
      } else if (iconSize <= 10) {
        int_media = 21;
      } else if (iconSize > 10) {
        int_media = 30;
      }
    } else {}

    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Indicador de carregamento
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, iconSize * 1, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              //VOLTAR
                            },
                          ),
                          Container(
                              width: iconSize * int_media,
                              child: Text('Etiquetagem de Equipamentos')),
                        ],
                      ),
                      if (kIsWeb)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (Theme.of(context).platform !=
                                      TargetPlatform.iOS ||
                                  Theme.of(context).platform !=
                                      TargetPlatform.android)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, iconSize, 0),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.print),
                                        onPressed: () {
                                          printPdf(); // Chama a função _showPrintedToast com o contexto
                                        },
                                      ),
                                      Text(
                                        'imprim',
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 0, iconSize, 0),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.download),
                                      onPressed: () {
                                        // Lógica para salvar
                                        loadAndSharePdf();
                                      },
                                    ),
                                    Text(
                                      'download',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ])
                    ]),
              ),
            ),
            body: PdfPreview(
              maxPageWidth: 700,
              build: (format) => _pdfvar,
              useActions: false,
            ),
            floatingActionButton: Column(
              verticalDirection: VerticalDirection.up,
              children: [
                if (!kIsWeb)
                  Column(
                    children: [
                      FloatingActionButton(
                        child: Icon(Icons.print),
                        onPressed: () {
                          printPdf(); // Chama a função _showPrintedToast com o contexto
                        }, // Substitua Icons.add pelo ícone que você deseja usar
                        // Substitua Colors.blue pela cor que você deseja usar
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      FloatingActionButton(
                        onPressed: () {
                          loadAndSharePdf();
                        },
                        child: Icon(Icons
                            .share), // Substitua Icons.add pelo ícone que você deseja usar
                        // Substitua Colors.blue pela cor que você deseja usar
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                    ],
                  )
              ],
            ),
          );
  }
}
