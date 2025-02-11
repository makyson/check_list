import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/api.dart';
import 'package:untitled/backend/api_requests/api_calls.dart';
import 'package:uuid/uuid.dart'; // para gerar IDs únicos

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/form_field_controller.dart';
import 'abrirsevicomodel.dart';
import 'customCheckbox.dart';
import 'custom_video_controls.dart';
import 'dropdonw.dart';
import 'model.dart';

export 'abrirsevicomodel.dart';

class DetalyCopy3Widget extends StatefulWidget {
  final LancamentoChecklist? initialLancamento;

  const DetalyCopy3Widget({super.key, this.initialLancamento});

  @override
  State<DetalyCopy3Widget> createState() => _DetalyCopy3WidgetState();
}

class _DetalyCopy3WidgetState extends State<DetalyCopy3Widget> {
  late DetalyCopy3Model _model;
  final ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ChecklistStorage checklistStorage = ChecklistStorage();

  final childWidgetKey1 = GlobalKey<FormState>();
  final childWidgetKey2 = GlobalKey<FormState>();
  final childWidgetKey3 = GlobalKey<FormState>();
  final childWidgetKey4 = GlobalKey<FormState>();

  List<bool> isSelected = [false, false];
  String controlId = '';

  @override
  void initState() {
    super.initState();

    buscar();
    _loadInitialLancamento();

    _model = createModel(context, () => DetalyCopy3Model());
    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();
    _model.textController7 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();
    controlId = Uuid().v4();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _loadInitialLancamento() {
    if (widget.initialLancamento != null) {
      setState(() {
        _model.checklistItems = widget.initialLancamento!.checklistItems ?? [];
        _model.equipamento = widget.initialLancamento!.equipamento;
        _model.dropDownValueController1 =
            FormFieldController(widget.initialLancamento!.tipoinput);

        if (widget.initialLancamento!.tipoinput != null) {}

        _model.isRunning = widget.initialLancamento!.urgente ?? false;
        _model.selectedDate = widget.initialLancamento!.datavalue ?? null;
      });
    }
  }

  List<Map<String, dynamic>> _pickedFiles = [];
  List<Map<String, dynamic>> equipamento = [];

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

  Future<void> submitChecklist() async {
    ApiCallResponse response = await Post_checklistCall.call(
      name: AppStateNotifier.instance.user!.userData!.name,
      checklistItem: _model.checklistItems,
      equipamento: _model.equipamento,
      tipoinput: _model.tipoinput,
      urgente: _model.isRunning,
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

  Future<void> _saveDraft() async {
    LancamentoChecklist lancamento = LancamentoChecklist(
      checklistItems:
          _model.checklistItems.isNotEmpty ? _model.checklistItems : null,
      equipamento: _model.equipamento,
      tipoinput: _model.tipoinput,
      urgente: _model.isRunning,
      datavalue: _model.selectedDate,
    );

    List<LancamentoChecklist> lancamentos =
        await checklistStorage.loadLancamentos();
    lancamentos.add(lancamento);
    await checklistStorage.saveLancamentos(lancamentos);
  }

  Future<void> _confirmExit() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Salvar Alterações?'),
          content: Text('Você deseja salvar as alterações antes de sair?'),
          actions: <Widget>[
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Saia sem salvar
              },
            ),
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                _saveDraft();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Salve e saia
              },
            ),
          ],
        );
      },
    );
  }

  bool _allNokItemsHaveFiles(List<ChecklistItem> checklistItems) {
    for (var checklistItem in checklistItems) {
      for (var item in checklistItem.questionario) {
        // Supondo que questionario seja uma lista de QuestionarioItem
        if (item.boxvalue == "2" && item.pickedFiles.isEmpty) {
          return false;
        }
      }
    }
    return true;
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
        //  await _confirmExit();
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
                // await _confirmExit();
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
                                                'Setor *',
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
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child:
                                                  FlutterFlowDropDown<String>(
                                                controller: _model
                                                        .dropDownValueController1 ??=
                                                    FormFieldController<String>(
                                                        null),
                                                validator: (value) {
                                                  print(value);
                                                  if (value == null) {
                                                    return 'Este campo é obrigatório.';
                                                  }
                                                  return null;
                                                },
                                                options: const [
                                                  'Produção',
                                                  'Manutenção',
                                                  'Administrativo'
                                                ],
                                                onChanged: (val) =>
                                                    setState(() => setState(() {
                                                          _model.tipoinput =
                                                              val;
                                                        })),
                                                width: double.infinity,
                                                height: 56.0,
                                                searchHintTextStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMediumFamily,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts: GoogleFonts
                                                                  .asMap()
                                                              .containsKey(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMediumFamily),
                                                        ),
                                                searchTextStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts: GoogleFonts
                                                                  .asMap()
                                                              .containsKey(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily),
                                                        ),
                                                textStyle: _model.tipoinput ==
                                                        null
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts: GoogleFonts
                                                                  .asMap()
                                                              .containsKey(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily),
                                                        )
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts: GoogleFonts
                                                                  .asMap()
                                                              .containsKey(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily),
                                                        ),
                                                hintText:
                                                    'Clique aqui para selecionar ...',
                                                searchHintText:
                                                    'Pesquise aqui ...',
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 24.0,
                                                ),
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                elevation: 1.0,
                                                borderColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                borderWidth: 1.3,
                                                borderRadius: 8.0,
                                                margin:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        16.0, 4.0, 16.0, 4.0),
                                                hidesUnderline: true,
                                                isOverButton: true,
                                                isSearchable: true,
                                                isMultiSelect: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(),
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
                                                'Urgente',
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
                                        Transform.scale(
                                          scale: 1.2,
                                          child: Switch(
                                            thumbIcon: MaterialStateProperty
                                                .resolveWith<Icon?>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return const Icon(Icons.check,
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1.0));
                                                }
                                                return const Icon(Icons.close);
                                              },
                                            ),
                                            thumbColor: MaterialStateProperty
                                                .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return Color(0xFFFA4B55);
                                                }
                                                return Colors.grey;
                                              },
                                            ),
                                            trackColor: MaterialStateProperty
                                                .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.selected)) {
                                                  return FlutterFlowTheme.of(
                                                          context)
                                                      .error;
                                                }
                                                return null;
                                              },
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.values[1],
                                            value: _model.isRunning,
                                            onChanged: (value) {
                                              setState(() {
                                                _model.isRunning = value;
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(),
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
                                              if (_model.equipamento == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.only(
                                                      top: MediaQuery.of(
                                                              context)
                                                          .padding
                                                          .top, // Adjust for safe area
                                                      left: 16,
                                                      right: 16),
                                                  content:
                                                      AwesomeSnackbarContent(
                                                    inMaterialBanner: false,
                                                    title:
                                                        'Campo Equipamento é obrigatório',
                                                    message:
                                                        'Por favor, preencha o campo de Equipamento para prosseguir',
                                                    contentType:
                                                        ContentType.warning,
                                                  ),
                                                ));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .clearSnackBars();
                                                _model.checklist = true;
                                                if (_model
                                                        .equipamentoselcetanterior !=
                                                    _model.equipamento) {
                                                  _model.equipamentoselcetanterior =
                                                      _model.equipamento;
                                                  _model.checklistItems = [];
                                                }
                                                safeSetState(() {});
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChecklistScreen(
                                                      checklistItems:
                                                          _model.checklistItems,
                                                      id_equipment: _model
                                                          .equipamento
                                                          .toString(),
                                                      imagem: _model
                                                          .equipamentoimagem,
                                                    ),
                                                  ),
                                                );
                                              }
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
                    Container(
                      width: double.infinity,
                      height: (constraints.maxHeight * 0.1),
                      child: Align(
                        alignment: AlignmentDirectional(0, -1),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 5, 8, 0),
                          child: FFButtonWidget(
                            onPressed: () {
                              _model.formKey.currentState?.validate();
                              if (_model.checklistItems.length > 0) {
                                if (!_allNokItemsHaveFiles(
                                    _model.checklistItems)) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  final snackBar = SnackBar(
                                    backgroundColor: Colors.transparent,
                                    margin: EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    elevation: 0,
                                    behavior: SnackBarBehavior.floating,
                                    content: AwesomeSnackbarContent(
                                      inMaterialBanner: false,
                                      title: 'Atenção',
                                      message:
                                          'Nem todos os itens marcados como "NOK" têm arquivos anexados.',
                                      contentType: ContentType.failure,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  submitChecklist();
                                }
                              } else {
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  content: AwesomeSnackbarContent(
                                    inMaterialBanner: false,
                                    title: 'Checklist Vazio',
                                    message:
                                        'Por favor, preencha o checklist para prosseguir',
                                    contentType: ContentType.warning,
                                  ),
                                );
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            text: 'Enviar',
                            icon: Icon(
                              Icons.upload_file,
                              size: 24,
                            ),
                            options: FFButtonOptions(
                              height: 40,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: FlutterFlowTheme.of(context).success,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: Colors.white,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .titleSmallFamily),
                                  ),
                              elevation: 3,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

class ChecklistStorage {
  static const String _keyChecklists = 'checklists';

  Future<void> saveLancamentos(List<LancamentoChecklist> lancamentos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> lancamentoList = lancamentos
          .map((lancamento) => jsonEncode(lancamento.toJson()))
          .toList();
      await prefs.setStringList(_keyChecklists, lancamentoList);
    } catch (e) {
      print('Erro ao salvar rascunho: $e');
    }
  }

  Future<List<LancamentoChecklist>> loadLancamentos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? lancamentoList = prefs.getStringList(_keyChecklists);
    if (lancamentoList != null) {
      return lancamentoList
          .map((lancamento) =>
              LancamentoChecklist.fromJson(jsonDecode(lancamento)))
          .toList();
    } else {
      return [];
    }
  }
}

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({Key? key}) : super(key: key);

  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  final ChecklistStorage checklistStorage = ChecklistStorage();
  List<LancamentoChecklist> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    try {
      List<LancamentoChecklist> loadedDrafts =
          await checklistStorage.loadLancamentos();
      setState(() {
        drafts = loadedDrafts;
      });
    } catch (e) {
      print('Erro ao carregar rascunhos: $e');
    }
  }

  Future<void> _deleteDraft(int index) async {
    try {
      setState(() {
        drafts.removeAt(index);
      });
      await checklistStorage.saveLancamentos(drafts);
    } catch (e) {
      print('Erro ao deletar rascunho: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rascunhos Salvos'),
      ),
      body: drafts.isEmpty
          ? Center(child: Text('Nenhum rascunho salvo'))
          : ListView.builder(
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Equipamento: ${drafts[index].equipamento}'),
                  subtitle: Text('Data: ${drafts[index].datavalue}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteDraft(index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DraftDetailWidget(
                          initialLancamento: drafts[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class SuggestionsTextFieldCARD extends StatefulWidget {
  final List<Map<String, dynamic>> lista;
  final String? valorInicial;
  final Function(Equipamentoreturn) onValueChanged;
  final SuggestionsTextstruc estrutura;
  final Function()? runValida;
  final EdgeInsetsGeometry? padding;
  final bool? persiste;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final String? formerrovalue;
  final String? urlarquivoimagem;

  const SuggestionsTextFieldCARD({
    Key? key,
    required this.lista,
    this.valorInicial,
    required this.onValueChanged,
    this.padding,
    this.persiste = false,
    required this.icon,
    required this.estrutura,
    this.runValida,
    required this.formKey,
    this.formerrovalue,
    this.urlarquivoimagem,
  }) : super(key: key);

  @override
  _SuggestionsTextFieldStateCARD createState() =>
      _SuggestionsTextFieldStateCARD();
}

class Equipamentoreturn {
  String id;
  String nome;
  String funcao;
  String imagem_caminho;

  Equipamentoreturn({
    required this.id,
    required this.nome,
    required this.funcao,
    required this.imagem_caminho,
  });
}

class SuggestionsTextstruc {
  String? id;
  String? title;
  String? subtitle;
  String? imagem_caminho;

  SuggestionsTextstruc({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagem_caminho,
  });
}

class _SuggestionsTextFieldStateCARD extends State<SuggestionsTextFieldCARD> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _showSuggestions = true;
  bool _showSuggestionslist = false;
  List<Map<String, dynamic>> _sugestoesFiltradas = [];
  Timer? _debounceTimer;
  late Equipamentoreturn? _selectedItem;
  bool? pessiste;
  bool? bortao;

  @override
  void initState() {
    super.initState();
    pessiste = widget.persiste;
    _textFieldFocusNode.addListener(_handleFocusChange);
    if (widget.valorInicial != null) {
      _controller.text = widget.valorInicial!;
      _showSuggestions = false;
    }
    _sugestoesFiltradas = widget.lista;
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_handleFocusChange);
    _debounceTimer?.cancel();
    _controller.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_textFieldFocusNode.hasFocus) {
      _cancelDebounceTimer();
    } else {
      _startDebounceTimer();
    }
  }

  void _startDebounceTimer() {
    _debounceTimer = Timer(Duration(seconds: 1), () {
      if (!_textFieldFocusNode.hasFocus) {
        setState(() {
          if (_controller.text.isNotEmpty) {
            if (pessiste == true) {
              _selectedItem = Equipamentoreturn(
                id: '',
                nome: _controller.text,
                funcao: bortao == true ? '' : 'novo',
                imagem_caminho: '',
              );

              widget.onValueChanged(_selectedItem!);

              _showSuggestionslist = false;
              _showSuggestions = false;
              bortao = false;
            } else if (_selectedItem != null) {
              _showSuggestionslist = false;
              _showSuggestions = false;
            } else {
              _controller.clear();
            }
          } else {
            _showSuggestionslist = false;
          }
        });
      }
    });
  }

  void _cancelDebounceTimer() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
  }

  String removeDiacritics(String input) {
    final diacriticsRegex = RegExp(r'[^\u0000-\u007F]');
    return input.replaceAll(diacriticsRegex, '');
  }

  void _filterList(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      setState(() {
        final filteredQuery = removeDiacritics(query.toLowerCase());
        _sugestoesFiltradas = widget.lista.where((item) {
          final nome = removeDiacritics(item['nome'].toString().toLowerCase());
          final funcao =
              removeDiacritics(item['funcao']?.toString().toLowerCase() ?? '');
          return nome.contains(filteredQuery) || funcao.contains(filteredQuery);
        }).toList();
      });
    });
  }

  void exibirSobreposicao(
      BuildContext context, Equipamentoreturn _selectedItem, selicon) {
    IconData icon = selicon;

    showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _selectedItem.imagem_caminho != null &&
                        _selectedItem.imagem_caminho != ''
                    ? Image.network(
                        apidevprod() +
                            widget.urlarquivoimagem.toString() +
                            _selectedItem.imagem_caminho,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.width * 0.7 / 2,
                          );
                        },
                      )
                    : Icon(
                        icon,
                        color: Colors.grey,
                        size: MediaQuery.of(context).size.width * 0.7 / 2,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_showSuggestions && _selectedItem != null)
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                border: Border.all(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 2, 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).accent1,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              exibirSobreposicao(
                                  context, _selectedItem!, widget.icon);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _selectedItem?.imagem_caminho != null &&
                                        _selectedItem?.imagem_caminho != ''
                                    ? Image.network(
                                        apidevprod() +
                                            widget.urlarquivoimagem.toString() +
                                            _selectedItem!.imagem_caminho,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            widget.icon,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 24,
                                          );
                                        },
                                      )
                                    : Icon(
                                        widget.icon,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 8, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedItem!.nome,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        useGoogleFonts: GoogleFonts.asMap()
                                            .containsKey(
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily),
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 0, 0),
                                  child: Text(
                                    _selectedItem!.funcao,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                          child: GestureDetector(
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            onTap: () {
                              setState(() {
                                _showSuggestions = true;
                                _showSuggestionslist = true;
                                _textFieldFocusNode.requestFocus();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _showSuggestions = true;
                    _showSuggestionslist = true;
                    _textFieldFocusNode.requestFocus();
                  });
                },
              ),
            ),
          if (_showSuggestions)
            Form(
              key: widget.formKey,
              child: TextFormField(
                controller: _controller,
                focusNode: _textFieldFocusNode,
                autofocus: false,
                obscureText: false,
                onChanged: (value) {
                  _filterList(value);
                },
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.text.isNotEmpty) {
                          _showSuggestionslist = !_showSuggestionslist;
                          if (pessiste == false && _selectedItem == null) {
                            _controller.clear();
                          }
                        } else {
                          _showSuggestionslist = !_showSuggestionslist;
                        }
                      });
                    },
                    child: Icon(
                      _showSuggestionslist
                          ? Icons.close
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                  labelText: 'Digite aqui...',
                  labelStyle: FlutterFlowTheme.of(context).labelMedium,
                  hintStyle: FlutterFlowTheme.of(context).labelMedium,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).error,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).error,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.formerrovalue ?? '';
                  }
                  return null;
                },
                onTap: () {
                  setState(() {
                    _showSuggestions = true;
                    _showSuggestionslist = true;
                    if (_controller.text.isNotEmpty) {
                      _sugestoesFiltradas = widget.lista
                          .where((item) => item['nome']
                              .toLowerCase()
                              .startsWith(_controller.text.toLowerCase()))
                          .toList();
                    } else {
                      _sugestoesFiltradas = widget.lista;
                    }
                  });
                },
              ),
            ),
          const SizedBox(height: 10),
          if (_showSuggestions &&
              _sugestoesFiltradas.isNotEmpty &&
              _showSuggestionslist)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sugestoesFiltradas.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: const Color(0x33000000),
                            offset: const Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent1,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _sugestoesFiltradas[index][widget
                                                  .estrutura.imagem_caminho] !=
                                              null &&
                                          _sugestoesFiltradas[index][widget
                                                  .estrutura.imagem_caminho] !=
                                              ''
                                      ? Image.network(
                                          apidevprod() +
                                              widget.urlarquivoimagem
                                                  .toString() +
                                              _sugestoesFiltradas[index][widget
                                                  .estrutura.imagem_caminho],
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              widget.icon,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 24,
                                            );
                                          },
                                        )
                                      : Icon(
                                          widget.icon,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24,
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 8, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _sugestoesFiltradas[index]
                                              [widget.estrutura.title] ??
                                          '',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontWeight: FontWeight.bold,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey(
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily),
                                          ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 4, 0, 0),
                                      child: Text(
                                        _sugestoesFiltradas[index]
                                                [widget.estrutura.subtitle] ??
                                            '',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              useGoogleFonts:
                                                  GoogleFonts.asMap()
                                                      .containsKey(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmallFamily),
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
                    onTap: () {
                      try {
                        _selectedItem = Equipamentoreturn(
                          id: _sugestoesFiltradas[index][widget.estrutura.id]
                                  .toString() ??
                              '',
                          nome: _sugestoesFiltradas[index]
                                      [widget.estrutura.title]
                                  .toString() ??
                              '',
                          funcao: _sugestoesFiltradas[index]
                                      [widget.estrutura.subtitle]
                                  .toString() ??
                              '',
                          imagem_caminho: _sugestoesFiltradas[index]
                                      [widget.estrutura.imagem_caminho]
                                  .toString() ??
                              '',
                        );

                        widget.onValueChanged(_selectedItem!);

                        bortao = true;

                        setState(() {});
                        _showSuggestions = false;
                      } catch (e) {
                        print(e);
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class ChecklistScreen extends StatefulWidget {
  final List<ChecklistItem> checklistItems;
  final String id_equipment;
  final String imagem;
  ChecklistScreen(
      {required this.checklistItems,
      required this.id_equipment,
      required this.imagem});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  int currentStep = 0;
  List<ChecklistItem> checklistItems = [];

  bool allNokItemsHaveFiles = true;

  bool visible = false;

  ApiCallResponse? response;

  @override
  void initState() {
    super.initState();

    // Adiciona um listener para detectar mudanças no tamanho do sheet

    buscar();
  }

  Future<void> buscar() async {
    try {
      if (widget.checklistItems.isEmpty) {
        response = await Buscar_checklistCall.call(id: widget.id_equipment);
        final items =
            Buscar_checklistCall.getChecklistItems(response?.jsonBody);

        if (items != null) {
          setState(() {
            widget.checklistItems.addAll(items
                .map((e) => ChecklistItem(
                      nome: e['nome'],
                      imagem: e['imagem'],
                      questionario: (e['QUESTIONARIO'] as List)
                          .map((q) => QuestionarioItem(
                                id: q['id'],
                                question: q['pergunta'],
                                boxvalue: "0",
                                pickedFiles: [],
                                isoutro: false,
                              ))
                          .toList(),
                    ))
                .toList());
            // widget.checklistItems.addAll(checklistItems);
            visible = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, // Adjust for safe area
                left: 16,
                right: 16),
            content: AwesomeSnackbarContent(
              inMaterialBanner: false,
              title: 'Campo Equipamento é obrigatório',
              message:
                  'Por favor, preencha o campo de Equipamento para prosseguir',
              contentType: ContentType.warning,
            ),
          ));
          Navigator.pop(context);
        }
      } else {
        setState(() {
          visible = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, // Adjust for safe area
            left: 16,
            right: 16),
        content: AwesomeSnackbarContent(
          inMaterialBanner: false,
          title: 'Campo Equipamento é obrigatório',
          message: 'Por favor, preencha o campo de Equipamento para prosseguir',
          contentType: ContentType.warning,
        ),
      ));
      Navigator.pop(context);
      print('Erro ao buscar: $e');
    }
  }

  void _showChecklistModalBottomSheet(BuildContext context,
      {required List<QuestionarioItem> questionario}) {
    double initButon = questionario.length > 5
        ? 0.75
        : questionario.length > 4
            ? 0.65
            : questionario.length > 2
                ? 0.54
                : 0.35;

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
                              controller: scrollController,
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
                                                  style:
                                                      TextStyle(fontSize: 16)),
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
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              CustomCheckbox(
                                                value: questionario[index]
                                                        .boxvalue ==
                                                    "2",
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    questionario[index]
                                                            .boxvalue =
                                                        value! ? "2" : "0";

                                                    // Verificação de anexo
                                                    if (questionario[index]
                                                                .boxvalue ==
                                                            "2" &&
                                                        questionario[index]
                                                            .pickedFiles
                                                            .isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Por favor, anexe um arquivo para itens marcados como "NOK".',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
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
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
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
                                                                      color: Theme.of(
                                                                              context)
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
                                                          setModalState(() {});
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
                                  if (questionario[index].pickedFiles.isEmpty &&
                                      questionario[index].boxvalue == "2")
                                    Column(
                                      children: [
                                        Text(
                                          'Por favor, anexe um arquivo!',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
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
                                                        files:
                                                            questionario[index]
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.attach_file,
                                                        color: Colors.white),
                                                    Text('Anexar',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  Padding(padding: EdgeInsets.only(bottom: 10)),
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
                            title: Text("Adicionar Outros itens"),
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
                                                        Navigator.pop(context);
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
                                            questionario.add(QuestionarioItem(
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
                            },
                          ),
                          if (questionario.any((q) => q.boxvalue != "0"))
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton(
                                onPressed: () {
                                  bool allNokItemsHaveFiles = true;
                                  int indexToScroll = -1;

                                  for (int i = 0;
                                      i < questionario.length;
                                      i++) {
                                    if (questionario[i].boxvalue == "2" &&
                                        questionario[i].pickedFiles.isEmpty) {
                                      allNokItemsHaveFiles = false;
                                      indexToScroll = i;
                                      break;
                                    }
                                  }

                                  if (!allNokItemsHaveFiles) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Erro'),
                                          content: Text(
                                              'Todos os itens marcados como "NOK" devem ter pelo menos um arquivo anexado.'),
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

                                    if (indexToScroll != -1) {
                                      scrollController.animateTo(
                                        indexToScroll * 100.0,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      if (currentStep <
                                          widget.checklistItems!.length - 1) {
                                        currentStep++;
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    });
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
    ).whenComplete(() {
      allNokItemsHaveFiles = _allNokItemsHaveFiles(questionario);
      setState(() {});
    });
  }

  responder(bool resposta, int index) {
    print('Resposta: $resposta');
  }

  bool _allNokItemsHaveFiles(List<QuestionarioItem> questionario) {
    for (var item in questionario) {
      if (item.boxvalue == "2" && item.pickedFiles.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return visible == false
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text('Novo Checklist'),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: LinearProgressIndicator(
                        value:
                            (currentStep + 1) / widget.checklistItems!.length,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.checklistItems![currentStep].nome,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Image.network(
                      widget.imagem,
                      width: 500,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 40),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // ... (seus widgets ElevatedButton)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (currentStep > 0) {
                            if (!allNokItemsHaveFiles) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              final snackBar = SnackBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                content: AwesomeSnackbarContent(
                                  inMaterialBanner: false,
                                  title: 'Você não pode voltar',
                                  message:
                                      'Por favor, anexe os arquivos necessários.',
                                  contentType: ContentType.failure,
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            } else {
                              currentStep--;
                            }
                            allNokItemsHaveFiles = _allNokItemsHaveFiles(widget
                                .checklistItems![currentStep].questionario);
                          }
                        });
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: currentStep > 0
                            ? allNokItemsHaveFiles
                                ? null
                                : Colors.grey
                            : null,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentStep > 0
                            ? allNokItemsHaveFiles
                                ? null
                                : Colors.grey.shade400
                            : null,
                      ),
                    ),
                    Text(
                      '${currentStep + 1} de ${widget.checklistItems!.length}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (currentStep < widget.checklistItems!.length - 1) {
                            if (!allNokItemsHaveFiles) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              final snackBar = SnackBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                content: AwesomeSnackbarContent(
                                  inMaterialBanner: false,
                                  title: 'Você não pode prosseguir',
                                  message:
                                      'Por favor, anexe os arquivos necessários.',
                                  contentType: ContentType.failure,
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            } else {
                              currentStep++;
                            }
                            allNokItemsHaveFiles = _allNokItemsHaveFiles(widget
                                .checklistItems![currentStep].questionario);
                          }
                        });
                      },
                      child: Icon(
                        Icons.arrow_forward,
                        color: allNokItemsHaveFiles ? null : Colors.grey,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            allNokItemsHaveFiles ? null : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showChecklistModalBottomSheet(context,
                              questionario: widget.checklistItems?[currentStep]
                                      .questionario ??
                                  []);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor:
                              Colors.white, // Set text color explicitly
                          minimumSize:
                              Size(150, 40), // Ajuste o tamanho mínimo do botão
                          elevation:
                              3.0, // Add a subtle shadow (adjust value as needed)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Make corners more rounded
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0), // Adjust padding for balance
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Icon(Icons.close, size: 30.0),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (currentStep <
                                widget.checklistItems!.length - 1) {
                              if (!allNokItemsHaveFiles) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  content: AwesomeSnackbarContent(
                                    inMaterialBanner: false,
                                    title: 'Você não pode prosseguir',
                                    message:
                                        'Por favor, anexe os arquivos necessários.',
                                    contentType: ContentType.failure,
                                  ),
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                return;
                              } else {
                                currentStep++;
                              }
                              allNokItemsHaveFiles = _allNokItemsHaveFiles(
                                  widget.checklistItems![currentStep]
                                      .questionario);
                            } else {
                              //volta pra tela anterior

                              Navigator.pop(context);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              allNokItemsHaveFiles ? Colors.green : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(150, 40),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.check, size: 38, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class FileViewer extends StatefulWidget {
  final List<PickedFilesType> files;
  final int initialIndex;

  FileViewer({required this.files, required this.initialIndex});

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late PageController _pageController;
  late int _currentIndex;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        List<PlatformFile> files = result.files;
        for (var file in files) {
          final mimeType = mime(file.name) ?? 'application/octet-stream';
          final mimeTypeParts = mimeType.split('/');
          if (file.bytes != null) {
            setState(() {
              widget.files.add(PickedFilesType(
                type: mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'unknown',
                file: mimeTypeParts.length > 1 ? mimeTypeParts[0] : 'unknown',
                bytes: file.bytes!,
              ));
            });
          }
        }
      }
    } catch (e) {
      print('Error ao selecionar imagem: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _removeFile(int index) {
    setState(() {
      widget.files.removeAt(index);
      if (_currentIndex >= widget.files.length) {
        _currentIndex = widget.files.length - 1;
      }

      if (_currentIndex < 0) {
        _currentIndex = 0;
      }

      _pageController = PageController(initialPage: _currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context, widget.files),
        ),
        actions: [
          if (!kIsWeb) IconButton(icon: Icon(Icons.crop), onPressed: () {}),
          if (!kIsWeb)
            IconButton(icon: Icon(Icons.text_fields), onPressed: () {}),
          if (!kIsWeb) IconButton(icon: Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          if (widget.files.isNotEmpty)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.files.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final file = widget.files[index];
                  if (file.file == 'image') {
                    return Image.memory(file.bytes);
                  } else if (file.file == 'video') {
                    return YoutubeStyleVideoControls(file: file);
                  } else {
                    return Center(child: Icon(Icons.insert_drive_file));
                  }
                },
              ),
            ),
          if (widget.files.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: Align(
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    final double itemWidth =
                        70.0 + 8.0; // Largura da imagem + padding horizontal
                    final double totalItemsWidth =
                        widget.files.length * itemWidth;
                    final double padding =
                        10.0; // Espaçamento entre as miniaturas
                    final double maxWidth =
                        totalItemsWidth + (widget.files.length - 1) * padding;

                    return Container(
                      width:
                          maxWidth > availableWidth ? availableWidth : maxWidth,
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.files.length,
                        itemBuilder: (context, index) {
                          final image = widget.files[index];
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.linear,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: image.file == 'image'
                                          ? Image.memory(
                                              image.bytes,
                                              width: 70,
                                              height: 80,
                                              fit: BoxFit.fill,
                                            )
                                          : image.file == 'video'
                                              ? Icon(Icons.video_library)
                                              : Icon(Icons.insert_drive_file),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _currentIndex == index,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3),
                                        width: 70,
                                        height: 80,
                                        child: GestureDetector(
                                          child: Icon(
                                            Icons.delete_forever_outlined,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          onTap: () {
                                            _removeFile(index);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          if (widget.files.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 15, left: 8),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(15), // Borda arredondada
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.image,
                            color: Colors.white), // Ícone de confirmação
                        onPressed: () {
                          _pickFiles();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(25), // Borda arredondada
                      ),
                      child: Row(
                        children: [
                          // Ícone de imagem
                          SizedBox(
                              width: 8), // Espaçamento entre o ícone e o texto
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: widget.files.isNotEmpty &&
                                          _currentIndex < widget.files.length
                                      ? widget.files[_currentIndex]
                                              .description ??
                                          ''
                                      : ''),
                              onChanged: (value) {
                                if (widget.files.isNotEmpty &&
                                    _currentIndex < widget.files.length) {
                                  widget.files[_currentIndex] = PickedFilesType(
                                    type: widget.files[_currentIndex].type,
                                    file: widget.files[_currentIndex].file,
                                    bytes: widget.files[_currentIndex].bytes,
                                    description: value,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Adicione uma legenda...',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(15), // Borda arredondada
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.check,
                            color: Colors.white), // Ícone de confirmação
                        onPressed: () {
                          Navigator.pop(context, widget.files);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.files.isEmpty)
            Expanded(
                child: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 100, color: Colors.grey),
                Text('Nenhum arquivo anexado',
                    style: TextStyle(fontSize: 20, color: Colors.grey)),
                ElevatedButton(
                  onPressed: () {
                    _pickFiles();
                  },
                  child: Text('Anexar arquivo'),
                ),
              ],
            ))),
          if (widget.files.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 15, left: 8),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(15), // Borda arredondada
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.image,
                            color: Colors.white), // Ícone de confirmação
                        onPressed: () {
                          _pickFiles();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(25), // Borda arredondada
                      ),
                      child: Row(
                        children: [
                          // Ícone de imagem
                          SizedBox(
                              width: 8), // Espaçamento entre o ícone e o texto
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue, // Cor de fundo preta
                        borderRadius:
                            BorderRadius.circular(15), // Borda arredondada
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.check,
                            color: Colors.white), // Ícone de confirmação
                        onPressed: () {
                          Navigator.pop(context, widget.files);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

class DraftDetailWidget extends StatefulWidget {
  final LancamentoChecklist? initialLancamento;

  const DraftDetailWidget({super.key, this.initialLancamento});

  @override
  State<DraftDetailWidget> createState() => _DraftDetailWidgetState();
}

class _DraftDetailWidgetState extends State<DraftDetailWidget> {
  late DetalyCopy3Model _model;
  final ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ChecklistStorage checklistStorage = ChecklistStorage();
  bool carregando = true;
  final childWidgetKey1 = GlobalKey<FormState>();
  final childWidgetKey2 = GlobalKey<FormState>();
  final childWidgetKey3 = GlobalKey<FormState>();
  final childWidgetKey4 = GlobalKey<FormState>();

  List<bool> isSelected = [false, false];
  String controlId = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetalyCopy3Model());
    fetchInformacoes();
    buscar();
    _loadInitialLancamento();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();
    _model.textController7 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();
    controlId = Uuid().v4();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _loadInitialLancamento() {
    if (widget.initialLancamento != null) {
      setState(() {
        _model.checklistItems = widget.initialLancamento!.checklistItems ?? [];
        _model.equipamento = widget.initialLancamento!.equipamento;
        if (widget.initialLancamento!.tipoinput != null) {
          _model.dropDownValueController1 =
              FormFieldController(widget.initialLancamento!.tipoinput);
        }

        _model.isRunning = widget.initialLancamento!.urgente ?? false;
        _model.selectedDate = widget.initialLancamento!.datavalue ?? null;
        carregando = true;
      });
    }
  }

  List<Map<String, dynamic>> _pickedFiles = [];
  List<Map<String, dynamic>> equipamento = [];

  Future<void> buscar() async {
    try {
      final response = await http.get(Uri.parse(apidevprod() + 'informacoes'));

      if (response.statusCode == 200) {
        final informacoes = json.decode(response.body);
        setState(() {
          equipamento =
              List<Map<String, dynamic>>.from(informacoes['equipamento']);
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

  Future<void> fetchInformacoes() async {
    try {
      final response = await http.get(Uri.parse(apidevprod() + 'informacoes'));

      if (response.statusCode == 200) {
        final informacoes = json.decode(response.body);
        setState(() {
          equipamento =
              List<Map<String, dynamic>>.from(informacoes['equipamento']);
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

  Future<void> submitChecklist() async {
    ApiCallResponse response = await Post_checklistCall.call(
      name: "outros",
      checklistItem: _model.checklistItems,
      equipamento: _model.equipamento,
      tipoinput: _model.tipoinput,
      urgente: _model.isRunning,
      datavalue: _model.selectedDate,
    );

    if (response.statusCode == 200) {
      print('Checklist enviado com sucesso. ID: $controlId');
      context.safePop();
    } else {
      print('Erro ao enviar checklist');
    }
  }

  Future<void> _saveDraft() async {
    LancamentoChecklist lancamento = LancamentoChecklist(
      checklistItems:
          _model.checklistItems.isNotEmpty ? _model.checklistItems : null,
      equipamento: _model.equipamento,
      tipoinput: _model.tipoinput,
      urgente: _model.isRunning,
      datavalue: _model.selectedDate,
    );

    List<LancamentoChecklist> lancamentos =
        await checklistStorage.loadLancamentos();
    lancamentos.add(lancamento);
    await checklistStorage.saveLancamentos(lancamentos);
  }

  Future<void> _confirmExit() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Salvar Alterações?'),
          content: Text('Você deseja salvar as alterações antes de sair?'),
          actions: <Widget>[
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Saia sem salvar
              },
            ),
            TextButton(
              child: Text('Sim'),
              onPressed: () {
                _saveDraft();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Salve e saia
              },
            ),
          ],
        );
      },
    );
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
        //  await _confirmExit();
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
                //  await _confirmExit();
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
                          'Rascunho de Checklist',
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
          body: carregando == false
              ? CircularProgressIndicator()
              : SafeArea(
                  top: true,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8, left: 2, right: 2),
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
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8, 10, 8, 0),
                                    child: Form(
                                      key: _model.formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 2, 0, 0),
                                                child: Text(
                                                  'Data',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
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
                                                initialValue: _model
                                                    .selectedDate
                                                    ?.toString(),
                                                onDateTimeSelected: (dateTime) {
                                                  setState(() {
                                                    _model.selectedDate =
                                                        dateTime;
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 2, 0, 0),
                                                child: Text(
                                                  'Equipamento *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
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
                                                  imagem_caminho:
                                                      'imagem_caminho',
                                                  subtitle: 'tipo',
                                                ),
                                                onValueChanged:
                                                    (Equipamentoreturn d) {
                                                  try {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
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
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 2, 0, 0),
                                                    child: Text(
                                                      'Setor *',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                fontSize: 16,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: FlutterFlowDropDown<
                                                        String>(
                                                      controller: _model
                                                              .dropDownValueController1 ??=
                                                          FormFieldController<
                                                              String>(null),
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return 'Este campo é obrigatório.';
                                                        }
                                                        return null;
                                                      },
                                                      options: const [
                                                        'Produção',
                                                        'Manutenção',
                                                        'Administrativo'
                                                      ],
                                                      onChanged: (val) =>
                                                          setState(() =>
                                                              setState(() {
                                                                _model.tipoinput =
                                                                    val;
                                                              })),
                                                      width: double.infinity,
                                                      height: 56.0,
                                                      searchHintTextStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelMediumFamily),
                                                              ),
                                                      searchTextStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              ),
                                                      textStyle: _model
                                                                  .tipoinput ==
                                                              null
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              )
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              ),
                                                      hintText:
                                                          'Clique aqui para selecionar ...',
                                                      searchHintText:
                                                          'Pesquise aqui ...',
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 24.0,
                                                      ),
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      elevation: 1.0,
                                                      borderColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      borderWidth: 1.3,
                                                      borderRadius: 8.0,
                                                      margin:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(16.0,
                                                              4.0, 16.0, 4.0),
                                                      hidesUnderline: true,
                                                      isOverButton: true,
                                                      isSearchable: true,
                                                      isMultiSelect: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                decoration: BoxDecoration(),
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
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 2, 0, 0),
                                                    child: Text(
                                                      'Urgente',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                fontSize: 16,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Transform.scale(
                                                scale: 1.2,
                                                child: Switch(
                                                  thumbIcon:
                                                      MaterialStateProperty
                                                          .resolveWith<Icon?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .selected)) {
                                                        return const Icon(
                                                            Icons.check,
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    1.0));
                                                      }
                                                      return const Icon(
                                                          Icons.close);
                                                    },
                                                  ),
                                                  thumbColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .selected)) {
                                                        return Color(
                                                            0xFFFA4B55);
                                                      }
                                                      return Colors.grey;
                                                    },
                                                  ),
                                                  trackColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color?>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .selected)) {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .error;
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .values[1],
                                                  value: _model.isRunning,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _model.isRunning = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(),
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
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 2, 0, 0),
                                                    child: Text(
                                                      'Checklist *',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                fontSize: 16,
                                                                useGoogleFonts: GoogleFonts
                                                                        .asMap()
                                                                    .containsKey(
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily),
                                                              ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: FFButtonWidget(
                                                  onPressed: () {
                                                    if (_model.equipamento ==
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        margin: EdgeInsets.only(
                                                            top: MediaQuery.of(
                                                                    context)
                                                                .padding
                                                                .top, // Adjust for safe area
                                                            left: 16,
                                                            right: 16),
                                                        content:
                                                            AwesomeSnackbarContent(
                                                          inMaterialBanner:
                                                              true,
                                                          title:
                                                              'Campo Equipamento é obrigatório',
                                                          message:
                                                              'Por favor, preencha o campo de Equipamento para prosseguir',
                                                          contentType:
                                                              ContentType
                                                                  .warning,
                                                        ),
                                                      ));
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .clearSnackBars();
                                                      _model.checklist = true;
                                                      if (_model
                                                              .equipamentoselcetanterior !=
                                                          _model.equipamento) {
                                                        _model.equipamentoselcetanterior =
                                                            _model.equipamento;
                                                        _model.checklistItems =
                                                            [];
                                                      }
                                                      safeSetState(() {});
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChecklistScreen(
                                                            checklistItems: _model
                                                                .checklistItems,
                                                            id_equipment: _model
                                                                .equipamento
                                                                .toString(),
                                                            imagem: _model
                                                                .equipamentoimagem,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  text: 'Novo Checklist',
                                                  icon: Icon(
                                                    Icons
                                                        .document_scanner_outlined,
                                                    size: 18,
                                                  ),
                                                  options: FFButtonOptions(
                                                    height: 40,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                24, 0, 24, 0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 0),
                                                    color: _model.checklistItems
                                                                .length >
                                                            0
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary1
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
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
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(),
                                              ),
                                            ].divide(SizedBox(height: 2)),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 60)),
                                        ].divide(SizedBox(height: 5)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: (constraints.maxHeight * 0.1),
                            child: Align(
                              alignment: AlignmentDirectional(0, -1),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 5, 8, 0),
                                child: FFButtonWidget(
                                  onPressed: () {
                                    _model.formKey.currentState?.validate();
                                    if (_model.checklistItems.length > 0) {
                                      submitChecklist();
                                    } else {
                                      final snackBar = SnackBar(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        content: AwesomeSnackbarContent(
                                          inMaterialBanner: true,
                                          title: 'Checklist Vazio',
                                          message:
                                              'Por favor, preencha o checklist para prosseguir',
                                          contentType: ContentType.warning,
                                        ),
                                      );
                                      return ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  },
                                  text: 'Enviar',
                                  icon: Icon(
                                    Icons.upload_file,
                                    size: 24,
                                  ),
                                  options: FFButtonOptions(
                                    height: 40,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24, 0, 24, 0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: FlutterFlowTheme.of(context).success,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          color: Colors.white,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily),
                                        ),
                                    elevation: 3,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
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
