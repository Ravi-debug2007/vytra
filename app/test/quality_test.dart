import 'package:flutter_test/flutter_test.dart';
import 'package:vytra/src/vision/quality.dart';

void main() {
  test('white reference accepts bright neutral un clipped patch', () {
    final result = validateWhiteReference(meanR: 220, meanG: 221, meanB: 219, clippedR: 0, clippedG: 0, clippedB: 0);
    expect(result.accepted, isTrue);
    expect(result.gainR, closeTo(220 / 255, 1e-9));
  });

  test('white reference rejects dark, cast, and clipped patches', () {
    expect(validateWhiteReference(meanR: 170, meanG: 180, meanB: 180, clippedR: 0, clippedG: 0, clippedB: 0).accepted, isFalse);
    expect(validateWhiteReference(meanR: 220, meanG: 180, meanB: 220, clippedR: 0, clippedG: 0, clippedB: 0).accepted, isFalse);
    expect(validateWhiteReference(meanR: 220, meanG: 220, meanB: 220, clippedR: .06, clippedG: 0, clippedB: 0).accepted, isFalse);
  });

  test('quality thresholds match the locked gates', () {
    expect(blurPasses(100), isFalse);
    expect(blurPasses(100.01), isTrue);
    expect(exposurePasses(40), isTrue);
    expect(exposurePasses(200), isTrue);
    expect(exposurePasses(39.9), isFalse);
    expect(earPasses(.2), isFalse);
    expect(earPasses(.2001), isTrue);
  });
}
