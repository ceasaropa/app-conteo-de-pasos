import 'package:proyecto_imu_v1_2/utils/position_calculator.dart';

/// Ejemplo de uso del calculador de posición
class PositionCalculatorExample {
  /// Ejemplo básico con datos de prueba
  static void ejemploBasico() {
    print('=== Ejemplo de Calculador de Posición ===\n');

    // Datos de ejemplo: distancias en metros y ángulos en grados
    final distancias = [1.0, 0.8, 1.2, 0.9, 1.1];
    final angulos = [0.0, 45.0, 90.0, 135.0, 180.0];

    print('Datos de entrada:');
    print('Distancias: $distancias');
    print('Ángulos: $angulos\n');

    // Calcular recorrido usando el método simple
    final resultado = PositionCalculator.calcularRecorridoSimple(
      distancias,
      angulos,
    );

    print('Coordenadas calculadas:');
    print('X: ${resultado['x']}');
    print('Y: ${resultado['y']}\n');

    // Crear matriz para el método principal
    final matriz = [distancias, angulos];
    final recorrido = PositionCalculator.calcularRecorrido(matriz);

    // Obtener información adicional
    final posicionFinal = PositionCalculator.obtenerPosicionFinal(recorrido);
    final distanciaTotal = PositionCalculator.calcularDistanciaTotal(
      distancias,
    );

    print('Información del recorrido:');
    print(
      'Posición final: X=${posicionFinal['x']?.toStringAsFixed(2)}, Y=${posicionFinal['y']?.toStringAsFixed(2)}',
    );
    print(
      'Distancia desde origen: ${posicionFinal['distancia']?.toStringAsFixed(2)} m',
    );
    print('Distancia total recorrida: ${distanciaTotal.toStringAsFixed(2)} m');
  }

  /// Ejemplo simulando datos reales de pasos
  static void ejemploConDatosPasos() {
    print('\n=== Ejemplo con Datos de Pasos Simulados ===\n');

    // Simular datos de pasos como los que generaría ConteoPasosTexteando
    final distanciasPasos = [
      0.75,
      0.68,
      0.82,
      0.71,
      0.79,
      0.66,
      0.74,
    ]; // metros por paso
    final azimuthPasos = [15.0, 25.0, 10.0, 350.0, 5.0, 20.0, 15.0]; // grados

    print('Datos de pasos simulados:');
    print('Longitudes de paso: $distanciasPasos');
    print('Azimuth por paso: $azimuthPasos\n');

    // Calcular recorrido
    final recorrido = PositionCalculator.calcularRecorrido([
      distanciasPasos,
      azimuthPasos,
    ]);
    final posicionFinal = PositionCalculator.obtenerPosicionFinal(recorrido);
    final distanciaTotal = PositionCalculator.calcularDistanciaTotal(
      distanciasPasos,
    );

    print('Resultados del recorrido:');
    for (int i = 0; i < distanciasPasos.length; i++) {
      print(
        'Paso ${i + 1}: X=${recorrido[0][i].toStringAsFixed(2)}, Y=${recorrido[1][i].toStringAsFixed(2)}',
      );
    }

    print('\nResumen:');
    print(
      'Posición final: X=${posicionFinal['x']?.toStringAsFixed(2)}, Y=${posicionFinal['y']?.toStringAsFixed(2)}',
    );
    print(
      'Distancia desde origen: ${posicionFinal['distancia']?.toStringAsFixed(2)} m',
    );
    print('Distancia total caminada: ${distanciaTotal.toStringAsFixed(2)} m');
    print(
      'Eficiencia de ruta: ${((posicionFinal['distancia'] ?? 0.0) / distanciaTotal * 100).toStringAsFixed(1)}%',
    );
  }

  /// Ejemplo con datos que contienen ceros (pasos filtrados)
  static void ejemploConDatosFiltrados() {
    print('\n=== Ejemplo con Datos Filtrados ===\n');

    // Datos con algunos valores en cero (pasos filtrados o no válidos)
    final distancias = [0.8, 0.0, 0.9, 0.0, 1.1, 0.7, 0.0, 0.85];
    final angulos = [30.0, 0.0, 60.0, 0.0, 90.0, 120.0, 0.0, 150.0];

    print('Datos con filtros (0 = paso no válido):');
    print('Distancias: $distancias');
    print('Ángulos: $angulos\n');

    final recorrido = PositionCalculator.calcularRecorrido([
      distancias,
      angulos,
    ]);
    final posicionFinal = PositionCalculator.obtenerPosicionFinal(recorrido);
    final distanciaTotal = PositionCalculator.calcularDistanciaTotal(
      distancias,
    );

    print('Coordenadas (solo pasos válidos):');
    for (int i = 0; i < distancias.length; i++) {
      if (distancias[i] != 0) {
        print(
          'Paso válido en índice $i: X=${recorrido[0][i].toStringAsFixed(2)}, Y=${recorrido[1][i].toStringAsFixed(2)}',
        );
      }
    }

    print('\nResultado final:');
    print(
      'Posición: X=${posicionFinal['x']?.toStringAsFixed(2)}, Y=${posicionFinal['y']?.toStringAsFixed(2)}',
    );
    print(
      'Distancia total (solo pasos válidos): ${distanciaTotal.toStringAsFixed(2)} m',
    );
  }
}
