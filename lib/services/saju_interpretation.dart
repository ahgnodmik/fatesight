import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'saju_service.dart';

/// 정적 해석 데이터 로더 + 리딩 조립기.
/// assets/saju/interpretations_{ko,en}.json 을 읽어
/// SajuResult 를 완성된 리딩 텍스트로 변환한다.
class SajuInterpretation {
  static final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>> _load(String language) async {
    final lang = language == 'ko' ? 'ko' : 'en';
    return _cache[lang] ??= jsonDecode(
      await rootBundle.loadString('assets/saju/interpretations_$lang.json'),
    ) as Map<String, dynamic>;
  }

  static const _elementKo = {
    'wood': '목(木)',
    'fire': '화(火)',
    'earth': '토(土)',
    'metal': '금(金)',
    'water': '수(水)',
  };
  static const _elementEn = {
    'wood': 'Wood',
    'fire': 'Fire',
    'earth': 'Earth',
    'metal': 'Metal',
    'water': 'Water',
  };

  /// 사주 리딩 전체 텍스트 생성.
  Future<String> buildReading({
    required String name,
    required SajuResult saju,
    required String language,
    DateTime? today,
  }) async {
    final data = await _load(language);
    final isKo = language == 'ko';
    final service = SajuService();

    String section(String category, String key) {
      final entry = (data[category] as Map<String, dynamic>)[key];
      if (entry == null) return '';
      return '**${entry['title']}**\n${entry['text']}';
    }

    final pillarLabels = [
      if (isKo) '연주 ${saju.year.label}' else 'Year ${saju.year.label}',
      if (isKo) '월주 ${saju.month.label}' else 'Month ${saju.month.label}',
      if (isKo) '일주 ${saju.day.label}' else 'Day ${saju.day.label}',
      if (saju.hour != null)
        if (isKo) '시주 ${saju.hour!.label}' else 'Hour ${saju.hour!.label}',
    ];

    final counts = saju.elementCounts;
    final elementNames = isKo ? _elementKo : _elementEn;
    final distribution = counts.entries
        .map((e) => '${elementNames[e.key]} ${e.value}')
        .join(' · ');

    final parts = <String>[
      isKo
          ? '🔮 $name님의 사주팔자\n${pillarLabels.join('  |  ')}'
          : "🔮 $name's Four Pillars\n${pillarLabels.join('  |  ')}",
      section('ilgan', saju.ilganKo),
      isKo
          ? '**오행 분포**\n$distribution'
          : '**Five Elements**\n$distribution',
      section('element_dominant', saju.dominantElement),
      for (final missing in saju.missingElements)
        section('element_missing', missing),
      isKo ? '☀️ 오늘의 운세' : "☀️ Today's Fortune",
      section('sipsin', service.todaySipsin(saju, today: today)),
    ];

    return parts.where((p) => p.isNotEmpty).join('\n\n');
  }
}
