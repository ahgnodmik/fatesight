import 'package:lunar/lunar.dart';

/// 사주 계산 엔진 — lunar 패키지의 팔자(八字) 계산 위에
/// 한글 표기·오행 분포·십신 관계를 얹는다. 네트워크 불필요, 결정론적.

/// 천간 (한자 순서: 甲乙丙丁戊己庚辛壬癸)
const List<String> _ganHanja = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
const List<String> _ganKo = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
// 천간 오행: 목목화화토토금금수수, 짝수 인덱스가 양(陽)
const List<String> _ganElement = ['wood', 'wood', 'fire', 'fire', 'earth', 'earth', 'metal', 'metal', 'water', 'water'];

/// 지지 (한자 순서: 子丑寅卯辰巳午未申酉戌亥)
const List<String> _zhiHanja = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
const List<String> _zhiKo = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
const List<String> _zhiElement = ['water', 'earth', 'wood', 'wood', 'earth', 'fire', 'fire', 'earth', 'metal', 'metal', 'earth', 'water'];

/// 오행 상생: 생(生)하는 방향 (wood→fire→earth→metal→water→wood)
const Map<String, String> _generates = {
  'wood': 'fire',
  'fire': 'earth',
  'earth': 'metal',
  'metal': 'water',
  'water': 'wood',
};

/// 오행 상극: 극(剋)하는 방향 (wood→earth→water→fire→metal→wood)
const Map<String, String> _controls = {
  'wood': 'earth',
  'earth': 'water',
  'water': 'fire',
  'fire': 'metal',
  'metal': 'wood',
};

class Pillar {
  final String ganHanja;
  final String zhiHanja;
  final String ganKo;
  final String zhiKo;
  final String ganElement;
  final String zhiElement;

  Pillar(this.ganHanja, this.zhiHanja)
      : ganKo = _ganKo[_ganHanja.indexOf(ganHanja)],
        zhiKo = _zhiKo[_zhiHanja.indexOf(zhiHanja)],
        ganElement = _ganElement[_ganHanja.indexOf(ganHanja)],
        zhiElement = _zhiElement[_zhiHanja.indexOf(zhiHanja)];

  /// 예: "갑자 (甲子)"
  String get label => '$ganKo$zhiKo ($ganHanja$zhiHanja)';
}

class SajuResult {
  final Pillar year;
  final Pillar month;
  final Pillar day;
  final Pillar? hour; // 시간 미상 허용

  SajuResult({required this.year, required this.month, required this.day, this.hour});

  /// 일간 — 사주 해석의 중심 글자
  String get ilganKo => day.ganKo;
  String get ilganHanja => day.ganHanja;
  String get ilganElement => day.ganElement;
  bool get ilganYang => _ganHanja.indexOf(day.ganHanja) % 2 == 0;

  /// 일주 60갑자 키 (해석 데이터 조회용, 예: "갑자")
  String get dayPillarKey => '${day.ganKo}${day.zhiKo}';

  List<Pillar> get pillars => [year, month, day, if (hour != null) hour!];

  /// 오행 분포 — 천간·지지 전체 (시주 없으면 6글자)
  Map<String, int> get elementCounts {
    final counts = {'wood': 0, 'fire': 0, 'earth': 0, 'metal': 0, 'water': 0};
    for (final p in pillars) {
      counts[p.ganElement] = counts[p.ganElement]! + 1;
      counts[p.zhiElement] = counts[p.zhiElement]! + 1;
    }
    return counts;
  }

  /// 가장 많은/없는 오행 (해석 데이터 키)
  String get dominantElement =>
      elementCounts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  List<String> get missingElements =>
      elementCounts.entries.where((e) => e.value == 0).map((e) => e.key).toList();
}

class SajuService {
  /// 생년월일시 → 사주팔자. [hasTime] false면 시주 생략.
  SajuResult calculate(DateTime birth, {bool hasTime = true}) {
    final eightChar = Lunar.fromDate(birth).getEightChar();
    return SajuResult(
      year: Pillar(eightChar.getYearGan(), eightChar.getYearZhi()),
      month: Pillar(eightChar.getMonthGan(), eightChar.getMonthZhi()),
      day: Pillar(eightChar.getDayGan(), eightChar.getDayZhi()),
      hour: hasTime ? Pillar(eightChar.getTimeGan(), eightChar.getTimeZhi()) : null,
    );
  }

  /// 오늘 일진의 천간이 사용자 일간에 대해 갖는 십신 관계.
  /// 반환 키: bigyeon, geopjae, siksin, sanggwan, pyeonjae, jeongjae,
  /// pyeongwan, jeonggwan, pyeonin, jeongin
  String todaySipsin(SajuResult user, {DateTime? today}) {
    final todayChar = Lunar.fromDate(today ?? DateTime.now()).getEightChar();
    return sipsinOf(user.day.ganHanja, todayChar.getDayGan());
  }

  /// [otherGan]이 [myGan](일간)에 대해 갖는 십신.
  String sipsinOf(String myGan, String otherGan) {
    final myIdx = _ganHanja.indexOf(myGan);
    final otherIdx = _ganHanja.indexOf(otherGan);
    final myElem = _ganElement[myIdx];
    final otherElem = _ganElement[otherIdx];
    final samePolarity = (myIdx % 2) == (otherIdx % 2);

    if (myElem == otherElem) {
      return samePolarity ? 'bigyeon' : 'geopjae'; // 비견/겁재
    }
    if (_generates[myElem] == otherElem) {
      return samePolarity ? 'siksin' : 'sanggwan'; // 식신/상관
    }
    if (_controls[myElem] == otherElem) {
      return samePolarity ? 'pyeonjae' : 'jeongjae'; // 편재/정재
    }
    if (_controls[otherElem] == myElem) {
      return samePolarity ? 'pyeongwan' : 'jeonggwan'; // 편관/정관
    }
    // 남는 관계는 나를 생하는 인성뿐
    return samePolarity ? 'pyeonin' : 'jeongin'; // 편인/정인
  }
}
