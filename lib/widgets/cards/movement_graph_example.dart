import 'package:flutter/material.dart';
import 'package:proyecto_imu_v1_2/widgets/cards/movement_graph_card.dart';

/// Ejemplo de uso del gráfico de movimiento
class MovementGraphExample extends StatelessWidget {
  const MovementGraphExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        title: const Text('Ejemplo de Gráfico de Movimiento'),
        backgroundColor: const Color(0xFF1A1E3A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ejemplo 1: Caminata en línea recta hacia el norte
            MovementGraphCard(
              title: 'Caminata Recta (Norte)',
              distancias: [0.8, 0.7, 0.9, 0.8, 0.75],
              azimuth: [0.0, 5.0, 350.0, 2.0, 358.0],
              color: const Color(0xFF4ECDC4),
            ),
            
            // Ejemplo 2: Caminata en cuadrado
            MovementGraphCard(
              title: 'Caminata en Cuadrado',
              distancias: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
              azimuth: [0.0, 0.0, 90.0, 90.0, 180.0, 180.0, 270.0, 270.0],
              color: const Color(0xFF9C27B0),
            ),
            
            // Ejemplo 3: Caminata en zigzag
            MovementGraphCard(
              title: 'Caminata en Zigzag',
              distancias: [0.8, 0.9, 0.7, 0.8, 0.85, 0.75],
              azimuth: [45.0, 315.0, 45.0, 315.0, 45.0, 315.0],
              color: const Color(0xFFFF7043),
            ),
            
            // Ejemplo 4: Caminata circular
            MovementGraphCard(
              title: 'Caminata Circular',
              distancias: [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
              azimuth: [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0],
              color: const Color(0xFF00BCD4),
            ),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Gráfico:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('🟢', 'Punto Verde: Inicio del recorrido'),
                  _buildInfoRow('🔴', 'Punto Rojo: Final del recorrido'),
                  _buildInfoRow('🔵', 'Puntos Azules: Pasos intermedios'),
                  _buildInfoRow('📏', 'Línea: Trayectoria seguida'),
                  const SizedBox(height: 8),
                  const Text(
                    'Métricas mostradas:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildInfoRow('📍', 'Posición final: Coordenadas X,Y del destino'),
                  _buildInfoRow('📐', 'Distancia total: Suma de todos los pasos'),
                  _buildInfoRow('📊', 'Desplazamiento: Distancia directa inicio-fin'),
                  _buildInfoRow('⚡', 'Eficiencia: % de qué tan directo fue el recorrido'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}