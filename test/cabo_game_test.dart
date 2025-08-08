import 'package:flutter_test/flutter_test.dart';
import 'package:cabo_offline/CaboGame.dart';
import 'package:cabo_offline/PlayingCard.dart';

void main() {
  test('reshuffled discard cards are turned face down', () {
    final game = CaboGame();

    // Empty the deck to trigger reshuffle
    game.deck.clear();
    // Create a discard pile with two face-up cards
    game.discardPile = [
      PlayingCard(value: 5, suit: 'Hearts', isFaceUp: true),
      PlayingCard(value: 7, suit: 'Spades', isFaceUp: true),
    ];
    game.topDiscard = game.discardPile.last;

    // Draw a card to force deck reshuffle from discard pile
    final card = game.drawCard();

    // The drawn card should have been turned face down before drawing
    expect(card.isFaceUp, isFalse);
    // Remaining cards in deck should also be face down
    expect(game.deck.every((c) => c.isFaceUp == false), isTrue);
  });
}
