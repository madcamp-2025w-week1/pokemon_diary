import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PokedexProvider extends ChangeNotifier {
  final PokemonApiService _apiService = PokemonApiService();

  // Cache the full list so we don't parse CSV repeatedly
  List<Pokemon> _allPokemon = [];
  
  // Cache the owned IDs for fast O(1) lookups
  Set<int> _ownedIds = {};
  
  bool _isLoading = false;

  // Getters
  List<Pokemon> get allPokemon => List.unmodifiable(_allPokemon);
  bool get isLoading => _isLoading;
  int get totalCaught => _ownedIds.length;

  /// Helper to check ownership in UI
  bool isOwned(int id) => _ownedIds.contains(id);

  /// 1. Load the CSV Data (Called once on startup or first tab view)
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

  /// 2. Sync with DiaryProvider
  /// Call this whenever the diary list changes so the Pokedex updates immediately
  void updateOwnedList(List<Diary> diaries) {
    final newOwned = diaries.map((d) => d.pokemonId).toSet();
    
    // Optimization: Only notify listeners if the set actually changed
    if (newOwned.length != _ownedIds.length || !newOwned.containsAll(_ownedIds)) {
      _ownedIds = newOwned;
      notifyListeners();
    }
  }
}