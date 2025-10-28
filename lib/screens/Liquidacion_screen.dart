// lib/screens/Liquidacion_screen.dart

import 'package:flutter/material.dart';
import 'sin_observaciones_screen.dart';
import 'incidencia_del_conductor_screen.dart';
import 'incidencia_del_pasajero_screen.dart';
import 'herramienta_comparativa_screen.dart';

class LiquidacionScreen extends StatefulWidget {
  final String fechaAbordaje;
  final String horaAbordaje;

  const LiquidacionScreen({
    super.key,
    required this.fechaAbordaje,
    required this.horaAbordaje,
  });

  @override
  State<LiquidacionScreen> createState() => _LiquidacionScreenState();
}

class _LiquidacionScreenState extends State<LiquidacionScreen> {
  final List<TextEditingController> _initialControllers = List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> _currentControllers = List.generate(7, (_) => TextEditingController());

  final List<String> _precios = ['S/. 1.00', 'S/. 1.50', 'S/. 2.00', 'S/. 2.50', 'S/. 3.00', 'S/. 4.00', 'S/. 5.00'];

  @override
  void dispose() {
    for (var controller in _initialControllers) {
      controller.dispose();
    }
    for (var controller in _currentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Se ha eliminado la función _saveData() ya que no se usa.
  // La lógica de navegación ahora está en el nuevo botón.

  List<String> _formatAndGetCodes(List<TextEditingController> controllers) {
    return controllers.map((controller) {
      String value = controller.text.trim();
      if (value.isEmpty) {
        return '';
      }
      return value.padLeft(3, '0');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquidación'),
        backgroundColor: const Color(0xFF0D47A1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Se ha eliminado el actions: [IconButton(...)]
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Inserte los Códigos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 80),
                  Expanded(child: Text('Inicio', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Corte', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(7, (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        _precios[index],
                        style: TextStyle(fontSize: 16, color: Colors.cyan[600]),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _initialControllers[index],
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _currentControllers[index],
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    // El botón "Guardar Datos" ahora es "Comparar" y navega a la nueva pantalla
                    ElevatedButton(
                      onPressed: () {
                        final List<String> initialCodes = _formatAndGetCodes(_initialControllers).reversed.toList();
                        final List<String> currentCodes = _formatAndGetCodes(_currentControllers).reversed.toList();
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HerramientaComparativaScreen(
                              codigosIniciales: initialCodes,
                              codigosActuales: currentCodes,
                            ),
                          ),
                        );
                      },
                      child: const Text('Comparar', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinObservacionesScreen(
                        fechaAbordaje: widget.fechaAbordaje,
                        horaAbordaje: widget.horaAbordaje,
                      ),
                    ),
                  );
                },
                child: const Text('Continuar a Sin Observaciones'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidenciaDelConductorScreen(
                        fechaInicial: widget.fechaAbordaje,
                        horaInicial: widget.horaAbordaje,
                      ),
                    ),
                  );
                },
                child: const Text('Continuar a Incidencia del Conductor'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidenciaDelPasajeroScreen(
                        fechaInicial: widget.fechaAbordaje,
                        horaInicial: widget.horaAbordaje,
                      ),
                    ),
                  );
                },
                child: const Text('Continuar a Incidencia del Pasajero'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}