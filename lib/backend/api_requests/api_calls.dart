import 'dart:convert';

import '/flutter_flow/flutter_flow_util.dart';
import '../../api.dart';
import '../../pages/service/model.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginCall {
  static Future<ApiCallResponse> call({
    String? name = '',
    String? senha = '',
  }) async {
    final ffApiRequestBody = '''
{
  "name": "${name}",
  "password": "${senha}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '${apilogin()}/auth/login',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      alwaysAllowBody: false,
    );
  }

  static String? token(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.token''',
      ));
  static String? user(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.name''',
      ));
  static List<String>? permissions(dynamic response) => (getJsonField(
        response,
        r'''$.permissions''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class Buscar_checklistCall {
  static Future<ApiCallResponse> call({
    String? id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'BuscarChecklist',
      apiUrl: '${apilogin()}/checklist/buscar',
      callType: ApiCallType.GET, // Use GET for fetching data
      headers: {'Content-Type': 'application/json'}, // Optional for GET
      params: {'id': id}, // Optional for GET
      returnBody: true,
      decodeUtf8: true, // Decode response as UTF-8
      cache: false,
    );
  }

  // Remove the 'permissions' function as we're using 'getChecklistItems'

  static List<Map<String, dynamic>>? getChecklistItems(dynamic response) {
    if (response == null) return null;
    final checklistItems = response['checklistItems'];

    if (checklistItems is List) {
      return checklistItems.map((x) => x as Map<String, dynamic>).toList();
    } else {
      return null;
    }
  }
}

class Post_checklistCall {
  static Future<ApiCallResponse> call({
    required String name,
    required List<ChecklistItem> checklistItem,
    required int? mecanicoid,
    required int? equipamento,
    required String? tipoinput,
    required bool urgente,
    required String? datavalue,
  }) async {
    var data = {
      'nome': name,
      'maquinaid': equipamento,
      'setor': tipoinput,
      'mecanicoid': mecanicoid,
      'data': datavalue,
      'urgente': urgente,
      'checklistItems': checklistItem
          .map((item) {
            var filteredQuestions = item.questionario
                .where(
                    (question) => question != null && question.boxvalue == "2")
                .map((question) {
              return {
                'question': question.question,
                'id': question.id,
                'boxvalue': question.boxvalue,
                'isoutro': question.isoutro,
                'pickedFiles': question.pickedFiles.map((file) {
                  return {
                    'type': file.type,
                    'file': file.file,
                    'bytes': base64Encode(file.bytes),
                    'description': file.description,
                  };
                }).toList(),
              };
            }).toList();

            // Retornar apenas se houver questões válidas
            if (filteredQuestions.isNotEmpty) {
              return {
                'questionario': filteredQuestions,
              };
            } else {
              return null; // Ignorar itens sem questões válidas
            }
          })
          .where((item) => item != null)
          .toList(), // Remover itens nulos do checklistItems
    };

    final ffApiRequestBody = jsonEncode(data);
    return ApiManager.instance.makeApiCall(
      callName: 'PostChecklist',
      apiUrl: '${apilogin()}/checklist/submit-checklist',
      callType: ApiCallType.POST,
      headers: {'Content-Type': 'application/json'},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      alwaysAllowBody: false,
    );
  }

  static String? id(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.id''',
      ));
}

class Buscar_operadores {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Buscaroperadores',
      apiUrl: '${apilogin()}/list/listoperador',
      callType: ApiCallType.GET, // Use GET for fetching data
      headers: {'Content-Type': 'application/json'}, // Optional for GET
      returnBody: true,
      decodeUtf8: true, // Decode response as UTF-8
      cache: false,
    );
  }

  // Remove the 'permissions' function as we're using 'getChecklistItems'

  static List<Map<String, dynamic>>? getChecklistItems(dynamic response) {
    if (response == null) return null;
    final checklistItems = response;

    if (checklistItems is List) {
      return checklistItems.map((x) => x as Map<String, dynamic>).toList();
    } else {
      return null;
    }
  }
}

class Buscar_checklistCalloperadores {
  static Future<ApiCallResponse> call({
    String? id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'BuscarChecklist',
      apiUrl: '${apilogin()}/checklistoperador/buscarall',
      callType: ApiCallType.GET, // Use GET for fetching data
      headers: {'Content-Type': 'application/json'}, // Optional for GET
      params: {'id': id}, // Optional for GET
      returnBody: true,
      decodeUtf8: true, // Decode response as UTF-8
      cache: false,
    );
  }

  // Remove the 'permissions' function as we're using 'getChecklistItems'

  static List<Map<String, dynamic>>? getChecklistItems(dynamic response) {
    if (response == null) return null;
    final checklistItems = response['questionarios'];

    if (checklistItems is List) {
      return checklistItems.map((x) => x as Map<String, dynamic>).toList();
    } else {
      return null;
    }
  }
}

class Post_operadores {
  static Future<ApiCallResponse> call({
    required String name,
    required int? operadorid,
    required List<ChecklistItems> checklistItem,
    required int? equipamento,
    required String? datavalue,
  }) async {
    var data = {
      'nome': name,
      'operadorid': operadorid,
      'maquinaid': equipamento,
      'data': datavalue,
      'checklistItems': checklistItem
          .map((item) {
            var filteredQuestions = item.questionario
                .where(
                    (question) => question != null && question.boxvalue != "0")
                .map((question) {
              return {
                'question': question.question,
                'id': question.id,
                'boxvalue': question.boxvalue,
                'isoutro': question.isoutro,
                'pickedFiles': question.pickedFiles.map((file) {
                  return {
                    'type': file.type,
                    'file': file.file,
                    'bytes': base64Encode(file.bytes),
                    'description': file.description,
                  };
                }).toList(),
              };
            }).toList();

            // Retornar apenas se houver questões válidas
            if (filteredQuestions.isNotEmpty) {
              return {
                'questionario': filteredQuestions,
              };
            } else {
              return null; // Ignorar itens sem questões válidas
            }
          })
          .where((item) => item != null)
          .toList(), // Remover itens nulos do checklistItems
    };

    final ffApiRequestBody = jsonEncode(data);
    return ApiManager.instance.makeApiCall(
      callName: 'PostChecklistoperador',
      apiUrl: '${apilogin()}/checklistoperador/submit-checklist',
      callType: ApiCallType.POST,
      headers: {'Content-Type': 'application/json'},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      alwaysAllowBody: false,
    );
  }

  static String? id(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.id''',
      ));
}
