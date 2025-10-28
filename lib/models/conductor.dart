// Archivo: lib/models/conductor.dart

class Conductor {
  final double idConductor; // Usamos double para el tipo REAL de SQLite
  final String nombres;
  final String apellidos;

  Conductor({
    required this.idConductor,
    required this.nombres,
    required this.apellidos,
  });

  // Constructor factory para crear un objeto Conductor desde un Map (desde la base de datos).
  factory Conductor.fromMap(Map<String, dynamic> map) {
    return Conductor(
      idConductor: map['idConductor'] as double,
      nombres: map['nombres'] as String,
      apellidos: map['apellidos'] as String,
    );
  }

  // Método para convertir un objeto Conductor a un Map (para insertarlo o actualizarlo en la base de datos).
  Map<String, dynamic> toMap() {
    return {
      'idConductor': idConductor,
      'nombres': nombres,
      'apellidos': apellidos,
    };
  }
}