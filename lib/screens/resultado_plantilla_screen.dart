// resultado_plantilla_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/incidencia_data.dart';
import 'abordar_screen.dart';
import 'registro_de_informes_screen.dart';

class ResultadoPlantillaScreen extends StatefulWidget {
  final IncidenciaData incidenciaData;
  final bool fromConductorIncidencia;

  const ResultadoPlantillaScreen({
    super.key,
    required this.incidenciaData,
    this.fromConductorIncidencia = false,
  });

  @override
  State<ResultadoPlantillaScreen> createState() => _ResultadoPlantillaScreenState();
}

class _ResultadoPlantillaScreenState extends State<ResultadoPlantillaScreen> {
  late String _informeGeneradoPrincipal;
  late String _informeGeneradoSecundarioConductor;

  String _inspectorId = '';
  String _inspectorCode = '';
  String _inspectorName = '';
  bool _isLoadingInspectorData = true;

  @override
  void initState() {
    super.initState();
    _loadInspectorInfoAndGenerateReports();
  }

  Future<void> _loadInspectorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _inspectorId = prefs.getString('idInspector') ?? 'N/A';
      _inspectorCode = prefs.getString('codeInsp') ?? 'N/A';
      _inspectorName = prefs.getString('nombre') ?? 'Desconocido';
      String? rawName = prefs.getString('nombre');
      if (rawName != null && rawName.isNotEmpty) {
        _inspectorName = rawName.split(' ').first.toUpperCase();
      } else {
        _inspectorName = 'Desconocido';
      }
    });
    print('ResultadoPlantillaScreen: Inspector cargado - ID: $_inspectorId, Código: $_inspectorCode - Nombre: $_inspectorName');
  }

  Future<void> _loadInspectorInfoAndGenerateReports() async {
    await _loadInspectorInfo();

    _informeGeneradoPrincipal = _generarPlantillaTexto(widget.incidenciaData);
    _saveReport(_informeGeneradoPrincipal);

    if (widget.fromConductorIncidencia) {
      _informeGeneradoSecundarioConductor = _generarPlantillaSecundariaConductor(widget.incidenciaData);
    } else {
      _informeGeneradoSecundarioConductor = '';
    }

    setState(() {
      _isLoadingInspectorData = false;
    });
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return monthNames[month];
  }

  String _getDayOfWeekName(int weekday) {
    const List<String> weekdayNames = [
      '', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return weekdayNames[weekday];
  }

  String _getSentidoEmoji(String sentido) {
    if (sentido.toLowerCase() == 'subiendo') {
      return '⬆';
    } else if (sentido.toLowerCase() == 'bajando') {
      return '⬇';
    }
    return '';
  }

  String _formatTimeForDisplay(String fullTime) {
    final parts = fullTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return fullTime;
  }

  String _calcularTiempoInspeccion(String horaAbordeStr, String? horaBajadaStr) {
    String tiempoInspeccion = 'N/A';
    if (horaAbordeStr.isNotEmpty && horaBajadaStr != null && horaBajadaStr.isNotEmpty) {
      try {
        final abParts = horaAbordeStr.split(':');
        final bajParts = horaBajadaStr.split(':');

        if (abParts.length >= 2 && bajParts.length >= 2) {
          final abHour = int.parse(abParts[0]);
          final abMinute = int.parse(abParts[1]);
          final abSecond = abParts.length > 2 ? int.parse(abParts[2]) : 0;

          final bajHour = int.parse(bajParts[0]);
          final bajMinute = int.parse(bajParts[1]);
          final bajSecond = bajParts.length > 2 ? int.parse(bajParts[2]) : 0;

          final DateTime abordeTime = DateTime(2000, 1, 1, abHour, abMinute, abSecond);
          DateTime bajadaTime = DateTime(2000, 1, 1, bajHour, bajMinute, bajSecond);

          if (bajadaTime.isBefore(abordeTime)) {
            bajadaTime = bajadaTime.add(const Duration(days: 1));
          }

          final Duration difference = bajadaTime.difference(abordeTime);
          final int totalSeconds = difference.inSeconds;
          final int minutes = totalSeconds ~/ 60;
          final int seconds = totalSeconds % 60;

          tiempoInspeccion = '$minutes:${seconds.toString().padLeft(2, '0')}s';
        }
      } catch (e) {
        print('Error al calcular el Tiempo de Inspección: $e');
        tiempoInspeccion = 'Error';
      }
    }
    return tiempoInspeccion;
  }

  String _generarPlantillaTexto(IncidenciaData data) {
    final StringBuffer buffer = StringBuffer();

    List<String> fechaParts = data.fecha.split('/');
    int day = int.parse(fechaParts[0]);
    int month = int.parse(fechaParts[1]);
    int year = int.parse(fechaParts[2]);
    DateTime parsedDate = DateTime(year, month, day);

    String monthName = _getMonthName(parsedDate.month);
    String dayOfWeek = _getDayOfWeekName(parsedDate.weekday);
    final String horaDisplay = _formatTimeForDisplay(data.hora);
    String sentidoArrow = _getSentidoEmoji(data.sentido);
    String tiempoInspeccion = _calcularTiempoInspeccion(data.hora, data.horaBajadaFinal);

    if (data.tipoIncidencia == 'sin observaciones') {
      buffer.writeln('••• $dayOfWeek, ${parsedDate.day} $monthName  ||  $horaDisplay •••\n');
      buffer.writeln('🟢 Todo en Orden en la unidad\n');

      buffer.writeln('📚Padrón ${data.padron}');
      buffer.writeln('📚Conductor: ${data.operador}');
      buffer.writeln('📚Lugar: ${data.lugar} $sentidoArrow\n');

      buffer.writeln('*Tiempo en la unidad: $tiempoInspeccion*');

      if (data.lugarBajadaFinal != null && data.lugarBajadaFinal!.isNotEmpty) {
        buffer.writeln('Lugar de Bajada: ${data.lugarBajadaFinal}\n');
      } else {
        buffer.writeln('\n');
      }

    } else if (data.tipoIncidencia == 'incidencia del pasajero') {
      buffer.writeln('••• $dayOfWeek, ${parsedDate.day} $monthName  ||  $horaDisplay •••\n');

      buffer.writeln('⚫ Incidencia Encontrada\n');
      buffer.writeln('Del tipo: *${data.falta} [${data.cantidad}]*\n');

      if (data.reintegradoMontos.isNotEmpty) {
        double totalReintegrado = 0.0;
        for (String montoStr in data.reintegradoMontos) {
          try {
            double monto = double.parse(montoStr);
            buffer.writeln('C. Reintegro: S/. ${monto.toStringAsFixed(2)}');
            totalReintegrado += monto;
          } catch (e) {
            buffer.writeln('C. Reintegro: S/. $montoStr (Error en formato)');
            print('Error al parsear monto reintegrado: $montoStr. Error: $e');
          }
        }
        buffer.writeln('-----------------------------------------');
        buffer.writeln('Total Reintegrado: S/. ${totalReintegrado.toStringAsFixed(2)}\n');
      }

      buffer.writeln('📚Padrón ${data.padron}');
      buffer.writeln('📚Conductor: ${data.operador}');
      buffer.writeln('📚Lugar: ${data.lugar} $sentidoArrow\n');

      buffer.writeln('*Tiempo en la unidad: $tiempoInspeccion*');
      if (data.lugarBajadaFinal != null && data.lugarBajadaFinal!.isNotEmpty) {
        buffer.writeln('Lugar de Bajada: ${data.lugarBajadaFinal}\n');
      } else {
        buffer.writeln('\n');
      }

      if (data.usuariosAdicionales.isNotEmpty) {
        buffer.writeln('Detalles de los Usuarios:');
        for (int i = 0; i < data.usuariosAdicionales.length; i++) {
          final user = data.usuariosAdicionales[i];
          String dinero = user['dinero'] ?? '0.00';
          try {
            dinero = double.parse(dinero).toStringAsFixed(2);
          } catch (e) {
            print('Error al parsear dinero de usuario adicional: ${user['dinero']}. Error: $e');
          }
          buffer.writeln('👤Usuario${(i + 1).toString().padLeft(2, '0')}: (S/. $dinero) ${user['lugarSubida']} - ${user['lugarBajada']}');
        }
        buffer.writeln('');
      }

      if (data.observaciones.isNotEmpty) {
        buffer.writeln('Observaciones');
        for (int i = 0; i < data.observaciones.length; i++) {
          buffer.writeln('${i + 1}. ${data.observaciones[i]}');
        }
        buffer.writeln('');
      }

    } else {
      buffer.writeln('••• $dayOfWeek, ${parsedDate.day} $monthName  ||  $horaDisplay •••\n');

      buffer.writeln('📚Lugar: ${data.lugar} $sentidoArrow');
      buffer.writeln('📚Padrón: ${data.padron}');
      buffer.writeln('📚Conductor: ${data.operador}');
      buffer.writeln('📚Falta: *${data.falta} [${data.cantidad}]*\n');

      if (data.usuariosAdicionales.isNotEmpty) {
        buffer.writeln('Detalles de los Usuarios:');
        for (int i = 0; i < data.usuariosAdicionales.length; i++) {
          final user = data.usuariosAdicionales[i];
          String dinero = user['dinero'] ?? '0.00';
          try {
            dinero = double.parse(dinero).toStringAsFixed(2);
          } catch (e) {
            print('Error al parsear dinero de usuario adicional: ${user['dinero']}. Error: $e');
          }
          buffer.writeln('👤Usuario${(i + 1).toString().padLeft(2, '0')}: (S/. $dinero) ${user['lugarSubida']} - ${user['lugarBajada']}');
        }
        buffer.writeln('');
      }

      if (data.observaciones.isNotEmpty) {
        buffer.writeln('Observaciones');
        for (int i = 0; i < data.observaciones.length; i++) {
          buffer.writeln('${i + 1}. ${data.observaciones[i]}');
        }
        buffer.writeln('');
      }
    }

    buffer.writeln('\n👁‍🗨Inspector:');
    buffer.writeln('COD $_inspectorCode - $_inspectorName');

    return buffer.toString();
  }

  String _generarPlantillaSecundariaConductor(IncidenciaData data) {
    final StringBuffer buffer = StringBuffer();

    List<String> fechaParts = data.fecha.split('/');
    int day = int.parse(fechaParts[0]);
    int month = int.parse(fechaParts[1]);
    int year = int.parse(fechaParts[2]);
    DateTime parsedDate = DateTime(year, month, day);

    String monthName = _getMonthName(parsedDate.month);
    String dayOfWeek = _getDayOfWeekName(parsedDate.weekday);
    final String horaDisplay = _formatTimeForDisplay(data.hora);
    String sentidoArrow = _getSentidoEmoji(data.sentido);

    String tiempoInspeccion = _calcularTiempoInspeccion(data.hora, data.horaBajadaFinal);

    buffer.writeln('••• $dayOfWeek, ${parsedDate.day} $monthName  ||  $horaDisplay •••\n');
    buffer.writeln('🚨 *Incidencia Encontrada*\n');

    buffer.writeln('Del tipo: *${data.falta}*');
    buffer.writeln('📚Padrón ${data.padron}');
    buffer.writeln('📚Conductor: ${data.operador}');
    buffer.writeln('📚Lugar:  ${data.lugar} $sentidoArrow\n');

    if (data.horaBajadaFinal != null && data.horaBajadaFinal!.isNotEmpty) {
      buffer.writeln('Hora de Bajada: ${_formatTimeForDisplay(data.horaBajadaFinal!)}');
    }
    if (data.lugarBajadaFinal != null && data.lugarBajadaFinal!.isNotEmpty) {
      buffer.writeln('Lugar de Bajada: ${data.lugarBajadaFinal}');
    }
    buffer.writeln('\n');

    buffer.writeln('*Tiempo en la unidad: $tiempoInspeccion*');
    buffer.writeln('\n👁‍🗨Inspector:');
    buffer.writeln('COD $_inspectorCode - $_inspectorName');

    return buffer.toString();
  }

  Future<void> _saveReport(String fullText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> informesJson = prefs.getStringList('saved_reports') ?? [];

      final newReport = SavedReport(
        incidencia: widget.incidenciaData,
        fullText: fullText,
      );

      final String newReportJsonString = json.encode(newReport.toJson());
      informesJson.insert(0, newReportJsonString);

      await prefs.setStringList('saved_reports', informesJson);
      print('Informe principal guardado con éxito en SharedPreferences.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe principal guardado automáticamente.')),
      );
    } catch (e) {
      print('Error al guardar el informe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el informe: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoadingInspectorData) {
      return Scaffold(
        appBar: AppBar(title: Text('Cargando Informe...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de la Plantilla'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AbordarScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80.0,
            ),
            const SizedBox(height: 16),
            const Text(
              'Reporte creado exitosamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Plantilla Principal:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: double.infinity,
              child: SelectableText(
                _informeGeneradoPrincipal,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _informeGeneradoPrincipal));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plantilla principal copiada al portapapeles')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text(
                  'Copiar Plantilla Principal',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            if (widget.fromConductorIncidencia) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Plantilla Simplificada (Conductor):',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: double.infinity,
                child: SelectableText(
                  _informeGeneradoSecundarioConductor,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _informeGeneradoSecundarioConductor));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plantilla simplificada copiada al portapapeles')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text(
                    'Copiar Plantilla Simplificada',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AbordarScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  'Volver a Inicio',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}