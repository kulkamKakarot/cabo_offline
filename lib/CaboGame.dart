import 'dart:math';
import 'package:flutter/material.dart';
import 'Player.dart';
import 'PlayingCard.dart';

enum GamePhase { dealing, playing, roundEnd, gameOver }

class CaboGame {
  List<Player> players = [];
  List<PlayingCard> deck = [];
  List<PlayingCard> discardPile = [];
  int currentPlayerIndex = 0;
  GamePhase gamePhase = GamePhase.dealing;
  PlayingCard? topDiscard;

  CaboGame() {
    initializeGame();
  }

  void initializeGame() {
    // Initialize players
    players = [
      Player(name: "Player 1"),
      Player(name: "Player 2"),
    ];

    // Create and shuffle a standard deck
    createDeck();

    // Deal cards to players
    dealInitialCards();

    // Flip top card to start discard pile
    topDiscard = drawCard();
    topDiscard!.isFaceUp = true;
    discardPile.add(topDiscard!);

    gamePhase = GamePhase.playing;
  }

  void createDeck() {
    deck = [];
    List<String> suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    for (var suit in suits) {
      for (int value = 1; value <= 13; value++) {
        deck.add(PlayingCard(value: value, suit: suit));
      }
    }

    // Shuffle deck
    deck.shuffle(Random());
  }

  void dealInitialCards() {
    // In Cabo, each player typically gets 4 cards
    for (var player in players) {
      for (int i = 0; i < 4; i++) {
        player.hand.add(drawCard());
      }
    }
  }

  PlayingCard drawCard() {
    if (deck.isEmpty) {
      // Reshuffle discard pile except top card if deck is empty
      PlayingCard top = discardPile.removeLast();
      deck.addAll(discardPile);
      discardPile = [top];
      deck.shuffle(Random());
    }
    return deck.removeAt(0);
  }

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

// Game action methods will be added here
}