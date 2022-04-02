import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:chat_flutter/models/usuario.dart';
import 'package:chat_flutter/global/environment.dart';
import 'package:chat_flutter/models/login_response.dart';

class AuthService with ChangeNotifier {


  Usuario? usuario;
  bool _autenticando = false;


  final _storage = new FlutterSecureStorage();


  bool get autenticando => _autenticando;

  set autenticando(bool value) {
    _autenticando = value;
    notifyListeners();
  }

  // Getters del token de forma estatica
  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token ?? '';
  }
  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }
  
  // Getters del usuario de forma estatica
  static Future<Usuario?> getUsuario() async {
    final _storage = new FlutterSecureStorage();
    final usuario = await _storage.read(key: 'usuario');
    return usuario != null ? Usuario.fromJson(json.decode(usuario)) : null;
  }




  Future<bool> login( String email, String password ) async {


    autenticando = true;

    final data = {
      'email': email,
      'password': password
    };

    final resp = await http.post(
      Uri.parse('${Environment.apiURL}/login'), 
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    autenticando = false;

    if ( resp.statusCode == 200 ) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;

      await _guardarToken( loginResponse.token );

      return true;

    } else {

      return false;
    }


  }


  Future register( String nombre, String email, String password ) async {

    autenticando = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password': password
    };

    final resp = await http.post(
      Uri.parse('${Environment.apiURL}/login/new'), 
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    autenticando = false;

    if ( resp.statusCode == 200 ) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;

      await _guardarToken( loginResponse.token );

      return true;

    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }


  Future<bool> isLoggedIn() async {

    final token = await _storage.read(key: 'token');

    final resp = await http.get(
      Uri.parse('${Environment.apiURL}/login/renew?token=$token'),
      headers: {
        'Content-Type': 'application/json',
        'x-token': token ?? ''
      }
    );

    if ( resp.statusCode == 200 ) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      await _guardarToken( loginResponse.token );
      return true;

    } else {
      logout();
      return false;
    }

  }



  Future _guardarToken( String token ) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }






}

