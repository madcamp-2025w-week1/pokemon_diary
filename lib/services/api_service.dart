import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

class PokemonApiService {
  static const String _coreCsvPath = 'assets/data/pokemon_core.csv';
  
  // Define your two paths
  static const String _modernSpritePath = 'assets/data/pokemon_sprites_modern.csv';
  static const String _retroSpritePath = 'assets/data/pokemon_sprites_retro.csv'; // Ensure this file exists!

  List<Pokemon>? _cache;

  /// Added optional parameters to control style and forcing a refresh
  Future<List<Pokemon>> getAllPokemon({bool isRetro = false, bool forceRefresh = false}) async {
    // Return cache if available and we aren't forcing a refresh
    if (_cache != null && !forceRefresh) return _cache!;

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
    return pokemonList;
  }
  
  // ... (rest of the file: getPokemonById, _loadCsvAsIdMap remains the same)
  Future<Pokemon?> getPokemonById(int id) async {
      // If we call this directly, it might use the old cache. 
      // Usually better to ensure getAllPokemon is called with correct flags first.
      final allPokemon = await getAllPokemon(); 
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
      print("Error loading CSV $path: $e");
      return {};
    }
  }
}