import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/models.dart';
import '../services/services.dart';

class PokemonDetailDialog extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailDialog({super.key, required this.pokemon});

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
    const months = <String>[
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  Color _typeColor(PokemonType type) {
    switch (type) {
      case PokemonType.electric: return const Color(0xFFFFD700);
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
      default: return Colors.grey;
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

    const Color borderLight = Color(0xFF63c7c8);
    const Color borderDark = Color(0xFF286a6b);
    const Color cardBgLight = Color(0xFF86c096);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        // Remove fixed height so it shrinks to content
        decoration: BoxDecoration(
          color: borderLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
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
              // 1. BASE BACKGROUND
              Positioned.fill(child: Container(color: const Color.fromARGB(255, 79, 209, 197))),

              // 2. WHITE STRIP (Extended to cover Types)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                height: 280,
                child: Container(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),

              // 3. GLOBAL STRIPES
              Positioned.fill(
                child: CustomPaint(
                  painter: StripePainter(
                    stripeColor: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // 4. CONTENT LAYER
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderDark, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ★ 수정됨: 내용물 크기만큼만 차지
                  children: [
                    // --- HEADER ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF70a0e0),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              "POKEDEX",
                              style: pixelStyle.copyWith(color: Colors.white, fontSize: 10),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, color: borderDark, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // --- SCROLLABLE CONTENT ---
                    Flexible( // ★ 수정됨: Expanded -> Flexible로 변경하여 빈 공간 제거
                      fit: FlexFit.loose, // ★ 내용물이 적으면 줄어듬
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- NAME & ID ---
                            Text(
                              title,
                              style: pixelStyle.copyWith(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // --- IMAGE BOX ---
                            Center(
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderDark, width: 2),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: CachedNetworkImage(
                                  imageUrl: pokemon.homeSpriteUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: borderDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- TYPES ---
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

                            // --- STATS ---
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: borderDark.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'HT: ${pokemon.height.toStringAsFixed(1)}m | WT: ${pokemon.weight.toStringAsFixed(1)}kg',
                                style: pixelStyle.copyWith(color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- DESCRIPTION ---
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: borderDark),
                              ),
                              child: Text(
                                description.toUpperCase(),
                                style: pixelStyle.copyWith(fontSize: 10, height: 1.6),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- DATES CAUGHT ---
                            Text(
                              "DATES CAUGHT",
                              style: pixelStyle.copyWith(color: Colors.white, fontSize: 10),
                            ),
                            Container(
                              height: 2,
                              color: Colors.white.withValues(alpha: 0.5),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            FutureBuilder<List<String>>(
                              future: _loadCatchDates(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text("NO DATA", style: pixelStyle.copyWith(color: Colors.white70)),
                                  );
                                }
                                return SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8, top: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: borderDark),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _formatDateLabel(snapshot.data![index]),
                                            style: pixelStyle.copyWith(fontSize: 9),
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.3), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        type.name.toUpperCase(),
        style: baseStyle.copyWith(
          color: Colors.white,
          fontSize: 10,
          shadows: [const Shadow(offset: Offset(1, 1), color: Colors.black26)],
        ),
      ),
    );
  }
}

// Ensure StripePainter is available (copy from trainer_card.dart if needed)
class StripePainter extends CustomPainter {
  final Color stripeColor;

  StripePainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;
    const stripeHeight = 4.0;

    for (double i = 0; i < size.height; i += stripeHeight * 2) {
      canvas.drawRect(Rect.fromLTWH(0, i, size.width, stripeHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}