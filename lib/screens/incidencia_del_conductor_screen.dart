import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/incidencia_data.dart';
import 'resultado_plantilla_screen.dart';
import 'add_conductor_screen.dart';
import 'elegir_sentido_screen.dart'; // Importa el selector de sentido

class UserInputControllers {
  final TextEditingController dineroController;
  final TextEditingController lugarSubidaController;
  final TextEditingController lugarBajadaController;

  UserInputControllers()
      : dineroController = TextEditingController(),
        lugarSubidaController = TextEditingController(),
        lugarBajadaController = TextEditingController();

  void dispose() {
    dineroController.dispose();
    lugarSubidaController.dispose();
    lugarBajadaController.dispose();
  }
}

class ObservationInputController {
  final TextEditingController textController;

  ObservationInputController() : textController = TextEditingController();

  void dispose() {
    textController.dispose();
  }
}

class IncidenciaDelConductorScreen extends StatefulWidget {
  final String? fechaInicial;
  final String? horaInicial;

  const IncidenciaDelConductorScreen({
    super.key,
    this.fechaInicial,
    this.horaInicial,
  });

  @override
  State<IncidenciaDelConductorScreen> createState() => _IncidenciaDelConductorScreenState();
}

class _IncidenciaDelConductorScreenState extends State<IncidenciaDelConductorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _padronController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _sentidoDisplayController = TextEditingController(); // Nuevo controller para mostrar el sentido

  bool _showAddConductorButton = false;

  String? _selectedSentidoValue; // Almacenará 'subiendo' o 'bajando'
  String? _selectedFalta;
  int? _selectedCantidad;

  final List<UserInputControllers> _addedUsers = [];
  final List<ObservationInputController> _addedObservations = [];

  // Eliminamos _sentidoOptions de aquí, ya que el FullScreenSentidoSelector las define
  /*
  final List<SentidoOption> _sentidoOptions = [
    SentidoOption(text: 'Subiendo', icon: Icons.arrow_upward, value: 'subiendo'),
    SentidoOption(text: 'Bajando', icon: Icons.arrow_downward, value: 'bajando'),
  ];
  */
  final List<String> _faltasOptions = [
    'Cobrar y no dar Boleto',
    'Dar boleto de Menor tarifa',
    'Reventa de Boletos',
  ];
  final List<int> _cantidadOptions = List<int>.generate(30, (i) => i + 1);

  String _inspectorCod = 'N/A';
  String _inspectorName = 'Desconocido';

  @override
  void initState() {
    super.initState();
    _setInitialDateTime();
    _operadorController.addListener(_onOperadorTextChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadConductorList();
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
  }

  void _onOperadorTextChanged() {
    setState(() {
      _showAddConductorButton = false;
    });
  }

  void _setInitialDateTime() {
    _fechaController.text = widget.fechaInicial ?? "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";
    _horaController.text = widget.horaInicial ?? "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
  }

  void _addAnotherUser() {
    setState(() {
      _addedUsers.add(UserInputControllers());
    });
  }

  void _removeUser(int index) {
    setState(() {
      _addedUsers[index].dispose();
      _addedUsers.removeAt(index);
    });
  }

  void _addObservation() {
    setState(() {
      _addedObservations.add(ObservationInputController());
    });
  }

  void _removeObservation(int index) {
    setState(() {
      _addedObservations[index].dispose();
      _addedObservations.removeAt(index);
    });
  }

  void _searchOperador() {
    String abreviatura = _operadorController.text.trim().toUpperCase();
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
        builder: (context) => AddConductorScreen(initialAbreviatura: abreviatura),
      ),
    );

    if (result != null && result is Map<String, String>) {
      final String newAbreviatura = result['abreviatura']!.toUpperCase();
      final String newNombreCompleto = result['nombreCompleto']!.toUpperCase();

      conductorLista[newAbreviatura] = newNombreCompleto;
      await saveConductorList();

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

  // Nueva función para mostrar el selector de sentido en pantalla completa
  void _showSentidoSelector() async {
    final String? selectedSentido = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const ElegirSentidoScreen();
      },
    );

    if (selectedSentido != null) {
      setState(() {
        _selectedSentidoValue = selectedSentido;
        // Actualiza el texto del controlador de display para que el usuario vea la selección
        _sentidoDisplayController.text = selectedSentido == 'subiendo' ? 'Subiendo' : 'Bajando';
      });
    }
  }

  void _showLugarBajadaDialog() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos requeridos correctamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Asegurarse de que el sentido esté seleccionado antes de continuar
    if (_selectedSentidoValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione el sentido.'),
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
                      return 'Este campo no puede estar vacío';
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
    List<Map<String, String>> usuariosAdicionalesData = _addedUsers.map((user) {
      return {
        'dinero': user.dineroController.text,
        'lugarSubida': user.lugarSubidaController.text,
        'lugarBajada': user.lugarBajadaController.text,
      };
    }).toList();

    List<String> observacionesData = _addedObservations.map((obs) => obs.textController.text).toList();

    IncidenciaData incidenciaData = IncidenciaData(
      fecha: _fechaController.text,
      hora: _horaController.text,
      padron: _padronController.text,
      lugar: _lugarController.text,
      sentido: _selectedSentidoValue!, // Usamos el valor directamente
      operador: _operadorController.text,
      falta: _selectedFalta!,
      cantidad: _selectedCantidad!,
      reintegradoMontos: [],
      usuariosAdicionales: usuariosAdicionalesData,
      observaciones: observacionesData,
      tipoIncidencia: 'incidencia del conductor',
      lugarBajadaFinal: lugarBajadaFinal,
      horaBajadaFinal: horaBajadaFinal,
      inspectorCod: _inspectorCod,
      inspectorName: _inspectorName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadoPlantillaScreen(
          incidenciaData: incidenciaData,
          fromConductorIncidencia: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _padronController.dispose();
    _lugarController.dispose();
    _operadorController.removeListener(_onOperadorTextChanged);
    _operadorController.dispose();
    _sentidoDisplayController.dispose(); // No olvides disponer el nuevo controller
    for (var userControllers in _addedUsers) {
      userControllers.dispose();
    }
    for (var obsController in _addedObservations) {
      obsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencia del Conductor'),
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
          autovalidateMode: AutovalidateMode.disabled,
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
                          return 'Por favor, ingrese el lugar.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Espacio entre el TextFormField y el botón de Sentido
                  SizedBox( // Envuelve el botón en un SizedBox para controlar su ancho
                    width: 150, // Ajusta este ancho según necesites (ejemplo: 150)
                    child: Column( // Envuelve el botón y su validación en una columna
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showSentidoSelector,
                          icon: Icon(_selectedSentidoValue == 'subiendo' ? Icons.arrow_upward : Icons.arrow_downward), // Cambia el icono según el sentido
                          label: FittedBox( // Usa FittedBox para que el texto se ajuste
                            fit: BoxFit.scaleDown,
                            child: Text(_selectedSentidoValue == 'subiendo' ? 'Subiendo' : (_selectedSentidoValue == 'bajando' ? 'Bajando' : 'Sentido')),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // Ajusta la altura si es necesario
                            alignment: Alignment.center, // Centra el contenido dentro del botón
                            padding: const EdgeInsets.symmetric(horizontal: 8), // Padding interno del botón
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedSentidoValue == null // Puedes usar _selectedSentidoValue para el color del borde si necesitas validación visual
                                    ? Colors.red // Ejemplo de color de borde para validación
                                    : Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        if (_selectedSentidoValue == null)
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
                    return 'Por favor, ingrese el padrón.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número de padrón válido.';
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
                          return 'Por favor, ingrese el DNI del operador.';
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
                          tooltip: 'Buscar operador',
                        ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFalta,
                decoration: const InputDecoration(
                  labelText: 'Elige un reporte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                hint: const Text('Selecciona una falta'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFalta = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione una falta.';
                  }
                  return null;
                },
                items: _faltasOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione la cantidad.';
                  }
                  return null;
                },
                items: _cantidadOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Column(
                children: _addedUsers.asMap().entries.map((entry) {
                  int index = entry.key;
                  UserInputControllers user = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Detalles de Usuario ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeUser(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: user.dineroController,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad de Dinero (Soles)',
                            hintText: 'Ej: 2.50 o 0.50',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese la cantidad de dinero.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ingrese un valor numérico válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: user.lugarSubidaController,
                          decoration: const InputDecoration(
                            labelText: 'Lugar de Subida',
                            hintText: 'Ej: Parada de bus, Calle ABC',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese el lugar de subida.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: user.lugarBajadaController,
                          decoration: const InputDecoration(
                            labelText: 'Lugar de Bajada (Destino)',
                            hintText: 'Ej: Plaza Central, Av. Principal',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese el lugar de bajada.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton.icon(
                onPressed: _addAnotherUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Añadir usuario'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Observaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: _addedObservations.asMap().entries.map((entry) {
                  int index = entry.key;
                  ObservationInputController obs = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Observación ${index + 1}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeObservation(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: obs.textController,
                          maxLines: 4,
                          maxLength: 250,
                          decoration: const InputDecoration(
                            labelText: 'Escribe tu observación aquí',
                            hintText: 'Máximo 250 caracteres',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          keyboardType: TextInputType.multiline,
                          buildCounter: (BuildContext context, {required int currentLength, required int? maxLength, required bool isFocused}) {
                            return Text(
                              '$currentLength/$maxLength caracteres',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                          validator: (value) {
                            if (value != null && value.length > 250) {
                              return 'Máximo 250 caracteres.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton.icon(
                onPressed: _addObservation,
                icon: const Icon(Icons.add_comment),
                label: const Text('Añadir observación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
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