import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

class PokemonApiService {
  // 1. Core Data (Stats, Names, Descriptions)
  static const String _coreCsvPath = 'assets/data/pokemon_core.csv';

  // 2. Sprite Data (Hardcoded Artstyle Selection)
  // CHANGE THIS LINE to 'assets/data/pokemon_sprites_modern.csv' to switch styles.
  static const String _spriteCsvPath = 'assets/data/pokemon_sprites_modern.csv';

  List<Pokemon>? _cache;

  Future<List<Pokemon>> getAllPokemon() async {
    if (_cache != null) return _cache!;

    // 1. Load both files in parallel for performance
    final results = await Future.wait([
      _loadCsvAsIdMap(_coreCsvPath),
      _loadCsvAsIdMap(_spriteCsvPath),
    ]);

    final coreDataMap = results[0];
    final spriteDataMap = results[1];

    if (coreDataMap.isEmpty) {
      _cache = [];
      return _cache!;
    }

    final pokemonList = <Pokemon>[];

    // 2. Merge Data
    // We iterate through the Core data and try to find matching Sprite data
    for (final id in coreDataMap.keys) {
      final coreRow = coreDataMap[id]!;
      // specific sprite data for this ID, or empty map if missing
      final spriteRow = spriteDataMap[id] ?? <String, String>{};

      // Combine maps: Sprite data overwrites Core data if keys duplicate (unlikely here)
      final mergedRow = <String, String>{
        ...coreRow,
        ...spriteRow,
      };

      pokemonList.add(Pokemon.fromCsvMap(mergedRow));
    }

    _cache = pokemonList;
    return pokemonList;
  }

  Future<Pokemon?> getPokemonById(int id) async {
    final allPokemon = await getAllPokemon();
    try {
      return allPokemon.firstWhere((pokemon) => pokemon.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Helper: Reads a CSV and returns a Map<ID, RowData>
  /// This makes merging two CSVs much easier/faster than nested loops.
  Future<Map<int, Map<String, String>>> _loadCsvAsIdMap(String path) async {
    try {
      final rawCsv = await rootBundle.loadString(path);
      final rows = const CsvToListConverter().convert(rawCsv);

      if (rows.isEmpty) return {};

      // Parse Headers
      final headerRow = rows.first.map((e) => e.toString()).toList();
      final headerIndex = <String, int>{
        for (var i = 0; i < headerRow.length; i++) headerRow[i]: i,
      };

      final dataMap = <int, Map<String, String>>{};

      // Parse Rows
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final rowMap = <String, String>{};
        
        for (final entry in headerIndex.entries) {
          final value = entry.value < row.length ? row[entry.value] : '';
          rowMap[entry.key] = value?.toString() ?? '';
        }

        // We use 'id' as the key for merging
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