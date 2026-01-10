import 'dart:math';

import 'package:pokemon_diary/models/models.dart';

class GachaLogic {
  // Define the relationship between Emotions and PokemonTypes
  static const Map<String, List<PokemonType>> _emotionTypeMap = {
    'joy': [PokemonType.electric, PokemonType.flying, PokemonType.fairy],
    'sad': [PokemonType.water, PokemonType.ghost, PokemonType.ice, PokemonType.poison, PokemonType.ground],
    'angry': [PokemonType.fire, PokemonType.fighting, PokemonType.dragon, PokemonType.dark],
    'calm': [PokemonType.grass, PokemonType.normal, PokemonType.bug, PokemonType.psychic, PokemonType.steel, PokemonType.rock],
  };
  int draftRandomPokemon() {
    final random = Random();
    return random.nextInt(151) + 1;
  }
}