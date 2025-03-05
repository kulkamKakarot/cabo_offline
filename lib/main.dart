import 'package:flutter/material.dart';
import 'CaboGame.dart';
import 'Player.dart';
import 'PlayingCard.dart';

void main() {
  runApp(const CaboApp());
}

class CaboApp extends StatelessWidget {
  const CaboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cabo Card Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CaboGame game;

  @override
  void initState() {
    super.initState();
    game = CaboGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cabo Card Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Player 2 hand (top)
          _buildPlayerHand(game.players[1], isCurrentPlayer: game.currentPlayerIndex == 1),

          // Middle area with draw and discard piles
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Draw pile
                _buildDeckPile(),

                // Discard pile
                _buildDiscardPile(),
              ],
            ),
          ),

          // Player 1 hand (bottom)
          _buildPlayerHand(game.players[0], isCurrentPlayer: game.currentPlayerIndex == 0),

          // Game controls
          _buildGameControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerHand(Player player, {required bool isCurrentPlayer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isCurrentPlayer ? Colors.green.shade100 : Colors.transparent,
      child: Column(
        children: [
          Text(player.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: player.hand.map((card) => _buildCard(card)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PlayingCard card) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // For demonstration, flip the card when tapped
          card.isFaceUp = !card.isFaceUp;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 80,
        width: 60,
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: card.isFaceUp
            ? Center(
          child: Text(
            '${card.value}\n${card.suit[0]}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: card.suit == 'Hearts' || card.suit == 'Diamonds'
                  ? Colors.red
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildDeckPile() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (game.deck.isNotEmpty) {
            PlayingCard drawnCard = game.drawCard();
            drawnCard.isFaceUp = true; // Show the card to the player

            // For demonstration, add to current player's hand
            game.players[game.currentPlayerIndex].hand.add(drawnCard);
          }
        });
      },
      child: Container(
        height: 100,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: const Center(
          child: Text(
            'DRAW',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscardPile() {
    return game.topDiscard != null
        ? _buildCard(game.topDiscard!)
        : Container(
      height: 100,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      child: const Center(
        child: Text(
          'DISCARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle "Call Cabo" action
            },
            child: const Text('Call Cabo'),
          ),
          ElevatedButton(
            onPressed: () {
              // End turn
              setState(() {
                game.nextPlayer();
              });
            },
            child: const Text('End Turn'),
          ),
        ],
      ),
    );
  }
}