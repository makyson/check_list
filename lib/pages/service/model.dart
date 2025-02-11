import 'dart:convert';
import 'dart:typed_data';


class ChecklistItems {
  final String nome;

  final List<QuestionarioItem> questionario;

  ChecklistItems({
    required this.nome,

    required this.questionario,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,

      'questionario': questionario.map((item) => item.toJson()).toList(),
    };
  }

  factory ChecklistItems.fromJson(Map<String, dynamic> json) {
    return ChecklistItems(
      nome: json['nome'],

      questionario: (json['questionario'] as List)
          .map((item) => QuestionarioItem.fromJson(item))
          .toList(),
    );
  }
}

class ChecklistItem {
  final String nome;
  final String imagem;
  final List<QuestionarioItem> questionario;

  ChecklistItem({
    required this.nome,
    required this.imagem,
    required this.questionario,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'imagem': imagem,
      'questionario': questionario.map((item) => item.toJson()).toList(),
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      nome: json['nome'],
      imagem: json['imagem'],
      questionario: (json['questionario'] as List)
          .map((item) => QuestionarioItem.fromJson(item))
          .toList(),
    );
  }
}

class QuestionarioItem {
  final String question;
  final String id;
  final List<PickedFilesType> pickedFiles;
  String boxvalue;
  bool isoutro;

  QuestionarioItem({
    required this.id,
    required this.question,
    this.boxvalue = "0",
    this.isoutro = false,
    List<PickedFilesType>? pickedFiles,
  }) : pickedFiles = pickedFiles ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'boxvalue': boxvalue,
      'isoutro': isoutro,
      'pickedFiles': pickedFiles.map((file) => file.toJson()).toList(),
    };
  }

  factory QuestionarioItem.fromJson(Map<String, dynamic> json) {
    return QuestionarioItem(
      id: json['id'],
      question: json['question'],
      boxvalue: json['boxvalue'],
      isoutro: json['isoutro'],
      pickedFiles: (json['pickedFiles'] as List)
          .map((file) => PickedFilesType.fromJson(file))
          .toList(),
    );
  }
}

class PickedFilesType {
  final String type;
  final String file;
  final Uint8List bytes;
  final String? description;

  PickedFilesType({
    required this.type,
    required this.file,
    required this.bytes,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'file': file,
      'bytes': base64Encode(bytes),
      'description': description,
    };
  }

  factory PickedFilesType.fromJson(Map<String, dynamic> json) {
    return PickedFilesType(
      type: json['type'],
      file: json['file'],
      bytes: base64Decode(json['bytes']),
      description: json['description'],
    );
  }

  PickedFilesType copyWith({
    String? type,
    String? file,
    Uint8List? bytes,
    String? description,
  }) {
    return PickedFilesType(
      type: type ?? this.type,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      description: description ?? this.description,
    );
  }
}

class LancamentoChecklist {
  final List<ChecklistItem>? checklistItems;
  final int? equipamento;
  final String? tipoinput;
  final bool? urgente;
  final String? datavalue;

  LancamentoChecklist({
    this.checklistItems,
    this.equipamento,
    this.tipoinput,
    this.urgente,
    this.datavalue,
  });

  Map<String, dynamic> toJson() {
    return {
      'checklistItems': checklistItems?.map((item) => item.toJson()).toList(),
      'equipamento': equipamento,
      'tipoinput': tipoinput,
      'urgente': urgente,
      'datavalue': datavalue,
    };
  }

  factory LancamentoChecklist.fromJson(Map<String, dynamic> json) {
    return LancamentoChecklist(
      checklistItems: (json['checklistItems'] as List?)?.map((item) => ChecklistItem.fromJson(item)).toList(),
      equipamento: json['equipamento'],
      tipoinput: json['tipoinput'],
      urgente: json['urgente'],
      datavalue: json['datavalue'],
    );
  }
}
