import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sound_service.dart';
import '../utils/utils.dart';

class SettingsProvider extends ChangeNotifier {
  // Defaults
  String _languageCode = 'en';
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.5;
  String _bgmTrack = 'sounds/bgm_main_8bit.mp3';
  bool _isRetroArt = false;

  // Getters
  String get languageCode => _languageCode;
  bool get isKorean => _languageCode == 'ko';
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  String get bgmTrack => _bgmTrack;
  bool get isRetroArt => _isRetroArt;

  SettingsProvider() {
    _loadSettings();
  }

  // --- Localization Helper ---
  String getText(String key) => UiText.get(key, _languageCode);

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _languageCode = prefs.getString('setting_language') ?? 'en';
    _bgmVolume = prefs.getDouble('setting_bgm_vol') ?? 0.4;
    _sfxVolume = prefs.getDouble('setting_sfx_vol') ?? 0.2;
    _bgmTrack = prefs.getString('setting_bgm_track') ?? 'sounds/bgm_main_8bit.mp3';
    _isRetroArt = prefs.getBool('setting_retro_art') ?? false;

    // Apply sound settings immediately to the service
    final sound = SoundService();
    await sound.setBgmVolume(_bgmVolume);
    await sound.setSfxVolume(_sfxVolume);
    // Note: We don't auto-play BGM here; HomeScreen handles that
    
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'ko') return;
    _languageCode = code;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_language', _languageCode);
    notifyListeners();
  }

  Future<void> setBgmVolume(double value) async {
    _bgmVolume = value;
    await SoundService().setBgmVolume(value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('setting_bgm_vol', value);
    notifyListeners();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value;
    await SoundService().setSfxVolume(value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('setting_sfx_vol', value);
    notifyListeners();
  }

  Future<void> setBgmTrack(String track) async {
    _bgmTrack = track;
    await SoundService().playBgm(track); // Preview/Change immediately
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_bgm_track', track);
    notifyListeners();
  }

  Future<void> setRetroArt(bool value) async {
    if (_isRetroArt == value) return;
    _isRetroArt = value;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setting_retro_art', value);
    notifyListeners();
  }
}