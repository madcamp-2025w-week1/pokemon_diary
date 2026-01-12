import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';
import '../services/services.dart';

class Tab2Diary extends StatefulWidget {
  const Tab2Diary({super.key});

  @override
  State<Tab2Diary> createState() => _Tab2DiaryState();
}

class _Tab2DiaryState extends State<Tab2Diary> {
  static const double _itemExtent = 110;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  
  // ★ 수정 1: late를 제거하고 nullable로 선언하거나, 
  // 여기서는 initState 의존성을 없애기 위해 nullable Future로 관리해.
  Future<List<Pokemon>>? _pokemonFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★ 수정 2: context가 완전히 준비된 didChangeDependencies에서 초기화하는 것이 더 안전해.
    // 한 번만 실행되도록 체크.
    _pokemonFuture ??= context.read<PokemonApiService>().getAllPokemon();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final diaries = diaryProvider.diaries;

    if (diaryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diaries.isEmpty) {
      return SafeArea(
        child: Container(
          color: const Color(0xFF2B6FD3),
          child: Column(
            children: [
              _buildHeader(
                GoogleFonts.pressStart2p(
                  fontSize: 11,
                  color: const Color(0xFF2F3A3A),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildEmptyDetailPanel(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    // 선택된 인덱스 보정 로직
    if (_selectedIndex >= diaries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedIndex = diaries.isEmpty ? 0 : diaries.length - 1;
        });
      });
    }

    final selectedDiary = diaries[_selectedIndex.clamp(0, diaries.length - 1)];
    final pixelText = GoogleFonts.pressStart2p(
      fontSize: 11,
      color: const Color(0xFF2F3A3A),
    );

    return SafeArea(
      child: Container(
        color: const Color(0xFF2B6FD3),
        child: FutureBuilder<List<Pokemon>>(
          // ★ 수정 3: _pokemonFuture가 null일 경우를 대비해 처리
          future: _pokemonFuture,
          builder: (context, snapshot) {
            // 로딩 중 표시 추가 (Future가 완료될 때까지 기다림)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final pokemonList = snapshot.data ?? const <Pokemon>[];
            final pokemonMap = {
              for (final pokemon in pokemonList) pokemon.id: pokemon,
            };

            return Column(
              children: [
                _buildHeader(pixelText),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _buildDetailPanel(
                          selectedDiary,
                          pokemonMap[selectedDiary.pokemonId],
                          pixelText,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildListPanel(diaries, pokemonMap, pixelText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 이하 위젯 빌드 메서드들은 기존과 동일 (생략하지 않고 그대로 사용하면 돼) ---
  // _buildHeader, _buildDetailPanel, _buildListPanel 등...
  
  Widget _buildHeader(TextStyle pixelText) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B79DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D3E6B), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D3E6B),
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
            'DIARY ENTRIES',
            style: pixelText.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(Diary diary, Pokemon? pokemon, TextStyle pixelText) {
    return Container(
      height: 240, // 적절한 고정 높이 부여 또는 Flexible 처리
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
                _buildPokemonIcon(pokemon, 40),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_formatDetailTitle(diary), style: pixelText.copyWith(fontSize: 10)),
                ),
                _buildSentimentBadge(diary.sentiment, pixelText),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LinedPaperPainter(),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Text(
                          diary.content,
                          style: pixelText.copyWith(height: 1.6, fontSize: 9),
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

  Widget _buildEmptyDetailPanel() {
    final pixelText = GoogleFonts.pressStart2p(
      fontSize: 11,
      color: const Color(0xFF2F3A3A),
    );

    return Container(
      height: 240,
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
        child: Center(
          child: Text(
            'NO DIARIES YET. GO DRAFT YOUR FIRST POKEMON!',
            textAlign: TextAlign.center,
            style: pixelText.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildListPanel(List<Diary> diaries, Map<int, Pokemon> pokemonMap, TextStyle pixelText) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B79DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D3E6B), width: 3),
      ),
      // 1. Wrap with LayoutBuilder to get the available height
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 2. Calculate padding: Allow the last item to scroll to the top
          // (View Height - Item Height) ensures the last item can stand alone at the top
          final double bottomPadding = (constraints.maxHeight - _itemExtent).clamp(0.0, double.infinity);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                // Your existing selection logic
                final index = (notification.metrics.pixels / _itemExtent).round();
                final clamped = index.clamp(0, diaries.length - 1);
                
                if (clamped != _selectedIndex) {
                  setState(() {
                    _selectedIndex = clamped;
                  });
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemExtent: _itemExtent,
              // 3. Apply the calculated padding here
              padding: EdgeInsets.only(bottom: bottomPadding),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                final diary = diaries[index];
                final isSelected = index == _selectedIndex;
                return _DiaryListItem(
                  diary: diary,
                  pokemon: pokemonMap[diary.pokemonId],
                  isSelected: isSelected,
                  pixelText: pixelText,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonIcon(Pokemon? pokemon, double size) {
    final iconUrl = pokemon?.iconSpriteUrl;
    if (iconUrl == null || iconUrl.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) => SizedBox(width: size, height: size),
    );
  }

  Widget _buildSentimentBadge(String sentiment, TextStyle pixelText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _sentimentColor(sentiment),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
      ),
      child: Text(sentiment.toUpperCase(), style: pixelText.copyWith(fontSize: 8, color: Colors.white)),
    );
  }

  Color _sentimentColor(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();
    if (normalized == 'joy' || normalized == 'happy') return const Color(0xFFF2C94C);
    if (normalized == 'angry' || normalized == 'stress') return const Color(0xFFE76F51);
    if (normalized == 'sad' || normalized == 'depressed') return const Color(0xFF5B7DB1);
    if (normalized == 'calm' || normalized == 'normal') return const Color(0xFF5DBE87);
    return const Color(0xFF9FA8A3);
  }

  String _formatDetailTitle(Diary diary) {
    final parsed = DateTime.tryParse(diary.date);
    if (parsed == null) return 'DATE --/--/--';
    return 'DATE ${_formatShortDate(parsed)}';
  }

  String _formatShortDate(DateTime parsed) {
    final year = parsed.year % 100;
    return '${parsed.month}/${parsed.day}/$year';
  }
}

class _DiaryListItem extends StatelessWidget {
  final Diary diary;
  final Pokemon? pokemon;
  final bool isSelected;
  final TextStyle pixelText;

  const _DiaryListItem({
    required this.diary,
    required this.pokemon,
    required this.isSelected,
    required this.pixelText,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(diary.date);
    final dateLabel = parsed != null ? _formatShortDate(parsed) : '--/--/--';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: isSelected ? 1 : 0,
            child: const Icon(Icons.play_arrow, color: Color(0xFFE5D98C)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5D98C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2F3A3A)
                      : const Color(0xFF8E7B2C),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1D3E6B),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8BF5B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        _DiaryIcon(pokemon: pokemon, size: 36),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: pixelText.copyWith(fontSize: 10),
                          ),
                        ),
                        _SentimentDot(sentiment: diary.sentiment),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2E8B7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      _titleSnippet(diary.content),
                      style: pixelText,
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
  final Pokemon? pokemon;
  final double size;

  const _DiaryIcon({required this.pokemon, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final iconUrl = pokemon?.iconSpriteUrl;
    if (iconUrl == null || iconUrl.isEmpty) {
      return SizedBox(width: size, height: size);
    }

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
    final color = _sentimentColor(sentiment);
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

  Color _sentimentColor(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();
    if (normalized == 'joy' || normalized == 'happy') {
      return const Color(0xFFF2C94C);
    }
    if (normalized == 'angry' || normalized == 'stress') {
      return const Color(0xFFE76F51);
    }
    if (normalized == 'sad' || normalized == 'depressed') {
      return const Color(0xFF5B7DB1);
    }
    if (normalized == 'calm' || normalized == 'normal') {
      return const Color(0xFF5DBE87);
    }
    return const Color(0xFF9FA8A3);
  }
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCE0EA)
      ..strokeWidth = 1;

    const lineGap = 18.0;
    for (double y = 0; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
