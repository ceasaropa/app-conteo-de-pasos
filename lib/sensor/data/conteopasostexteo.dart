import 'package:proyecto_imu_v1_2/sensor/data/fusion_y_acortamiento_datos.dart';

class ConteoPasosTexteando {
  final acortamientoDatos = ProcesamientoEventos();

  void procesar(
    List<List<double>> matrizOrdenada,
    List<List<double>> matrizUltimosDatos,
    List<List<double>> matrizSecuenciasRevisar,
    List<double> unionFiltradoRecortadoTotal,
    List<double> unionFiltradoRecortadoTotal2,
    int ventanaTiempo,
    List<List<double>> matrizGyro,
    List<double> listaTiemposRestados, // ✅ Nuevo parámetro
  ) {
    if (matrizOrdenada.isEmpty || matrizOrdenada[0].isEmpty) return;

    final n = matrizOrdenada[0].length + 4;
    List<List<double>> matrizDatosExtendida = List.generate(
      3,
      (_) => List.filled(n, 0.0),
    );

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        matrizDatosExtendida[j][i] = matrizUltimosDatos[j][i];
      }
    }

    for (int i = 4; i < n; i++) {
      for (int j = 0; j < 3; j++) {
        final indexOrigen = i - 4;
        if (indexOrigen < matrizOrdenada[j].length) {
          matrizDatosExtendida[j][i] = matrizOrdenada[j][indexOrigen];
        }
      }
    }

    final (simbolosFilt, magnitudesFilt, tiemposFilt) = acortamientoDatos
        .filtrarSimbolosCero(
          matrizDatosExtendida[0],
          matrizDatosExtendida[1],
          matrizDatosExtendida[2],
        );

    var matrizDatosAcortada = acortamientoDatos.procesarSimbolosConsecutivos(
      simbolosFilt,
      magnitudesFilt,
      tiemposFilt,
    );

    matrizDatosAcortada = _filtrarPrimerCruceConTiempo(matrizDatosAcortada);

    final totalFilas1 = matrizDatosExtendida[0].length - 4;
    final totalFilas = matrizDatosAcortada[0].length;
    if (totalFilas1 < 4) {
      int faltan = 4 - totalFilas1;
      for (int i = 0; i < 4; i++) {
        if (i < faltan) {
          matrizUltimosDatos[0][i] = 0;
          matrizUltimosDatos[1][i] = 0;
          matrizUltimosDatos[2][i] = 0;
        } else {
          int idx = totalFilas - totalFilas1 + (i - faltan);
          if (idx >= 0 && idx < totalFilas) {
            // Se verifica si el tiempo del dato en matrizAcortada es menor a -65.
            if (matrizDatosAcortada[2][idx] < -65) {
              matrizUltimosDatos[0][i] = 0.0; // Se anula solo el símbolo.
            } else {
              matrizUltimosDatos[0][i] = matrizDatosAcortada[0][idx];
            }
            // La magnitud y el tiempo se asignan de todas formas.
            matrizUltimosDatos[1][i] = matrizDatosAcortada[1][idx];
            matrizUltimosDatos[2][i] =
                (ventanaTiempo - matrizDatosAcortada[2][idx]) * -1;
          } else {
            matrizUltimosDatos[0][i] = 0;
            matrizUltimosDatos[1][i] = 0;
            matrizUltimosDatos[2][i] = 0;
          }
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        int idx = totalFilas - 4 + i;
        // Se verifica si el tiempo del dato en matrizAcortada es menor a -65.
        if (matrizDatosAcortada[2][idx] < -65) {
          matrizUltimosDatos[0][i] = 0.0; // Se anula solo el símbolo.
        } else {
          matrizUltimosDatos[0][i] = matrizDatosAcortada[0][idx];
        }
        // La magnitud y el tiempo se asignan de todas formas.
        matrizUltimosDatos[1][i] = matrizDatosAcortada[1][idx];
        matrizUltimosDatos[2][i] =
            (ventanaTiempo - matrizDatosAcortada[2][idx]) * -1;
      }
    }
    unionFiltradoRecortadoTotal.addAll(matrizDatosAcortada[0]);
    unionFiltradoRecortadoTotal.add(0.0);
    unionFiltradoRecortadoTotal2.addAll(matrizDatosAcortada[2]);
    unionFiltradoRecortadoTotal2.add(0.0);

    if (matrizDatosAcortada[0].length < 5) return;

    int filasM = matrizDatosAcortada[0].length - 4;
    int contadorPasos = 0;
    int indicadorPaso = matrizUltimosDatos[3][0].toInt();

    for (int i = 0; i < filasM; i++) {
      List<double> secuencia = [
        matrizDatosAcortada[0][i],
        matrizDatosAcortada[0][i + 1],
        matrizDatosAcortada[0][i + 2],
        matrizDatosAcortada[0][i + 3],
        matrizDatosAcortada[0][i + 4],
      ];

      matrizSecuenciasRevisar.add(List.from(secuencia));
      if (secuencia[2] == 1 && secuencia[3] == 1 && secuencia[4] == 1) {
        indicadorPaso = 0; // Reinicia el indicador de estado
        matrizUltimosDatos[3][0] = 0.0; // Actualiza la matriz
        continue; // Salta a la siguiente iteración
      }

      if (secuencia[0] == 1 && secuencia[2] == 1 && secuencia[4] == 1) {
        if ((secuencia[1] == 2 && secuencia[3] == 3) ||
            (secuencia[1] == 3 && secuencia[3] == 2)) {
          double tiempo1 = matrizDatosAcortada[2][i];
          double tiempo2 = matrizDatosAcortada[2][i + 4];

          // Agregar los tiempos a la lista (primero tiempo1, luego tiempo2)

          double diferencia = (tiempo2 - tiempo1).abs();

          if (secuencia[1] == 2 && secuencia[3] == 3) {
            if (indicadorPaso == 0) {
              indicadorPaso = 1;
              matrizUltimosDatos[3][0] = 1.0;
            }
            if (indicadorPaso == 1) {
              listaTiemposRestados.add(tiempo1);
              listaTiemposRestados.add(tiempo2);
              matrizUltimosDatos[4][contadorPasos] = diferencia;

              contadorPasos++;
            }
          }

          if (secuencia[1] == 3 && secuencia[3] == 2) {
            if (indicadorPaso == 0) {
              indicadorPaso = 2;
              matrizUltimosDatos[3][0] = 2.0;
            }
            if (indicadorPaso == 2) {
              listaTiemposRestados.add(tiempo1);
              listaTiemposRestados.add(tiempo2);
              matrizUltimosDatos[4][contadorPasos] = diferencia;

              contadorPasos++;
            }
          }
        }
      }
    }

    matrizUltimosDatos[3][1] = contadorPasos.toDouble();
    matrizUltimosDatos[3][2] += contadorPasos.toDouble();
  }

  // Método privado para filtrar cruces consecutivos
  List<List<double>> _filtrarPrimerCruceConTiempo(List<List<double>> matriz) {
    // Si la matriz está vacía o no tiene suficientes elementos para una secuencia,
    // la devolvemos sin cambios para evitar errores.
    if (matriz.isEmpty || matriz[0].length < 2) {
      return matriz;
    }

    // Lista para almacenar el resultado del filtrado.
    List<List<double>> resultado = List.generate(3, (_) => <double>[]);

    int i = 0; // Índice para recorrer la matriz.
    while (i < matriz[0].length) {
      // Verificamos si hay al menos dos '1's consecutivos.
      // La condición `i + 1 < matriz[0].length` previene un error de rango.
      if (i + 1 < matriz[0].length &&
          matriz[0][i] == 1 &&
          matriz[0][i + 1] == 1) {
        // --- LÓGICA SIMPLIFICADA ---
        // Siempre seleccionamos los datos correspondientes al segundo '1' de la secuencia.
        resultado[0].add(matriz[0][i + 1]);
        resultado[1].add(matriz[1][i + 1]);
        resultado[2].add(matriz[2][i + 1]);

        // Avanzamos el índice en 2 para saltar el par de '1's que acabamos de procesar.
        i += 2;

        // Después, avanzamos sobre cualquier otro '1' consecutivo para ignorarlos.
        // Esto asegura que de una secuencia larga (ej: 1, 1, 1, 1), solo nos
        // quedemos con el segundo y saltemos el resto.
        while (i < matriz[0].length && matriz[0][i] == 1) {
          i++;
        }
      } else {
        // Si el elemento actual no es un '1' o no inicia una secuencia,
        // simplemente lo agregamos al resultado y avanzamos al siguiente.
        resultado[0].add(matriz[0][i]);
        resultado[1].add(matriz[1][i]);
        resultado[2].add(matriz[2][i]);
        i++;
      }
    }

    return resultado;
  }

  bool _esPasoValidoConGyro(
    List<List<double>> matrizGyro,
    List<List<double>> matrizDatosAcortada,
    int indicePaso,
  ) {
    const List<int> indicesEventos = [1, 3];
    const double umbralTiempo = 11;

    for (int j = 0; j < matrizGyro[0].length; j++) {
      for (int k in indicesEventos) {
        double diferencia =
            (matrizGyro[1][j] - matrizDatosAcortada[2][indicePaso + k]).abs();
        if (diferencia < umbralTiempo) {
          return false;
        }
      }
    }
    return true;
  }
}
