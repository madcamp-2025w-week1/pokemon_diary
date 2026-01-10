import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  Color _typeColor(PokemonType type) {
    switch (type) {
      case PokemonType.electric: return const Color(0xFFFFD700); // GBA Yellow
      case PokemonType.flying: return const Color(0xFF89CFF0); // GBA Blue
      case PokemonType.fire: return const Color(0xFFFF6B6B);
      case PokemonType.water: return const Color(0xFF4D96FF);
      case PokemonType.grass: return const Color(0xFF78C850);
      case PokemonType.poison: return const Color(0xFFA040A0);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final displayName = isKorean ? pokemon.koreanName : pokemon.englishName;
    final description = isKorean ? pokemon.dexEntryKorean : pokemon.dexEntryEnglish;
    // ★ 레트로 느낌을 위해 모두 대문자로 변환
    final title = '${displayName.toUpperCase()} #${pokemon.id.toString().padLeft(3, '0')}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        // ★ 1. 레트로 스캔라인 배경 구현
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 4),
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FD1C5), // 밝은 청록
              Color(0xFF38B2AC), // 어두운 청록
            ],
            stops: [0.5, 0.5], // 딱 절반에서 색이 바뀌는 스트라이프 효과
            tileMode: TileMode.repeated,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header (Name) ---
              _buildRetroContainer(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Monospace', // 픽셀 폰트 느낌
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 24), // 아이콘 크기만큼 공백
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // --- Main Image Box ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRetroContainer(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: CachedNetworkImage(
                      imageUrl: pokemon.homeSpriteUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- Types Bar ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRetroContainer(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTypeChip(pokemon.type1),
                      if (pokemon.type2 != null) ...[
                        const SizedBox(width: 10),
                        _buildTypeChip(pokemon.type2!),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // --- Stats Bar ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withOpacity(0.3), // 반투명 검은 배경
                child: Text(
                  'HEIGHT: ${pokemon.height.toStringAsFixed(1)}m | WEIGHT: ${pokemon.weight.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // --- Description Box ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildRetroContainer(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(
                      description.toUpperCase(), // 레트로는 대문자가 제맛
                      style: const TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- Dates Caught Title ---
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'DATES CAUGHT',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    shadows: [Shadow(offset: Offset(2, 2), color: Colors.black)],
                  ),
                ),
              ),

              // --- Dates List ---
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                child: FutureBuilder<List<String>>(
                  future: _loadCatchDates(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildRetroContainer(
                        padding: const EdgeInsets.all(8),
                        child: const Text("NO DATA", style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }
                    return SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: _buildRetroContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                _formatDateLabel(snapshot.data![index]),
                                style: const TextStyle(
                                  fontFamily: 'Monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ★ 레트로 스타일 컨테이너 (흰색 박스 + 검은 테두리 + 그림자)
  Widget _buildRetroContainer({required Widget child, EdgeInsets? padding, double? height}) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }

  // ★ 타입 칩 (레트로 스타일)
  Widget _buildTypeChip(PokemonType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _typeColor(type),
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Text(
        type.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontFamily: 'Monospace',
          fontSize: 12,
          shadows: [Shadow(offset: Offset(1, 1), color: Colors.black)],
        ),
      ),
    );
  }
}
