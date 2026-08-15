import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TarotCard {
  final int id;
  final String nameKo;
  final String nameEn;
  final String suit;
  final String meaningKo;
  final String meaningEn;
  final String reversedKo;
  final String reversedEn;
  final String fortuneKo;
  final String fortuneEn;
  final String fortuneRevKo;
  final String fortuneRevEn;

  TarotCard.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        nameKo = json['name_ko'] as String,
        nameEn = json['name_en'] as String,
        suit = json['suit'] as String,
        meaningKo = json['meaning_ko'] as String,
        meaningEn = json['meaning_en'] as String,
        reversedKo = json['reversed_ko'] as String,
        reversedEn = json['reversed_en'] as String,
        fortuneKo = json['fortune_ko'] as String,
        fortuneEn = json['fortune_en'] as String,
        fortuneRevKo = json['fortune_rev_ko'] as String,
        fortuneRevEn = json['fortune_rev_en'] as String;

  String name(bool isKorean) => isKorean ? nameKo : nameEn;
  String meaning(bool isKorean, {required bool reversed}) => reversed
      ? (isKorean ? reversedKo : reversedEn)
      : (isKorean ? meaningKo : meaningEn);
  String fortune(bool isKorean, {required bool reversed}) => reversed
      ? (isKorean ? fortuneRevKo : fortuneRevEn)
      : (isKorean ? fortuneKo : fortuneEn);

  Color get color => switch (suit) {
        'major' => const Color(0xFF7C3AED), // 보라
        'wands' => const Color(0xFFD97706), // 주황 (불)
        'cups' => const Color(0xFF0891B2), // 청록 (물)
        'swords' => const Color(0xFF6B7280), // 회색 (바람)
        _ => const Color(0xFF059669), // 초록 (땅, pentacles)
      };
}

/// 78장 전체 덱. assets/tarot/*.json 3개 파일을 병합해 로드.
class TarotDeck {
  static List<TarotCard>? _cards;
  static final Random _random = Random();

  static const _assetPaths = [
    'assets/tarot/cards_major.json',
    'assets/tarot/cards_wands_cups.json',
    'assets/tarot/cards_swords_pentacles.json',
  ];

  static Future<List<TarotCard>> load() async {
    if (_cards != null) return _cards!;
    final cards = <TarotCard>[];
    for (final path in _assetPaths) {
      final list = jsonDecode(await rootBundle.loadString(path)) as List<dynamic>;
      cards.addAll(list.map((e) => TarotCard.fromJson(e as Map<String, dynamic>)));
    }
    cards.sort((a, b) => a.id.compareTo(b.id));
    return _cards = List.unmodifiable(cards);
  }

  /// 정/역방향 무작위 결정 (정방향 확률 약 65% — 체감 밸런스용)
  static bool drawReversed() => _random.nextInt(100) >= 65;
}
