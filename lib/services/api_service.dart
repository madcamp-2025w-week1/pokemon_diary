import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

class PokemonApiService {
  static const String _coreCsvPath = 'assets/data/pokemon_core.csv';
  
  // Define your two paths
  static const String _modernSpritePath = 'assets/data/pokemon_sprites_modern.csv';
  static const String _retroSpritePath = 'assets/data/pokemon_sprites_retro.csv'; // Ensure this file exists!

  List<Pokemon>? _cache;
  bool? _isCacheRetro; // To track the style of the cached data

  /// Added optional parameters to control style and forcing a refresh
  Future<List<Pokemon>> getAllPokemon({bool isRetro = false, bool forceRefresh = false}) async {
    // Determine if the requested style is different from the cached one.
    final bool styleChanged = _isCacheRetro != null && _isCacheRetro != isRetro;

    // Return cache if available, not forcing refresh, and style is the same
    if (_cache != null && !forceRefresh && !styleChanged) return _cache!;

    // 1. Determine which sprite file to use
    final spritePath = isRetro ? _retroSpritePath : _modernSpritePath;

    // 2. Load files
    final results = await Future.wait([
      _loadCsvAsIdMap(_coreCsvPath),
      _loadCsvAsIdMap(spritePath),
    ]);

    final coreDataMap = results[0];
    final spriteDataMap = results[1];

    if (coreDataMap.isEmpty) {
      _cache = [];
      _isCacheRetro = isRetro;
      return _cache!;
    }

    final pokemonList = <Pokemon>[];

    for (final id in coreDataMap.keys) {
      final coreRow = coreDataMap[id]!;
      final spriteRow = spriteDataMap[id] ?? <String, String>{};

      final mergedRow = <String, String>{
        ...coreRow,
        ...spriteRow,
      };

      pokemonList.add(Pokemon.fromCsvMap(mergedRow));
    }

    _cache = pokemonList;
    _isCacheRetro = isRetro; // Update the cache style tracker
    return pokemonList;
  }
  
  // ... (rest of the file: getPokemonById, _loadCsvAsIdMap remains the same)
  Future<Pokemon?> getPokemonById(int id, {bool isRetro = false}) async {
      // The getAllPokemon method will now handle refreshing if the style has changed.
      final allPokemon = await getAllPokemon(isRetro: isRetro); 
      try {
        return allPokemon.firstWhere((pokemon) => pokemon.id == id);
      } catch (_) {
        return null;
      }
  }

  Future<Map<int, Map<String, String>>> _loadCsvAsIdMap(String path) async {
    // ... (Keep existing implementation)
    try {
      final rawCsv = await rootBundle.loadString(path);
      final rows = const CsvToListConverter().convert(rawCsv);

      if (rows.isEmpty) return {};

      final headerRow = rows.first.map((e) => e.toString()).toList();
      final headerIndex = <String, int>{
        for (var i = 0; i < headerRow.length; i++) headerRow[i]: i,
      };

      final dataMap = <int, Map<String, String>>{};

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final rowMap = <String, String>{};
        
        for (final entry in headerIndex.entries) {
          final value = entry.value < row.length ? row[entry.value] : '';
          rowMap[entry.key] = value?.toString() ?? '';
        }

        if (rowMap.containsKey('id')) {
          final id = int.tryParse(rowMap['id'] ?? '0') ?? 0;
          if (id != 0) {
            dataMap[id] = rowMap;
          }
        }
      }
      return dataMap;
    } catch (e) {
      debugPrint("Error loading CSV $path: $e");
      return {};
    }
  }
}