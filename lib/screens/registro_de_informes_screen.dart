// registro_de_informes_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/incidencia_data.dart';
import 'detalle_informe_screen.dart';
import 'package:flutter/services.dart';

class SavedReport {
  final IncidenciaData incidencia;
  final String fullText;

  SavedReport({required this.incidencia, required this.fullText});
  factory SavedReport.fromJson(Map<String, dynamic> json) {
    return SavedReport(
      incidencia: IncidenciaData(
        fecha: json['fecha'],
        hora: json['hora'],
        padron: json['padron'],
        lugar: json['lugar'],
        operador: json['operador'],
        sentido: json['sentido'],
        falta: json['falta'],
        cantidad: json['cantidad'],
        usuariosAdicionales: (json['usuariosAdicionales'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e))
                .toList() ??
            [],
        observaciones: (json['observaciones'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        tipoIncidencia: json['tipoIncidencia'],
        lugarBajadaFinal: json['lugarBajadaFinal'],
        horaBajadaFinal: json['horaBajadaFinal'],
        reintegradoMontos: (json['reintegradoMontos'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        inspectorCod: json['inspectorCod'],
        inspectorName: json['inspectorName'],
      ),
      fullText: json['fullText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': incidencia.fecha,
      'hora': incidencia.hora,
      'padron': incidencia.padron,
      'lugar': incidencia.lugar,
      'operador': incidencia.operador,
      'sentido': incidencia.sentido,
      'falta': incidencia.falta,
      'cantidad': incidencia.cantidad,
      'usuariosAdicionales': incidencia.usuariosAdicionales,
      'observaciones': incidencia.observaciones,
      'tipoIncidencia': incidencia.tipoIncidencia,
      'lugarBajadaFinal': incidencia.lugarBajadaFinal,
      'horaBajadaFinal': incidencia.horaBajadaFinal,
      'reintegradoMontos': incidencia.reintegradoMontos,
      'inspectorCod': incidencia.inspectorCod,
      'inspectorName': incidencia.inspectorName,
      'fullText': fullText,
    };
  }
}

class RegistroDeInformesScreen extends StatefulWidget {
  const RegistroDeInformesScreen({super.key});

  @override
  State<RegistroDeInformesScreen> createState() =>
      _RegistroDeInformesScreenState();
}

class _RegistroDeInformesScreenState extends State<RegistroDeInformesScreen> {
  List<SavedReport> _informes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInformes();
  }

  Future<void> _loadInformes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? informesJson = prefs.getStringList('saved_reports');

      if (informesJson != null) {
        _informes = informesJson
            .map((item) => SavedReport.fromJson(json.decode(item)))
            .toList();
        _informes.sort((a, b) {
          final DateTime dateTimeA = DateTime.parse(
              '${a.incidencia.fecha.split('/').reversed.join('-')} ${a.incidencia.hora}');
          final DateTime dateTimeB = DateTime.parse(
              '${b.incidencia.fecha.split('/').reversed.join('-')} ${b.incidencia.hora}');
          return dateTimeB.compareTo(dateTimeA);
        });
      } else {
        _informes = [];
      }
    } catch (e) {
      print('Error al cargar informes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildReportSummary(IncidenciaData incidencia) {
    return """Fecha y Hora: ${incidencia.fecha} ${incidencia.hora}
Conductor: ${incidencia.operador}
Lugar y Dirección: ${incidencia.lugar} ${incidencia.sentido.toLowerCase()}
Tipo de Falta: ${incidencia.falta}
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Informes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInformes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _informes.isEmpty
              ? const Center(
                  child: Text('No hay informes guardados. Genera uno desde el formulario.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _informes.length,
                  itemBuilder: (context, index) {
                    final SavedReport report = _informes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _buildReportSummary(report.incidencia),
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalleInformeScreen(
                                          informe: report.incidencia,
                                          informeCompletoTexto: report.fullText,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Ver completo'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: report.fullText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Informe copiado al portapapeles.')),
                                    );
                                  },
                                  child: const Text('Copiar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}