import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pokemon_diary/providers/trainer_provider.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';
import '../services/services.dart';

class Tab1Draft extends StatefulWidget {
  const Tab1Draft({super.key});

  @override
  State<Tab1Draft> createState() => _Tab1DraftState();
}

class _Tab1DraftState extends State<Tab1Draft> with TickerProviderStateMixin {
  static const double _messageBoxHeight = 220;
  final TextEditingController _controller = TextEditingController();
  final SentimentService _sentimentService = SentimentService();
  final GachaLogic _gachaLogic = GachaLogic();

  bool _isLoading = true;
  bool _isResultMode = false;
  bool _isInputMode = true;

  bool _isGachaAnimating = false;
  bool _showLightning = false;

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
    _blinkAnimation =
        Tween<double>(begin: 0.0, end: 0.8).animate(_blinkController);

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

    if (false /*existing.isNotEmpty*/) {
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

    setState(() {
      _isInputMode = false;
      _isGachaAnimating = true;
    });

    _blinkController.repeat(reverse: true);

    final logicFuture = _performGachaLogic(text);

    await Future.delayed(const Duration(milliseconds: 2500));

    final resultData = await logicFuture;
    final pokemon = resultData['pokemon'] as Pokemon;

    String lightningFile = 'assets/animations/gray_lightning.json';
    if (pokemon.isMythical) {
      lightningFile = 'assets/animations/purple_lightning.json';
    } else if (pokemon.isLegendary) {
      lightningFile = 'assets/animations/yellow_lightning.json';
    }

    _blinkController.stop();

    setState(() {
      _currentLightningAnim = lightningFile;
      _showLightning = true;
    });

    if (mounted) {
      await precacheImage(NetworkImage(pokemon.homeSpriteUrl), context);
    }

    await Future.delayed(const Duration(milliseconds: 2500));

    final diary = resultData['diary'] as Diary;
    await DbHelper.instance.insertDiary(diary);
    if (mounted) {
      await context.read<DiaryProvider>().refreshDiaries();
      await context.read<TrainerProvider>().refreshData();
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
    final sentiment = await _sentimentService.analyzeSentiment(text);
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
              child: SizedBox(
                width: constraints.maxWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD93838),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      _buildDraftHeader(),
                      const SizedBox(height: 12),
                      _buildScreen(),
                      const SizedBox(height: 12),
                      _buildStatusLabel(),
                      const SizedBox(height: 12),
                      _buildMessageArea(),
                      const SizedBox(height: 8),
                      _buildControlsRow(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreen() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF355A35),
        border: Border.all(color: const Color(0xFF202020), width: 3),
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF70A070),
          border: Border.all(color: const Color(0xFF1E2B1E), width: 2),
        ),
        height: 220,
        child: Center(
          child: _buildTopVisual(),
        ),
      ),
    );
  }

  Widget _buildDraftHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD93838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF202020),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.catching_pokemon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'DRAFT',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel() {
    final label = _isGachaAnimating
        ? 'SCANNING...'
        : _isResultMode && _currentPokemon != null
            ? '${_currentPokemon!.englishName}'.toUpperCase()
            : 'READY TO ANALYZE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7FB7E8),
        border: Border.all(color: const Color(0xFF202020), width: 2),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.pressStart2p(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMessageArea() {
    if (!_isInputMode) {
      return _buildSpeechBubble(
        _todayDiary?.content ?? _controller.text,
      );
    }

    return SizedBox(
      height: _messageBoxHeight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6EFD8),
          border: Border.all(color: const Color(0xFF202020), width: 2),
        ),
        child: TextField(
          controller: _controller,
          enabled: true,
          maxLines: null,
          expands: true,
          style: GoogleFonts.pressStart2p(
            fontSize: 11,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText:
                'How are you feeling today? Share your thoughts to find your Pokemon companion...'
                    .toUpperCase(),
            hintStyle: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Stack(
      children: [
        SizedBox(
          height: _messageBoxHeight,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EFD8),
              border: Border.all(color: const Color(0xFF202020), width: 2),
            ),
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: GoogleFonts.pressStart2p(
                fontSize: 11,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          bottom: -8,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EFD8),
              border: Border.all(color: const Color(0xFF202020), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 10),
          child: _buildDpad(),
        ),
        const SizedBox(width: 16),
        _buildGachaButton(),
      ],
    );
  }

  Widget _buildDpad() {
    const dpadSize = 90.0;
    const padColor = Color(0xFF2B2B2B);

    return SizedBox(
      width: dpadSize,
      height: dpadSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30,
            height: dpadSize,
            decoration: BoxDecoration(
              color: padColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          Container(
            width: dpadSize,
            height: 30,
            decoration: BoxDecoration(
              color: padColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaButton() {
    final isEnabled = _isInputMode && !_isGachaAnimating;
    final buttonColor =
        isEnabled ? const Color(0xFFF2C94C) : const Color(0xFFB0B0B0);
    final shadowColor = isEnabled ? Colors.black54 : Colors.black26;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: isEnabled ? _handleGacha : null,
          child: Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF202020), width: 3),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'GACHA!',
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ),
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
        return Lottie.asset(
          _currentLightningAnim,
          height: 220,
          fit: BoxFit.contain,
        );
      }
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
