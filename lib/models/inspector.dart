// Archivo: lib/models/inspector.dart

class Inspector {
  final String idInspector;
  final String codeInsp;
  final String nombre;
  final String apellido;
  final String? paradero;
  final String? fechaRegistro;

  Inspector({
    required this.idInspector,
    required this.codeInsp,
    required this.nombre,
    required this.apellido,
    this.paradero,
    this.fechaRegistro,
  });

  // Constructor factory para crear un objeto Inspector desde un Map.
  factory Inspector.fromMap(Map<String, dynamic> map) {
    return Inspector(
      idInspector: map['idInspector'] as String,
      codeInsp: map['codeInsp'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      paradero: map['paradero'] as String?,
      fechaRegistro: map['fechaRegistro'] as String?,
    );
  }

  // Método para convertir un objeto Inspector a un Map.
  Map<String, dynamic> toMap() {
    return {
      'idInspector': idInspector,
      'codeInsp': codeInsp,
      'nombre': nombre,
      'apellido': apellido,
      'paradero': paradero,
      'fechaRegistro': fechaRegistro,
    };
  }
}