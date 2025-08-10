import 'package:flutter/material.dart';
import 'package:proyecto_imu_v1_2/sensor/data/sensor_processor.dart';
import 'package:proyecto_imu_v1_2/sensor/sensor_manager.dart';
import '../../cards/stat_card.dart';
import '../../cards/info_card.dart';
import '../../cards/analysis_list_card.dart';

class AnalysisSection extends StatelessWidget {
  final DataProcessor dataProcessor;
  final SensorManager sensorManager;

  const AnalysisSection({
    super.key,
    required this.dataProcessor,
    required this.sensorManager,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Pasos Totales',
                  value: '${dataProcessor.matrizUltimosDatos[3][2].toInt()}',
                  icon: Icons.directions_walk,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Ventanas',
                  value: '${dataProcessor.pasosPorVentana.length}',
                  icon: Icons.view_module,
                  color: const Color(0xFFFFD93D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tiempo de Pasos Card
          if (dataProcessor.tiempoDePasosList.isNotEmpty)
            InfoCard(
              title: 'Tiempo de Pasos (s)',
              value: dataProcessor.tiempoDePasosList
                  .map((t) => t.toStringAsFixed(2))
                  .join(', '),
              icon: Icons.timer_outlined,
              color: const Color(0xFFFC5C7D),
            ),

          // Pasos por Ventana List
          if (dataProcessor.pasosPorVentana.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnalysisListCard(
              title: 'Pasos por Ventana',
              icon: Icons.directions_walk,
              color: const Color(0xFF4ECDC4),
              itemCount: dataProcessor.pasosPorVentana.length,
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
                      '${dataProcessor.pasosPorVentana[index]} pasos',
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
          if (dataProcessor.unionFiltradorecortadoTotal.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnalysisListCard(
              title: 'Muestras Recortadas 1',
              icon: Icons.content_cut,
              color: const Color(0xFF6A82FB),
              itemCount: dataProcessor.unionFiltradorecortadoTotal.length,
              itemBuilder: (context, index) {
                return Text(
                  'Muestra ${index + 1}: ${dataProcessor.unionFiltradorecortadoTotal[index].toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ],
          if (dataProcessor.crucesPorCeroListFiltrado.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnalysisListCard(
              title: 'cruces por cero',
              icon: Icons.content_cut,
              color: const Color(0xFF6A82FB),
              itemCount: dataProcessor.crucesPorCeroListFiltrado.length,
              itemBuilder: (context, index) {
                return Text(
                  'Muestra ${index + 1}: ${dataProcessor.crucesPorCeroListFiltrado[index].toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ],

          // Muestras Recortadas 2
          if (dataProcessor.unionFiltradorecortadoTotal2.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnalysisListCard(
              title: 'Muestras Recortadas 2',
              icon: Icons.content_cut,
              color: const Color(0xFF6A82FB),
              itemCount: dataProcessor.unionFiltradorecortadoTotal2.length,
              itemBuilder: (context, index) {
                return Text(
                  'Muestra ${index + 1}: ${dataProcessor.unionFiltradorecortadoTotal2[index].toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ],

          // Signal Stability Card
          const SizedBox(height: 16),
        
          // Tiempos Restados
          if (!sensorManager.isRunning &&
              dataProcessor.tiemposRestados.isNotEmpty) ...[
            const SizedBox(height: 16),
            AnalysisListCard(
              title: 'Pares de Tiempos Restados (s)',
              icon: Icons.hourglass_empty,
              color: const Color(0xFFF7971E),
              itemCount: dataProcessor.tiemposRestados.length ~/ 2,
              itemBuilder: (context, index) {
                final tiempo1 = dataProcessor.tiemposRestados[index * 2]
                    .toStringAsFixed(2);
                final tiempo2 = dataProcessor.tiemposRestados[index * 2 + 1]
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
}
