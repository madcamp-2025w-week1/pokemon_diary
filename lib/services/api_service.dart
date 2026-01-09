import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/pokemon_model.dart';

class PokemonApiService {
  static const String _csvAssetPath = 'assets/data/pokemon_data.csv';

  List<Pokemon>? _cache;

  Future<List<Pokemon>> getAllPokemon() async {
    if (_cache != null) return _cache!;

    final rawCsv = await rootBundle.loadString(_csvAssetPath);
    final rows = const CsvToListConverter().convert(rawCsv);

    if (rows.isEmpty) {
      _cache = [];
      return _cache!;
    }

    final headerRow = rows.first.map((e) => e.toString()).toList();
    // Map header names to indexes to keep CSV order flexible.
    final headerIndex = <String, int>{
      for (var i = 0; i < headerRow.length; i++) headerRow[i]: i,
    };

    final pokemonList = <Pokemon>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowMap = <String, String>{};
      for (final entry in headerIndex.entries) {
        final value = entry.value < row.length ? row[entry.value] : '';
        rowMap[entry.key] = value?.toString() ?? '';
      }
      pokemonList.add(Pokemon.fromCsvMap(rowMap));
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
}