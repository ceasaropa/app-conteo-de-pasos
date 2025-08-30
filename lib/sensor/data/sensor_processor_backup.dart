import 'package:proyecto_imu_v1_2/sensor/data/low_pass_filter.dart';
import 'package:proyecto_imu_v1_2/sensor/data/clasificador_de_datos.dart';
import 'package:proyecto_imu_v1_2/sensor/data/fusion_y_acortamiento_datos.dart';
import 'package:proyecto_imu_v1_2/sensor/data/conteopasostexteo.dart';
import 'package:scidart/numdart.dart';

class DataProcessor {
  final ConteoPasosTexteando conteoPasos = ConteoPasosTexteando();
  final _acortaFusionaDatos = ProcesamientoEventos();
  
  // Filtros en tiempo real
  final StreamingFilter _accFilter = StreamingFilter(cutoffHz: 2, fs: 125);
  final StreamingFilter _gyroFilter = StreamingFilter(cutoffHz: 4, fs: 125);
  
  // Datos principales (consolidados)
  List<double> accMagnitudeList = List.filled(50000, 0.0);
  List<double> gyroMagnitudeList = List.filled(50000, 0.0);
  List<double> accMagnitudeListFiltered = List.filled(50000, 0.0);
  List<double> gyroMagnitudeListFiltered = List.filled(50000, 0.0);
  
  // Ventanas de datos desfasados
  List<double> accMagnitudeListDesfasada = [];
  List<double> gyroMagnitudeListDesfasada = [];
  
  // Historial procesado
  List<double> historialFiltrado = [];
  List<double> ventanaGyroXYZFiltradaList = [];
  
  // Parámetros de configuración
  final int ventanaTiempo = 125;
  int indiceInicio = 0;
  int index = 0;
  
  // Umbrales
  double umbralGyroPico = 1;
  double umbralPico = 1;
  double umbralPicoSinFiltrar = 1.2;
  double umbralValle = -0.5;
  double umbralValleSinFiltrar = -0.6;

  // Estados de análisis
  bool inicioAnalisis2 = false;
  bool inicioAnalisis3 = false;
  bool inicioAnalisis4 = false;
  bool inicioAnalisis5 = false;
  bool inicioAnalisis6 = false;
  bool inicioAnalisis7 = false;
  bool inicioAnalisis8 = false;
  bool inicioAnalisis9 = false;

  // Resultados de análisis (consolidados)
  List<double> crucesPorCeroList = [];
  List<double> crucesPorCeroListFiltrado = [];
  List<double> picosList = [];
  List<double> picosListFiltrado = [];
  List<double> picosGyroFiltrado = [];
  List<double> vallesList = [];
  List<double> vallesListFiltrado = [];
  List<double> unionCrucesPicosVallesList = [];
  List<double> unionCrucesPicosVallesListFiltrado = [];
  List<double> unionCrucesPicosVallesListTotal = [];
  List<double> unionCrucesPicosVallesListFiltradoTotal = [];

  // Matrices de procesamiento (consolidadas)
  List<List<double>> matrizGyro = [[], [], []];
  List<List<double>> matrizordenada = [[], [], []];
  List<List<double>> matrizordenada1 = [[], [], []];
  List<double> primeraFilaMatrizOrdenada = [];
  List<List<double>> matrizordenada2 = [[], [], []];
  
  List<double> unionordenadoList = [];
  List<double> unionordenadoList1 = [];
  List<double> unionordenadoList2 = [];
  List<double> unionordenadoListfil = [];
  List<double> unionordenadoListfil1 = [];
  List<double> unionordenadoListfil2 = [];
  List<double> unionordenadoListdef = [];
  List<double> unionordenadoListdef1 = [];
  List<double> unionordenadoListdef2 = [];
  
  // Datos de salida finales (incluye 4 filas: 3 originales + 1 para heading filtrado)
  List<List<double>> matrizDatosRecientes = List.generate(4, (_) => List.filled(4, 0.0));
  List<List<double>> matrizPasos = List.generate(3, (i) => List.filled(20, 0.0));
  List<List<double>> matrizSecuenciasrevisar = [];
  List<List<double>> matrizsignalfiltertotal = [];
  List<double> unionFiltradorecortadoTotal = [];
  List<double> unionFiltradorecortadoTotal2 = [];
  List<int> pasosPorVentana = [];
  List<double> tiempoDePasosList = [];
  List<List<double>> matrizordenadatotal = [[], [], [], [], []];
  List<double> tiemposRestados = [];

  void addAccelerometer(
    double magnitude,
    double frequency,
    double gyroMagnitude,
  ) {
    // Paso 1: Filtrar en tiempo real
    double accFiltered = _accFilter.filter(magnitude);
    double gyroFiltered = _gyroFilter.filter(gyroMagnitude);
    
    int inicio = indiceInicio;
    int fin = inicio + ventanaTiempo;
    
    if (index < 50000) {
      // Guardar datos originales y filtrados
      accMagnitudeList[index] = magnitude;
      gyroMagnitudeList[index] = gyroMagnitude;
      accMagnitudeListFiltered[index] = accFiltered;
      gyroMagnitudeListFiltered[index] = gyroFiltered;
      index++;
    }
    
    bool ready = (indiceInicio + ventanaTiempo <= index);
    if (ready) {
      _processWindow(inicio, fin);
      inicioAnalisis2 = true;
      indiceInicio += ventanaTiempo;
    }
    
    // Procesar análisis secuencial
    if (inicioAnalisis2) _processFiltering(inicio, fin);
    if (inicioAnalisis3) _processCrossings(inicio, fin);
    if (inicioAnalisis4) _processPeaks(inicio, fin);
    if (inicioAnalisis5) _processValleys(inicio, fin);
    if (inicioAnalisis6) _processUnions();
    if (inicioAnalisis7) _processMatrices(inicio, fin);
    if (inicioAnalisis8) _processStepCounting();
    if (inicioAnalisis9) _finalizarAnalisis();
  }
  
  void _processWindow(int inicio, int fin) {
    var ventanaGyroXYZ = gyroMagnitudeList.sublist(
      indiceInicio,
      indiceInicio + ventanaTiempo,
    );
    var ventanaAccXYZ = accMagnitudeList.sublist(
      indiceInicio,
      indiceInicio + ventanaTiempo,
    );
    
    // Manejo del desfase
    List<double> ventanaAccXYZdesfasada;
    List<double> ventanaGyroXYZdesfasada;
    
    if (indiceInicio == 0) {
      List<double> inicioDesfase = [...List.filled(25, 0.0), ...ventanaAccXYZ];
      ventanaAccXYZdesfasada = inicioDesfase.sublist(
        indiceInicio,
        indiceInicio + ventanaTiempo,
      );
      inicioDesfase = [...List.filled(25, 0.0), ...ventanaGyroXYZ];
      ventanaGyroXYZdesfasada = inicioDesfase.sublist(
        indiceInicio,
        indiceInicio + ventanaTiempo,
      );
    } else {
      ventanaAccXYZdesfasada = accMagnitudeList.sublist(
        indiceInicio - 25,
        indiceInicio + ventanaTiempo - 25,
      );
      ventanaGyroXYZdesfasada = gyroMagnitudeList.sublist(
        indiceInicio - 25,
        indiceInicio + ventanaTiempo - 25,
      );
    }
    
    accMagnitudeListDesfasada.addAll(ventanaAccXYZdesfasada);
    gyroMagnitudeListDesfasada.addAll(ventanaGyroXYZdesfasada);
  }
  
  void _processFiltering(int inicio, int fin) {
    var ventanaAccXYZFiltered = accMagnitudeListFiltered.sublist(
      indiceInicio - ventanaTiempo,
      indiceInicio,
    );
    var ventanaGyroXYZFiltered = gyroMagnitudeListFiltered.sublist(
      indiceInicio - ventanaTiempo,
      indiceInicio,
    );

    historialFiltrado.addAll(ventanaAccXYZFiltered);
    ventanaGyroXYZFiltradaList.addAll(ventanaGyroXYZFiltered);
    matrizsignalfiltertotal.add(ventanaAccXYZFiltered); // Usar datos filtrados

    inicioAnalisis2 = false;
    inicioAnalisis3 = true;
  }
  
  void _processCrossings(int inicio, int fin) {
    if (accMagnitudeListDesfasada.length < ventanaTiempo ||
        historialFiltrado.length < ventanaTiempo) {
      inicioAnalisis3 = false;
      inicioAnalisis4 = true;
      return;
    }
    var ventanaDesfasada = accMagnitudeListDesfasada.sublist(
      accMagnitudeListDesfasada.length - ventanaTiempo,
      accMagnitudeListDesfasada.length
    );
    var datosFiltrados = historialFiltrado.sublist(
      historialFiltrado.length - ventanaTiempo,
      historialFiltrado.length
    );
    
    crucesPorCeroList = AnalizadorDeSenales.crucesPorCero(
      ventanaDesfasada);
    crucesPorCeroListFiltrado = AnalizadorDeSenales.crucesPorCero(
      datosFiltrados);
    
    inicioAnalisis3 = false;
    inicioAnalisis4 = true;
  }
  
  void _processPeaks(int inicio, int fin) {
    if (accMagnitudeListDesfasada.length < ventanaTiempo ||
        historialFiltrado.length < ventanaTiempo ||
        ventanaGyroXYZFiltradaList.length < ventanaTiempo) {
      inicioAnalisis4 = false;
      inicioAnalisis5 = true;
      return;
    }
    var ventanaDesfasada = accMagnitudeListDesfasada.sublist(
      accMagnitudeListDesfasada.length - ventanaTiempo,
      accMagnitudeListDesfasada.length
    );
    var datosFiltrados = historialFiltrado.sublist(
      historialFiltrado.length - ventanaTiempo,
      historialFiltrado.length
    );
    var ventanaGyroFiltrada = ventanaGyroXYZFiltradaList.sublist(
      ventanaGyroXYZFiltradaList.length - ventanaTiempo,
      ventanaGyroXYZFiltradaList.length
    );
    
    picosList = AnalizadorDeSenales.deteccionPicos(ventanaDesfasada, umbralPicoSinFiltrar);
    picosListFiltrado = AnalizadorDeSenales.deteccionPicos(datosFiltrados, umbralPico);
    picosGyroFiltrado = AnalizadorDeSenales.deteccionPicos(ventanaGyroFiltrada, umbralGyroPico);
    
    inicioAnalisis4 = false;
    inicioAnalisis5 = true;
  }
  
  void _processValleys(int inicio, int fin) {
    if (accMagnitudeListDesfasada.length < ventanaTiempo ||
        historialFiltrado.length < ventanaTiempo) {
      inicioAnalisis5 = false;
      inicioAnalisis6 = true;
      return;
    }
    var ventanaDesfasada = accMagnitudeListDesfasada.sublist(
      accMagnitudeListDesfasada.length - ventanaTiempo,
      accMagnitudeListDesfasada.length
    );
    var datosFiltrados = historialFiltrado.sublist(
      historialFiltrado.length - ventanaTiempo,
      historialFiltrado.length
    );
    
    vallesList = AnalizadorDeSenales.deteccionValles(ventanaDesfasada, umbralValleSinFiltrar);
    vallesListFiltrado = AnalizadorDeSenales.deteccionValles(datosFiltrados, umbralValle);
    
    inicioAnalisis5 = false;
    inicioAnalisis6 = true;
  }
  
  void _processUnions() {
    unionCrucesPicosVallesList = AnalizadorDeSenales.unionCrucesPicosValles(
      crucesPorCeroList, picosList, vallesList);
    unionCrucesPicosVallesListFiltrado = AnalizadorDeSenales.unionCrucesPicosValles(
      crucesPorCeroListFiltrado, picosListFiltrado, vallesListFiltrado);
    
    unionCrucesPicosVallesListTotal.addAll(unionCrucesPicosVallesList);
    unionCrucesPicosVallesListFiltradoTotal.addAll(unionCrucesPicosVallesListFiltrado);
    
    inicioAnalisis6 = false;
    inicioAnalisis7 = true;
  }
  
  void _processMatrices(int inicio, int fin) {
    if (accMagnitudeListDesfasada.length < ventanaTiempo ||
        historialFiltrado.length < ventanaTiempo ||
        ventanaGyroXYZFiltradaList.length < ventanaTiempo) {
      inicioAnalisis7 = false;
      inicioAnalisis8 = true;
      return;
    }
    var ventanaDesfasada = accMagnitudeListDesfasada.sublist(
      accMagnitudeListDesfasada.length - ventanaTiempo,
      accMagnitudeListDesfasada.length
    );
    var datosFiltrados = historialFiltrado.sublist(
      historialFiltrado.length - ventanaTiempo,
      historialFiltrado.length
    );
    var ventanaGyroFiltrada = ventanaGyroXYZFiltradaList.sublist(
      ventanaGyroXYZFiltradaList.length - ventanaTiempo,
      ventanaGyroXYZFiltradaList.length
    );
    
    // Procesamiento del giroscopio
    List<double> indices = List.generate(picosGyroFiltrado.length, (index) => index.toDouble());
    final (simbolosFiltrados, magnitudesFiltradas, tiemposFiltrados) = 
      _acortaFusionaDatos.filtrarSimbolosCero(picosGyroFiltrado, ventanaGyroFiltrada, indices);
    matrizGyro = [simbolosFiltrados, tiemposFiltrados, magnitudesFiltradas];
    
    // Crear matrices acortadas
    matrizordenada = _acortaFusionaDatos.matrizAcortada(unionCrucesPicosVallesListFiltrado, datosFiltrados);
    primeraFilaMatrizOrdenada.addAll(matrizordenada[0]);
    matrizordenada1 = _acortaFusionaDatos.matrizAcortada(unionCrucesPicosVallesList, ventanaDesfasada);
    
  

    // Agregar datos a las listas de unión
    unionordenadoListfil.addAll(matrizordenada[0]);
    unionordenadoListfil1.addAll(matrizordenada[1]);
    unionordenadoListfil2.addAll(matrizordenada[2]);
    unionordenadoList.addAll(matrizordenada1[0]);
    unionordenadoList1.addAll(matrizordenada1[1]);
    unionordenadoList2.addAll(matrizordenada1[2]);
    unionordenadoListdef.addAll(matrizordenada2[0]);
    unionordenadoListdef1.addAll(matrizordenada2[1]);
    unionordenadoListdef2.addAll(matrizordenada2[2]);

    inicioAnalisis7 = false;
    inicioAnalisis8 = true;
  }
  
  void _processStepCounting() {
    conteoPasos.procesar(
        matrizordenada, matrizDatosRecientes, matrizPasos,
      unionFiltradorecortadoTotal, unionFiltradorecortadoTotal2,
      ventanaTiempo, matrizGyro, tiemposRestados);
      
      pasosPorVentana.add(matrizPasos[0][1].toInt());
      for (int i = 0; i < matrizPasos[0][1]; i++) {
        tiempoDePasosList.add(matrizPasos[1][i]);
      }
      matrizPasos[0][1] = 0;
    }

    inicioAnalisis8 = false;
    inicioAnalisis9 = true;
  }
  
  void _finalizarAnalisis() {
    for (int i = 0; i < 3; i++) {
      matrizordenadatotal[i].addAll(matrizordenada2[i]);
    }
    matrizordenadatotal[3] = tiempoDePasosList;
    matrizordenadatotal[4].addAll(matrizGyro[2]);

    inicioAnalisis9 = false;
  }

  // Información del estado del procesador
  Map<String, dynamic> getProcessorStatus() {
    return {
      'index': index,
      'indiceInicio': indiceInicio,
      'totalWindows': pasosPorVentana.length,
  'totalSteps': matrizPasos[0][2].toInt(),
      'thresholds': {
        'umbralPico': umbralPico,
        'umbralValle': umbralValle,
        'umbralGyroPico': umbralGyroPico,
      },
    };
  }
}
