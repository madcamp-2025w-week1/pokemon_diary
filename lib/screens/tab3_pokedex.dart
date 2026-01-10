import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';
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
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          cacheExtent: 600,
          itemCount: pokemonList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
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
        );
      },
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
    final nameColor = isOwned ? Colors.black87 : Colors.black38;

    // ★ 최적화 포인트: CachedNetworkImage 사용
    Widget imageWidget = CachedNetworkImage(
      imageUrl: pokemon.showdownGifUrl, // GIF URL
      fit: BoxFit.contain,
      // 로딩 중일 때 보여줄 위젯 (UX 향상)
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20, 
          height: 20, 
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[300]),
        ),
      ),
      // 에러 났을 때 보여줄 위젯
      errorWidget: (context, url, error) => const Icon(Icons.error),
      // 페이드인 효과로 부드럽게 뜨게 함
      fadeInDuration: const Duration(milliseconds: 200),
    );

    // 미보유 시 실루엣 처리
    if (!isOwned) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        child: imageWidget,
      );
    }

    return Card(
      elevation: 2,
      color: const Color(0xFFF5F1E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isOwned ? () {
          // TODO: 상세 페이지 이동 로직 (추후 구현)
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Center(child: imageWidget),
              ),
              const SizedBox(height: 6),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
