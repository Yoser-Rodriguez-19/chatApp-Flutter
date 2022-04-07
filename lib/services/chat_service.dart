import 'package:chat_flutter/models/mensajes_response.dart';
import 'package:chat_flutter/models/usuario.dart';
import 'package:chat_flutter/global/environment.dart';
import 'package:chat_flutter/services/auth_service.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';


class ChatService with ChangeNotifier {

  late Usuario usuarioPara;



  Future <List<Mensaje>> getChat(String usuarioID) async {
    
    final resp = await http.get(
      Uri.parse('${Environment.apiURL}/mensajes/$usuarioID'),
      headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      }
    );

    final mensajesResp = mensajesResponseFromJson(resp.body);

    return mensajesResp.mensajes;


  }



}


