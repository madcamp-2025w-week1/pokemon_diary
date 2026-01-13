import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../services/sound_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  static const double _itemExtent = 72; 
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final pokedexProvider = context.watch<PokedexProvider>();
    final settings = context.watch<SettingsProvider>(); 
    
    final diaries = diaryProvider.diaries;

    // [Refactor] Use helper
    final pixelText = UiThemeHelper.getPixelFont(
      const TextStyle(
        fontSize: 11,
        color: Color(0xFF2F3A3A),
      ),
      isKorean: settings.isKorean,
    );

    if (diaryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diaries.isEmpty) {
      return SafeArea(
        child: Container(
          color: const Color(0xFF2B6FD3),
          child: Column(
            children: [
              _buildHeader(pixelText, settings),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildEmptyDetailPanel(settings),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    if (_selectedIndex >= diaries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedIndex = diaries.length - 1;
        });
      });
    }

    final selectedDiary = diaries[_selectedIndex.clamp(0, diaries.length - 1)];

    return SafeArea(
      child: Container(
        color: const Color(0xFF2B6FD3),
        child: Column(
          children: [
            _buildHeader(pixelText, settings),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: _buildDetailPanel(selectedDiary, pixelText, pokedexProvider, settings),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      flex: 2, 
                      child: _buildListPanel(diaries, pixelText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextStyle pixelText, SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A6D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F2142), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0F2142),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            settings.getText('DIARY_ENTRIES'), 
            style: pixelText.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(Diary diary, TextStyle pixelText, PokedexProvider pokedex, SettingsProvider settings) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5D98C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8E7B2C), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPokemonIcon(diary.pokemonId, 45),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${settings.getText('DATE_LABEL')} ${DateHelper.formatShortDateFromString(diary.date)}", 
                    style: pixelText.copyWith(fontSize: 12), 
                  ),
                ),
                _buildSentimentBadge(diary.sentiment, pixelText),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: LinedPaperPainter()),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: SingleChildScrollView(
                        child: Text(
                          diary.content, 
                          style: pixelText.copyWith(height: 2.0, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetailPanel(SettingsProvider settings) {
    // [Refactor] Use helper
    final pixelText = UiThemeHelper.getPixelFont(
      const TextStyle(
        fontSize: 11,
        color: Color(0xFF2F3A3A),
      ),
      isKorean: settings.isKorean,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5D98C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8E7B2C), width: 3),
        boxShadow: const [BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
        ),
        child: Center(
          child: Text(
            settings.getText('NO_DIARIES'), 
            textAlign: TextAlign.center,
            style: pixelText.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildListPanel(List<Diary> diaries, TextStyle pixelText) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B79DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D3E6B), width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double bottomPadding = (constraints.maxHeight - _itemExtent).clamp(0.0, double.infinity);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final index = (notification.metrics.pixels / _itemExtent).round();
                final clamped = index.clamp(0, diaries.length - 1);
                
                if (clamped != _selectedIndex) {
                  setState(() {
                    _selectedIndex = clamped;
                  });
                  SoundService().playCardSelectSound();
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemExtent: _itemExtent,
              padding: EdgeInsets.only(bottom: bottomPadding),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                final diary = diaries[index];
                final isSelected = index == _selectedIndex;
                
                return _DiaryListItem(
                  diary: diary,
                  isSelected: isSelected,
                  pixelText: pixelText,
                  onTap: () {
                    _scrollController.animateTo(
                      index * _itemExtent,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonIcon(int pokemonId, double size) {
    return _DiaryIcon(pokemonId: pokemonId, size:size);
  }

  Widget _buildSentimentBadge(String sentiment, TextStyle pixelText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UiThemeHelper.getSentimentColor(sentiment),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
      ),
      child: Text(sentiment.toUpperCase(), style: pixelText.copyWith(fontSize: 8, color: Colors.white)),
    );
  }
}

class _DiaryListItem extends StatelessWidget {
  final Diary diary;
  final bool isSelected;
  final TextStyle pixelText;
  final VoidCallback onTap;

  const _DiaryListItem({
    required this.diary,
    required this.isSelected,
    required this.pixelText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(diary.date);
    final dateLabel = parsed != null ? _formatShortDate(parsed) : '--/--/--';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: isSelected ? 1 : 0,
              child: const Icon(Icons.play_arrow, color: Color(0xFFE5D98C), size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D98C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2F3A3A) : const Color(0xFF8E7B2C),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(1, 1), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD8BF5B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          _DiaryIcon(pokemonId: diary.pokemonId, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: pixelText.copyWith(fontSize: 8),
                            ),
                          ),
                          Transform.scale(scale: 0.8, child: _SentimentDot(sentiment: diary.sentiment)),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2E8B7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        _titleSnippet(diary.content),
                        style: pixelText.copyWith(fontSize: 9),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleSnippet(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 'ENTRY';
    return trimmed.length > 24 ? '${trimmed.substring(0, 24)}...' : trimmed;
  }

  String _formatShortDate(DateTime parsed) {
    final year = parsed.year % 100;
    return '${parsed.month}/${parsed.day}/$year';
  }
}

class _DiaryIcon extends StatelessWidget {
  final int pokemonId;
  final double size;

  const _DiaryIcon({required this.pokemonId, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();
    
    final pokemon = pokedex.allPokemon.firstWhere(
      (p) => p.id == pokemonId, 
      orElse: () => Pokemon.empty()
    );

    final iconUrl = (pokemon.id != 0) 
        ? pokemon.iconSpriteUrl 
        : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/$pokemonId.png';

    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(width: size, height: size);
      },
    );
  }
}

class _SentimentDot extends StatelessWidget {
  final String sentiment;

  const _SentimentDot({required this.sentiment});

  @override
  Widget build(BuildContext context) {
    final color = UiThemeHelper.getSentimentColor(sentiment);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2F3A3A), width: 1.5),
      ),
    );
  }
}