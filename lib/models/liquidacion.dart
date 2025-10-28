class Liquidacion {
  final int id; // ID de la fila en la DB (opcional)
  final String fecha;
  final String nroPadron;
  final String nombreConductor;
  // ... y así sucesivamente para todos los campos de tu formulario

  Liquidacion({
    required this.id,
    required this.fecha,
    required this.nroPadron,
    required this.nombreConductor,
    // ...
  });

  // Un método para convertir el objeto a un Map (para insertarlo en la DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'nroPadron': nroPadron,
      'nombreConductor': nombreConductor,
      // ...
    };
  }

  // Un método para crear un objeto desde un Map (cuando lo lees de la DB)
  static Liquidacion fromMap(Map<String, dynamic> map) {
    return Liquidacion(
      id: map['id'],
      fecha: map['fecha'],
      nroPadron: map['nroPadron'],
      nombreConductor: map['nombreConductor'],
      // ...
    );
  }
}