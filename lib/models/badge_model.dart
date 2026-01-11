// Simple Badge Model
import 'package:flutter/material.dart';

class PokemonBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  PokemonBadge({
    required this.id,
    required this.name, 
    required this.description, 
    required this.icon, 
    required this.isUnlocked
  });
}