import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuario.dart';

//LEER ------------------------------------------------------------------
/*
Primero voy a enmarcar éste auth_service para que se pueda utilizar de manera gloobal
en mi aplicación utilizando provider. Entonces:
El MaterialApp del main.dart (ctrl + punto) lo envuelvo en un nuevo widget
El widget que voy a utilizar es el MultiProvider (al escribirlo me aseguro de que se importó)
Añadimos la propiedad "Provider" en el widget que creamos. quedaría así:

return MultiProvider(
  providers: [
    //acá ponemos un listado o colección de providers
    //en éste caso AuthService es un provider porque estoy mezclando con mi changeNotifier
    //entoces creamos una instancia global de mi AuthService abajo
    ChangeNotifier (create: (_) => AuthService()),
  ]
)
*/
//LEER ------------------------------------------------------------------
class AuthService with ChangeNotifier {
  Usuario? usuario;
  bool _autenticando = false;

  // Create storage
  final _storage = new FlutterSecureStorage();

  //creamos los geters y seters de la propiedad _autenticando para notificar a los
  //widget que están escuchando y notificarle que hubo un cambio
  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  //Getters del token de forma estática para acceder al mismo desde cualquier lugar
  static Future<String?> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool?> login(String email, String password) async {
    this.autenticando = true;
    //lo que vamos a mandar al backend
    final data = {
      'email': email,
      'password': password,
    };

    final uri = Uri.parse('${Environment.apiUrl}/login');
    final resp = await http.post(uri, body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
    });
    //página para matear lo que recibimos del servidor (nombre,correo, token etc)
    //https://quicktype.io/
    //copio la respuesta que recibo cuando hago un login de usuario en postman
    //pego en la pagina quicktype.io y me mapea todo
    //le pongo el nombre de la clase como LoginResponse (en la caja de texto arriba de donde pego el código en quicktype.io)
    //copio el código que me genera quicktype.io y pego en un nuevo archivo en la carpeta de models
    //en este caso copie en models/login_response.dart

    //ponemos el boton INGRESAR en false porque ya inició sesión
    this.autenticando = false;
    //ahora verificamos que no haya ningún error
    if (resp.statusCode == 200) {
      //quiere decir que no hay errores
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      //vamos a devolver true como respuesta del Future que es un bool ya que
      //si llegamos a éste punto quiere decir que está todo bien

      //Guardar token en un lugar seguro (el token está guardado en loginResponse)
      await this._guardarToken(loginResponse.token!);
      //espera a que se grabe y continúa con la siguiente línea, por eso el await

      return true;
    } else {
      return false;
    }
  }

  Future register(String nombre, String email, String password) async {
    this.autenticando = true;
    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };
    final uri = Uri.parse('${Environment.apiUrl}/login/new');
    final resp = await http.post(uri, body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
    });
    this.autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token!);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool?> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');
    final uri = Uri.parse('${Environment.apiUrl}/login/renew');
    final resp = await http.get(uri,
        headers: {'Content-Type': 'application/json', 'x-token': token!});

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token!);
      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future _guardarToken(String token) async {
    // Write value
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
