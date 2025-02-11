import '/backend/api_requests/api_calls.dart';

import '/flutter_flow/flutter_flow_util.dart';

import 'HomeOperador_widget.dart' show HomeOperadorWidget;
import 'package:flutter/material.dart';


class HomeOperadorModel extends FlutterFlowModel<HomeOperadorWidget> {
  ///  State fields for stateful widgets in this page.

  TextEditingController pesquisaController = TextEditingController();
  FocusNode pesquisaFocusNode = FocusNode();
  Set<String> filtrosSelecionados = {};
  Set<String> filtrosSelecionadospesquisa = {};
  bool mostrarPesquisa = false;
  bool focusPesquisa = false;



  final unfocusNode = FocusNode();




  @override
  void initState(BuildContext context) {



    pesquisaController.addListener(() {
       // Notificar ouvintes sobre a mudança
    });


    pesquisaFocusNode.addListener(() {
      if (!pesquisaFocusNode.hasFocus && pesquisaController.text.isEmpty) {
        mostrarPesquisa = false;


      }
      if (!pesquisaFocusNode.hasFocus) {
        focusPesquisa = false;


      }


    });

  }

  void dispose() {
    unfocusNode.dispose();


    pesquisaController.dispose();
    pesquisaFocusNode.dispose();

  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
