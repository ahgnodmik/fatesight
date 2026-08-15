import 'package:flutter_test/flutter_test.dart';
import 'package:lunar/lunar.dart';
import 'package:fatesight/services/saju_service.dart';

void main() {
  final service = SajuService();

  test('1984 is 갑자(甲子) year', () {
    final result = service.calculate(DateTime(1984, 6, 1, 12));
    expect(result.year.ganHanja, '甲');
    expect(result.year.zhiHanja, '子');
    expect(result.year.label, '갑자 (甲子)');
  });

  test('sipsin matches lunar package SHI_SHEN table for all 100 pairs', () {
    const gans = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    // lunar 패키지의 중국식 십신 명칭 → 이 앱의 키
    const zhToKey = {
      '比肩': 'bigyeon',
      '劫财': 'geopjae',
      '食神': 'siksin',
      '伤官': 'sanggwan',
      '偏财': 'pyeonjae',
      '正财': 'jeongjae',
      '七杀': 'pyeongwan',
      '正官': 'jeonggwan',
      '偏印': 'pyeonin',
      '正印': 'jeongin',
    };
    for (final my in gans) {
      for (final other in gans) {
        final zh = LunarUtil.SHI_SHEN['$my$other'];
        expect(zh, isNotNull, reason: 'missing SHI_SHEN for $my$other');
        expect(service.sipsinOf(my, other), zhToKey[zh],
            reason: 'mismatch for my=$my other=$other (zh=$zh)');
      }
    }
  });

  test('element counts sum to 8 with hour, 6 without', () {
    final withHour = service.calculate(DateTime(1990, 3, 15, 8, 30));
    expect(withHour.elementCounts.values.reduce((a, b) => a + b), 8);
    final noHour = service.calculate(DateTime(1990, 3, 15), hasTime: false);
    expect(noHour.elementCounts.values.reduce((a, b) => a + b), 6);
    expect(noHour.hour, isNull);
  });

  test('day pillar key is stable regardless of query time', () {
    final r = service.calculate(DateTime(1995, 11, 2, 14));
    expect(r.dayPillarKey.length, 2);
    expect(r.ilganKo, r.dayPillarKey[0]);
  });
}
