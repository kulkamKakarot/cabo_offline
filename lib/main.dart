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
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
/*
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
          _buildMiddleArea(),
         /* Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Draw pile
                _buildDeckPile(),

                // Discard pile
                _buildDiscardPile(),
              ],
            ),
          ),*/

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

  Widget _buildCard(PlayingCard card, {bool isDrawnCard = false}) {
    bool isInCurrentPlayerHand = false;
    int? cardIndex;

    // Check if this card belongs to the current player
    if (!isDrawnCard && game.players[game.currentPlayerIndex].hand.contains(card)) {
      isInCurrentPlayerHand = true;
      cardIndex = game.players[game.currentPlayerIndex].hand.indexOf(card);
    }

    return GestureDetector(
      onTap: () {
        if (game.drawnCard != null && isInCurrentPlayerHand) {
          setState(() {
            // Exchange the card with drawn card
            game.playDrawnCard(cardIndex!);
          });
        } else if (isInCurrentPlayerHand) {
          setState(() {
            // Flip the card
            card.isFaceUp = !card.isFaceUp;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 80,
        width: 60,
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: game.drawnCard != null && isInCurrentPlayerHand
                ? Colors.green
                : (isDrawnCard ? Colors.purple : Colors.black),
            width: (game.drawnCard != null && isInCurrentPlayerHand) || isDrawnCard ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (card.isFaceUp)
              Center(
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
              ),
            if (game.drawnCard != null && isInCurrentPlayerHand)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckPile() {
    return GestureDetector(
      onTap: () {
        // Only allow drawing if no card is currently drawn
        if (game.lastAction == PlayerAction.none) {
          setState(() {
            PlayingCard drawnCard = game.drawCard();
            drawnCard.isFaceUp = true; // Show the card to the player
          });
        }
      },
      child: Container(
        height: 100,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: game.lastAction == PlayerAction.none ? Colors.yellow : Colors.black,
            width: game.lastAction == PlayerAction.none ? 2 : 1,
          ),
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

  Widget _buildMiddleArea() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Drawn card display
          if (game.drawnCard != null)
            Column(
              children: [
                Text(
                  'Drawn Card',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildCard(game.drawnCard!, isDrawnCard: true),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          game.discardDrawnCard();
                        });
                      },
                      child: const Text('Discard'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        // Show instruction to tap a card for exchange
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tap any of your cards to exchange'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Exchange'),
                    ),
                  ],
                ),
              ],
            ),
          SizedBox(height: 24),
          // Draw and discard piles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDeckPile(),
              _buildDiscardPile(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscardPile() {
    return GestureDetector(
      onTap: () {
        // Only allow drawing if it's the start of the player's turn
        if (game.lastAction == PlayerAction.none && game.topDiscard != null) {
          setState(() {
            PlayingCard? drawnCard = game.drawFromDiscard();
            if (drawnCard != null) {
              drawnCard.isFaceUp = true; // Show the card to the player
              // The card remains in the game's drawnCard field until played or discarded
            }
          });
        }
      },
      child: game.topDiscard != null
          ? Stack(
        children: [
          _buildCard(game.topDiscard!),
          if (game.lastAction == PlayerAction.none)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      )
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
          if (game.drawnCard != null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  game.discardDrawnCard();
                });
              },
              child: const Text('Discard Card'),
            ),
          ElevatedButton(
            onPressed: game.drawnCard != null ? null : () {
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
} */

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CaboGame game;

  // For swap card action
  int? selectedPlayerIndex;
  int? selectedCardIndex;

  // For displaying messages
  String statusMessage = "Game started";

  @override
  void initState() {
    super.initState();
    game = CaboGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cabo - Round ${game.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status message
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              statusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Player scores
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: game.players.map((player) =>
                  Text('${player.name}: ${player.totalScore} pts',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ).toList(),
            ),
          ),

          // Player 2 hand (top)
          _buildPlayerHand(game.players[1], isCurrentPlayer: game.currentPlayerIndex == 1),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Drawn card display (if there is one)
                if (game.drawnCard != null)
                  Flexible(
                    child: _buildDrawnCard(game.drawnCard!),
                  ),

                const SizedBox(height: 16),

                // Draw and discard piles
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDeckPile(),
                      _buildDiscardPile(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Player 1 hand (bottom)
          _buildPlayerHand(game.players[0], isCurrentPlayer: game.currentPlayerIndex == 0),

          // Game controls (simplified, as drawn card actions moved to card display)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: game.currentPlayerIndex == 0 && !game.isLastRound
                      ? () {
                    setState(() {
                      game.callCabo();
                      statusMessage = "You called Cabo! Last round starting.";
                    });
                  }
                      : null,
                  child: const Text('Call Cabo'),
                ),
                ElevatedButton(
                  onPressed: game.drawnCard == null && game.pendingSpecialAction == SpecialAction.none
                      ? () {
                    setState(() {
                      game.nextPlayer();
                      statusMessage = "Turn ended. ${game.players[game.currentPlayerIndex].name}'s turn.";
                    });
                  }
                      : null,
                  child: const Text('End Turn'),
                ),
              ],
            ),
          ),

          // Special action controls
          if (game.pendingSpecialAction != SpecialAction.none)
            _buildSpecialActionControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerHand(Player player, {required bool isCurrentPlayer}) {
    bool isOpponent = player != game.players[game.currentPlayerIndex];
    int playerIndex = game.players.indexOf(player);

    return Container(
      padding: const EdgeInsets.all(16),
      color: isCurrentPlayer ? Colors.green.shade100 : Colors.transparent,
      child: Column(
        children: [
          Text(
              '${player.name}${player.calledCabo ? " (Called Cabo)" : ""}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(player.hand.length, (index) {
              return _buildCardWidget(player.hand[index], playerIndex, index, isOpponent);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(PlayingCard card, int playerIndex, int cardIndex, bool isOpponent) {
    // Determine if this card can be selected for exchange
    bool canExchange = game.drawnCard != null && playerIndex == game.currentPlayerIndex;

    // Special actions logic
    bool canSelect = false;
    if (game.pendingSpecialAction == SpecialAction.swap) {
      if (selectedPlayerIndex == null) {
        canSelect = true;
      } else if (selectedPlayerIndex != null && selectedCardIndex != null) {
        canSelect = false;
      } else {
        canSelect = playerIndex != selectedPlayerIndex;
      }
    }
    else if (game.pendingSpecialAction == SpecialAction.peekOwn) {
      // Can only select your own cards
      canSelect = playerIndex == game.currentPlayerIndex && !card.isFaceUp;
    }
    else if (game.pendingSpecialAction == SpecialAction.peekOpponent) {
      // Can only select opponent's cards
      canSelect = playerIndex != game.currentPlayerIndex && !card.isFaceUp;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          // Special actions logic
          if (game.pendingSpecialAction == SpecialAction.peekOwn) {
            if (playerIndex == game.currentPlayerIndex && !card.isFaceUp) {
              card.isFaceUp = true;
              // Just a quick peek, then flip back
              Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  card.isFaceUp = false;
                  game.pendingSpecialAction = SpecialAction.none;
                  statusMessage = "Card peeked. Continue your turn.";
                });
              });
            }
          }

          else if (game.pendingSpecialAction == SpecialAction.peek) {
            game.peekAtCard(playerIndex, cardIndex);
            statusMessage = "Peeked at card!";
          }
          else if (game.pendingSpecialAction == SpecialAction.swap) {
            if (selectedPlayerIndex == null) {
              selectedPlayerIndex = playerIndex;
              selectedCardIndex = cardIndex;
              statusMessage = "Selected first card. Now select another card to swap with.";
            } else if (selectedPlayerIndex != null && selectedCardIndex != null) {
              game.swapCards(selectedPlayerIndex!, selectedCardIndex!, playerIndex, cardIndex);
              statusMessage = "Cards swapped!";
              selectedPlayerIndex = null;
              selectedCardIndex = null;
            }
          }

          else if (game.pendingSpecialAction == SpecialAction.peekOpponent) {
            if (playerIndex != game.currentPlayerIndex && !card.isFaceUp) {
              card.isFaceUp = true;
              // Just a quick peek, then flip back
              Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  card.isFaceUp = false;
                  game.pendingSpecialAction = SpecialAction.none;
                  statusMessage = "Opponent's card peeked. Continue your turn.";
                });
              });
            }
          }
          // Exchange drawn card with this card
          else if (canExchange) {
            game.playDrawnCard(cardIndex);
            statusMessage = "Card exchanged successfully!";
          }
          // Just flipping your own cards
          else if (playerIndex == game.currentPlayerIndex && !isOpponent) {
            card.isFaceUp = !card.isFaceUp;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 80,
        width: 60,
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canExchange
                ? Colors.green
                : (canSelect ? Colors.yellow :
            (selectedPlayerIndex == playerIndex && selectedCardIndex == cardIndex)
                ? Colors.orange : Colors.black),
            width: canExchange || canSelect ||
                (selectedPlayerIndex == playerIndex && selectedCardIndex == cardIndex) ? 2 : 1,
          ),
          boxShadow: canExchange ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Stack(
          children: [
            if (card.isFaceUp)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getCardValueDisplay(card),
                      style: TextStyle(
                        color: _getCardColor(card),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _getSuitSymbol(card),
                      style: TextStyle(
                        color: _getCardColor(card),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            if (canExchange)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawnCard(PlayingCard card) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          height: 80,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getCardValueDisplay(card),
                  style: TextStyle(
                    color: _getCardColor(card),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _getSuitSymbol(card),
                  style: TextStyle(
                    color: _getCardColor(card),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                setState(() {
                  game.discardDrawnCard();
                  statusMessage = "Discarded drawn card.";
                });
              },
              child: const Text('Discard', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap any of your cards to exchange with this card'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  statusMessage = "Select a card to exchange with the drawn card.";
                });
              },
              child: const Text('Exchange', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  String _getCardValueDisplay(PlayingCard card) {
    if (card.value == 1) return 'A';
    if (card.value == 11) return 'J';
    if (card.value == 12) return 'Q';
    if (card.value == 13) return 'K';
    return '${card.value}';
  }

  String _getSuitSymbol(PlayingCard card) {
    if (card.suit == 'Hearts') return '♥';
    if (card.suit == 'Diamonds') return '♦';
    if (card.suit == 'Clubs') return '♣';
    if (card.suit == 'Spades') return '♠';
    return '';
  }

  Color _getCardColor(PlayingCard card) {
    return (card.suit == 'Hearts' || card.suit == 'Diamonds') ? Colors.red : Colors.black;
  }

  Widget _buildDeckPile() {
    return GestureDetector(
      onTap: () {
        // Only allow drawing if it's the current player's turn and they haven't drawn yet
        if (game.lastAction == PlayerAction.none && game.gamePhase == GamePhase.playing) {
          setState(() {
            PlayingCard drawnCard = game.drawCard();
            drawnCard.isFaceUp = true; // Show the card to the player
            statusMessage = "Drew a card from the deck.";

            // If it's a special card, show appropriate message
            if (game.pendingSpecialAction != SpecialAction.none) {
              statusMessage = _getSpecialActionMessage(game.pendingSpecialAction);
            }
          });
        }
      },
      child: Container(
        height: 100,
        width: 70,
        decoration: BoxDecoration(
          color: (game.lastAction == PlayerAction.none && game.gamePhase == GamePhase.playing)
              ? Colors.blue
              : Colors.grey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'DRAW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(${game.deck.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscardPile() {
    return GestureDetector(
      onTap: () {
        // Only allow drawing if it's the start of the player's turn
        if (game.lastAction == PlayerAction.none && game.topDiscard != null && game.gamePhase == GamePhase.playing) {
          setState(() {
            PlayingCard? drawnCard = game.drawFromDiscard();
            if (drawnCard != null) {
              statusMessage = "Drew ${drawnCard.value} of ${drawnCard.suit} from discard pile.";

              // If it's a special card, show appropriate message
              if (game.pendingSpecialAction != SpecialAction.none) {
                statusMessage = _getSpecialActionMessage(game.pendingSpecialAction);
              }
            }
          });
        }
      },
      child: game.topDiscard != null
          ? Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (game.lastAction == PlayerAction.none && game.gamePhase == GamePhase.playing)
                    ? Colors.yellow
                    : Colors.black,
                width: (game.lastAction == PlayerAction.none && game.gamePhase == GamePhase.playing) ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getCardValueDisplay(game.topDiscard!),
                    style: TextStyle(
                      color: _getCardColor(game.topDiscard!),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _getSuitSymbol(game.topDiscard!),
                    style: TextStyle(
                      color: _getCardColor(game.topDiscard!),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
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
      ),
    );
  }

  Widget _buildGameControls() {
    // Show different controls based on game phase
    if (game.gamePhase == GamePhase.gameOver) {
      return _buildGameOverControls();
    } else if (game.gamePhase == GamePhase.roundEnd) {
      return _buildRoundEndControls();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: game.currentPlayerIndex == 0 && !game.isLastRound
                ? () {
              setState(() {
                game.callCabo();
                statusMessage = "You called Cabo! Last round starting.";
              });
            }
                : null,
            child: const Text('Call Cabo'),
          ),
          if (game.drawnCard != null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  game.discardDrawnCard();
                  statusMessage = "Discarded drawn card.";
                });
              },
              child: const Text('Discard Card'),
            ),
          ElevatedButton(
            onPressed: game.drawnCard == null && game.pendingSpecialAction == SpecialAction.none
                ? () {
              setState(() {
                game.nextPlayer();
                statusMessage = "Turn ended. ${game.players[game.currentPlayerIndex].name}'s turn.";
              });
            }
                : null,
            child: const Text('End Turn'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverControls() {
    // Find the winner (lowest score)
    int lowestScore = 999;
    Player? winner;

    for (var player in game.players) {
      if (player.totalScore < lowestScore) {
        lowestScore = player.totalScore;
        winner = player;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Game Over! ${winner?.name} wins with $lowestScore points!",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              game = CaboGame(); // Start a new game
              statusMessage = "New game started.";
            });
          },
          child: const Text('Start New Game'),
        ),
      ],
    );
  }

  Widget _buildRoundEndControls() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Round ${game.roundNumber} ended!",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Show each player's round score
        ...game.players.map((player) => Text(
          "${player.name}: +${player.roundScore} points (Total: ${player.totalScore})",
          style: const TextStyle(fontSize: 16),
        )),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              game.resetForNewRound();
              statusMessage = "Round ${game.roundNumber} started.";
            });
          },
          child: const Text('Start Next Round'),
        ),
      ],
    );
  }

  Widget _buildSpecialActionControls() {
    String actionInstructions = _getSpecialActionMessage(game.pendingSpecialAction);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            actionInstructions,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          if (game.pendingSpecialAction == SpecialAction.swap && selectedPlayerIndex != null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPlayerIndex = null;
                  selectedCardIndex = null;
                  statusMessage = "Swap cancelled.";
                });
              },
              child: const Text('Cancel Selection'),
            ),
        ],
      ),
    );
  }

  String _getSpecialActionMessage(SpecialAction action) {
    switch (action) {
      case SpecialAction.peekOwn:
        return "Special ability: Tap one of your cards to peek at it.";
      case SpecialAction.peekOpponent:
        return "Special ability: Tap an opponent's card to peek at it.";
      case SpecialAction.swap:
        return "Special ability: Tap cards to swap them.";
      case SpecialAction.drawTwo:
        return "Special ability: Draw two more cards.";
      default:
        return "";
    }
  }
}