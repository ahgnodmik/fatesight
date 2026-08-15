import 'package:flutter_test/flutter_test.dart';
import 'package:fatesight/services/saju_service.dart';
import 'package:fatesight/services/saju_interpretation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = SajuService();
  final interpretation = SajuInterpretation();

  test('Korean reading contains name, pillars, and daily fortune', () async {
    final saju = service.calculate(DateTime(1990, 3, 15, 8, 30));
    final reading = await interpretation.buildReading(
      name: '홍길동',
      saju: saju,
      language: 'ko',
      today: DateTime(2026, 8, 15),
    );
    expect(reading, contains('홍길동'));
    expect(reading, contains('연주'));
    expect(reading, contains('오늘의 운세'));
    expect(reading, contains('오행 분포'));
  });

  test('English reading localized', () async {
    final saju = service.calculate(DateTime(1985, 12, 1, 22, 10));
    final reading = await interpretation.buildReading(
      name: 'Jane',
      saju: saju,
      language: 'en',
      today: DateTime(2026, 8, 15),
    );
    expect(reading, contains('Jane'));
    expect(reading, contains("Today's Fortune"));
    expect(reading, contains('Five Elements'));
  });

  test('same birth same pillars, daily part varies by day', () async {
    final a = service.calculate(DateTime(2000, 1, 1, 6));
    final b = service.calculate(DateTime(2000, 1, 1, 6));
    expect(a.dayPillarKey, b.dayPillarKey);
    expect(a.elementCounts, b.elementCounts);

    final r1 = await interpretation.buildReading(
        name: 'x', saju: a, language: 'ko', today: DateTime(2026, 8, 15));
    final r2 = await interpretation.buildReading(
        name: 'x', saju: a, language: 'ko', today: DateTime(2026, 8, 16));
    expect(r1, isNot(equals(r2)));
  });
}
