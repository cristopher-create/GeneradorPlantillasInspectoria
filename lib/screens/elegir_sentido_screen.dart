import 'package:flutter/material.dart';

class ElegirSentidoScreen extends StatelessWidget {
  const ElegirSentidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // El diálogo ocupa toda la pantalla
      child: Column( // Usamos Column para dividir la pantalla verticalmente
        children: [
          // Mitad superior para "Subiendo"
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop('subiendo'); // Devuelve el valor al cerrar
              },
              child: Container(
                color: Colors.transparent, // Color transparente para que el hitbox sea invisible pero funcional
                alignment: Alignment.center, // Centra el contenido (el botón)
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho de la pantalla
                  height: 120, // 3.5 veces el tamaño actual (o el tamaño que hayas ajustado)
                  child: ElevatedButton.icon(
                    // onpressed del botón también para que se active al tocar el botón directamente
                    onPressed: () {
                      Navigator.of(context).pop('subiendo');
                    },
                    icon: const Icon(Icons.arrow_upward, size: 48), // Icono más grande
                    label: const Text('Subiendo', style: TextStyle(fontSize: 32)), // Texto más grande
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- INICIO DE LA LÍNEA DIVISORIA ---
          const Divider(
            height: 2, // Altura de la línea divisoria (grosor)
            thickness: 2, // Grosor real de la línea
            color: Colors.grey, // Color de la línea
            indent: 0, // Indentación desde el inicio (izquierda)
            endIndent: 0, // Indentación desde el final (derecha)
          ),
          // --- FIN DE LA LÍNEA DIVISORIA ---

          // Mitad inferior para "Bajando"
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop('bajando'); // Devuelve el valor al cerrar
              },
              child: Container(
                color: Colors.transparent, // Color transparente para el hitbox
                alignment: Alignment.center, // Centra el contenido (el botón)
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho de la pantalla
                  height: 120, // 3.5 veces el tamaño actual (o el tamaño que hayas ajustado)
                  child: ElevatedButton.icon(
                    // onpressed del botón también para que se active al tocar el botón directamente
                    onPressed: () {
                      Navigator.of(context).pop('bajando');
                    },
                    icon: const Icon(Icons.arrow_downward, size: 48), // Icono más grande
                    label: const Text('Bajando', style: TextStyle(fontSize: 32)), // Texto más grande
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}