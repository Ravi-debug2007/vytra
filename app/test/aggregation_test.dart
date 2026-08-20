import 'package:flutter_test/flutter_test.dart';
import 'package:vytra/src/core/domain.dart';
import 'package:vytra/src/vision/classify.dart';

void main() {
  test('fewer than two valid captures is unable to assess', () {
    expect(aggregateAnemia([12]).risk, Risk.unableToAssess);
    expect(aggregateJaundice([8]).risk, Risk.unableToAssess);
  });

  test('anemia uses median and locked prototype bins', () {
    expect(aggregateAnemia([4, 6]).risk, Risk.moderate);
    expect(aggregateAnemia([10, 12]).risk, Risk.low);
    expect(aggregateAnemia([1, 3]).risk, Risk.high);
  });

  test('jaundice uses median and locked prototype bins', () {
    expect(aggregateJaundice([13, 15]).risk, Risk.moderate);
    expect(aggregateJaundice([4, 8]).risk, Risk.low);
    expect(aggregateJaundice([15, 17]).risk, Risk.high);
  });
}
