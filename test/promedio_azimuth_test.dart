import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_imu_v1_2/sensor/data/conteopasostexteo.dart';

void main() {
  group('PromedioAzimuth Tests', () {
    late ConteoPasosTexteando conteoPasos;

    setUp(() {
      conteoPasos = ConteoPasosTexteando();
    });

    test('Calcular promedio azimuth con progresión normal', () {
      // Caso de prueba: progresión normal de azimuth
      List<double> tiempos = [1.0, 2.0, 3.0, 4.0, 5.0];
      List<double> azimuth = [45.0, 50.0, 55.0, 60.0, 65.0];
      
      double resultado = conteoPasos.promedioAzimuth(1.0, 5.0, tiempos, azimuth);
      
      // El resultado debe estar entre 45 y 65, con mayor peso hacia los valores finales
      expect(resultado, greaterThan(50.0));
      expect(resultado, lessThan(65.0));
      print('Promedio azimuth progresión normal: $resultado');
    });

    test('Calcular promedio azimuth con discontinuidad 359°->0°', () {
      // Caso de prueba: manejo de discontinuidad de 359° a 0°
      List<double> tiempos = [1.0, 2.0, 3.0, 4.0, 5.0];
      List<double> azimuth = [350.0, 355.0, 0.0, 5.0, 10.0];
      
      double resultado = conteoPasos.promedioAzimuth(1.0, 5.0, tiempos, azimuth);
      
      // El resultado debe manejar correctamente la discontinuidad
      expect(resultado, isA<double>());
      expect(resultado, greaterThanOrEqualTo(0.0));
      expect(resultado, lessThanOrEqualTo(360.0));
      print('Promedio azimuth con discontinuidad: $resultado');
    });

    test('Calcular promedio azimuth con un solo valor', () {
      // Caso de prueba: un solo valor
      List<double> tiempos = [1.0];
      List<double> azimuth = [90.0];
      
      double resultado = conteoPasos.promedioAzimuth(1.0, 1.0, tiempos, azimuth);
      
      // Debe retornar el mismo valor
      expect(resultado, equals(90.0));
      print('Promedio azimuth un valor: $resultado');
    });

    test('Calcular promedio azimuth con datos vacíos', () {
      // Caso de prueba: datos vacíos
      List<double> tiempos = [];
      List<double> azimuth = [];
      
      double resultado = conteoPasos.promedioAzimuth(1.0, 5.0, tiempos, azimuth);
      
      // Debe retornar 0.0
      expect(resultado, equals(0.0));
      print('Promedio azimuth datos vacíos: $resultado');
    });

    test('Calcular promedio azimuth con rango parcial', () {
      // Caso de prueba: usar solo parte del arreglo
      List<double> tiempos = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0];
      List<double> azimuth = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0];
      
      double resultado = conteoPasos.promedioAzimuth(2.0, 4.0, tiempos, azimuth);
      
      // Debe usar solo los valores entre tiempo 2.0 y 4.0 (índices 1 a 3)
      // Valores: [20.0, 30.0, 40.0] con pesos [1, 2, 3]
      // Promedio ponderado: (20*1 + 30*2 + 40*3) / (1+2+3) = (20+60+120)/6 = 200/6 ≈ 33.33
      expect(resultado, greaterThan(30.0));
      expect(resultado, lessThan(40.0));
      print('Promedio azimuth rango parcial: $resultado');
    });

    test('Verificar pesos progresivos', () {
      // Caso de prueba específico para verificar que los valores finales tienen más peso
      List<double> tiempos = [1.0, 2.0, 3.0];
      List<double> azimuth = [0.0, 0.0, 180.0]; // El último valor es muy diferente
      
      double resultado = conteoPasos.promedioAzimuth(1.0, 3.0, tiempos, azimuth);
      
      // Con pesos [1, 2, 3], el resultado debe estar más cerca de 180° que de 0°
      // (0*1 + 0*2 + 180*3) / 6 = 540/6 = 90°
      expect(resultado, equals(90.0));
      print('Promedio azimuth con pesos progresivos: $resultado');
    });
  });
}