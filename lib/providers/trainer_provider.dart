import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

class TrainerProvider with ChangeNotifier {
  String _name = "RED";
  String _gender = "MALE";
  String _debutDate = "???"; 
  int _streak = 0;
  List<PokemonBadge> _badges = [];

  List<PokemonBadge> _newlyUnlockedBadges = [];

  String get name => _name;
  String get gender => _gender;
  String get debutDate => _debutDate;
  int get streak => _streak;
  List<PokemonBadge> get badges => _badges;
  List<PokemonBadge> get newlyUnlockedBadges => _newlyUnlockedBadges;

  final _pokemonService = PokemonApiService();

  // 1. Load data immediately when the Provider is created
  TrainerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to load saved data, otherwise fallback to defaults
    _name = prefs.getString('trainer_name') ?? "RED";
    _gender = prefs.getString('trainer_gender') ?? "MALE";

    // load debut date 
    String? savedDebut = prefs.getString('trainer_debut');
    if (savedDebut != null) {
      _debutDate = savedDebut;
    } else {
      // Not in prefs? Check DB (First time run logic)
      final diaries = await DbHelper.instance.getDiaries();
      if (diaries.isNotEmpty) {
        // Diaries are usually sorted ID DESC (Newest first), so Last is Oldest
        _debutDate = diaries.last.date; 
        // Save to prefs so we never query DB for this again
        await prefs.setString('trainer_debut', _debutDate); 
      } else {
        _debutDate = "NOT STARTED";
      }
    }

    // calculate data 
    final allDiaries = await DbHelper.instance.getDiaries();
    final allPokemon = await _pokemonService.getAllPokemon();
    final Map<int, Pokemon> pokemonMap = {
      for (var p in allPokemon) p.id: p
    };

    _streak = calculateStreak(allDiaries);

    final freshBadges = _calculateBadges(allDiaries, _streak, pokemonMap);
    _badges = freshBadges;

    // Load the list of badge IDs we already knew about
    final List<String> knownBadgeIds = prefs.getStringList('trainer_known_badges') ?? [];
    
    _newlyUnlockedBadges = []; // Reset the "New" list
    List<String> updatedKnownBadges = List.from(knownBadgeIds);
    bool needsSave = false;

    for (var badge in _badges) {
      // If badge is unlocked NOW, but was NOT in our known list...
      if (badge.isUnlocked && !knownBadgeIds.contains(badge.id)) {
        _newlyUnlockedBadges.add(badge);
        updatedKnownBadges.add(badge.id);
        needsSave = true;
      }
    }

    if (needsSave) {
      await prefs.setStringList('trainer_known_badges', updatedKnownBadges);
    }

    notifyListeners();
  }

  // Call this after showing the popups to clean up
  void clearNewBadges() {
    _newlyUnlockedBadges = [];
    notifyListeners();
  }

  // 2. Update memory AND save to disk
  Future<void> updateName(String newName) async {
    _name = newName.toUpperCase();
    notifyListeners(); // Update UI immediately
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_name', _name); // Save permanently
  }

  Future<void> updateGender(String newGender) async {
    _gender = newGender.toUpperCase();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_gender', _gender);
  }

  // Helper to strip time off a DateTime (keep only YYYY-MM-DD)
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Call this when a new entry is added
  Future<void> refreshData() async {
    await _loadData(); // Re-runs everything including badge calc
  }

  int calculateStreak(List<Diary> diaries) {
    if (diaries.isEmpty) return 0;

    // 1. Sort diaries newest to oldest (just in case)
    // Assumes Diary.date is an ISO8601 string 'YYYY-MM-DD'
    diaries.sort((a, b) => b.date.compareTo(a.date));

    // 2. Get unique dates (in case user wrote 2 entries in 1 day)
    final uniqueDates = diaries.map((e) => e.date).toSet().toList();
    
    // 3. Check the latest entry
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final lastEntryDate = DateTime.parse(uniqueDates.first); // Assuming 'YYYY-MM-DD'

    // If the last entry is older than yesterday, the streak is broken.
    if (_dateOnly(lastEntryDate).isBefore(yesterday)) {
      return 0;
    }

    // 4. Count backwards
    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final current = DateTime.parse(uniqueDates[i]);
      final next = DateTime.parse(uniqueDates[i + 1]);

      // Check if 'next' is exactly 1 day before 'current'
      if (_dateOnly(current).subtract(const Duration(days: 1)) == _dateOnly(next)) {
        streak++;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }

  List<PokemonBadge> _calculateBadges(List<Diary> diaries, int currentStreak, Map<int, Pokemon> pokemonMap) {
    String getType(int id) => pokemonMap[id]?.type1.toString().toLowerCase() ?? 'normal';

    final uniqueTypes = diaries.map((d) => getType(d.pokemonId)).toSet();
    final uniqueEmotions = diaries.map((d) => d.sentiment.toLowerCase()).toSet();
    final angryCount = diaries.where((d) => d.sentiment.toLowerCase() == 'angry').length;

    // Thunder Badge Logic (Check Types using the Map)
    int maxElectricStreak = getMaxElectricStreak(diaries, pokemonMap);

    return [
      // 1. BOULDER (Rock) - Foundation: 7 Days Total
      PokemonBadge(
        id: 'boulder',
        name: 'Boulder Badge',
        description: 'Log entries on 7 different days',
        icon: Icons.hexagon, // Rock shape
        isUnlocked: diaries.length >= 7,
      ),

      // 2. CASCADE (Water) - Flow: All 4 Emotions
      PokemonBadge(
        id: 'cascade',
        name: 'Cascade Badge',
        description: 'Log Joy, Sad, Angry, and Calm',
        icon: Icons.water_drop,
        isUnlocked: uniqueEmotions.containsAll(['joy', 'sad', 'angry', 'calm']),
      ),

      // 3. THUNDER (Electric) - Spark: 3 Day Electric Streak
      PokemonBadge(
        id: 'thunder',
        name: 'Thunder Badge',
        description: '3-day streak of High Energy (Joy)',
        icon: Icons.bolt,
        isUnlocked: maxElectricStreak >= 3,
      ),

      // 4. RAINBOW (Grass/Color) - Diversity: 10 Types
      PokemonBadge(
        id: 'rainbow',
        name: 'Rainbow Badge',
        description: 'Catch 10 unique Pokemon types',
        icon: Icons.grass, // Or Icons.palette
        isUnlocked: uniqueTypes.length >= 10,
      ),

      // 5. SOUL (Heart) - Reflection: 500+ chars
      PokemonBadge(
        id: 'soul',
        name: 'Soul Badge',
        description: 'Write a long entry (>500 chars)',
        icon: Icons.favorite,
        isUnlocked: diaries.any((d) => d.content.length > 500),
      ),

      // 6. MARSH (Psychic) - Discipline: 30 Day Streak
      PokemonBadge(
        id: 'marsh',
        name: 'Marsh Badge',
        description: 'Achieve a 30-day writing streak',
        icon: Icons.psychology,
        isUnlocked: currentStreak >= 30,
      ),

      // 7. VOLCANO (Fire) - Venting: 5 Angry Entries
      PokemonBadge(
        id: 'volcano',
        name: 'Volcano Badge',
        description: 'Log 5 Angry entries',
        icon: Icons.local_fire_department,
        isUnlocked: angryCount >= 5,
      ),

      // 8. EARTH (Ground) - Master: 50 Unique Entries
      PokemonBadge(
        id: 'earth',
        name: 'Earth Badge',
        description: 'Log 50 total entries',
        icon: Icons.public, // Earth icon
        isUnlocked: diaries.length >= 50,
      ),
    ];
    
    }
  }

  int getMaxElectricStreak(List<Diary> diaries, Map<int, Pokemon> pokemonMap) {
    int maxElectricStreak = 0;
    int currentElectricStreak = 0;
    List<Diary> sorted = List.from(diaries)..sort((a, b) => a.date.compareTo(b.date));
    
    String getType(int id) => pokemonMap[id]?.type1.toString().toLowerCase() ?? 'normal';

    for (int i = 0; i < sorted.length; i++) {
       // Look up Type from Map
       String type = getType(sorted[i].pokemonId);
       
       if (type == 'electric') {
         if (i > 0) {
            final prev = DateTime.parse(sorted[i-1].date);
            final curr = DateTime.parse(sorted[i].date);
            if (curr.difference(prev).inDays == 1) {
               currentElectricStreak++;
            } else if (curr.difference(prev).inDays > 1) {
               currentElectricStreak = 1; 
            }
         } else {
            currentElectricStreak = 1;
         }
       } else {
         currentElectricStreak = 0;
       }
       if (currentElectricStreak > maxElectricStreak) maxElectricStreak = currentElectricStreak;

       
    }
    return maxElectricStreak;
}