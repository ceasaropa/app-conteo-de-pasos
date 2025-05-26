import 'package:flutter/material.dart';
import 'package:proyecto_imu_v1_2/sensor/sensor_manager.dart';
import 'package:proyecto_imu_v1_2/sensor/data/sensor_processor.dart';
import 'package:proyecto_imu_v1_2/widgets/graphbuilder.dart';
import 'package:proyecto_imu_v1_2/sensor/guardar/savedata.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SensorManager _sensorManager;
  late final DataProcessor _dataProcessor;
  final GraphBuilder _graphBuilder = GraphBuilder();
  bool showgraph = false;

  @override
  void initState() {
    super.initState();
    _dataProcessor = DataProcessor();
    _sensorManager = SensorManager(onUpdate: _onSensorDataUpdate,dataProcessor: _dataProcessor);  // Pasamos el callback
  }

  @override
  void dispose() {
    _sensorManager.dispose();
    super.dispose();
  }

  // Esta función se llama cada vez que hay una actualización en los sensores
  void _onSensorDataUpdate() {
    setState(() {});  // Llamamos a setState para redibujar la UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor de Sensores')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Sección del Acelerómetro
              const Text(
                'Acelerómetro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('X: ${_sensorManager.accX.toStringAsFixed(2)} m/s²'),
              Text('Y: ${_sensorManager.accY.toStringAsFixed(2)} m/s²'),
              Text('Z: ${_sensorManager.accZ.toStringAsFixed(2)} m/s²'),
              Text(
                'Magnitud: ${_sensorManager.accMagnitude.toStringAsFixed(2)} m/s²',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 30),
              
              // Sección del Giroscopio
              const Text(
                'Giroscopio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('X: ${_sensorManager.gyroX.toStringAsFixed(2)} rad/s'),
              Text('Y: ${_sensorManager.gyroY.toStringAsFixed(2)} rad/s'),
              Text('Z: ${_sensorManager.gyroZ.toStringAsFixed(2)} rad/s'),
              Text(
                'Magnitud: ${_sensorManager.gyroMagnitude.toStringAsFixed(2)} rad/s',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 30),
              
              // Información de muestreo
              Text(
                'Frecuencia: ${_sensorManager.frequency.toStringAsFixed(2)} Hz',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Estado: ${_sensorManager.isRunning ? 'ACTIVO' : 'INACTIVO'}',
                style: TextStyle(
                  fontSize: 18,
                  color: _sensorManager.isRunning ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 30),
              Text('Pasos: ${_dataProcessor.matrizUltimosDatos[3][2].toInt()}'),
              const SizedBox(height: 20),
              _dataProcessor.tiempoDePasosList.isNotEmpty
              ? Text('Tiempos por pasos (ms): ${_dataProcessor.tiempoDePasosList.map((t) => t.toStringAsFixed(0)).join(' ms, ')} ms')
              : SizedBox.shrink(),
            
              // Botón de control
              ElevatedButton(
                onPressed: _sensorManager.toggleSensors,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  _sensorManager.isRunning ? 'DETENER SENSORES' : 'INICIAR SENSORES',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              if (!_sensorManager.isRunning)
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Guardar Datos'),
                  onPressed: () {
                    GuardarDatos.guardarMatrizJson(_dataProcessor.matrizordenadatotal, generarNombreArchivo());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos guardados en almacenamiento interno')),
                    );
                  },
                ),
              const Text('Pasos por ventana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200, // altura fija para que no crezca infinito
                child: ListView.builder(
                  itemCount: _dataProcessor.pasosPorVentana.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.directions_walk),
                      title: Text('Ventana ${index + 1}'),
                      trailing: Text('${_dataProcessor.pasosPorVentana[index]} pasos'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _dataProcessor.unionordenadoListfil2.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text('Muestra ${index + 1}: ${_dataProcessor.unionordenadoListfil2[index]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _dataProcessor.unionordenadoListdef2.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text('Muestra ${index + 1}: ${_dataProcessor.unionordenadoListdef2[index]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              

              // 📈 Gráfico de magnitud del acelerómetro
              if (!_sensorManager.isRunning) _graphBuilder.buildGraph(_dataProcessor.accMagnitudeListDesfasada, color: Colors.blue),
              if (!_sensorManager.isRunning) _graphBuilder.buildGraph(_dataProcessor.historialFiltrado, color: Colors.blue),


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
String generarNombreArchivo() {
  final now = DateTime.now();
  final nombreArchivo = '${now.year}'
      '-${now.month.toString().padLeft(2, '0')}'
      '-${now.day.toString().padLeft(2, '0')}'
      '_${now.hour.toString().padLeft(2, '0')}'
      '-${now.minute.toString().padLeft(2, '0')}'
      '-${now.second.toString().padLeft(2, '0')}.txt';

  return nombreArchivo;
}
