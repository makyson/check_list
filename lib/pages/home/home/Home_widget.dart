import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../api.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import 'Home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> equipamento = [];
  List<dynamic> pendencias = [];
  List<dynamic> urgentes = [];
  List<dynamic> liberado = [];
  List<dynamic> aguardando = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => buscar());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    buscartypos();
  }

  Future<void> buscarequipamento() async {
    final response =
        await http.get(Uri.parse(apilogin() + '/list/listequipamento'));

    if (response.statusCode == 200) {
      final informacoes = json.decode(response.body);
      setState(() {
        equipamento = List<Map<String, dynamic>>.from(informacoes);
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> buscartypos() async {
    final response = await http.get(
        Uri.parse(apilogin() + '/checklist/listar-equipamentos-pendentes'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pendencias = data['pendencias'];
        urgentes = data['urgentes'];
        liberado = data['liberados'];
        aguardando = data['aguardando'];
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  Future<void> buscar() async {
    await buscarequipamento();
    await buscartypos();
    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> processEquipamentos() {
    List<Map<String, dynamic>> processedEquipamentos = [];

    for (var equip in equipamento) {
      var pendencia = pendencias
          .firstWhere((p) => p['maquinaid'] == equip['id'], orElse: () => null);
      var urgente = urgentes.firstWhere((u) => u['maquinaid'] == equip['id'],
          orElse: () => null);
      var liberados = liberado.firstWhere((u) => u['maquinaid'] == equip['id'],
          orElse: () => null);
      var aguardandos = aguardando
          .firstWhere((u) => u['maquinaid'] == equip['id'], orElse: () => null);

      if (urgente != null) {
        equip['quantidade_urgentes'] =
            '${urgente['quantidade_urgentes']} Urgente';
      } else {
        equip['quantidade_urgentes'] = '';
      }
      if (pendencia != null) {
        equip['quantidade_pendentes'] =
            '${pendencia['quantidade_pendentes']} Pendente';
      } else {
        equip['quantidade_pendentes'] = '';
      }
      if (aguardandos != null) {
        equip['quantidade_aguardando'] =
            '${aguardandos['quantidade_aguardando']} Aguardando';
      } else {
        equip['quantidade_aguardando'] = '';
      }

      if (liberados != null) {
        equip['quantidade_livre'] =
            '${liberados['quantidade_liberados']} Liberado';
      } else {
        equip['quantidade_livre'] = '';
      }

      if (urgente == null && pendencia == null && liberados == null) {
        equip['quantidade_urgentes'] = 'Sem informações';
      }

      if (urgente != null) {
        equip['status'] = 'Urgente';
      } else if (pendencia != null) {
        equip['status'] = 'Pendente';
      } else if (aguardandos != null) {
        equip['status'] = 'Aguardando';
      } else if (liberados != null) {
        equip['status'] = 'Liberado';
      } else {
        equip['status'] = '';
      }
      processedEquipamentos.add(equip);
    }
    return processedEquipamentos;
  }

  List<Map<String, dynamic>> filterEquipamentos() {
    String searchTerm = _model.pesquisaController.text.toLowerCase();
    Set<String> selectedFilters = _model.filtrosSelecionados;
    List<Map<String, dynamic>> filteredEquipamentos = processEquipamentos();

    if (searchTerm.isNotEmpty) {
      filteredEquipamentos = filteredEquipamentos.where((equip) {
        return equip['nome'].toLowerCase().contains(searchTerm);
      }).toList();
    }

    if (!_model.mostrarPesquisa) {
      if (selectedFilters.isNotEmpty) {
        if (selectedFilters.contains('Liberado') &&
            selectedFilters.contains('Pendente') &&
            selectedFilters.contains('Urgente')) {
          // Nenhum filtro aplicado, pois todos os filtros estão selecionados.
        } else {
          filteredEquipamentos = filteredEquipamentos.where((equip) {
            // Inclui equipamentos com status vazio quando "Liberado" está selecionado
            if (selectedFilters.contains('Liberado') && equip['status'] == '') {
              return true;
            }
            // Filtra pelos status selecionados normalmente
            return selectedFilters.contains(equip['status']);
          }).toList();

          // Ordena para que "Liberado" venha primeiro e os vazios por último
          filteredEquipamentos.sort((a, b) {
            if (a['status'] == '' && b['status'] != '') {
              return 1; // Equipamento com status vazio vai para o final
            } else if (a['status'] != '' && b['status'] == '') {
              return -1; // Equipamento com status não vazio vem antes
            } else if (a['status'] == 'Liberado' && b['status'] != 'Liberado') {
              return -1; // "Liberado" vem antes
            } else if (a['status'] != 'Liberado' && b['status'] == 'Liberado') {
              return 1; // "Liberado" vem depois
            }
            return 0; // Deixa os demais itens em suas posições atuais
          });
        }
      }
    }

    return filteredEquipamentos;
  }

  void exibirSobreposicao(BuildContext context, String? imagem, selicon) {
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

  Widget buildEquipamentoItem(Map<String, dynamic> equip) {
    Color textColor;
    if (equip['status'] == 'Urgente') {
      textColor = Colors.black;
    } else if (equip['status'] == 'Pendente') {
      textColor = Colors.red;
    } else {
      textColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'ListarDefeitos',
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
                      border: Border.all(
                        color: equip['status'] == 'Urgente'
                            ? Colors.black
                            : equip['status'] == 'Pendente'
                                ? Colors.red
                                : equip['status'] == 'Aguardando'
                                    ? Colors.amber
                                    : equip['status'] == 'Liberado'
                                        ? Colors.green
                                        : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        exibirSobreposicao(
                            context, equip['imagem_caminho'], Icons.train);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: equip['imagem_caminho'] != null &&
                                  equip['imagem_caminho'] != ''
                              ? Image.network(
                                  '${apidevimagem()}imagem/imagemequipamento/${equip['imagem_caminho']}',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.train,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.train,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
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
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .bodyMediumFamily),
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 4, 0, 0),
                            child: Text(
                              equip['quantidade_pendentes'].toString() +
                                  ' ' +
                                  equip['quantidade_aguardando'] +
                                  '' +
                                  equip['quantidade_urgentes'].toString() +
                                  ' ' +
                                  equip['quantidade_livre'].toString(),
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

  Widget BotaoFiltro(String texto, TextStyle textstyle, bool selecionado) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selecionado
            ? Color.fromRGBO(170, 171, 217, 0.8901960784313725)
            : null,
      ),
      onPressed: () {
        setState(() {
          if (_model.filtrosSelecionados.contains(texto)) {
            _model.filtrosSelecionados.remove(texto);
          } else {
            _model.filtrosSelecionados.add(texto);
          }
        });
      },
      child: Text(
        texto,
        style: textstyle,
      ),
    );
  }

  Widget BotaoFiltropesquisa(
      String texto, TextStyle textstyle, bool selecionado) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selecionado ? Color.fromRGBO(170, 171, 217, 0.76) : null,
      ),
      onPressed: () {
        setState(() {
          if (_model.filtrosSelecionadospesquisa.contains(texto)) {
            _model.filtrosSelecionadospesquisa.remove(texto);
          } else {
            _model.filtrosSelecionadospesquisa.add(texto);
          }
        });
      },
      child: Text(
        texto,
        style: textstyle,
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 15.0, 0.0, 0.0),
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
                                          transitionBuilder: (Widget child,
                                              Animation<double> animation) {
                                            return SizeTransition(
                                              sizeFactor: animation,
                                              child: child,
                                            );
                                          },
                                          child: _model.mostrarPesquisa
                                              ? Padding(
                                                  key: ValueKey(1),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 0, 16, 0),
                                                  child: TextField(
                                                    focusNode: _model
                                                        .pesquisaFocusNode,
                                                    controller: _model
                                                        .pesquisaController,
                                                    onChanged: (value) {
                                                      setState(() {});
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: 'Pesquisar...',
                                                      filled: true,
                                                      fillColor:
                                                          Colors.grey[200],
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      prefixIcon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: IconButton(
                                                          icon: Icon(
                                                              Icons.arrow_back,
                                                              color:
                                                                  Colors.blue),
                                                          onPressed: () {
                                                            setState(() {
                                                              _model.mostrarPesquisa =
                                                                  false;
                                                              _model
                                                                  .pesquisaController
                                                                  .clear();
                                                              _model.unfocusNode
                                                                  .requestFocus();
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
                                      child: !_model.mostrarPesquisa ||
                                              _model.pesquisaController.text
                                                  .isEmpty
                                          ? Wrap(
                                              key: ValueKey(3),
                                              alignment: WrapAlignment.center,
                                              spacing:
                                                  8.0, // Espaçamento entre os itens na mesma linha
                                              runSpacing:
                                                  8.0, // Espaçamento entre as linhas
                                              children: [
                                                BotaoFiltro(
                                                    'Liberado',
                                                    TextStyle(
                                                        color: Color.fromRGBO(
                                                            33, 117, 2, 1.0)),
                                                    _model.filtrosSelecionados
                                                        .contains('Liberado')),
                                                BotaoFiltro(
                                                    'Pendente',
                                                    TextStyle(
                                                        color: Colors.red),
                                                    _model.filtrosSelecionados
                                                        .contains('Pendente')),
                                                BotaoFiltro(
                                                    'Urgente',
                                                    TextStyle(
                                                        color: Colors.black),
                                                    _model.filtrosSelecionados
                                                        .contains('Urgente')),
                                                BotaoFiltro(
                                                    'Aguardando',
                                                    TextStyle(
                                                        color: Colors.amber),
                                                    _model.filtrosSelecionados
                                                        .contains(
                                                            'Aguardando')),
                                                IconButton(
                                                  icon: Icon(Icons.search),
                                                  onPressed: () {
                                                    setState(() {
                                                      _model.mostrarPesquisa =
                                                          !_model
                                                              .mostrarPesquisa;
                                                      _model
                                                          .filtrosSelecionadospesquisa
                                                          .add('Todos');
                                                      _model.focusPesquisa =
                                                          !_model.focusPesquisa;
                                                      _model.pesquisaFocusNode
                                                          .requestFocus();
                                                    });
                                                  },
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
                                  itemCount: filterEquipamentos().length,
                                  itemBuilder: (context, index) {
                                    return buildEquipamentoItem(
                                        filterEquipamentos()[index]);
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
            GoRouter.of(context).pushNamed('NewService');
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
