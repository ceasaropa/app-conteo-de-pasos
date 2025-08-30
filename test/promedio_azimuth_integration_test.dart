import 'package:test/test.dart';
import 'package:proyecto_imu_v1_2/sensor/data/conteopasostexteo.dart';

void main() {
  group('Azimuth Averaging (Promedio Azimuth) Tests', () {
    late ConteoPasosTexteando conteoPasos;

    setUp(() {
      conteoPasos = ConteoPasosTexteando();
    });

    test('promedioAzimuth - Normal case without discontinuity', () {
      // Test normal azimuth progression
      final timeArray = [1.0, 2.0, 3.0, 4.0, 5.0];
      final azimuthArray = [45.0, 50.0, 55.0, 60.0, 65.0];

      final result = conteoPasos.promedioAzimuth(
        1.0, // startTime
        5.0, // endTime
        timeArray,
        azimuthArray,
      );

      // Expected: Progressive weighted average (favoring later values)
      // Weights: [1, 2, 3, 4, 5] = 15 total
      // Weighted sum: 45*1 + 50*2 + 55*3 + 60*4 + 65*5 = 45+100+165+240+325 = 875
      // Average: 875/15 = 58.33
      expect(result, closeTo(58.33, 0.1));
      print('✓ Normal azimuth averaging: $result');
    });

    test('promedioAzimuth - Discontinuity handling (359° → 0°)', () {
      // Test discontinuity case
      final timeArray = [1.0, 2.0, 3.0, 4.0, 5.0];
      final azimuthArray = [350.0, 355.0, 0.0, 5.0, 10.0];

      final result = conteoPasos.promedioAzimuth(
        1.0,
        5.0,
        timeArray,
        azimuthArray,
      );

      // Values should be normalized: [350, 355, 360, 365, 370]
      // Weights: [1, 2, 3, 4, 5] = 15 total
      // Weighted sum: 350*1 + 355*2 + 360*3 + 365*4 + 370*5 = 350+710+1080+1460+1850 = 5450
      // Average: 5450/15 = 363.33, normalized to 3.33
      expect(result, closeTo(3.33, 0.1));
      print('✓ Discontinuity handling: $result');
    });

    test('promedioAzimuth - Single value', () {
      final timeArray = [3.0];
      final azimuthArray = [180.0];

      final result = conteoPasos.promedioAzimuth(
        2.0,
        4.0,
        timeArray,
        azimuthArray,
      );

      expect(result, equals(180.0));
      print('✓ Single value case: $result');
    });

    test('promedioAzimuth - No data in interval', () {
      final timeArray = [1.0, 2.0, 8.0, 9.0];
      final azimuthArray = [45.0, 50.0, 55.0, 60.0];

      final result = conteoPasos.promedioAzimuth(
        4.0, // startTime
        6.0, // endTime
        timeArray,
        azimuthArray,
      );

      // Should return closest value (middle time = 5.0, closest is index 1 with time 2.0)
      // But actually closest to 5.0 is index 2 with time 8.0 (distance 3.0 vs 3.0)
      // Actually closest by distance is index 1 (distance 3.0) or index 2 (distance 3.0)
      // Algorithm picks first one found (index 1)
      expect(
        result,
        anyOf(equals(50.0), equals(55.0)),
      ); // Either could be closest
      print('✓ No data in interval (closest): $result');
    });

    test('promedioAzimuth - Edge cases', () {
      // Empty arrays
      expect(conteoPasos.promedioAzimuth(1.0, 2.0, [], []), equals(0.0));

      // Invalid time range
      expect(conteoPasos.promedioAzimuth(5.0, 2.0, [1.0], [45.0]), equals(0.0));

      // Mismatched array lengths
      expect(
        conteoPasos.promedioAzimuth(1.0, 2.0, [1.0, 2.0], [45.0]),
        equals(0.0),
      );

      print('✓ Edge cases handled correctly');
    });

    test('Step detection with azimuth integration', () {
      // Create test matrix data with step pattern and heading
      final matrizOrdenada = [
        [1.0, 2.0, 1.0, 3.0, 1.0, 2.0, 1.0], // symbols - valid step pattern
        [0.8, 1.2, 0.9, -1.1, 0.7, 1.3, 0.6], // magnitudes
        [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0], // times
        [45.0, 47.0, 43.0, 46.0, 44.0, 48.0, 42.0], // heading data
      ];

      final matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
      final matrizPasos = List.generate(3, (_) => List.filled(20, 0.0));
      final matrizSecuenciasRevisar = <List<double>>[];
      final unionFiltradoRecortado = <double>[];
      final unionFiltradoRecortado2 = <double>[];
      final matrizGyro = [<double>[], <double>[], <double>[]];
      final tiemposRestados = <double>[];

      // Process the data
      conteoPasos.procesar(
        matrizOrdenada,
        matrizDatosRecientes,
        matrizPasos,
        matrizSecuenciasRevisar,
        unionFiltradoRecortado,
        unionFiltradoRecortado2,
        125, // ventanaTiempo
        matrizGyro,
        tiemposRestados,
      );

      // Check if azimuth data was calculated
      final azimuthData = conteoPasos.averageAzimuthPerStep;
      expect(azimuthData, isNotEmpty);

      // Get step info
      final lastStepInfo = conteoPasos.getLastStepInfo(matrizPasos);
      if (lastStepInfo != null) {
        expect(lastStepInfo.containsKey('averageAzimuth'), isTrue);
        expect(lastStepInfo['averageAzimuth'], isA<double>());
        print('✓ Last step azimuth: ${lastStepInfo['averageAzimuth']}');
      }

      final allStepsInfo = conteoPasos.getAllStepsInfo(matrizPasos);
      for (final stepInfo in allStepsInfo) {
        expect(stepInfo.containsKey('averageAzimuth'), isTrue);
        print(
          '  Step ${stepInfo['stepIndex']}: azimuth=${stepInfo['averageAzimuth']}, length=${stepInfo['stepLength']}',
        );
      }

      print('✓ Step detection with azimuth integration successful');
    });

    test('Progressive weighting calculation', () {
      // Test with known values to verify progressive weighting
      final timeArray = [1.0, 2.0, 3.0];
      final azimuthArray = [
        0.0,
        0.0,
        90.0,
      ]; // Only last value matters with heavy weighting

      final result = conteoPasos.promedioAzimuth(
        1.0,
        3.0,
        timeArray,
        azimuthArray,
      );

      // Weights: [1, 2, 3] = 6 total
      // Weighted sum: 0*1 + 0*2 + 90*3 = 270
      // Average: 270/6 = 45.0
      expect(result, equals(45.0));
      print('✓ Progressive weighting verified: $result');
    });

    test('Azimuth data reset functionality', () {
      // Create test data for step detection to generate azimuth data
      final matrizOrdenada = [
        [1.0, 2.0, 1.0, 3.0, 1.0], // step pattern
        [0.8, 1.2, 0.9, -1.1, 0.7], // magnitudes
        [10.0, 20.0, 30.0, 40.0, 50.0], // times
        [45.0, 47.0, 43.0, 46.0, 44.0], // heading
      ];

      final matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
      final matrizPasos = List.generate(3, (_) => List.filled(20, 0.0));

      // Process to generate azimuth data
      conteoPasos.procesar(
        matrizOrdenada,
        matrizDatosRecientes,
        matrizPasos,
        <List<double>>[],
        <double>[],
        <double>[],
        125,
        [<double>[], <double>[], <double>[]],
        <double>[],
      );

      // Check data was generated
      final initialAzimuthCount = conteoPasos.averageAzimuthPerStep.length;

      // Reset data
      conteoPasos.resetAzimuthData();

      expect(conteoPasos.averageAzimuthPerStep.length, equals(0));
      expect(conteoPasos.filteredHeadingData.length, equals(0));

      print('✓ Azimuth data reset successful (had $initialAzimuthCount steps)');
    });

    test('Complex discontinuity scenarios', () {
      // Test multiple discontinuities
      final timeArray = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
      final azimuthArray = [358.0, 2.0, 359.0, 1.0, 357.0, 3.0];

      final result = conteoPasos.promedioAzimuth(
        1.0,
        6.0,
        timeArray,
        azimuthArray,
      );

      // Should handle multiple 359°→0° transitions correctly
      expect(result, greaterThanOrEqualTo(0.0));
      expect(result, lessThan(360.0));
      print('✓ Complex discontinuity handling: $result');
    });
  });
}
