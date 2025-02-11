import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/api.dart';
import 'package:untitled/backend/api_requests/api_calls.dart';
import 'package:uuid/uuid.dart'; // para gerar IDs únicos

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../service/abrirsevico.dart';
import '../service/customCheckbox.dart';
import '../service/model.dart';
import 'abrirsevicomodeloperador.dart';

export 'abrirsevicomodeloperador.dart';

class DetalyOperadorWidget extends StatefulWidget {
  final LancamentoChecklist? initialLancamento;

  const DetalyOperadorWidget({super.key, this.initialLancamento});

  @override
  State<DetalyOperadorWidget> createState() => _DetalyOperadorWidgetState();
}

class _DetalyOperadorWidgetState extends State<DetalyOperadorWidget> {
  late DetalyOperadorModel _model;
  final ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final childWidgetKey1 = GlobalKey<FormState>();
  final childWidgetKey2 = GlobalKey<FormState>();
  final childWidgetKey3 = GlobalKey<FormState>();
  final childWidgetKey4 = GlobalKey<FormState>();

  List<bool> isSelected = [false, false];
  String controlId = '';
  ApiCallResponse? response;

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    buscaroperadores();
    buscar();
    buscaroperadoreslist();

    _model = createModel(context, () => DetalyOperadorModel());
    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();
    _model.textController7 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();
    controlId = Uuid().v4();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  List<Map<String, dynamic>> equipamento = [];
  List<Map<String, dynamic>> operador = [];

  Future<void> buscar() async {
    try {
      final response =
          await http.get(Uri.parse(apilogin() + '/list/listequipamento'));

      if (response.statusCode == 200) {
        final informacoes = json.decode(response.body);
        setState(() {
          equipamento = List<Map<String, dynamic>>.from(informacoes);
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('equipamento', jsonEncode(equipamento));
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final equipamentoData = prefs.getString('equipamento');
      if (equipamentoData != null) {
        setState(() {
          equipamento =
              List<Map<String, dynamic>>.from(jsonDecode(equipamentoData));
        });
      } else {
        throw Exception('Falha ao carregar dados');
      }
    }
  }

  Future<void> buscaroperadores() async {
    response = await Buscar_operadores.call();
    if (response!.succeeded) {
      final data = Buscar_operadores.getChecklistItems(response?.jsonBody);

      setState(() {
        operador = data!;
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> buscaroperadoreslist() async {
    response = await Buscar_checklistCalloperadores.call(id: "grupo1");
    try {
      if (response!.succeeded) {
        final data = Buscar_operadores.getChecklistItems(response?.jsonBody);

        setState(() {
          if (data != null) {
            _model.checklistItems.addAll(data
                .map((e) => ChecklistItems(
                      nome: e['nome'],
                      questionario: (e['questionarios'] as List)
                          .map((q) => QuestionarioItem(
                                id: q['id'].toString(),
                                question: q['pergunta'],
                                boxvalue: "0",
                                pickedFiles: [],
                                isoutro: false,
                              ))
                          .toList(),
                    ))
                .toList());
            // widget.checklistItems.addAll(checklistItems);
          }
        });
      } else {
        print('Falha ao carregar dados');
      }
    } catch (e) {
      print('erro ao busca operadores: ${e}');
    }
  }

  Future<void> submitChecklist() async {
    ApiCallResponse response = await Post_operadores.call(
      name: AppStateNotifier.instance.user!.userData!.name,
      operadorid: _model.operador,
      checklistItem: _model.checklistItems,
      equipamento: _model.equipamento,
      datavalue: _model.selectedDate,
    );

    if (response.statusCode == 200) {
      print('Checklist enviado com sucesso. ID: $controlId');
      context.safePop();
      context.go('/home');
    } else {
      print('Erro ao enviar checklist');
    }
  }

  void _showChecklistModalBottomSheet(
      {required BuildContext context,
      required List<QuestionarioItem> questionario}) {
    try {
      double initButon = 0.75;

      final ScrollController controller = ScrollController();
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: initButon,
            maxChildSize: 0.9,
            minChildSize: 0.25,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 60),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: questionario.length,
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    ListTile(
                                      title: Text(questionario[index].question,
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 5),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('OK',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                CustomCheckbox(
                                                  value: questionario[index]
                                                          .boxvalue ==
                                                      "1",
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      questionario[index]
                                                              .boxvalue =
                                                          value! ? "1" : "0";
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 5),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('NOK',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                CustomCheckbox(
                                                  value: questionario[index]
                                                          .boxvalue ==
                                                      "2",
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      questionario[index]
                                                              .boxvalue =
                                                          value! ? "2" : "0";
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (questionario[index]
                                            .pickedFiles
                                            .isNotEmpty &&
                                        questionario[index].boxvalue == "2")
                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          width: double.infinity,
                                          height: 65,
                                          child: Padding(
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              width: double.infinity,
                                              height: 144,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                              child: ScrollConfiguration(
                                                behavior:
                                                    MyCustomScrollBehavior(),
                                                child: ListView.builder(
                                                  controller: controller,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: questionario[index]
                                                      .pickedFiles
                                                      .length,
                                                  itemBuilder:
                                                      (context, fileIndex) {
                                                    final pickedFile =
                                                        questionario[index]
                                                                .pickedFiles[
                                                            fileIndex];
                                                    return Container(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                                  end: 4,
                                                                  start: 5),
                                                      child: GestureDetector(
                                                        child: Image.memory(
                                                          pickedFile.bytes,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Center(
                                                              child: Column(
                                                                verticalDirection:
                                                                    VerticalDirection
                                                                        .up,
                                                                children: [
                                                                  Text(
                                                                    pickedFile
                                                                        .type,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            7,
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                  Icon(
                                                                      Icons
                                                                          .document_scanner_outlined,
                                                                      size: 30),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        onTap: () async {
                                                          final updatedFiles =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      FileViewer(
                                                                files: questionario[
                                                                        index]
                                                                    .pickedFiles,
                                                                initialIndex:
                                                                    fileIndex,
                                                              ),
                                                            ),
                                                          );
                                                          if (updatedFiles !=
                                                              null) {
                                                            setModalState(
                                                                () {});
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (questionario[index]
                                            .pickedFiles
                                            .isEmpty &&
                                        questionario[index].boxvalue == "2" &&
                                        questionario[index].isoutro == false)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ButtonTheme(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                final updatedFiles =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FileViewer(
                                                      files: questionario[index]
                                                          .pickedFiles,
                                                      initialIndex: index,
                                                    ),
                                                  ),
                                                );
                                                if (updatedFiles != null) {
                                                  setModalState(() {});
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.attach_file,
                                                      color: Colors.white),
                                                  Text('Anexar',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ButtonTheme(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      final TextEditingController
                                                          _controller =
                                                          TextEditingController();
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Adicionar Observação'),
                                                        content: TextField(
                                                          controller:
                                                              _controller,
                                                          autofocus: true,
                                                          onChanged: (value) {
                                                            if (questionario[
                                                                    index]
                                                                .pickedFiles
                                                                .isNotEmpty) {
                                                              questionario[
                                                                          index]
                                                                      .pickedFiles[0] =
                                                                  PickedFilesType(
                                                                type: "phfdç",
                                                                file: "fdsfdf",
                                                                bytes:
                                                                    Uint8List(
                                                                        0),
                                                                description:
                                                                    value,
                                                              );
                                                            }
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Adicione uma descriçao...',
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                'Cancelar'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              //se o texto for vazio, não adiciona e mostra uma mensagem modal

                                                              if (_controller
                                                                  .text
                                                                  .isEmpty) {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Erro'),
                                                                      content: Text(
                                                                          'O campo não pode ser vazio'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text('OK'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );

                                                                return;
                                                              }

                                                              if (index >= 0 &&
                                                                  index <
                                                                      questionario
                                                                          .length) {
                                                                if (questionario[
                                                                        index]
                                                                    .pickedFiles
                                                                    .isEmpty) {
                                                                  questionario[
                                                                          index]
                                                                      .pickedFiles
                                                                      .add(
                                                                          PickedFilesType(
                                                                        type:
                                                                            "obs",
                                                                        file:
                                                                            "obsevarçao",
                                                                        bytes:
                                                                            Uint8List(0),
                                                                        description:
                                                                            _controller.text,
                                                                      ));
                                                                }
                                                              } else {
                                                                print(
                                                                    'Índice fora do intervalo: $index');
                                                              }
                                                              setModalState(
                                                                  () {});

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                'Adicionar'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } catch (e) {
                                                  print('erros $e');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit,
                                                      color: Colors.white),
                                                  Text('Observação',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10)),
                                    Divider(
                                        indent: 20,
                                        endIndent: 20,
                                        height: 1,
                                        color: Colors.grey),
                                  ]);
                                },
                              ),
                            ),
                            ListTile(
                                title: Text("Adicionar Outros"),
                                leading: Icon(Icons.add),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final TextEditingController _controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Text('Adicionar Outros'),
                                        content: TextField(
                                          controller: _controller,
                                          decoration: InputDecoration(
                                            hintText: 'Digite aqui...',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              //se o texto for vazio, não adiciona e mostra uma mensagem modal

                                              if (_controller.text.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text('Erro'),
                                                      content: Text(
                                                          'O campo não pode ser vazio'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              setModalState(() {
                                                questionario
                                                    .add(QuestionarioItem(
                                                  question: _controller.text,
                                                  boxvalue: "2",
                                                  pickedFiles: [],
                                                  id: '99999',
                                                  isoutro: true,
                                                ));
                                              });

                                              Navigator.pop(context);
                                            },
                                            child: Text('Adicionar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                            if (questionario.any((q) => q.boxvalue != "0"))
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_model.operador != null) {
                                      if (_model.equipamento != null) {
                                        if (questionario.any(
                                            (q) => q.boxvalue.contains("0"))) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Erro'),
                                                content: Text(
                                                    'Por favor, preencha o checklist para prosseguir'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          submitChecklist();
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Erro'),
                                              content: Text(
                                                  'Por favor, preencha o campo de Equipamento para prosseguir'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Erro'),
                                            content: Text(
                                                'Por favor, preencha o campo de Operador para prosseguir'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(106, 113, 246, 1.0),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text('Enviar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          child: Container(
                            width: 60,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(114, 112, 112, 1.0),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 13,
                          left: 4,
                          right: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Questionario',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30,
              borderWidth: 1,
              buttonSize: 60,
              icon: Icon(
                Icons.arrow_back_ios,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 30,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: Text(
                          'Checklist',
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .headlineMediumFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 22,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context)
                                        .headlineMediumFamily),
                              ),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsetsDirectional.symmetric(horizontal: 10)),
                    ],
                  ),
                ),
                if (_model.edita == true)
                  Align(
                    alignment: AlignmentDirectional(-1, -1),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                      child: FlutterFlowIconButton(
                        borderColor: FlutterFlowTheme.of(context).primary,
                        borderRadius: 10,
                        borderWidth: 2,
                        buttonSize: 40,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          Icons.edit_off_sharp,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24,
                        ),
                        onPressed: () {
                          print('IconButton pressed ...');
                        },
                      ),
                    ),
                  ),
                if (_model.edita == true)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 10,
                      borderWidth: 2,
                      buttonSize: 40,
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      icon: Icon(
                        Icons.edit,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24,
                      ),
                      onPressed: () {
                        print('IconButton pressed ...');
                      },
                    ),
                  ),
              ],
            ),
            centerTitle: false,
            elevation: 2,
          ),
          body: SafeArea(
            top: true,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: (constraints.maxHeight * 0.88),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 10, 8, 0),
                              child: Form(
                                key: _model.formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 2, 0, 0),
                                          child: Text(
                                            'Data',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 16,
                                                  useGoogleFonts: GoogleFonts
                                                          .asMap()
                                                      .containsKey(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily),
                                                ),
                                          ),
                                        ),
                                        MyDateTimeField(
                                          initialValue:
                                              DateTime.now().toString(),
                                          onDateTimeSelected: (dateTime) {
                                            setState(() {
                                              _model.selectedDate = dateTime;
                                              print(_model.selectedDate);
                                            });
                                          },
                                        ),
                                      ].divide(SizedBox(height: 2)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 2, 0, 0),
                                          child: Text(
                                            'Operador *',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 16,
                                                  useGoogleFonts: GoogleFonts
                                                          .asMap()
                                                      .containsKey(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily),
                                                ),
                                          ),
                                        ),
                                        SuggestionsTextFieldCARD(
                                          formerrovalue:
                                              'Por favor, preencha o campo de Equipamento.',
                                          formKey: childWidgetKey3,
                                          icon: FontAwesomeIcons.person,
                                          persiste: false,
                                          urlarquivoimagem:
                                              'imagem/imagemequipamento/',
                                          estrutura: SuggestionsTextstruc(
                                            id: 'id',
                                            title: 'nome',
                                            imagem_caminho: 'imagem',
                                            subtitle: 'funcao',
                                          ),
                                          onValueChanged:
                                              (Equipamentoreturn d) {
                                            try {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              );
                                              _model.operador = int.parse(d.id);
                                            } catch (e) {
                                              print(e);
                                            } finally {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          lista: operador,
                                        ),
                                      ].divide(SizedBox(height: 2)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 2, 0, 0),
                                          child: Text(
                                            'Equipamento *',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 16,
                                                  useGoogleFonts: GoogleFonts
                                                          .asMap()
                                                      .containsKey(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily),
                                                ),
                                          ),
                                        ),
                                        SuggestionsTextFieldCARD(
                                          formerrovalue:
                                              'Por favor, preencha o campo de Equipamento.',
                                          formKey: childWidgetKey1,
                                          icon: FontAwesomeIcons.tractor,
                                          persiste: false,
                                          urlarquivoimagem:
                                              'imagem/imagemequipamento/',
                                          estrutura: SuggestionsTextstruc(
                                            id: 'id',
                                            title: 'nome',
                                            imagem_caminho: 'imagem_caminho',
                                            subtitle: 'tipo',
                                          ),
                                          onValueChanged:
                                              (Equipamentoreturn d) {
                                            try {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              );
                                              _model.equipamento =
                                                  int.parse(d.id);
                                              _model.equipamentoimagem =
                                                  apidevprod() +
                                                      'imagem/imagemequipamento/' +
                                                      d.imagem_caminho;
                                            } catch (e) {
                                              print(e);
                                            } finally {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          lista: equipamento,
                                        ),
                                      ].divide(SizedBox(height: 2)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 2, 0, 0),
                                              child: Text(
                                                'Checklist *',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          fontSize: 16,
                                                          useGoogleFonts: GoogleFonts
                                                                  .asMap()
                                                              .containsKey(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily),
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 4, 0, 0),
                                          child: FFButtonWidget(
                                            onPressed: () {
                                              _showChecklistModalBottomSheet(
                                                  context: context,
                                                  questionario: _model
                                                      .checklistItems[0]
                                                      .questionario);
                                            },
                                            text: 'Novo Checklist',
                                            icon: Icon(
                                              Icons.document_scanner_outlined,
                                              size: 18,
                                            ),
                                            options: FFButtonOptions(
                                              height: 40,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(24, 0, 24, 0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 0, 0),
                                              color: _model.checklistItems
                                                          .length >
                                                      0
                                                  ? FlutterFlowTheme.of(context)
                                                      .tertiary1
                                                  : FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmallFamily,
                                                        color: Colors.white,
                                                        useGoogleFonts: GoogleFonts
                                                                .asMap()
                                                            .containsKey(
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily),
                                                      ),
                                              elevation: 3,
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(),
                                        ),
                                      ].divide(SizedBox(height: 2)),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 60)),
                                  ].divide(SizedBox(height: 5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class MyDateTimeField extends StatefulWidget {
  final void Function(String dateTime) onDateTimeSelected;
  final String? initialValue;

  const MyDateTimeField(
      {Key? key, required this.onDateTimeSelected, this.initialValue})
      : super(key: key);

  @override
  _MyDateTimeFieldState createState() => _MyDateTimeFieldState();
}

class _MyDateTimeFieldState extends State<MyDateTimeField> {
  late DateTime selectedDate;
  late bool hasInitialValue;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null &&
        isValidDateTimeFormat(widget.initialValue!)) {
      selectedDate = DateTime.parse(widget.initialValue!);
      hasInitialValue = true;
    } else {
      selectedDate = DateTime.now();
      hasInitialValue = false;
    }

    // Mover a chamada _sendDateTime() para o final do initState()
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _sendDateTime();
    });
  }

  bool isValidDateTimeFormat(String dateTimeString) {
    try {
      DateTime.parse(dateTimeString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _sendDateTime();
    }
  }

  void _sendDateTime() {
    final formattedDate = '${selectedDate.toIso8601String().substring(0, 10)}';
    widget.onDateTimeSelected(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondaryText,
              width: 1.3,
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: 270,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 12, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.calendar_today,
                    size: 24), // Adiciona o ícone de calendário
                SizedBox(
                    width: 1), // Adiciona um espaço entre o ícone e o texto
                Expanded(
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
