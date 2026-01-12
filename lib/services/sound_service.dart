import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  // 효과음 전용 플레이어 (미리 생성해서 메모리에 올려둠)
  final AudioPlayer _tabSfxPlayer = AudioPlayer();

  Future<void> init() async {
    // 1. 오디오 컨텍스트 설정 (BGM과 효과음 믹싱)
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, 
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
    ));

    // 2. BGM 설정
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.4);

    // 3. 효과음 플레이어 미리 세팅
    // ★ PlayerMode.lowLatency: 짧은 효과음 전용 모드 (필수)
    await _tabSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _tabSfxPlayer.setVolume(1.0);
    
    // ★ 핵심: 파일을 미리 한 번 로드해서 캐시에 등록해둠 (이걸 해두면 나중에 play 할 때 빠름)
    // 소리는 안 내고 로드만 하는 꼼수야.
    await _tabSfxPlayer.setSource(AssetSource('sounds/tab_switching.wav'));
  }

  Future<void> playBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  // ★ [수정된 로직]
  Future<void> playTabSound() async {
    // 1. 만약 이전 소리가 재생 중이면 즉시 끊어서 리셋 (반응속도 향상)
    if (_tabSfxPlayer.state == PlayerState.playing) {
      await _tabSfxPlayer.stop();
    }
    
    // 2. resume() 대신 play() 사용!
    // AssetSource를 쓰면 내부적으로 캐싱된 파일을 쓰기 때문에 딜레이가 거의 없음
    await _tabSfxPlayer.play(AssetSource('sounds/tab_switching.wav'));
  }

  Future<void> pauseBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) {
      await _bgmPlayer.pause();
    }
  }

  Future<void> resumeBgm() async {
    if (_bgmPlayer.state == PlayerState.paused) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
}