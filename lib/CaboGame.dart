import 'dart:math';
import 'package:flutter/material.dart';
import 'Player.dart';
import 'PlayingCard.dart';

enum GamePhase { dealing, playing, roundEnd, gameOver }
enum PlayerAction { none, drewFromDeck, drewFromDiscard }

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

// Game action methods will be added here

  PlayerAction lastAction = PlayerAction.none;
  PlayingCard? drawnCard;

  // Add this method to draw from discard
  PlayingCard? drawFromDiscard() {
    if (discardPile.isEmpty) return null;

    drawnCard = discardPile.removeLast();
    if (discardPile.isNotEmpty) {
      topDiscard = discardPile.last;
    } else {
      topDiscard = null;
    }
    lastAction = PlayerAction.drewFromDiscard;
    return drawnCard;
  }

  // Modify drawCard method to track state
  PlayingCard drawCard() {
    if (deck.isEmpty) {
      // Reshuffle discard pile except top card if deck is empty
      PlayingCard top = discardPile.removeLast();
      deck.addAll(discardPile);
      discardPile = [top];
      deck.shuffle(Random());
    }

    drawnCard = deck.removeAt(0);
    lastAction = PlayerAction.drewFromDeck;
    return drawnCard!;
  }

  // Add method to play drawn card
  void playDrawnCard(int handIndex) {
    if (drawnCard == null) return;

    // Replace the card at the specified index with the drawn card
    PlayingCard oldCard = players[currentPlayerIndex].hand[handIndex];
    players[currentPlayerIndex].hand[handIndex] = drawnCard!;

    // Add the replaced card to the discard pile
    discardPile.add(oldCard);
    topDiscard = oldCard;

    drawnCard = null;
    lastAction = PlayerAction.none;
  }

  // Add method to discard drawn card
  void discardDrawnCard() {
    if (drawnCard == null) return;

    // Add the drawn card to the discard pile
    discardPile.add(drawnCard!);
    topDiscard = drawnCard!;

    drawnCard = null;
    lastAction = PlayerAction.none;
  }

  void nextPlayer() {
    // Reset state before changing players
    drawnCard = null;
    lastAction = PlayerAction.none;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

}