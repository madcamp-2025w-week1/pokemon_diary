import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import '../services/sound_service.dart';
import '../services/services.dart';

class Tab3Pokedex extends StatelessWidget {
  const Tab3Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final ownedIds = diaryProvider.diaries.map((diary) => diary.pokemonId).toSet();
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final apiService = context.read<PokemonApiService>();

    return FutureBuilder<List<Pokemon>>(
      future: apiService.getAllPokemon(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Pokemon available.'));
        }

        final pokemonList = snapshot.data!;
        final pixelText = GoogleFonts.pressStart2p(
          fontSize: 11,
          color: const Color(0xFF2F3A3A),
        );

        return Container(
          color: const Color(0xFF7F9B6F),
          child: Column(
            children: [
              _buildHeader(pixelText),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4D63),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1B2D3A), width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1B2D3A),
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.zero,
                    child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B7A62),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1B2D3A), width: 2),
                      ),
                      padding: EdgeInsets.zero,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(0),
                        cacheExtent: 600,
                        itemCount: pokemonList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final pokemon = pokemonList[index];
                          final isOwned = ownedIds.contains(pokemon.id);
                          return _PokedexTile(
                            pokemon: pokemon,
                            isOwned: isOwned,
                            isKorean: isKorean,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildHeader(TextStyle pixelText) {
  return Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF4F6E74),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1B2D3A), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0xFF1B2D3A),
          offset: Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.grid_view, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          'POKEDEX',
          style: pixelText.copyWith(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}

class _PokedexTile extends StatelessWidget {
  final Pokemon pokemon;
  final bool isOwned;
  final bool isKorean;

  const _PokedexTile({
    required this.pokemon,
    required this.isOwned,
    required this.isKorean,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = isOwned
        ? (isKorean ? pokemon.koreanName : pokemon.englishName)
        : '???';
    final nameColor = isOwned ? const Color(0xFF1E1E1E) : const Color(0xFF4A4A4A);

    final imageUrl = isOwned ? pokemon.showdownGifUrl : pokemon.homeSpriteUrl;
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, 
      memCacheHeight: 200,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey[300],
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    if (!isOwned) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        child: imageWidget,
      );
    } else {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final idFontSize = (constraints.maxWidth * 0.10).clamp(8.0, 10.0);
        final nameFontSize = (constraints.maxWidth * 0.01).clamp(8.0, 10.0);
        final pixelId = GoogleFonts.pressStart2p(
          fontSize: idFontSize,
          color: nameColor,
        );
        final pixelName = GoogleFonts.pressStart2p(
          fontSize: nameFontSize,
          color: nameColor,
        );

        final lineColor = const Color(0xFF2B2B2B);
        final bandOuter = isOwned ? const Color(0xFF4F6E3E) : const Color(0xFF3F4A3A);
        final bandInner = isOwned ? const Color(0xFF5E7A46) : const Color(0xFF4A5440);
        final innerFill = isOwned ? const Color(0xFFF7F1E3) : const Color(0xFF6E7A67);

        return Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
        onTap: isOwned
            ? () {
                SoundService().playCardSelectSound();
                showDialog(
                  context: context,
                  builder: (_) => PokemonDetailDialog(pokemon: pokemon),
                );
              }
                : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: bandOuter,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: lineColor, width: 2),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  color: innerFill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: lineColor, width: 2),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(child: imageWidget),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: pixelId,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayName.toUpperCase(),
                        style: pixelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
