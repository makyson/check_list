// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class UserStruct extends BaseStruct {
  UserStruct({
    String? name,
    String? senha,
    List<String>? permissions,
  })  : _name = name,
        _senha = senha,
        _permissions = permissions;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;
  bool hasName() => _name != null;

  // "senha" field.
  String? _senha;
  String get senha => _senha ?? '';
  set senha(String? val) => _senha = val;
  bool hasSenha() => _senha != null;

  // "permissions" field.
  List<String>? _permissions;
  List<String> get permissions => _permissions ?? const [];
  set permissions(List<String>? val) => _permissions = val;
  void updatepermissions(Function(List<String>) updateFn) => updateFn(_permissions ??= []);
  bool haspermissions() => _permissions != null;

  static UserStruct fromMap(Map<String, dynamic> data) => UserStruct(
        name: data['name'] as String?,
        senha: data['senha'] as String?,
    permissions: getDataList(data['permissions']),
      );

  static UserStruct? maybeFromMap(dynamic data) =>
      data is Map ? UserStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'senha': _senha,
        'permissions': _permissions,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'senha': serializeParam(
          _senha,
          ParamType.String,
        ),
        'permissions': serializeParam(
          _permissions,
          ParamType.String,
          true,
        ),
      }.withoutNulls;

  static UserStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        senha: deserializeParam(
          data['senha'],
          ParamType.String,
          false,
        ),
        permissions: deserializeParam<String>(
          data['permissions'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'UserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is UserStruct &&
        name == other.name &&
        senha == other.senha &&
        listEquality.equals(permissions, other.permissions);
  }

  @override
  int get hashCode => const ListEquality().hash([name, senha, permissions]);
}

UserStruct createUserStruct({
  String? name,
  String? senha,
}) =>
    UserStruct(
      name: name,
      senha: senha,
    );
