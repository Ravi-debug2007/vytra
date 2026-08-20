import '../vision/classify.dart';

const algorithmVersion = 'alg-1.1.0';
const thresholdVersion = 'th-1.0.0';

enum Series { anemia, jaundice }
enum CaptureState { hunting, ready, analysing, recorded }
enum Lighting { indoorNatural, indoorArtificial, outdoorShade, outdoorDirect }
enum FitzpatrickMethod { selfReported, workerAssessed }
enum RejectionReason { blur, exposureDark, exposureBright, eyeClosed, roiTooSmall, whiteRefFail, meshMissing, other }

class CaptureAttempt {
  const CaptureAttempt({required this.series, required this.index, required this.valid, this.signal, this.rejectionReason, this.meshUsed = false});
  final Series series;
  final int index;
  final bool valid;
  final double? signal;
  final RejectionReason? rejectionReason;
  final bool meshUsed;
}

class RiskResult {
  const RiskResult({required this.risk, this.signal});
  final Risk risk;
  final double? signal;
}

RiskResult aggregateAnemia(List<double> values) {
  final result = classifyAnemiaSeries(values);
  return RiskResult(risk: result.risk, signal: result.signal);
}

RiskResult aggregateJaundice(List<double> values) {
  final result = classifyJaundiceSeries(values);
  return RiskResult(risk: result.risk, signal: result.signal);
}

String riskLabel(Risk risk) => riskWire(risk);
