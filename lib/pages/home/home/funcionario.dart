import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/flutter_flow/flutter_flow_util.dart';

import '../../../api.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/form_field_controller.dart';
import '../../service/abrirsevico.dart';
import '../../service/dropdonw.dart';
import '../../service/model.dart';
import '3.dart';

class ListarFuncionarioWidget extends StatefulWidget {
  final String maquinaid;

  ListarFuncionarioWidget({required this.maquinaid, Key? key})
      : super(key: key);

  @override
  _ListarFuncionarioWidgetState createState() =>
      _ListarFuncionarioWidgetState();
}

List<Map<String, dynamic>> equipamento = [];

class _ListarFuncionarioWidgetState extends State<ListarFuncionarioWidget>
    with SingleTickerProviderStateMixin {
  List<dynamic> defeitosPendentes = [];
  List<dynamic> defeitosAguardando = [];
  List<dynamic> defeitosSolucionados = [];
  late List<bool> isShowList;
  bool isLoading = true;
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isSearching = false;
  FocusNode pesquisaFocusNode = FocusNode();
  bool _showError = false;
  List<Map<String, dynamic>> mecanicos = []; // Lista de mecânicos com id e nome
  FormFieldController<String>? dropDownValueController1;
  String? mecanico;
  final keyform = GlobalKey<FormState>();

  final ValueNotifier<Map<String, dynamic>?> _dropdownController =
      ValueNotifier<Map<String, dynamic>?>(null);

  final ValueNotifier<String?> _initialTitle = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    buscarequipamento();
    _tabController = TabController(length: 3, vsync: this);
    searchController.addListener(onSearchChanged);

    pesquisaFocusNode.addListener(() {
      if (!pesquisaFocusNode.hasFocus) {
        if (searchController.text.isEmpty) {
          isSearching = false;
          setState(() {});
        }
      }
    });

    // Inicialmente, buscar mecânicos do servidor
    fetchMecanicos();

    fetchDefeitos();
  }

  void onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;
    });
  }

  Future<void> _addMacAddress(
      int id, String Observacao, String solicitacao) async {
    if (keyform.currentState?.validate() ?? false) {
      adicionarAguardando(id, Observacao, solicitacao);

      keyform.currentState?.reset();
      Navigator.of(context).pop(); // Fecha o modal e retorna a observação
    }
  }

  Map<String, dynamic>? getNomeUrlinid(String id) {
    final equip = equipamento.firstWhere(
      (item) => item['id'] == int.tryParse(id),
      orElse: () => {},
    );


    return equip;
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<void> _addresolucao(
      BuildContext context,
      int defeito,
      String? solucaoController,
      String? mecanicoid,
      List<PickedFilesType>? files,
      String un_medidaController,
      String osController) async {
    try {
      if (!(keyform.currentState?.validate() ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Formulário inválido! Verifique os campos obrigatórios.'),
          ),
        );
        return;
      }
      if (mecanicoid == null || mecanicoid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Selecione um mecânico antes de continuar.'),
          ),
        );
        return;
      }

      // Exibe um modal de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await adicionarSolucao(defeito, solucaoController, mecanicoid, files,
            un_medidaController, osController);

        // Exibe o SnackBar corretamente sobre o modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Solução adicionada com sucesso!')),
        );

        // Atualiza a lista de defeitos
        setState(() {
          defeitosPendentes.removeWhere((d) => d['id'] == defeito);
          fetchDefeitos();
        });
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro ao adicionar solução: $e')),
        );
      } finally {
        // Fecha o modal de carregamento
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('❌ Erro inesperado: $e');
    }
  }

  Future<void> adicionarSolucao(
      int id,
      String? solucao,
      String idmecanico,
      List<PickedFilesType>? files,
      String un_medidaController,
      String osController) async {
    try {
      var data = {
        'pickedFiles': files?.map((file) {
              return {
                'type': file.type,
                'file': file.file,
                'bytes': base64Encode(file.bytes),
                'description': file.description,
              };
            }).toList() ??
            [],
      };

      final response = await http.put(
        Uri.parse('${apilogin()}/checklist/adicionar-solucao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'solucao': solucao,
          'idmecanico': idmecanico,
          'imagem': data,
          'nome': AppStateNotifier.instance.user?.userData?.name,
          'un_medida': un_medidaController,
          'os': osController
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao adicionar solução: $e');
      rethrow;
    }
  }

  String getNomePorId(String id) {
    final mecanico = mecanicos.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {'nome': 'Mecânico não encontrado'},
    );
    print(mecanicos);
    print(id);
    return mecanico['nome']!;
  }

  Future<void> fetchMecanicos() async {
    final response =
        await http.get(Uri.parse('${apilogin()}/checklist/mecanicos'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      setState(() {
        // Mapeia os dados recebidos para a lista de mecânicos
        mecanicos = data
            .map((item) => {
                  'id': item['id'].toString(),
                  'nome': item['nome'],
                  'funcao': item['funcao']
                })
            .toList();
      });
    } else {
      throw Exception('Falha ao carregar os mecânicos');
    }
  }

  Future<void> adicionarAguardando(
      int id, String solucao, String numero) async {
    final response = await http.put(
      Uri.parse('${apilogin()}/checklist/adicionar-aguardando'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': AppStateNotifier.instance.user?.userData?.name,
        'id': id,
        'aguardando': solucao,
        'numerosolicitacao': numero
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solução adicionada com sucesso')));
      setState(() {
        defeitosAguardando.removeWhere((defeito) => defeito['id'] == id);
        fetchDefeitos(); // Atualiza a lista de defeitos após adicionar a solução
      });
    } else {
      throw Exception('Falha ao adicionar solução');
    }
  }

  Future<Map<String, dynamic>> adicionarNovoMecanico(
      String nome, String funcao, bool ativo, bool funcionario) async {
    final response = await http.post(
      Uri.parse('${apilogin()}/checklist/mecanicos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'funcao': funcao,
        'ativo': ativo,
        'funcionario': funcionario
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'id': data['id'],
        'nome': nome,
        'funcao': funcao,
        'ativo': ativo,
        'funcionario': funcionario,
      };
    } else {
      throw Exception('Falha ao adicionar o mecânico');
    }
  }

  void exibirSobreposicao(
      BuildContext context, String? imagem, IconData selicon, String? texto) {
    // Armazenar dimensões da tela
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: imagem != null && imagem.isNotEmpty
                          ? AspectRatio(
                              aspectRatio: 16 /
                                  9, // Ajusta a proporção conforme necessário
                              child: Image.network(
                                imagem,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      selicon,
                                      color: Colors.grey,
                                      size: screenWidth * 0.7 / 2,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(
                                selicon,
                                color: Colors.grey,
                                size: screenWidth * 0.7 / 2,
                              ),
                            ),
                    ),
                  ),
                  if (texto != null && texto.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SelectableText(
                        "Descrição: $texto",
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirCadastroNovoMecanico() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nomeController = TextEditingController();
        TextEditingController funcaoController = TextEditingController();
        bool ativo = true;
        bool funcionario = true;
        return AlertDialog(
          title: Text('Cadastrar Novo Responsável pela inspeção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration:
                    InputDecoration(hintText: 'Responsável pela inspeção'),
              ),
              TextField(
                controller: funcaoController,
                decoration: InputDecoration(hintText: 'observação'),
              ),
              SwitchListTile(
                title: Text('É Funcionário?'),
                value: funcionario,
                onChanged: (bool value) {
                  funcionario = value;
                  setState(() {});
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar $funcionario'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal sem salvar
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () async {
                if (nomeController.text.isNotEmpty &&
                    funcaoController.text.isNotEmpty) {
                  try {
                    Map<String, dynamic> novoMecanicoId =
                        await adicionarNovoMecanico(
                      nomeController.text,
                      funcaoController.text,
                      ativo,
                      funcionario,
                    );

                    setState(() {
                      mecanicos.add({
                        'id': novoMecanicoId['id'],
                        'nome': novoMecanicoId['nome'],
                        'funcao': novoMecanicoId['funcao'],
                      });

                      _dropdownController.value = {
                        'id': novoMecanicoId['id'],
                        'nome': novoMecanicoId['nome'],
                        'funcao': novoMecanicoId['funcao'],
                      };

                      _initialTitle.value = novoMecanicoId['nome'];
                    });

                    // Atualiza o título inicial no Dropdown

                    Navigator.of(context).pop(); // Fecha o modal
                    Navigator.of(context).pop();
                  } catch (e) {
                    print(e);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _menulancamento(
    BuildContext context,
    List<PickedFilesType> files,
    int defeitoId,
    int index,
  ) {
    TextEditingController solucaoController = TextEditingController();
    TextEditingController un_medidaController = TextEditingController();
    TextEditingController osController = TextEditingController();
    String? mecanicoid;
    bool _showError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return AlertDialog(
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text('Insira uma Observação'),
              content: Form(
                key: keyform,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: osController,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'OS *',
                        hintText: 'Digite o número da os...',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira o número da OS";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: un_medidaController,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Horímetro / Km *',
                        hintText: 'Digite o Horímetro atual...',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira o Horímetro atual";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: solucaoController,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Observação',
                        hintText: 'Digite sua observação aqui...',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            width: 2,
                          ),
                        ),
                      ),
                      /*
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor insira a observação";
                        }
                        return null;
                      },

                      */
                    ),
                    SizedBox(height: 10),
                    CustomDropdownFormField(
                      items: mecanicos,
                      initialTitleNotifier: _initialTitle,
                      dropdownMaxHeight: 300,
                      showAddNewItem: true,
                      onAddNewItem: () {
                        _abrirCadastroNovoMecanico();
                      },
                      titleKey: 'nome',
                      subtitleKey: 'funcao',
                      onChanged: (value) {
                        mecanicoid = value?['id'].toString();
                      },
                      decoration: InputDecoration(
                        labelText: 'Responsável pela inspeção *',
                        hintText:
                            'Selecione quem realizou a inspeção para continuar...',
                        hintStyle: TextStyle(
                          fontSize: 17,
                          height: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, Selecione quem realizou a inspeção para continuar!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    ButtonTheme(
                      child: ElevatedButton(
                        onPressed: () async {
                          final updatedFiles = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FileViewer(
                                files: files,
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (files.isEmpty)
                              Icon(Icons.attach_file, color: Colors.white),
                            Text(
                              files.isEmpty
                                  ? 'Anexar'
                                  : files.length > 1
                                      ? '${files.length} Anexos'
                                      : '${files.length} Anexo',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            if (files.isNotEmpty)
                              Icon(Icons.attachment_sharp, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    if (_showError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Por favor Selecione algum arquivo para continuar!',
                          style: TextStyle(color: Colors.red, fontSize: 12.0),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o modal sem salvar
                  },
                ),
                TextButton(
                  child: Text('Salvar'),
                  onPressed: () async {
                    _showError = false;
                    setModalState(() {});

                    await _addresolucao(
                        context,
                        defeitoId,
                        solucaoController.text,
                        mecanicoid,
                        files,
                        un_medidaController.text,
                        osController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
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

  Future<void> fetchDefeitos() async {
    final response = await http.get(Uri.parse(
        '${apilogin()}/checklist/listar-funcionario/${widget.maquinaid}'));
    if (response.statusCode == 200) {
      List<dynamic> todosDefeitos = json.decode(response.body);
      setState(() {
        defeitosPendentes =
            todosDefeitos.where((d) => d['status'] == 'pendente').toList();
        defeitosAguardando =
            todosDefeitos.where((d) => d['status'] == 'aguardando').toList();
        defeitosSolucionados =
            todosDefeitos.where((d) => d['status'] == 'solucionado').toList();

        // 🔹 Inicializa a lista de expansão com todos os valores como `false`
        isShowList = List.filled(todosDefeitos.length, false);

        isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar os defeitos');
    }
  }

  Widget buildDefeitosList(List<dynamic> defeitos) {
    return defeitos.isEmpty
        ? Center(child: Text('Nenhum defeito encontrado'))
        : ListView.builder(
            itemCount: defeitos.length,
            itemBuilder: (context, index) {
              return buildDefeitoItem(defeitos[index], index);
            },
          );
  }

  Widget buildDefeitoItem(defeito, int index) {
    final List<dynamic> imagens = defeito['imagens'] ?? [];
    final List<dynamic> imagenssolucao = defeito['imagenssolucao'] ?? [];
    final solucaoController = TextEditingController();
    final solicitacaoController = TextEditingController();
    List<PickedFilesType> files = [];
    _initialTitle.value = null;
    isShowList = List<bool>.filled(defeito.length, false);
    String? mecanicoid;

    return Card(
      child: defeito['status'] == 'solucionado'
          ? ExpansionTile(
              onExpansionChanged: (bool expanded) {
                setState(() {
                  isShowList[index] = expanded;
                });
              },
              title: defeito['status'] == 'solucionado'
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${defeito['question']} - ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis, // Trunca o texto que não cabe
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '${defeito['question']} - ${defeito['data'].substring(8, 10)}/${defeito['data'].substring(5, 7)}/${defeito['data'].substring(0, 4)}'),
              subtitle: defeito['status'] == 'pendente'
                  ? Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          if (!isShowList[index] && imagens.isNotEmpty)
                            Container(
                              height: 30,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagens.length,
                                itemBuilder: (context, i) {
                                  final imagem = imagens[i];
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        child: ClipOval(
                                          child: Image.network(
                                            imagem['path'],
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        onTap: () => exibirSobreposicao(
                                          context,
                                          '${imagem['path']}',
                                          Icons.image,
                                          imagem['description'],
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                    ],
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Insira uma Observação'),
                                        content: Form(
                                          key: keyform,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller:
                                                    solicitacaoController,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Solicitação / data *',
                                                  hintText:
                                                      'Digite o número da solicitação aqui...',
                                                  hintStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Por favor, insira o número da solicitação!";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller: solucaoController,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium,
                                                decoration: InputDecoration(
                                                  labelText: 'Observação *',
                                                  hintText:
                                                      'Digite sua observação aqui...',
                                                  hintStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Por favor, insira a observação";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Fecha o modal sem salvar
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Salvar'),
                                            onPressed: () {
                                              _addMacAddress(
                                                defeito['id'],
                                                solucaoController.text,
                                                solicitacaoController.text,
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Em Andamento'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  dropDownValueController1?.value = null;
                                  _menulancamento(
                                      context, files, defeito['id'], index);
                                },
                                child: Text('Enviar Solução'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : defeito['status'] == 'aguardando'
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isShowList[index])
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Motivo: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: defeito['aguardando'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Solic: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: defeito['aguardandonumero'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _menulancamento(
                                          context, files, defeito['id'], index);
                                    },
                                    child: Text('Enviar Solução'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : defeito['status'] == 'solucionado'
                          ? Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Data: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: defeito['data'].substring(8, 10) +
                                            '/' +
                                            defeito['data'].substring(5, 7) +
                                            '/' +
                                            defeito['data'].substring(0, 4),
                                        style: TextStyle(
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow
                                      .ellipsis, // Trunca o texto que não cabe
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'OS: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            defeito['os'] ?? 'sem informações',
                                        style: TextStyle(
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow
                                      .ellipsis, // Trunca o texto que não cabe
                                ),
                              ],
                            )
                          : null,
              children: [
                if (isShowList[index] && defeito['status'] == 'aguardando')
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Motivo: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: defeito['aguardando'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Solic: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: defeito['aguardandonumero'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (imagenssolucao.isEmpty &&
                    defeito['status'] != 'solucionado')
                  for (var imagem in imagens)
                    ListTile(
                      leading: GestureDetector(
                        child: ClipOval(
                          child: Image.network(
                            imagem['path'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () => exibirSobreposicao(
                          context,
                          '${imagem['path']}',
                          Icons.image,
                          imagem['description'],
                        ),
                      ),
                      title: Text(imagem['description'] ?? 'Sem descrição'),
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {
                          downloadFile(
                            context,
                            '${imagem['path']}',
                            imagem['path'].split('/').last.split('?')[0],
                          );
                        },
                      ),
                    ),
                if (defeito['status'] == 'solucionado')
                  Column(
                    children: [
                      Divider(),
                      if (defeito['aguardando'] != null)
                        ListTile(
                          title: Text("Observações de Pausar:"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Motivo: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: defeito['aguardando'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Numero Solicitação: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: defeito['aguardandonumero'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      if (defeito['aguardando'] != null) Divider(),
                      ListTile(
                        title: Text("O que foi feito:"),
                        subtitle: Text(defeito['solucao']),
                      ),
                      if (imagenssolucao.isNotEmpty)
                        ExpansionTile(
                          title: Text('Clique para ver as imagens...'),
                          children: [
                            for (var imagem in imagenssolucao)
                              ListTile(
                                leading: GestureDetector(
                                  child: ClipOval(
                                    child: Image.network(
                                      imagem['path'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  onTap: () => exibirSobreposicao(
                                      context,
                                      '${imagem['path']}',
                                      Icons.image,
                                      imagem['description']),
                                ),
                                title: Text(
                                    imagem['description'] ?? 'Sem descrição'),
                                trailing: IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () {
                                    downloadFile(
                                      context,
                                      '${imagem['path']}',
                                      imagem['path']
                                          .split('/')
                                          .last
                                          .split('?')[0],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      Divider(),
                      ListTile(
                        title: Text("Responsável pela inspeção:"),
                        subtitle: Text(
                            getNomePorId(defeito['mecanicoId'].toString())),
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Horimetro:"),
                        subtitle: Text(defeito['un_medida'].toString() == 'null'
                            ? 'sem informações'
                            : defeito['un_medida'].toString()),
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Data de Baixa:"),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(DateTime.parse(defeito['updatedAt']))),
                      ),
                      Divider(),
                      if (imagens.isNotEmpty)
                        ListTile(
                          title: Text("Imagem da abertura:"),
                          subtitle: ExpansionTile(
                            title: Text('Clique para ver as imagens...'),
                            children: [
                              for (var imagem in imagens)
                                ListTile(
                                  leading: GestureDetector(
                                    child: ClipOval(
                                      child: Image.network(
                                        imagem['path'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    onTap: () => exibirSobreposicao(
                                        context,
                                        '${imagem['path']}',
                                        Icons.image,
                                        imagem['description']),
                                  ),
                                  title: Text(
                                      imagem['description'] ?? 'Sem descrição'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.download),
                                    onPressed: () {
                                      downloadFile(
                                        context,
                                        '${imagem['path']}',
                                        imagem['path']
                                            .split('/')
                                            .last
                                            .split('?')[0],
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            )
          : Container(
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(6, 6, 2, 6),
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
                                      child: Image.network(
                                        '${apidevimagem()}imagem/imagemequipamento/${getNomeUrlinid('${defeito['maquinaid']}')?['imagem_caminho']}',
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.train,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 24,
                                          );
                                        },
                                      )),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      12, 0, 8, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${getNomeUrlinid('${defeito['maquinaid']}')?['nome']}',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                            '${defeito['question']} - ${defeito['data'].substring(8, 10)}/${defeito['data'].substring(5, 7)}/${defeito['data'].substring(0, 4)}'),
                      ],
                    ),
                    subtitle: defeito['status'] == 'pendente'
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                if (!isShowList[index] && imagens.isNotEmpty)
                                  Container(
                                    height: 30,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: imagens.length,
                                      itemBuilder: (context, i) {
                                        final imagem = imagens[i];
                                        return Row(
                                          children: [
                                            GestureDetector(
                                              child: ClipOval(
                                                child: Image.network(
                                                  imagem['path'],
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              onTap: () => exibirSobreposicao(
                                                  context,
                                                  '${imagem['path']}',
                                                  Icons.image,
                                                  imagem['description']),
                                            ),
                                            SizedBox(width: 2),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  title: Text(
                                                      'Insira uma Observação'),
                                                  content: Form(
                                                    key: keyform,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextFormField(
                                                          controller:
                                                              solicitacaoController,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Solicitação / data *',
                                                            hintText:
                                                                'Digite o número da solicitação aqui...',
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                width: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "Por favor, insira o número da solicitação ou data!";
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                        SizedBox(height: 10),
                                                        TextFormField(
                                                          controller:
                                                              solucaoController,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Observação *',
                                                            hintText:
                                                                'Digite sua observação aqui...',
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                width: 2,
                                                              ),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "Por favor, insira a observação";
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancelar'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Fecha o modal sem salvar
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text('Salvar'),
                                                      onPressed: () {
                                                        _addMacAddress(
                                                          defeito['id'],
                                                          solucaoController
                                                              .text,
                                                          solicitacaoController
                                                              .text,
                                                        );
                                                      },
                                                    ),
                                                  ]);
                                            });
                                      },
                                      child: Text('Em Andamento'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _menulancamento(context, files,
                                            defeito['id'], index);
                                      },
                                      child: Text('Enviar Solução'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : defeito['status'] == 'aguardando'
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isShowList[index])
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Motivo: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: defeito['aguardando'],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Solic: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: defeito[
                                                      'aguardandonumero'],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 5),
                                    if (!isShowList[index] &&
                                        imagens.isNotEmpty)
                                      Container(
                                        height: 30,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imagens.length,
                                          itemBuilder: (context, i) {
                                            final imagem = imagens[i];
                                            return Row(
                                              children: [
                                                GestureDetector(
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      imagem['path'],
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      exibirSobreposicao(
                                                    context,
                                                    '${imagem['path']}',
                                                    Icons.image,
                                                    imagem['description'],
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            _menulancamento(context, files,
                                                defeito['id'], index);
                                          },
                                          child: Text('Enviar Solução'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : defeito['status'] == 'solucionado'
                                ? Text(
                                    'Solução: ${defeito['solucao']}',
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
              overflow: TextOverflow
                  .ellipsis, // Adiciona reticências se o texto for longo
            ),
          ),
          SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: EdgeInsets.all(0),
              constraints: BoxConstraints(
                  maxWidth: count > 999
                      ? 40
                      : count > 99
                          ? 30
                          : count > 9
                              ? 35
                              : 35), // Define uma largura máxima
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9999 ? '+9999' : count.toString(),
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
    });
    if (!isSearching) {
      searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:
          scaffoldMessengerKey, // Define a chave correta para gerenciar os SnackBars
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              automaticallyImplyLeading: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 8, right: 8),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: isSearching
                        ? Padding(
                            key: ValueKey(1),
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: searchController,
                              focusNode: pesquisaFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Pesquisar...',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      isSearching = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new),
                                onPressed: () {
                                  if (context.canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    context.go('/home');
                                  }
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Listar Defeitos'),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search),
                                onPressed: toggleSearch,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab('Pendentes', defeitosPendentes.length),
                  _buildTab('Aguardando', defeitosAguardando.length),
                  _buildTab('Solucionados', defeitosSolucionados.length),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            buildDefeitosList(filterAndSort(defeitosPendentes)),
            buildDefeitosList(filterAndSort(defeitosAguardando)),
            buildDefeitosList(filterAndSort(defeitosSolucionados)),
          ],
        ),
      ),
    );
  }

  List<dynamic> filterAndSort(List<dynamic> original) {
    var filtered = original
        .where((item) =>
            item['question'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    filtered.sort((a, b) => a['question'].compareTo(b['question']));
    return filtered;
  }
}
