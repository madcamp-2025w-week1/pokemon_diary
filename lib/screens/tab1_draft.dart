import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/diary_model.dart';
import '../services/api_service.dart';
import '../services/db_helper.dart';
import '../services/gacha_logic.dart';
import '../services/sentiment_service.dart';

class Tab1Draft extends StatefulWidget {
  const Tab1Draft({super.key});

  @override
  State<Tab1Draft> createState() => _Tab1DraftState();
}

class _Tab1DraftState extends State<Tab1Draft> {
  final TextEditingController _controller = TextEditingController();
  final SentimentService _sentimentService = SentimentService();
  final GachaLogic _gachaLogic = GachaLogic();

  bool _isLoading = true;
  bool _isResultMode = false;
  Diary? _todayDiary;
  String? _pokemonName;

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 오늘 작성한 일기가 있는지 확인
  Future<void> _loadTodayEntry() async {
    final todayKey = _formatDate(DateTime.now());
    final diaries = await DbHelper.instance.getDiaries();
    final existing = diaries.where((entry) => entry.date == todayKey).toList();

    if (existing.isNotEmpty) {
      final diary = existing.first;
      if (!mounted) return;
      
      // 이미 일기가 있다면 포켓몬 정보 로드 후 결과 모드로 전환
      final apiService = context.read<PokemonApiService>();
      final pokemon = await apiService.getPokemonById(diary.pokemonId);
      
      if (!mounted) return;
      setState(() {
        _todayDiary = diary;
        _pokemonName = pokemon?.englishName ?? 'Unknown';
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

  // 가챠 버튼 클릭 핸들러
  Future<void> _handleGacha() async {
    final text = _controller.text.trim();
    
    // 유효성 검사: 10자 미만이면 스낵바 표시
    if (text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please write at least 10 characters to analyze emotion!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 로직 실행 (감정 분석 -> 포켓몬 뽑기)
    final sentiment = _sentimentService.analyzeSentiment(text);
    final pokemonId = _gachaLogic.draftRandomPokemon();
    debugPrint('Mock sentiment: $sentiment, Pokemon ID: $pokemonId');

    final diary = Diary(
      date: _formatDate(DateTime.now()),
      content: text,
      sentiment: sentiment,
      pokemonId: pokemonId,
    );

    // DB 저장
    await DbHelper.instance.insertDiary(diary);

    if (!mounted) return;
    final apiService = context.read<PokemonApiService>();
    final pokemon = await apiService.getPokemonById(pokemonId);
    
    if (!mounted) return;
    setState(() {
      _todayDiary = diary;
      _pokemonName = pokemon?.englishName ?? 'Unknown';
      _isResultMode = true;
      _isLoading = false;
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
                    // --- [Section 1: Result Only] Top Pokemon Image ---
                    if (_isResultMode && _todayDiary != null)
                      Image.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/${_todayDiary!.pokemonId}.png',
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.catching_pokemon, size: 180);
                        },
                      ),
                    
                    if (_isResultMode && _pokemonName != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _pokemonName!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // --- [Section 2: Main Card (Input OR Result Text)] ---
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
                      // ★ 핵심 수정 사항: 결과 모드일 때와 입력 모드일 때의 child 분기 처리 ★
                      child: _isResultMode && _todayDiary != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                // 1. Background Watermark (Result Mode Only)
                                Opacity(
                                  opacity: 0.2, // 은은하게 20% 투명도
                                  child: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Pok%C3%A9_Ball_icon.svg/512px-Pok%C3%A9_Ball_icon.svg.png',
                                    height: 200,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // 로드 실패 시 아이콘으로 대체
                                      return const Icon(
                                        Icons.catching_pokemon, 
                                        size: 150, 
                                        color: Colors.redAccent
                                      );
                                    },
                                  ),
                                ),
                                // 2. Read-only Text
                                Text(
                                  _todayDiary!.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : TextField(
                              controller: _controller,
                              maxLines: 8, // 입력창을 넉넉하게
                              minLines: 4,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                // 요청한 긴 텍스트를 hintText로 이동
                                hintText: 'How are you feeling today? Share your thoughts to find your Pokemon companion...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                                border: InputBorder.none, // 카드 안에 깔끔하게
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- [Section 3: Gacha Button (Input Mode Only)] ---
                    if (!_isResultMode)
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}