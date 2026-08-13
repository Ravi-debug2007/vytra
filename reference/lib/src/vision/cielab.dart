/// True CIELAB D65 2°. Must match vision/cielab_reference.py ±0.05.
import 'dart:math' as math;

const double kXn = 0.95047;
const double kYn = 1.00000;
const double kZn = 1.08883;
const double kDelta = 6.0 / 29.0;

class Lab {
  const Lab(this.l, this.a, this.b);
  final double l;
  final double a;
  final double b;
}

double srgbToLinear(double c) {
  if (c <= 0.04045) return c / 12.92;
  return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double labF(double t) {
  final delta3 = kDelta * kDelta * kDelta;
  if (t > delta3) return math.pow(t, 1.0 / 3.0).toDouble();
  return t / (3.0 * kDelta * kDelta) + 4.0 / 29.0;
}

Lab rgb01ToLab(double r, double g, double b) {
  final rl = srgbToLinear(r);
  final gl = srgbToLinear(g);
  final bl = srgbToLinear(b);
  final x = 0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl;
  final y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl;
  final z = 0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl;
  final fy = labF(y / kYn);
  return Lab(
    116.0 * fy - 16.0,
    500.0 * (labF(x / kXn) - fy),
    200.0 * (fy - labF(z / kZn)),
  );
}

Lab rgb255ToLab(num r, num g, num b) =>
    rgb01ToLab(r / 255.0, g / 255.0, b / 255.0);

({double r, double g, double b}) applyWhitePatch({
  required double r255,
  required double g255,
  required double b255,
  required double gainR,
  required double gainG,
  required double gainB,
}) {
  if (gainR < 0.05 || gainG < 0.05 || gainB < 0.05) {
    throw StateError('white-patch gain < 0.05');
  }
  double n(double c, double g) => ((c / 255.0) / g).clamp(0.0, 1.0);
  return (r: n(r255, gainR), g: n(g255, gainG), b: n(b255, gainB));
}
