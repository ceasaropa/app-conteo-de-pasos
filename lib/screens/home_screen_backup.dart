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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final SensorManager _sensorManager;
  late final DataProcessor _dataProcessor;
  final GraphBuilder _graphBuilder = GraphBuilder();
  late AnimationController _pulseAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool showgraph = false;
  int? _selectedWindowIndex;
  List<int> availableWindows = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataProcessor = DataProcessor();
    _sensorManager = SensorManager(
      onUpdate: _onSensorDataUpdate,
      dataProcessor: _dataProcessor,
    );

    // Animaciones
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _fadeAnimationController.dispose();
    _sensorManager.dispose();
    super.dispose();
  }

  void _onSensorDataUpdate() {
    final newWindowCount = _dataProcessor.matrizsignalfiltertotal.length;
    if (newWindowCount > availableWindows.length) {
      setState(() {
        availableWindows = List.generate(newWindowCount, (index) => index);
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Header moderno
              SliverToBoxAdapter(child: _buildModernHeader()),

              // Control de grabación
              SliverToBoxAdapter(child: _buildRecordingControl()),

              // Tabs para diferentes vistas
              SliverToBoxAdapter(child: _buildTabBar()),

              // Contenido según tab seleccionado
              SliverToBoxAdapter(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IMU Monitor',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sensor de movimiento en tiempo real',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          _sensorManager.isRunning
                              ? _pulseAnimation.value
                              : 1.0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                _sensorManager.isRunning
                                    ? [
                                      const Color(0xFFFF6B6B),
                                      const Color(0xFFFF8E53),
                                    ]
                                    : [
                                      const Color(0xFF4ECDC4),
                                      const Color(0xFF44A08D),
                                    ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_sensorManager.isRunning
                                      ? const Color(0xFFFF6B6B)
                                      : const Color(0xFF4ECDC4))
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _sensorManager.isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sensorManager.isRunning
                            ? 'Grabando...'
                            : 'Listo para grabar',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Frecuencia: ${_sensorManager.frequency.toStringAsFixed(1)} Hz',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _sensorManager.toggleSensors,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        _sensorManager.isRunning
                            ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                            : [
                              const Color(0xFF667eea),
                              const Color(0xFF764ba2),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_sensorManager.isRunning
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFF667eea))
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _sensorManager.isRunning
                      ? 'DETENER SENSORES'
                      : 'INICIAR SENSORES',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          if (!_sensorManager.isRunning) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                GuardarDatos.guardarMatrizJson(
                  _dataProcessor.matrizordenadatotal,
                  _generarNombreArchivo(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Datos guardados exitosamente'),
                    backgroundColor: const Color(0xFF4ECDC4),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          _buildTabItem('Sensores', 0, Icons.sensors),
          _buildTabItem('Análisis', 1, Icons.analytics_outlined),
          _buildTabItem('Gráficos', 2, Icons.show_chart),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    )
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSensorTab();
      case 1:
        return _buildAnalysisTab();
      case 2:
        return _buildGraphTab();
      default:
        return _buildSensorTab();
    }
  }

  Widget _buildSensorTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Acelerómetro Card
          _buildSensorCard(
            'Acelerómetro',
            Icons.speed,
            [
              'X: ${_sensorManager.accX.toStringAsFixed(2)} m/s²',
              'Y: ${_sensorManager.accY.toStringAsFixed(2)} m/s²',
              'Z: ${_sensorManager.accZ.toStringAsFixed(2)} m/s²',
            ],
            'Magnitud: ${_sensorManager.accMagnitude.toStringAsFixed(2)} m/s²',
            const Color(0xFF667eea),
          ),

          const SizedBox(height: 16),

          // Giroscopio Card
          _buildSensorCard(
            'Giroscopio',
            Icons.rotate_right,
            [
              'X: ${_sensorManager.gyroX.toStringAsFixed(2)} rad/s',
              'Y: ${_sensorManager.gyroY.toStringAsFixed(2)} rad/s',
              'Z: ${_sensorManager.gyroZ.toStringAsFixed(2)} rad/s',
            ],
            'Magnitud: ${_sensorManager.gyroMagnitude.toStringAsFixed(2)} rad/s',
            const Color(0xFFFF6B6B),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    IconData icon,
    List<String> values,
    String magnitude,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            magnitude,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // NUEVO: Widget _buildAnalysisTab actualizado con los nuevos elementos
  Widget _buildAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pasos Totales',
                  '${_dataProcessor.matrizUltimosDatos[3][2].toInt()}',
                  Icons.directions_walk,
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Ventanas',
                  '${_dataProcessor.pasosPorVentana.length}',
                  Icons.view_module,
                  const Color(0xFFFFD93D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tiempo de Pasos Card
          if (_dataProcessor.tiempoDePasosList.isNotEmpty)
            _buildInfoCard(
              'Tiempo de Pasos (s)',
              _dataProcessor.tiempoDePasosList
                  .map((t) => t.toStringAsFixed(2))
                  .join(', '),
              Icons.timer_outlined,
              const Color(0xFFFC5C7D),
            ),

          // Pasos por Ventana List
          if (_dataProcessor.pasosPorVentana.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAnalysisListCard(
              title: 'Pasos por Ventana',
              icon: Icons.directions_walk,
              color: const Color(0xFF4ECDC4),
              itemCount: _dataProcessor.pasosPorVentana.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Text(
                      'Ventana ${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_dataProcessor.pasosPorVentana[index]} pasos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          // Muestras Recortadas 1
          if (_dataProcessor.unionFiltradorecortadoTotal.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAnalysisListCard(
              title: 'Muestras Recortadas 1',
              icon: Icons.content_cut,
              color: const Color(0xFF6A82FB),
              itemCount: _dataProcessor.unionFiltradorecortadoTotal.length,
              itemBuilder: (context, index) {
                return Text(
                  'Muestra ${index + 1}: ${_dataProcessor.unionFiltradorecortadoTotal[index].toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ],

          // Muestras Recortadas 2
          if (_dataProcessor.unionFiltradorecortadoTotal2.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAnalysisListCard(
              title: 'Muestras Recortadas 2',
              icon: Icons.content_cut,
              color: const Color(0xFF6A82FB),
              itemCount: _dataProcessor.unionFiltradorecortadoTotal2.length,
              itemBuilder: (context, index) {
                return Text(
                  'Muestra ${index + 1}: ${_dataProcessor.unionFiltradorecortadoTotal2[index].toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ],

          // Tiempos Restados
          if (!_sensorManager.isRunning &&
              _dataProcessor.tiemposRestados.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAnalysisListCard(
              title: 'Pares de Tiempos Restados (s)',
              icon: Icons.hourglass_empty,
              color: const Color(0xFFF7971E),
              itemCount: _dataProcessor.tiemposRestados.length ~/ 2,
              itemBuilder: (context, index) {
                final tiempo1 = _dataProcessor.tiemposRestados[index * 2]
                    .toStringAsFixed(2);
                final tiempo2 = _dataProcessor.tiemposRestados[index * 2 + 1]
                    .toStringAsFixed(2);
                return Text(
                  'Par ${index + 1}: [$tiempo1, $tiempo2]',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // NUEVO: Widget auxiliar para tarjetas de información general
  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NUEVO: Widget auxiliar para construir listas de análisis con estilo coherente
  Widget _buildAnalysisListCard({
    required String title,
    required IconData icon,
    required Color color,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Container(
      height: 220, // Altura fija para la lista
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: itemBuilder(context, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // Reducimos el padding horizontal
      child: Column(
        children: [
          // Selector de ventanas mejorado
          if (!_sensorManager.isRunning && availableWindows.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Seleccionar Ventana para Análisis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedWindowIndex,
                        hint: Text(
                          'Elige una ventana para visualizar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        dropdownColor: const Color(0xFF1A1E3A),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        items:
                            availableWindows.map((index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(
                                  'Ventana ${index + 1} (${_dataProcessor.pasosPorVentana.length > index ? "${_dataProcessor.pasosPorVentana[index]} pasos" : "Sin datos"})',
                                ),
                              );
                            }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedWindowIndex = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Gráficos con mejor organización
          if (!_sensorManager.isRunning) ...[
            // Sección de Acelerómetro
            _buildSectionTitle(
              'Datos del Acelerómetro',
              Icons.speed,
              const Color(0xFF667eea),
            ),
            _buildGraphCard(
              'Acelerómetro (Señal Original)',
              _dataProcessor.accMagnitudeListDesfasada,
              const Color(0xFF667eea),
            ),
            _buildGraphCard(
              'Acelerómetro (Señal Filtrada)',
              _dataProcessor.historialFiltrado,
              const Color(0xFF4ECDC4),
            ),

            const SizedBox(height: 20),

            // Sección de Giroscopio
            _buildSectionTitle(
              'Datos del Giroscopio',
              Icons.rotate_right,
              const Color(0xFFFF6B6B),
            ),
            _buildGraphCard(
              'Giroscopio (Señal Original)',
              _dataProcessor.gyroMagnitudeListDesfasada,
              const Color(0xFFFF6B6B),
            ),
            _buildGraphCard(
              'Giroscopio (Señal Filtrada)',
              _dataProcessor.ventanaGyroXYZFiltradaList,
              const Color(0xFFFF8E53),
            ),

            const SizedBox(height: 20),

            // Sección de Análisis
            _buildSectionTitle(
              'Análisis de Pasos',
              Icons.analytics,
              const Color(0xFFFFD93D),
            ),
            _buildGraphCard(
              'Detección: Cruces, Picos y Valles',
              _dataProcessor.unionCrucesPicosVallesListFiltradoTotal,
              const Color(0xFF9C27B0),
            ),

            // Gráfico de ventana específica si está seleccionada
            if (_selectedWindowIndex != null &&
                _dataProcessor.matrizsignalfiltertotal.length >
                    _selectedWindowIndex!) ...[
              const SizedBox(height: 20),
              _buildSectionTitle(
                'Ventana Específica',
                Icons.view_module,
                const Color(0xFF00BCD4),
              ),
              _buildGraphCard(
                'Ventana ${_selectedWindowIndex! + 1} - Análisis Detallado',
                _dataProcessor.matrizsignalfiltertotal[_selectedWindowIndex!],
                const Color(0xFF00BCD4),
              ),
            ],
          ] else ...[
            // Mensaje cuando está grabando
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.show_chart,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Grabando datos...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los gráficos se mostrarán cuando detengas la grabación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40), // Más espacio al final
        ],
      ),
    );
  }

  // Widget auxiliar para títulos de sección
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(String title, List<double> data, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.length} puntos',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contenedor del gráfico con altura fija más grande
          Container(
            height: 280, // Aumentamos significativamente la altura
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: _graphBuilder.buildGraph(
              data,
              color: color,
              // Si tu GraphBuilder acepta parámetros adicionales, puedes añadirlos aquí
              // Por ejemplo:
              // height: 240,
              // showAxes: true,
              // axisColor: Colors.white.withOpacity(0.5),
            ),
          ),

          // Información adicional del gráfico
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatInfo(
                'Min',
                data.reduce((a, b) => a < b ? a : b).toStringAsFixed(3),
              ),
              _buildStatInfo(
                'Max',
                data.reduce((a, b) => a > b ? a : b).toStringAsFixed(3),
              ),
              _buildStatInfo(
                'Promedio',
                (data.reduce((a, b) => a + b) / data.length).toStringAsFixed(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar estadísticas del gráfico
  Widget _buildStatInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _generarNombreArchivo() {
    final now = DateTime.now();
    return '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}'
        '-${now.minute.toString().padLeft(2, '0')}'
        '-${now.second.toString().padLeft(2, '0')}';
  }
}
