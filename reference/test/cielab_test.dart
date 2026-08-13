import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vytra/src/vision/cielab.dart';
import 'package:vytra/src/vision/classify.dart';

void main() {
  final json = jsonDecode(
    File('test/fixtures/golden_cielab.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('Lab goldens ±0.05', () {
    for (final raw in json['samples'] as List) {
      final row = raw as Map<String, dynamic>;
      final rgb = (row['rgb255'] as List).cast<num>();
      final lab = rgb255ToLab(rgb[0], rgb[1], rgb[2]);
      expect((lab.l - (row['L'] as num)).abs(), lessThanOrEqualTo(0.05), reason: '${row['name']} L');
      expect((lab.a - (row['a'] as num)).abs(), lessThanOrEqualTo(0.05), reason: '${row['name']} a');
      expect((lab.b - (row['b'] as num)).abs(), lessThanOrEqualTo(0.05), reason: '${row['name']} b');
    }
  });

  test('anemia / jaundice boundaries', () {
    final bounds = json['classify_boundaries'] as Map<String, dynamic>;
    for (final raw in bounds['anemia'] as List) {
      final row = raw as Map<String, dynamic>;
      expect(riskWire(classifyAnemia((row['a'] as num).toDouble())), row['expect']);
    }
    for (final raw in bounds['jaundice'] as List) {
      final row = raw as Map<String, dynamic>;
      expect(riskWire(classifyJaundice((row['b'] as num).toDouble())), row['expect']);
    }
  });

  test('<2 valid → UNABLE, two values use mean', () {
    expect(classifyAnemiaSeries(const []).risk, Risk.unableToAssess);
    expect(classifyAnemiaSeries(const [8]).signal, isNull);
    final two = classifyAnemiaSeries(const [4, 12]);
    expect(two.signal, closeTo(8, 1e-9));
    expect(two.risk, Risk.moderate);
  });
}
