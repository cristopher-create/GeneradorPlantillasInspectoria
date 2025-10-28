// Archivo: lib/services/database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Importa tus modelos de datos
import '../models/inspector.dart';
import '../models/conductor.dart';
import '../models/tipo_falta.dart'; // ¡Nombre de archivo y clase actualizados!
import '../models/guia_control_inspectores.dart';

// Importa el archivo de datos de prueba
import '../data/mock_data.dart';

// Esta clase es un Singleton para manejar la base de datos
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Usa un getter para obtener la instancia de la base de datos.
  // Si la base de datos no existe, la inicializa.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDb() async {
    // Obtiene la ruta del directorio de documentos de la aplicación
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'liquidaciones.db');
    print('Ruta de la base de datos: $path');

    // Abre la base de datos.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Opcional, para manejar actualizaciones de la DB
    );
  }

  // Crea las tablas de la base de datos y añade los datos de prueba
  Future _onCreate(Database db, int version) async {
    // Crea la tabla de Inspectores (CON LA COLUMNA `contrasena` ELIMINADA)
    await db.execute('''
      CREATE TABLE Inspectores (
        idInspector TEXT PRIMARY KEY,
        codeInsp TEXT NOT NULL,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        paradero TEXT,
        fechaRegistro TEXT
      )
    ''');
    print('Tabla Inspectores creada.');

    // Crea la tabla de Conductores
    await db.execute('''
      CREATE TABLE Conductores (
        idConductor REAL PRIMARY KEY,
        nombres TEXT NOT NULL,
        apellidos TEXT NOT NULL
      )
    ''');
    print('Tabla Conductores creada.');

    // Crea la tabla de Faltas
    await db.execute('''
      CREATE TABLE Faltas (
        idFalta TEXT PRIMARY KEY,
        nomFalta TEXT NOT NULL,
        TipoReporte TEXT NOT NULL
      )
    ''');
    print('Tabla Faltas creada.');

    // Crea la tabla de GuiaControlInspectores
    await db.execute('''
      CREATE TABLE GuiaControlInspectores (
        idGuia TEXT PRIMARY KEY,
        idInspector TEXT NOT NULL,
        fecha TEXT NOT NULL,
        padron REAL NOT NULL,
        idConductor REAL,
        horaAborde TEXT,
        LugarAborde TEXT,
        horaBajada TEXT,
        lugarBajada TEXT,
        cod1sol TEXT,
        cod1_50sol TEXT,
        cod2soles TEXT,
        cod2_50soles TEXT,
        cod3soles TEXT,
        cod4soles TEXT,
        cod5soles TEXT,
        FOREIGN KEY (idInspector) REFERENCES Inspectores(idInspector),
        FOREIGN KEY (padron) REFERENCES Unidad(padron),
        FOREIGN KEY (idConductor) REFERENCES Conductores(idConductor)
      )
    ''');
    print('Tabla GuiaControlInspectores creada.');

    // Nota: La tabla 'Unidad' debe existir para que la FK funcione.
    // Si no la tienes, es posible que el onCreate falle.
    // Si es así, crea la tabla de Unidad aquí también.

    // ==========================================================
    // Añadir datos de prueba al crearse la base de datos
    // ==========================================================
    print('Insertando datos de prueba...');

    // Insertar Inspectores
    for (var inspector in mockInspectores) {
      await db.insert('Inspectores', inspector.toMap());
    }

    // Insertar Conductores
    for (var conductor in mockConductores) {
      await db.insert('Conductores', conductor.toMap());
    }

    // Insertar Faltas
    for (var falta in mockFaltas) {
      await db.insert('Faltas', falta.toMap());
    }

    print('Datos de prueba insertados con éxito.');
  }

  // ==========================================================
  // Métodos CRUD para la tabla de Inspectores
  // ==========================================================

  // Crea un nuevo inspector
  Future<int> insertInspector(Inspector inspector) async {
    final db = await database;
    return await db.insert('Inspectores', inspector.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lee todos los inspectores
  Future<List<Inspector>> getInspectores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Inspectores');
    return List.generate(maps.length, (i) => Inspector.fromMap(maps[i]));
  }

  // Lee un inspector por su ID
  Future<Inspector?> getInspectorById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Inspectores', where: 'idInspector = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Inspector.fromMap(maps.first);
    }
    return null;
  }
  
  // Actualiza un inspector
  Future<int> updateInspector(Inspector inspector) async {
    final db = await database;
    return await db.update('Inspectores', inspector.toMap(), where: 'idInspector = ?', whereArgs: [inspector.idInspector]);
  }

  // Elimina un inspector
  Future<int> deleteInspector(String id) async {
    final db = await database;
    return await db.delete('Inspectores', where: 'idInspector = ?', whereArgs: [id]);
  }
  
  // ==========================================================
  // Métodos CRUD para la tabla de Conductores
  // ==========================================================
  
  // Crea un nuevo conductor
  Future<int> insertConductor(Conductor conductor) async {
    final db = await database;
    return await db.insert('Conductores', conductor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lee todos los conductores
  Future<List<Conductor>> getConductores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Conductores');
    return List.generate(maps.length, (i) => Conductor.fromMap(maps[i]));
  }

  // Lee un conductor por su ID
  Future<Conductor?> getConductorById(double id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Conductores', where: 'idConductor = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Conductor.fromMap(maps.first);
    }
    return null;
  }
  
  // Actualiza un conductor
  Future<int> updateConductor(Conductor conductor) async {
    final db = await database;
    return await db.update('Conductores', conductor.toMap(), where: 'idConductor = ?', whereArgs: [conductor.idConductor]);
  }

  // Elimina un conductor
  Future<int> deleteConductor(double id) async {
    final db = await database;
    return await db.delete('Conductores', where: 'idConductor = ?', whereArgs: [id]);
  }
  
  // ==========================================================
  // Métodos CRUD para la tabla de Tipos de Faltas
  // ==========================================================
  
  // Crea un nuevo tipo de falta
  Future<int> insertTipoFalta(TipoFalta falta) async {
    final db = await database;
    return await db.insert('Faltas', falta.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lee todos los tipos de falta
  Future<List<TipoFalta>> getTiposFalta() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Faltas');
    return List.generate(maps.length, (i) => TipoFalta.fromMap(maps[i]));
  }

  // Lee un tipo de falta por su ID
  Future<TipoFalta?> getTipoFaltaById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Faltas', where: 'idFalta = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return TipoFalta.fromMap(maps.first);
    }
    return null;
  }
  
  // Actualiza un tipo de falta
  Future<int> updateTipoFalta(TipoFalta falta) async {
    final db = await database;
    return await db.update('Faltas', falta.toMap(), where: 'idFalta = ?', whereArgs: [falta.idFalta]);
  }

  // Elimina un tipo de falta
  Future<int> deleteTipoFalta(String id) async {
    final db = await database;
    return await db.delete('Faltas', where: 'idFalta = ?', whereArgs: [id]);
  }
  
  // ==========================================================
  // Métodos CRUD para la tabla de GuiaControlInspectores
  // ==========================================================
  
  // Crea una nueva GuiaControlInspectores
  Future<int> insertGuiaControlInspectores(GuiaControlInspectores guia) async {
    final db = await database;
    return await db.insert('GuiaControlInspectores', guia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lee todas las GuiaControlInspectores
  Future<List<GuiaControlInspectores>> getGuiasControlInspectores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('GuiaControlInspectores');
    return List.generate(maps.length, (i) => GuiaControlInspectores.fromMap(maps[i]));
  }

  // Lee una guia por su ID
  Future<GuiaControlInspectores?> getGuiaControlInspectoresById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('GuiaControlInspectores', where: 'idGuia = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return GuiaControlInspectores.fromMap(maps.first);
    }
    return null;
  }
  
  // Actualiza una guia
  Future<int> updateGuiaControlInspectores(GuiaControlInspectores guia) async {
    final db = await database;
    return await db.update('GuiaControlInspectores', guia.toMap(), where: 'idGuia = ?', whereArgs: [guia.idGuia]);
  }

  // Elimina una guia
  Future<int> deleteGuiaControlInspectores(String id) async {
    final db = await database;
    return await db.delete('GuiaControlInspectores', where: 'idGuia = ?', whereArgs: [id]);
  }

  // ==========================================================
  // Métodos adicionales útiles
  // ==========================================================

  // Elimina la base de datos completa. Útil para desarrollo/testing
  Future<void> deleteDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'liquidaciones.db');
    await deleteDatabase(path);
    _database = null; // Reinicia la instancia de la base de datos
    print('Base de datos eliminada.');
  }
}