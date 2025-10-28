// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/auth_service.dart';
import 'abordar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idInspectorController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String idInspector = _idInspectorController.text;
      final String password = _passwordController.text;

      debugPrint('Intentando login para ID: $idInspector con backend...');

      final Map<String, dynamic>? inspectorResponse = await _authService.login(idInspector, password);

      if (inspectorResponse != null && inspectorResponse['success'] == true) {
        debugPrint("Login exitoso para el ID de Inspector: $idInspector");

        final prefs = await SharedPreferences.getInstance();
        final DateTime now = DateTime.now();

        await prefs.setString('last_login_date', "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");

        final Map<String, dynamic>? inspectorData = inspectorResponse['inspector'];

        final String fetchedIdInspector = inspectorData?['idInspector'] ?? '';
        final String fetchedCodeInsp = inspectorData?['codeInsp'] ?? '';
        final String fetchedNombreCompleto = inspectorData?['nombre'] ?? '';

        final String nombreParaSP = fetchedNombreCompleto; 


        await prefs.setString('idInspector', fetchedIdInspector);
        await prefs.setString('codeInsp', fetchedCodeInsp);
        await prefs.setString('nombre', nombreParaSP);

        debugPrint('Datos del inspector guardados en SharedPreferences:');
        debugPrint('idInspector: $fetchedIdInspector');
        debugPrint('codeInsp: $fetchedCodeInsp');
        debugPrint('nombre: $nombreParaSP');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AbordarScreen(),
          ),
        );
      } else {
        String errorMessage = 'ID de Inspector o Contraseña incorrectos.';
        if (inspectorResponse != null && inspectorResponse.containsKey('message')) {
          errorMessage = inspectorResponse['message'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint("Login fallido para ID de Inspector: $idInspector");
      }
    }
  }

  @override
  void dispose() {
    _idInspectorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'ID de Inspector',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextFormField(
                controller: _idInspectorController,
                decoration: const InputDecoration(
                  labelText: 'ID de Inspector',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su ID de Inspector';
                  }
                  return null;
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Contraseña',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su Contraseña';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}