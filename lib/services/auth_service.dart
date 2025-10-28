// services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {

  final String _backendBaseUrl = 'https://flores57backend.onrender.com'; //

  // --- MODIFICACIÓN CLAVE AQUÍ: Cambiamos el tipo de retorno a Future<Map<String, dynamic>?> ---
  Future<Map<String, dynamic>?> login(String idInspector, String password) async {
    final url = Uri.parse('$_backendBaseUrl/login');
    debugPrint('Intentando login enviando credenciales a mi backend en: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'idInspector': idInspector,
          'password': password,
        }),
      );

      debugPrint('Código de estado HTTP del Backend: ${response.statusCode}');
      debugPrint('Cuerpo de la respuesta del Backend: ${response.body}');

      // Si la respuesta es 200 (OK), decodificamos el JSON y lo devolvemos.
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData; // MODIFICADO: Devolvemos el mapa completo
      } else {
        // Si el backend devolvió un error (ej. 401), aún decodificamos para obtener el mensaje de error
        final Map<String, dynamic> errorResponseData = json.decode(response.body);
        debugPrint('Error del Backend: ${errorResponseData['message'] ?? 'Error desconocido en el servidor'}');
        // MODIFICADO: Devolvemos el mapa con el error (o al menos 'success': false)
        return errorResponseData;
      }
    } catch (e) {
      debugPrint('Error de conexión o procesamiento con el backend: $e');
      // MODIFICADO: En caso de excepción, devolvemos un mapa indicando fallo.
      // Puedes devolver null aquí si prefieres que null signifique un error de conexión/excepción.
      return {'success': false, 'message': 'Error de conexión o procesamiento: $e'};
    }
  }
}