import 'package:flutter/material.dart';
import 'PlayingCard.dart';

class Player {
  final String name;
  List<PlayingCard> hand = [];
  bool calledCabo = false;
  int totalScore = 0;
  int roundScore = 0;

  Player({required this.name});

  int calculateScore() {
    // Calculate score based on cards in hand
    roundScore = hand.fold(0, (sum, card) => sum + card.points);
    return roundScore;
  }
}
