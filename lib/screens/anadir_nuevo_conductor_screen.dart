import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para TextInputFormatter

// Si UpperCaseTextFormatter ya está definida globalmente (ej. en main.dart o en incidencia_data.dart
// si seguiste la sugerencia del mixin), puedes eliminar esta definición e importarla.
// La mantengo aquí por si solo la usas en esta pantalla o no la tienes centralizada aún.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AnadirNuevoConductorScreen extends StatefulWidget {
  // === MODIFICACIÓN: Propiedad para recibir la abreviatura inicial ===
  final String initialAbreviatura;

  const AnadirNuevoConductorScreen({
    super.key,
    required this.initialAbreviatura, // Hacemos que la abreviatura inicial sea requerida
  });

  @override
  State<AnadirNuevoConductorScreen> createState() => _AnadirNuevoConductorScreenState();
}

class _AnadirNuevoConductorScreenState extends State<AnadirNuevoConductorScreen> {
  // === NUEVO: Controladores para los campos de texto ===
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _abreviaturaController = TextEditingController();
  final TextEditingController _nombreCompletoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // === NUEVO: Pre-llenar el campo de abreviatura con el valor inicial ===
    _abreviaturaController.text = widget.initialAbreviatura;
  }

  @override
  void dispose() {
    // === NUEVO: Liberar los controladores cuando la pantalla se cierra ===
    _abreviaturaController.dispose();
    _nombreCompletoController.dispose();
    super.dispose();
  }

  // === NUEVO: Lógica para guardar el conductor y regresar los datos ===
  void _guardarConductor() {
    if (_formKey.currentState!.validate()) {
      final String abreviatura = _abreviaturaController.text.trim().toUpperCase();
      final String nombreCompleto = _nombreCompletoController.text.trim().toUpperCase();

      // Al hacer pop, pasamos un Map con la abreviatura y el nombre completo.
      // La pantalla que llamó a esta (`SinObservacionesScreen`) recibirá este Map.
      Navigator.pop(context, {
        'abreviatura': abreviatura,
        'nombreCompleto': nombreCompleto,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Conductor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Si el usuario regresa sin guardar, hacemos pop sin datos
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // Usamos SingleChildScrollView para evitar desbordamiento con el teclado
        padding: const EdgeInsets.all(16.0),
        child: Form( // Usamos Form para validación
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Para que los campos y el botón se estiren
            children: [
              // === NUEVO: Campo de texto para la Abreviatura (DNI) ===
              TextFormField(
                controller: _abreviaturaController,
                decoration: const InputDecoration(
                  labelText: 'Abreviatura (DNI)',
                  hintText: 'Ingrese el DNI del conductor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                textCapitalization: TextCapitalization.characters, // Para que el texto sea siempre en mayúsculas
                inputFormatters: [
                  UpperCaseTextFormatter(), // Convierte a mayúsculas mientras se escribe
                  LengthLimitingTextInputFormatter(40), // Limita la longitud
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La abreviatura (DNI) no puede estar vacía.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // === NUEVO: Campo de texto para el Nombre Completo ===
              TextFormField(
                controller: _nombreCompletoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ingrese el nombre completo del conductor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.characters, // Para que el texto sea siempre en mayúsculas
                inputFormatters: [
                  UpperCaseTextFormatter(), // Convierte a mayúsculas mientras se escribe
                  LengthLimitingTextInputFormatter(100), // Limita la longitud
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre completo no puede estar vacío.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // === MODIFICACIÓN: Botón para guardar ===
              ElevatedButton.icon(
                onPressed: _guardarConductor,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Conductor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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