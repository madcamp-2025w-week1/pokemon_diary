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

  TrainerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('trainer_name') ?? "RED";
    _gender = prefs.getString('trainer_gender') ?? "MALE";

    String? savedDebut = prefs.getString('trainer_debut');
    if (savedDebut != null) {
      _debutDate = savedDebut;
    } else {
      final diaries = await DbHelper.instance.getDiaries();
      if (diaries.isNotEmpty) {
        _debutDate = diaries.last.date; 
        await prefs.setString('trainer_debut', _debutDate); 
      } else {
        _debutDate = "NOT STARTED";
      }
    }

    final allDiaries = await DbHelper.instance.getDiaries();
    final allPokemon = await _pokemonService.getAllPokemon();
    final Map<int, Pokemon> pokemonMap = {
      for (var p in allPokemon) p.id: p
    };

    _streak = calculateStreak(allDiaries);

    // Calculate badges with KEYS instead of raw text
    _badges = _calculateBadges(allDiaries, _streak, pokemonMap);

    final List<String> knownBadgeIds = prefs.getStringList('trainer_known_badges') ?? [];
    
    _newlyUnlockedBadges = []; 
    List<String> updatedKnownBadges = List.from(knownBadgeIds);
    bool needsSave = false;

    for (var badge in _badges) {
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

  void clearNewBadges() {
    _newlyUnlockedBadges = [];
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    _name = newName.toUpperCase();
    notifyListeners(); 
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_name', _name); 
  }

  Future<void> updateGender(String newGender) async {
    _gender = newGender.toUpperCase();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trainer_gender', _gender);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> refreshData() async {
    await _loadData(); 
  }

  int calculateStreak(List<Diary> diaries) {
    if (diaries.isEmpty) return 0;
    diaries.sort((a, b) => b.date.compareTo(a.date));

    final uniqueDates = diaries.map((e) => e.date).toSet().toList();
    
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final lastEntryDate = DateTime.parse(uniqueDates.first); 

    if (_dateOnly(lastEntryDate).isBefore(yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final current = DateTime.parse(uniqueDates[i]);
      final next = DateTime.parse(uniqueDates[i + 1]);

      if (_dateOnly(current).subtract(const Duration(days: 1)) == _dateOnly(next)) {
        streak++;
      } else {
        break; 
      }
    }
    return streak;
  }

  List<PokemonBadge> _calculateBadges(List<Diary> diaries, int currentStreak, Map<int, Pokemon> pokemonMap) {
    String getType(int id) => pokemonMap[id]?.type1.toString().toLowerCase() ?? 'normal';

    final uniqueTypes = diaries.map((d) => getType(d.pokemonId)).toSet();
    final uniqueEmotions = diaries.map((d) => d.sentiment.toLowerCase()).toSet();
    final angryCount = diaries.where((d) => d.sentiment.toLowerCase() == 'angry').length;

    int maxElectricStreak = getMaxElectricStreak(diaries, pokemonMap);

    // HERE IS THE CHANGE: Using KEYS instead of English Text
    return [
      PokemonBadge(
        id: 'boulder',
        name: 'BADGE_BOULDER_NAME',
        description: 'BADGE_BOULDER_DESC',
        icon: Icons.hexagon, 
        isUnlocked: diaries.length >= 7,
      ),
      PokemonBadge(
        id: 'cascade',
        name: 'BADGE_CASCADE_NAME',
        description: 'BADGE_CASCADE_DESC',
        icon: Icons.water_drop,
        isUnlocked: uniqueEmotions.containsAll(['joy', 'sad', 'angry', 'calm']),
      ),
      PokemonBadge(
        id: 'thunder',
        name: 'BADGE_THUNDER_NAME',
        description: 'BADGE_THUNDER_DESC',
        icon: Icons.bolt,
        isUnlocked: maxElectricStreak >= 3,
      ),
      PokemonBadge(
        id: 'rainbow',
        name: 'BADGE_RAINBOW_NAME',
        description: 'BADGE_RAINBOW_DESC',
        icon: Icons.grass, 
        isUnlocked: uniqueTypes.length >= 10,
      ),
      PokemonBadge(
        id: 'soul',
        name: 'BADGE_SOUL_NAME',
        description: 'BADGE_SOUL_DESC',
        icon: Icons.favorite,
        isUnlocked: diaries.any((d) => d.content.length > 500),
      ),
      PokemonBadge(
        id: 'marsh',
        name: 'BADGE_MARSH_NAME',
        description: 'BADGE_MARSH_DESC',
        icon: Icons.psychology,
        isUnlocked: currentStreak >= 30,
      ),
      PokemonBadge(
        id: 'volcano',
        name: 'BADGE_VOLCANO_NAME',
        description: 'BADGE_VOLCANO_DESC',
        icon: Icons.local_fire_department,
        isUnlocked: angryCount >= 5,
      ),
      PokemonBadge(
        id: 'earth',
        name: 'BADGE_EARTH_NAME',
        description: 'BADGE_EARTH_DESC',
        icon: Icons.public, 
        isUnlocked: diaries.length >= 50,
      ),
    ];
  }

  int getMaxElectricStreak(List<Diary> diaries, Map<int, Pokemon> pokemonMap) {
    int maxElectricStreak = 0;
    int currentElectricStreak = 0;
    List<Diary> sorted = List.from(diaries)..sort((a, b) => a.date.compareTo(b.date));
    
    String getType(int id) => pokemonMap[id]?.type1.toString().toLowerCase() ?? 'normal';

    for (int i = 0; i < sorted.length; i++) {
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
}