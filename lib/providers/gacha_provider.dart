import 'package:flutter/material.dart';
import 'package:translator/translator.dart'; // <--- 1. Import Translator

import '../models/models.dart';
import '../services/sound_service.dart';
import '../services/services.dart';
import 'diary_provider.dart';
import 'trainer_provider.dart';

class GachaProvider extends ChangeNotifier {
  // --- Dependencies ---
  final SentimentService _sentimentService = SentimentService();
  final GachaLogic _gachaLogic = GachaLogic();
  final GoogleTranslator _translator = GoogleTranslator(); // <--- 2. Instantiate Translator

  // --- State Variables ---
  bool _isLoading = true;
  bool _isResultMode = false;
  bool _isInputMode = true;
  
  // Animation States
  bool _isGachaAnimating = false;
  bool _showLightning = false;
  bool _isRevealing = false;
  String _currentLightningAnim = 'assets/animations/gray_lightning.json';

  // Data
  Diary? _todayDiary;
  Pokemon? _currentPokemon;

  final List<PokemonBadge> _pendingBadges = [];

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isResultMode => _isResultMode;
  bool get isInputMode => _isInputMode;
  bool get isGachaAnimating => _isGachaAnimating;
  bool get showLightning => _showLightning;
  bool get isRevealing => _isRevealing;
  String get currentLightningAnim => _currentLightningAnim;
  Diary? get todayDiary => _todayDiary;
  Pokemon? get currentPokemon => _currentPokemon;
  List<PokemonBadge> get pendingBadges => List.unmodifiable(_pendingBadges);

  // --- Methods ---

  void clearPendingBadges() {
    _pendingBadges.clear();
  }

  Future<void> refreshCurrentPokemon(PokemonApiService apiService, bool isRetro) async {
    if (_currentPokemon != null) {
      final updated = await apiService.getPokemonById(_currentPokemon!.id, isRetro: isRetro);
      if (updated != null) {
        _currentPokemon = updated;
        notifyListeners();
      }
    }
  }

  void finishReveal() {
    if (_isRevealing) {
      _isRevealing = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayEntry({
    required DiaryProvider diaryProvider, 
    required PokemonApiService apiService,
    required bool isRetro,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (diaryProvider.diaries.isEmpty) {
        await diaryProvider.loadDiaries();
    }

    final todayKey = _formatDate(DateTime.now());
    final existing = diaryProvider.diaries.where((entry) => entry.date == todayKey).toList();

    if (existing.isNotEmpty) {
      final diary = existing.first;
      final pokemon = await apiService.getPokemonById(diary.pokemonId, isRetro: isRetro);

      _todayDiary = diary;
      _currentPokemon = pokemon;
      _isResultMode = true;
      _isInputMode = false;
    } else {
      _isResultMode = false;
      _isInputMode = true;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> performGacha({
    required String text,
    required DiaryProvider diaryProvider,
    required TrainerProvider trainerProvider,
    required PokemonApiService apiService,
    required bool isRetro,
    required Function(String) onError,
  }) async {
    
    if (text.trim().length < 10) {
      onError('Please write at least 10 characters!');
      return;
    }

    final soundService = SoundService();

    const scanDuration = Duration(milliseconds: 3400);
    const lightningDuration = Duration(seconds: 2);

    await soundService.duckBgm();
    _isInputMode = false;
    _isResultMode = false;
    _isGachaAnimating = true;
    _showLightning = false;
    _isRevealing = false;
    notifyListeners();

    final logicFuture = _performGachaLogic(text, apiService, isRetro: isRetro);

    soundService.playPokeballSpin();
    await Future.delayed(scanDuration);
    await soundService.stopPokeballSpin();

    final resultData = await logicFuture;
    final diary = resultData['diary'] as Diary;
    final pokemon = resultData['pokemon'] as Pokemon;

    if (pokemon.isMythical) {
      _currentLightningAnim = 'assets/animations/purple_lightning.json';
    } else if (pokemon.isLegendary) {
      _currentLightningAnim = 'assets/animations/yellow_lightning.json';
    } else {
      _currentLightningAnim = 'assets/animations/gray_lightning.json';
    }
    
    _showLightning = true;
    notifyListeners();

    soundService.playElectricShock();
    await Future.delayed(lightningDuration);
    _showLightning = false;
    _todayDiary = diary;
    _currentPokemon = pokemon;
    _isResultMode = true;
    _isGachaAnimating = false;
    _isRevealing = true;
    notifyListeners();

    await DbHelper.instance.insertDiary(diary);

    await diaryProvider.refreshDiaries();
    await trainerProvider.refreshData();

    if (trainerProvider.newlyUnlockedBadges.isNotEmpty) {
      _pendingBadges.addAll(trainerProvider.newlyUnlockedBadges);
      trainerProvider.clearNewBadges();
    }

    notifyListeners();
  }

  /// Internal helper to orchestrate the Services
  Future<Map<String, dynamic>> _performGachaLogic(String text, PokemonApiService apiService, {required bool isRetro}) async {
    
    // --- 3. Translation Logic ---
    String textForAnalysis = text;
    
    // Regex to detect Korean characters (Hangul Syllables)
    if (RegExp(r'[가-힣]').hasMatch(text)) {
      try {
        final translation = await _translator.translate(text, to: 'en');
        textForAnalysis = translation.text;
        debugPrint(textForAnalysis);
      } catch (e) {
        debugPrint("Translation failed: $e");
        // Fallback: Proceed with original text (or handle error as needed)
      }
    }
    // -----------------------------

    // Analyze the (potentially translated) text
    final sentiment = await _sentimentService.analyzeSentiment(textForAnalysis);
    
    final pokemonId = await _gachaLogic.draftRandomPokemon(sentiment, apiService);
    final pokemon = await apiService.getPokemonById(pokemonId, isRetro: isRetro);

    final diary = Diary(
      date: _formatDate(DateTime.now()),
      content: text, // Save the ORIGINAL text, not the translated one
      sentiment: sentiment,
      pokemonId: pokemonId,
    );

    return {'diary': diary, 'pokemon': pokemon!};
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}