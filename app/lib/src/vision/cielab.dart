import 'dart:math' as math;

/// True CIELAB D65, 2° conversion. This is intentionally not OpenCV uint8 Lab.
class Cielab {
  const Cielab(this.l, this.a, this.b);
  final double l;
  final double a;
  final double b;
}

class CielabConverter {
  const CielabConverter();

  Cielab fromSrgb(double r, double g, double b) {
    final rgb = [_linearize(r), _linearize(g), _linearize(b)];
    final x = rgb[0] * 0.4124564 + rgb[1] * 0.3575761 + rgb[2] * 0.1804375;
    final y = rgb[0] * 0.2126729 + rgb[1] * 0.7151522 + rgb[2] * 0.0721750;
    final z = rgb[0] * 0.0193339 + rgb[1] * 0.1191920 + rgb[2] * 0.9503041;
    const xn = 0.95047, yn = 1.0, zn = 1.08883;
    final fx = _f(x / xn), fy = _f(y / yn), fz = _f(z / zn);
    return Cielab(116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }

  double _linearize(double value) {
    final v = value.clamp(0.0, 1.0);
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  double _f(double value) => value > 0.008856451679 ? math.pow(value, 1 / 3).toDouble() : (7.787037037 * value) + (16 / 116);
}
