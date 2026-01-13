import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PokedexProvider extends ChangeNotifier {
  final PokemonApiService _apiService = PokemonApiService();

  // Cache the full list so we don't parse CSV repeatedly
  List<Pokemon> _allPokemon = [];
  bool _isLoading = false;

  // Getters
  List<Pokemon> get allPokemon => List.unmodifiable(_allPokemon);
  bool get isLoading => _isLoading;

  /// Load the CSV Data (Called once on startup or first tab view)
  Future<void> loadPokedex() async {
    // If data is already cached, skip loading
    if (_allPokemon.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _allPokemon = await _apiService.getAllPokemon();
    } catch (e) {
      debugPrint("Error loading Pokedex: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}