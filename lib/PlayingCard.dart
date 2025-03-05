class PlayingCard {
  final int value;
  final String suit;
  bool isFaceUp;

  PlayingCard({required this.value, required this.suit, this.isFaceUp = false});

  int get points {
    // In Cabo, face cards (J, Q, K) are worth 10 points,
    // Aces are worth 1, and number cards are worth their face value
    if (value > 10) return 10;
    return value;
  }

  @override
  String toString() => isFaceUp ? '$value of $suit' : 'Face Down Card';
}