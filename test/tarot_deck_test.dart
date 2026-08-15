import 'package:flutter_test/flutter_test.dart';
import 'package:fatesight/services/tarot_deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deck has 78 unique cards with complete bilingual fields', () async {
    final deck = await TarotDeck.load();
    expect(deck.length, 78);
    expect(deck.map((c) => c.id).toSet().length, 78);
    expect(deck.map((c) => c.nameEn).toSet().length, 78);

    final suits = <String, int>{};
    for (final c in deck) {
      suits[c.suit] = (suits[c.suit] ?? 0) + 1;
      for (final field in [
        c.nameKo, c.nameEn,
        c.meaningKo, c.meaningEn,
        c.reversedKo, c.reversedEn,
        c.fortuneKo, c.fortuneEn,
      ]) {
        expect(field.trim(), isNotEmpty, reason: 'empty field on card ${c.id}');
      }
    }
    expect(suits, {'major': 22, 'wands': 14, 'cups': 14, 'swords': 14, 'pentacles': 14});
  });

  test('ids are sequential 0..77 after load', () async {
    final deck = await TarotDeck.load();
    for (var i = 0; i < deck.length; i++) {
      expect(deck[i].id, i);
    }
  });
}
