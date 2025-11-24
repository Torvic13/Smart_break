// test/mapa_utils_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const radioTierra = 6371000.0; // metros
  final dLat = (lat2 - lat1) * (pi / 180);
  final dLon = (lon2 - lon1) * (pi / 180);
  final a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return radioTierra * c;
}

void main() {
  group('PRUEBAS UNITARIAS - HU01: Cálculo de distancia (4 pruebas)', () {
    test('Distancia entre el mismo punto debe ser 0', () {
      final d = calcularDistancia(-12.0675, -77.0342, -12.0675, -77.0342);
      expect(d, lessThan(1));
    });

    test('PUCP → Los Olivos ≈ 8.7 km (coordenadas reales)', () {
      final d = calcularDistancia(-12.0675, -77.0342, -11.9935, -77.0600);
      expect(d, greaterThan(8000)); // CORRECCIÓN
      expect(d, lessThan(9000)); // CORRECCIÓN
    });

    test('PUCP → Miraflores (Larcomar) ≈ 7.8 km', () {
      // Larcomar: -12.1318, -77.0305
      final d = calcularDistancia(-12.0675, -77.0342, -12.1318, -77.0305);
      expect(d, greaterThan(7000));
      expect(d, lessThan(8500)); // ≈ 7.8 km
    });

    test('Distancia cercana (500m) debe ser < 600m', () {
      final d = calcularDistancia(-12.0675, -77.0342, -12.0680, -77.0345);
      expect(d, lessThan(600));
    });
  });

  print("4 pruebas unitarias de distancia ");
}