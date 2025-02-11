
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';

import '../../../api.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '3.dart';







class ListarDefeitosOperadorWidget extends StatefulWidget {
  final String maquinaid;

  ListarDefeitosOperadorWidget({required this.maquinaid, Key? key}) : super(key: key);

  @override
  _ListarDefeitosOperadorWidgetState createState() => _ListarDefeitosOperadorWidgetState();
}



class _ListarDefeitosOperadorWidgetState extends State<ListarDefeitosOperadorWidget> with SingleTickerProviderStateMixin {
  List<dynamic> defeitosPendentes = [];
  List<dynamic> defeitosSolucionados = [];
  bool isLoading = true;
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isSearching = false;

  FocusNode pesquisaFocusNode = FocusNode();

  @override

  void initState() {
    super.initState();
    fetchDefeitos();
    _tabController = TabController(length: 2, vsync: this);
    searchController.addListener(onSearchChanged);

    pesquisaFocusNode.addListener(() {

      if (!pesquisaFocusNode.hasFocus ) {

        if ( searchController.text.isEmpty ) {

          isSearching = false;
        setState(() {

        });

        }


      }


    });

  }

  Future<void> fetchDefeitos() async {
    final response = await http.get(Uri.parse('${apilogin()}/checklistoperador/listar-defeitos/${widget.maquinaid}'));
    if (response.statusCode == 200) {
      List<dynamic> todosDefeitos = json.decode(response.body);
      setState(() {
        defeitosPendentes = todosDefeitos.where((defeito) => defeito['solucao'] == null).toList();
        defeitosSolucionados = todosDefeitos.where((defeito) => defeito['solucao'] != null).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar os defeitos');
    }
  }


  Future<void> adicionarSolucao(int id, String solucao) async {
    final response = await http.put(
      Uri.parse('${apilogin()}/checklist/adicionar-solucao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'solucao': solucao}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solução adicionada com sucesso')));
      setState(() {
        defeitosPendentes.removeWhere((defeito) => defeito['id'] == id);
        fetchDefeitos(); // Atualiza a lista de defeitos após adicionar a solução
      });
    } else {
      throw Exception('Falha ao adicionar solução');
    }
  }



  Widget buildDefeitoItem(defeito) {
    final imagens = defeito['imagens'];
    final solucaoController = TextEditingController();


    return Card(
      child: ExpansionTile(

        //title: Text(defeito['question'] + defeito['data']), vem como string ano/mes/dia quero so dia/mes
        title: Text(defeito['question'] + ' - ' + defeito['data'].substring(8, 10) + '/' + defeito['data'].substring(5, 7) + '/' + defeito['data'].substring(0, 4)),
        subtitle: defeito['solucao'] == null? null: Text('Solução: ${defeito['solucao']}'),
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
                onTap:() => exibirSobreposicao(context, '${imagem['path']}', Icons.image),
              ),
              title: Text(imagem['description'] ?? 'Sem descrição'),
              trailing: IconButton(
                icon: Icon(Icons.download),
                onPressed: () {

                  downloadFile(
                    context,
                    '${imagem['path']}',
                    imagem['path'].split('/').last,
                  );
                },
              ),

            ),
          if (defeito['solucao'] == null)



            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: solucaoController,
                    //quebra de linha
                    maxLines: null,
                    decoration: InputDecoration(labelText: 'Adicionar Solução'),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if(solucaoController.text.isEmpty || solucaoController.text == null || solucaoController.text.trim().isEmpty){
                        final snackBar = SnackBar(
                          //mostra no topo
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,


                          content: AwesomeSnackbarContent(
                            inMaterialBanner:true ,

                            title: 'Campo Obrigatório',
                            message: 'O campo de solução é obrigatório por favor preencha! para enviar a solução.',
                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        return;
                      };
                      adicionarSolucao(defeito['id'], solucaoController.text);
                    },
                    child: Text('Enviar Solução'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [


          Text(label, style: FlutterFlowTheme.of(context).bodyLarge.override(
            fontFamily: 'Poppins',
            color: Colors.black,
          )),
          SizedBox(width: 8),
          if (count > 0)


            Container(

              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                //  count maio que 4 casa mostre +9999
                count > 9999 ? '+9999' : count.toString(),
                style: FlutterFlowTheme.of(context).bodyText1.override(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            )
        ],
      ),
    );
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
                child: imagem != null &&
                    imagem != ''
                    ? Image.network(
                  imagem,
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




  Widget buildDefeitosList(List<dynamic> defeitos) {
    return defeitos.isEmpty
        ? Center(child: Text('Nenhum defeito encontrado'))
        : ListView.builder(
      itemCount: defeitos.length,
      itemBuilder: (context, index) {
        return buildDefeitoItem(defeitos[index]);
      },
    );
  }



  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;

    });
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120.0, // Mantido constante para simplificação
              floating: true,
              automaticallyImplyLeading: false,
              pinned: true,

              flexibleSpace: FlexibleSpaceBar(
                // Correção para alternar entre pesquisa e título
                background:  Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 8, right: 8),
                  child:  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                    position: Tween<Offset>(
                    begin: Offset(0.0, -0.25), // Começa um pouco acima
                    end: Offset(0.0, 0.0), // Termina na posição normal
                    ).animate(animation),
                    child: child,
                    ),
                    );

                    },
                    child: isSearching
                        ? Padding(
                      key: ValueKey(1),
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        focusNode: pesquisaFocusNode,

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
                                  isSearching = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                        : Row(children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Listar Detalhes',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: 'Poppins',
                                color: Colors.black,)
                          ),
                        ),
                      ),
                      if(isSearching == false)
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: toggleSearch,
                        ),
                    ],),
                  ),
                )
                 // Usar Center para melhor alinhamento
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab('item', defeitosPendentes.length),
                   ],
              ),
            ),
          ];
        },
        body: Builder(

          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top ), // Ajusta o padding para evitar sobreposição
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildDefeitosList(filterAndSort(defeitosPendentes)),
                  buildDefeitosList(filterAndSort(defeitosSolucionados)),
                ],
              ),
            );
          },
        ),
      ),
    );

  }

  List<dynamic> filterAndSort(List<dynamic> original) {
    var filtered = original.where((item) => item['question'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
    filtered.sort((a, b) => a['question'].compareTo(b['question']));
    return filtered;
  }



}
