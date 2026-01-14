import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sound_service.dart';
import '../utils/utils.dart';

class SettingsProvider extends ChangeNotifier {
  // Defaults
  String _languageCode = 'en';
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.5;
  String _bgmTrack = SoundService.defaultTrack; 
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

    // --- BGM 트랙 로드 및 유효성 검사 ---
    String? savedTrack = prefs.getString('setting_bgm_track');
    
    // 1. 저장된 값이 없거나
    // 2. 저장된 파일명이 현재 SoundService 리스트에 없다면 (파일이 삭제된 경우 등)
    // -> 기본값(Pallet Town.mp3)으로 강제 초기화
    if (savedTrack == null || !SoundService().bgmTracks.contains(savedTrack)) {
      _bgmTrack = SoundService.defaultTrack;
      // 잘못된 설정이 있다면 덮어쓰기 (선택 사항)
      await prefs.setString('setting_bgm_track', _bgmTrack);
    } else {
      _bgmTrack = savedTrack;
    }

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

// 트랙 변경 메서드
  Future<void> setBgmTrack(String trackFilename) async {
    // 리스트에 있는 유효한 트랙인지 확인
    if (!SoundService().bgmTracks.contains(trackFilename)) return;

    _bgmTrack = trackFilename;
    await SoundService().playBgm(trackFilename); // 즉시 미리듣기/변경
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_bgm_track', trackFilename);
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