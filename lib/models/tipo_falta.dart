// Archivo: lib/models/tipo_falta.dart

class TipoFalta {
  final String idFalta;
  final String nomFalta;
  final String TipoReporte;

  TipoFalta({
    required this.idFalta,
    required this.nomFalta,
    required this.TipoReporte,
  });

  // Constructor factory para crear un objeto TipoFalta desde un Map (desde la base de datos).
  factory TipoFalta.fromMap(Map<String, dynamic> map) {
    return TipoFalta(
      idFalta: map['idFalta'] as String,
      nomFalta: map['nomFalta'] as String,
      TipoReporte: map['TipoReporte'] as String,
    );
  }

  // Método para convertir un objeto TipoFalta a un Map (para insertarlo o actualizarlo en la base de datos).
  Map<String, dynamic> toMap() {
    return {
      'idFalta': idFalta,
      'nomFalta': nomFalta,
      'TipoReporte': TipoReporte,
    };
  }
}