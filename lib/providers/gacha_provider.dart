import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'diary_provider.dart';
import 'trainer_provider.dart';

class GachaProvider extends ChangeNotifier {
  // --- Dependencies ---
  final SentimentService _sentimentService = SentimentService();
  final GachaLogic _gachaLogic = GachaLogic();

  // --- State Variables ---
  bool _isLoading = true;
  bool _isResultMode = false; // True when showing the Pokemon card
  bool _isInputMode = true;   // True when showing the text field
  
  // Animation States
  bool _isGachaAnimating = false;
  bool _showLightning = false;
  String _currentLightningAnim = 'assets/animations/gray_lightning.json';

  // Data
  Diary? _todayDiary;
  Pokemon? _currentPokemon;

  // Queue for badges to show in UI (for popup once obtained for the first time)
  final List<PokemonBadge> _pendingBadges = [];

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isResultMode => _isResultMode;
  bool get isInputMode => _isInputMode;
  bool get isGachaAnimating => _isGachaAnimating;
  bool get showLightning => _showLightning;
  String get currentLightningAnim => _currentLightningAnim;
  Diary? get todayDiary => _todayDiary;
  Pokemon? get currentPokemon => _currentPokemon;
  List<PokemonBadge> get pendingBadges => List.unmodifiable(_pendingBadges);

  // --- Methods ---

  /// Clears the badge queue after they have been shown
  void clearPendingBadges() {
    _pendingBadges.clear();
  }

  /// Checks if the user has already drafted today
  Future<void> loadTodayEntry(DiaryProvider diaryProvider, PokemonApiService apiService) async {
    _isLoading = true;
    notifyListeners();

    // Ensure diary provider is loaded first
    if (diaryProvider.diaries.isEmpty) {
        await diaryProvider.loadDiaries();
    }

    final todayKey = _formatDate(DateTime.now());
    
    // Check local cache in DiaryProvider instead of querying DB again
    final existing = diaryProvider.diaries.where((entry) => entry.date == todayKey).toList();

    if (false /*existing.isNotEmpty*/) {
      final diary = existing.first;
      // We need to fetch the Pokemon details to display the result card
      final pokemon = await apiService.getPokemonById(diary.pokemonId);

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

  /// The main action: Analyzes text -> Drafts Pokemon -> Animates -> Saves
  Future<void> performGacha({
    required String text,
    required DiaryProvider diaryProvider,
    required TrainerProvider trainerProvider,
    required PokemonApiService apiService,
    required Function(String) onError, // Callback for UI errors (e.g. Snackbars)
  }) async {
    
    if (text.trim().length < 10) {
      onError('Please write at least 10 characters!');
      return;
    }

    // 1. Start Animation State
    _isInputMode = false;
    _isGachaAnimating = true;
    notifyListeners();

    // 2. Perform Logic (Parallel to animation)
    // We calculate the result early, but wait for animation to reveal it.
    final logicFuture = _performGachaLogic(text, apiService);

    // Wait for "scanning" phase (2.5s)
    await Future.delayed(const Duration(milliseconds: 2500));

    // Retrieve results
    final resultData = await logicFuture;
    final diary = resultData['diary'] as Diary;
    final pokemon = resultData['pokemon'] as Pokemon;

    // 3. Determine Lightning Color based on Rarity
    if (pokemon.isMythical) {
      _currentLightningAnim = 'assets/animations/purple_lightning.json';
    } else if (pokemon.isLegendary) {
      _currentLightningAnim = 'assets/animations/yellow_lightning.json';
    } else {
      _currentLightningAnim = 'assets/animations/gray_lightning.json';
    }
    
    _showLightning = true;
    notifyListeners();

    // 4. Reveal Phase (Lightning Animation)
    // Delay to let the lightning play before showing the card
    await Future.delayed(const Duration(milliseconds: 2500));

    // 5. Save Data using DbHelper (accessed via Services export)
    await DbHelper.instance.insertDiary(diary);

    // 6. Refresh Providers so other tabs update immediately
    await diaryProvider.refreshDiaries();
    await trainerProvider.refreshData();

    // 7. Check for New Badges
    if (trainerProvider.newlyUnlockedBadges.isNotEmpty) {
      _pendingBadges.addAll(trainerProvider.newlyUnlockedBadges);
      trainerProvider.clearNewBadges();
    }

    // 8. Final State Update
    _todayDiary = diary;
    _currentPokemon = pokemon;
    _isResultMode = true;
    _isGachaAnimating = false;
    _showLightning = false;
    
    notifyListeners();
  }

  /// Internal helper to orchestrate the Services
  Future<Map<String, dynamic>> _performGachaLogic(String text, PokemonApiService apiService) async {
    final sentiment = await _sentimentService.analyzeSentiment(text);
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

  // Helper for DB Date Format (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}