import 'dart:math';

/// Utilidad para calcular el recorrido de posiciones basado en distancias y ángulos
/// Convierte coordenadas polares a cartesianas y acumula la posición
class PositionCalculator {
  /// Calcula el recorrido de las distancias y los ángulos
  ///
  /// [dydUnidas] Matriz de 2 filas donde:
  /// - Fila 0: Distancias de cada paso
  /// - Fila 1: Ángulos/azimuth en grados
  ///
  /// Retorna matriz de 2 filas con:
  /// - Fila 0: Coordenadas X acumuladas
  /// - Fila 1: Coordenadas Y acumuladas
  static List<List<double>> calcularRecorrido(List<List<double>> dydUnidas) {
    if (dydUnidas.isEmpty || dydUnidas.length < 2 || dydUnidas[0].isEmpty) {
      return [[], []]; // Retornar matriz vacía si los datos no son válidos
    }

    final int length = dydUnidas[0].length;

    // Matriz para almacenar coordenadas X e Y
    List<List<double>> xy = List.generate(2, (_) => List.filled(length, 0.0));

    // Array para almacenar ángulos en radianes
    List<double> theta = List.filled(length, 0.0);

    // Paso directamente la primera distancia y el primer azimuth
    xy[0][0] = dydUnidas[0][0]; // Primera distancia
    xy[1][0] = dydUnidas[1][0]; // Primer azimuth

    int contCiclos = 1;

    // Filtrar valores no cero y copiar a la matriz de trabajo
    for (int n = 1; n < length; n++) {
      if (dydUnidas[0][n] != 0) {
        xy[0][contCiclos] = dydUnidas[0][n];
        xy[1][contCiclos] = dydUnidas[1][n]; // Sin restar el primer azimuth
        contCiclos++;
      }
    }

    // Convertir de coordenadas polares a cartesianas
    for (int n = 0; n < length; n++) {
      // Convertir grados a radianes
      theta[n] = xy[1][n] * pi / 180;

      // Guardar distancia temporal
      double rAux = xy[0][n];

      // Calcular coordenadas cartesianas
      xy[0][n] = (-1) * rAux * cos(theta[n]); // Valores de X
      xy[1][n] = rAux * sin(theta[n]); // Valores de Y
    }

    // Acumular posiciones para obtener el recorrido total
    for (int n = 1; n < length; n++) {
      if (xy[0][n] != 0) {
        xy[0][n] = xy[0][n] + xy[0][n - 1]; // X acumulada
        xy[1][n] = xy[1][n] + xy[1][n - 1]; // Y acumulada
      }
    }

    return xy;
  }

  /// Versión simplificada que acepta listas separadas de distancias y ángulos
  ///
  /// [distancias] Lista de distancias de cada paso
  /// [angulos] Lista de ángulos/azimuth en grados
  ///
  /// Retorna un Map con las coordenadas:
  /// - 'x': Lista de coordenadas X acumuladas
  /// - 'y': Lista de coordenadas Y acumuladas
  static Map<String, List<double>> calcularRecorridoSimple(
    List<double> distancias,
    List<double> angulos,
  ) {
    if (distancias.isEmpty ||
        angulos.isEmpty ||
        distancias.length != angulos.length) {
      return {'x': <double>[], 'y': <double>[]};
    }

    // Crear matriz temporal
    final dydUnidas = [
      List<double>.from(distancias),
      List<double>.from(angulos),
    ];

    // Calcular recorrido
    final resultado = calcularRecorrido(dydUnidas);

    return {'x': resultado[0], 'y': resultado[1]};
  }

  /// Calcula la distancia total recorrida
  ///
  /// [distancias] Lista de distancias de cada paso
  ///
  /// Retorna la suma total de distancias válidas (no cero)
  static double calcularDistanciaTotal(List<double> distancias) {
    double total = 0.0;
    for (double distancia in distancias) {
      if (distancia != 0) {
        total += distancia;
      }
    }
    return total;
  }

  /// Obtiene la posición final del recorrido
  ///
  /// [recorrido] Resultado de calcularRecorrido()
  ///
  /// Retorna un Map con la posición final:
  /// - 'x': Coordenada X final
  /// - 'y': Coordenada Y final
  /// - 'distancia': Distancia desde el origen
  static Map<String, double> obtenerPosicionFinal(
    List<List<double>> recorrido,
  ) {
    if (recorrido.isEmpty || recorrido[0].isEmpty || recorrido[1].isEmpty) {
      return {'x': 0.0, 'y': 0.0, 'distancia': 0.0};
    }

    // Encontrar la última posición válida (no cero)
    double xFinal = 0.0;
    double yFinal = 0.0;

    for (int i = recorrido[0].length - 1; i >= 0; i--) {
      if (recorrido[0][i] != 0 || recorrido[1][i] != 0) {
        xFinal = recorrido[0][i];
        yFinal = recorrido[1][i];
        break;
      }
    }

    // Calcular distancia desde el origen
    double distanciaDesdeOrigen = sqrt(xFinal * xFinal + yFinal * yFinal);

    return {'x': xFinal, 'y': yFinal, 'distancia': distanciaDesdeOrigen};
  }
}
