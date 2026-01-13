import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PokedexProvider extends ChangeNotifier {
  final PokemonApiService _apiService = PokemonApiService();

  List<Pokemon> _allPokemon = [];
  bool _isLoading = false;

  List<Pokemon> get allPokemon => List.unmodifiable(_allPokemon);
  bool get isLoading => _isLoading;

  // Modified to accept style
  Future<void> loadPokedex({bool isRetro = false, bool forceRefresh = false}) async {
    if (_allPokemon.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Pass the flags down to the service
      _allPokemon = await _apiService.getAllPokemon(
        isRetro: isRetro, 
        forceRefresh: forceRefresh
      );
    } catch (e) {
      debugPrint("Error loading Pokedex: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}