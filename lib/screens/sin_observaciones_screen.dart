import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incidencia_data.dart';
import 'resultado_plantilla_screen.dart';
import 'anadir_nuevo_conductor_screen.dart';
import 'elegir_sentido_screen.dart'; // Importamos el nuevo selector de sentido

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

// Mantener SentidoOption y _sentidoOptions para compatibilidad si IncidenciaData aún los usa
// y para mapear el valor devuelto del selector a un SentidoOption.
class SentidoOption {
  final String text;
  final IconData icon;
  final String value;
  SentidoOption({required this.text, required this.icon, required this.value});
}

class SinObservacionesScreen extends StatefulWidget {
  final String fechaAbordaje;
  final String horaAbordaje;

  const SinObservacionesScreen({
    super.key,
    required this.fechaAbordaje,
    required this.horaAbordaje,
  });

  @override
  State<SinObservacionesScreen> createState() => _SinObservacionesScreenState();
}

class _SinObservacionesScreenState extends State<SinObservacionesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _padronController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();

  SentidoOption? _selectedSentidoOption;
  // Mantener _sentidoOptions para poder buscar la opción por su 'value'
  final List<SentidoOption> _sentidoOptions = [
    SentidoOption(text: 'Subiendo', icon: Icons.arrow_upward, value: 'subiendo'),
    SentidoOption(text: 'Bajando', icon: Icons.arrow_downward, value: 'bajando'),
  ];
  String? _sentidoErrorText;
  bool _showAddConductorButton = false;

  String _inspectorCod = 'N/A';
  String _inspectorName = 'Desconocido';

  @override
  void initState() {
    super.initState();
    _fechaController.text = widget.fechaAbordaje;
    _horaController.text = widget.horaAbordaje;
    _operadorController.addListener(_onOperadorTextChanged);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // AHORA LLAMAMOS A LA FUNCIÓN loadConductorList() DE incidencia_data.dart
    await loadConductorList();

    // Esta parte sigue necesitando SharedPreferences para los datos del inspector
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _inspectorCod = prefs.getString('codeInsp') ?? 'N/A';
      String? rawName = prefs.getString('nombre');
      if (rawName != null && rawName.isNotEmpty) {
        _inspectorName = rawName.split(' ').first.toUpperCase();
      } else {
        _inspectorName = 'Desconocido';
      }
    });
    print('SinObservacionesScreen: Inspector cargado - Código: $_inspectorCod - Nombre procesado: $_inspectorName');
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _padronController.dispose();
    _lugarController.dispose();
    _operadorController.removeListener(_onOperadorTextChanged);
    _operadorController.dispose();
    super.dispose();
  }

  void _onOperadorTextChanged() {
    if (_showAddConductorButton) {
      setState(() {
        _showAddConductorButton = false;
      });
    }
  }

  void _searchOperador() {
    String abreviatura = _operadorController.text.trim().toUpperCase();
    // AHORA accedemos a la variable global conductorLista directamente de incidencia_data.dart
    String? nombreCompleto = conductorLista[abreviatura];

    setState(() {
      _showAddConductorButton = false;
    });

    if (nombreCompleto != null) {
      setState(() {
        _operadorController.text = nombreCompleto.toUpperCase();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operador encontrado: $nombreCompleto'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abreviatura de operador no encontrada.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _showAddConductorButton = true;
      });
    }
  }

  void _navigateToAddConductor() async {
    final String abreviatura = _operadorController.text.trim().toUpperCase();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnadirNuevoConductorScreen(initialAbreviatura: abreviatura),
      ),
    );

    if (result != null && result is Map<String, String>) {
      final String newAbreviatura = result['abreviatura']!.toUpperCase();
      final String newNombreCompleto = result['nombreCompleto']!.toUpperCase();

      // AHORA modificamos la variable global conductorLista de incidencia_data.dart
      conductorLista[newAbreviatura] = newNombreCompleto;
      // Y llamamos a la función saveConductorList() de incidencia_data.dart
      await saveConductorList();

      print('Nuevo conductor añadido: $newNombreCompleto ($newAbreviatura)');

      setState(() {
        _operadorController.text = newNombreCompleto;
        _showAddConductorButton = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conductor $newNombreCompleto añadido y guardado.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- NUEVA FUNCIÓN PARA SELECCIONAR EL SENTIDO CON PANTALLA COMPLETA ---
  Future<void> _selectSentidoByFullScreenTap() async {
    final String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Usamos el nuevo widget ElegirSentidoScreen
        return const ElegirSentidoScreen();
      },
    );

    if (selectedValue != null) {
      setState(() {
        // Buscamos la SentidoOption correspondiente al valor devuelto
        _selectedSentidoOption = _sentidoOptions.firstWhere(
          (option) => option.value == selectedValue,
          orElse: () => _sentidoOptions.firstWhere((option) => option.value == 'subiendo'), // Fallback si no encuentra (no debería pasar)
        );
        _sentidoErrorText = null; // Limpiar el error si se selecciona
      });
    }
  }

  void _showLugarBajadaDialog() async {
    if (!_formKey.currentState!.validate()) {
      if (_selectedSentidoOption == null) {
        setState(() {
          _sentidoErrorText = 'Por favor, elige un sentido.';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos obligatorios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSentidoOption != null && _sentidoErrorText != null) {
      setState(() {
        _sentidoErrorText = null;
      });
    }

    final TextEditingController lugarBajadaDialogController = TextEditingController();
    final Map<String, String?>? dialogResult = await showDialog<Map<String, String?>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Lugar de Bajada'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Por favor, ingrese el lugar de bajada general:'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lugarBajadaDialogController,
                  decoration: const InputDecoration(
                    labelText: 'Lugar de Bajada',
                    hintText: 'Ej: Mercado Central, Paradero Final',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El lugar de bajada no puede estar vacío.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (lugarBajadaDialogController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('El lugar de bajada no puede estar vacío.'), backgroundColor: Colors.red),
                  );
                } else {
                  DateTime now = DateTime.now();
                  String currentHour = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                  Navigator.of(dialogContext).pop({
                    'lugar': lugarBajadaDialogController.text.trim(),
                    'hora': currentHour,
                  });
                }
              },
              child: const Text('Crear Plantilla'),
            ),
          ],
        );
      },
    );

    if (dialogResult != null && dialogResult['lugar'] != null) {
      _navigateToResultadoPlantilla(
        dialogResult['lugar']!,
        dialogResult['hora'],
      );
    }
    lugarBajadaDialogController.dispose();
  }

  void _navigateToResultadoPlantilla(String lugarBajadaFinal, String? horaBajadaFinal) {

    List<Map<String, String>> usuariosAdicionalesData = [];
    List<String> observacionesData = [];

    IncidenciaData incidenciaData = IncidenciaData(
      fecha: _fechaController.text,
      hora: _horaController.text,
      padron: _padronController.text,
      lugar: _lugarController.text,
      operador: _operadorController.text,
      sentido: _selectedSentidoOption!.value, // Asegúrate de que _selectedSentidoOption no sea nulo aquí
      falta: 'N/A',
      cantidad: 0,
      reintegradoMontos: [],
      usuariosAdicionales: usuariosAdicionalesData,
      observaciones: observacionesData,
      tipoIncidencia: 'sin observaciones',
      lugarBajadaFinal: lugarBajadaFinal,
      horaBajadaFinal: horaBajadaFinal,
      inspectorCod: _inspectorCod,
      inspectorName: _inspectorName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadoPlantillaScreen(incidenciaData: incidenciaData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte sin Observaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16), // Espacio después de "Hora"





              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lugarController,
                      decoration: const InputDecoration(
                        labelText: 'Lugar',
                        hintText: 'Ej: Av. Brasil, Parada de bus',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el lugar.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // Espacio entre Lugar y Sentido
                  Expanded(
                child: Column( // Envuelve el botón y el texto de error en una columna para que el error se muestre debajo
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _selectSentidoByFullScreenTap, // Sigue llamando a la misma función
                      icon: _selectedSentidoOption?.icon != null // Muestra el icono del sentido seleccionado o un icono predeterminado
                          ? Icon(_selectedSentidoOption!.icon)
                          : const Icon(Icons.alt_route),
                      label: Text(
                        _selectedSentidoOption?.text ?? 'Elegir Sentido', // Muestra el texto del sentido o un placeholder
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50), // Hace que el botón ocupe casi todo el ancho disponible y tenga una altura decente
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Bordes redondeados
                          side: BorderSide(
                            color: _sentidoErrorText != null ? Colors.red : Theme.of(context).colorScheme.primary, // Borde rojo si hay error
                            width: _sentidoErrorText != null ? 2.0 : 1.0,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.surface, // Un color de fondo que se vea bien en un 'botón de entrada'
                        foregroundColor: Theme.of(context).colorScheme.onSurface, // Color del texto e icono
                        alignment: Alignment.centerLeft, // Alinea el contenido a la izquierda
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    if (_sentidoErrorText != null) // Muestra el texto de error si existe
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          _sentidoErrorText!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),




                ],
              ),
              const SizedBox(height: 16), // Espacio antes de "Padrón"
              TextFormField(
                controller: _padronController,
                decoration: const InputDecoration(
                  labelText: 'Padrón',
                  hintText: 'Ingrese el número de padrón',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bus),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el padrón.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _operadorController,
                      decoration: const InputDecoration(
                        labelText: 'Operador',
                        hintText: 'Coloque el DNI del operador',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(40)
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el operador.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _showAddConductorButton
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: _navigateToAddConductor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            child: const Text('Añadir', style: TextStyle(fontSize: 16)),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, size: 30),
                          onPressed: _searchOperador,
                          tooltip: 'Buscar Operador',
                        ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showLugarBajadaDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Crear Plantilla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}