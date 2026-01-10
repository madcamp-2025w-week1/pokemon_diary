import 'dart:convert';

enum PokemonType {
  electric, flying, fairy,                    // Joy
  water, ghost, ice, ground, poison,          // Sad
  fire, fighting, dragon, dark,               // Angry
  grass, normal, bug, psychic, steel, rock    // Calm
  
}

extension PokemonTypeExtension on PokemonType {
  static PokemonType? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return PokemonType.values.firstWhere(
        (type) => type.name.toLowerCase() == value.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class Pokemon {
  final int id;
  final String englishName;
  final String koreanName;
  final String dexEntryEnglish;
  final String dexEntryKorean;
  final PokemonType type1;
  final PokemonType? type2;
  final bool isLegendary;
  final bool isMythical;
  final double height;
  final double weight;
  final String? spriteUrl;
  final String? gifUrl;
  final String? iconUrl;

  const Pokemon({
    required this.id,
    required this.englishName,
    required this.koreanName,
    required this.dexEntryEnglish,
    required this.dexEntryKorean,
    required this.type1,
    required this.type2,
    required this.isLegendary,
    required this.isMythical,
    required this.height,
    required this.weight,
    required this.spriteUrl,
    required this.gifUrl,
    required this.iconUrl,
  });

  factory Pokemon.fromCsvMap(Map<String, String> map) {
    return Pokemon(
      id: int.parse(map['id'] ?? '0'),
      englishName: map['english_name'] ?? '',
      koreanName: map['korean_name'] ?? '',
      dexEntryEnglish: map['dex_entry_english'] ?? '',
      dexEntryKorean: map['dex_entry_korean'] ?? '',
      type1: PokemonTypeExtension.tryParse(map['type_1']) ?? PokemonType.normal,
      type2: PokemonTypeExtension.tryParse(map['type_2']),
      isLegendary: _parseBool(map['is_legendary']),
      isMythical: _parseBool(map['is_mythical']),
      height: double.tryParse(map['height'] ?? '') ?? 0,
      weight: double.tryParse(map['weight'] ?? '') ?? 0,
      spriteUrl: _emptyToNull(map['sprite_url']),
      gifUrl: _emptyToNull(map['gif_url']),
      iconUrl: _emptyToNull(map['icon_url']),
    );
  }

  String get homeSpriteUrl {
    return spriteUrl ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png';
  }

  String get showdownGifUrl {
    return gifUrl ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';
  }

  String get iconSpriteUrl {
    return iconUrl ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/$id.png';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english_name': englishName,
      'korean_name': koreanName,
      'dex_entry_english': dexEntryEnglish,
      'dex_entry_korean': dexEntryKorean,
      'type_1': type1.name,
      'type_2': type2?.name,
      'is_legendary': isLegendary,
      'is_mythical': isMythical,
      'height': height,
      'weight': weight,
      'sprite_url': spriteUrl,
      'gif_url': gifUrl,
      'icon_url': iconUrl,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static String? _emptyToNull(String? value) {
    if (value == null) return null;
    if (value.trim().isEmpty) return null;
    return value;
  }

  static bool _parseBool(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
}
