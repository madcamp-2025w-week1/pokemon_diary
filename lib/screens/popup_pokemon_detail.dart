import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokemon_diary/services/sound_service.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../providers/providers.dart'; // Import for SettingsProvider
import 'screens.dart';

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

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isKorean = settings.isKorean;

    final displayName = isKorean ? pokemon.koreanName : pokemon.englishName;
    final description = isKorean ? pokemon.dexEntryKorean : pokemon.dexEntryEnglish;
    final title = '${displayName.toUpperCase()} #${pokemon.id.toString().padLeft(3, '0')}';

    final pixelStyle = GoogleFonts.pressStart2p(
      fontSize: 10,
      color: const Color(0xFF2d3436),
      height: 1.4,
    );

    final theme = UiThemeHelper.getTypeTheme(pokemon.type1);
    final pokedexOuter = theme['outer']!;
    final pokedexInner = theme['inner']!;
    final headerColor = theme['header']!;

    const Color borderDark = Color(0xFF1B2D3A);   
    const Color contentBg = Color(0xFFF7F1E3);    

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: pokedexOuter,
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
              Positioned.fill(child: Container(color: pokedexInner)), 
              Positioned(
                top: 50, left: 0, right: 0, height: 280,
                child: Container(color: contentBg.withOpacity(0.95)),
              ),
              Positioned.fill(
                child: CustomPaint(painter: StripePainter(stripeColor: Colors.black.withOpacity(0.05))),
              ),

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
                              color: headerColor, 
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black.withOpacity(0.2)),
                            ),
                            child: Text(
                              settings.getText('POKEDEX'), 
                              style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              SoundService().playCardSelectSound();
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
                                  imageBuilder: (context, imageProvider) => Image(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none, 
                                  ),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: borderDark)),
                                  errorWidget: (context, url, error) => const Icon(Icons.error, color: borderDark),
                                )
                              ),
                            ),
                            const SizedBox(height: 16),
                            
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
                            
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(color: borderDark.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                '${settings.getText('HT')}: ${pokemon.height.toStringAsFixed(1)}m | ${settings.getText('WT')}: ${pokemon.weight.toStringAsFixed(1)}kg',
                                style: pixelStyle.copyWith(color: Colors.white, fontSize: 10), textAlign: TextAlign.center
                              ),
                            ),
                            const SizedBox(height: 16),
                            
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
                            
                            Text(settings.getText('DATES_CAUGHT'), style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)),
                            Container(height: 2, color: Colors.white.withOpacity(0.5), margin: const EdgeInsets.symmetric(vertical: 4)),
                            
                            FutureBuilder<List<String>>(
                              future: _loadCatchDates(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data!.isEmpty) return Text(settings.getText('NO_DATA'));
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
                                            child: Center(child: Text(DateHelper.formatFullDateFromString(dateStr), style: pixelStyle.copyWith(fontSize: 9))),
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
        color: UiThemeHelper.getTypeColor(type),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
      ),
      child: Text(type.name.toUpperCase(), style: baseStyle.copyWith(color: Colors.white, fontSize: 10, shadows: [const Shadow(offset: Offset(1, 1), color: Colors.black26)])),
    );
  }
}