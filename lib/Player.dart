import 'package:flutter/material.dart';
import 'PlayingCard.dart';

class Player {
  final String name;
  List<PlayingCard> hand = [];
  bool calledCabo = false;

  Player({required this.name});

  int calculateScore() {
    return hand.fold(0, (sum, card) => sum + card.points);
  }
}