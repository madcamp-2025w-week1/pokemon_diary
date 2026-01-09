import 'package:flutter/material.dart';

class Tab1Draft extends StatelessWidget {
  const Tab1Draft({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/pokeball.png',
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.catching_pokemon, size: 180);
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How are you feeling today? Share your thoughts to find your Pokemon companion...',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    'https://raw.githubusercontent.com/ashwin-7/PokeDex/master/assets/pokeball_open.png',
                                    height: 180,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.catching_pokemon,
                                        size: 160,
                                        color: Colors.redAccent,
                                      );
                                    },
                                  ),
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black87,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.network(
                                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
                                      height: 90,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.bolt,
                                          size: 72,
                                          color: Colors.black87,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.catching_pokemon),
                        label: const Text('Gacha! Analyze Emotion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}