// add_conductor_screen.dart
import 'package:flutter/material.dart';


class AddConductorScreen extends StatefulWidget {
  final String initialAbreviatura;

  const AddConductorScreen({
    super.key,
    required this.initialAbreviatura,
  });

  @override
  State<AddConductorScreen> createState() => _AddConductorScreenState();
}

class _AddConductorScreenState extends State<AddConductorScreen> {
  final TextEditingController _abreviaturaController = TextEditingController();
  final TextEditingController _nombreConductorController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 

  @override
  void initState() {
    super.initState();
    _abreviaturaController.text = widget.initialAbreviatura;
  }

  @override
  void dispose() {
    _abreviaturaController.dispose();
    _nombreConductorController.dispose();
    super.dispose();
  }

  void _saveConductor() {
    if (_formKey.currentState!.validate()) {
      final String abreviatura = _abreviaturaController.text.trim().toUpperCase();
      final String nombreCompleto = _nombreConductorController.text.trim();

      if (nombreCompleto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre del conductor no puede estar vacío.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.pop(context, {
        'abreviatura': abreviatura,
        'nombreCompleto': nombreCompleto,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conductor "$nombreCompleto" ($abreviatura) añadido.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Conductor'),
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _abreviaturaController,
                decoration: const InputDecoration(
                  labelText: 'Abreviatura',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.short_text),
                ),
                readOnly: true,
                enabled: false,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreConductorController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo del Conductor',
                  hintText: 'Ej: JUAN PEREZ LOPEZ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingrese el nombre completo del conductor.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveConductor,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Conductor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}