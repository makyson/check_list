import 'dart:convert';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:untitled/backend/api_requests/api_calls.dart';
import 'package:untitled/backend/api_requests/api_manager.dart';

import '../../../api.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import './HomeOperador_model.dart';



import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class HomeOperadorWidget extends StatefulWidget {
  const HomeOperadorWidget({Key? key}) : super(key: key);

  @override
  _HomeOperadorWidgetState createState() => _HomeOperadorWidgetState();
}

class _HomeOperadorWidgetState extends State<HomeOperadorWidget> {
  late HomeOperadorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> operador = [];

  bool isLoading = true;

  ApiCallResponse? response;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeOperadorModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => buscaroperadores());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> buscaroperadores() async {
    response = await Buscar_operadores.call();
    if (response!.succeeded) {
      final data = Buscar_operadores.getChecklistItems(response?.jsonBody);

      setState(() {
        operador = data!;
        isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }



  List<Map<String, dynamic>> filterOperador() {
    String searchTerm = _model.pesquisaController.text.toLowerCase();
    List<Map<String, dynamic>> filteredEquipamentos = operador;

    if (searchTerm.isNotEmpty) {
      List<String> searchWords = searchTerm.split(' ');

      filteredEquipamentos = filteredEquipamentos.where((equip) {
        String nome = equip['nome'].toLowerCase();
        String funcao = equip['funcao'].toLowerCase();

        bool nomeMatch = searchWords.any((word) =>
        StringSimilarity.compareTwoStrings(word, nome) > 0.2);
        bool funcaoMatch = searchWords.any((word) =>
        StringSimilarity.compareTwoStrings(word, funcao) > 0.35);

        return nomeMatch || funcaoMatch;
      }).toList();

      // Ordenar os resultados pela melhor correspondência de nome e função
      filteredEquipamentos.sort((a, b) {
        double maxSimilarityA = searchWords.map((word) => StringSimilarity.compareTwoStrings(word, a['nome'].toLowerCase())).reduce((a, b) => a > b ? a : b);
        double maxSimilarityB = searchWords.map((word) => StringSimilarity.compareTwoStrings(word, b['nome'].toLowerCase())).reduce((a, b) => a > b ? a : b);
        return maxSimilarityB.compareTo(maxSimilarityA);
      });
    }

    return filteredEquipamentos;
  }

  void exibirSobreposicao(BuildContext context, String? imagem, IconData selicon) {
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
                child: imagem != null && imagem != ''
                    ? Image.network(
                  '${apidevimagem()}imagem/imagemequipamento/${imagem}',
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

  Widget buildOperadores(Map<String, dynamic> equip) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'ListarDetalyOperador',
          queryParameters: {
            'id': serializeParam(
              equip['id'].toString(),
              ParamType.String,
            ),
          },
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 2, 6),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: equip['imagem_caminho'] != null &&
                            equip['imagem_caminho'] != ''
                            ? Image.network(
                          equip['imagem_caminho'],
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                              size: 24,
                            );
                          },
                        )
                            : Icon(
                          Icons.person,
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
                            equip['nome'],
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
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: Text(
                              equip['funcao'],
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primary,
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
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE4E4E4),
            ),
          ],
        ),
      ),
    );
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

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).info,
        body: SafeArea(
          top: true,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            children: [
                              Column(
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return SizeTransition(
                                        sizeFactor: animation,
                                        child: child,
                                      );
                                    },
                                    child: _model.mostrarPesquisa
                                        ? Padding(
                                      key: ValueKey(1),
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                      child: TextField(
                                        focusNode: _model.pesquisaFocusNode,
                                        controller: _model.pesquisaController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Pesquisar...',
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_back, color: Colors.blue),
                                              onPressed: () {
                                                setState(() {
                                                  _model.mostrarPesquisa = false;
                                                  _model.pesquisaController.clear();
                                                  _model.unfocusNode.requestFocus();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : SizedBox.shrink(),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                          if (!_model.mostrarPesquisa)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: !_model.mostrarPesquisa || _model.pesquisaController.text.isEmpty
                                    ? Row(
                                  key: ValueKey(3),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          setState(() {
                                            _model.mostrarPesquisa = !_model.mostrarPesquisa;
                                            _model.filtrosSelecionadospesquisa.add('Todos');
                                            _model.focusPesquisa = !_model.focusPesquisa;
                                            _model.pesquisaFocusNode.requestFocus();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                                    : SizedBox.shrink(),
                              ),
                            ),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filterOperador().length,
                            itemBuilder: (context, index) {
                              return buildOperadores(filterOperador()[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GoRouter.of(context).pushNamed('Newoperador');
          },
          child: Icon(
            Icons.add,
            size: 37,
            color: Colors.white,
          ),
          backgroundColor: Colors.indigoAccent,
        ),
      ),
    );
  }
}
