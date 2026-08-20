/// Prototype heuristics. threshold_version = th-1.0.0. Not Tamir 2017.
enum Risk { low, moderate, high, unableToAssess }

String riskWire(Risk r) => switch (r) {
      Risk.low => 'LOW',
      Risk.moderate => 'MODERATE',
      Risk.high => 'HIGH',
      Risk.unableToAssess => 'UNABLE_TO_ASSESS',
    };

Risk classifyAnemia(double aStar) {
  if (aStar < 5.0) return Risk.high;
  if (aStar < 10.0) return Risk.moderate;
  return Risk.low;
}

Risk classifyJaundice(double bStar) {
  if (bStar >= 15.0) return Risk.high;
  if (bStar >= 10.0) return Risk.moderate;
  return Risk.low;
}

double? seriesMedian(List<double> values) {
  if (values.length < 2) return null;
  final s = [...values]..sort();
  final n = s.length;
  if (n.isOdd) return s[n ~/ 2];
  return (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2.0;
}

({Risk risk, double? signal}) classifyAnemiaSeries(List<double> values) {
  final signal = seriesMedian(values);
  if (signal == null) return (risk: Risk.unableToAssess, signal: null);
  return (risk: classifyAnemia(signal), signal: signal);
}

({Risk risk, double? signal}) classifyJaundiceSeries(List<double> values) {
  final signal = seriesMedian(values);
  if (signal == null) return (risk: Risk.unableToAssess, signal: null);
  return (risk: classifyJaundice(signal), signal: signal);
}
