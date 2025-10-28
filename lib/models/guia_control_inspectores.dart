// Archivo: lib/models/guia_control_inspectores.dart

class GuiaControlInspectores {
  final String idGuia;
  final String idInspector;
  final String fecha;
  final double padron; // Tipo REAL en SQLite
  final double? idConductor; // Puede ser nulo
  final String? horaAborde; // Puede ser nulo
  final String? LugarAborde; // Puede ser nulo
  final String? horaBajada; // Puede ser nulo
  final String? lugarBajada; // Puede ser nulo
  final String? cod1sol; // Puede ser nulo
  final String? cod1_50sol; // Puede ser nulo
  final String? cod2soles; // Puede ser nulo
  final String? cod2_50soles; // Puede ser nulo
  final String? cod3soles; // Puede ser nulo
  final String? cod4soles; // Puede ser nulo
  final String? cod5soles; // Puede ser nulo

  GuiaControlInspectores({
    required this.idGuia,
    required this.idInspector,
    required this.fecha,
    required this.padron,
    this.idConductor,
    this.horaAborde,
    this.LugarAborde,
    this.horaBajada,
    this.lugarBajada,
    this.cod1sol,
    this.cod1_50sol,
    this.cod2soles,
    this.cod2_50soles,
    this.cod3soles,
    this.cod4soles,
    this.cod5soles,
  });

  // Constructor factory para crear un objeto GuiaControlInspectores desde un Map.
  factory GuiaControlInspectores.fromMap(Map<String, dynamic> map) {
    return GuiaControlInspectores(
      idGuia: map['idGuia'] as String,
      idInspector: map['idInspector'] as String,
      fecha: map['fecha'] as String,
      padron: map['padron'] as double,
      idConductor: map['idConductor'] as double?,
      horaAborde: map['horaAborde'] as String?,
      LugarAborde: map['LugarAborde'] as String?,
      horaBajada: map['horaBajada'] as String?,
      lugarBajada: map['lugarBajada'] as String?,
      cod1sol: map['cod1sol'] as String?,
      cod1_50sol: map['cod1_50sol'] as String?,
      cod2soles: map['cod2soles'] as String?,
      cod2_50soles: map['cod2_50soles'] as String?,
      cod3soles: map['cod3soles'] as String?,
      cod4soles: map['cod4soles'] as String?,
      cod5soles: map['cod5soles'] as String?,
    );
  }

  // Método para convertir un objeto GuiaControlInspectores a un Map.
  Map<String, dynamic> toMap() {
    return {
      'idGuia': idGuia,
      'idInspector': idInspector,
      'fecha': fecha,
      'padron': padron,
      'idConductor': idConductor,
      'horaAborde': horaAborde,
      'LugarAborde': LugarAborde,
      'horaBajada': horaBajada,
      'lugarBajada': lugarBajada,
      'cod1sol': cod1sol,
      'cod1_50sol': cod1_50sol,
      'cod2soles': cod2soles,
      'cod2_50soles': cod2_50soles,
      'cod3soles': cod3soles,
      'cod4soles': cod4soles,
      'cod5soles': cod5soles,
    };
  }
}