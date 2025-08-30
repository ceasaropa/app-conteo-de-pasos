import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_imu_v1_2/sensor/sensor_manager.dart';
import 'package:proyecto_imu_v1_2/sensor/data/sensor_processor.dart';
import 'package:proyecto_imu_v1_2/widgets/home/sections/sensor_section.dart';
import 'package:flutter/material.dart';

void main() {
  group('Compass Heading Tests', () {
    test('SensorManager should initialize with heading value', () {
      final dataProcessor = DataProcessor();
      final sensorManager = SensorManager(
        onUpdate: () {},
        dataProcessor: dataProcessor,
      );
      
      expect(sensorManager.heading, equals(0.0));
    });

    testWidgets('SensorSection should display compass card', (WidgetTester tester) async {
      final dataProcessor = DataProcessor();
      final sensorManager = SensorManager(
        onUpdate: () {},
        dataProcessor: dataProcessor,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SensorSection(sensorManager: sensorManager),
          ),
        ),
      );
      
      expect(find.text('Brújula'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });

    test('Cardinal direction should be correct for North', () {
      final dataProcessor = DataProcessor();
      final sensorManager = SensorManager(
        onUpdate: () {},
        dataProcessor: dataProcessor,
      );
      
      const sensorSection = SensorSection(sensorManager: null);
      
      // Test North direction (0 degrees)
      expect(sensorSection._getCardinalDirection(0.0), equals('N'));
      expect(sensorSection._getCardinalDirection(360.0), equals('N'));
      
      // Test East direction (90 degrees)
      expect(sensorSection._getCardinalDirection(90.0), equals('E'));
      
      // Test South direction (180 degrees)
      expect(sensorSection._getCardinalDirection(180.0), equals('S'));
      
      // Test West direction (270 degrees)
      expect(sensorSection._getCardinalDirection(270.0), equals('W'));
    });
  });
}