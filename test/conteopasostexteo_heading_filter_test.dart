import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_imu_v1_2/sensor/data/conteopasostexteo.dart';

void main() {
  group('ConteoPasosTexteando - Heading Filter Tests', () {
    late ConteoPasosTexteando conteoPasos;

    setUp(() {
      conteoPasos = ConteoPasosTexteando();
    });

    group('Heading filtering functionality', () {
      test('should filter heading data correctly with valid indices', () {
        // Arrange
        final matrizOrdenada = [
          [1.0, 2.0, 3.0], // símbolos
          [0.5, 1.0, 1.5], // magnitudes
          [0.0, 2.0, 4.0], // índices de tiempo (tercera fila)
        ];
        final headingList = [10.0, 20.0, 30.0, 40.0, 50.0]; // 5 elementos
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(filteredHeading.length, equals(3));
        expect(filteredHeading[0], equals(10.0)); // índice 0
        expect(filteredHeading[1], equals(30.0)); // índice 2
        expect(filteredHeading[2], equals(50.0)); // índice 4
      });

      test('should handle out of bounds indices gracefully', () {
        // Arrange
        final matrizOrdenada = [
          [1.0, 2.0], // símbolos
          [0.5, 1.0], // magnitudes
          [1.0, 10.0], // índices de tiempo (uno válido, uno fuera de rango)
        ];
        final headingList = [
          10.0,
          20.0,
          30.0,
        ]; // 3 elementos, índice 10 está fuera de rango
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(filteredHeading.length, equals(1)); // Solo un índice válido
        expect(filteredHeading[0], equals(20.0)); // índice 1
      });

      test('should handle negative indices gracefully', () {
        // Arrange
        final matrizOrdenada = [
          [1.0, 2.0], // símbolos
          [0.5, 1.0], // magnitudes
          [-1.0, 1.0], // índices de tiempo (uno negativo, uno válido)
        ];
        final headingList = [10.0, 20.0, 30.0];
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(filteredHeading.length, equals(1)); // Solo un índice válido
        expect(filteredHeading[0], equals(20.0)); // índice 1
      });

      test('should handle empty inputs gracefully', () {
        // Arrange
        final matrizOrdenada = [<double>[], <double>[], <double>[]];
        final headingList = <double>[];
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(filteredHeading.length, equals(0));
      });

      test('should handle matrizOrdenada with less than 3 rows', () {
        // Arrange
        final matrizOrdenada = [
          [1.0, 2.0], // solo 2 filas en lugar de 3
          [0.5, 1.0],
        ];
        final headingList = [10.0, 20.0, 30.0];
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(
          filteredHeading.length,
          equals(0),
        ); // Debe ser vacío debido a la validación
      });

      test('should handle floating point indices by converting to int', () {
        // Arrange
        final matrizOrdenada = [
          [1.0, 2.0, 3.0], // símbolos
          [0.5, 1.0, 1.5], // magnitudes
          [0.7, 1.9, 3.1], // índices de tiempo con decimales
        ];
        final headingList = [10.0, 20.0, 30.0, 40.0]; // 4 elementos
        final matrizDatosRecientes = List.generate(
          4,
          (_) => List.filled(4, 0.0),
        );
        final matrizPasos = [
          [0.0, 0.0, 0.0, 0.0],
          List.filled(100, 0.0),
          List.filled(100, 0.0),
        ];
        final matrizSecuenciasRevisar = <List<double>>[];
        final unionFiltradoRecortadoTotal = <double>[];
        final unionFiltradoRecortadoTotal2 = <double>[];
        final matrizGyro = [<double>[], <double>[], <double>[]];
        final listaTiemposRestados = <double>[];

        // Act
        conteoPasos.procesar(
          matrizOrdenada,
          matrizDatosRecientes,
          matrizPasos,
          headingList,
          matrizSecuenciasRevisar,
          unionFiltradoRecortadoTotal,
          unionFiltradoRecortadoTotal2,
          125,
          matrizGyro,
          listaTiemposRestados,
        );

        // Assert
        final filteredHeading = conteoPasos.filteredHeadingData;
        expect(filteredHeading.length, equals(3));
        expect(filteredHeading[0], equals(10.0)); // índice 0.7 -> 0
        expect(filteredHeading[1], equals(20.0)); // índice 1.9 -> 1
        expect(filteredHeading[2], equals(40.0)); // índice 3.1 -> 3
      });

      test(
        'should store last 4 filtered heading values in fourth row of matrizDatosRecientes',
        () {
          // Arrange
          final matrizOrdenada = [
            [1.0, 2.0, 3.0, 1.0, 2.0], // símbolos
            [0.5, 1.0, 1.5, 2.0, 2.5], // magnitudes
            [0.0, 1.0, 2.0, 3.0, 4.0], // índices de tiempo
          ];
          final headingList = [
            100.0,
            200.0,
            300.0,
            400.0,
            500.0,
          ]; // 5 elementos
          final matrizDatosRecientes = List.generate(
            4,
            (_) => List.filled(4, 0.0),
          );
          final matrizPasos = [
            [0.0, 0.0, 0.0, 0.0],
            List.filled(100, 0.0),
            List.filled(100, 0.0),
          ];
          final matrizSecuenciasRevisar = <List<double>>[];
          final unionFiltradoRecortadoTotal = <double>[];
          final unionFiltradoRecortadoTotal2 = <double>[];
          final matrizGyro = [<double>[], <double>[], <double>[]];
          final listaTiemposRestados = <double>[];

          // Act
          conteoPasos.procesar(
            matrizOrdenada,
            matrizDatosRecientes,
            matrizPasos,
            headingList,
            matrizSecuenciasRevisar,
            unionFiltradoRecortadoTotal,
            unionFiltradoRecortadoTotal2,
            125,
            matrizGyro,
            listaTiemposRestados,
          );

          // Assert
          final filteredHeading = conteoPasos.filteredHeadingData;
          expect(filteredHeading.length, equals(5));

          // Verificar que la cuarta fila de matrizDatosRecientes contiene los últimos 4 datos de heading filtrado
          final lastFourHeading = conteoPasos
              .getLastFourFilteredHeadingFromMatrix(matrizDatosRecientes);
          expect(lastFourHeading.length, equals(4));

          // Los últimos 4 valores de filteredHeading deberían estar en la cuarta fila
          if (filteredHeading.length >= 4) {
            expect(
              lastFourHeading[0],
              equals(filteredHeading[filteredHeading.length - 4]),
            );
            expect(
              lastFourHeading[1],
              equals(filteredHeading[filteredHeading.length - 3]),
            );
            expect(
              lastFourHeading[2],
              equals(filteredHeading[filteredHeading.length - 2]),
            );
            expect(
              lastFourHeading[3],
              equals(filteredHeading[filteredHeading.length - 1]),
            );
          }
        },
      );

      test(
        'should store filtered heading data in matrizDatosExtendida fourth row',
        () {
          // Arrange
          final matrizOrdenada = [
            [1.0, 2.0, 3.0], // símbolos
            [0.5, 1.0, 1.5], // magnitudes
            [0.0, 1.0, 2.0], // índices de tiempo
          ];
          final headingList = [100.0, 200.0, 300.0]; // 3 elementos
          final matrizDatosRecientes = List.generate(
            4,
            (_) => List.filled(4, 0.0),
          );
          final matrizPasos = [
            [0.0, 0.0, 0.0, 0.0],
            List.filled(100, 0.0),
            List.filled(100, 0.0),
          ];
          final matrizSecuenciasRevisar = <List<double>>[];
          final unionFiltradoRecortadoTotal = <double>[];
          final unionFiltradoRecortadoTotal2 = <double>[];
          final matrizGyro = [<double>[], <double>[], <double>[]];
          final listaTiemposRestados = <double>[];

          // Act
          conteoPasos.procesar(
            matrizOrdenada,
            matrizDatosRecientes,
            matrizPasos,
            headingList,
            matrizSecuenciasRevisar,
            unionFiltradoRecortadoTotal,
            unionFiltradoRecortadoTotal2,
            125,
            matrizGyro,
            listaTiemposRestados,
          );

          // Assert
          final filteredHeading = conteoPasos.filteredHeadingData;
          expect(filteredHeading.length, equals(3));
          expect(filteredHeading, equals([100.0, 200.0, 300.0]));

          // Verificar que el método para acceder a matrizDatosExtendida funciona
          final testMatrix = List.generate(4, (_) => List.filled(7, 0.0));
          testMatrix[3] = [100.0, 200.0, 300.0, 0.0, 100.0, 200.0, 300.0];

          final headingFromExtended = conteoPasos
              .getFilteredHeadingFromExtendedMatrix(testMatrix);
          expect(headingFromExtended.length, equals(7));
          expect(
            headingFromExtended.take(3).toList(),
            equals([100.0, 200.0, 300.0]),
          );
        },
      );
    });
  });
}
