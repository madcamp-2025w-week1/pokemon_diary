import 'dart:math';

import 'package:pokemon_diary/models/models.dart';

import 'services.dart';

class GachaLogic {
  final Random _random = Random();

  // Define the relationship between Emotions and PokemonTypes
  static const Map<String, List<PokemonType>> _emotionTypeMap = {
    'joy': [PokemonType.electric, PokemonType.flying, PokemonType.fairy],
    'sad': [PokemonType.water, PokemonType.ghost, PokemonType.ice, PokemonType.poison, PokemonType.ground],
    'angry': [PokemonType.fire, PokemonType.fighting, PokemonType.dragon, PokemonType.dark],
    'calm': [PokemonType.grass, PokemonType.normal, PokemonType.bug, PokemonType.psychic, PokemonType.steel, PokemonType.rock],
  };
  
  Future<int> draftRandomPokemon(String sentiment, PokemonApiService apiService) async {
    // 1. Get all Pokemon from your CSV Cache
    final allPokemon = await apiService.getAllPokemon();
    
    // 2. Get allowed types for the sentiment
    // Default to 'calm' types if sentiment is unknown
    final allowedTypes = _emotionTypeMap[sentiment] ?? _emotionTypeMap['calm']!;

    // 3. Filter the list
    // We check if either type1 or type2 matches our allowed list
    final candidates = allPokemon.where((pokemon) {
      return allowedTypes.contains(pokemon.type1) || allowedTypes.contains(pokemon.type2);
    }).toList();

    // 4. Pick a winner
    if (candidates.isNotEmpty) {
      final winner = candidates[_random.nextInt(candidates.length)];
      return winner.id;
    } else {
      // Fallback (e.g., Bulbasaur) if data is missing
      return 1; 
    }
  }
}