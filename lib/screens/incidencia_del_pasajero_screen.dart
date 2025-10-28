import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/incidencia_data.dart';
import 'resultado_plantilla_screen.dart';
import 'add_conductor_screen.dart';
import 'elegir_sentido_screen.dart'; // Importa la pantalla ElegirSentidoScreen

class SentidoOption {
  final String text;
  final IconData icon;
  final String value;

  SentidoOption({required this.text, required this.icon, required this.value});
}

class IncidenciaDelPasajeroScreen extends StatefulWidget {
  final String? fechaInicial;
  final String? horaInicial;

  const IncidenciaDelPasajeroScreen({
    super.key,
    this.fechaInicial,
    this.horaInicial,
  });

  @override
  State<IncidenciaDelPasajeroScreen> createState() => _IncidenciaDelPasajeroScreenState();
}

class _IncidenciaDelPasajeroScreenState extends State<IncidenciaDelPasajeroScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _padronController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();

  String? _selectedSentidoValue; // Almacenará 'subiendo' o 'bajando'
  SentidoOption? _selectedSentidoOption; // Almacenará el objeto SentidoOption completo

  final List<SentidoOption> _sentidoOptions = [
    SentidoOption(text: 'Subiendo', icon: Icons.arrow_upward, value: 'subiendo'),
    SentidoOption(text: 'Bajando', icon: Icons.arrow_downward, value: 'bajando'),
  ];

  String? _selectedTipoReporte;
  final List<String> _tipoReporteOptions = [
    'Pasajero Vivo',
    'Reintegro',
  ];

  int? _selectedCantidad;
  final List<int> _cantidadOptions = List<int>.generate(10, (i) => i + 1);

  List<TextEditingController> _reintegradoControllers = [];

  bool _showAddConductorButton = false;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _setInitialDateTime();
    _operadorController.addListener(_onOperadorTextChanged);
    loadConductorList().then((_) {});
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _padronController.dispose();
    _lugarController.dispose();
    _operadorController.removeListener(_onOperadorTextChanged);
    _operadorController.dispose();
    for (var controller in _reintegradoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOperadorTextChanged() {
    if (_showAddConductorButton) {
      setState(() {
        _showAddConductorButton = false;
      });
    }
  }

  void _setInitialDateTime() {
    _fechaController.text = widget.fechaInicial ?? "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";
    _horaController.text = widget.horaInicial ?? "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
  }

  void _searchOperador() {
    String abreviatura = _operadorController.text.trim().toUpperCase();
    String? nombreCompleto = conductorLista[abreviatura];

    setState(() {
      _showAddConductorButton = false;
    });

    if (nombreCompleto != null) {
      setState(() {
        _operadorController.text = nombreCompleto;
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
        builder: (context) => AddConductorScreen(initialAbreviatura: abreviatura),
      ),
    );

    if (result != null && result is Map<String, String>) {
      final String newAbreviatura = result['abreviatura']!;
      final String newNombreCompleto = result['nombreCompleto']!;

      conductorLista[newAbreviatura] = newNombreCompleto;
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

  void _updateReintegradoControllers() {
    if (_selectedCantidad != null) {
      if (_reintegradoControllers.length > _selectedCantidad!) {
        for (int i = _selectedCantidad!; i < _reintegradoControllers.length; i++) {
          _reintegradoControllers[i].dispose();
        }
        _reintegradoControllers = _reintegradoControllers.sublist(0, _selectedCantidad!);
      }
      while (_reintegradoControllers.length < _selectedCantidad!) {
        _reintegradoControllers.add(TextEditingController());
      }
    } else {
      for (var controller in _reintegradoControllers) {
        controller.dispose();
      }
      _reintegradoControllers.clear();
    }
  }

  void _showLugarBajadaDialog() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, rellene todos los campos obligatorios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
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
                      return 'Este campo no puede estar vacío.';
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
                  // No se necesita validate aquí, el validator del TextFormField ya se encarga.
                  // Solo no hacemos pop si está vacío.
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

  // --- Nueva función para abrir el diálogo de Sentido ---
  void _navigateToSentidoSelector() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const ElegirSentidoScreen();
      },
    );

    if (result != null) {
      setState(() {
        _selectedSentidoValue = result;
        // Encuentra el SentidoOption correspondiente al valor devuelto
        _selectedSentidoOption = _sentidoOptions.firstWhere(
          (option) => option.value == _selectedSentidoValue,
          orElse: () => _sentidoOptions[0], // Fallback a 'Subiendo' si no se encuentra (no debería pasar)
        );
      });
    }
  }

  void _navigateToResultadoPlantilla(String lugarBajadaFinal, String? horaBajadaFinal) {
    List<String> reintegradoMontos = [];

    if (_selectedCantidad != null && _selectedCantidad! > 0) {
      reintegradoMontos = _reintegradoControllers.map((controller) => controller.text).toList();
    }

    IncidenciaData incidenciaData = IncidenciaData(
      fecha: _fechaController.text,
      hora: _horaController.text,
      padron: _padronController.text,
      lugar: _lugarController.text,
      operador: _operadorController.text,
      sentido: _selectedSentidoOption!.value, // Aseguramos que _selectedSentidoOption no sea null por la validación
      falta: _selectedTipoReporte!,
      cantidad: _selectedCantidad ?? 0,
      usuariosAdicionales: const [],
      observaciones: const [],
      tipoIncidencia: 'incidencia del pasajero',
      lugarBajadaFinal: lugarBajadaFinal,
      horaBajadaFinal: horaBajadaFinal,
      reintegradoMontos: reintegradoMontos,
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
        title: const Text('Incidencia del Pasajero'),
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
          autovalidateMode: _autovalidateMode,
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
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea los elementos en la parte superior
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
                        if (value == null || value.trim().isEmpty) {
                          return 'El lugar no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Espacio entre el TextFormField y el botón
                  SizedBox( // Puedes ajustar el width o quitarlo para que el botón se ajuste al contenido
                    width: 150, // Ejemplo: Ajusta este ancho según necesites
                    child: Column( // Envuelve el botón y su validación en una columna
                      children: [
                        ElevatedButton.icon(
                          onPressed: _navigateToSentidoSelector,
                          icon: Icon(_selectedSentidoOption?.icon ?? Icons.alt_route),
                          label: FittedBox( // Usa FittedBox para que el texto se ajuste si es muy largo
                            fit: BoxFit.scaleDown,
                            child: Text(_selectedSentidoOption?.text ?? 'Sentido'),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // Ajusta la altura si es necesario
                            alignment: Alignment.center, // Centra el contenido dentro del botón
                            padding: const EdgeInsets.symmetric(horizontal: 8), // Padding interno del botón
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedSentidoOption == null && _autovalidateMode == AutovalidateMode.always
                                    ? Colors.red
                                    : Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        if (_selectedSentidoOption == null && _autovalidateMode == AutovalidateMode.always)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0), // Ajusta el padding para que esté cerca del botón
                            child: Text(
                              'Seleccione sentido.', // Mensaje más corto para espacio reducido
                              style: TextStyle(color: Colors.red, fontSize: 10), // Fuente más pequeña
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                  if (value == null || value.trim().isEmpty) {
                    return 'El padrón no puede estar vacío.';
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
                        LengthLimitingTextInputFormatter(40),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El operador no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search, size: 30),
                    onPressed: _searchOperador,
                    tooltip: 'Buscar operador',
                  ),
                  if (_showAddConductorButton)
                    Padding(
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
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTipoReporte,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Reporte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                hint: const Text('Selecciona el tipo de reporte'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTipoReporte = newValue;
                  });
                },
                items: _tipoReporteOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione el tipo de reporte.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCantidad,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                hint: const Text('Selecciona la cantidad'),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCantidad = newValue;
                    _updateReintegradoControllers();
                  });
                },
                items: _cantidadOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione la cantidad.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedCantidad != null && _selectedCantidad! > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Montos de C. Reintegrado:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ..._reintegradoControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'C. Reintegrado ${index + 1} (Soles)',
                            hintText: 'Ej: 5.50',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El monto no puede estar vacío.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingrese un monto numérico válido.';
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showLugarBajadaDialog,
                child: const Text('Crear Plantilla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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