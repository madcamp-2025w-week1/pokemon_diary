import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../services/sound_service.dart';

// --- 1. Diary Detail Dialog (Themed to match Tab2Diary) ---
class DiaryDetailDialog extends StatefulWidget {
  final Diary diary;
  final Pokemon? pokemon;

  const DiaryDetailDialog({
    super.key, 
    required this.diary, 
    this.pokemon
  });

  @override
  State<DiaryDetailDialog> createState() => _DiaryDetailDialogState();
}

class _DiaryDetailDialogState extends State<DiaryDetailDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Theme Helper: Matches colors from Tab2Diary ---
  Map<String, Color> _getSentimentTheme(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();

    // JOY / HAPPY (Yellow/Gold)
    if (normalized == 'joy' || normalized == 'happy') {
      return {
        'outer': const Color(0xFFE5D98C),    // Card Color
        'border': const Color(0xFF8E7B2C),   // Border Color
        'inner': const Color(0xFFD8BF5B),    // Header Color (Background)
        'paper': const Color(0xFFF2E8B7),    // Body Color (Content Area)
      };
    }

    // ANGRY / STRESS (Red/Terra Cotta)
    if (normalized == 'angry' || normalized == 'stress' || normalized.contains('frustrat')) {
      return {
        'outer': const Color(0xFFE08E79),
        'border': const Color(0xFF8D3B25),
        'inner': const Color(0xFFCC7A66),
        'paper': const Color(0xFFF2D5CE),
      };
    }

    // SAD / DEPRESSED (Blue)
    if (normalized == 'sad' || normalized == 'depressed' || normalized.contains('blue')) {
      return {
        'outer': const Color(0xFF9FB7E6),
        'border': const Color(0xFF2C448E),
        'inner': const Color(0xFF7B99D8),
        'paper': const Color(0xFFD3DEF2),
      };
    }

    // CALM / NORMAL (Green)
    if (normalized == 'calm' || normalized == 'normal' || normalized.contains('peace')) {
      return {
        'outer': const Color(0xFF8CE5A9),
        'border': const Color(0xFF2C8E4F),
        'inner': const Color(0xFF6BD890),
        'paper': const Color(0xFFD3F2DC),
      };
    }

    // DEFAULT (Grey/Neutral)
    return {
      'outer': const Color(0xFFC0C0C0),
      'border': const Color(0xFF606060),
      'inner': const Color(0xFFA0A0A0),
      'paper': const Color(0xFFE0E0E0),
    };
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Colors & Fonts
    final theme = _getSentimentTheme(widget.diary.sentiment);
    final pixelStyle = GoogleFonts.pressStart2p(
      color: const Color(0xFF2d3436),
      fontSize: 10,
      height: 1.5,
    );

    final pokemonName = widget.pokemon?.englishName.toUpperCase() ?? "UNKNOWN";
    
    // Extract colors
    final outerColor = theme['outer']!;
    final borderColor = theme['border']!;
    final innerColor = theme['inner']!;
    final paperColor = theme['paper']!;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: outerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 3), // Outer White Rim
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // 1. Background Fill (Inner/Header Color)
                Positioned.fill(child: Container(color: innerColor)),

                // 2. Paper Content Area (Bottom 3/4ths)
                Positioned(
                  top: 50,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(color: paperColor),
                ),

                // 3. Stripes Overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: StripePainter(stripeColor: Colors.black.withOpacity(0.05)),
                  ),
                ),

                // 4. Content Layout
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 2), // Colored Theme Border
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Header Row ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Date Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatDate(widget.diary.date),
                                style: pixelStyle.copyWith(color: Colors.white, fontSize: 10),
                              ),
                            ),
                            // Close Button
                            GestureDetector(
                              onTap: () {
                                SoundService().playCardSelectSound();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                child: Icon(Icons.close, size: 14, color: borderColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- Main Content ---
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              
                              // Sentiment & Pokemon Info
                              Row(
                                children: [
                                  // Sentiment Icon/Chip
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: borderColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2,2))],
                                    ),
                                    child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.diary.sentiment.toUpperCase(),
                                          style: pixelStyle.copyWith(
                                            color: borderColor,
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "FEAT. $pokemonName",
                                          style: pixelStyle.copyWith(fontSize: 8, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),

                              // Text Content Box
                              Container(
                                constraints: const BoxConstraints(minHeight: 100),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: borderColor, width: 1.5),
                                ),
                                child: Text(
                                  widget.diary.content,
                                  style: pixelStyle.copyWith(
                                    fontSize: 11,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. Pokemon Detail Dialog (Unchanged Type-Themed Version) ---
class PokemonDetailDialog extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailDialog({super.key, required this.pokemon});

  // --- Theme Helper: Returns Colors based on Type ---
  Map<String, Color> _getTypeTheme(PokemonType type) {
    switch (type) {
      case PokemonType.grass:
        return {
          'outer': const Color(0xFF388E3C), // Dark Green
          'inner': const Color(0xFF81C784), // Light Green
          'header': const Color(0xFF2E7D32), // Deep Green Tag
        };
      case PokemonType.fire:
        return {
          'outer': const Color(0xFFD32F2F), // Red
          'inner': const Color(0xFFFF8A65), // Soft Orange
          'header': const Color(0xFFC62828), // Deep Red Tag
        };
      case PokemonType.water:
        return {
          'outer': const Color(0xFF1976D2), // Blue
          'inner': const Color(0xFF64B5F6), // Light Blue
          'header': const Color(0xFF1565C0), // Deep Blue Tag
        };
      case PokemonType.electric:
        return {
          'outer': const Color(0xFFFBC02D), // Dark Yellow
          'inner': const Color.fromARGB(129, 255, 241, 118), // Light Yellow
          'header': const Color(0xFFF9A825), // Deep Gold Tag
        };
      case PokemonType.psychic:
        return {
          'outer': const Color(0xFFC2185B), // Pink
          'inner': const Color(0xFFF06292), // Light Pink
          'header': const Color(0xFFAD1457), // Deep Pink Tag
        };
      case PokemonType.ice:
        return {
          'outer': const Color(0xFF0097A7), // Cyan
          'inner': const Color(0xFF4DD0E1), // Light Cyan
          'header': const Color(0xFF00838F), // Deep Cyan Tag
        };
      case PokemonType.dragon:
        return {
          'outer': const Color(0xFF512DA8), // Deep Purple
          'inner': const Color(0xFF9575CD), // Light Purple
          'header': const Color(0xFF4527A0), // Dark Purple Tag
        };
      case PokemonType.dark:
        return {
          'outer': const Color(0xFF424242), // Dark Grey
          'inner': const Color(0xFF9E9E9E), // Light Grey
          'header': const Color(0xFF212121), // Black Tag
        };
      case PokemonType.fairy:
        return {
          'outer': const Color(0xFFE91E63), // Hot Pink
          'inner': const Color(0xFFF48FB1), // Light Pink
          'header': const Color(0xFFC2185B), // Deep Pink Tag
        };
      case PokemonType.fighting:
        return {
          'outer': const Color(0xFFC62828), // Red-Brown
          'inner': const Color(0xFFEF9A9A), // Light Red
          'header': const Color(0xFFB71C1C), // Deep Maroon Tag
        };
      case PokemonType.poison:
        return {
          'outer': const Color(0xFF7B1FA2), // Purple
          'inner': const Color(0xFFCE93D8), // Light Purple
          'header': const Color(0xFF6A1B9A), // Deep Purple Tag
        };
      case PokemonType.ground:
        return {
          'outer': const Color(0xFF795548), // Brown
          'inner': const Color(0xFFA1887F), // Light Brown
          'header': const Color(0xFF5D4037), // Deep Brown Tag
        };
      case PokemonType.rock:
        return {
          'outer': const Color(0xFF616161), // Grey
          'inner': const Color(0xFFBDBDBD), // Light Grey
          'header': const Color(0xFF424242), // Dark Grey Tag
        };
      case PokemonType.bug:
        return {
          'outer': const Color(0xFF689F38), // Olive Green
          'inner': const Color(0xFFAED581), // Light Olive
          'header': const Color(0xFF558B2F), // Deep Olive Tag
        };
      case PokemonType.ghost:
        return {
          'outer': const Color(0xFF4527A0), // Deep Indigo
          'inner': const Color(0xFF7986CB), // Light Indigo
          'header': const Color(0xFF311B92), // Dark Indigo Tag
        };
      case PokemonType.steel:
        return {
          'outer': const Color(0xFF546E7A), // Blue Grey
          'inner': const Color(0xFF90A4AE), // Light Blue Grey
          'header': const Color(0xFF455A64), // Deep Blue Grey Tag
        };
      case PokemonType.flying:
        return {
          'outer': const Color(0xFF0288D1), // Light Blue
          'inner': const Color(0xFF81D4FA), // Sky Blue
          'header': const Color(0xFF0277BD), // Deep Blue Tag
        };
      case PokemonType.normal:
      default:
        return {
          'outer': const Color(0xFF2F4D63), // Default Slate (Tab3 Style)
          'inner': const Color(0xFF5B7A62), // Default Sage
          'header': const Color(0xFF4F6E74), // Default Teal
        };
    }
  }

  Future<List<String>> _loadCatchDates() async {
    final diaries = await DbHelper.instance.getDiaries();
    final dates = diaries
        .where((entry) => entry.pokemonId == pokemon.id)
        .map((entry) => entry.date)
        .toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  String _formatDateLabel(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  Color _typeColor(PokemonType type) {
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

  @override
  Widget build(BuildContext context) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final displayName = isKorean ? pokemon.koreanName : pokemon.englishName;
    final description = isKorean ? pokemon.dexEntryKorean : pokemon.dexEntryEnglish;
    final title = '${displayName.toUpperCase()} #${pokemon.id.toString().padLeft(3, '0')}';

    final pixelStyle = GoogleFonts.pressStart2p(
      fontSize: 10,
      color: const Color(0xFF2d3436),
      height: 1.4,
    );

    // --- APPLY THEME ---
    final theme = _getTypeTheme(pokemon.type1);
    final pokedexOuter = theme['outer']!;
    final pokedexInner = theme['inner']!;
    final headerColor = theme['header']!;

    const Color borderDark = Color(0xFF1B2D3A);   // Keep borders dark/consistent
    const Color contentBg = Color(0xFFF7F1E3);    // Cream (Paper/Screen)

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: pokedexOuter, // Dynamic Type Color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 1. Dynamic Background Color
              Positioned.fill(child: Container(color: pokedexInner)), 
              
              // 2. Content Area (Cream)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                height: 280,
                child: Container(color: contentBg.withOpacity(0.95)),
              ),
              
              // 3. Stripes
              Positioned.fill(
                child: CustomPaint(
                  painter: StripePainter(stripeColor: Colors.black.withOpacity(0.05)),
                ),
              ),

              // 4. Main Content
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderDark, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: headerColor, // Dynamic Tag Color
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black.withOpacity(0.2)),
                            ),
                            child: Text("POKEDEX", style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)),
                          ),
                          GestureDetector(
                            onTap: () {
                              SoundService().playCardSelectSound();
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.close, color: borderDark, size: 20),
                          ),
                        ],
                      ),
                    ),
                    
                    // Detail Scroll View
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(title, style: pixelStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            
                            // Image Box
                            Center(
                              child: Container(
                                width: 180, height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderDark, width: 2),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: CachedNetworkImage(
                                  imageUrl: pokemon.gifUrl!,
                                  // 1. Use imageBuilder to customize how the image is rendered
                                  imageBuilder: (context, imageProvider) => Image(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                    // 2. This is the key setting. It forces "Nearest Neighbor" scaling.
                                    filterQuality: FilterQuality.none, 
                                  ),
                                  // Keep your existing placeholder
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: borderDark)
                                  ),
                                  // It's good practice to add an error widget too, just in case
                                  errorWidget: (context, url, error) => const Icon(Icons.error, color: borderDark),
                                )
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Type Chips
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildPixelTypeChip(pokemon.type1, pixelStyle),
                                if (pokemon.type2 != null) ...[
                                  const SizedBox(width: 8),
                                  _buildPixelTypeChip(pokemon.type2!, pixelStyle),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Height/Weight Box
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(color: borderDark.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                              child: Text('HT: ${pokemon.height.toStringAsFixed(1)}m | WT: ${pokemon.weight.toStringAsFixed(1)}kg',
                                  style: pixelStyle.copyWith(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 16),
                            
                            // Description Box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: contentBg.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: borderDark),
                              ),
                              child: Text(description.toUpperCase(), style: pixelStyle.copyWith(fontSize: 10, height: 1.6)),
                            ),
                            const SizedBox(height: 16),
                            
                            // Dates Label
                            Text("DATES CAUGHT", style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)),
                            Container(height: 2, color: Colors.white.withOpacity(0.5), margin: const EdgeInsets.symmetric(vertical: 4)),
                            
                            // Dates List
                            FutureBuilder<List<String>>(
                              future: _loadCatchDates(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("NO DATA");
                                return SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final dateStr = snapshot.data![index];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 8),
                                        child: InkWell( 
                                          onTap: () async {
                                            SoundService().playCardSelectSound();
                                            final diaries = await DbHelper.instance.getDiaries();
                                            final targetDiary = diaries.firstWhere((d) => d.date == dateStr && d.pokemonId == pokemon.id);
                                            if (context.mounted) {
                                              showDialog(
                                                context: context,
                                                builder: (context) => DiaryDetailDialog(diary: targetDiary, pokemon: pokemon),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: contentBg, 
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: borderDark),
                                            ),
                                            child: Center(child: Text(_formatDateLabel(dateStr), style: pixelStyle.copyWith(fontSize: 9))),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelTypeChip(PokemonType type, TextStyle baseStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _typeColor(type),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
      ),
      child: Text(type.name.toUpperCase(), style: baseStyle.copyWith(color: Colors.white, fontSize: 10, shadows: [const Shadow(offset: Offset(1, 1), color: Colors.black26)])),
    );
  }
}

class StripePainter extends CustomPainter {
  final Color stripeColor;
  StripePainter({required this.stripeColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;
    for (double i = 0; i < size.height; i += 8.0) {
      canvas.drawRect(Rect.fromLTWH(0, i, size.width, 4.0), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
