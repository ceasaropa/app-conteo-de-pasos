import 'package:test/test.dart';
import 'package:proyecto_imu_v1_2/sensor/data/sensor_processor.dart';
import 'package:proyecto_imu_v1_2/sensor/data/conteopasostexteo.dart';

void main() {
  group('Sensor Processor Stage 5 Optimization Tests', () {
    late DataProcessor processor;
    late ConteoPasosTexteando conteoPasos;

    setUp(() {
      processor = DataProcessor();
      conteoPasos = ConteoPasosTexteando();
    });

    test('Sensor processor creates 4-row matrizordenada with heading data', () {
      // Simular datos de sensores con heading values
      final sensorData = [
        [1.0, 0.5, 45.0], // magnitude, gyro, heading
        [1.2, 0.6, 47.0],
        [0.8, 0.4, 43.0],
        [1.1, 0.7, 46.0],
        [0.9, 0.3, 44.0],
      ];

      // Agregar suficientes datos para procesar una ventana completa
      for (int i = 0; i < 150; i++) {
        final dataIndex = i % sensorData.length;
        processor.addSensorData(
          sensorData[dataIndex][0], // magnitude
          sensorData[dataIndex][1], // gyro
          sensorData[dataIndex][2], // heading
        );
      }

      // Verificar que matrizordenada tiene 4 filas
      expect(processor.matrizordenada.length, equals(4));

      // Verificar que la cuarta fila contiene datos de heading filtrados
      if (processor.matrizordenada[3].isNotEmpty) {
        expect(
          processor.matrizordenada[3].every((value) => value >= 0),
          isTrue,
        );
        print('✓ matrizordenada tiene 4 filas con heading data integrado');
        print('  - Símbolos: ${processor.matrizordenada[0].length} elementos');
        print(
          '  - Magnitudes: ${processor.matrizordenada[1].length} elementos',
        );
        print('  - Tiempos: ${processor.matrizordenada[2].length} elementos');
        print('  - Heading: ${processor.matrizordenada[3].length} elementos');
      }
    });

    test('ConteoPasosTexteando efficiently processes 4-row matrices', () {
      // Crear matriz de prueba de 4 filas (incluyendo heading)
      final matrizOrdenadaTest = [
        [1.0, 2.0, 1.0, 3.0, 1.0], // símbolos
        [0.8, 1.2, 0.9, 1.1, 0.7], // magnitudes
        [10.0, 20.0, 30.0, 40.0, 50.0], // tiempos
        [45.0, 47.0, 43.0, 46.0, 44.0], // heading (pre-procesado)
      ];

      final matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
      final matrizPasos = List.generate(3, (_) => List.filled(20, 0.0));
      final matrizSecuenciasRevisar = <List<double>>[];
      final unionFiltradoRecortado = <double>[];
      final unionFiltradoRecortado2 = <double>[];
      final matrizGyro = [<double>[], <double>[], <double>[]];
      final tiemposRestados = <double>[];
      final headingList = <double>[]; // No se usa con matriz de 4 filas

      // Procesar con la matriz optimizada
      conteoPasos.procesar(
        matrizOrdenadaTest,
        matrizDatosRecientes,
        matrizPasos,
        headingList, // No se usa
        matrizSecuenciasRevisar,
        unionFiltradoRecortado,
        unionFiltradoRecortado2,
        125, // ventanaTiempo
        matrizGyro,
        tiemposRestados,
      );

      // Verificar que los datos de heading filtrado se obtuvieron correctamente
      expect(conteoPasos.filteredHeadingData.isNotEmpty, isTrue);
      expect(conteoPasos.filteredHeadingData.length, equals(5));

      // Verificar que matrizDatosRecientes tiene 4 filas con datos de heading
      expect(matrizDatosRecientes.length, equals(4));
      expect(matrizDatosRecientes[3].any((value) => value != 0.0), isTrue);

      print('✓ ConteoPasosTexteando procesó eficientemente matriz de 4 filas');
      print('  - Heading filtrado: ${conteoPasos.filteredHeadingData}');
      print(
        '  - Últimos 4 heading en matrizDatosRecientes: ${matrizDatosRecientes[3]}',
      );
    });

    test('Heading correlation maintained throughout filtering pipeline', () {
      // Crear datos de prueba con valores conocidos
      final testData = [
        [1.0, 0.0, 1.0, 0.0, 1.0], // símbolos con cruces
        [0.8, 0.0, 0.9, 0.0, 0.7], // magnitudes
        [10.0, 15.0, 30.0, 35.0, 50.0], // tiempos
        [45.0, 47.0, 43.0, 46.0, 44.0], // heading correlacionado
      ];

      final matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
      final matrizPasos = List.generate(3, (_) => List.filled(20, 0.0));
      final matrizSecuenciasRevisar = <List<double>>[];
      final unionFiltradoRecortado = <double>[];
      final unionFiltradoRecortado2 = <double>[];
      final matrizGyro = [<double>[], <double>[], <double>[]];
      final tiemposRestados = <double>[];

      conteoPasos.procesar(
        testData,
        matrizDatosRecientes,
        matrizPasos,
        [], // headingList no se usa
        matrizSecuenciasRevisar,
        unionFiltradoRecortado,
        unionFiltradoRecortado2,
        125,
        matrizGyro,
        tiemposRestados,
      );

      // Verificar que la correlación se mantiene
      final headingFromMatrix = conteoPasos
          .getLastFourFilteredHeadingFromMatrix(matrizDatosRecientes);
      expect(headingFromMatrix.length, equals(4));

      // Verificar que los valores no son todos ceros (indicaría pérdida de datos)
      expect(headingFromMatrix.any((value) => value != 0.0), isTrue);

      print('✓ Correlación heading-símbolo mantenida en pipeline optimizado');
      print('  - Heading correlacionado: $headingFromMatrix');
    });

    test('Performance improvement: no redundant heading correlation', () {
      // Simular una matriz ya procesada desde sensor processor
      final matrizOptimizada = [
        [1.0, 2.0, 1.0, 3.0, 1.0, 2.0, 1.0], // símbolos
        [0.8, 1.2, 0.9, 1.1, 0.7, 1.0, 0.8], // magnitudes
        [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0], // tiempos
        [45.0, 47.0, 43.0, 46.0, 44.0, 48.0, 42.0], // heading ya correlacionado
      ];

      final stopwatch = Stopwatch()..start();

      final matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
      final matrizPasos = List.generate(3, (_) => List.filled(20, 0.0));

      conteoPasos.procesar(
        matrizOptimizada,
        matrizDatosRecientes,
        matrizPasos,
        [], // headingList vacío - no se necesita
        <List<double>>[],
        <double>[],
        <double>[],
        125,
        [<double>[], <double>[], <double>[]],
        <double>[],
      );

      stopwatch.stop();

      // Verificar que el procesamiento fue exitoso y rápido
      expect(conteoPasos.filteredHeadingData.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMicroseconds, lessThan(1000)); // Menos de 1ms

      print(
        '✓ Procesamiento optimizado completado en ${stopwatch.elapsedMicroseconds} microsegundos',
      );
      print('  - Sin correlación redundante de heading');
      print('  - Datos heading pre-procesados utilizados directamente');
    });
  });
}
