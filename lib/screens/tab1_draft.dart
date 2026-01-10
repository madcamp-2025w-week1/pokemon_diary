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
  
  // 애니메이션 상태 관리
  bool _isGachaAnimating = false;
  bool _showLightning = false;
  
  Diary? _todayDiary;
  Pokemon? _currentPokemon;

  // 점멸 효과(Blinking) 컨트롤러
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

    if (false/*existing.isNotEmpty*/) {
      final diary = existing.first;
      if (!mounted) return;
      
      final apiService = context.read<PokemonApiService>();
      final pokemon = await apiService.getPokemonById(diary.pokemonId);
      
      if (!mounted) return;
      setState(() {
        _todayDiary = diary;
        _currentPokemon = pokemon;
        _isResultMode = true;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isResultMode = false;
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

    // 1. 애니메이션 시작
    setState(() {
      _isGachaAnimating = true; 
    });
    
    _blinkController.repeat(reverse: true);

    final sentiment = _sentimentService.analyzeSentiment(text);
    final apiService = context.read<PokemonApiService>();
    final pokemonId = await _gachaLogic.draftRandomPokemon(sentiment, apiService);
    final pokemon = await apiService.getPokemonById(pokemonId);

    // [Phase 1] 회전 및 점멸 대기 (2.5초)
    await Future.delayed(const Duration(milliseconds: 2500));

    // [Phase 2] 번개 효과로 전환
    _blinkController.stop(); 
    setState(() {
      _showLightning = true; 
    });

    // ★ 수정됨: 번개 시간 2.5초로 연장 (기존 1.2초)
    await Future.delayed(const Duration(milliseconds: 2500));

    final diary = Diary(
      date: _formatDate(DateTime.now()),
      content: text,
      sentiment: sentiment,
      pokemonId: pokemonId,
    );
    await DbHelper.instance.insertDiary(diary);
    await context.read<DiaryProvider>().refreshDiaries();

    if (!mounted) return;
    setState(() {
      _todayDiary = diary;
      _currentPokemon = pokemon;
      _isResultMode = true;
      _isGachaAnimating = false;
      _showLightning = false;
    });
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
                    // --- [Section 1: Dynamic Top Area] ---
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
                      child: _isResultMode && _todayDiary != null
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
                                  _todayDiary!.content,
                                  style: const TextStyle(
                                    fontSize: 16, color: Colors.black87, height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : TextField(
                              controller: _controller,
                              enabled: !_isGachaAnimating,
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
                    if (!_isResultMode && !_isGachaAnimating)
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
                      )
                    else if (_isGachaAnimating)
                       const Text(
                         "Analyzing your emotions...",
                         style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
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
    // 1. 결과 모드: 포켓몬 이미지
    if (_isResultMode && _todayDiary != null && _currentPokemon != null) {
      return Image.network(
        _currentPokemon!.homeSpriteUrl,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    
    // 2. 가챠 애니메이션 진행 중
    if (_isGachaAnimating) {
      if (_showLightning) {
        // [Phase 2] 번개 애니메이션 (2.5초간 지속)
        return Lottie.asset(
          'assets/animations/Pikachu lightning.json',
          height: 220,
          fit: BoxFit.contain,
        );
      } else {
        // [Phase 1] 회전하는 몬스터볼 + 점멸
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

    // [입력 모드] 정적 이미지 대신 Lottie를 멈춘 상태로 출력
    return Lottie.asset(
      'assets/animations/Pokeball loading animation.json',
      height: 180,
      fit: BoxFit.contain,
      animate: false, // 여기서 애니메이션을 끄면 0번 프레임(정적 이미지)으로 나옴
    );
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}
