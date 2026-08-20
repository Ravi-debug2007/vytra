import 'dart:math' as math;

class WhiteReferenceResult {
  const WhiteReferenceResult({required this.accepted, required this.gainR, required this.gainG, required this.gainB, this.reason});
  final bool accepted;
  final double gainR;
  final double gainG;
  final double gainB;
  final String? reason;
}

WhiteReferenceResult validateWhiteReference({required double meanR, required double meanG, required double meanB, required double clippedR, required double clippedG, required double clippedB}) {
  if (meanR < 180 || meanG < 180 || meanB < 180) return const WhiteReferenceResult(accepted: false, gainR: 1, gainG: 1, gainB: 1, reason: 'TOO_DARK');
  final mean = (meanR + meanG + meanB) / 3;
  final sd = math.sqrt(((meanR - mean) * (meanR - mean) + (meanG - mean) * (meanG - mean) + (meanB - mean) * (meanB - mean)) / 3);
  if (sd > 15) return const WhiteReferenceResult(accepted: false, gainR: 1, gainG: 1, gainB: 1, reason: 'COLOUR_CAST');
  if (clippedR > 0.05 || clippedG > 0.05 || clippedB > 0.05) return const WhiteReferenceResult(accepted: false, gainR: 1, gainG: 1, gainB: 1, reason: 'CLIPPED');
  return WhiteReferenceResult(accepted: true, gainR: meanR / 255, gainG: meanG / 255, gainB: meanB / 255);
}

bool blurPasses(double laplacianVariance) => laplacianVariance > 100;
bool exposurePasses(double meanGray) => meanGray >= 40 && meanGray <= 200;
bool earPasses(double ear) => ear > 0.2;
