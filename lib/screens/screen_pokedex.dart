import 'package:flutter/material.dart';
import 'package:pokemon_diary/services/sound_service.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/utils.dart'; // For UiThemeHelper

import '../models/models.dart';
import '../providers/providers.dart';
import 'screens.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  // State for filtering and sorting
  bool _showOwnedOnly = false;
  bool _sortByDate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      context.read<PokedexProvider>().loadPokedex(isRetro: settings.isRetroArt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final pokedexProvider = context.watch<PokedexProvider>();
    final settings = context.watch<SettingsProvider>();

    final isKorean = settings.isKorean;
    final pixelText = UiThemeHelper.getPixelFont(
      const TextStyle(
        fontSize: 11,
        color: Color(0xFF2F3A3A),
      ),
      isKorean: isKorean,
    );

    // 1. Prepare Data
    final allPokemon = pokedexProvider.allPokemon;
    final ownedIds = diaryProvider.diaries.map((d) => d.pokemonId).toSet();
    
    // Stats
    final totalCount = allPokemon.length;
    final obtainedCount = ownedIds.length;

    // 2. Filter & Sort Logic
    List<Pokemon> displayList = List.from(allPokemon);

    // A. Filter
    if (_showOwnedOnly) {
      displayList = displayList.where((p) => ownedIds.contains(p.id)).toList();
    }

    // B. Sort
    if (_sortByDate) {
      final firstCatchMap = <int, DateTime>{};
      for (var diary in diaryProvider.diaries) {
        final date = DateTime.tryParse(diary.date);
        if (date != null) {
          if (!firstCatchMap.containsKey(diary.pokemonId) || 
              date.isBefore(firstCatchMap[diary.pokemonId]!)) {
            firstCatchMap[diary.pokemonId] = date;
          }
        }
      }

      displayList.sort((a, b) {
        final dateA = firstCatchMap[a.id];
        final dateB = firstCatchMap[b.id];

        if (dateA == null && dateB == null) return a.id.compareTo(b.id); 
        if (dateA == null) return 1; 
        if (dateB == null) return -1; 
        
        final comparison = dateA.compareTo(dateB);
        return comparison != 0 ? comparison : a.id.compareTo(b.id);
      });
    } else {
      displayList.sort((a, b) => a.id.compareTo(b.id));
    }

    return Container(
      color: const Color(0xFF7F9B6F),
      child: Column(
        children: [
          // Header with Stats
          _buildHeader(pixelText, settings, obtainedCount, totalCount),
          
          // Filter & Sort Bar
          _buildFilterBar(pixelText, settings),

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
                    BoxShadow(color: Color(0xFF1B2D3A), offset: Offset(3, 3)),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B7A62),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1B2D3A), width: 2),
                  ),
                  child: pokedexProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: EdgeInsets.zero,
                          cacheExtent: 600,
                          itemCount: displayList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final pokemon = displayList[index];
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
  }

  Widget _buildHeader(TextStyle pixelText, SettingsProvider settings, int obtained, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4F6E74),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B2D3A), width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFF1B2D3A), offset: Offset(2, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                settings.getText('POKEDEX'), 
                style: pixelText.copyWith(color: Colors.white, fontSize: 12)
              ),
            ],
          ),
          // Obtained Count Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2C94C), // Yellowish Gold
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26),
            ),
            child: Row(
              children: [
                const Icon(Icons.catching_pokemon, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  "$obtained / $total",
                  style: pixelText.copyWith(
                    color: const Color(0xFF2d3436), 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // [UPDATED] New Contrast Colors for Buttons
  Widget _buildFilterBar(TextStyle pixelText, SettingsProvider settings) {
    // Blue-ish for Filter (Contrast with Teal)
    const Color filterBase = Color(0xFF5B7DB1); // Muted Blue
    const Color filterBorder = Color(0xFF2C448E); // Darker Blue
    
    // Orange-ish for Sort (Complementary to Teal)
    const Color sortBase = Color(0xFFE76F51); // Muted Orange
    const Color sortBorder = Color(0xFF8D3B25); // Darker Orange

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          // FILTER TOGGLE
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: filterBase,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: filterBorder, width: 2),
                boxShadow: const [BoxShadow(color: filterBorder, offset: Offset(1, 1))],
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    label: settings.getText('FILTER_ALL'),
                    isActive: !_showOwnedOnly,
                    onTap: () => setState(() => _showOwnedOnly = false),
                    pixelText: pixelText,
                  ),
                  Container(width: 2, color: filterBorder),
                  _buildToggleButton(
                    label: settings.getText('FILTER_OWNED'),
                    isActive: _showOwnedOnly,
                    onTap: () => setState(() => _showOwnedOnly = true),
                    pixelText: pixelText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // SORT TOGGLE
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: sortBase,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sortBorder, width: 2),
                boxShadow: const [BoxShadow(color: sortBorder, offset: Offset(1, 1))],
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    label: settings.getText('SORT_DEX'),
                    isActive: !_sortByDate,
                    onTap: () => setState(() => _sortByDate = false),
                    pixelText: pixelText,
                  ),
                  Container(width: 2, color: sortBorder),
                  _buildToggleButton(
                    label: settings.getText('SORT_DATE'),
                    isActive: _sortByDate,
                    onTap: () => setState(() => _sortByDate = true),
                    pixelText: pixelText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required TextStyle pixelText,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            SoundService().playCardSelectSound();
            onTap();
          }
        },
        child: Container(
          // Active = Light overlay, Inactive = Transparent
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: pixelText.copyWith(
              fontSize: 9,
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
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

    final imageUrl = isOwned 
        ? (pokemon.gifUrl ?? pokemon.homeSpriteUrl) 
        : pokemon.homeSpriteUrl;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      memCacheHeight: 200,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[300]),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    if (!isOwned) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: imageWidget,
      );
    } else {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final idFontSize = (constraints.maxWidth * 0.10).clamp(8.0, 10.0);
        final nameFontSize = (constraints.maxWidth * 0.01).clamp(8.0, 10.0);
        
        // [Refactor] Use helper
        final pixelId = UiThemeHelper.getPixelFont(
            TextStyle(fontSize: idFontSize, color: nameColor),
            isKorean: isKorean
        );
        final pixelName = UiThemeHelper.getPixelFont(
            TextStyle(fontSize: nameFontSize, color: nameColor),
            isKorean: isKorean
        );

        final lineColor = const Color(0xFF2B2B2B);
        final bandOuter = isOwned ? const Color(0xFF4F6E3E) : const Color(0xFF3F4A3A);
        final innerFill = isOwned ? const Color(0xFFF7F1E3) : const Color(0xFF6E7A67);

        return Card(
          elevation: 0,
          color: Colors.transparent,
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
                decoration: BoxDecoration(color: bandOuter, borderRadius: BorderRadius.circular(8)),
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
                        Expanded(child: Center(child: imageWidget)),
                        const SizedBox(height: 6),
                        Text('#${pokemon.id.toString().padLeft(3, '0')}', style: pixelId),
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