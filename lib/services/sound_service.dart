// lib/services/sound_service.dart

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(2.5);
  }

  Future<void> playBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  // ★ [추가] 일시 정지 (백그라운드 갈 때)
  Future<void> pauseBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) {
      await _bgmPlayer.pause();
    }
  }

  // ★ [추가] 다시 재생 (앱 돌아올 때)
  Future<void> resumeBgm() async {
    if (_bgmPlayer.state == PlayerState.paused) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
  
  // ... 기존 효과음 메서드들 ...
}