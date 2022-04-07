// To parse this JSON data, do
//
//     final usuariosListaResponse = usuariosListaResponseFromJson(jsonString);

import 'dart:convert';

import 'package:chat_flutter/models/usuario.dart';

UsuariosListaResponse usuariosListaResponseFromJson(String str) => UsuariosListaResponse.fromJson(json.decode(str));

String usuariosListaResponseToJson(UsuariosListaResponse data) => json.encode(data.toJson());

class UsuariosListaResponse {
    UsuariosListaResponse({
        required this.ok,
        required this.usuarios,
    });

    bool ok;
    List<Usuario> usuarios;

    factory UsuariosListaResponse.fromJson(Map<String, dynamic> json) => UsuariosListaResponse(
        ok: json["ok"],
        usuarios: List<Usuario>.from(json["usuarios"].map((x) => Usuario.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "usuarios": List<dynamic>.from(usuarios.map((x) => x.toJson())),
    };
}

