import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart'; // Ensure this points to your PokemonType enum

// COLORS AND FONTS
class UiThemeHelper {
  // --- SENTIMENT COLORS (Used in Diary Tab & Draft) ---
  
  static Color getSentimentColor(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();
    // JOY / HAPPY
    if (normalized == 'joy') {
      return const Color(0xFFF2C94C);
    }
    // ANGRY / STRESS
    if (normalized == 'angry') {
      return const Color(0xFFE76F51);
    }
    // SAD / DEPRESSED
    if (normalized == 'sad') {
      return const Color(0xFF5B7DB1);
    }
    // CALM / NORMAL
    if (normalized == 'calm') {
      return const Color(0xFF5DBE87);
    }
    // Default
    return const Color(0xFF9FA8A3);
  }

  /// Returns the full theme map used in DiaryDetailDialog
  static Map<String, Color> getSentimentTheme(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();

    // JOY
    if (normalized == 'joy') {
      return {
        'outer': const Color(0xFFE5D98C),
        'border': const Color(0xFF8E7B2C),
        'inner': const Color(0xFFD8BF5B),
        'paper': const Color(0xFFF2E8B7),
      };
    }
    // ANGRY
    if (normalized == 'angry') {
      return {
        'outer': const Color(0xFFE08E79),
        'border': const Color(0xFF8D3B25),
        'inner': const Color(0xFFCC7A66),
        'paper': const Color(0xFFF2D5CE),
      };
    }
    // SAD
    if (normalized == 'sad') {
      return {
        'outer': const Color(0xFF9FB7E6),
        'border': const Color(0xFF2C448E),
        'inner': const Color(0xFF7B99D8),
        'paper': const Color(0xFFD3DEF2),
      };
    }
    // CALM
    if (normalized == 'calm') {
      return {
        'outer': const Color(0xFF8CE5A9),
        'border': const Color(0xFF2C8E4F),
        'inner': const Color(0xFF6BD890),
        'paper': const Color(0xFFD3F2DC),
      };
    }
    // DEFAULT
    return {
      'outer': const Color(0xFFC0C0C0),
      'border': const Color(0xFF606060),
      'inner': const Color(0xFFA0A0A0),
      'paper': const Color(0xFFE0E0E0),
    };
  }

  // --- POKEMON TYPE COLORS (Used in Pokedex & Details) ---

  static Color getTypeColor(PokemonType type) {
    switch (type) {
      case PokemonType.electric: return const Color.fromARGB(255, 231, 196, 3);
      case PokemonType.flying: return const Color(0xFF89CFF0);
      case PokemonType.fire: return const Color(0xFFFF6B6B);
      case PokemonType.water: return const Color(0xFF4D96FF);
      case PokemonType.grass: return const Color(0xFF78C850);
      case PokemonType.poison: return const Color(0xFFA040A0);
      case PokemonType.bug: return const Color(0xFFA8B820);
      case PokemonType.normal: return const Color(0xFFA8A878);
      case PokemonType.ground: return const Color(0xFFE0C068);
      case PokemonType.fairy: return const Color(0xFFEE99AC);
      case PokemonType.fighting: return const Color(0xFFC03028);
      case PokemonType.psychic: return const Color(0xFFF85888);
      case PokemonType.rock: return const Color(0xFFB8A038);
      case PokemonType.ghost: return const Color(0xFF705898);
      case PokemonType.ice: return const Color(0xFF98D8D8);
      case PokemonType.dragon: return const Color(0xFF7038F8);
      case PokemonType.steel: return const Color(0xFFB8B8D0);
      case PokemonType.dark: return const Color(0xFF705848);
    }
  }

  /// Returns the detailed theme map for Pokemon Detail Cards
  static Map<String, Color> getTypeTheme(PokemonType type) {
    switch (type) {
      case PokemonType.grass:
        return {'outer': const Color(0xFF388E3C), 'inner': const Color(0xFF81C784), 'header': const Color(0xFF2E7D32)};
      case PokemonType.fire:
        return {'outer': const Color(0xFFD32F2F), 'inner': const Color(0xFFFF8A65), 'header': const Color(0xFFC62828)};
      case PokemonType.water:
        return {'outer': const Color(0xFF1976D2), 'inner': const Color(0xFF64B5F6), 'header': const Color(0xFF1565C0)};
      case PokemonType.electric:
        return {'outer': const Color(0xFFFBC02D), 'inner': const Color.fromARGB(129, 255, 241, 118), 'header': const Color(0xFFF9A825)};
      case PokemonType.psychic:
        return {'outer': const Color(0xFFC2185B), 'inner': const Color(0xFFF06292), 'header': const Color(0xFFAD1457)};
      case PokemonType.ice:
        return {'outer': const Color(0xFF0097A7), 'inner': const Color(0xFF4DD0E1), 'header': const Color(0xFF00838F)};
      case PokemonType.dragon:
        return {'outer': const Color(0xFF512DA8), 'inner': const Color(0xFF9575CD), 'header': const Color(0xFF4527A0)};
      case PokemonType.dark:
        return {'outer': const Color(0xFF424242), 'inner': const Color(0xFF9E9E9E), 'header': const Color(0xFF212121)};
      case PokemonType.fairy:
        return {'outer': const Color(0xFFE91E63), 'inner': const Color(0xFFF48FB1), 'header': const Color(0xFFC2185B)};
      case PokemonType.fighting:
        return {'outer': const Color(0xFFC62828), 'inner': const Color(0xFFEF9A9A), 'header': const Color(0xFFB71C1C)};
      case PokemonType.poison:
        return {'outer': const Color(0xFF7B1FA2), 'inner': const Color(0xFFCE93D8), 'header': const Color(0xFF6A1B9A)};
      case PokemonType.ground:
        return {'outer': const Color(0xFF795548), 'inner': const Color(0xFFA1887F), 'header': const Color(0xFF5D4037)};
      case PokemonType.rock:
        return {'outer': const Color(0xFF616161), 'inner': const Color(0xFFBDBDBD), 'header': const Color(0xFF424242)};
      case PokemonType.bug:
        return {'outer': const Color(0xFF689F38), 'inner': const Color(0xFFAED581), 'header': const Color(0xFF558B2F)};
      case PokemonType.ghost:
        return {'outer': const Color(0xFF4527A0), 'inner': const Color(0xFF7986CB), 'header': const Color(0xFF311B92)};
      case PokemonType.steel:
        return {'outer': const Color(0xFF546E7A), 'inner': const Color(0xFF90A4AE), 'header': const Color(0xFF455A64)};
      case PokemonType.flying:
        return {'outer': const Color(0xFF0288D1), 'inner': const Color(0xFF81D4FA), 'header': const Color(0xFF0277BD)};
      case PokemonType.normal:
      default:
        return {'outer': const Color(0xFF2F4D63), 'inner': const Color(0xFF5B7A62), 'header': const Color(0xFF4F6E74)};
    }
  }

  // --- BADGE COLORS (Used in Badge Popup) ---

  static Color getBadgeColor(String badgeId) {
    switch (badgeId.toLowerCase()) {
      case 'boulder': return const Color(0xFF78909C);
      case 'cascade': return const Color(0xFF29B6F6);
      case 'thunder': return const Color(0xFFFFCA28);
      case 'rainbow': return const Color(0xFF66BB6A);
      case 'soul':    return const Color(0xFFEC407A);
      case 'marsh':   return const Color(0xFFAB47BC);
      case 'volcano': return const Color(0xFFFF7043);
      case 'earth':   return const Color(0xFF8D6E63);
      default:        return const Color(0xFFe58e26);
    }
  }

  static TextStyle getPixelFont(TextStyle baseStyle, {bool isKorean = false}) {
    if (isKorean) {
      // Custom downloaded font
      final double size = baseStyle.fontSize ?? 12.0;
      final double scaledSize = size * 1.2;
      return baseStyle.copyWith(fontFamily: 'Galmuri11',
                                fontSize: scaledSize,
                                );

    } else {
      // Existing Google Font
      return GoogleFonts.pressStart2p(textStyle: baseStyle);
    }
  }
}