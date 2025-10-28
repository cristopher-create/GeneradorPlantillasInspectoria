//incidencia_data.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IncidenciaData {
  final String fecha;
  final String hora;
  final String padron;
  final String lugar;
  final String operador;
  final String sentido;
  final String falta;
  final int cantidad;
  final List<Map<String, String>> usuariosAdicionales;
  final List<String> observaciones;
  final String tipoIncidencia;
  final String? lugarBajadaFinal;
  final String? horaBajadaFinal;
  final List<String> reintegradoMontos;
  final String? inspectorCod;
  final String? inspectorName;

  IncidenciaData({
    required this.fecha,
    required this.hora,
    required this.padron,
    required this.lugar,
    required this.operador,
    required this.sentido,
    required this.falta,
    required this.cantidad,
    this.usuariosAdicionales = const [],
    this.observaciones = const [],
    required this.tipoIncidencia,
    this.lugarBajadaFinal,
    this.horaBajadaFinal,
    this.reintegradoMontos = const [],
    this.inspectorCod,
    this.inspectorName,
  });

  IncidenciaData copyWith({
    String? fecha,
    String? hora,
    String? padron,
    String? lugar,
    String? operador,
    String? sentido,
    String? falta,
    int? cantidad,
    List<Map<String, String>>? usuariosAdicionales,
    List<String>? observaciones,
    String? tipoIncidencia,
    String? lugarBajadaFinal,
    String? horaBajadaFinal,
    List<String>? reintegradoMontos,
    String? inspectorCod,
    String? inspectorName,
  }) {
    return IncidenciaData(
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      padron: padron ?? this.padron,
      lugar: lugar ?? this.lugar,
      operador: operador ?? this.operador,
      sentido: sentido ?? this.sentido,
      falta: falta ?? this.falta,
      cantidad: cantidad ?? this.cantidad,
      usuariosAdicionales: usuariosAdicionales ?? this.usuariosAdicionales,
      observaciones: observaciones ?? this.observaciones,
      tipoIncidencia: tipoIncidencia ?? this.tipoIncidencia,
      lugarBajadaFinal: lugarBajadaFinal ?? this.lugarBajadaFinal,
      horaBajadaFinal: horaBajadaFinal ?? this.horaBajadaFinal,
      reintegradoMontos: reintegradoMontos ?? this.reintegradoMontos,
      inspectorCod: inspectorCod ?? this.inspectorCod,
      inspectorName: inspectorName ?? this.inspectorName,
    );
  }
}
Map<String, String> conductorLista = {
  '71379794': 'DE LA CRUZ CAÑAVI, DENNIS BRAYAN',
  '9245156': 'ABANTO PALOMINO, BRUNO ARNULFO',
  '10141449': 'ACEVEDO USCATA, CARLOS ALBERTO',
  '7164801': 'AGUADO GERONIMO, LUCIO LUIS',
  '41477943': 'AGUIRRE BARO, EDWIN',
  '44189643': 'ALANIA DIAZ, FREDDY',
  '71542016': 'ALARCON ARROYO, JORDAN BALTAZAR',
  '6033084': 'ALARCON CHAMPI, ANTONIO',
  '10672315': 'ALIAGA LAZARO, CARLOS HUMBERTO',
  '7513532': 'ALVAREZ RIVERA, MIGUEL ANGEL',
  '42551438': 'AMBROSIO CARLOS, JULIO',
  '10371407': 'APAZA TOQUE, RUBEN RICARDO',
  '2418841': 'ARANGUREN SILVA, OSWALDO ENRIQUE',
  '9654715': 'ARGUME PAUCAR, YURI EDWIN',
  '41195410': 'ARIAS QUISPE, JOSE LUIS',
  '44963676': 'ARRIETA CHACON, BLEQUER EDWIN',
  '44104849': 'ARROYO CUZCANO, CARLOS GUILLERMO',
  '18206519': 'ARROYO YNFANTES, CARLOS ALBERTO',
  '10117844': 'ARROYO INFANTES, JAIME ENRIQUE',
  '32904585': 'AZAÑA RAMIREZ, ROBERT',
  '43572924': 'BACALLA MARTEL, GEORGE HITLER',
  '43362324': 'BALLARDO CANO, ABNER CHARLLY',
  '10666670': 'BERNARDO COLLAZOS, WILLIAM YOLMER',
  '10359259': 'BRAVO AGUIRRE, CLIFFORD CALEB',
  '45942909': 'BRAVO SICCHA, ROGER NINO',
  '41807477': 'BRAVO SICCHA, ROY TEODORO',
  '9560923': 'BUSTILLOS BARRERA, VICTOR',
  '8157952': 'CANALES DEL AGUILA, JULIO EDUARDO',
  '80000855': 'CANTERAC TELLO, MARCO ANTONIO',
  '10578227': 'CARBONEL RODRIGUEZ, CESAR AUGUSTO',
  '46820006': 'CARDENAS SOTIL, JOSUE MANUEL',
  '43239642': 'CARDENAS LAGOS, TONY',
  '10163688': 'CASO HUARCAYA, JOSE ROBERTO',
  '45266385': 'CASTILLO HUANACO, SANTOS',
  '7974771': 'CASTRO VARGAS, MANUEL VICTOR',
  '42139271': 'CAYETANO BERNA, JUAN APOLONIO',
  '10435933': 'CCONOCHUILLCA CONCHA, SABINO',
  '41275731': 'CHAMORRO CABELLO, ANDRES YOEL',
  '45854541': 'CHIPANA MIRANDA, ANDERSON DARIO',
  '42342849': 'CHIPANA MIRANDA, EDSON JUVENAL',
  '10157963': 'CHIPANA MIRANDA, JORGE',
  '40384769': 'CHIPANA MIRANDA, ROLANDO EDER',
  '42398088': 'CHIPANA MIRANDA, RONAL',
  '42366835': 'CHIPANA MIRANDA, ZE CARLOS',
  '46668222': 'CHIPANA MIRANDA, IVAN',
  '9572744': 'CIUDAD MONSERRATE, JOSE LUIS',
  '45781159': 'CLAROS GARCIA, GEAN CARLOS',
  '44686087': 'COAGUILA DELGADO, MARCO ANTONIO',
  '9662919': 'COCHACHI SUNCHA, FELIX',
  '41061580': 'CONDEMAYTA USEDO, HUMBERTO',
  '46129084': 'CORDOVA PANTOJA, JOSE ENRIQUE',
  '10514210': 'CUSICUNA QUISPE, RICHARD',
  '20040418': 'CUYATTI CHAVEZ, JOSE LUIS',
  '46302068': 'DELGADO CUBAS, LUIS',
  '5734427': 'DIAZ MORALES, AMILCAR ANGEL',
  '46907761': 'DIAZ ORTIZ, ELGAR',
  '41179972': 'DIAZ SOLANO, MAX',
  '41391603': 'CHANG TENA, ERICK MANUEL',
  '8320119': 'EVARISTO VADILLO, JUAN',
  '45001700': 'FERNANDEZ RAMIREZ, LUIS ALBERTO',
  '41553199': 'FERRER HUANCAHUARE, ROLAND ROSSI',
  '8326276': 'FIGUEROA SANTA CRUZ, JULIO CESAR',
  '32932174': 'FLORES BASILIO, FILIBERTO ALEJANDRO',
  '41325901': 'GALVEZ MACHACUAY, JOEL RAFAEL',
  '43403399': 'GARCIA PONCE, JHAN FRANCO',
  '45282220': 'GONZALES PANIAGUA, JOSE NELSON',
  '8440602': 'GONZALEZ MAYORCA, IVAN GABRIEL',
  '3935402': 'MONTILLA OLIVEROS, HERNANDO JOSE',
  '45990729': 'HUALLPA QUISPE, TEOFILO ANGEL',
  '41231831': 'HUAMAN MALQUI, WILMER ARMANDO',
  '42818050': 'HUAMANI SAHUANAY, UBALDO JAVIER',
  '10511008': 'HUANCA MAMANI, JOSE FELICIANO',
  '44161897': 'HURTADO QUINTANA, ERIK FAVIO',
  '10691248': 'IBAÑEZ JIMENEZ, CHARLES ISAIAS',
  '45906941': 'IBAÑEZ JIMENEZ, WILMER SANTIAGO',
  '46898826': 'INOÑAN INOLOPU, JOSE MERCEDES',
  '44513332': 'JARA BLAZ, EZEQUEL',
  '70575674': 'JULIAN REYES, EVER GUSTAVO',
  '45290208': 'LAZARO CHAVEZ, GUILLERMO CESAR',
  '42599763': 'LAZARO CHAVEZ, JORGE ARMANDO',
  '8295182': 'LAZARO ORE, PRUDENCIO',
  '46008376': 'LINARES PACHAS, HOMAR ALEXANDER',
  '70848547': 'LLANOS MANDUJANO, EMERSON LEONIDAS',
  '10658452': 'LOPEZ SANCHEZ, ROLANDO CHALE',
  '45657184': 'MANRIQUE MIRANDA, MARCO ANTONIO',
  '9663815': 'MANSILLA MENDOZA, DAVID ALBERTO',
  '9102652': 'MANSILLA MENDOZA, JORGE LUIS',
  '9331630': 'MANCILLA MENDOZA, LUIS ALBERTO',
  '6709480': 'MANSILLA QUISPE, JESUS CALIXTO',
  '40745405': 'MARIN MARIN, ANGEL ARTURO',
  '4073276': 'MAYTA SURICHAQUI, ROBERTO ELOY',
  '4849741': 'MEJIA MONSALVE, LEONARDO JOSE',
  '40323971': 'MENDOZA ROJAS, BENITO ENRIQUE',
  '5528300': 'MODESTO DELGADO, JAVIER EDUARDO',
  '32973319': 'MOGOLLON BERMEO, DANNY ROBERTH',
  '16732024': 'MORETO LEYSEQUIA, LORENZO',
  '80000325': 'MOZO UÑAPILLCO, FLAVIO',
  '44946472': 'MUÑOZ TEJADA, HENRY JEAN',
  '40951538': 'MURGA ALBA, FRED MONER',
  '48360577': 'NAVARRO ALVAREZ, MARIO',
  '40052210': 'NAVARRO ANICAMA, DAVID ALEJANDRO',
  '9190058': 'NEYRA LOZANO, LUIS ALFREDO',
  '10351049': 'OBREGON ALVARADO, CESAR AUGUSTO',
  '40787289': 'OLAVE LAURENTE, JOSE LUIS',
  '42651728': 'OLIVARES ORTIZ, JOSE ALEJANDRO',
  '9651322': 'OLIVOS VALENCIA, ALFONSO',
  '42616721': 'ORELLANA CHUPAN, RUBEN STIP',
  '43122176': 'ORONCOY BUENO, MIGUEL ANGEL',
  '41653075': 'OSORIO FHON, LUIS DEMETRIO',
  '41150167': 'OSORIO FHON, MIGUEL ANGEL',
  '9962698': 'OSORIO SOTO, EDWARD ANGEL',
  '6874298': 'OSORIO VILLEGAS, DEMETRIO GREGORIO',
  '72754567': 'OYARCE ALVARADO, JORDAN ANDERSON',
  '44326217': 'PALACIOS AHUANARI, EMERSON DANIEL',
  '10113681': 'PAREDES FRANCISCO, WILMERS FERNANDO',
  '10671775': 'PAREDES MARTINEZ, EDGAR DAVID',
  '20652531': 'PAUCAR CUEVA, CAYETANO ALBERTO',
  '45418569': 'PEÑA MORALES, RITUAL',
  '10350208': 'PEREZ PRADO, ISMAEL ROLLY',
  '45703479': 'PILLCO PALLIN, ALEXANDER SANTIAGO',
  '42242422': 'POMALAZA SANCHEZ, ROLANDO JAVIER',
  '21083928': 'PORRAS VERASTEGUI, SIOMA OSWALDO',
  '44052575': 'POZO FLORES, ISMAEL LEONARDO',
  '44079216': 'PUMA MORALES, GINO ALBERTO',
  '43848097': 'QUEZADA DIESTRA, LUIS ALBERTO',
  '44201965': 'QUINTANA DELGADO, DARIO',
  '44245816': 'QUISPE ALCA, JUAN CARLOS',
  '10580787': 'QUISPE BERNACHEA, NEVARDO',
  '40561421': 'QUISPE LLAVE, RICARDO',
  '46068018': 'QUISPE LUCANO, GUSTAVO ALFREDO',
  '80229762': 'QUISPE MAMANI, MIGUEL ANGEL',
  '40180122': 'QUISPE OSORIO, DENNYS PERCY',
  '9570407': 'QUISPE RAMOS, MIGUEL FLORENCIO',
  '45337560': 'QUISPE ROJAS, MIGUEL ANTONY',
  '41078589': 'RAMIREZ CHAVEZ, JOSE ANTONIO',
  '43309135': 'RAMIREZ LUNA, ALFREDO RAUL',
  '44270697': 'RAMIREZ LUNA, ANGEL REYMUNDO',
  '10513274': 'RAMIREZ RODRIGUEZ, JHONNY FERNANDO',
  '41046257': 'RAMON ROMERO, HUGO CESAR',
  '41989233': 'RAMOS MASCIOTTI, RICARDO WASHINGTON',
  '40834500': 'RECSI ESTEBAN, RONALD',
  '43444759': 'REYES GABINO, JOSEPH NICANOR',
  '40605847': 'REYES GAVINO, FERNANDO',
  '10129348': 'REYES SANTIAGO, CLAUDIO AURELIO',
  '42652685': 'RIVERA PAJUELO, JUAN CARLOS',
  '43455658': 'RODRIGUEZ LEVANO, FERNANDO EDU',
  '7639373': 'ROJAS DORADO, PEDRO ANTONIO',
  '72626130': 'ROJAS ECHEVARRIA, LENIN ANTONIO',
  '42236954': 'ROJAS QUISPEALAYA, PERCY',
  '40055342': 'ROMERO ALARCON, JUAN CARLOS',
  '44383881': 'ROSAS QUISPE, WILFREDO ANTONIO',
  '40121959': 'SALCEDO GARCIA, LUIS HOMERO',
  '9429797': 'SALCEDO ZAGACETA, VICTOR CONRRADO',
  '18079428': 'SANCHEZ RODRIGUEZ, CARLOS ALBERTO',
  '10649578': 'SANTOS URRUTIA, ISAIAS',
  '7006902': 'SERRANO TOVAR, YONEY RAFAEL',
  '43551578': 'SHOLL RUBIN, ELVIS JHONNI',
  '41184151': 'SILVERA HOLGUINO, MARIO',
  '7365503': 'SOTO GUARDAMINO, PEDRO',
  '41445388': 'TAIPE BENITO, CARLOS',
  '43830524': 'TAIPE HUAMANI, SANTOS GUMERCINDO',
  '9983347': 'TAPAHUASCO TAYPE, ALEJANDRO',
  '4016415': 'TAPIA DIAZ, MARCO ANTONIO',
  '43809767': 'TAQUIRE REYNOSO, SANDRO CESAR',
  '40988866': 'TITO MONZON, NIELS RONALD',
  '41586479': 'TITO NOA, PEDRO RUI',
  '4411870': 'TORO DA COSTA, LENIN JOSE',
  '8313522': 'TRUJILLO INGA, ARNULFO',
  '10349541': 'VASQUEZ VELASQUEZ, JUAN',
  '40205692': 'VICTORIANO BAUTISTA, EDGAR YIMY',
  '40368187': 'VICTORIANO BUENDIA, RONY LUIS',
  '3024148': 'VILCHEZ PINTO, MARTIN RAMON',
  '18126556': 'VILLARROEL SALVATIERRA, LUIS',
  '10419640': 'YARASCA AYLAS, LOT ISAI',
  '44083336': 'ZAMUDIO SILVA, NANCY KATHERINE',
  '42448644': 'CONTRERAS VALLES, YASSER IVAN',
  '43123332': 'ESCALANTE CORAJE, PEPE FRANCO',
  '47275659': 'ATALAYA SALAS, NEANDER',
  '10771280': 'ALDANA MARQUEZ, LUIS ALBERTO',
  '10356921': 'VILLALVA VELASQUEZ, FRANKLIN'
};

Future<void> loadConductorList() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? storedListJson = prefs.getString('conductor_list');
    if (storedListJson != null && storedListJson.isNotEmpty) {
      final Map<String, dynamic> decodedList = json.decode(storedListJson);
      conductorLista = decodedList.map((key, value) => MapEntry(key, value.toString()));
      print('Lista de conductores cargada desde SharedPreferences.');
    } else {
      print('No se encontró lista de conductores guardada. Usando la lista predeterminada.');
      await saveConductorList();
    }
  } catch (e) {
    print('Error al cargar la lista de conductores: $e');
  }
}

Future<void> saveConductorList() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('conductor_list', json.encode(conductorLista));
    print('Lista de conductores guardada en SharedPreferences.');
  } catch (e) {
    print('Error al guardar la lista de conductores: $e');
  }
}