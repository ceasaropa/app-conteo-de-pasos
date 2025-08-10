class ProcesamientoEventos {
  /// Devuelve la matriz acortada con procesamiento completo
  List<List<double>> matrizAcortada(
    List<double> unionCrucesPicosVallesList,
    List<double> ventana,
  ) {
    List<double> indices = List.generate(
      unionCrucesPicosVallesList.length,
      (index) => index.toDouble(),
    );

    final (
      simbolosFiltrados,
      magnitudesFiltradas,
      tiemposFiltrados,
    ) = filtrarSimbolosCero(unionCrucesPicosVallesList, ventana, indices);

    final datosProcesados = procesarSimbolosConsecutivos(
      simbolosFiltrados,
      magnitudesFiltradas,
      tiemposFiltrados,
    );

    return filtrarCrucesConsecutivos(datosProcesados);
  }

  /// Elimina los ceros
  (List<double>, List<double>, List<double>) filtrarSimbolosCero(
    List<double> simbolosList,
    List<double> magnitudesList,
    List<double> tiemposList,
  ) {
    final simbolosFiltrados = <double>[];
    final magnitudesFiltradas = <double>[];
    final tiemposFiltrados = <double>[];

    for (int i = 0; i < simbolosList.length; i++) {
      if (simbolosList[i] != 0) {
        simbolosFiltrados.add(simbolosList[i]);
        magnitudesFiltradas.add(magnitudesList[i]);
        tiemposFiltrados.add(tiemposList[i]);
      }
    }

    return (simbolosFiltrados, magnitudesFiltradas, tiemposFiltrados);
  }

  /// Procesa símbolos consecutivos para reducir duplicados
  List<List<double>> procesarSimbolosConsecutivos(
    List<double> simbolosFiltrados,
    List<double> magnitudesFiltradas,
    List<double> tiemposFiltrados,
  ) {
    final datosProcesados = [
      <double>[], // símbolos
      <double>[], // magnitudes
      <double>[], // tiempos
    ];

    int? simboloActual;
    double? mejorMagnitud;
    double? mejorTiempo;

    for (int i = 0; i < simbolosFiltrados.length; i++) {
      final simbolo = simbolosFiltrados[i].toInt();
      final magnitud = magnitudesFiltradas[i];
      final tiempo = tiemposFiltrados[i];

      if (simbolo != simboloActual) {
        if (simboloActual != null && simboloActual != 1) {
          datosProcesados[0].add(simboloActual.toDouble());
          datosProcesados[1].add(mejorMagnitud!);
          datosProcesados[2].add(mejorTiempo!);
        }

        simboloActual = simbolo;

        if (simbolo == 1) {
          datosProcesados[0].add(1.0);
          datosProcesados[1].add(magnitud);
          datosProcesados[2].add(tiempo);
          simboloActual = null;
        } else {
          mejorMagnitud = magnitud;
          mejorTiempo = tiempo;
        }
      } else {
        if (simbolo == 2 && magnitud > mejorMagnitud!) {
          mejorMagnitud = magnitud;
          mejorTiempo = tiempo;
        } else if (simbolo == 3 && magnitud < mejorMagnitud!) {
          mejorMagnitud = magnitud;
          mejorTiempo = tiempo;
        }
      }
    }

    if (simboloActual != null && simboloActual != 1) {
      datosProcesados[0].add(simboloActual.toDouble());
      datosProcesados[1].add(mejorMagnitud!);
      datosProcesados[2].add(mejorTiempo!);
    }

    return datosProcesados;
  }

  /// Filtra los cruces consecutivos, dejando solo el primero de cada grupo
  List<List<double>> filtrarCrucesConsecutivos(List<List<double>> datosCrudos) {
    final simbolosFiltrados = <double>[];
    final magnitudesFiltrados = <double>[];
    final tiemposFiltrados = <double>[];

    int i = 0;
    while (i < datosCrudos[0].length) {
      final simbolo = datosCrudos[0][i];

      if (simbolo == 1) {
        // Guarda solo el primer cruce por cero
        simbolosFiltrados.add(1.0);
        magnitudesFiltrados.add(datosCrudos[1][i]);
        tiemposFiltrados.add(datosCrudos[2][i]);

        // Salta todos los cruces consecutivos
        while (i + 1 < datosCrudos[0].length && datosCrudos[0][i + 1] == 1) {
          i++;
        }
      } else {
        simbolosFiltrados.add(simbolo);
        magnitudesFiltrados.add(datosCrudos[1][i]);
        tiemposFiltrados.add(datosCrudos[2][i]);
      }

      i++;
    }

    return [simbolosFiltrados, magnitudesFiltrados, tiemposFiltrados];
  }


}
