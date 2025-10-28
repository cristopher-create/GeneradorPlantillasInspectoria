// DetalleInformeScreen.dart
import 'package:flutter/material.dart';
import '../models/incidencia_data.dart';

class DetalleInformeScreen extends StatelessWidget {
  final IncidenciaData informe;

  final String informeCompletoTexto;

  const DetalleInformeScreen({
    super.key,
    required this.informe,
    required this.informeCompletoTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Informe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${informe.fecha}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hora: ${informe.hora}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Padrón: ${informe.padron}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Operador: ${informe.operador}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Tipo de Incidencia: ${informe.tipoIncidencia}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Falta: ${informe.falta}',
              style: const TextStyle(fontSize: 16),
            ),
            if (informe.lugarBajadaFinal != null && informe.lugarBajadaFinal!.isNotEmpty)
              Text(
                'Lugar Bajada Final: ${informe.lugarBajadaFinal}',
                style: const TextStyle(fontSize: 16),
              ),
            if (informe.horaBajadaFinal != null && informe.horaBajadaFinal!.isNotEmpty)
              Text(
                'Hora Bajada Final: ${informe.horaBajadaFinal}',
                style: const TextStyle(fontSize: 16),
              ),
            if (informe.inspectorName != null && informe.inspectorName!.isNotEmpty)
              Text(
                'Inspector: ${informe.inspectorName}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Text(
              'Texto completo del informe:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                informeCompletoTexto,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}