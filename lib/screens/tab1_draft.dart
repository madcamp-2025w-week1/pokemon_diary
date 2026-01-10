import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';
import '../services/services.dart';

class Tab1Draft extends StatefulWidget {
  const Tab1Draft({super.key});

  @override
  State<Tab1Draft> createState() => _Tab1DraftState();
}

class _Tab1DraftState extends State<Tab1Draft> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final SentimentService _sentimentService = SentimentService();
  final GachaLogic _gachaLogic = GachaLogic();

  bool _isLoading = true;
  bool _isResultMode = false; 
  bool _isInputMode = true;   
  
  bool _isGachaAnimating = false;
  bool _showLightning = false;
  
  // ★ 추가: 현재 재생할 번개 애니메이션 파일 경로 (기본값: 일반)
  String _currentLightningAnim = 'assets/animations/gray_lightning.json';
  
  Diary? _todayDiary;
  Pokemon? _currentPokemon;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(_blinkController);

    _loadTodayEntry();
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayEntry() async {
    final todayKey = _formatDate(DateTime.now());
    final diaries = await DbHelper.instance.getDiaries();
    final existing = diaries.where((entry) => entry.date == todayKey).toList();

    if (existing.isNotEmpty) {
      final diary = existing.first;
      if (!mounted) return;
      
      final apiService = context.read<PokemonApiService>();
      final pokemon = await apiService.getPokemonById(diary.pokemonId);
      
      if (!mounted) return;
      setState(() {
        _todayDiary = diary;
        _currentPokemon = pokemon;
        _isResultMode = true;
        _isInputMode = false;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isResultMode = false;
        _isInputMode = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGacha() async {
    final text = _controller.text.trim();
    
    if (text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write at least 10 characters!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // [Step 1] 즉시 UI 전환
    setState(() {
      _isInputMode = false; 
      _isGachaAnimating = true; 
    });
    
    _blinkController.repeat(reverse: true);

    // [Step 2] 로직 수행 & 프리로딩 시작
    final logicFuture = _performGachaLogic(text);

    // [Phase 1] 회전 및 점멸 대기 (2.5초)
    await Future.delayed(const Duration(milliseconds: 2500));

    // ★ 중요: 번개 치기 전에 어떤 포켓몬인지 먼저 확인해서 색깔 결정!
    final resultData = await logicFuture;
    final pokemon = resultData['pokemon'] as Pokemon;

    // 등급별 애니메이션 선택 로직
    String lightningFile = 'assets/animations/gray_lightning.json'; // Default: Normal
    if (pokemon.isMythical) {
      lightningFile = 'assets/animations/purple_lightning.json'; // Mythical
    } else if (pokemon.isLegendary) {
      lightningFile = 'assets/animations/yellow_lightning.json'; // Legendary
    }

    // [Phase 2] 번개 효과로 전환
    _blinkController.stop(); 
    
    setState(() {
      _currentLightningAnim = lightningFile; // 결정된 애니메이션 설정
      _showLightning = true; 
    });

    // 이미지 프리로딩 (번개 치는 동안 다운로드)
    if (mounted) {
      await precacheImage(NetworkImage(pokemon.homeSpriteUrl), context);
    }

    // [Phase 3] 번개 지속 시간 (2.5초)
    await Future.delayed(const Duration(milliseconds: 2500));

    // [Final] 결과 반영
    final diary = resultData['diary'] as Diary;
    await DbHelper.instance.insertDiary(diary);
    if(mounted) {
       await context.read<DiaryProvider>().refreshDiaries();
    }

    if (!mounted) return;
    setState(() {
      _todayDiary = diary;
      _currentPokemon = pokemon;
      _isResultMode = true;
      _isGachaAnimating = false;
      _showLightning = false;
    });
  }

  Future<Map<String, dynamic>> _performGachaLogic(String text) async {
    final sentiment = _sentimentService.analyzeSentiment(text);
    final apiService = context.read<PokemonApiService>();
    final pokemonId = await _gachaLogic.draftRandomPokemon(sentiment, apiService);
    final pokemon = await apiService.getPokemonById(pokemonId);

    final diary = Diary(
      date: _formatDate(DateTime.now()),
      content: text,
      sentiment: sentiment,
      pokemonId: pokemonId,
    );

    return {'diary': diary, 'pokemon': pokemon};
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    // --- [Section 1: Top Visual] ---
                    SizedBox(
                      height: 220,
                      child: Center(
                        child: _buildTopVisual(), 
                      ),
                    ),
                    
                    if (_isResultMode && _currentPokemon != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _currentPokemon!.englishName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ] else if (_isGachaAnimating) ...[
                       const SizedBox(height: 12),
                       const Text(
                         "Finding your companion...",
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.w600,
                           color: Colors.grey,
                         ),
                       ),
                    ],

                    const SizedBox(height: 20),

                    // --- [Section 2: Main Card] ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                      child: !_isInputMode
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: 0.3,
                                  child: Image.asset(
                                    'assets/images/poke-ball.png',
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Text(
                                  _todayDiary?.content ?? _controller.text,
                                  style: const TextStyle(
                                    fontSize: 16, color: Colors.black87, height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : TextField(
                              controller: _controller,
                              enabled: true,
                              maxLines: 8,
                              minLines: 4,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'How are you feeling today? Share your thoughts to find your Pokemon companion...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- [Section 3: Button] ---
                    if (_isInputMode)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleGacha,
                          icon: const Icon(Icons.catching_pokemon),
                          label: const Text('Gacha! Analyze Emotion'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE74C3C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,
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

  Widget _buildTopVisual() {
    if (_isResultMode && _currentPokemon != null) {
      return Image.network(
        _currentPokemon!.homeSpriteUrl,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    
    if (_isGachaAnimating) {
      if (_showLightning) {
        // ★ 수정 포인트: 결정된 이펙트 파일 재생
        return Lottie.asset(
          _currentLightningAnim, 
          height: 220,
          fit: BoxFit.contain,
        );
      } else {
        return Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Pokeball loading animation.json',
              height: 180,
              fit: BoxFit.contain,
            ),
            AnimatedBuilder(
              animation: _blinkAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _blinkAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }
    }

    return Lottie.asset(
      'assets/animations/Pokeball loading animation.json',
      height: 180,
      fit: BoxFit.contain,
      animate: false,
    );
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}