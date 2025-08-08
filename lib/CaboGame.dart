import 'dart:math';
import 'package:flutter/material.dart';
import 'Player.dart';
import 'PlayingCard.dart';

enum GamePhase { dealing, playing, roundEnd, gameOver }
enum PlayerAction { none, drewFromDeck, drewFromDiscard }
enum SpecialAction { none, peek, swap, drawTwo, peekOwn, peekOpponent }

class CaboGame {
  List<Player> players = [];
  List<PlayingCard> deck = [];
  List<PlayingCard> discardPile = [];
  int currentPlayerIndex = 0;
  GamePhase gamePhase = GamePhase.dealing;
  PlayingCard? topDiscard;
  PlayerAction lastAction = PlayerAction.none;
  PlayingCard? drawnCard;
  SpecialAction pendingSpecialAction = SpecialAction.none;
  int roundNumber = 1;
  int lastRoundPlayerIndex = -1;
  int caboCallerIndex = -1;

  bool isLastRound = false;
  String statusMessage = "";

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
      player.hand.clear();
      for (int i = 0; i < 4; i++) {
        PlayingCard card = drawCard();
        // In Cabo, players initially see 2 of their cards
        if (i < 2) {
          card.isFaceUp = true;
        }
        player.hand.add(card);
      }
    }
  }

  PlayingCard? drawFromDiscard() {
    if (discardPile.isEmpty) return null;

    drawnCard = discardPile.removeLast();
    if (discardPile.isNotEmpty) {
      topDiscard = discardPile.last;
    } else {
      topDiscard = null;
    }
    lastAction = PlayerAction.drewFromDiscard;
    
    // Check for special card abilities
    checkSpecialCardAbilities(drawnCard!);
    
    return drawnCard;
  }

  PlayingCard drawCard() {
    if (deck.isEmpty && discardPile.isNotEmpty) {
      // Reshuffle discard pile except the top card if deck is empty
      PlayingCard top = discardPile.removeLast();

      // Turn the rest of the discard pile face down before shuffling
      for (var card in discardPile) {
        card.isFaceUp = false;
      }

      deck.addAll(discardPile);
      discardPile = [top];
      deck.shuffle(Random());
      topDiscard = top;
    }

    if (deck.isEmpty) {
      // If still empty, game is over
      gamePhase = GamePhase.gameOver;
      return PlayingCard(value: 0, suit: 'None');
    }

    drawnCard = deck.removeAt(0);
    lastAction = PlayerAction.drewFromDeck;
    
    // Check for special card abilities
    checkSpecialCardAbilities(drawnCard!);
    
    return drawnCard!;
  }

  void checkSpecialCardAbilities(PlayingCard card) {
    // In Cabo, only J, Q, K have abilities when drawn
    if (card.value == 11 || card.value == 12) {
      // Swap one of your cards with an opponent's card
      pendingSpecialAction = SpecialAction.swap;
    } else if (card.value == 13) {
      // Draw two cards, then discard three
      pendingSpecialAction = SpecialAction.drawTwo;
    }
  }

  void playDrawnCard(int handIndex) {
    if (drawnCard == null) return;

    // Replace the card at the specified index with the drawn card
    PlayingCard oldCard = players[currentPlayerIndex].hand[handIndex];
    players[currentPlayerIndex].hand[handIndex] = drawnCard!;

    // Add the replaced card to the discard pile
    oldCard.isFaceUp = true; // Show the discarded card
    discardPile.add(oldCard);
    topDiscard = oldCard;

    drawnCard = null;
    lastAction = PlayerAction.none;
    pendingSpecialAction = SpecialAction.none;
  }

  void discardDrawnCard() {
    if (drawnCard == null) return;

    // Check special abilities before adding to discard pile
    if (drawnCard!.value == 7 || drawnCard!.value == 8) {
      // Player can look at one of their own cards
      pendingSpecialAction = SpecialAction.peekOwn;
      statusMessage = "You discarded a ${drawnCard!.value}. You may peek at one of your cards.";
    } else if (drawnCard!.value == 9 || drawnCard!.value == 10) {
      // Player can look at one opponent's card
      pendingSpecialAction = SpecialAction.peekOpponent;
      statusMessage = "You discarded a ${drawnCard!.value}. You may peek at one opponent's card.";
    }

    // Add the drawn card to the discard pile
    drawnCard!.isFaceUp = true; // Make sure it's face up
    discardPile.add(drawnCard!);
    topDiscard = drawnCard!;

    drawnCard = null;
    lastAction = PlayerAction.none;

    // Don't reset pendingSpecialAction here as we need it for the special action
  }

  void nextPlayer() {
    // Reset state before changing players
    drawnCard = null;
    lastAction = PlayerAction.none;
    pendingSpecialAction = SpecialAction.none;
    
    // Move to next player
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    
    // Check if this is the final round
    if (isLastRound && currentPlayerIndex == lastRoundPlayerIndex) {
      endRound();
    }
  }

  void callCabo() {
    if (caboCallerIndex == -1) {
      // First time Cabo is called
      caboCallerIndex = currentPlayerIndex;
      isLastRound = true;
      lastRoundPlayerIndex = currentPlayerIndex;
      players[currentPlayerIndex].calledCabo = true;
    }
  }

  void endRound() {
    // Calculate scores for each player
    for (var player in players) {
      // Sort hand by value for scoring
      player.hand.sort((a, b) => a.value.compareTo(b.value));
      
      // Make all cards face up for scoring
      for (var card in player.hand) {
        card.isFaceUp = true;
      }
      
      // Calculate score for this round
      int roundScore = player.calculateScore();
      
      // Add to total score
      player.totalScore += roundScore;
      
      // Reset cabo flag
      player.calledCabo = false;
    }
    
    // If the Cabo caller has the lowest score, they get 0 points
    // If not, they get a penalty of 10 points
    if (caboCallerIndex != -1) {
      int lowestScore = 999;
      int lowestScoreIndex = -1;
      
      for (int i = 0; i < players.length; i++) {
        int score = players[i].calculateScore();
        if (score < lowestScore) {
          lowestScore = score;
          lowestScoreIndex = i;
        }
      }
      
      if (lowestScoreIndex != caboCallerIndex) {
        // Penalty for wrong Cabo call
        players[caboCallerIndex].totalScore += 10;
      }
    }
    
    // Check if game is over (player reached 100 points)
    bool gameOver = false;
    for (var player in players) {
      if (player.totalScore >= 100) {
        gameOver = true;
      }
    }
    
    if (gameOver) {
      gamePhase = GamePhase.gameOver;
    } else {
      // Prepare for next round
      roundNumber++;
      resetForNewRound();
    }
  }

  void resetForNewRound() {
    // Reset variables
    isLastRound = false;
    lastRoundPlayerIndex = -1;
    caboCallerIndex = -1;
    
    // Create new deck
    createDeck();
    
    // Clear discard pile
    discardPile.clear();
    
    // Deal new cards
    dealInitialCards();
    
    // Flip top card to start discard pile
    topDiscard = drawCard();
    topDiscard!.isFaceUp = true;
    discardPile.add(topDiscard!);
    
    // Set game phase
    gamePhase = GamePhase.playing;
    
    // Start with a random player
    currentPlayerIndex = Random().nextInt(players.length);
  }

  // Methods for special card abilities
  void peekAtCard(int playerIndex, int cardIndex) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    if (cardIndex < 0 || cardIndex >= players[playerIndex].hand.length) return;
    
    // Make the card visible temporarily
    players[playerIndex].hand[cardIndex].isFaceUp = true;
    
    // Special action is completed
    pendingSpecialAction = SpecialAction.none;
  }

  void swapCards(int playerIndex1, int cardIndex1, int playerIndex2, int cardIndex2) {
    if (playerIndex1 < 0 || playerIndex1 >= players.length) return;
    if (playerIndex2 < 0 || playerIndex2 >= players.length) return;
    if (cardIndex1 < 0 || cardIndex1 >= players[playerIndex1].hand.length) return;
    if (cardIndex2 < 0 || cardIndex2 >= players[playerIndex2].hand.length) return;
    
    // Swap the cards
    PlayingCard temp = players[playerIndex1].hand[cardIndex1];
    players[playerIndex1].hand[cardIndex1] = players[playerIndex2].hand[cardIndex2];
    players[playerIndex2].hand[cardIndex2] = temp;
    
    // Special action is completed
    pendingSpecialAction = SpecialAction.none;
  }
}
