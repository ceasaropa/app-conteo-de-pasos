import 'package:flutter/material.dart';
import 'package:proyecto_imu_v1_2/sensor/sensor_manager.dart';
import '../../cards/sensor_card.dart';

class SensorSection extends StatelessWidget {
  final SensorManager sensorManager;

  const SensorSection({
    super.key,
    required this.sensorManager,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Acelerómetro Card con datos Kalman
          SensorCard(
            title: 'Acelerómetro',
            icon: Icons.speed,
            values: [
              'X: ${sensorManager.accX.toStringAsFixed(2)} m/s²',
              'Y: ${sensorManager.accY.toStringAsFixed(2)} m/s²',
              'Z: ${sensorManager.accZ.toStringAsFixed(2)} m/s²',
            ],
            magnitude:
                'Magnitud: ${sensorManager.accMagnitude.toStringAsFixed(2)} m/s²',
            // 🚀 NUEVO: Datos Kalman en subtitulo
            subtitle:
                'Kalman: ${sensorManager.kalmanAccMagnitude.toStringAsFixed(2)} m/s²',
            color: const Color(0xFF667eea),
          ),

          const SizedBox(height: 16),

          // Giroscopio Card
          SensorCard(
            title: 'Giroscopio',
            icon: Icons.rotate_right,
            values: [
              'X: ${sensorManager.gyroX.toStringAsFixed(2)} rad/s',
              'Y: ${sensorManager.gyroY.toStringAsFixed(2)} rad/s',
              'Z: ${sensorManager.gyroZ.toStringAsFixed(2)} rad/s',
            ],
            magnitude:
                'Magnitud: ${sensorManager.gyroMagnitude.toStringAsFixed(2)} rad/s',
            color: const Color(0xFFFF6B6B),
          ),

          const SizedBox(height: 16),

          // 🚀 NUEVA: Tarjeta de estadísticas Kalman
          

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
