import 'package:audioplayers/audioplayers.dart';

class SoundService {
  // 싱글톤 패턴: 앱 어디서든 SoundService()로 부르면 같은 녀석이 나옴
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // 초기화 및 설정
  Future<void> init() async {
    // 1. 반복 모드 설정 (1분짜리 곡이 끝나면 자동으로 다시 시작)
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    // 2. 볼륨 설정 (0.0 ~ 1.0) 
    // BGM은 배경에 깔려야 하므로 0.3 ~ 0.5 정도가 적당해.
    await _bgmPlayer.setVolume(0.4);
  }

  // BGM 재생
  Future<void> playBgm() async {
    // 이미 재생 중이라면 중복 실행 방지
    if (_bgmPlayer.state == PlayerState.playing) return;

    // 'assets/sounds/' 경로는 AssetSource가 알아서 찾아줌
    // 실제 파일 경로: lib/assets/sounds/bgm_main_8bit.mp3 (pubspec 등록 기준)
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  // BGM 정지 (필요할 때 호출)
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
  
  // (나중에 효과음 메서드들도 여기에 추가하면 돼)
}