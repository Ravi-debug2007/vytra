import 'package:flutter_test/flutter_test.dart';
import 'package:vytra/src/vision/cielab.dart';

void main() {
  test('white converts to D65 white Lab', () {
    final lab = const CielabConverter().fromSrgb(1, 1, 1);
    expect(lab.l, closeTo(100.0, 0.05));
    expect(lab.a, closeTo(0.0, 0.05));
    expect(lab.b, closeTo(0.0, 0.05));
  });

  test('black converts to zero lightness', () {
    final lab = const CielabConverter().fromSrgb(0, 0, 0);
    expect(lab.l, closeTo(0.0, 0.05));
  });
}
