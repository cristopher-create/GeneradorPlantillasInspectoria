// abordar_screen.dart
import 'package:flutter/material.dart';
import 'Liquidacion_screen.dart'; 
import 'ajustes_screen.dart'; 

class AbordarScreen extends StatefulWidget {
  const AbordarScreen({super.key});

  @override
  State<AbordarScreen> createState() => _AbordarScreenState();
}

class _AbordarScreenState extends State<AbordarScreen> {

  String _capturedDate = '';
  String _capturedTime = '';


  void _abordar() {
    setState(() {
      DateTime now = DateTime.now();
      
      _capturedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      _capturedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      print("Fecha capturada: $_capturedDate");
      print("Hora capturada: $_capturedTime");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiquidacionScreen(
            fechaAbordaje: _capturedDate,
            horaAbordaje: _capturedTime,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abordar'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjustesScreen(), 
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            ElevatedButton(
              onPressed: _abordar, 
              child: const Text('Abordar'),
              style: ElevatedButton.styleFrom(
               padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50), 
              ),
            ),
            if (_capturedDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0), 
                child: Text('Fecha Capturada: $_capturedDate'), 
              ), 
            if (_capturedTime.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0), 
                child: Text('Hora Capturada: $_capturedTime'), 
              ),
          ],
        ),
      ),
    );
  }
}